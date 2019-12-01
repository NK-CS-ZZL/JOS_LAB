
obj/user/softint：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 10             	sub    $0x10,%esp
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004f:	00 00 00 
	thisenv=envs+ENVX(sys_getenvid());
  800052:	e8 db 00 00 00       	call   800132 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	c1 e0 05             	shl    $0x5,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x3d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	89 74 24 04          	mov    %esi,0x4(%esp)
  80007b:	89 1c 24             	mov    %ebx,(%esp)
  80007e:	e8 b0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800083:	e8 07 00 00 00       	call   80008f <exit>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    

0080008f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009c:	e8 3f 00 00 00       	call   8000e0 <sys_env_destroy>
}
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	89 c6                	mov    %eax,%esi
  8000ba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 d1                	mov    %edx,%ecx
  8000d3:	89 d3                	mov    %edx,%ebx
  8000d5:	89 d7                	mov    %edx,%edi
  8000d7:	89 d6                	mov    %edx,%esi
  8000d9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 cb                	mov    %ecx,%ebx
  8000f8:	89 cf                	mov    %ecx,%edi
  8000fa:	89 ce                	mov    %ecx,%esi
  8000fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 28                	jle    80012a <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800102:	89 44 24 10          	mov    %eax,0x10(%esp)
  800106:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010d:	00 
  80010e:	c7 44 24 08 72 0e 80 	movl   $0x800e72,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011d:	00 
  80011e:	c7 04 24 8f 0e 80 00 	movl   $0x800e8f,(%esp)
  800125:	e8 27 00 00 00       	call   800151 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	83 c4 2c             	add    $0x2c,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800159:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800162:	e8 cb ff ff ff       	call   800132 <sys_getenvid>
  800167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016e:	8b 55 08             	mov    0x8(%ebp),%edx
  800171:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800175:	89 74 24 08          	mov    %esi,0x8(%esp)
  800179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017d:	c7 04 24 a0 0e 80 00 	movl   $0x800ea0,(%esp)
  800184:	e8 c1 00 00 00       	call   80024a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800189:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018d:	8b 45 10             	mov    0x10(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 51 00 00 00       	call   8001e9 <vcprintf>
	cprintf("\n");
  800198:	c7 04 24 c4 0e 80 00 	movl   $0x800ec4,(%esp)
  80019f:	e8 a6 00 00 00       	call   80024a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a4:	cc                   	int3   
  8001a5:	eb fd                	jmp    8001a4 <_panic+0x53>

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 14             	sub    $0x14,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 13                	mov    (%ebx),%edx
  8001b3:	8d 42 01             	lea    0x1(%edx),%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
  8001b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	75 19                	jne    8001df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cd:	00 
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 ca fe ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	83 c4 14             	add    $0x14,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f9:	00 00 00 
	b.cnt = 0;
  8001fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800203:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
  800209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 44 24 08          	mov    %eax,0x8(%esp)
  800214:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	c7 04 24 a7 01 80 00 	movl   $0x8001a7,(%esp)
  800225:	e8 b4 01 00 00       	call   8003de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023a:	89 04 24             	mov    %eax,(%esp)
  80023d:	e8 61 fe ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  800242:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800250:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	e8 87 ff ff ff       	call   8001e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    
  800264:	66 90                	xchg   %ax,%ax
  800266:	66 90                	xchg   %ax,%ax
  800268:	66 90                	xchg   %ax,%ax
  80026a:	66 90                	xchg   %ax,%ax
  80026c:	66 90                	xchg   %ax,%ax
  80026e:	66 90                	xchg   %ax,%ax

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 c3                	mov    %eax,%ebx
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800292:	b9 00 00 00 00       	mov    $0x0,%ecx
  800297:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029d:	39 d9                	cmp    %ebx,%ecx
  80029f:	72 05                	jb     8002a6 <printnum+0x36>
  8002a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a4:	77 69                	ja     80030f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ad:	83 ee 01             	sub    $0x1,%esi
  8002b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002c0:	89 c3                	mov    %eax,%ebx
  8002c2:	89 d6                	mov    %edx,%esi
  8002c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 fc 08 00 00       	call   800be0 <__udivdi3>
  8002e4:	89 d9                	mov    %ebx,%ecx
  8002e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 fa                	mov    %edi,%edx
  8002f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fa:	e8 71 ff ff ff       	call   800270 <printnum>
  8002ff:	eb 1b                	jmp    80031c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	8b 45 18             	mov    0x18(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff d3                	call   *%ebx
  80030d:	eb 03                	jmp    800312 <printnum+0xa2>
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800312:	83 ee 01             	sub    $0x1,%esi
  800315:	85 f6                	test   %esi,%esi
  800317:	7f e8                	jg     800301 <printnum+0x91>
  800319:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800320:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800324:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800327:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	e8 cc 09 00 00       	call   800d10 <__umoddi3>
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	0f be 80 c6 0e 80 00 	movsbl 0x800ec6(%eax),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800355:	ff d0                	call   *%eax
}
  800357:	83 c4 3c             	add    $0x3c,%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800362:	83 fa 01             	cmp    $0x1,%edx
  800365:	7e 0e                	jle    800375 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	8b 52 04             	mov    0x4(%edx),%edx
  800373:	eb 22                	jmp    800397 <getuint+0x38>
	else if (lflag)
  800375:	85 d2                	test   %edx,%edx
  800377:	74 10                	je     800389 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 0e                	jmp    800397 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a8:	73 0a                	jae    8003b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b2:	88 02                	mov    %al,(%edx)
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	e8 02 00 00 00       	call   8003de <vprintfmt>
	va_end(ap);
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	57                   	push   %edi
  8003e2:	56                   	push   %esi
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 3c             	sub    $0x3c,%esp
  8003e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
  8003ea:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
  8003f1:	eb 17                	jmp    80040a <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	0f 84 ca 03 00 00    	je     8007c5 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  8003fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800408:	89 fb                	mov    %edi,%ebx
  80040a:	8d 7b 01             	lea    0x1(%ebx),%edi
  80040d:	0f b6 03             	movzbl (%ebx),%eax
  800410:	83 f8 25             	cmp    $0x25,%eax
  800413:	75 de                	jne    8003f3 <vprintfmt+0x15>
  800415:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800420:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800425:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80042c:	ba 00 00 00 00       	mov    $0x0,%edx
  800431:	eb 18                	jmp    80044b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800435:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800439:	eb 10                	jmp    80044b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043d:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800441:	eb 08                	jmp    80044b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800443:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800446:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8d 5f 01             	lea    0x1(%edi),%ebx
  80044e:	0f b6 07             	movzbl (%edi),%eax
  800451:	0f b6 c8             	movzbl %al,%ecx
  800454:	83 e8 23             	sub    $0x23,%eax
  800457:	3c 55                	cmp    $0x55,%al
  800459:	0f 87 41 03 00 00    	ja     8007a0 <vprintfmt+0x3c2>
  80045f:	0f b6 c0             	movzbl %al,%eax
  800462:	ff 24 85 54 0f 80 00 	jmp    *0x800f54(,%eax,4)
  800469:	89 df                	mov    %ebx,%edi
  80046b:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800470:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800473:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800477:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80047a:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80047d:	83 f8 09             	cmp    $0x9,%eax
  800480:	77 33                	ja     8004b5 <vprintfmt+0xd7>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800482:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800485:	eb e9                	jmp    800470 <vprintfmt+0x92>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 48 04             	lea    0x4(%eax),%ecx
  80048d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800490:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800494:	eb 1f                	jmp    8004b5 <vprintfmt+0xd7>
  800496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800499:	85 c9                	test   %ecx,%ecx
  80049b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a0:	0f 49 c1             	cmovns %ecx,%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	89 df                	mov    %ebx,%edi
  8004a8:	eb a1                	jmp    80044b <vprintfmt+0x6d>
  8004aa:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ac:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8004b3:	eb 96                	jmp    80044b <vprintfmt+0x6d>

		process_precision:
			if (width < 0)
  8004b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b9:	79 90                	jns    80044b <vprintfmt+0x6d>
  8004bb:	eb 86                	jmp    800443 <vprintfmt+0x65>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c2:	eb 87                	jmp    80044b <vprintfmt+0x6d>

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8004cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004d0:	89 74 24 04          	mov    %esi,0x4(%esp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8004d4:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d7:	0b 30                	or     (%eax),%esi
			putch(ch, putdat);
  8004d9:	89 34 24             	mov    %esi,(%esp)
  8004dc:	ff 55 08             	call   *0x8(%ebp)
                  	color=0x0700;
  8004df:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
			break;
  8004e6:	e9 1f ff ff ff       	jmp    80040a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	89 df                	mov    %ebx,%edi
			ch=va_arg(ap,int)|color;
			putch(ch, putdat);
                  	color=0x0700;
			break;
		case 'B':
			color=0x0100;
  8004ed:	c7 45 d8 00 01 00 00 	movl   $0x100,-0x28(%ebp)
			goto reswitch;
  8004f4:	e9 52 ff ff ff       	jmp    80044b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	89 df                	mov    %ebx,%edi
			break;
		case 'B':
			color=0x0100;
			goto reswitch;
		case 'R':
			color=0x0400;
  8004fb:	c7 45 d8 00 04 00 00 	movl   $0x400,-0x28(%ebp)
			goto reswitch;
  800502:	e9 44 ff ff ff       	jmp    80044b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	89 df                	mov    %ebx,%edi
			goto reswitch;
		case 'R':
			color=0x0400;
			goto reswitch;
		case 'G':
			color=0x0200;
  800509:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
			goto reswitch;
  800510:	e9 36 ff ff ff       	jmp    80044b <vprintfmt+0x6d>
		// error message
		case 'e':
			err = va_arg(ap, int);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	99                   	cltd   
  800521:	31 d0                	xor    %edx,%eax
  800523:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800525:	83 f8 06             	cmp    $0x6,%eax
  800528:	7f 0b                	jg     800535 <vprintfmt+0x157>
  80052a:	8b 14 85 ac 10 80 00 	mov    0x8010ac(,%eax,4),%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	75 23                	jne    800558 <vprintfmt+0x17a>
				printfmt(putch, putdat, "error %d", err);
  800535:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800539:	c7 44 24 08 de 0e 80 	movl   $0x800ede,0x8(%esp)
  800540:	00 
  800541:	8b 45 0c             	mov    0xc(%ebp),%eax
  800544:	89 44 24 04          	mov    %eax,0x4(%esp)
  800548:	8b 45 08             	mov    0x8(%ebp),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	e8 63 fe ff ff       	call   8003b6 <printfmt>
  800553:	e9 b2 fe ff ff       	jmp    80040a <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800558:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055c:	c7 44 24 08 e7 0e 80 	movl   $0x800ee7,0x8(%esp)
  800563:	00 
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056b:	8b 45 08             	mov    0x8(%ebp),%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 40 fe ff ff       	call   8003b6 <printfmt>
  800576:	e9 8f fe ff ff       	jmp    80040a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80057e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80058c:	85 ff                	test   %edi,%edi
  80058e:	b8 d7 0e 80 00       	mov    $0x800ed7,%eax
  800593:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800596:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80059a:	0f 84 96 00 00 00    	je     800636 <vprintfmt+0x258>
  8005a0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005a4:	0f 8e 94 00 00 00    	jle    80063e <vprintfmt+0x260>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ae:	89 3c 24             	mov    %edi,(%esp)
  8005b1:	e8 b2 02 00 00       	call   800868 <strnlen>
  8005b6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005b9:	29 c1                	sub    %eax,%ecx
  8005bb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
					putch(padc, putdat);
  8005be:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8005c2:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005c5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005ce:	89 cb                	mov    %ecx,%ebx
  8005d0:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d2:	eb 0f                	jmp    8005e3 <vprintfmt+0x205>
					putch(padc, putdat);
  8005d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	89 3c 24             	mov    %edi,(%esp)
  8005de:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e0:	83 eb 01             	sub    $0x1,%ebx
  8005e3:	85 db                	test   %ebx,%ebx
  8005e5:	7f ed                	jg     8005d4 <vprintfmt+0x1f6>
  8005e7:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005ea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005ed:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f0:	85 d2                	test   %edx,%edx
  8005f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f7:	0f 49 c2             	cmovns %edx,%eax
  8005fa:	29 c2                	sub    %eax,%edx
  8005fc:	89 d3                	mov    %edx,%ebx
  8005fe:	eb 44                	jmp    800644 <vprintfmt+0x266>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800600:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800604:	74 1e                	je     800624 <vprintfmt+0x246>
  800606:	0f be d2             	movsbl %dl,%edx
  800609:	83 ea 20             	sub    $0x20,%edx
  80060c:	83 fa 5e             	cmp    $0x5e,%edx
  80060f:	76 13                	jbe    800624 <vprintfmt+0x246>
					putch('?', putdat);
  800611:	8b 45 0c             	mov    0xc(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
  800622:	eb 0d                	jmp    800631 <vprintfmt+0x253>
				else
					putch(ch, putdat);
  800624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800627:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800631:	83 eb 01             	sub    $0x1,%ebx
  800634:	eb 0e                	jmp    800644 <vprintfmt+0x266>
  800636:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800639:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80063c:	eb 06                	jmp    800644 <vprintfmt+0x266>
  80063e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800641:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800644:	83 c7 01             	add    $0x1,%edi
  800647:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80064b:	0f be c2             	movsbl %dl,%eax
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 27                	je     800679 <vprintfmt+0x29b>
  800652:	85 f6                	test   %esi,%esi
  800654:	78 aa                	js     800600 <vprintfmt+0x222>
  800656:	83 ee 01             	sub    $0x1,%esi
  800659:	79 a5                	jns    800600 <vprintfmt+0x222>
  80065b:	89 d8                	mov    %ebx,%eax
  80065d:	8b 75 08             	mov    0x8(%ebp),%esi
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800663:	89 c3                	mov    %eax,%ebx
  800665:	eb 18                	jmp    80067f <vprintfmt+0x2a1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800672:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 06                	jmp    80067f <vprintfmt+0x2a1>
  800679:	8b 75 08             	mov    0x8(%ebp),%esi
  80067c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80067f:	85 db                	test   %ebx,%ebx
  800681:	7f e4                	jg     800667 <vprintfmt+0x289>
  800683:	89 75 08             	mov    %esi,0x8(%ebp)
  800686:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800689:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80068c:	e9 79 fd ff ff       	jmp    80040a <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800691:	83 fa 01             	cmp    $0x1,%edx
  800694:	7e 10                	jle    8006a6 <vprintfmt+0x2c8>
		return va_arg(*ap, long long);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 08             	lea    0x8(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)
  80069f:	8b 30                	mov    (%eax),%esi
  8006a1:	8b 78 04             	mov    0x4(%eax),%edi
  8006a4:	eb 26                	jmp    8006cc <vprintfmt+0x2ee>
	else if (lflag)
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	74 12                	je     8006bc <vprintfmt+0x2de>
		return va_arg(*ap, long);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b3:	8b 30                	mov    (%eax),%esi
  8006b5:	89 f7                	mov    %esi,%edi
  8006b7:	c1 ff 1f             	sar    $0x1f,%edi
  8006ba:	eb 10                	jmp    8006cc <vprintfmt+0x2ee>
	else
		return va_arg(*ap, int);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 50 04             	lea    0x4(%eax),%edx
  8006c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c5:	8b 30                	mov    (%eax),%esi
  8006c7:	89 f7                	mov    %esi,%edi
  8006c9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	0f 89 87 00 00 00    	jns    800764 <vprintfmt+0x386>
				putch('-', putdat);
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ee:	89 f0                	mov    %esi,%eax
  8006f0:	89 fa                	mov    %edi,%edx
  8006f2:	f7 d8                	neg    %eax
  8006f4:	83 d2 00             	adc    $0x0,%edx
  8006f7:	f7 da                	neg    %edx
			}
			base = 10;
  8006f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006fe:	eb 64                	jmp    800764 <vprintfmt+0x386>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
  800703:	e8 57 fc ff ff       	call   80035f <getuint>
			base = 10;
  800708:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80070d:	eb 55                	jmp    800764 <vprintfmt+0x386>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 48 fc ff ff       	call   80035f <getuint>
			base=8;
  800717:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80071c:	eb 46                	jmp    800764 <vprintfmt+0x386>

		// pointer
		case 'p':
			putch('0', putdat);
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800721:	89 44 24 04          	mov    %eax,0x4(%esp)
  800725:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 04             	lea    0x4(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800749:	8b 00                	mov    (%eax),%eax
  80074b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800750:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800755:	eb 0d                	jmp    800764 <vprintfmt+0x386>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	e8 00 fc ff ff       	call   80035f <getuint>
			base = 16;
  80075f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800764:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800768:	89 74 24 10          	mov    %esi,0x10(%esp)
  80076c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80076f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800773:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	e8 e7 fa ff ff       	call   800270 <printnum>
			break;
  800789:	e9 7c fc ff ff       	jmp    80040a <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	89 0c 24             	mov    %ecx,(%esp)
  800798:	ff 55 08             	call   *0x8(%ebp)
			break;
  80079b:	e9 6a fc ff ff       	jmp    80040a <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ae:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b1:	89 fb                	mov    %edi,%ebx
  8007b3:	eb 03                	jmp    8007b8 <vprintfmt+0x3da>
  8007b5:	83 eb 01             	sub    $0x1,%ebx
  8007b8:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007bc:	75 f7                	jne    8007b5 <vprintfmt+0x3d7>
  8007be:	66 90                	xchg   %ax,%ax
  8007c0:	e9 45 fc ff ff       	jmp    80040a <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8007c5:	83 c4 3c             	add    $0x3c,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5f                   	pop    %edi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 28             	sub    $0x28,%esp
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 30                	je     80081e <vsnprintf+0x51>
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	7e 2c                	jle    80081e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	89 44 24 04          	mov    %eax,0x4(%esp)
  800807:	c7 04 24 99 03 80 00 	movl   $0x800399,(%esp)
  80080e:	e8 cb fb ff ff       	call   8003de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800813:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800816:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081c:	eb 05                	jmp    800823 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800832:	8b 45 10             	mov    0x10(%ebp),%eax
  800835:	89 44 24 08          	mov    %eax,0x8(%esp)
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 82 ff ff ff       	call   8007cd <vsnprintf>
	va_end(ap);

	return rc;
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    
  80084d:	66 90                	xchg   %ax,%ax
  80084f:	90                   	nop

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	eb 03                	jmp    800860 <strlen+0x10>
		n++;
  80085d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800864:	75 f7                	jne    80085d <strlen+0xd>
		n++;
	return n;
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
  800876:	eb 03                	jmp    80087b <strnlen+0x13>
		n++;
  800878:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	39 d0                	cmp    %edx,%eax
  80087d:	74 06                	je     800885 <strnlen+0x1d>
  80087f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800883:	75 f3                	jne    800878 <strnlen+0x10>
		n++;
	return n;
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800891:	89 c2                	mov    %eax,%edx
  800893:	83 c2 01             	add    $0x1,%edx
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80089d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a0:	84 db                	test   %bl,%bl
  8008a2:	75 ef                	jne    800893 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b1:	89 1c 24             	mov    %ebx,(%esp)
  8008b4:	e8 97 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c0:	01 d8                	add    %ebx,%eax
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	e8 bd ff ff ff       	call   800887 <strcpy>
	return dst;
}
  8008ca:	89 d8                	mov    %ebx,%eax
  8008cc:	83 c4 08             	add    $0x8,%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	89 f3                	mov    %esi,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 0f                	jmp    8008f5 <strncpy+0x23>
		*dst++ = *src;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	39 da                	cmp    %ebx,%edx
  8008f7:	75 ed                	jne    8008e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80090d:	89 f0                	mov    %esi,%eax
  80090f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 c9                	test   %ecx,%ecx
  800915:	75 0b                	jne    800922 <strlcpy+0x23>
  800917:	eb 1d                	jmp    800936 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800922:	39 d8                	cmp    %ebx,%eax
  800924:	74 0b                	je     800931 <strlcpy+0x32>
  800926:	0f b6 0a             	movzbl (%edx),%ecx
  800929:	84 c9                	test   %cl,%cl
  80092b:	75 ec                	jne    800919 <strlcpy+0x1a>
  80092d:	89 c2                	mov    %eax,%edx
  80092f:	eb 02                	jmp    800933 <strlcpy+0x34>
  800931:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800933:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800936:	29 f0                	sub    %esi,%eax
}
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800945:	eb 06                	jmp    80094d <strcmp+0x11>
		p++, q++;
  800947:	83 c1 01             	add    $0x1,%ecx
  80094a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094d:	0f b6 01             	movzbl (%ecx),%eax
  800950:	84 c0                	test   %al,%al
  800952:	74 04                	je     800958 <strcmp+0x1c>
  800954:	3a 02                	cmp    (%edx),%al
  800956:	74 ef                	je     800947 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	0f b6 c0             	movzbl %al,%eax
  80095b:	0f b6 12             	movzbl (%edx),%edx
  80095e:	29 d0                	sub    %edx,%eax
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c3                	mov    %eax,%ebx
  80096e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800971:	eb 06                	jmp    800979 <strncmp+0x17>
		n--, p++, q++;
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800979:	39 d8                	cmp    %ebx,%eax
  80097b:	74 15                	je     800992 <strncmp+0x30>
  80097d:	0f b6 08             	movzbl (%eax),%ecx
  800980:	84 c9                	test   %cl,%cl
  800982:	74 04                	je     800988 <strncmp+0x26>
  800984:	3a 0a                	cmp    (%edx),%cl
  800986:	74 eb                	je     800973 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 00             	movzbl (%eax),%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
  800990:	eb 05                	jmp    800997 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a4:	eb 07                	jmp    8009ad <strchr+0x13>
		if (*s == c)
  8009a6:	38 ca                	cmp    %cl,%dl
  8009a8:	74 0f                	je     8009b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f2                	jne    8009a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c5:	eb 07                	jmp    8009ce <strfind+0x13>
		if (*s == c)
  8009c7:	38 ca                	cmp    %cl,%dl
  8009c9:	74 0a                	je     8009d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	84 d2                	test   %dl,%dl
  8009d3:	75 f2                	jne    8009c7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e3:	85 c9                	test   %ecx,%ecx
  8009e5:	74 36                	je     800a1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ed:	75 28                	jne    800a17 <memset+0x40>
  8009ef:	f6 c1 03             	test   $0x3,%cl
  8009f2:	75 23                	jne    800a17 <memset+0x40>
		c &= 0xFF;
  8009f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f8:	89 d3                	mov    %edx,%ebx
  8009fa:	c1 e3 08             	shl    $0x8,%ebx
  8009fd:	89 d6                	mov    %edx,%esi
  8009ff:	c1 e6 18             	shl    $0x18,%esi
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	c1 e0 10             	shl    $0x10,%eax
  800a07:	09 f0                	or     %esi,%eax
  800a09:	09 c2                	or     %eax,%edx
  800a0b:	89 d0                	mov    %edx,%eax
  800a0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a12:	fc                   	cld    
  800a13:	f3 ab                	rep stos %eax,%es:(%edi)
  800a15:	eb 06                	jmp    800a1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	fc                   	cld    
  800a1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1d:	89 f8                	mov    %edi,%eax
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a32:	39 c6                	cmp    %eax,%esi
  800a34:	73 35                	jae    800a6b <memmove+0x47>
  800a36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a39:	39 d0                	cmp    %edx,%eax
  800a3b:	73 2e                	jae    800a6b <memmove+0x47>
		s += n;
		d += n;
  800a3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a40:	89 d6                	mov    %edx,%esi
  800a42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4a:	75 13                	jne    800a5f <memmove+0x3b>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 0e                	jne    800a5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a51:	83 ef 04             	sub    $0x4,%edi
  800a54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a5a:	fd                   	std    
  800a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5d:	eb 09                	jmp    800a68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5f:	83 ef 01             	sub    $0x1,%edi
  800a62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a65:	fd                   	std    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a68:	fc                   	cld    
  800a69:	eb 1d                	jmp    800a88 <memmove+0x64>
  800a6b:	89 f2                	mov    %esi,%edx
  800a6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	f6 c2 03             	test   $0x3,%dl
  800a72:	75 0f                	jne    800a83 <memmove+0x5f>
  800a74:	f6 c1 03             	test   $0x3,%cl
  800a77:	75 0a                	jne    800a83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	fc                   	cld    
  800a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a81:	eb 05                	jmp    800a88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a92:	8b 45 10             	mov    0x10(%ebp),%eax
  800a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 79 ff ff ff       	call   800a24 <memmove>
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abd:	eb 1a                	jmp    800ad9 <memcmp+0x2c>
		if (*s1 != *s2)
  800abf:	0f b6 02             	movzbl (%edx),%eax
  800ac2:	0f b6 19             	movzbl (%ecx),%ebx
  800ac5:	38 d8                	cmp    %bl,%al
  800ac7:	74 0a                	je     800ad3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac9:	0f b6 c0             	movzbl %al,%eax
  800acc:	0f b6 db             	movzbl %bl,%ebx
  800acf:	29 d8                	sub    %ebx,%eax
  800ad1:	eb 0f                	jmp    800ae2 <memcmp+0x35>
		s1++, s2++;
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad9:	39 f2                	cmp    %esi,%edx
  800adb:	75 e2                	jne    800abf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af4:	eb 07                	jmp    800afd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	38 08                	cmp    %cl,(%eax)
  800af8:	74 07                	je     800b01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	39 d0                	cmp    %edx,%eax
  800aff:	72 f5                	jb     800af6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0f:	eb 03                	jmp    800b14 <strtol+0x11>
		s++;
  800b11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b14:	0f b6 0a             	movzbl (%edx),%ecx
  800b17:	80 f9 09             	cmp    $0x9,%cl
  800b1a:	74 f5                	je     800b11 <strtol+0xe>
  800b1c:	80 f9 20             	cmp    $0x20,%cl
  800b1f:	74 f0                	je     800b11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b21:	80 f9 2b             	cmp    $0x2b,%cl
  800b24:	75 0a                	jne    800b30 <strtol+0x2d>
		s++;
  800b26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2e:	eb 11                	jmp    800b41 <strtol+0x3e>
  800b30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b35:	80 f9 2d             	cmp    $0x2d,%cl
  800b38:	75 07                	jne    800b41 <strtol+0x3e>
		s++, neg = 1;
  800b3a:	8d 52 01             	lea    0x1(%edx),%edx
  800b3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b46:	75 15                	jne    800b5d <strtol+0x5a>
  800b48:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4b:	75 10                	jne    800b5d <strtol+0x5a>
  800b4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b51:	75 0a                	jne    800b5d <strtol+0x5a>
		s += 2, base = 16;
  800b53:	83 c2 02             	add    $0x2,%edx
  800b56:	b8 10 00 00 00       	mov    $0x10,%eax
  800b5b:	eb 10                	jmp    800b6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	75 0c                	jne    800b6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b61:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b63:	80 3a 30             	cmpb   $0x30,(%edx)
  800b66:	75 05                	jne    800b6d <strtol+0x6a>
		s++, base = 8;
  800b68:	83 c2 01             	add    $0x1,%edx
  800b6b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 0a             	movzbl (%edx),%ecx
  800b78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b7b:	89 f0                	mov    %esi,%eax
  800b7d:	3c 09                	cmp    $0x9,%al
  800b7f:	77 08                	ja     800b89 <strtol+0x86>
			dig = *s - '0';
  800b81:	0f be c9             	movsbl %cl,%ecx
  800b84:	83 e9 30             	sub    $0x30,%ecx
  800b87:	eb 20                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b8c:	89 f0                	mov    %esi,%eax
  800b8e:	3c 19                	cmp    $0x19,%al
  800b90:	77 08                	ja     800b9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b92:	0f be c9             	movsbl %cl,%ecx
  800b95:	83 e9 57             	sub    $0x57,%ecx
  800b98:	eb 0f                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	3c 19                	cmp    $0x19,%al
  800ba1:	77 16                	ja     800bb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ba3:	0f be c9             	movsbl %cl,%ecx
  800ba6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ba9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bac:	7d 0f                	jge    800bbd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bb7:	eb bc                	jmp    800b75 <strtol+0x72>
  800bb9:	89 d8                	mov    %ebx,%eax
  800bbb:	eb 02                	jmp    800bbf <strtol+0xbc>
  800bbd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	74 05                	je     800bca <strtol+0xc7>
		*endptr = (char *) s;
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bca:	f7 d8                	neg    %eax
  800bcc:	85 ff                	test   %edi,%edi
  800bce:	0f 44 c3             	cmove  %ebx,%eax
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    
  800bd6:	66 90                	xchg   %ax,%ax
  800bd8:	66 90                	xchg   %ax,%ax
  800bda:	66 90                	xchg   %ax,%ax
  800bdc:	66 90                	xchg   %ax,%ax
  800bde:	66 90                	xchg   %ax,%ax

00800be0 <__udivdi3>:
  800be0:	55                   	push   %ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800bea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800bee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800bf2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bfc:	89 ea                	mov    %ebp,%edx
  800bfe:	89 0c 24             	mov    %ecx,(%esp)
  800c01:	75 2d                	jne    800c30 <__udivdi3+0x50>
  800c03:	39 e9                	cmp    %ebp,%ecx
  800c05:	77 61                	ja     800c68 <__udivdi3+0x88>
  800c07:	85 c9                	test   %ecx,%ecx
  800c09:	89 ce                	mov    %ecx,%esi
  800c0b:	75 0b                	jne    800c18 <__udivdi3+0x38>
  800c0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c12:	31 d2                	xor    %edx,%edx
  800c14:	f7 f1                	div    %ecx
  800c16:	89 c6                	mov    %eax,%esi
  800c18:	31 d2                	xor    %edx,%edx
  800c1a:	89 e8                	mov    %ebp,%eax
  800c1c:	f7 f6                	div    %esi
  800c1e:	89 c5                	mov    %eax,%ebp
  800c20:	89 f8                	mov    %edi,%eax
  800c22:	f7 f6                	div    %esi
  800c24:	89 ea                	mov    %ebp,%edx
  800c26:	83 c4 0c             	add    $0xc,%esp
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    
  800c2d:	8d 76 00             	lea    0x0(%esi),%esi
  800c30:	39 e8                	cmp    %ebp,%eax
  800c32:	77 24                	ja     800c58 <__udivdi3+0x78>
  800c34:	0f bd e8             	bsr    %eax,%ebp
  800c37:	83 f5 1f             	xor    $0x1f,%ebp
  800c3a:	75 3c                	jne    800c78 <__udivdi3+0x98>
  800c3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c40:	39 34 24             	cmp    %esi,(%esp)
  800c43:	0f 86 9f 00 00 00    	jbe    800ce8 <__udivdi3+0x108>
  800c49:	39 d0                	cmp    %edx,%eax
  800c4b:	0f 82 97 00 00 00    	jb     800ce8 <__udivdi3+0x108>
  800c51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c58:	31 d2                	xor    %edx,%edx
  800c5a:	31 c0                	xor    %eax,%eax
  800c5c:	83 c4 0c             	add    $0xc,%esp
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    
  800c63:	90                   	nop
  800c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	f7 f1                	div    %ecx
  800c6c:	31 d2                	xor    %edx,%edx
  800c6e:	83 c4 0c             	add    $0xc,%esp
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
  800c75:	8d 76 00             	lea    0x0(%esi),%esi
  800c78:	89 e9                	mov    %ebp,%ecx
  800c7a:	8b 3c 24             	mov    (%esp),%edi
  800c7d:	d3 e0                	shl    %cl,%eax
  800c7f:	89 c6                	mov    %eax,%esi
  800c81:	b8 20 00 00 00       	mov    $0x20,%eax
  800c86:	29 e8                	sub    %ebp,%eax
  800c88:	89 c1                	mov    %eax,%ecx
  800c8a:	d3 ef                	shr    %cl,%edi
  800c8c:	89 e9                	mov    %ebp,%ecx
  800c8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c92:	8b 3c 24             	mov    (%esp),%edi
  800c95:	09 74 24 08          	or     %esi,0x8(%esp)
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	d3 e7                	shl    %cl,%edi
  800c9d:	89 c1                	mov    %eax,%ecx
  800c9f:	89 3c 24             	mov    %edi,(%esp)
  800ca2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ca6:	d3 ee                	shr    %cl,%esi
  800ca8:	89 e9                	mov    %ebp,%ecx
  800caa:	d3 e2                	shl    %cl,%edx
  800cac:	89 c1                	mov    %eax,%ecx
  800cae:	d3 ef                	shr    %cl,%edi
  800cb0:	09 d7                	or     %edx,%edi
  800cb2:	89 f2                	mov    %esi,%edx
  800cb4:	89 f8                	mov    %edi,%eax
  800cb6:	f7 74 24 08          	divl   0x8(%esp)
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	f7 24 24             	mull   (%esp)
  800cc1:	39 d6                	cmp    %edx,%esi
  800cc3:	89 14 24             	mov    %edx,(%esp)
  800cc6:	72 30                	jb     800cf8 <__udivdi3+0x118>
  800cc8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ccc:	89 e9                	mov    %ebp,%ecx
  800cce:	d3 e2                	shl    %cl,%edx
  800cd0:	39 c2                	cmp    %eax,%edx
  800cd2:	73 05                	jae    800cd9 <__udivdi3+0xf9>
  800cd4:	3b 34 24             	cmp    (%esp),%esi
  800cd7:	74 1f                	je     800cf8 <__udivdi3+0x118>
  800cd9:	89 f8                	mov    %edi,%eax
  800cdb:	31 d2                	xor    %edx,%edx
  800cdd:	e9 7a ff ff ff       	jmp    800c5c <__udivdi3+0x7c>
  800ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ce8:	31 d2                	xor    %edx,%edx
  800cea:	b8 01 00 00 00       	mov    $0x1,%eax
  800cef:	e9 68 ff ff ff       	jmp    800c5c <__udivdi3+0x7c>
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	83 c4 0c             	add    $0xc,%esp
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__umoddi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	83 ec 14             	sub    $0x14,%esp
  800d16:	8b 44 24 28          	mov    0x28(%esp),%eax
  800d1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800d1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800d22:	89 c7                	mov    %eax,%edi
  800d24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d28:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d30:	89 34 24             	mov    %esi,(%esp)
  800d33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	89 c2                	mov    %eax,%edx
  800d3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d3f:	75 17                	jne    800d58 <__umoddi3+0x48>
  800d41:	39 fe                	cmp    %edi,%esi
  800d43:	76 4b                	jbe    800d90 <__umoddi3+0x80>
  800d45:	89 c8                	mov    %ecx,%eax
  800d47:	89 fa                	mov    %edi,%edx
  800d49:	f7 f6                	div    %esi
  800d4b:	89 d0                	mov    %edx,%eax
  800d4d:	31 d2                	xor    %edx,%edx
  800d4f:	83 c4 14             	add    $0x14,%esp
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	39 f8                	cmp    %edi,%eax
  800d5a:	77 54                	ja     800db0 <__umoddi3+0xa0>
  800d5c:	0f bd e8             	bsr    %eax,%ebp
  800d5f:	83 f5 1f             	xor    $0x1f,%ebp
  800d62:	75 5c                	jne    800dc0 <__umoddi3+0xb0>
  800d64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d68:	39 3c 24             	cmp    %edi,(%esp)
  800d6b:	0f 87 e7 00 00 00    	ja     800e58 <__umoddi3+0x148>
  800d71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d75:	29 f1                	sub    %esi,%ecx
  800d77:	19 c7                	sbb    %eax,%edi
  800d79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d81:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d89:	83 c4 14             	add    $0x14,%esp
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    
  800d90:	85 f6                	test   %esi,%esi
  800d92:	89 f5                	mov    %esi,%ebp
  800d94:	75 0b                	jne    800da1 <__umoddi3+0x91>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f6                	div    %esi
  800d9f:	89 c5                	mov    %eax,%ebp
  800da1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da5:	31 d2                	xor    %edx,%edx
  800da7:	f7 f5                	div    %ebp
  800da9:	89 c8                	mov    %ecx,%eax
  800dab:	f7 f5                	div    %ebp
  800dad:	eb 9c                	jmp    800d4b <__umoddi3+0x3b>
  800daf:	90                   	nop
  800db0:	89 c8                	mov    %ecx,%eax
  800db2:	89 fa                	mov    %edi,%edx
  800db4:	83 c4 14             	add    $0x14,%esp
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    
  800dbb:	90                   	nop
  800dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	8b 04 24             	mov    (%esp),%eax
  800dc3:	be 20 00 00 00       	mov    $0x20,%esi
  800dc8:	89 e9                	mov    %ebp,%ecx
  800dca:	29 ee                	sub    %ebp,%esi
  800dcc:	d3 e2                	shl    %cl,%edx
  800dce:	89 f1                	mov    %esi,%ecx
  800dd0:	d3 e8                	shr    %cl,%eax
  800dd2:	89 e9                	mov    %ebp,%ecx
  800dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd8:	8b 04 24             	mov    (%esp),%eax
  800ddb:	09 54 24 04          	or     %edx,0x4(%esp)
  800ddf:	89 fa                	mov    %edi,%edx
  800de1:	d3 e0                	shl    %cl,%eax
  800de3:	89 f1                	mov    %esi,%ecx
  800de5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800ded:	d3 ea                	shr    %cl,%edx
  800def:	89 e9                	mov    %ebp,%ecx
  800df1:	d3 e7                	shl    %cl,%edi
  800df3:	89 f1                	mov    %esi,%ecx
  800df5:	d3 e8                	shr    %cl,%eax
  800df7:	89 e9                	mov    %ebp,%ecx
  800df9:	09 f8                	or     %edi,%eax
  800dfb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800dff:	f7 74 24 04          	divl   0x4(%esp)
  800e03:	d3 e7                	shl    %cl,%edi
  800e05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e09:	89 d7                	mov    %edx,%edi
  800e0b:	f7 64 24 08          	mull   0x8(%esp)
  800e0f:	39 d7                	cmp    %edx,%edi
  800e11:	89 c1                	mov    %eax,%ecx
  800e13:	89 14 24             	mov    %edx,(%esp)
  800e16:	72 2c                	jb     800e44 <__umoddi3+0x134>
  800e18:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  800e1c:	72 22                	jb     800e40 <__umoddi3+0x130>
  800e1e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e22:	29 c8                	sub    %ecx,%eax
  800e24:	19 d7                	sbb    %edx,%edi
  800e26:	89 e9                	mov    %ebp,%ecx
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	d3 e8                	shr    %cl,%eax
  800e2c:	89 f1                	mov    %esi,%ecx
  800e2e:	d3 e2                	shl    %cl,%edx
  800e30:	89 e9                	mov    %ebp,%ecx
  800e32:	d3 ef                	shr    %cl,%edi
  800e34:	09 d0                	or     %edx,%eax
  800e36:	89 fa                	mov    %edi,%edx
  800e38:	83 c4 14             	add    $0x14,%esp
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    
  800e3f:	90                   	nop
  800e40:	39 d7                	cmp    %edx,%edi
  800e42:	75 da                	jne    800e1e <__umoddi3+0x10e>
  800e44:	8b 14 24             	mov    (%esp),%edx
  800e47:	89 c1                	mov    %eax,%ecx
  800e49:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  800e4d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  800e51:	eb cb                	jmp    800e1e <__umoddi3+0x10e>
  800e53:	90                   	nop
  800e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e58:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e5c:	0f 82 0f ff ff ff    	jb     800d71 <__umoddi3+0x61>
  800e62:	e9 1a ff ff ff       	jmp    800d81 <__umoddi3+0x71>
