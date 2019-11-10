// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <inc/col.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line

struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "showmappings", "showmappings", showmappings },
	{ "setm", "setmemory", setm },
	{ "showvm", "showvirtualmemory", showvm }
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t *ebp = (uint32_t*) (read_ebp());
	cprintf("%s","Stack backtrace:\n");
	while(ebp != 0x0){
		uint32_t eip = *(ebp+1);
		cprintf("ebp %08.x  eip %08.x  args", ebp, *(ebp+1));
		for(int i = 2; i < 7; ++i){
				cprintf(" %08.x", *(ebp+i));
		}
		cprintf("\n");
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
		cprintf("\t%s:%d: %.*s+%d\n", 
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
		ebp = (uint32_t*) (*ebp);
	}
	return 0;
}

/*****Implementations of extend monitor command *****/

uint32_t
hex2addr(char* buffer){
	uint32_t result = 0;
	buffer += 2;
	while(*buffer != '\0'){
		result *= 16;
		if(*buffer >= 'a'){
			result += *buffer - 'a' + 10;
		}
		else{
			result += *buffer - '0';
		}
		buffer++;
	}
	return result;
}

int
showmappings(int argc, char** argv, struct Trapframe *tf){
	if(argc == 1){
		cprintf("Format: showmappings 0xBEGIN_ADRR 0xEND_ADRR\n");
		return 0;
	}
	else if(argc < 3){
		cprintf("WRONG FORMAT\n");
		return 0;	
	}
	uint32_t beg = hex2addr(argv[1]), end = hex2addr(argv[2]);
	cprintf("BEGIN_ADDR: %x	END_ADDR: %x\n", beg, end);
	while(beg <= end){
		pte_t* pte = pgdir_walk(kern_pgdir, (void*)beg, 1);
		struct PageInfo* pp;
		pp = page_lookup(kern_pgdir, (void*)beg, 0);
		if(pte == NULL)
			panic("OOM");
		if(*pte | PTE_P){
			cprintf("page %x %x		", beg, page2pa(pp));
			cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte&PTE_P, (*pte&PTE_W)>>1, (*pte&PTE_U)>>2);
		}
		else{
			cprintf("page %x	not exist", beg);
		}
		beg += PGSIZE;
	}
	return 0;
}

int
setm(int argc, char** argv, struct Trapframe *tf){
	if(argc == 1){
		cprintf("Format: setm 0xADDR 0(SET)|1(CLEAN) P|W|U\n");
		return 0;
	}
	if(argc < 4){
		cprintf("WRONG FORMAT\n");
		return 0;
	}
	uint32_t addr = hex2addr(argv[1]);
	pte_t* pte = pgdir_walk(kern_pgdir, (void*)addr, 1);
	cprintf("address: %x before setting: ", addr);
	cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte&PTE_P, (*pte&PTE_W)>>1, (*pte&PTE_U)>>2);
	uint32_t perm = 0;
	if(argv[3][0] == 'P'){
		perm = PTE_P;
		cprintf("set present\n");
	}
	else if(argv[3][0] == 'W'){
		perm = PTE_W;
		cprintf("set writable\n");
	}
	else if(argv[3][0] == 'U'){
		perm = PTE_U;
		cprintf("set user\n");
	}
	if(argv[2][0] == '0'){
		*pte &= ~perm;
		cprintf("set zero\n");
	}
	else{
		*pte |= perm;
		cprintf("set positive\n");
	}
	cprintf("address: %x after setting: ", addr);
	cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte&PTE_P, (*pte&PTE_W)>>1, (*pte&PTE_U)>>2);
	return 0;
}

int
showvm(int argc, char** argv, struct Trapframe *tf){
	if(argc == 1){
		cprintf("Format: showvm 0xADDR 0xNUM\n");
		return 0;
	}
	if(argc < 3){
		cprintf("WRONG FORMAT\n");
		return 0;
	}
	void** addr = (void**)hex2addr(argv[1]);
	uint32_t num = hex2addr(argv[2]);
	for(int i = 0; i < num; i++)
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command %s\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type help for a list of commands.\n");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
