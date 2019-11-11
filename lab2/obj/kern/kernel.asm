
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but were still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 74 89 11 f0       	mov    $0xf0118974,%eax
f010004b:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 83 11 f0       	push   $0xf0118300
f0100058:	e8 21 37 00 00       	call   f010377e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 b5 04 00 00       	call   f0100517 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 c0 3b 10 f0       	push   $0xf0103bc0
f010006f:	e8 69 2b 00 00       	call   f0102bdd <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 ac 12 00 00       	call   f0101325 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 8d 0a 00 00       	call   f0100b13 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 60 89 11 f0 00 	cmpl   $0x0,0xf0118960
f010009a:	74 0f                	je     f01000ab <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009c:	83 ec 0c             	sub    $0xc,%esp
f010009f:	6a 00                	push   $0x0
f01000a1:	e8 6d 0a 00 00       	call   f0100b13 <monitor>
f01000a6:	83 c4 10             	add    $0x10,%esp
f01000a9:	eb f1                	jmp    f010009c <_panic+0x11>
	panicstr = fmt;
f01000ab:	89 35 60 89 11 f0    	mov    %esi,0xf0118960
	__asm __volatile("cli; cld");
f01000b1:	fa                   	cli    
f01000b2:	fc                   	cld    
	va_start(ap, fmt);
f01000b3:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b6:	83 ec 04             	sub    $0x4,%esp
f01000b9:	ff 75 0c             	pushl  0xc(%ebp)
f01000bc:	ff 75 08             	pushl  0x8(%ebp)
f01000bf:	68 db 3b 10 f0       	push   $0xf0103bdb
f01000c4:	e8 14 2b 00 00       	call   f0102bdd <cprintf>
	vcprintf(fmt, ap);
f01000c9:	83 c4 08             	add    $0x8,%esp
f01000cc:	53                   	push   %ebx
f01000cd:	56                   	push   %esi
f01000ce:	e8 e4 2a 00 00       	call   f0102bb7 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 5f 4c 10 f0 	movl   $0xf0104c5f,(%esp)
f01000da:	e8 fe 2a 00 00       	call   f0102bdd <cprintf>
f01000df:	83 c4 10             	add    $0x10,%esp
f01000e2:	eb b8                	jmp    f010009c <_panic+0x11>

f01000e4 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	53                   	push   %ebx
f01000e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000eb:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ee:	ff 75 0c             	pushl  0xc(%ebp)
f01000f1:	ff 75 08             	pushl  0x8(%ebp)
f01000f4:	68 f3 3b 10 f0       	push   $0xf0103bf3
f01000f9:	e8 df 2a 00 00       	call   f0102bdd <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	53                   	push   %ebx
f0100102:	ff 75 10             	pushl  0x10(%ebp)
f0100105:	e8 ad 2a 00 00       	call   f0102bb7 <vcprintf>
	cprintf("\n");
f010010a:	c7 04 24 5f 4c 10 f0 	movl   $0xf0104c5f,(%esp)
f0100111:	e8 c7 2a 00 00       	call   f0102bdd <cprintf>
	va_end(ap);
}
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011c:	c9                   	leave  
f010011d:	c3                   	ret    

f010011e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011e:	55                   	push   %ebp
f010011f:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100121:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100126:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100127:	a8 01                	test   $0x1,%al
f0100129:	74 0b                	je     f0100136 <serial_proc_data+0x18>
f010012b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100130:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100131:	0f b6 c0             	movzbl %al,%eax
}
f0100134:	5d                   	pop    %ebp
f0100135:	c3                   	ret    
		return -1;
f0100136:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010013b:	eb f7                	jmp    f0100134 <serial_proc_data+0x16>

f010013d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 04             	sub    $0x4,%esp
f0100144:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100146:	ff d3                	call   *%ebx
f0100148:	83 f8 ff             	cmp    $0xffffffff,%eax
f010014b:	74 2d                	je     f010017a <cons_intr+0x3d>
		if (c == 0)
f010014d:	85 c0                	test   %eax,%eax
f010014f:	74 f5                	je     f0100146 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100151:	8b 0d 24 85 11 f0    	mov    0xf0118524,%ecx
f0100157:	8d 51 01             	lea    0x1(%ecx),%edx
f010015a:	89 15 24 85 11 f0    	mov    %edx,0xf0118524
f0100160:	88 81 20 83 11 f0    	mov    %al,-0xfee7ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100166:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010016c:	75 d8                	jne    f0100146 <cons_intr+0x9>
			cons.wpos = 0;
f010016e:	c7 05 24 85 11 f0 00 	movl   $0x0,0xf0118524
f0100175:	00 00 00 
f0100178:	eb cc                	jmp    f0100146 <cons_intr+0x9>
	}
}
f010017a:	83 c4 04             	add    $0x4,%esp
f010017d:	5b                   	pop    %ebx
f010017e:	5d                   	pop    %ebp
f010017f:	c3                   	ret    

f0100180 <kbd_proc_data>:
{
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp
f0100183:	53                   	push   %ebx
f0100184:	83 ec 04             	sub    $0x4,%esp
f0100187:	ba 64 00 00 00       	mov    $0x64,%edx
f010018c:	ec                   	in     (%dx),%al
	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010018d:	a8 01                	test   $0x1,%al
f010018f:	0f 84 f2 00 00 00    	je     f0100287 <kbd_proc_data+0x107>
f0100195:	ba 60 00 00 00       	mov    $0x60,%edx
f010019a:	ec                   	in     (%dx),%al
f010019b:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010019d:	3c e0                	cmp    $0xe0,%al
f010019f:	0f 84 8e 00 00 00    	je     f0100233 <kbd_proc_data+0xb3>
	} else if (data & 0x80) {
f01001a5:	84 c0                	test   %al,%al
f01001a7:	0f 88 99 00 00 00    	js     f0100246 <kbd_proc_data+0xc6>
	} else if (shift & E0ESC) {
f01001ad:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f01001b3:	f6 c1 40             	test   $0x40,%cl
f01001b6:	74 0e                	je     f01001c6 <kbd_proc_data+0x46>
		data |= 0x80;
f01001b8:	83 c8 80             	or     $0xffffff80,%eax
f01001bb:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001bd:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001c0:	89 0d 00 83 11 f0    	mov    %ecx,0xf0118300
	shift |= shiftcode[data];
f01001c6:	0f b6 d2             	movzbl %dl,%edx
f01001c9:	0f b6 82 60 3d 10 f0 	movzbl -0xfefc2a0(%edx),%eax
f01001d0:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f01001d6:	0f b6 8a 60 3c 10 f0 	movzbl -0xfefc3a0(%edx),%ecx
f01001dd:	31 c8                	xor    %ecx,%eax
f01001df:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f01001e4:	89 c1                	mov    %eax,%ecx
f01001e6:	83 e1 03             	and    $0x3,%ecx
f01001e9:	8b 0c 8d 40 3c 10 f0 	mov    -0xfefc3c0(,%ecx,4),%ecx
f01001f0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01001f4:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01001f7:	a8 08                	test   $0x8,%al
f01001f9:	74 0d                	je     f0100208 <kbd_proc_data+0x88>
		if ('a' <= c && c <= 'z')
f01001fb:	89 da                	mov    %ebx,%edx
f01001fd:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100200:	83 f9 19             	cmp    $0x19,%ecx
f0100203:	77 74                	ja     f0100279 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100205:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100208:	f7 d0                	not    %eax
f010020a:	a8 06                	test   $0x6,%al
f010020c:	75 31                	jne    f010023f <kbd_proc_data+0xbf>
f010020e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100214:	75 29                	jne    f010023f <kbd_proc_data+0xbf>
		cprintf("Rebooting!\n");
f0100216:	83 ec 0c             	sub    $0xc,%esp
f0100219:	68 0d 3c 10 f0       	push   $0xf0103c0d
f010021e:	e8 ba 29 00 00       	call   f0102bdd <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100223:	b8 03 00 00 00       	mov    $0x3,%eax
f0100228:	ba 92 00 00 00       	mov    $0x92,%edx
f010022d:	ee                   	out    %al,(%dx)
f010022e:	83 c4 10             	add    $0x10,%esp
f0100231:	eb 0c                	jmp    f010023f <kbd_proc_data+0xbf>
		shift |= E0ESC;
f0100233:	83 0d 00 83 11 f0 40 	orl    $0x40,0xf0118300
		return 0;
f010023a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010023f:	89 d8                	mov    %ebx,%eax
f0100241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100244:	c9                   	leave  
f0100245:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100246:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f010024c:	89 cb                	mov    %ecx,%ebx
f010024e:	83 e3 40             	and    $0x40,%ebx
f0100251:	83 e0 7f             	and    $0x7f,%eax
f0100254:	85 db                	test   %ebx,%ebx
f0100256:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100259:	0f b6 d2             	movzbl %dl,%edx
f010025c:	0f b6 82 60 3d 10 f0 	movzbl -0xfefc2a0(%edx),%eax
f0100263:	83 c8 40             	or     $0x40,%eax
f0100266:	0f b6 c0             	movzbl %al,%eax
f0100269:	f7 d0                	not    %eax
f010026b:	21 c8                	and    %ecx,%eax
f010026d:	a3 00 83 11 f0       	mov    %eax,0xf0118300
		return 0;
f0100272:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100277:	eb c6                	jmp    f010023f <kbd_proc_data+0xbf>
		else if ('A' <= c && c <= 'Z')
f0100279:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010027c:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010027f:	83 fa 1a             	cmp    $0x1a,%edx
f0100282:	0f 42 d9             	cmovb  %ecx,%ebx
f0100285:	eb 81                	jmp    f0100208 <kbd_proc_data+0x88>
		return -1;
f0100287:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010028c:	eb b1                	jmp    f010023f <kbd_proc_data+0xbf>

f010028e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010028e:	55                   	push   %ebp
f010028f:	89 e5                	mov    %esp,%ebp
f0100291:	57                   	push   %edi
f0100292:	56                   	push   %esi
f0100293:	53                   	push   %ebx
f0100294:	83 ec 1c             	sub    $0x1c,%esp
f0100297:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100299:	bb 00 00 00 00       	mov    $0x0,%ebx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010029e:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002a3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002a8:	eb 09                	jmp    f01002b3 <cons_putc+0x25>
f01002aa:	89 ca                	mov    %ecx,%edx
f01002ac:	ec                   	in     (%dx),%al
f01002ad:	ec                   	in     (%dx),%al
f01002ae:	ec                   	in     (%dx),%al
f01002af:	ec                   	in     (%dx),%al
	     i++)
f01002b0:	83 c3 01             	add    $0x1,%ebx
f01002b3:	89 f2                	mov    %esi,%edx
f01002b5:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b6:	a8 20                	test   $0x20,%al
f01002b8:	75 08                	jne    f01002c2 <cons_putc+0x34>
f01002ba:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002c0:	7e e8                	jle    f01002aa <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f01002c2:	89 f8                	mov    %edi,%eax
f01002c4:	88 45 e7             	mov    %al,-0x19(%ebp)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002cc:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d2:	be 79 03 00 00       	mov    $0x379,%esi
f01002d7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002dc:	eb 09                	jmp    f01002e7 <cons_putc+0x59>
f01002de:	89 ca                	mov    %ecx,%edx
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	ec                   	in     (%dx),%al
f01002e2:	ec                   	in     (%dx),%al
f01002e3:	ec                   	in     (%dx),%al
f01002e4:	83 c3 01             	add    $0x1,%ebx
f01002e7:	89 f2                	mov    %esi,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f0:	7f 04                	jg     f01002f6 <cons_putc+0x68>
f01002f2:	84 c0                	test   %al,%al
f01002f4:	79 e8                	jns    f01002de <cons_putc+0x50>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f6:	ba 78 03 00 00       	mov    $0x378,%edx
f01002fb:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002ff:	ee                   	out    %al,(%dx)
f0100300:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100305:	b8 0d 00 00 00       	mov    $0xd,%eax
f010030a:	ee                   	out    %al,(%dx)
f010030b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100310:	ee                   	out    %al,(%dx)
	if (!color)
f0100311:	83 3d 64 89 11 f0 00 	cmpl   $0x0,0xf0118964
f0100318:	75 0a                	jne    f0100324 <cons_putc+0x96>
		color = 0x0700;
f010031a:	c7 05 64 89 11 f0 00 	movl   $0x700,0xf0118964
f0100321:	07 00 00 
	if (!(c & ~0xFF))
f0100324:	89 fa                	mov    %edi,%edx
f0100326:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= color;
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	0b 05 64 89 11 f0    	or     0xf0118964,%eax
f0100334:	85 d2                	test   %edx,%edx
f0100336:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100339:	89 f8                	mov    %edi,%eax
f010033b:	0f b6 c0             	movzbl %al,%eax
f010033e:	83 f8 09             	cmp    $0x9,%eax
f0100341:	0f 84 b6 00 00 00    	je     f01003fd <cons_putc+0x16f>
f0100347:	83 f8 09             	cmp    $0x9,%eax
f010034a:	7e 73                	jle    f01003bf <cons_putc+0x131>
f010034c:	83 f8 0a             	cmp    $0xa,%eax
f010034f:	0f 84 9b 00 00 00    	je     f01003f0 <cons_putc+0x162>
f0100355:	83 f8 0d             	cmp    $0xd,%eax
f0100358:	0f 85 d6 00 00 00    	jne    f0100434 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010035e:	0f b7 05 28 85 11 f0 	movzwl 0xf0118528,%eax
f0100365:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010036b:	c1 e8 16             	shr    $0x16,%eax
f010036e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100371:	c1 e0 04             	shl    $0x4,%eax
f0100374:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
	if (crt_pos >= CRT_SIZE) {
f010037a:	66 81 3d 28 85 11 f0 	cmpw   $0x7cf,0xf0118528
f0100381:	cf 07 
f0100383:	0f 87 ce 00 00 00    	ja     f0100457 <cons_putc+0x1c9>
	outb(addr_6845, 14);
f0100389:	8b 0d 30 85 11 f0    	mov    0xf0118530,%ecx
f010038f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100394:	89 ca                	mov    %ecx,%edx
f0100396:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100397:	0f b7 1d 28 85 11 f0 	movzwl 0xf0118528,%ebx
f010039e:	8d 71 01             	lea    0x1(%ecx),%esi
f01003a1:	89 d8                	mov    %ebx,%eax
f01003a3:	66 c1 e8 08          	shr    $0x8,%ax
f01003a7:	89 f2                	mov    %esi,%edx
f01003a9:	ee                   	out    %al,(%dx)
f01003aa:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003af:	89 ca                	mov    %ecx,%edx
f01003b1:	ee                   	out    %al,(%dx)
f01003b2:	89 d8                	mov    %ebx,%eax
f01003b4:	89 f2                	mov    %esi,%edx
f01003b6:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003ba:	5b                   	pop    %ebx
f01003bb:	5e                   	pop    %esi
f01003bc:	5f                   	pop    %edi
f01003bd:	5d                   	pop    %ebp
f01003be:	c3                   	ret    
	switch (c & 0xff) {
f01003bf:	83 f8 08             	cmp    $0x8,%eax
f01003c2:	75 70                	jne    f0100434 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f01003c4:	0f b7 05 28 85 11 f0 	movzwl 0xf0118528,%eax
f01003cb:	66 85 c0             	test   %ax,%ax
f01003ce:	74 b9                	je     f0100389 <cons_putc+0xfb>
			crt_pos--;
f01003d0:	83 e8 01             	sub    $0x1,%eax
f01003d3:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003d9:	0f b7 c0             	movzwl %ax,%eax
f01003dc:	66 81 e7 00 ff       	and    $0xff00,%di
f01003e1:	83 cf 20             	or     $0x20,%edi
f01003e4:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f01003ea:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003ee:	eb 8a                	jmp    f010037a <cons_putc+0xec>
		crt_pos += CRT_COLS;
f01003f0:	66 83 05 28 85 11 f0 	addw   $0x50,0xf0118528
f01003f7:	50 
f01003f8:	e9 61 ff ff ff       	jmp    f010035e <cons_putc+0xd0>
		cons_putc(' ');
f01003fd:	b8 20 00 00 00       	mov    $0x20,%eax
f0100402:	e8 87 fe ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f0100407:	b8 20 00 00 00       	mov    $0x20,%eax
f010040c:	e8 7d fe ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f0100411:	b8 20 00 00 00       	mov    $0x20,%eax
f0100416:	e8 73 fe ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f010041b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100420:	e8 69 fe ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f0100425:	b8 20 00 00 00       	mov    $0x20,%eax
f010042a:	e8 5f fe ff ff       	call   f010028e <cons_putc>
f010042f:	e9 46 ff ff ff       	jmp    f010037a <cons_putc+0xec>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100434:	0f b7 05 28 85 11 f0 	movzwl 0xf0118528,%eax
f010043b:	8d 50 01             	lea    0x1(%eax),%edx
f010043e:	66 89 15 28 85 11 f0 	mov    %dx,0xf0118528
f0100445:	0f b7 c0             	movzwl %ax,%eax
f0100448:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f010044e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100452:	e9 23 ff ff ff       	jmp    f010037a <cons_putc+0xec>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100457:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f010045c:	83 ec 04             	sub    $0x4,%esp
f010045f:	68 00 0f 00 00       	push   $0xf00
f0100464:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010046a:	52                   	push   %edx
f010046b:	50                   	push   %eax
f010046c:	e8 5a 33 00 00       	call   f01037cb <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100471:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100477:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010047d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100483:	83 c4 10             	add    $0x10,%esp
f0100486:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010048b:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010048e:	39 d0                	cmp    %edx,%eax
f0100490:	75 f4                	jne    f0100486 <cons_putc+0x1f8>
		crt_pos -= CRT_COLS;
f0100492:	66 83 2d 28 85 11 f0 	subw   $0x50,0xf0118528
f0100499:	50 
f010049a:	e9 ea fe ff ff       	jmp    f0100389 <cons_putc+0xfb>

f010049f <serial_intr>:
	if (serial_exists)
f010049f:	80 3d 34 85 11 f0 00 	cmpb   $0x0,0xf0118534
f01004a6:	75 02                	jne    f01004aa <serial_intr+0xb>
f01004a8:	f3 c3                	repz ret 
{
f01004aa:	55                   	push   %ebp
f01004ab:	89 e5                	mov    %esp,%ebp
f01004ad:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01004b0:	b8 1e 01 10 f0       	mov    $0xf010011e,%eax
f01004b5:	e8 83 fc ff ff       	call   f010013d <cons_intr>
}
f01004ba:	c9                   	leave  
f01004bb:	c3                   	ret    

f01004bc <kbd_intr>:
{
f01004bc:	55                   	push   %ebp
f01004bd:	89 e5                	mov    %esp,%ebp
f01004bf:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c2:	b8 80 01 10 f0       	mov    $0xf0100180,%eax
f01004c7:	e8 71 fc ff ff       	call   f010013d <cons_intr>
}
f01004cc:	c9                   	leave  
f01004cd:	c3                   	ret    

f01004ce <cons_getc>:
{
f01004ce:	55                   	push   %ebp
f01004cf:	89 e5                	mov    %esp,%ebp
f01004d1:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01004d4:	e8 c6 ff ff ff       	call   f010049f <serial_intr>
	kbd_intr();
f01004d9:	e8 de ff ff ff       	call   f01004bc <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01004de:	8b 15 20 85 11 f0    	mov    0xf0118520,%edx
	return 0;
f01004e4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01004e9:	3b 15 24 85 11 f0    	cmp    0xf0118524,%edx
f01004ef:	74 18                	je     f0100509 <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f01004f1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01004f4:	89 0d 20 85 11 f0    	mov    %ecx,0xf0118520
f01004fa:	0f b6 82 20 83 11 f0 	movzbl -0xfee7ce0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100501:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100507:	74 02                	je     f010050b <cons_getc+0x3d>
}
f0100509:	c9                   	leave  
f010050a:	c3                   	ret    
			cons.rpos = 0;
f010050b:	c7 05 20 85 11 f0 00 	movl   $0x0,0xf0118520
f0100512:	00 00 00 
f0100515:	eb f2                	jmp    f0100509 <cons_getc+0x3b>

f0100517 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100517:	55                   	push   %ebp
f0100518:	89 e5                	mov    %esp,%ebp
f010051a:	57                   	push   %edi
f010051b:	56                   	push   %esi
f010051c:	53                   	push   %ebx
f010051d:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100520:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100527:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010052e:	5a a5 
	if (*cp != 0xA55A) {
f0100530:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100537:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010053b:	0f 84 b7 00 00 00    	je     f01005f8 <cons_init+0xe1>
		addr_6845 = MONO_BASE;
f0100541:	c7 05 30 85 11 f0 b4 	movl   $0x3b4,0xf0118530
f0100548:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010054b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100550:	8b 3d 30 85 11 f0    	mov    0xf0118530,%edi
f0100556:	b8 0e 00 00 00       	mov    $0xe,%eax
f010055b:	89 fa                	mov    %edi,%edx
f010055d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055e:	8d 4f 01             	lea    0x1(%edi),%ecx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100561:	89 ca                	mov    %ecx,%edx
f0100563:	ec                   	in     (%dx),%al
f0100564:	0f b6 c0             	movzbl %al,%eax
f0100567:	c1 e0 08             	shl    $0x8,%eax
f010056a:	89 c3                	mov    %eax,%ebx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100571:	89 fa                	mov    %edi,%edx
f0100573:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100574:	89 ca                	mov    %ecx,%edx
f0100576:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100577:	89 35 2c 85 11 f0    	mov    %esi,0xf011852c
	pos |= inb(addr_6845 + 1);
f010057d:	0f b6 c0             	movzbl %al,%eax
f0100580:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100582:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100588:	bb 00 00 00 00       	mov    $0x0,%ebx
f010058d:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f0100592:	89 d8                	mov    %ebx,%eax
f0100594:	89 ca                	mov    %ecx,%edx
f0100596:	ee                   	out    %al,(%dx)
f0100597:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010059c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005a1:	89 fa                	mov    %edi,%edx
f01005a3:	ee                   	out    %al,(%dx)
f01005a4:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	be f9 03 00 00       	mov    $0x3f9,%esi
f01005b4:	89 d8                	mov    %ebx,%eax
f01005b6:	89 f2                	mov    %esi,%edx
f01005b8:	ee                   	out    %al,(%dx)
f01005b9:	b8 03 00 00 00       	mov    $0x3,%eax
f01005be:	89 fa                	mov    %edi,%edx
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005c6:	89 d8                	mov    %ebx,%eax
f01005c8:	ee                   	out    %al,(%dx)
f01005c9:	b8 01 00 00 00       	mov    $0x1,%eax
f01005ce:	89 f2                	mov    %esi,%edx
f01005d0:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d6:	ec                   	in     (%dx),%al
f01005d7:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d9:	3c ff                	cmp    $0xff,%al
f01005db:	0f 95 05 34 85 11 f0 	setne  0xf0118534
f01005e2:	89 ca                	mov    %ecx,%edx
f01005e4:	ec                   	in     (%dx),%al
f01005e5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005ea:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005eb:	80 fb ff             	cmp    $0xff,%bl
f01005ee:	74 23                	je     f0100613 <cons_init+0xfc>
		cprintf("Serial port does not exist!\n");
}
f01005f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005f3:	5b                   	pop    %ebx
f01005f4:	5e                   	pop    %esi
f01005f5:	5f                   	pop    %edi
f01005f6:	5d                   	pop    %ebp
f01005f7:	c3                   	ret    
		*cp = was;
f01005f8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005ff:	c7 05 30 85 11 f0 d4 	movl   $0x3d4,0xf0118530
f0100606:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100609:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010060e:	e9 3d ff ff ff       	jmp    f0100550 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f0100613:	83 ec 0c             	sub    $0xc,%esp
f0100616:	68 19 3c 10 f0       	push   $0xf0103c19
f010061b:	e8 bd 25 00 00       	call   f0102bdd <cprintf>
f0100620:	83 c4 10             	add    $0x10,%esp
}
f0100623:	eb cb                	jmp    f01005f0 <cons_init+0xd9>

f0100625 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010062b:	8b 45 08             	mov    0x8(%ebp),%eax
f010062e:	e8 5b fc ff ff       	call   f010028e <cons_putc>
}
f0100633:	c9                   	leave  
f0100634:	c3                   	ret    

f0100635 <getchar>:

int
getchar(void)
{
f0100635:	55                   	push   %ebp
f0100636:	89 e5                	mov    %esp,%ebp
f0100638:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010063b:	e8 8e fe ff ff       	call   f01004ce <cons_getc>
f0100640:	85 c0                	test   %eax,%eax
f0100642:	74 f7                	je     f010063b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100644:	c9                   	leave  
f0100645:	c3                   	ret    

f0100646 <iscons>:

int
iscons(int fdnum)
{
f0100646:	55                   	push   %ebp
f0100647:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100649:	b8 01 00 00 00       	mov    $0x1,%eax
f010064e:	5d                   	pop    %ebp
f010064f:	c3                   	ret    

f0100650 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	53                   	push   %ebx
f0100654:	83 ec 04             	sub    $0x4,%esp
f0100657:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010065c:	83 ec 04             	sub    $0x4,%esp
f010065f:	ff b3 24 42 10 f0    	pushl  -0xfefbddc(%ebx)
f0100665:	ff b3 20 42 10 f0    	pushl  -0xfefbde0(%ebx)
f010066b:	68 60 3e 10 f0       	push   $0xf0103e60
f0100670:	e8 68 25 00 00       	call   f0102bdd <cprintf>
f0100675:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < NCOMMANDS; i++)
f0100678:	83 c4 10             	add    $0x10,%esp
f010067b:	83 fb 3c             	cmp    $0x3c,%ebx
f010067e:	75 dc                	jne    f010065c <mon_help+0xc>
	return 0;
}
f0100680:	b8 00 00 00 00       	mov    $0x0,%eax
f0100685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100688:	c9                   	leave  
f0100689:	c3                   	ret    

f010068a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010068a:	55                   	push   %ebp
f010068b:	89 e5                	mov    %esp,%ebp
f010068d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100690:	68 69 3e 10 f0       	push   $0xf0103e69
f0100695:	e8 43 25 00 00       	call   f0102bdd <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010069a:	83 c4 08             	add    $0x8,%esp
f010069d:	68 0c 00 10 00       	push   $0x10000c
f01006a2:	68 50 40 10 f0       	push   $0xf0104050
f01006a7:	e8 31 25 00 00       	call   f0102bdd <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ac:	83 c4 0c             	add    $0xc,%esp
f01006af:	68 0c 00 10 00       	push   $0x10000c
f01006b4:	68 0c 00 10 f0       	push   $0xf010000c
f01006b9:	68 78 40 10 f0       	push   $0xf0104078
f01006be:	e8 1a 25 00 00       	call   f0102bdd <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c3:	83 c4 0c             	add    $0xc,%esp
f01006c6:	68 b9 3b 10 00       	push   $0x103bb9
f01006cb:	68 b9 3b 10 f0       	push   $0xf0103bb9
f01006d0:	68 9c 40 10 f0       	push   $0xf010409c
f01006d5:	e8 03 25 00 00       	call   f0102bdd <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006da:	83 c4 0c             	add    $0xc,%esp
f01006dd:	68 00 83 11 00       	push   $0x118300
f01006e2:	68 00 83 11 f0       	push   $0xf0118300
f01006e7:	68 c0 40 10 f0       	push   $0xf01040c0
f01006ec:	e8 ec 24 00 00       	call   f0102bdd <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006f1:	83 c4 0c             	add    $0xc,%esp
f01006f4:	68 74 89 11 00       	push   $0x118974
f01006f9:	68 74 89 11 f0       	push   $0xf0118974
f01006fe:	68 e4 40 10 f0       	push   $0xf01040e4
f0100703:	e8 d5 24 00 00       	call   f0102bdd <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100708:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010070b:	b8 73 8d 11 f0       	mov    $0xf0118d73,%eax
f0100710:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100715:	c1 f8 0a             	sar    $0xa,%eax
f0100718:	50                   	push   %eax
f0100719:	68 08 41 10 f0       	push   $0xf0104108
f010071e:	e8 ba 24 00 00       	call   f0102bdd <cprintf>
	return 0;
}
f0100723:	b8 00 00 00 00       	mov    $0x0,%eax
f0100728:	c9                   	leave  
f0100729:	c3                   	ret    

f010072a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010072a:	55                   	push   %ebp
f010072b:	89 e5                	mov    %esp,%ebp
f010072d:	57                   	push   %edi
f010072e:	56                   	push   %esi
f010072f:	53                   	push   %ebx
f0100730:	83 ec 44             	sub    $0x44,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100733:	89 ee                	mov    %ebp,%esi
	uint32_t *ebp = (uint32_t*) (read_ebp());
	cprintf("%s","Stack backtrace:\n");
f0100735:	68 82 3e 10 f0       	push   $0xf0103e82
f010073a:	68 e8 49 10 f0       	push   $0xf01049e8
f010073f:	e8 99 24 00 00       	call   f0102bdd <cprintf>
	while(ebp != 0x0){
f0100744:	83 c4 10             	add    $0x10,%esp
f0100747:	eb 78                	jmp    f01007c1 <mon_backtrace+0x97>
		uint32_t eip = *(ebp+1);
f0100749:	8b 46 04             	mov    0x4(%esi),%eax
f010074c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("ebp %08.x  eip %08.x  args", ebp, *(ebp+1));
f010074f:	83 ec 04             	sub    $0x4,%esp
f0100752:	50                   	push   %eax
f0100753:	56                   	push   %esi
f0100754:	68 94 3e 10 f0       	push   $0xf0103e94
f0100759:	e8 7f 24 00 00       	call   f0102bdd <cprintf>
f010075e:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100761:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100764:	83 c4 10             	add    $0x10,%esp
		for(int i = 2; i < 7; ++i){
				cprintf(" %08.x", *(ebp+i));
f0100767:	83 ec 08             	sub    $0x8,%esp
f010076a:	ff 33                	pushl  (%ebx)
f010076c:	68 af 3e 10 f0       	push   $0xf0103eaf
f0100771:	e8 67 24 00 00       	call   f0102bdd <cprintf>
f0100776:	83 c3 04             	add    $0x4,%ebx
		for(int i = 2; i < 7; ++i){
f0100779:	83 c4 10             	add    $0x10,%esp
f010077c:	39 fb                	cmp    %edi,%ebx
f010077e:	75 e7                	jne    f0100767 <mon_backtrace+0x3d>
		}
		cprintf("\n");
f0100780:	83 ec 0c             	sub    $0xc,%esp
f0100783:	68 5f 4c 10 f0       	push   $0xf0104c5f
f0100788:	e8 50 24 00 00       	call   f0102bdd <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f010078d:	83 c4 08             	add    $0x8,%esp
f0100790:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100793:	50                   	push   %eax
f0100794:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100797:	57                   	push   %edi
f0100798:	e8 44 25 00 00       	call   f0102ce1 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f010079d:	83 c4 08             	add    $0x8,%esp
f01007a0:	89 f8                	mov    %edi,%eax
f01007a2:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007a5:	50                   	push   %eax
f01007a6:	ff 75 d8             	pushl  -0x28(%ebp)
f01007a9:	ff 75 dc             	pushl  -0x24(%ebp)
f01007ac:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007af:	ff 75 d0             	pushl  -0x30(%ebp)
f01007b2:	68 b6 3e 10 f0       	push   $0xf0103eb6
f01007b7:	e8 21 24 00 00       	call   f0102bdd <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
		ebp = (uint32_t*) (*ebp);
f01007bc:	8b 36                	mov    (%esi),%esi
f01007be:	83 c4 20             	add    $0x20,%esp
	while(ebp != 0x0){
f01007c1:	85 f6                	test   %esi,%esi
f01007c3:	75 84                	jne    f0100749 <mon_backtrace+0x1f>
	}
	return 0;
}
f01007c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007cd:	5b                   	pop    %ebx
f01007ce:	5e                   	pop    %esi
f01007cf:	5f                   	pop    %edi
f01007d0:	5d                   	pop    %ebp
f01007d1:	c3                   	ret    

f01007d2 <hex2addr>:

/*****Implementations of extend monitor command *****/

uint32_t
hex2addr(char* buffer){
f01007d2:	55                   	push   %ebp
f01007d3:	89 e5                	mov    %esp,%ebp
	uint32_t result = 0;
	buffer += 2;
f01007d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01007d8:	8d 48 02             	lea    0x2(%eax),%ecx
	uint32_t result = 0;
f01007db:	b8 00 00 00 00       	mov    $0x0,%eax
	while(*buffer != '\0'){
f01007e0:	eb 0a                	jmp    f01007ec <hex2addr+0x1a>
		result *= 16;
		if(*buffer >= 'a'){
			result += *buffer - 'a' + 10;
		}
		else{
			result += *buffer - '0';
f01007e2:	0f be d2             	movsbl %dl,%edx
f01007e5:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
		}
		buffer++;
f01007e9:	83 c1 01             	add    $0x1,%ecx
	while(*buffer != '\0'){
f01007ec:	0f b6 11             	movzbl (%ecx),%edx
f01007ef:	84 d2                	test   %dl,%dl
f01007f1:	74 11                	je     f0100804 <hex2addr+0x32>
		result *= 16;
f01007f3:	c1 e0 04             	shl    $0x4,%eax
		if(*buffer >= 'a'){
f01007f6:	80 fa 60             	cmp    $0x60,%dl
f01007f9:	7e e7                	jle    f01007e2 <hex2addr+0x10>
			result += *buffer - 'a' + 10;
f01007fb:	0f be d2             	movsbl %dl,%edx
f01007fe:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
f0100802:	eb e5                	jmp    f01007e9 <hex2addr+0x17>
	}
	return result;
}
f0100804:	5d                   	pop    %ebp
f0100805:	c3                   	ret    

f0100806 <showmappings>:

int
showmappings(int argc, char** argv, struct Trapframe *tf){
f0100806:	55                   	push   %ebp
f0100807:	89 e5                	mov    %esp,%ebp
f0100809:	57                   	push   %edi
f010080a:	56                   	push   %esi
f010080b:	53                   	push   %ebx
f010080c:	83 ec 0c             	sub    $0xc,%esp
f010080f:	8b 45 08             	mov    0x8(%ebp),%eax
	if(argc == 1){
f0100812:	83 f8 01             	cmp    $0x1,%eax
f0100815:	0f 84 b5 00 00 00    	je     f01008d0 <showmappings+0xca>
		cprintf("Format: showmappings 0xBEGIN_ADRR 0xEND_ADRR\n");
		return 0;
	}
	else if(argc < 3){
f010081b:	83 f8 02             	cmp    $0x2,%eax
f010081e:	0f 8e be 00 00 00    	jle    f01008e2 <showmappings+0xdc>
		cprintf("WRONG FORMAT\n");
		return 0;	
	}
	uint32_t beg = hex2addr(argv[1]), end = hex2addr(argv[2]);
f0100824:	83 ec 0c             	sub    $0xc,%esp
f0100827:	8b 45 0c             	mov    0xc(%ebp),%eax
f010082a:	ff 70 04             	pushl  0x4(%eax)
f010082d:	e8 a0 ff ff ff       	call   f01007d2 <hex2addr>
f0100832:	83 c4 04             	add    $0x4,%esp
f0100835:	89 c3                	mov    %eax,%ebx
f0100837:	8b 45 0c             	mov    0xc(%ebp),%eax
f010083a:	ff 70 08             	pushl  0x8(%eax)
f010083d:	e8 90 ff ff ff       	call   f01007d2 <hex2addr>
f0100842:	83 c4 0c             	add    $0xc,%esp
f0100845:	89 c7                	mov    %eax,%edi
	cprintf("BEGIN_ADDR: %x	END_ADDR: %x\n", beg, end);
f0100847:	50                   	push   %eax
f0100848:	53                   	push   %ebx
f0100849:	68 d5 3e 10 f0       	push   $0xf0103ed5
f010084e:	e8 8a 23 00 00       	call   f0102bdd <cprintf>
	while(beg <= end){
f0100853:	83 c4 10             	add    $0x10,%esp
f0100856:	39 fb                	cmp    %edi,%ebx
f0100858:	0f 87 94 00 00 00    	ja     f01008f2 <showmappings+0xec>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*)beg, 1);
f010085e:	83 ec 04             	sub    $0x4,%esp
f0100861:	6a 01                	push   $0x1
f0100863:	53                   	push   %ebx
f0100864:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010086a:	e8 73 08 00 00       	call   f01010e2 <pgdir_walk>
f010086f:	89 c6                	mov    %eax,%esi
		struct PageInfo* pp;
		pp = page_lookup(kern_pgdir, (void*)beg, 0);
f0100871:	83 c4 0c             	add    $0xc,%esp
f0100874:	6a 00                	push   $0x0
f0100876:	53                   	push   %ebx
f0100877:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010087d:	e8 6a 09 00 00       	call   f01011ec <page_lookup>
		if(pte == NULL)
f0100882:	83 c4 10             	add    $0x10,%esp
f0100885:	85 f6                	test   %esi,%esi
f0100887:	74 76                	je     f01008ff <showmappings+0xf9>
			panic("OOM");
		if(*pte | PTE_P){
			cprintf("page %x %x		", beg, page2pa(pp));
f0100889:	83 ec 04             	sub    $0x4,%esp
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010088c:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100892:	c1 f8 03             	sar    $0x3,%eax
f0100895:	c1 e0 0c             	shl    $0xc,%eax
f0100898:	50                   	push   %eax
f0100899:	53                   	push   %ebx
f010089a:	68 05 3f 10 f0       	push   $0xf0103f05
f010089f:	e8 39 23 00 00       	call   f0102bdd <cprintf>
			cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte&PTE_P, (*pte&PTE_W)>>1, (*pte&PTE_U)>>2);
f01008a4:	8b 06                	mov    (%esi),%eax
f01008a6:	89 c2                	mov    %eax,%edx
f01008a8:	c1 ea 02             	shr    $0x2,%edx
f01008ab:	83 e2 01             	and    $0x1,%edx
f01008ae:	52                   	push   %edx
f01008af:	89 c2                	mov    %eax,%edx
f01008b1:	d1 ea                	shr    %edx
f01008b3:	83 e2 01             	and    $0x1,%edx
f01008b6:	52                   	push   %edx
f01008b7:	83 e0 01             	and    $0x1,%eax
f01008ba:	50                   	push   %eax
f01008bb:	68 64 41 10 f0       	push   $0xf0104164
f01008c0:	e8 18 23 00 00       	call   f0102bdd <cprintf>
		}
		else{
			cprintf("page %x	not exist", beg);
		}
		beg += PGSIZE;
f01008c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01008cb:	83 c4 20             	add    $0x20,%esp
f01008ce:	eb 86                	jmp    f0100856 <showmappings+0x50>
		cprintf("Format: showmappings 0xBEGIN_ADRR 0xEND_ADRR\n");
f01008d0:	83 ec 0c             	sub    $0xc,%esp
f01008d3:	68 34 41 10 f0       	push   $0xf0104134
f01008d8:	e8 00 23 00 00       	call   f0102bdd <cprintf>
		return 0;
f01008dd:	83 c4 10             	add    $0x10,%esp
f01008e0:	eb 10                	jmp    f01008f2 <showmappings+0xec>
		cprintf("WRONG FORMAT\n");
f01008e2:	83 ec 0c             	sub    $0xc,%esp
f01008e5:	68 c7 3e 10 f0       	push   $0xf0103ec7
f01008ea:	e8 ee 22 00 00       	call   f0102bdd <cprintf>
		return 0;	
f01008ef:	83 c4 10             	add    $0x10,%esp
	}
	return 0;
}
f01008f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008fa:	5b                   	pop    %ebx
f01008fb:	5e                   	pop    %esi
f01008fc:	5f                   	pop    %edi
f01008fd:	5d                   	pop    %ebp
f01008fe:	c3                   	ret    
			panic("OOM");
f01008ff:	83 ec 04             	sub    $0x4,%esp
f0100902:	68 f2 3e 10 f0       	push   $0xf0103ef2
f0100907:	6a 79                	push   $0x79
f0100909:	68 f6 3e 10 f0       	push   $0xf0103ef6
f010090e:	e8 78 f7 ff ff       	call   f010008b <_panic>

f0100913 <setm>:

int
setm(int argc, char** argv, struct Trapframe *tf){
f0100913:	55                   	push   %ebp
f0100914:	89 e5                	mov    %esp,%ebp
f0100916:	57                   	push   %edi
f0100917:	56                   	push   %esi
f0100918:	53                   	push   %ebx
f0100919:	83 ec 0c             	sub    $0xc,%esp
f010091c:	8b 45 08             	mov    0x8(%ebp),%eax
f010091f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc == 1){
f0100922:	83 f8 01             	cmp    $0x1,%eax
f0100925:	0f 84 db 00 00 00    	je     f0100a06 <setm+0xf3>
		cprintf("Format: setm 0xADDR 0(SET)|1(CLEAN) P|W|U\n");
		return 0;
	}
	if(argc < 4){
f010092b:	83 f8 03             	cmp    $0x3,%eax
f010092e:	0f 8e e4 00 00 00    	jle    f0100a18 <setm+0x105>
		cprintf("WRONG FORMAT\n");
		return 0;
	}
	uint32_t addr = hex2addr(argv[1]);
f0100934:	83 ec 0c             	sub    $0xc,%esp
f0100937:	ff 73 04             	pushl  0x4(%ebx)
f010093a:	e8 93 fe ff ff       	call   f01007d2 <hex2addr>
f010093f:	83 c4 0c             	add    $0xc,%esp
f0100942:	89 c7                	mov    %eax,%edi
	pte_t* pte = pgdir_walk(kern_pgdir, (void*)addr, 1);
f0100944:	6a 01                	push   $0x1
f0100946:	50                   	push   %eax
f0100947:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010094d:	e8 90 07 00 00       	call   f01010e2 <pgdir_walk>
f0100952:	89 c6                	mov    %eax,%esi
	cprintf("address: %x before setting: ", addr);
f0100954:	83 c4 08             	add    $0x8,%esp
f0100957:	57                   	push   %edi
f0100958:	68 12 3f 10 f0       	push   $0xf0103f12
f010095d:	e8 7b 22 00 00       	call   f0102bdd <cprintf>
	cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte&PTE_P, (*pte&PTE_W)>>1, (*pte&PTE_U)>>2);
f0100962:	8b 06                	mov    (%esi),%eax
f0100964:	89 c2                	mov    %eax,%edx
f0100966:	c1 ea 02             	shr    $0x2,%edx
f0100969:	83 e2 01             	and    $0x1,%edx
f010096c:	52                   	push   %edx
f010096d:	89 c2                	mov    %eax,%edx
f010096f:	d1 ea                	shr    %edx
f0100971:	83 e2 01             	and    $0x1,%edx
f0100974:	52                   	push   %edx
f0100975:	83 e0 01             	and    $0x1,%eax
f0100978:	50                   	push   %eax
f0100979:	68 64 41 10 f0       	push   $0xf0104164
f010097e:	e8 5a 22 00 00       	call   f0102bdd <cprintf>
	uint32_t perm = 0;
	if(argv[3][0] == 'P'){
f0100983:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100986:	0f b6 00             	movzbl (%eax),%eax
f0100989:	83 c4 20             	add    $0x20,%esp
f010098c:	3c 50                	cmp    $0x50,%al
f010098e:	0f 84 96 00 00 00    	je     f0100a2a <setm+0x117>
		perm = PTE_P;
		cprintf("set present\n");
	}
	else if(argv[3][0] == 'W'){
f0100994:	3c 57                	cmp    $0x57,%al
f0100996:	0f 84 a8 00 00 00    	je     f0100a44 <setm+0x131>
	uint32_t perm = 0;
f010099c:	ba 00 00 00 00       	mov    $0x0,%edx
		perm = PTE_W;
		cprintf("set writable\n");
	}
	else if(argv[3][0] == 'U'){
f01009a1:	3c 55                	cmp    $0x55,%al
f01009a3:	0f 84 b5 00 00 00    	je     f0100a5e <setm+0x14b>
		perm = PTE_U;
		cprintf("set user\n");
	}
	if(argv[2][0] == '0'){
f01009a9:	8b 43 08             	mov    0x8(%ebx),%eax
f01009ac:	80 38 30             	cmpb   $0x30,(%eax)
f01009af:	0f 84 c3 00 00 00    	je     f0100a78 <setm+0x165>
		*pte &= ~perm;
		cprintf("set zero\n");
	}
	else{
		*pte |= perm;
f01009b5:	09 16                	or     %edx,(%esi)
		cprintf("set positive\n");
f01009b7:	83 ec 0c             	sub    $0xc,%esp
f01009ba:	68 5e 3f 10 f0       	push   $0xf0103f5e
f01009bf:	e8 19 22 00 00       	call   f0102bdd <cprintf>
f01009c4:	83 c4 10             	add    $0x10,%esp
	}
	cprintf("address: %x after setting: ", addr);
f01009c7:	83 ec 08             	sub    $0x8,%esp
f01009ca:	57                   	push   %edi
f01009cb:	68 6c 3f 10 f0       	push   $0xf0103f6c
f01009d0:	e8 08 22 00 00       	call   f0102bdd <cprintf>
	cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte&PTE_P, (*pte&PTE_W)>>1, (*pte&PTE_U)>>2);
f01009d5:	8b 06                	mov    (%esi),%eax
f01009d7:	89 c2                	mov    %eax,%edx
f01009d9:	c1 ea 02             	shr    $0x2,%edx
f01009dc:	83 e2 01             	and    $0x1,%edx
f01009df:	52                   	push   %edx
f01009e0:	89 c2                	mov    %eax,%edx
f01009e2:	d1 ea                	shr    %edx
f01009e4:	83 e2 01             	and    $0x1,%edx
f01009e7:	52                   	push   %edx
f01009e8:	83 e0 01             	and    $0x1,%eax
f01009eb:	50                   	push   %eax
f01009ec:	68 64 41 10 f0       	push   $0xf0104164
f01009f1:	e8 e7 21 00 00       	call   f0102bdd <cprintf>
	return 0;
f01009f6:	83 c4 20             	add    $0x20,%esp
}
f01009f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a01:	5b                   	pop    %ebx
f0100a02:	5e                   	pop    %esi
f0100a03:	5f                   	pop    %edi
f0100a04:	5d                   	pop    %ebp
f0100a05:	c3                   	ret    
		cprintf("Format: setm 0xADDR 0(SET)|1(CLEAN) P|W|U\n");
f0100a06:	83 ec 0c             	sub    $0xc,%esp
f0100a09:	68 84 41 10 f0       	push   $0xf0104184
f0100a0e:	e8 ca 21 00 00       	call   f0102bdd <cprintf>
		return 0;
f0100a13:	83 c4 10             	add    $0x10,%esp
f0100a16:	eb e1                	jmp    f01009f9 <setm+0xe6>
		cprintf("WRONG FORMAT\n");
f0100a18:	83 ec 0c             	sub    $0xc,%esp
f0100a1b:	68 c7 3e 10 f0       	push   $0xf0103ec7
f0100a20:	e8 b8 21 00 00       	call   f0102bdd <cprintf>
		return 0;
f0100a25:	83 c4 10             	add    $0x10,%esp
f0100a28:	eb cf                	jmp    f01009f9 <setm+0xe6>
		cprintf("set present\n");
f0100a2a:	83 ec 0c             	sub    $0xc,%esp
f0100a2d:	68 2f 3f 10 f0       	push   $0xf0103f2f
f0100a32:	e8 a6 21 00 00       	call   f0102bdd <cprintf>
f0100a37:	83 c4 10             	add    $0x10,%esp
		perm = PTE_P;
f0100a3a:	ba 01 00 00 00       	mov    $0x1,%edx
f0100a3f:	e9 65 ff ff ff       	jmp    f01009a9 <setm+0x96>
		cprintf("set writable\n");
f0100a44:	83 ec 0c             	sub    $0xc,%esp
f0100a47:	68 3c 3f 10 f0       	push   $0xf0103f3c
f0100a4c:	e8 8c 21 00 00       	call   f0102bdd <cprintf>
f0100a51:	83 c4 10             	add    $0x10,%esp
		perm = PTE_W;
f0100a54:	ba 02 00 00 00       	mov    $0x2,%edx
f0100a59:	e9 4b ff ff ff       	jmp    f01009a9 <setm+0x96>
		cprintf("set user\n");
f0100a5e:	83 ec 0c             	sub    $0xc,%esp
f0100a61:	68 4a 3f 10 f0       	push   $0xf0103f4a
f0100a66:	e8 72 21 00 00       	call   f0102bdd <cprintf>
f0100a6b:	83 c4 10             	add    $0x10,%esp
		perm = PTE_U;
f0100a6e:	ba 04 00 00 00       	mov    $0x4,%edx
f0100a73:	e9 31 ff ff ff       	jmp    f01009a9 <setm+0x96>
		*pte &= ~perm;
f0100a78:	f7 d2                	not    %edx
f0100a7a:	21 16                	and    %edx,(%esi)
		cprintf("set zero\n");
f0100a7c:	83 ec 0c             	sub    $0xc,%esp
f0100a7f:	68 54 3f 10 f0       	push   $0xf0103f54
f0100a84:	e8 54 21 00 00       	call   f0102bdd <cprintf>
f0100a89:	83 c4 10             	add    $0x10,%esp
f0100a8c:	e9 36 ff ff ff       	jmp    f01009c7 <setm+0xb4>

f0100a91 <showvm>:

int
showvm(int argc, char** argv, struct Trapframe *tf){
f0100a91:	55                   	push   %ebp
f0100a92:	89 e5                	mov    %esp,%ebp
f0100a94:	56                   	push   %esi
f0100a95:	53                   	push   %ebx
f0100a96:	8b 45 08             	mov    0x8(%ebp),%eax
	if(argc == 1){
f0100a99:	83 f8 01             	cmp    $0x1,%eax
f0100a9c:	74 2b                	je     f0100ac9 <showvm+0x38>
		cprintf("Format: showvm 0xADDR 0xNUM\n");
		return 0;
	}
	if(argc < 3){
f0100a9e:	83 f8 02             	cmp    $0x2,%eax
f0100aa1:	7e 38                	jle    f0100adb <showvm+0x4a>
		cprintf("WRONG FORMAT\n");
		return 0;
	}
	void** addr = (void**)hex2addr(argv[1]);
f0100aa3:	83 ec 0c             	sub    $0xc,%esp
f0100aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100aa9:	ff 70 04             	pushl  0x4(%eax)
f0100aac:	e8 21 fd ff ff       	call   f01007d2 <hex2addr>
f0100ab1:	83 c4 04             	add    $0x4,%esp
f0100ab4:	89 c3                	mov    %eax,%ebx
	uint32_t num = hex2addr(argv[2]);
f0100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ab9:	ff 70 08             	pushl  0x8(%eax)
f0100abc:	e8 11 fd ff ff       	call   f01007d2 <hex2addr>
f0100ac1:	83 c4 10             	add    $0x10,%esp
f0100ac4:	8d 34 83             	lea    (%ebx,%eax,4),%esi
	for(int i = 0; i < num; i++)
f0100ac7:	eb 3a                	jmp    f0100b03 <showvm+0x72>
		cprintf("Format: showvm 0xADDR 0xNUM\n");
f0100ac9:	83 ec 0c             	sub    $0xc,%esp
f0100acc:	68 88 3f 10 f0       	push   $0xf0103f88
f0100ad1:	e8 07 21 00 00       	call   f0102bdd <cprintf>
		return 0;
f0100ad6:	83 c4 10             	add    $0x10,%esp
f0100ad9:	eb 2c                	jmp    f0100b07 <showvm+0x76>
		cprintf("WRONG FORMAT\n");
f0100adb:	83 ec 0c             	sub    $0xc,%esp
f0100ade:	68 c7 3e 10 f0       	push   $0xf0103ec7
f0100ae3:	e8 f5 20 00 00       	call   f0102bdd <cprintf>
		return 0;
f0100ae8:	83 c4 10             	add    $0x10,%esp
f0100aeb:	eb 1a                	jmp    f0100b07 <showvm+0x76>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100aed:	83 ec 04             	sub    $0x4,%esp
f0100af0:	ff 33                	pushl  (%ebx)
f0100af2:	53                   	push   %ebx
f0100af3:	68 a5 3f 10 f0       	push   $0xf0103fa5
f0100af8:	e8 e0 20 00 00       	call   f0102bdd <cprintf>
f0100afd:	83 c3 04             	add    $0x4,%ebx
f0100b00:	83 c4 10             	add    $0x10,%esp
	for(int i = 0; i < num; i++)
f0100b03:	39 f3                	cmp    %esi,%ebx
f0100b05:	75 e6                	jne    f0100aed <showvm+0x5c>
	return 0;
}
f0100b07:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b0f:	5b                   	pop    %ebx
f0100b10:	5e                   	pop    %esi
f0100b11:	5d                   	pop    %ebp
f0100b12:	c3                   	ret    

f0100b13 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b13:	55                   	push   %ebp
f0100b14:	89 e5                	mov    %esp,%ebp
f0100b16:	57                   	push   %edi
f0100b17:	56                   	push   %esi
f0100b18:	53                   	push   %ebx
f0100b19:	83 ec 58             	sub    $0x58,%esp
	char *buf;
	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b1c:	68 b0 41 10 f0       	push   $0xf01041b0
f0100b21:	e8 b7 20 00 00       	call   f0102bdd <cprintf>
	cprintf("Type help for a list of commands.\n");
f0100b26:	c7 04 24 d4 41 10 f0 	movl   $0xf01041d4,(%esp)
f0100b2d:	e8 ab 20 00 00       	call   f0102bdd <cprintf>
f0100b32:	83 c4 10             	add    $0x10,%esp
f0100b35:	eb 47                	jmp    f0100b7e <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100b37:	83 ec 08             	sub    $0x8,%esp
f0100b3a:	0f be c0             	movsbl %al,%eax
f0100b3d:	50                   	push   %eax
f0100b3e:	68 b9 3f 10 f0       	push   $0xf0103fb9
f0100b43:	e8 f9 2b 00 00       	call   f0103741 <strchr>
f0100b48:	83 c4 10             	add    $0x10,%esp
f0100b4b:	85 c0                	test   %eax,%eax
f0100b4d:	74 0a                	je     f0100b59 <monitor+0x46>
			*buf++ = 0;
f0100b4f:	c6 03 00             	movb   $0x0,(%ebx)
f0100b52:	89 fe                	mov    %edi,%esi
f0100b54:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b57:	eb 6b                	jmp    f0100bc4 <monitor+0xb1>
		if (*buf == 0)
f0100b59:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b5c:	74 73                	je     f0100bd1 <monitor+0xbe>
		if (argc == MAXARGS-1) {
f0100b5e:	83 ff 0f             	cmp    $0xf,%edi
f0100b61:	74 09                	je     f0100b6c <monitor+0x59>
		argv[argc++] = buf;
f0100b63:	8d 77 01             	lea    0x1(%edi),%esi
f0100b66:	89 5c bd a8          	mov    %ebx,-0x58(%ebp,%edi,4)
f0100b6a:	eb 39                	jmp    f0100ba5 <monitor+0x92>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b6c:	83 ec 08             	sub    $0x8,%esp
f0100b6f:	6a 10                	push   $0x10
f0100b71:	68 be 3f 10 f0       	push   $0xf0103fbe
f0100b76:	e8 62 20 00 00       	call   f0102bdd <cprintf>
f0100b7b:	83 c4 10             	add    $0x10,%esp
	while (1) {
		buf = readline("K> ");
f0100b7e:	83 ec 0c             	sub    $0xc,%esp
f0100b81:	68 b5 3f 10 f0       	push   $0xf0103fb5
f0100b86:	e8 99 29 00 00       	call   f0103524 <readline>
f0100b8b:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b8d:	83 c4 10             	add    $0x10,%esp
f0100b90:	85 c0                	test   %eax,%eax
f0100b92:	74 ea                	je     f0100b7e <monitor+0x6b>
	argv[argc] = 0;
f0100b94:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100b9b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ba0:	eb 24                	jmp    f0100bc6 <monitor+0xb3>
			buf++;
f0100ba2:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ba5:	0f b6 03             	movzbl (%ebx),%eax
f0100ba8:	84 c0                	test   %al,%al
f0100baa:	74 18                	je     f0100bc4 <monitor+0xb1>
f0100bac:	83 ec 08             	sub    $0x8,%esp
f0100baf:	0f be c0             	movsbl %al,%eax
f0100bb2:	50                   	push   %eax
f0100bb3:	68 b9 3f 10 f0       	push   $0xf0103fb9
f0100bb8:	e8 84 2b 00 00       	call   f0103741 <strchr>
f0100bbd:	83 c4 10             	add    $0x10,%esp
f0100bc0:	85 c0                	test   %eax,%eax
f0100bc2:	74 de                	je     f0100ba2 <monitor+0x8f>
			*buf++ = 0;
f0100bc4:	89 f7                	mov    %esi,%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100bc6:	0f b6 03             	movzbl (%ebx),%eax
f0100bc9:	84 c0                	test   %al,%al
f0100bcb:	0f 85 66 ff ff ff    	jne    f0100b37 <monitor+0x24>
	argv[argc] = 0;
f0100bd1:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100bd8:	00 
	if (argc == 0)
f0100bd9:	85 ff                	test   %edi,%edi
f0100bdb:	74 a1                	je     f0100b7e <monitor+0x6b>
	for (i = 0; i < NCOMMANDS; i++) {
f0100bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100be2:	83 ec 08             	sub    $0x8,%esp
f0100be5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100be8:	ff 34 85 20 42 10 f0 	pushl  -0xfefbde0(,%eax,4)
f0100bef:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bf2:	e8 ec 2a 00 00       	call   f01036e3 <strcmp>
f0100bf7:	83 c4 10             	add    $0x10,%esp
f0100bfa:	85 c0                	test   %eax,%eax
f0100bfc:	74 20                	je     f0100c1e <monitor+0x10b>
	for (i = 0; i < NCOMMANDS; i++) {
f0100bfe:	83 c3 01             	add    $0x1,%ebx
f0100c01:	83 fb 05             	cmp    $0x5,%ebx
f0100c04:	75 dc                	jne    f0100be2 <monitor+0xcf>
	cprintf("Unknown command %s\n", argv[0]);
f0100c06:	83 ec 08             	sub    $0x8,%esp
f0100c09:	ff 75 a8             	pushl  -0x58(%ebp)
f0100c0c:	68 db 3f 10 f0       	push   $0xf0103fdb
f0100c11:	e8 c7 1f 00 00       	call   f0102bdd <cprintf>
f0100c16:	83 c4 10             	add    $0x10,%esp
f0100c19:	e9 60 ff ff ff       	jmp    f0100b7e <monitor+0x6b>
			return commands[i].func(argc, argv, tf);
f0100c1e:	83 ec 04             	sub    $0x4,%esp
f0100c21:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c24:	ff 75 08             	pushl  0x8(%ebp)
f0100c27:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100c2a:	52                   	push   %edx
f0100c2b:	57                   	push   %edi
f0100c2c:	ff 14 85 28 42 10 f0 	call   *-0xfefbdd8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100c33:	83 c4 10             	add    $0x10,%esp
f0100c36:	85 c0                	test   %eax,%eax
f0100c38:	0f 89 40 ff ff ff    	jns    f0100b7e <monitor+0x6b>
				break;
	}
}
f0100c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c41:	5b                   	pop    %ebx
f0100c42:	5e                   	pop    %esi
f0100c43:	5f                   	pop    %edi
f0100c44:	5d                   	pop    %ebp
f0100c45:	c3                   	ret    

f0100c46 <boot_alloc>:
// If were out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c46:	55                   	push   %ebp
f0100c47:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// end is a magic symbol automatically generated by the linker,
	// which points to the end of the kernels bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c49:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
f0100c50:	74 1d                	je     f0100c6f <boot_alloc+0x29>
	// Allocate a chunk large enough to hold n bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100c52:	8b 0d 38 85 11 f0    	mov    0xf0118538,%ecx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100c58:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100c5f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c65:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
	return result;
}
f0100c6b:	89 c8                	mov    %ecx,%eax
f0100c6d:	5d                   	pop    %ebp
f0100c6e:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c6f:	ba 73 99 11 f0       	mov    $0xf0119973,%edx
f0100c74:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c7a:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
f0100c80:	eb d0                	jmp    f0100c52 <boot_alloc+0xc>

f0100c82 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c82:	89 d1                	mov    %edx,%ecx
f0100c84:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100c87:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c8a:	a8 01                	test   $0x1,%al
f0100c8c:	74 52                	je     f0100ce0 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100c93:	89 c1                	mov    %eax,%ecx
f0100c95:	c1 e9 0c             	shr    $0xc,%ecx
f0100c98:	3b 0d 68 89 11 f0    	cmp    0xf0118968,%ecx
f0100c9e:	73 25                	jae    f0100cc5 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100ca0:	c1 ea 0c             	shr    $0xc,%edx
f0100ca3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ca9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100cb0:	89 c2                	mov    %eax,%edx
f0100cb2:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100cb5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cba:	85 d2                	test   %edx,%edx
f0100cbc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100cc1:	0f 44 c2             	cmove  %edx,%eax
f0100cc4:	c3                   	ret    
{
f0100cc5:	55                   	push   %ebp
f0100cc6:	89 e5                	mov    %esp,%ebp
f0100cc8:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ccb:	50                   	push   %eax
f0100ccc:	68 5c 42 10 f0       	push   $0xf010425c
f0100cd1:	68 cf 02 00 00       	push   $0x2cf
f0100cd6:	68 b0 49 10 f0       	push   $0xf01049b0
f0100cdb:	e8 ab f3 ff ff       	call   f010008b <_panic>
		return ~0;
f0100ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100ce5:	c3                   	ret    

f0100ce6 <check_page_free_list>:
{
f0100ce6:	55                   	push   %ebp
f0100ce7:	89 e5                	mov    %esp,%ebp
f0100ce9:	57                   	push   %edi
f0100cea:	56                   	push   %esi
f0100ceb:	53                   	push   %ebx
f0100cec:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cef:	84 c0                	test   %al,%al
f0100cf1:	0f 85 48 02 00 00    	jne    f0100f3f <check_page_free_list+0x259>
	if (!page_free_list)
f0100cf7:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f0100cfe:	74 0a                	je     f0100d0a <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d00:	be 00 04 00 00       	mov    $0x400,%esi
f0100d05:	e9 90 02 00 00       	jmp    f0100f9a <check_page_free_list+0x2b4>
		panic("page_free_list is a null pointer!");
f0100d0a:	83 ec 04             	sub    $0x4,%esp
f0100d0d:	68 80 42 10 f0       	push   $0xf0104280
f0100d12:	68 12 02 00 00       	push   $0x212
f0100d17:	68 b0 49 10 f0       	push   $0xf01049b0
f0100d1c:	e8 6a f3 ff ff       	call   f010008b <_panic>
f0100d21:	50                   	push   %eax
f0100d22:	68 5c 42 10 f0       	push   $0xf010425c
f0100d27:	6a 52                	push   $0x52
f0100d29:	68 bc 49 10 f0       	push   $0xf01049bc
f0100d2e:	e8 58 f3 ff ff       	call   f010008b <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d33:	8b 1b                	mov    (%ebx),%ebx
f0100d35:	85 db                	test   %ebx,%ebx
f0100d37:	74 41                	je     f0100d7a <check_page_free_list+0x94>
	return (pp - pages) << PGSHIFT;
f0100d39:	89 d8                	mov    %ebx,%eax
f0100d3b:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100d41:	c1 f8 03             	sar    $0x3,%eax
f0100d44:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d47:	89 c2                	mov    %eax,%edx
f0100d49:	c1 ea 16             	shr    $0x16,%edx
f0100d4c:	39 f2                	cmp    %esi,%edx
f0100d4e:	73 e3                	jae    f0100d33 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100d50:	89 c2                	mov    %eax,%edx
f0100d52:	c1 ea 0c             	shr    $0xc,%edx
f0100d55:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0100d5b:	73 c4                	jae    f0100d21 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100d5d:	83 ec 04             	sub    $0x4,%esp
f0100d60:	68 80 00 00 00       	push   $0x80
f0100d65:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100d6a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d6f:	50                   	push   %eax
f0100d70:	e8 09 2a 00 00       	call   f010377e <memset>
f0100d75:	83 c4 10             	add    $0x10,%esp
f0100d78:	eb b9                	jmp    f0100d33 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100d7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d7f:	e8 c2 fe ff ff       	call   f0100c46 <boot_alloc>
f0100d84:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d87:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		assert(pp >= pages);
f0100d8d:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
		assert(pp < pages + npages);
f0100d93:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100d98:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100d9b:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d9e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100da1:	be 00 00 00 00       	mov    $0x0,%esi
f0100da6:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100da9:	e9 c9 00 00 00       	jmp    f0100e77 <check_page_free_list+0x191>
		assert(pp >= pages);
f0100dae:	68 ca 49 10 f0       	push   $0xf01049ca
f0100db3:	68 d6 49 10 f0       	push   $0xf01049d6
f0100db8:	68 2c 02 00 00       	push   $0x22c
f0100dbd:	68 b0 49 10 f0       	push   $0xf01049b0
f0100dc2:	e8 c4 f2 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100dc7:	68 eb 49 10 f0       	push   $0xf01049eb
f0100dcc:	68 d6 49 10 f0       	push   $0xf01049d6
f0100dd1:	68 2d 02 00 00       	push   $0x22d
f0100dd6:	68 b0 49 10 f0       	push   $0xf01049b0
f0100ddb:	e8 ab f2 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100de0:	68 a4 42 10 f0       	push   $0xf01042a4
f0100de5:	68 d6 49 10 f0       	push   $0xf01049d6
f0100dea:	68 2e 02 00 00       	push   $0x22e
f0100def:	68 b0 49 10 f0       	push   $0xf01049b0
f0100df4:	e8 92 f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != 0);
f0100df9:	68 ff 49 10 f0       	push   $0xf01049ff
f0100dfe:	68 d6 49 10 f0       	push   $0xf01049d6
f0100e03:	68 31 02 00 00       	push   $0x231
f0100e08:	68 b0 49 10 f0       	push   $0xf01049b0
f0100e0d:	e8 79 f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e12:	68 10 4a 10 f0       	push   $0xf0104a10
f0100e17:	68 d6 49 10 f0       	push   $0xf01049d6
f0100e1c:	68 32 02 00 00       	push   $0x232
f0100e21:	68 b0 49 10 f0       	push   $0xf01049b0
f0100e26:	e8 60 f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e2b:	68 d8 42 10 f0       	push   $0xf01042d8
f0100e30:	68 d6 49 10 f0       	push   $0xf01049d6
f0100e35:	68 33 02 00 00       	push   $0x233
f0100e3a:	68 b0 49 10 f0       	push   $0xf01049b0
f0100e3f:	e8 47 f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e44:	68 29 4a 10 f0       	push   $0xf0104a29
f0100e49:	68 d6 49 10 f0       	push   $0xf01049d6
f0100e4e:	68 34 02 00 00       	push   $0x234
f0100e53:	68 b0 49 10 f0       	push   $0xf01049b0
f0100e58:	e8 2e f2 ff ff       	call   f010008b <_panic>
	if (PGNUM(pa) >= npages)
f0100e5d:	89 c3                	mov    %eax,%ebx
f0100e5f:	c1 eb 0c             	shr    $0xc,%ebx
f0100e62:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100e65:	76 68                	jbe    f0100ecf <check_page_free_list+0x1e9>
	return (void *)(pa + KERNBASE);
f0100e67:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e6c:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100e6f:	77 70                	ja     f0100ee1 <check_page_free_list+0x1fb>
			++nfree_extmem;
f0100e71:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e75:	8b 12                	mov    (%edx),%edx
f0100e77:	85 d2                	test   %edx,%edx
f0100e79:	74 7f                	je     f0100efa <check_page_free_list+0x214>
		assert(pp >= pages);
f0100e7b:	39 d1                	cmp    %edx,%ecx
f0100e7d:	0f 87 2b ff ff ff    	ja     f0100dae <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100e83:	39 d7                	cmp    %edx,%edi
f0100e85:	0f 86 3c ff ff ff    	jbe    f0100dc7 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e8b:	89 d0                	mov    %edx,%eax
f0100e8d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100e90:	a8 07                	test   $0x7,%al
f0100e92:	0f 85 48 ff ff ff    	jne    f0100de0 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100e98:	c1 f8 03             	sar    $0x3,%eax
f0100e9b:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100e9e:	85 c0                	test   %eax,%eax
f0100ea0:	0f 84 53 ff ff ff    	je     f0100df9 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ea6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100eab:	0f 84 61 ff ff ff    	je     f0100e12 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100eb1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100eb6:	0f 84 6f ff ff ff    	je     f0100e2b <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ebc:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ec1:	74 81                	je     f0100e44 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ec3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ec8:	77 93                	ja     f0100e5d <check_page_free_list+0x177>
			++nfree_basemem;
f0100eca:	83 c6 01             	add    $0x1,%esi
f0100ecd:	eb a6                	jmp    f0100e75 <check_page_free_list+0x18f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ecf:	50                   	push   %eax
f0100ed0:	68 5c 42 10 f0       	push   $0xf010425c
f0100ed5:	6a 52                	push   $0x52
f0100ed7:	68 bc 49 10 f0       	push   $0xf01049bc
f0100edc:	e8 aa f1 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ee1:	68 fc 42 10 f0       	push   $0xf01042fc
f0100ee6:	68 d6 49 10 f0       	push   $0xf01049d6
f0100eeb:	68 35 02 00 00       	push   $0x235
f0100ef0:	68 b0 49 10 f0       	push   $0xf01049b0
f0100ef5:	e8 91 f1 ff ff       	call   f010008b <_panic>
f0100efa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100efd:	85 f6                	test   %esi,%esi
f0100eff:	7e 0c                	jle    f0100f0d <check_page_free_list+0x227>
	assert(nfree_extmem > 0);
f0100f01:	85 db                	test   %ebx,%ebx
f0100f03:	7e 21                	jle    f0100f26 <check_page_free_list+0x240>
}
f0100f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f08:	5b                   	pop    %ebx
f0100f09:	5e                   	pop    %esi
f0100f0a:	5f                   	pop    %edi
f0100f0b:	5d                   	pop    %ebp
f0100f0c:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100f0d:	68 43 4a 10 f0       	push   $0xf0104a43
f0100f12:	68 d6 49 10 f0       	push   $0xf01049d6
f0100f17:	68 3d 02 00 00       	push   $0x23d
f0100f1c:	68 b0 49 10 f0       	push   $0xf01049b0
f0100f21:	e8 65 f1 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100f26:	68 55 4a 10 f0       	push   $0xf0104a55
f0100f2b:	68 d6 49 10 f0       	push   $0xf01049d6
f0100f30:	68 3e 02 00 00       	push   $0x23e
f0100f35:	68 b0 49 10 f0       	push   $0xf01049b0
f0100f3a:	e8 4c f1 ff ff       	call   f010008b <_panic>
	if (!page_free_list)
f0100f3f:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0100f44:	85 c0                	test   %eax,%eax
f0100f46:	0f 84 be fd ff ff    	je     f0100d0a <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f4c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f52:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100f58:	89 c2                	mov    %eax,%edx
f0100f5a:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f60:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f66:	0f 95 c2             	setne  %dl
f0100f69:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f6c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f70:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f72:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f76:	8b 00                	mov    (%eax),%eax
f0100f78:	85 c0                	test   %eax,%eax
f0100f7a:	75 dc                	jne    f0100f58 <check_page_free_list+0x272>
		*tp[1] = 0;
f0100f7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f85:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f8b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f90:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f95:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f9a:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100fa0:	e9 90 fd ff ff       	jmp    f0100d35 <check_page_free_list+0x4f>

f0100fa5 <page_init>:
{
f0100fa5:	55                   	push   %ebp
f0100fa6:	89 e5                	mov    %esp,%ebp
f0100fa8:	53                   	push   %ebx
	pages[0].pp_ref = 1;
f0100fa9:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0100fae:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0100fb4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	for(i = 1; i<npages;i++){
f0100fba:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100fbf:	eb 4c                	jmp    f010100d <page_init+0x68>
		if(i >= IOPHYSMEM/PGSIZE && (i < EXTPHYSMEM/PGSIZE || i < ((int)(boot_alloc(0) - KERNBASE)/PGSIZE))){
f0100fc1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fc6:	e8 7b fc ff ff       	call   f0100c46 <boot_alloc>
f0100fcb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100fd1:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0100fd6:	85 d2                	test   %edx,%edx
f0100fd8:	0f 49 c2             	cmovns %edx,%eax
f0100fdb:	c1 f8 0c             	sar    $0xc,%eax
f0100fde:	39 d8                	cmp    %ebx,%eax
f0100fe0:	77 43                	ja     f0101025 <page_init+0x80>
			pages[i].pp_ref = 0;
f0100fe2:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100fe9:	89 c2                	mov    %eax,%edx
f0100feb:	03 15 70 89 11 f0    	add    0xf0118970,%edx
f0100ff1:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100ff7:	8b 0d 3c 85 11 f0    	mov    0xf011853c,%ecx
f0100ffd:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100fff:	03 05 70 89 11 f0    	add    0xf0118970,%eax
f0101005:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	for(i = 1; i<npages;i++){
f010100a:	83 c3 01             	add    $0x1,%ebx
f010100d:	39 1d 68 89 11 f0    	cmp    %ebx,0xf0118968
f0101013:	76 26                	jbe    f010103b <page_init+0x96>
		if(i >= IOPHYSMEM/PGSIZE && (i < EXTPHYSMEM/PGSIZE || i < ((int)(boot_alloc(0) - KERNBASE)/PGSIZE))){
f0101015:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f010101b:	76 c5                	jbe    f0100fe2 <page_init+0x3d>
f010101d:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0101023:	77 9c                	ja     f0100fc1 <page_init+0x1c>
			pages[i].pp_ref = 1;
f0101025:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f010102a:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f010102d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0101033:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101039:	eb cf                	jmp    f010100a <page_init+0x65>
}
f010103b:	5b                   	pop    %ebx
f010103c:	5d                   	pop    %ebp
f010103d:	c3                   	ret    

f010103e <page_alloc>:
{
f010103e:	55                   	push   %ebp
f010103f:	89 e5                	mov    %esp,%ebp
f0101041:	53                   	push   %ebx
f0101042:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list){
f0101045:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f010104b:	85 db                	test   %ebx,%ebx
f010104d:	74 0d                	je     f010105c <page_alloc+0x1e>
		page_free_list = page_free_list->pp_link;
f010104f:	8b 03                	mov    (%ebx),%eax
f0101051:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
		if(alloc_flags & ALLOC_ZERO){
f0101056:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010105a:	75 07                	jne    f0101063 <page_alloc+0x25>
}
f010105c:	89 d8                	mov    %ebx,%eax
f010105e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101061:	c9                   	leave  
f0101062:	c3                   	ret    
f0101063:	89 d8                	mov    %ebx,%eax
f0101065:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010106b:	c1 f8 03             	sar    $0x3,%eax
f010106e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101071:	89 c2                	mov    %eax,%edx
f0101073:	c1 ea 0c             	shr    $0xc,%edx
f0101076:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f010107c:	73 1a                	jae    f0101098 <page_alloc+0x5a>
			memset(page2kva(pg), 0, PGSIZE);
f010107e:	83 ec 04             	sub    $0x4,%esp
f0101081:	68 00 10 00 00       	push   $0x1000
f0101086:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101088:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010108d:	50                   	push   %eax
f010108e:	e8 eb 26 00 00       	call   f010377e <memset>
f0101093:	83 c4 10             	add    $0x10,%esp
f0101096:	eb c4                	jmp    f010105c <page_alloc+0x1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101098:	50                   	push   %eax
f0101099:	68 5c 42 10 f0       	push   $0xf010425c
f010109e:	6a 52                	push   $0x52
f01010a0:	68 bc 49 10 f0       	push   $0xf01049bc
f01010a5:	e8 e1 ef ff ff       	call   f010008b <_panic>

f01010aa <page_free>:
{
f01010aa:	55                   	push   %ebp
f01010ab:	89 e5                	mov    %esp,%ebp
f01010ad:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f01010b0:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f01010b6:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01010b8:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
}
f01010bd:	5d                   	pop    %ebp
f01010be:	c3                   	ret    

f01010bf <page_decref>:
{
f01010bf:	55                   	push   %ebp
f01010c0:	89 e5                	mov    %esp,%ebp
f01010c2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010c5:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010c9:	83 e8 01             	sub    $0x1,%eax
f01010cc:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010d0:	66 85 c0             	test   %ax,%ax
f01010d3:	74 02                	je     f01010d7 <page_decref+0x18>
}
f01010d5:	c9                   	leave  
f01010d6:	c3                   	ret    
		page_free(pp);
f01010d7:	52                   	push   %edx
f01010d8:	e8 cd ff ff ff       	call   f01010aa <page_free>
f01010dd:	83 c4 04             	add    $0x4,%esp
}
f01010e0:	eb f3                	jmp    f01010d5 <page_decref+0x16>

f01010e2 <pgdir_walk>:
{
f01010e2:	55                   	push   %ebp
f01010e3:	89 e5                	mov    %esp,%ebp
f01010e5:	56                   	push   %esi
f01010e6:	53                   	push   %ebx
f01010e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	if(!(pgdir[PDX(va)] & PTE_P)){
f01010ea:	89 f3                	mov    %esi,%ebx
f01010ec:	c1 eb 16             	shr    $0x16,%ebx
f01010ef:	c1 e3 02             	shl    $0x2,%ebx
f01010f2:	03 5d 08             	add    0x8(%ebp),%ebx
f01010f5:	f6 03 01             	testb  $0x1,(%ebx)
f01010f8:	75 2d                	jne    f0101127 <pgdir_walk+0x45>
		if(create){
f01010fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010fe:	74 67                	je     f0101167 <pgdir_walk+0x85>
			struct PageInfo* pg = page_alloc(ALLOC_ZERO);
f0101100:	83 ec 0c             	sub    $0xc,%esp
f0101103:	6a 01                	push   $0x1
f0101105:	e8 34 ff ff ff       	call   f010103e <page_alloc>
			if(pg == NULL)
f010110a:	83 c4 10             	add    $0x10,%esp
f010110d:	85 c0                	test   %eax,%eax
f010110f:	74 5d                	je     f010116e <pgdir_walk+0x8c>
			pg->pp_ref++;
f0101111:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101116:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010111c:	c1 f8 03             	sar    $0x3,%eax
f010111f:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[PDX(va)]= page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0101122:	83 c8 07             	or     $0x7,%eax
f0101125:	89 03                	mov    %eax,(%ebx)
	pte_t* pt = KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0101127:	8b 03                	mov    (%ebx),%eax
f0101129:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010112e:	89 c2                	mov    %eax,%edx
f0101130:	c1 ea 0c             	shr    $0xc,%edx
f0101133:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0101139:	73 17                	jae    f0101152 <pgdir_walk+0x70>
	return pt + PTX(va);
f010113b:	c1 ee 0a             	shr    $0xa,%esi
f010113e:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101144:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f010114b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010114e:	5b                   	pop    %ebx
f010114f:	5e                   	pop    %esi
f0101150:	5d                   	pop    %ebp
f0101151:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101152:	50                   	push   %eax
f0101153:	68 5c 42 10 f0       	push   $0xf010425c
f0101158:	68 6c 01 00 00       	push   $0x16c
f010115d:	68 b0 49 10 f0       	push   $0xf01049b0
f0101162:	e8 24 ef ff ff       	call   f010008b <_panic>
			return NULL;
f0101167:	b8 00 00 00 00       	mov    $0x0,%eax
f010116c:	eb dd                	jmp    f010114b <pgdir_walk+0x69>
				return NULL;
f010116e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101173:	eb d6                	jmp    f010114b <pgdir_walk+0x69>

f0101175 <boot_map_region>:
{
f0101175:	55                   	push   %ebp
f0101176:	89 e5                	mov    %esp,%ebp
f0101178:	57                   	push   %edi
f0101179:	56                   	push   %esi
f010117a:	53                   	push   %ebx
f010117b:	83 ec 1c             	sub    $0x1c,%esp
f010117e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101181:	8b 45 08             	mov    0x8(%ebp),%eax
	for(int i = 0; i<size/PGSIZE; i++, va+=PGSIZE, pa+=PGSIZE){
f0101184:	c1 e9 0c             	shr    $0xc,%ecx
f0101187:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010118a:	89 c3                	mov    %eax,%ebx
f010118c:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t* pte = pgdir_walk(pgdir, (void*)va, true);
f0101191:	89 d7                	mov    %edx,%edi
f0101193:	29 c7                	sub    %eax,%edi
		*pte = pa | perm | PTE_P;
f0101195:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101198:	83 c8 01             	or     $0x1,%eax
f010119b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for(int i = 0; i<size/PGSIZE; i++, va+=PGSIZE, pa+=PGSIZE){
f010119e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01011a1:	74 41                	je     f01011e4 <boot_map_region+0x6f>
		pte_t* pte = pgdir_walk(pgdir, (void*)va, true);
f01011a3:	83 ec 04             	sub    $0x4,%esp
f01011a6:	6a 01                	push   $0x1
f01011a8:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01011ab:	50                   	push   %eax
f01011ac:	ff 75 e0             	pushl  -0x20(%ebp)
f01011af:	e8 2e ff ff ff       	call   f01010e2 <pgdir_walk>
		if(pte == NULL)
f01011b4:	83 c4 10             	add    $0x10,%esp
f01011b7:	85 c0                	test   %eax,%eax
f01011b9:	74 12                	je     f01011cd <boot_map_region+0x58>
		*pte = pa | perm | PTE_P;
f01011bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011be:	09 da                	or     %ebx,%edx
f01011c0:	89 10                	mov    %edx,(%eax)
	for(int i = 0; i<size/PGSIZE; i++, va+=PGSIZE, pa+=PGSIZE){
f01011c2:	83 c6 01             	add    $0x1,%esi
f01011c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011cb:	eb d1                	jmp    f010119e <boot_map_region+0x29>
			panic("OOM");
f01011cd:	83 ec 04             	sub    $0x4,%esp
f01011d0:	68 f2 3e 10 f0       	push   $0xf0103ef2
f01011d5:	68 83 01 00 00       	push   $0x183
f01011da:	68 b0 49 10 f0       	push   $0xf01049b0
f01011df:	e8 a7 ee ff ff       	call   f010008b <_panic>
}
f01011e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011e7:	5b                   	pop    %ebx
f01011e8:	5e                   	pop    %esi
f01011e9:	5f                   	pop    %edi
f01011ea:	5d                   	pop    %ebp
f01011eb:	c3                   	ret    

f01011ec <page_lookup>:
{
f01011ec:	55                   	push   %ebp
f01011ed:	89 e5                	mov    %esp,%ebp
f01011ef:	53                   	push   %ebx
f01011f0:	83 ec 08             	sub    $0x8,%esp
f01011f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, false);
f01011f6:	6a 00                	push   $0x0
f01011f8:	ff 75 0c             	pushl  0xc(%ebp)
f01011fb:	ff 75 08             	pushl  0x8(%ebp)
f01011fe:	e8 df fe ff ff       	call   f01010e2 <pgdir_walk>
	if(pte == NULL || !(*pte & PTE_P))
f0101203:	83 c4 10             	add    $0x10,%esp
f0101206:	85 c0                	test   %eax,%eax
f0101208:	74 3a                	je     f0101244 <page_lookup+0x58>
f010120a:	f6 00 01             	testb  $0x1,(%eax)
f010120d:	74 3c                	je     f010124b <page_lookup+0x5f>
	if(pte_store)
f010120f:	85 db                	test   %ebx,%ebx
f0101211:	74 02                	je     f0101215 <page_lookup+0x29>
		*pte_store = pte;
f0101213:	89 03                	mov    %eax,(%ebx)
f0101215:	8b 00                	mov    (%eax),%eax
f0101217:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010121a:	39 05 68 89 11 f0    	cmp    %eax,0xf0118968
f0101220:	76 0e                	jbe    f0101230 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101222:	8b 15 70 89 11 f0    	mov    0xf0118970,%edx
f0101228:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010122b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010122e:	c9                   	leave  
f010122f:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101230:	83 ec 04             	sub    $0x4,%esp
f0101233:	68 44 43 10 f0       	push   $0xf0104344
f0101238:	6a 4b                	push   $0x4b
f010123a:	68 bc 49 10 f0       	push   $0xf01049bc
f010123f:	e8 47 ee ff ff       	call   f010008b <_panic>
		return NULL;
f0101244:	b8 00 00 00 00       	mov    $0x0,%eax
f0101249:	eb e0                	jmp    f010122b <page_lookup+0x3f>
f010124b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101250:	eb d9                	jmp    f010122b <page_lookup+0x3f>

f0101252 <page_remove>:
{
f0101252:	55                   	push   %ebp
f0101253:	89 e5                	mov    %esp,%ebp
f0101255:	53                   	push   %ebx
f0101256:	83 ec 18             	sub    $0x18,%esp
f0101259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010125c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010125f:	50                   	push   %eax
f0101260:	53                   	push   %ebx
f0101261:	ff 75 08             	pushl  0x8(%ebp)
f0101264:	e8 83 ff ff ff       	call   f01011ec <page_lookup>
	if (!pg) 
f0101269:	83 c4 10             	add    $0x10,%esp
f010126c:	85 c0                	test   %eax,%eax
f010126e:	75 05                	jne    f0101275 <page_remove+0x23>
}
f0101270:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101273:	c9                   	leave  
f0101274:	c3                   	ret    
	page_decref(pg);
f0101275:	83 ec 0c             	sub    $0xc,%esp
f0101278:	50                   	push   %eax
f0101279:	e8 41 fe ff ff       	call   f01010bf <page_decref>
	*pte = 0;
f010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101281:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101287:	0f 01 3b             	invlpg (%ebx)
f010128a:	83 c4 10             	add    $0x10,%esp
f010128d:	eb e1                	jmp    f0101270 <page_remove+0x1e>

f010128f <page_insert>:
{
f010128f:	55                   	push   %ebp
f0101290:	89 e5                	mov    %esp,%ebp
f0101292:	57                   	push   %edi
f0101293:	56                   	push   %esi
f0101294:	53                   	push   %ebx
f0101295:	83 ec 10             	sub    $0x10,%esp
f0101298:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010129b:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir,va,0);
f010129e:	6a 00                	push   $0x0
f01012a0:	57                   	push   %edi
f01012a1:	ff 75 08             	pushl  0x8(%ebp)
f01012a4:	e8 39 fe ff ff       	call   f01010e2 <pgdir_walk>
	if(pte)
f01012a9:	83 c4 10             	add    $0x10,%esp
f01012ac:	85 c0                	test   %eax,%eax
f01012ae:	74 57                	je     f0101307 <page_insert+0x78>
f01012b0:	89 c6                	mov    %eax,%esi
		if(*pte & PTE_P)
f01012b2:	f6 00 01             	testb  $0x1,(%eax)
f01012b5:	75 36                	jne    f01012ed <page_insert+0x5e>
		if(page_free_list == pp)
f01012b7:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01012bc:	39 d8                	cmp    %ebx,%eax
f01012be:	74 3e                	je     f01012fe <page_insert+0x6f>
	return (pp - pages) << PGSHIFT;
f01012c0:	89 d8                	mov    %ebx,%eax
f01012c2:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01012c8:	c1 f8 03             	sar    $0x3,%eax
f01012cb:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f01012ce:	8b 55 14             	mov    0x14(%ebp),%edx
f01012d1:	83 ca 01             	or     $0x1,%edx
f01012d4:	09 d0                	or     %edx,%eax
f01012d6:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f01012d8:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
f01012dd:	0f 01 3f             	invlpg (%edi)
	return 0;
f01012e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012e8:	5b                   	pop    %ebx
f01012e9:	5e                   	pop    %esi
f01012ea:	5f                   	pop    %edi
f01012eb:	5d                   	pop    %ebp
f01012ec:	c3                   	ret    
			page_remove(pgdir,va);//取消va与之物理页之间的关联
f01012ed:	83 ec 08             	sub    $0x8,%esp
f01012f0:	57                   	push   %edi
f01012f1:	ff 75 08             	pushl  0x8(%ebp)
f01012f4:	e8 59 ff ff ff       	call   f0101252 <page_remove>
f01012f9:	83 c4 10             	add    $0x10,%esp
f01012fc:	eb b9                	jmp    f01012b7 <page_insert+0x28>
			page_free_list = page_free_list->pp_link;//update the new free_list header
f01012fe:	8b 00                	mov    (%eax),%eax
f0101300:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
f0101305:	eb b9                	jmp    f01012c0 <page_insert+0x31>
		pte = pgdir_walk(pgdir,va,1);
f0101307:	83 ec 04             	sub    $0x4,%esp
f010130a:	6a 01                	push   $0x1
f010130c:	57                   	push   %edi
f010130d:	ff 75 08             	pushl  0x8(%ebp)
f0101310:	e8 cd fd ff ff       	call   f01010e2 <pgdir_walk>
f0101315:	89 c6                	mov    %eax,%esi
		if(pte == NULL)
f0101317:	83 c4 10             	add    $0x10,%esp
f010131a:	85 c0                	test   %eax,%eax
f010131c:	75 a2                	jne    f01012c0 <page_insert+0x31>
			return -E_NO_MEM;
f010131e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101323:	eb c0                	jmp    f01012e5 <page_insert+0x56>

f0101325 <mem_init>:
{
f0101325:	55                   	push   %ebp
f0101326:	89 e5                	mov    %esp,%ebp
f0101328:	57                   	push   %edi
f0101329:	56                   	push   %esi
f010132a:	53                   	push   %ebx
f010132b:	83 ec 38             	sub    $0x38,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010132e:	6a 15                	push   $0x15
f0101330:	e8 41 18 00 00       	call   f0102b76 <mc146818_read>
f0101335:	89 c3                	mov    %eax,%ebx
f0101337:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010133e:	e8 33 18 00 00       	call   f0102b76 <mc146818_read>
f0101343:	c1 e0 08             	shl    $0x8,%eax
f0101346:	09 d8                	or     %ebx,%eax
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101348:	c1 e0 0a             	shl    $0xa,%eax
f010134b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101351:	85 c0                	test   %eax,%eax
f0101353:	0f 48 c2             	cmovs  %edx,%eax
f0101356:	c1 f8 0c             	sar    $0xc,%eax
f0101359:	a3 40 85 11 f0       	mov    %eax,0xf0118540
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010135e:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101365:	e8 0c 18 00 00       	call   f0102b76 <mc146818_read>
f010136a:	89 c3                	mov    %eax,%ebx
f010136c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101373:	e8 fe 17 00 00       	call   f0102b76 <mc146818_read>
f0101378:	c1 e0 08             	shl    $0x8,%eax
f010137b:	09 d8                	or     %ebx,%eax
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010137d:	c1 e0 0a             	shl    $0xa,%eax
f0101380:	89 c2                	mov    %eax,%edx
f0101382:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f0101388:	83 c4 10             	add    $0x10,%esp
f010138b:	85 d2                	test   %edx,%edx
f010138d:	0f 49 c2             	cmovns %edx,%eax
f0101390:	c1 f8 0c             	sar    $0xc,%eax
	if (npages_extmem)
f0101393:	85 c0                	test   %eax,%eax
f0101395:	0f 85 c4 00 00 00    	jne    f010145f <mem_init+0x13a>
		npages = npages_basemem;
f010139b:	8b 15 40 85 11 f0    	mov    0xf0118540,%edx
f01013a1:	89 15 68 89 11 f0    	mov    %edx,0xf0118968
		npages_extmem * PGSIZE / 1024);
f01013a7:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013aa:	c1 e8 0a             	shr    $0xa,%eax
f01013ad:	50                   	push   %eax
		npages_basemem * PGSIZE / 1024,
f01013ae:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f01013b3:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013b6:	c1 e8 0a             	shr    $0xa,%eax
f01013b9:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01013ba:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01013bf:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013c2:	c1 e8 0a             	shr    $0xa,%eax
f01013c5:	50                   	push   %eax
f01013c6:	68 64 43 10 f0       	push   $0xf0104364
f01013cb:	e8 0d 18 00 00       	call   f0102bdd <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013d0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013d5:	e8 6c f8 ff ff       	call   f0100c46 <boot_alloc>
f01013da:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(kern_pgdir, 0, PGSIZE);
f01013df:	83 c4 0c             	add    $0xc,%esp
f01013e2:	68 00 10 00 00       	push   $0x1000
f01013e7:	6a 00                	push   $0x0
f01013e9:	50                   	push   %eax
f01013ea:	e8 8f 23 00 00       	call   f010377e <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013ef:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013f4:	83 c4 10             	add    $0x10,%esp
f01013f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013fc:	76 72                	jbe    f0101470 <mem_init+0x14b>
	return (physaddr_t)kva - KERNBASE;
f01013fe:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101404:	83 ca 05             	or     $0x5,%edx
f0101407:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*)boot_alloc(npages * sizeof(struct PageInfo));
f010140d:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101412:	c1 e0 03             	shl    $0x3,%eax
f0101415:	e8 2c f8 ff ff       	call   f0100c46 <boot_alloc>
f010141a:	a3 70 89 11 f0       	mov    %eax,0xf0118970
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f010141f:	83 ec 04             	sub    $0x4,%esp
f0101422:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0101428:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010142f:	52                   	push   %edx
f0101430:	6a 00                	push   $0x0
f0101432:	50                   	push   %eax
f0101433:	e8 46 23 00 00       	call   f010377e <memset>
	page_init();
f0101438:	e8 68 fb ff ff       	call   f0100fa5 <page_init>
	check_page_free_list(1);
f010143d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101442:	e8 9f f8 ff ff       	call   f0100ce6 <check_page_free_list>
	if (!pages)
f0101447:	83 c4 10             	add    $0x10,%esp
f010144a:	83 3d 70 89 11 f0 00 	cmpl   $0x0,0xf0118970
f0101451:	74 32                	je     f0101485 <mem_init+0x160>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101453:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101458:	bb 00 00 00 00       	mov    $0x0,%ebx
f010145d:	eb 42                	jmp    f01014a1 <mem_init+0x17c>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010145f:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101465:	89 15 68 89 11 f0    	mov    %edx,0xf0118968
f010146b:	e9 37 ff ff ff       	jmp    f01013a7 <mem_init+0x82>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101470:	50                   	push   %eax
f0101471:	68 a0 43 10 f0       	push   $0xf01043a0
f0101476:	68 8b 00 00 00       	push   $0x8b
f010147b:	68 b0 49 10 f0       	push   $0xf01049b0
f0101480:	e8 06 ec ff ff       	call   f010008b <_panic>
		panic("pages is a null pointer!");
f0101485:	83 ec 04             	sub    $0x4,%esp
f0101488:	68 66 4a 10 f0       	push   $0xf0104a66
f010148d:	68 4f 02 00 00       	push   $0x24f
f0101492:	68 b0 49 10 f0       	push   $0xf01049b0
f0101497:	e8 ef eb ff ff       	call   f010008b <_panic>
		++nfree;
f010149c:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010149f:	8b 00                	mov    (%eax),%eax
f01014a1:	85 c0                	test   %eax,%eax
f01014a3:	75 f7                	jne    f010149c <mem_init+0x177>
	assert((pp0 = page_alloc(0)));
f01014a5:	83 ec 0c             	sub    $0xc,%esp
f01014a8:	6a 00                	push   $0x0
f01014aa:	e8 8f fb ff ff       	call   f010103e <page_alloc>
f01014af:	89 c7                	mov    %eax,%edi
f01014b1:	83 c4 10             	add    $0x10,%esp
f01014b4:	85 c0                	test   %eax,%eax
f01014b6:	0f 84 12 02 00 00    	je     f01016ce <mem_init+0x3a9>
	assert((pp1 = page_alloc(0)));
f01014bc:	83 ec 0c             	sub    $0xc,%esp
f01014bf:	6a 00                	push   $0x0
f01014c1:	e8 78 fb ff ff       	call   f010103e <page_alloc>
f01014c6:	89 c6                	mov    %eax,%esi
f01014c8:	83 c4 10             	add    $0x10,%esp
f01014cb:	85 c0                	test   %eax,%eax
f01014cd:	0f 84 14 02 00 00    	je     f01016e7 <mem_init+0x3c2>
	assert((pp2 = page_alloc(0)));
f01014d3:	83 ec 0c             	sub    $0xc,%esp
f01014d6:	6a 00                	push   $0x0
f01014d8:	e8 61 fb ff ff       	call   f010103e <page_alloc>
f01014dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014e0:	83 c4 10             	add    $0x10,%esp
f01014e3:	85 c0                	test   %eax,%eax
f01014e5:	0f 84 15 02 00 00    	je     f0101700 <mem_init+0x3db>
	assert(pp1 && pp1 != pp0);
f01014eb:	39 f7                	cmp    %esi,%edi
f01014ed:	0f 84 26 02 00 00    	je     f0101719 <mem_init+0x3f4>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014f6:	39 c6                	cmp    %eax,%esi
f01014f8:	0f 84 34 02 00 00    	je     f0101732 <mem_init+0x40d>
f01014fe:	39 c7                	cmp    %eax,%edi
f0101500:	0f 84 2c 02 00 00    	je     f0101732 <mem_init+0x40d>
	return (pp - pages) << PGSHIFT;
f0101506:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010150c:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0101512:	c1 e2 0c             	shl    $0xc,%edx
f0101515:	89 f8                	mov    %edi,%eax
f0101517:	29 c8                	sub    %ecx,%eax
f0101519:	c1 f8 03             	sar    $0x3,%eax
f010151c:	c1 e0 0c             	shl    $0xc,%eax
f010151f:	39 d0                	cmp    %edx,%eax
f0101521:	0f 83 24 02 00 00    	jae    f010174b <mem_init+0x426>
f0101527:	89 f0                	mov    %esi,%eax
f0101529:	29 c8                	sub    %ecx,%eax
f010152b:	c1 f8 03             	sar    $0x3,%eax
f010152e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101531:	39 c2                	cmp    %eax,%edx
f0101533:	0f 86 2b 02 00 00    	jbe    f0101764 <mem_init+0x43f>
f0101539:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010153c:	29 c8                	sub    %ecx,%eax
f010153e:	c1 f8 03             	sar    $0x3,%eax
f0101541:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101544:	39 c2                	cmp    %eax,%edx
f0101546:	0f 86 31 02 00 00    	jbe    f010177d <mem_init+0x458>
	fl = page_free_list;
f010154c:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101551:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101554:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f010155b:	00 00 00 
	assert(!page_alloc(0));
f010155e:	83 ec 0c             	sub    $0xc,%esp
f0101561:	6a 00                	push   $0x0
f0101563:	e8 d6 fa ff ff       	call   f010103e <page_alloc>
f0101568:	83 c4 10             	add    $0x10,%esp
f010156b:	85 c0                	test   %eax,%eax
f010156d:	0f 85 23 02 00 00    	jne    f0101796 <mem_init+0x471>
	page_free(pp0);
f0101573:	83 ec 0c             	sub    $0xc,%esp
f0101576:	57                   	push   %edi
f0101577:	e8 2e fb ff ff       	call   f01010aa <page_free>
	page_free(pp1);
f010157c:	89 34 24             	mov    %esi,(%esp)
f010157f:	e8 26 fb ff ff       	call   f01010aa <page_free>
	page_free(pp2);
f0101584:	83 c4 04             	add    $0x4,%esp
f0101587:	ff 75 d4             	pushl  -0x2c(%ebp)
f010158a:	e8 1b fb ff ff       	call   f01010aa <page_free>
	assert((pp0 = page_alloc(0)));
f010158f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101596:	e8 a3 fa ff ff       	call   f010103e <page_alloc>
f010159b:	89 c6                	mov    %eax,%esi
f010159d:	83 c4 10             	add    $0x10,%esp
f01015a0:	85 c0                	test   %eax,%eax
f01015a2:	0f 84 07 02 00 00    	je     f01017af <mem_init+0x48a>
	assert((pp1 = page_alloc(0)));
f01015a8:	83 ec 0c             	sub    $0xc,%esp
f01015ab:	6a 00                	push   $0x0
f01015ad:	e8 8c fa ff ff       	call   f010103e <page_alloc>
f01015b2:	89 c7                	mov    %eax,%edi
f01015b4:	83 c4 10             	add    $0x10,%esp
f01015b7:	85 c0                	test   %eax,%eax
f01015b9:	0f 84 09 02 00 00    	je     f01017c8 <mem_init+0x4a3>
	assert((pp2 = page_alloc(0)));
f01015bf:	83 ec 0c             	sub    $0xc,%esp
f01015c2:	6a 00                	push   $0x0
f01015c4:	e8 75 fa ff ff       	call   f010103e <page_alloc>
f01015c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015cc:	83 c4 10             	add    $0x10,%esp
f01015cf:	85 c0                	test   %eax,%eax
f01015d1:	0f 84 0a 02 00 00    	je     f01017e1 <mem_init+0x4bc>
	assert(pp1 && pp1 != pp0);
f01015d7:	39 fe                	cmp    %edi,%esi
f01015d9:	0f 84 1b 02 00 00    	je     f01017fa <mem_init+0x4d5>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015e2:	39 c7                	cmp    %eax,%edi
f01015e4:	0f 84 29 02 00 00    	je     f0101813 <mem_init+0x4ee>
f01015ea:	39 c6                	cmp    %eax,%esi
f01015ec:	0f 84 21 02 00 00    	je     f0101813 <mem_init+0x4ee>
	assert(!page_alloc(0));
f01015f2:	83 ec 0c             	sub    $0xc,%esp
f01015f5:	6a 00                	push   $0x0
f01015f7:	e8 42 fa ff ff       	call   f010103e <page_alloc>
f01015fc:	83 c4 10             	add    $0x10,%esp
f01015ff:	85 c0                	test   %eax,%eax
f0101601:	0f 85 25 02 00 00    	jne    f010182c <mem_init+0x507>
f0101607:	89 f0                	mov    %esi,%eax
f0101609:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010160f:	c1 f8 03             	sar    $0x3,%eax
f0101612:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101615:	89 c2                	mov    %eax,%edx
f0101617:	c1 ea 0c             	shr    $0xc,%edx
f010161a:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0101620:	0f 83 1f 02 00 00    	jae    f0101845 <mem_init+0x520>
	memset(page2kva(pp0), 1, PGSIZE);
f0101626:	83 ec 04             	sub    $0x4,%esp
f0101629:	68 00 10 00 00       	push   $0x1000
f010162e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101630:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101635:	50                   	push   %eax
f0101636:	e8 43 21 00 00       	call   f010377e <memset>
	page_free(pp0);
f010163b:	89 34 24             	mov    %esi,(%esp)
f010163e:	e8 67 fa ff ff       	call   f01010aa <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101643:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010164a:	e8 ef f9 ff ff       	call   f010103e <page_alloc>
f010164f:	83 c4 10             	add    $0x10,%esp
f0101652:	85 c0                	test   %eax,%eax
f0101654:	0f 84 fd 01 00 00    	je     f0101857 <mem_init+0x532>
	assert(pp && pp0 == pp);
f010165a:	39 c6                	cmp    %eax,%esi
f010165c:	0f 85 0e 02 00 00    	jne    f0101870 <mem_init+0x54b>
	return (pp - pages) << PGSHIFT;
f0101662:	89 f2                	mov    %esi,%edx
f0101664:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f010166a:	c1 fa 03             	sar    $0x3,%edx
f010166d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101670:	89 d0                	mov    %edx,%eax
f0101672:	c1 e8 0c             	shr    $0xc,%eax
f0101675:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f010167b:	0f 83 08 02 00 00    	jae    f0101889 <mem_init+0x564>
	return (void *)(pa + KERNBASE);
f0101681:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101687:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010168d:	80 38 00             	cmpb   $0x0,(%eax)
f0101690:	0f 85 05 02 00 00    	jne    f010189b <mem_init+0x576>
f0101696:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101699:	39 d0                	cmp    %edx,%eax
f010169b:	75 f0                	jne    f010168d <mem_init+0x368>
	page_free_list = fl;
f010169d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016a0:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	page_free(pp0);
f01016a5:	83 ec 0c             	sub    $0xc,%esp
f01016a8:	56                   	push   %esi
f01016a9:	e8 fc f9 ff ff       	call   f01010aa <page_free>
	page_free(pp1);
f01016ae:	89 3c 24             	mov    %edi,(%esp)
f01016b1:	e8 f4 f9 ff ff       	call   f01010aa <page_free>
	page_free(pp2);
f01016b6:	83 c4 04             	add    $0x4,%esp
f01016b9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016bc:	e8 e9 f9 ff ff       	call   f01010aa <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016c1:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01016c6:	83 c4 10             	add    $0x10,%esp
f01016c9:	e9 eb 01 00 00       	jmp    f01018b9 <mem_init+0x594>
	assert((pp0 = page_alloc(0)));
f01016ce:	68 7f 4a 10 f0       	push   $0xf0104a7f
f01016d3:	68 d6 49 10 f0       	push   $0xf01049d6
f01016d8:	68 57 02 00 00       	push   $0x257
f01016dd:	68 b0 49 10 f0       	push   $0xf01049b0
f01016e2:	e8 a4 e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01016e7:	68 95 4a 10 f0       	push   $0xf0104a95
f01016ec:	68 d6 49 10 f0       	push   $0xf01049d6
f01016f1:	68 58 02 00 00       	push   $0x258
f01016f6:	68 b0 49 10 f0       	push   $0xf01049b0
f01016fb:	e8 8b e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101700:	68 ab 4a 10 f0       	push   $0xf0104aab
f0101705:	68 d6 49 10 f0       	push   $0xf01049d6
f010170a:	68 59 02 00 00       	push   $0x259
f010170f:	68 b0 49 10 f0       	push   $0xf01049b0
f0101714:	e8 72 e9 ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f0101719:	68 c1 4a 10 f0       	push   $0xf0104ac1
f010171e:	68 d6 49 10 f0       	push   $0xf01049d6
f0101723:	68 5c 02 00 00       	push   $0x25c
f0101728:	68 b0 49 10 f0       	push   $0xf01049b0
f010172d:	e8 59 e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101732:	68 c4 43 10 f0       	push   $0xf01043c4
f0101737:	68 d6 49 10 f0       	push   $0xf01049d6
f010173c:	68 5d 02 00 00       	push   $0x25d
f0101741:	68 b0 49 10 f0       	push   $0xf01049b0
f0101746:	e8 40 e9 ff ff       	call   f010008b <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010174b:	68 d3 4a 10 f0       	push   $0xf0104ad3
f0101750:	68 d6 49 10 f0       	push   $0xf01049d6
f0101755:	68 5e 02 00 00       	push   $0x25e
f010175a:	68 b0 49 10 f0       	push   $0xf01049b0
f010175f:	e8 27 e9 ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101764:	68 f0 4a 10 f0       	push   $0xf0104af0
f0101769:	68 d6 49 10 f0       	push   $0xf01049d6
f010176e:	68 5f 02 00 00       	push   $0x25f
f0101773:	68 b0 49 10 f0       	push   $0xf01049b0
f0101778:	e8 0e e9 ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010177d:	68 0d 4b 10 f0       	push   $0xf0104b0d
f0101782:	68 d6 49 10 f0       	push   $0xf01049d6
f0101787:	68 60 02 00 00       	push   $0x260
f010178c:	68 b0 49 10 f0       	push   $0xf01049b0
f0101791:	e8 f5 e8 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101796:	68 2a 4b 10 f0       	push   $0xf0104b2a
f010179b:	68 d6 49 10 f0       	push   $0xf01049d6
f01017a0:	68 67 02 00 00       	push   $0x267
f01017a5:	68 b0 49 10 f0       	push   $0xf01049b0
f01017aa:	e8 dc e8 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f01017af:	68 7f 4a 10 f0       	push   $0xf0104a7f
f01017b4:	68 d6 49 10 f0       	push   $0xf01049d6
f01017b9:	68 6e 02 00 00       	push   $0x26e
f01017be:	68 b0 49 10 f0       	push   $0xf01049b0
f01017c3:	e8 c3 e8 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01017c8:	68 95 4a 10 f0       	push   $0xf0104a95
f01017cd:	68 d6 49 10 f0       	push   $0xf01049d6
f01017d2:	68 6f 02 00 00       	push   $0x26f
f01017d7:	68 b0 49 10 f0       	push   $0xf01049b0
f01017dc:	e8 aa e8 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01017e1:	68 ab 4a 10 f0       	push   $0xf0104aab
f01017e6:	68 d6 49 10 f0       	push   $0xf01049d6
f01017eb:	68 70 02 00 00       	push   $0x270
f01017f0:	68 b0 49 10 f0       	push   $0xf01049b0
f01017f5:	e8 91 e8 ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f01017fa:	68 c1 4a 10 f0       	push   $0xf0104ac1
f01017ff:	68 d6 49 10 f0       	push   $0xf01049d6
f0101804:	68 72 02 00 00       	push   $0x272
f0101809:	68 b0 49 10 f0       	push   $0xf01049b0
f010180e:	e8 78 e8 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101813:	68 c4 43 10 f0       	push   $0xf01043c4
f0101818:	68 d6 49 10 f0       	push   $0xf01049d6
f010181d:	68 73 02 00 00       	push   $0x273
f0101822:	68 b0 49 10 f0       	push   $0xf01049b0
f0101827:	e8 5f e8 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010182c:	68 2a 4b 10 f0       	push   $0xf0104b2a
f0101831:	68 d6 49 10 f0       	push   $0xf01049d6
f0101836:	68 74 02 00 00       	push   $0x274
f010183b:	68 b0 49 10 f0       	push   $0xf01049b0
f0101840:	e8 46 e8 ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101845:	50                   	push   %eax
f0101846:	68 5c 42 10 f0       	push   $0xf010425c
f010184b:	6a 52                	push   $0x52
f010184d:	68 bc 49 10 f0       	push   $0xf01049bc
f0101852:	e8 34 e8 ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101857:	68 39 4b 10 f0       	push   $0xf0104b39
f010185c:	68 d6 49 10 f0       	push   $0xf01049d6
f0101861:	68 79 02 00 00       	push   $0x279
f0101866:	68 b0 49 10 f0       	push   $0xf01049b0
f010186b:	e8 1b e8 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101870:	68 57 4b 10 f0       	push   $0xf0104b57
f0101875:	68 d6 49 10 f0       	push   $0xf01049d6
f010187a:	68 7a 02 00 00       	push   $0x27a
f010187f:	68 b0 49 10 f0       	push   $0xf01049b0
f0101884:	e8 02 e8 ff ff       	call   f010008b <_panic>
f0101889:	52                   	push   %edx
f010188a:	68 5c 42 10 f0       	push   $0xf010425c
f010188f:	6a 52                	push   $0x52
f0101891:	68 bc 49 10 f0       	push   $0xf01049bc
f0101896:	e8 f0 e7 ff ff       	call   f010008b <_panic>
		assert(c[i] == 0);
f010189b:	68 67 4b 10 f0       	push   $0xf0104b67
f01018a0:	68 d6 49 10 f0       	push   $0xf01049d6
f01018a5:	68 7d 02 00 00       	push   $0x27d
f01018aa:	68 b0 49 10 f0       	push   $0xf01049b0
f01018af:	e8 d7 e7 ff ff       	call   f010008b <_panic>
		--nfree;
f01018b4:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018b7:	8b 00                	mov    (%eax),%eax
f01018b9:	85 c0                	test   %eax,%eax
f01018bb:	75 f7                	jne    f01018b4 <mem_init+0x58f>
	assert(nfree == 0);
f01018bd:	85 db                	test   %ebx,%ebx
f01018bf:	0f 85 91 07 00 00    	jne    f0102056 <mem_init+0xd31>
	cprintf("check_page_alloc() succeeded!\n");
f01018c5:	83 ec 0c             	sub    $0xc,%esp
f01018c8:	68 e4 43 10 f0       	push   $0xf01043e4
f01018cd:	e8 0b 13 00 00       	call   f0102bdd <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d9:	e8 60 f7 ff ff       	call   f010103e <page_alloc>
f01018de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018e1:	83 c4 10             	add    $0x10,%esp
f01018e4:	85 c0                	test   %eax,%eax
f01018e6:	0f 84 83 07 00 00    	je     f010206f <mem_init+0xd4a>
	assert((pp1 = page_alloc(0)));
f01018ec:	83 ec 0c             	sub    $0xc,%esp
f01018ef:	6a 00                	push   $0x0
f01018f1:	e8 48 f7 ff ff       	call   f010103e <page_alloc>
f01018f6:	89 c3                	mov    %eax,%ebx
f01018f8:	83 c4 10             	add    $0x10,%esp
f01018fb:	85 c0                	test   %eax,%eax
f01018fd:	0f 84 85 07 00 00    	je     f0102088 <mem_init+0xd63>
	assert((pp2 = page_alloc(0)));
f0101903:	83 ec 0c             	sub    $0xc,%esp
f0101906:	6a 00                	push   $0x0
f0101908:	e8 31 f7 ff ff       	call   f010103e <page_alloc>
f010190d:	89 c6                	mov    %eax,%esi
f010190f:	83 c4 10             	add    $0x10,%esp
f0101912:	85 c0                	test   %eax,%eax
f0101914:	0f 84 87 07 00 00    	je     f01020a1 <mem_init+0xd7c>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010191a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010191d:	0f 84 97 07 00 00    	je     f01020ba <mem_init+0xd95>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101923:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101926:	0f 84 a7 07 00 00    	je     f01020d3 <mem_init+0xdae>
f010192c:	39 c3                	cmp    %eax,%ebx
f010192e:	0f 84 9f 07 00 00    	je     f01020d3 <mem_init+0xdae>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101934:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101939:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010193c:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f0101943:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101946:	83 ec 0c             	sub    $0xc,%esp
f0101949:	6a 00                	push   $0x0
f010194b:	e8 ee f6 ff ff       	call   f010103e <page_alloc>
f0101950:	83 c4 10             	add    $0x10,%esp
f0101953:	85 c0                	test   %eax,%eax
f0101955:	0f 85 91 07 00 00    	jne    f01020ec <mem_init+0xdc7>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010195b:	83 ec 04             	sub    $0x4,%esp
f010195e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101961:	50                   	push   %eax
f0101962:	6a 00                	push   $0x0
f0101964:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010196a:	e8 7d f8 ff ff       	call   f01011ec <page_lookup>
f010196f:	83 c4 10             	add    $0x10,%esp
f0101972:	85 c0                	test   %eax,%eax
f0101974:	0f 85 8b 07 00 00    	jne    f0102105 <mem_init+0xde0>

	// there is no free memory, so we cant allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010197a:	6a 02                	push   $0x2
f010197c:	6a 00                	push   $0x0
f010197e:	53                   	push   %ebx
f010197f:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101985:	e8 05 f9 ff ff       	call   f010128f <page_insert>
f010198a:	83 c4 10             	add    $0x10,%esp
f010198d:	85 c0                	test   %eax,%eax
f010198f:	0f 89 89 07 00 00    	jns    f010211e <mem_init+0xdf9>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101995:	83 ec 0c             	sub    $0xc,%esp
f0101998:	ff 75 d4             	pushl  -0x2c(%ebp)
f010199b:	e8 0a f7 ff ff       	call   f01010aa <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019a0:	6a 02                	push   $0x2
f01019a2:	6a 00                	push   $0x0
f01019a4:	53                   	push   %ebx
f01019a5:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01019ab:	e8 df f8 ff ff       	call   f010128f <page_insert>
f01019b0:	83 c4 20             	add    $0x20,%esp
f01019b3:	85 c0                	test   %eax,%eax
f01019b5:	0f 85 7c 07 00 00    	jne    f0102137 <mem_init+0xe12>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019bb:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
	return (pp - pages) << PGSHIFT;
f01019c1:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
f01019c7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01019ca:	8b 17                	mov    (%edi),%edx
f01019cc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d5:	29 c8                	sub    %ecx,%eax
f01019d7:	c1 f8 03             	sar    $0x3,%eax
f01019da:	c1 e0 0c             	shl    $0xc,%eax
f01019dd:	39 c2                	cmp    %eax,%edx
f01019df:	0f 85 6b 07 00 00    	jne    f0102150 <mem_init+0xe2b>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01019ea:	89 f8                	mov    %edi,%eax
f01019ec:	e8 91 f2 ff ff       	call   f0100c82 <check_va2pa>
f01019f1:	89 da                	mov    %ebx,%edx
f01019f3:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019f6:	c1 fa 03             	sar    $0x3,%edx
f01019f9:	c1 e2 0c             	shl    $0xc,%edx
f01019fc:	39 d0                	cmp    %edx,%eax
f01019fe:	0f 85 65 07 00 00    	jne    f0102169 <mem_init+0xe44>
	assert(pp1->pp_ref == 1);
f0101a04:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a09:	0f 85 73 07 00 00    	jne    f0102182 <mem_init+0xe5d>
	assert(pp0->pp_ref == 1);
f0101a0f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a12:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a17:	0f 85 7e 07 00 00    	jne    f010219b <mem_init+0xe76>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a1d:	6a 02                	push   $0x2
f0101a1f:	68 00 10 00 00       	push   $0x1000
f0101a24:	56                   	push   %esi
f0101a25:	57                   	push   %edi
f0101a26:	e8 64 f8 ff ff       	call   f010128f <page_insert>
f0101a2b:	83 c4 10             	add    $0x10,%esp
f0101a2e:	85 c0                	test   %eax,%eax
f0101a30:	0f 85 7e 07 00 00    	jne    f01021b4 <mem_init+0xe8f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a36:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a3b:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101a40:	e8 3d f2 ff ff       	call   f0100c82 <check_va2pa>
f0101a45:	89 f2                	mov    %esi,%edx
f0101a47:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101a4d:	c1 fa 03             	sar    $0x3,%edx
f0101a50:	c1 e2 0c             	shl    $0xc,%edx
f0101a53:	39 d0                	cmp    %edx,%eax
f0101a55:	0f 85 72 07 00 00    	jne    f01021cd <mem_init+0xea8>
	assert(pp2->pp_ref == 1);
f0101a5b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a60:	0f 85 80 07 00 00    	jne    f01021e6 <mem_init+0xec1>

	// should be no free memory
	assert(!page_alloc(0));
f0101a66:	83 ec 0c             	sub    $0xc,%esp
f0101a69:	6a 00                	push   $0x0
f0101a6b:	e8 ce f5 ff ff       	call   f010103e <page_alloc>
f0101a70:	83 c4 10             	add    $0x10,%esp
f0101a73:	85 c0                	test   %eax,%eax
f0101a75:	0f 85 84 07 00 00    	jne    f01021ff <mem_init+0xeda>

	// should be able to map pp2 at PGSIZE because its already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a7b:	6a 02                	push   $0x2
f0101a7d:	68 00 10 00 00       	push   $0x1000
f0101a82:	56                   	push   %esi
f0101a83:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a89:	e8 01 f8 ff ff       	call   f010128f <page_insert>
f0101a8e:	83 c4 10             	add    $0x10,%esp
f0101a91:	85 c0                	test   %eax,%eax
f0101a93:	0f 85 7f 07 00 00    	jne    f0102218 <mem_init+0xef3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a99:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a9e:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101aa3:	e8 da f1 ff ff       	call   f0100c82 <check_va2pa>
f0101aa8:	89 f2                	mov    %esi,%edx
f0101aaa:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101ab0:	c1 fa 03             	sar    $0x3,%edx
f0101ab3:	c1 e2 0c             	shl    $0xc,%edx
f0101ab6:	39 d0                	cmp    %edx,%eax
f0101ab8:	0f 85 73 07 00 00    	jne    f0102231 <mem_init+0xf0c>
	assert(pp2->pp_ref == 1);
f0101abe:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ac3:	0f 85 81 07 00 00    	jne    f010224a <mem_init+0xf25>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ac9:	83 ec 0c             	sub    $0xc,%esp
f0101acc:	6a 00                	push   $0x0
f0101ace:	e8 6b f5 ff ff       	call   f010103e <page_alloc>
f0101ad3:	83 c4 10             	add    $0x10,%esp
f0101ad6:	85 c0                	test   %eax,%eax
f0101ad8:	0f 85 85 07 00 00    	jne    f0102263 <mem_init+0xf3e>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ade:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
f0101ae4:	8b 02                	mov    (%edx),%eax
f0101ae6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101aeb:	89 c1                	mov    %eax,%ecx
f0101aed:	c1 e9 0c             	shr    $0xc,%ecx
f0101af0:	3b 0d 68 89 11 f0    	cmp    0xf0118968,%ecx
f0101af6:	0f 83 80 07 00 00    	jae    f010227c <mem_init+0xf57>
	return (void *)(pa + KERNBASE);
f0101afc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b04:	83 ec 04             	sub    $0x4,%esp
f0101b07:	6a 00                	push   $0x0
f0101b09:	68 00 10 00 00       	push   $0x1000
f0101b0e:	52                   	push   %edx
f0101b0f:	e8 ce f5 ff ff       	call   f01010e2 <pgdir_walk>
f0101b14:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b17:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b1a:	83 c4 10             	add    $0x10,%esp
f0101b1d:	39 d0                	cmp    %edx,%eax
f0101b1f:	0f 85 6c 07 00 00    	jne    f0102291 <mem_init+0xf6c>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b25:	6a 06                	push   $0x6
f0101b27:	68 00 10 00 00       	push   $0x1000
f0101b2c:	56                   	push   %esi
f0101b2d:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101b33:	e8 57 f7 ff ff       	call   f010128f <page_insert>
f0101b38:	83 c4 10             	add    $0x10,%esp
f0101b3b:	85 c0                	test   %eax,%eax
f0101b3d:	0f 85 67 07 00 00    	jne    f01022aa <mem_init+0xf85>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b43:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101b49:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b4e:	89 f8                	mov    %edi,%eax
f0101b50:	e8 2d f1 ff ff       	call   f0100c82 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b55:	89 f2                	mov    %esi,%edx
f0101b57:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101b5d:	c1 fa 03             	sar    $0x3,%edx
f0101b60:	c1 e2 0c             	shl    $0xc,%edx
f0101b63:	39 d0                	cmp    %edx,%eax
f0101b65:	0f 85 58 07 00 00    	jne    f01022c3 <mem_init+0xf9e>
	assert(pp2->pp_ref == 1);
f0101b6b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b70:	0f 85 66 07 00 00    	jne    f01022dc <mem_init+0xfb7>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b76:	83 ec 04             	sub    $0x4,%esp
f0101b79:	6a 00                	push   $0x0
f0101b7b:	68 00 10 00 00       	push   $0x1000
f0101b80:	57                   	push   %edi
f0101b81:	e8 5c f5 ff ff       	call   f01010e2 <pgdir_walk>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	f6 00 04             	testb  $0x4,(%eax)
f0101b8c:	0f 84 63 07 00 00    	je     f01022f5 <mem_init+0xfd0>
	assert(kern_pgdir[0] & PTE_U);
f0101b92:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101b97:	f6 00 04             	testb  $0x4,(%eax)
f0101b9a:	0f 84 6e 07 00 00    	je     f010230e <mem_init+0xfe9>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ba0:	6a 02                	push   $0x2
f0101ba2:	68 00 10 00 00       	push   $0x1000
f0101ba7:	56                   	push   %esi
f0101ba8:	50                   	push   %eax
f0101ba9:	e8 e1 f6 ff ff       	call   f010128f <page_insert>
f0101bae:	83 c4 10             	add    $0x10,%esp
f0101bb1:	85 c0                	test   %eax,%eax
f0101bb3:	0f 85 6e 07 00 00    	jne    f0102327 <mem_init+0x1002>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bb9:	83 ec 04             	sub    $0x4,%esp
f0101bbc:	6a 00                	push   $0x0
f0101bbe:	68 00 10 00 00       	push   $0x1000
f0101bc3:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101bc9:	e8 14 f5 ff ff       	call   f01010e2 <pgdir_walk>
f0101bce:	83 c4 10             	add    $0x10,%esp
f0101bd1:	f6 00 02             	testb  $0x2,(%eax)
f0101bd4:	0f 84 66 07 00 00    	je     f0102340 <mem_init+0x101b>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bda:	83 ec 04             	sub    $0x4,%esp
f0101bdd:	6a 00                	push   $0x0
f0101bdf:	68 00 10 00 00       	push   $0x1000
f0101be4:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101bea:	e8 f3 f4 ff ff       	call   f01010e2 <pgdir_walk>
f0101bef:	83 c4 10             	add    $0x10,%esp
f0101bf2:	f6 00 04             	testb  $0x4,(%eax)
f0101bf5:	0f 85 5e 07 00 00    	jne    f0102359 <mem_init+0x1034>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bfb:	6a 02                	push   $0x2
f0101bfd:	68 00 00 40 00       	push   $0x400000
f0101c02:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c05:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101c0b:	e8 7f f6 ff ff       	call   f010128f <page_insert>
f0101c10:	83 c4 10             	add    $0x10,%esp
f0101c13:	85 c0                	test   %eax,%eax
f0101c15:	0f 89 57 07 00 00    	jns    f0102372 <mem_init+0x104d>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c1b:	6a 02                	push   $0x2
f0101c1d:	68 00 10 00 00       	push   $0x1000
f0101c22:	53                   	push   %ebx
f0101c23:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101c29:	e8 61 f6 ff ff       	call   f010128f <page_insert>
f0101c2e:	83 c4 10             	add    $0x10,%esp
f0101c31:	85 c0                	test   %eax,%eax
f0101c33:	0f 85 52 07 00 00    	jne    f010238b <mem_init+0x1066>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c39:	83 ec 04             	sub    $0x4,%esp
f0101c3c:	6a 00                	push   $0x0
f0101c3e:	68 00 10 00 00       	push   $0x1000
f0101c43:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101c49:	e8 94 f4 ff ff       	call   f01010e2 <pgdir_walk>
f0101c4e:	83 c4 10             	add    $0x10,%esp
f0101c51:	f6 00 04             	testb  $0x4,(%eax)
f0101c54:	0f 85 4a 07 00 00    	jne    f01023a4 <mem_init+0x107f>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c5a:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101c60:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c65:	89 f8                	mov    %edi,%eax
f0101c67:	e8 16 f0 ff ff       	call   f0100c82 <check_va2pa>
f0101c6c:	89 c1                	mov    %eax,%ecx
f0101c6e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c71:	89 d8                	mov    %ebx,%eax
f0101c73:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101c79:	c1 f8 03             	sar    $0x3,%eax
f0101c7c:	c1 e0 0c             	shl    $0xc,%eax
f0101c7f:	39 c1                	cmp    %eax,%ecx
f0101c81:	0f 85 36 07 00 00    	jne    f01023bd <mem_init+0x1098>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c87:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c8c:	89 f8                	mov    %edi,%eax
f0101c8e:	e8 ef ef ff ff       	call   f0100c82 <check_va2pa>
f0101c93:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101c96:	0f 85 3a 07 00 00    	jne    f01023d6 <mem_init+0x10b1>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c9c:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ca1:	0f 85 48 07 00 00    	jne    f01023ef <mem_init+0x10ca>
	assert(pp2->pp_ref == 0);
f0101ca7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cac:	0f 85 56 07 00 00    	jne    f0102408 <mem_init+0x10e3>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cb2:	83 ec 0c             	sub    $0xc,%esp
f0101cb5:	6a 00                	push   $0x0
f0101cb7:	e8 82 f3 ff ff       	call   f010103e <page_alloc>
f0101cbc:	83 c4 10             	add    $0x10,%esp
f0101cbf:	39 c6                	cmp    %eax,%esi
f0101cc1:	0f 85 5a 07 00 00    	jne    f0102421 <mem_init+0x10fc>
f0101cc7:	85 c0                	test   %eax,%eax
f0101cc9:	0f 84 52 07 00 00    	je     f0102421 <mem_init+0x10fc>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ccf:	83 ec 08             	sub    $0x8,%esp
f0101cd2:	6a 00                	push   $0x0
f0101cd4:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101cda:	e8 73 f5 ff ff       	call   f0101252 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cdf:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101ce5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cea:	89 f8                	mov    %edi,%eax
f0101cec:	e8 91 ef ff ff       	call   f0100c82 <check_va2pa>
f0101cf1:	83 c4 10             	add    $0x10,%esp
f0101cf4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cf7:	0f 85 3d 07 00 00    	jne    f010243a <mem_init+0x1115>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cfd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d02:	89 f8                	mov    %edi,%eax
f0101d04:	e8 79 ef ff ff       	call   f0100c82 <check_va2pa>
f0101d09:	89 da                	mov    %ebx,%edx
f0101d0b:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101d11:	c1 fa 03             	sar    $0x3,%edx
f0101d14:	c1 e2 0c             	shl    $0xc,%edx
f0101d17:	39 d0                	cmp    %edx,%eax
f0101d19:	0f 85 34 07 00 00    	jne    f0102453 <mem_init+0x112e>
	assert(pp1->pp_ref == 1);
f0101d1f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d24:	0f 85 42 07 00 00    	jne    f010246c <mem_init+0x1147>
	assert(pp2->pp_ref == 0);
f0101d2a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d2f:	0f 85 50 07 00 00    	jne    f0102485 <mem_init+0x1160>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d35:	6a 00                	push   $0x0
f0101d37:	68 00 10 00 00       	push   $0x1000
f0101d3c:	53                   	push   %ebx
f0101d3d:	57                   	push   %edi
f0101d3e:	e8 4c f5 ff ff       	call   f010128f <page_insert>
f0101d43:	83 c4 10             	add    $0x10,%esp
f0101d46:	85 c0                	test   %eax,%eax
f0101d48:	0f 85 50 07 00 00    	jne    f010249e <mem_init+0x1179>
	assert(pp1->pp_ref);
f0101d4e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d53:	0f 84 5e 07 00 00    	je     f01024b7 <mem_init+0x1192>
	assert(pp1->pp_link == NULL);
f0101d59:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d5c:	0f 85 6e 07 00 00    	jne    f01024d0 <mem_init+0x11ab>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d62:	83 ec 08             	sub    $0x8,%esp
f0101d65:	68 00 10 00 00       	push   $0x1000
f0101d6a:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101d70:	e8 dd f4 ff ff       	call   f0101252 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d75:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101d7b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d80:	89 f8                	mov    %edi,%eax
f0101d82:	e8 fb ee ff ff       	call   f0100c82 <check_va2pa>
f0101d87:	83 c4 10             	add    $0x10,%esp
f0101d8a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d8d:	0f 85 56 07 00 00    	jne    f01024e9 <mem_init+0x11c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d98:	89 f8                	mov    %edi,%eax
f0101d9a:	e8 e3 ee ff ff       	call   f0100c82 <check_va2pa>
f0101d9f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101da2:	0f 85 5a 07 00 00    	jne    f0102502 <mem_init+0x11dd>
	assert(pp1->pp_ref == 0);
f0101da8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dad:	0f 85 68 07 00 00    	jne    f010251b <mem_init+0x11f6>
	assert(pp2->pp_ref == 0);
f0101db3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101db8:	0f 85 76 07 00 00    	jne    f0102534 <mem_init+0x120f>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101dbe:	83 ec 0c             	sub    $0xc,%esp
f0101dc1:	6a 00                	push   $0x0
f0101dc3:	e8 76 f2 ff ff       	call   f010103e <page_alloc>
f0101dc8:	83 c4 10             	add    $0x10,%esp
f0101dcb:	85 c0                	test   %eax,%eax
f0101dcd:	0f 84 7a 07 00 00    	je     f010254d <mem_init+0x1228>
f0101dd3:	39 c3                	cmp    %eax,%ebx
f0101dd5:	0f 85 72 07 00 00    	jne    f010254d <mem_init+0x1228>

	// should be no free memory
	assert(!page_alloc(0));
f0101ddb:	83 ec 0c             	sub    $0xc,%esp
f0101dde:	6a 00                	push   $0x0
f0101de0:	e8 59 f2 ff ff       	call   f010103e <page_alloc>
f0101de5:	83 c4 10             	add    $0x10,%esp
f0101de8:	85 c0                	test   %eax,%eax
f0101dea:	0f 85 76 07 00 00    	jne    f0102566 <mem_init+0x1241>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101df0:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101df6:	8b 11                	mov    (%ecx),%edx
f0101df8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dfe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e01:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101e07:	c1 f8 03             	sar    $0x3,%eax
f0101e0a:	c1 e0 0c             	shl    $0xc,%eax
f0101e0d:	39 c2                	cmp    %eax,%edx
f0101e0f:	0f 85 6a 07 00 00    	jne    f010257f <mem_init+0x125a>
	kern_pgdir[0] = 0;
f0101e15:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e23:	0f 85 6f 07 00 00    	jne    f0102598 <mem_init+0x1273>
	pp0->pp_ref = 0;
f0101e29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e2c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e32:	83 ec 0c             	sub    $0xc,%esp
f0101e35:	50                   	push   %eax
f0101e36:	e8 6f f2 ff ff       	call   f01010aa <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e3b:	83 c4 0c             	add    $0xc,%esp
f0101e3e:	6a 01                	push   $0x1
f0101e40:	68 00 10 40 00       	push   $0x401000
f0101e45:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101e4b:	e8 92 f2 ff ff       	call   f01010e2 <pgdir_walk>
f0101e50:	89 c7                	mov    %eax,%edi
f0101e52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e55:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101e5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e5d:	8b 40 04             	mov    0x4(%eax),%eax
f0101e60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e65:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0101e6b:	89 c2                	mov    %eax,%edx
f0101e6d:	c1 ea 0c             	shr    $0xc,%edx
f0101e70:	83 c4 10             	add    $0x10,%esp
f0101e73:	39 ca                	cmp    %ecx,%edx
f0101e75:	0f 83 36 07 00 00    	jae    f01025b1 <mem_init+0x128c>
	assert(ptep == ptep1 + PTX(va));
f0101e7b:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e80:	39 c7                	cmp    %eax,%edi
f0101e82:	0f 85 3e 07 00 00    	jne    f01025c6 <mem_init+0x12a1>
	kern_pgdir[PDX(va)] = 0;
f0101e88:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e8b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e95:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e9b:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101ea1:	c1 f8 03             	sar    $0x3,%eax
f0101ea4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ea7:	89 c2                	mov    %eax,%edx
f0101ea9:	c1 ea 0c             	shr    $0xc,%edx
f0101eac:	39 d1                	cmp    %edx,%ecx
f0101eae:	0f 86 2b 07 00 00    	jbe    f01025df <mem_init+0x12ba>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101eb4:	83 ec 04             	sub    $0x4,%esp
f0101eb7:	68 00 10 00 00       	push   $0x1000
f0101ebc:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101ec1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ec6:	50                   	push   %eax
f0101ec7:	e8 b2 18 00 00       	call   f010377e <memset>
	page_free(pp0);
f0101ecc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101ecf:	89 3c 24             	mov    %edi,(%esp)
f0101ed2:	e8 d3 f1 ff ff       	call   f01010aa <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ed7:	83 c4 0c             	add    $0xc,%esp
f0101eda:	6a 01                	push   $0x1
f0101edc:	6a 00                	push   $0x0
f0101ede:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101ee4:	e8 f9 f1 ff ff       	call   f01010e2 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101ee9:	89 fa                	mov    %edi,%edx
f0101eeb:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101ef1:	c1 fa 03             	sar    $0x3,%edx
f0101ef4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ef7:	89 d0                	mov    %edx,%eax
f0101ef9:	c1 e8 0c             	shr    $0xc,%eax
f0101efc:	83 c4 10             	add    $0x10,%esp
f0101eff:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101f05:	0f 83 e6 06 00 00    	jae    f01025f1 <mem_init+0x12cc>
	return (void *)(pa + KERNBASE);
f0101f0b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101f11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101f14:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f1a:	f6 00 01             	testb  $0x1,(%eax)
f0101f1d:	0f 85 e0 06 00 00    	jne    f0102603 <mem_init+0x12de>
f0101f23:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101f26:	39 c2                	cmp    %eax,%edx
f0101f28:	75 f0                	jne    f0101f1a <mem_init+0xbf5>
	kern_pgdir[0] = 0;
f0101f2a:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101f2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f38:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f3e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f41:	89 0d 3c 85 11 f0    	mov    %ecx,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101f47:	83 ec 0c             	sub    $0xc,%esp
f0101f4a:	50                   	push   %eax
f0101f4b:	e8 5a f1 ff ff       	call   f01010aa <page_free>
	page_free(pp1);
f0101f50:	89 1c 24             	mov    %ebx,(%esp)
f0101f53:	e8 52 f1 ff ff       	call   f01010aa <page_free>
	page_free(pp2);
f0101f58:	89 34 24             	mov    %esi,(%esp)
f0101f5b:	e8 4a f1 ff ff       	call   f01010aa <page_free>

	cprintf("check_page() succeeded!\n");
f0101f60:	c7 04 24 48 4c 10 f0 	movl   $0xf0104c48,(%esp)
f0101f67:	e8 71 0c 00 00       	call   f0102bdd <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0101f6c:	a1 70 89 11 f0       	mov    0xf0118970,%eax
	if ((uint32_t)kva < KERNBASE)
f0101f71:	83 c4 10             	add    $0x10,%esp
f0101f74:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101f79:	0f 86 9d 06 00 00    	jbe    f010261c <mem_init+0x12f7>
f0101f7f:	83 ec 08             	sub    $0x8,%esp
f0101f82:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0101f84:	05 00 00 00 10       	add    $0x10000000,%eax
f0101f89:	50                   	push   %eax
f0101f8a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101f8f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101f94:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101f99:	e8 d7 f1 ff ff       	call   f0101175 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101f9e:	83 c4 10             	add    $0x10,%esp
f0101fa1:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0101fa6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101fab:	0f 86 80 06 00 00    	jbe    f0102631 <mem_init+0x130c>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0101fb1:	83 ec 08             	sub    $0x8,%esp
f0101fb4:	6a 02                	push   $0x2
f0101fb6:	68 00 e0 10 00       	push   $0x10e000
f0101fbb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101fc0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101fc5:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101fca:	e8 a6 f1 ff ff       	call   f0101175 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0101fcf:	83 c4 08             	add    $0x8,%esp
f0101fd2:	6a 02                	push   $0x2
f0101fd4:	6a 00                	push   $0x0
f0101fd6:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101fdb:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101fe0:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101fe5:	e8 8b f1 ff ff       	call   f0101175 <boot_map_region>
	pgdir = kern_pgdir;
f0101fea:	8b 1d 6c 89 11 f0    	mov    0xf011896c,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101ff0:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101ff5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ff8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101fff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102004:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102007:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f010200c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010200f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102012:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102018:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010201b:	be 00 00 00 00       	mov    $0x0,%esi
f0102020:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102023:	0f 86 4d 06 00 00    	jbe    f0102676 <mem_init+0x1351>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102029:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f010202f:	89 d8                	mov    %ebx,%eax
f0102031:	e8 4c ec ff ff       	call   f0100c82 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102036:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010203d:	0f 86 03 06 00 00    	jbe    f0102646 <mem_init+0x1321>
f0102043:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0102046:	39 c2                	cmp    %eax,%edx
f0102048:	0f 85 0f 06 00 00    	jne    f010265d <mem_init+0x1338>
	for (i = 0; i < n; i += PGSIZE)
f010204e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102054:	eb ca                	jmp    f0102020 <mem_init+0xcfb>
	assert(nfree == 0);
f0102056:	68 71 4b 10 f0       	push   $0xf0104b71
f010205b:	68 d6 49 10 f0       	push   $0xf01049d6
f0102060:	68 8a 02 00 00       	push   $0x28a
f0102065:	68 b0 49 10 f0       	push   $0xf01049b0
f010206a:	e8 1c e0 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f010206f:	68 7f 4a 10 f0       	push   $0xf0104a7f
f0102074:	68 d6 49 10 f0       	push   $0xf01049d6
f0102079:	68 e3 02 00 00       	push   $0x2e3
f010207e:	68 b0 49 10 f0       	push   $0xf01049b0
f0102083:	e8 03 e0 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102088:	68 95 4a 10 f0       	push   $0xf0104a95
f010208d:	68 d6 49 10 f0       	push   $0xf01049d6
f0102092:	68 e4 02 00 00       	push   $0x2e4
f0102097:	68 b0 49 10 f0       	push   $0xf01049b0
f010209c:	e8 ea df ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01020a1:	68 ab 4a 10 f0       	push   $0xf0104aab
f01020a6:	68 d6 49 10 f0       	push   $0xf01049d6
f01020ab:	68 e5 02 00 00       	push   $0x2e5
f01020b0:	68 b0 49 10 f0       	push   $0xf01049b0
f01020b5:	e8 d1 df ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f01020ba:	68 c1 4a 10 f0       	push   $0xf0104ac1
f01020bf:	68 d6 49 10 f0       	push   $0xf01049d6
f01020c4:	68 e8 02 00 00       	push   $0x2e8
f01020c9:	68 b0 49 10 f0       	push   $0xf01049b0
f01020ce:	e8 b8 df ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01020d3:	68 c4 43 10 f0       	push   $0xf01043c4
f01020d8:	68 d6 49 10 f0       	push   $0xf01049d6
f01020dd:	68 e9 02 00 00       	push   $0x2e9
f01020e2:	68 b0 49 10 f0       	push   $0xf01049b0
f01020e7:	e8 9f df ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01020ec:	68 2a 4b 10 f0       	push   $0xf0104b2a
f01020f1:	68 d6 49 10 f0       	push   $0xf01049d6
f01020f6:	68 f0 02 00 00       	push   $0x2f0
f01020fb:	68 b0 49 10 f0       	push   $0xf01049b0
f0102100:	e8 86 df ff ff       	call   f010008b <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102105:	68 04 44 10 f0       	push   $0xf0104404
f010210a:	68 d6 49 10 f0       	push   $0xf01049d6
f010210f:	68 f3 02 00 00       	push   $0x2f3
f0102114:	68 b0 49 10 f0       	push   $0xf01049b0
f0102119:	e8 6d df ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010211e:	68 3c 44 10 f0       	push   $0xf010443c
f0102123:	68 d6 49 10 f0       	push   $0xf01049d6
f0102128:	68 f6 02 00 00       	push   $0x2f6
f010212d:	68 b0 49 10 f0       	push   $0xf01049b0
f0102132:	e8 54 df ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102137:	68 6c 44 10 f0       	push   $0xf010446c
f010213c:	68 d6 49 10 f0       	push   $0xf01049d6
f0102141:	68 fa 02 00 00       	push   $0x2fa
f0102146:	68 b0 49 10 f0       	push   $0xf01049b0
f010214b:	e8 3b df ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102150:	68 9c 44 10 f0       	push   $0xf010449c
f0102155:	68 d6 49 10 f0       	push   $0xf01049d6
f010215a:	68 fb 02 00 00       	push   $0x2fb
f010215f:	68 b0 49 10 f0       	push   $0xf01049b0
f0102164:	e8 22 df ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102169:	68 c4 44 10 f0       	push   $0xf01044c4
f010216e:	68 d6 49 10 f0       	push   $0xf01049d6
f0102173:	68 fc 02 00 00       	push   $0x2fc
f0102178:	68 b0 49 10 f0       	push   $0xf01049b0
f010217d:	e8 09 df ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0102182:	68 7c 4b 10 f0       	push   $0xf0104b7c
f0102187:	68 d6 49 10 f0       	push   $0xf01049d6
f010218c:	68 fd 02 00 00       	push   $0x2fd
f0102191:	68 b0 49 10 f0       	push   $0xf01049b0
f0102196:	e8 f0 de ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f010219b:	68 8d 4b 10 f0       	push   $0xf0104b8d
f01021a0:	68 d6 49 10 f0       	push   $0xf01049d6
f01021a5:	68 fe 02 00 00       	push   $0x2fe
f01021aa:	68 b0 49 10 f0       	push   $0xf01049b0
f01021af:	e8 d7 de ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021b4:	68 f4 44 10 f0       	push   $0xf01044f4
f01021b9:	68 d6 49 10 f0       	push   $0xf01049d6
f01021be:	68 01 03 00 00       	push   $0x301
f01021c3:	68 b0 49 10 f0       	push   $0xf01049b0
f01021c8:	e8 be de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021cd:	68 30 45 10 f0       	push   $0xf0104530
f01021d2:	68 d6 49 10 f0       	push   $0xf01049d6
f01021d7:	68 02 03 00 00       	push   $0x302
f01021dc:	68 b0 49 10 f0       	push   $0xf01049b0
f01021e1:	e8 a5 de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01021e6:	68 9e 4b 10 f0       	push   $0xf0104b9e
f01021eb:	68 d6 49 10 f0       	push   $0xf01049d6
f01021f0:	68 03 03 00 00       	push   $0x303
f01021f5:	68 b0 49 10 f0       	push   $0xf01049b0
f01021fa:	e8 8c de ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01021ff:	68 2a 4b 10 f0       	push   $0xf0104b2a
f0102204:	68 d6 49 10 f0       	push   $0xf01049d6
f0102209:	68 06 03 00 00       	push   $0x306
f010220e:	68 b0 49 10 f0       	push   $0xf01049b0
f0102213:	e8 73 de ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102218:	68 f4 44 10 f0       	push   $0xf01044f4
f010221d:	68 d6 49 10 f0       	push   $0xf01049d6
f0102222:	68 09 03 00 00       	push   $0x309
f0102227:	68 b0 49 10 f0       	push   $0xf01049b0
f010222c:	e8 5a de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102231:	68 30 45 10 f0       	push   $0xf0104530
f0102236:	68 d6 49 10 f0       	push   $0xf01049d6
f010223b:	68 0a 03 00 00       	push   $0x30a
f0102240:	68 b0 49 10 f0       	push   $0xf01049b0
f0102245:	e8 41 de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010224a:	68 9e 4b 10 f0       	push   $0xf0104b9e
f010224f:	68 d6 49 10 f0       	push   $0xf01049d6
f0102254:	68 0b 03 00 00       	push   $0x30b
f0102259:	68 b0 49 10 f0       	push   $0xf01049b0
f010225e:	e8 28 de ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0102263:	68 2a 4b 10 f0       	push   $0xf0104b2a
f0102268:	68 d6 49 10 f0       	push   $0xf01049d6
f010226d:	68 0f 03 00 00       	push   $0x30f
f0102272:	68 b0 49 10 f0       	push   $0xf01049b0
f0102277:	e8 0f de ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010227c:	50                   	push   %eax
f010227d:	68 5c 42 10 f0       	push   $0xf010425c
f0102282:	68 12 03 00 00       	push   $0x312
f0102287:	68 b0 49 10 f0       	push   $0xf01049b0
f010228c:	e8 fa dd ff ff       	call   f010008b <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102291:	68 60 45 10 f0       	push   $0xf0104560
f0102296:	68 d6 49 10 f0       	push   $0xf01049d6
f010229b:	68 13 03 00 00       	push   $0x313
f01022a0:	68 b0 49 10 f0       	push   $0xf01049b0
f01022a5:	e8 e1 dd ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01022aa:	68 a0 45 10 f0       	push   $0xf01045a0
f01022af:	68 d6 49 10 f0       	push   $0xf01049d6
f01022b4:	68 16 03 00 00       	push   $0x316
f01022b9:	68 b0 49 10 f0       	push   $0xf01049b0
f01022be:	e8 c8 dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022c3:	68 30 45 10 f0       	push   $0xf0104530
f01022c8:	68 d6 49 10 f0       	push   $0xf01049d6
f01022cd:	68 17 03 00 00       	push   $0x317
f01022d2:	68 b0 49 10 f0       	push   $0xf01049b0
f01022d7:	e8 af dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01022dc:	68 9e 4b 10 f0       	push   $0xf0104b9e
f01022e1:	68 d6 49 10 f0       	push   $0xf01049d6
f01022e6:	68 18 03 00 00       	push   $0x318
f01022eb:	68 b0 49 10 f0       	push   $0xf01049b0
f01022f0:	e8 96 dd ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01022f5:	68 e0 45 10 f0       	push   $0xf01045e0
f01022fa:	68 d6 49 10 f0       	push   $0xf01049d6
f01022ff:	68 19 03 00 00       	push   $0x319
f0102304:	68 b0 49 10 f0       	push   $0xf01049b0
f0102309:	e8 7d dd ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010230e:	68 af 4b 10 f0       	push   $0xf0104baf
f0102313:	68 d6 49 10 f0       	push   $0xf01049d6
f0102318:	68 1a 03 00 00       	push   $0x31a
f010231d:	68 b0 49 10 f0       	push   $0xf01049b0
f0102322:	e8 64 dd ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102327:	68 f4 44 10 f0       	push   $0xf01044f4
f010232c:	68 d6 49 10 f0       	push   $0xf01049d6
f0102331:	68 1d 03 00 00       	push   $0x31d
f0102336:	68 b0 49 10 f0       	push   $0xf01049b0
f010233b:	e8 4b dd ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102340:	68 14 46 10 f0       	push   $0xf0104614
f0102345:	68 d6 49 10 f0       	push   $0xf01049d6
f010234a:	68 1e 03 00 00       	push   $0x31e
f010234f:	68 b0 49 10 f0       	push   $0xf01049b0
f0102354:	e8 32 dd ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102359:	68 48 46 10 f0       	push   $0xf0104648
f010235e:	68 d6 49 10 f0       	push   $0xf01049d6
f0102363:	68 1f 03 00 00       	push   $0x31f
f0102368:	68 b0 49 10 f0       	push   $0xf01049b0
f010236d:	e8 19 dd ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102372:	68 80 46 10 f0       	push   $0xf0104680
f0102377:	68 d6 49 10 f0       	push   $0xf01049d6
f010237c:	68 22 03 00 00       	push   $0x322
f0102381:	68 b0 49 10 f0       	push   $0xf01049b0
f0102386:	e8 00 dd ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010238b:	68 b8 46 10 f0       	push   $0xf01046b8
f0102390:	68 d6 49 10 f0       	push   $0xf01049d6
f0102395:	68 25 03 00 00       	push   $0x325
f010239a:	68 b0 49 10 f0       	push   $0xf01049b0
f010239f:	e8 e7 dc ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023a4:	68 48 46 10 f0       	push   $0xf0104648
f01023a9:	68 d6 49 10 f0       	push   $0xf01049d6
f01023ae:	68 26 03 00 00       	push   $0x326
f01023b3:	68 b0 49 10 f0       	push   $0xf01049b0
f01023b8:	e8 ce dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01023bd:	68 f4 46 10 f0       	push   $0xf01046f4
f01023c2:	68 d6 49 10 f0       	push   $0xf01049d6
f01023c7:	68 29 03 00 00       	push   $0x329
f01023cc:	68 b0 49 10 f0       	push   $0xf01049b0
f01023d1:	e8 b5 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023d6:	68 20 47 10 f0       	push   $0xf0104720
f01023db:	68 d6 49 10 f0       	push   $0xf01049d6
f01023e0:	68 2a 03 00 00       	push   $0x32a
f01023e5:	68 b0 49 10 f0       	push   $0xf01049b0
f01023ea:	e8 9c dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 2);
f01023ef:	68 c5 4b 10 f0       	push   $0xf0104bc5
f01023f4:	68 d6 49 10 f0       	push   $0xf01049d6
f01023f9:	68 2c 03 00 00       	push   $0x32c
f01023fe:	68 b0 49 10 f0       	push   $0xf01049b0
f0102403:	e8 83 dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102408:	68 d6 4b 10 f0       	push   $0xf0104bd6
f010240d:	68 d6 49 10 f0       	push   $0xf01049d6
f0102412:	68 2d 03 00 00       	push   $0x32d
f0102417:	68 b0 49 10 f0       	push   $0xf01049b0
f010241c:	e8 6a dc ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102421:	68 50 47 10 f0       	push   $0xf0104750
f0102426:	68 d6 49 10 f0       	push   $0xf01049d6
f010242b:	68 30 03 00 00       	push   $0x330
f0102430:	68 b0 49 10 f0       	push   $0xf01049b0
f0102435:	e8 51 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010243a:	68 74 47 10 f0       	push   $0xf0104774
f010243f:	68 d6 49 10 f0       	push   $0xf01049d6
f0102444:	68 34 03 00 00       	push   $0x334
f0102449:	68 b0 49 10 f0       	push   $0xf01049b0
f010244e:	e8 38 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102453:	68 20 47 10 f0       	push   $0xf0104720
f0102458:	68 d6 49 10 f0       	push   $0xf01049d6
f010245d:	68 35 03 00 00       	push   $0x335
f0102462:	68 b0 49 10 f0       	push   $0xf01049b0
f0102467:	e8 1f dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010246c:	68 7c 4b 10 f0       	push   $0xf0104b7c
f0102471:	68 d6 49 10 f0       	push   $0xf01049d6
f0102476:	68 36 03 00 00       	push   $0x336
f010247b:	68 b0 49 10 f0       	push   $0xf01049b0
f0102480:	e8 06 dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102485:	68 d6 4b 10 f0       	push   $0xf0104bd6
f010248a:	68 d6 49 10 f0       	push   $0xf01049d6
f010248f:	68 37 03 00 00       	push   $0x337
f0102494:	68 b0 49 10 f0       	push   $0xf01049b0
f0102499:	e8 ed db ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010249e:	68 98 47 10 f0       	push   $0xf0104798
f01024a3:	68 d6 49 10 f0       	push   $0xf01049d6
f01024a8:	68 3a 03 00 00       	push   $0x33a
f01024ad:	68 b0 49 10 f0       	push   $0xf01049b0
f01024b2:	e8 d4 db ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f01024b7:	68 e7 4b 10 f0       	push   $0xf0104be7
f01024bc:	68 d6 49 10 f0       	push   $0xf01049d6
f01024c1:	68 3b 03 00 00       	push   $0x33b
f01024c6:	68 b0 49 10 f0       	push   $0xf01049b0
f01024cb:	e8 bb db ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f01024d0:	68 f3 4b 10 f0       	push   $0xf0104bf3
f01024d5:	68 d6 49 10 f0       	push   $0xf01049d6
f01024da:	68 3c 03 00 00       	push   $0x33c
f01024df:	68 b0 49 10 f0       	push   $0xf01049b0
f01024e4:	e8 a2 db ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024e9:	68 74 47 10 f0       	push   $0xf0104774
f01024ee:	68 d6 49 10 f0       	push   $0xf01049d6
f01024f3:	68 40 03 00 00       	push   $0x340
f01024f8:	68 b0 49 10 f0       	push   $0xf01049b0
f01024fd:	e8 89 db ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102502:	68 d0 47 10 f0       	push   $0xf01047d0
f0102507:	68 d6 49 10 f0       	push   $0xf01049d6
f010250c:	68 41 03 00 00       	push   $0x341
f0102511:	68 b0 49 10 f0       	push   $0xf01049b0
f0102516:	e8 70 db ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010251b:	68 08 4c 10 f0       	push   $0xf0104c08
f0102520:	68 d6 49 10 f0       	push   $0xf01049d6
f0102525:	68 42 03 00 00       	push   $0x342
f010252a:	68 b0 49 10 f0       	push   $0xf01049b0
f010252f:	e8 57 db ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102534:	68 d6 4b 10 f0       	push   $0xf0104bd6
f0102539:	68 d6 49 10 f0       	push   $0xf01049d6
f010253e:	68 43 03 00 00       	push   $0x343
f0102543:	68 b0 49 10 f0       	push   $0xf01049b0
f0102548:	e8 3e db ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010254d:	68 f8 47 10 f0       	push   $0xf01047f8
f0102552:	68 d6 49 10 f0       	push   $0xf01049d6
f0102557:	68 46 03 00 00       	push   $0x346
f010255c:	68 b0 49 10 f0       	push   $0xf01049b0
f0102561:	e8 25 db ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0102566:	68 2a 4b 10 f0       	push   $0xf0104b2a
f010256b:	68 d6 49 10 f0       	push   $0xf01049d6
f0102570:	68 49 03 00 00       	push   $0x349
f0102575:	68 b0 49 10 f0       	push   $0xf01049b0
f010257a:	e8 0c db ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010257f:	68 9c 44 10 f0       	push   $0xf010449c
f0102584:	68 d6 49 10 f0       	push   $0xf01049d6
f0102589:	68 4c 03 00 00       	push   $0x34c
f010258e:	68 b0 49 10 f0       	push   $0xf01049b0
f0102593:	e8 f3 da ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0102598:	68 8d 4b 10 f0       	push   $0xf0104b8d
f010259d:	68 d6 49 10 f0       	push   $0xf01049d6
f01025a2:	68 4e 03 00 00       	push   $0x34e
f01025a7:	68 b0 49 10 f0       	push   $0xf01049b0
f01025ac:	e8 da da ff ff       	call   f010008b <_panic>
f01025b1:	50                   	push   %eax
f01025b2:	68 5c 42 10 f0       	push   $0xf010425c
f01025b7:	68 55 03 00 00       	push   $0x355
f01025bc:	68 b0 49 10 f0       	push   $0xf01049b0
f01025c1:	e8 c5 da ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f01025c6:	68 19 4c 10 f0       	push   $0xf0104c19
f01025cb:	68 d6 49 10 f0       	push   $0xf01049d6
f01025d0:	68 56 03 00 00       	push   $0x356
f01025d5:	68 b0 49 10 f0       	push   $0xf01049b0
f01025da:	e8 ac da ff ff       	call   f010008b <_panic>
f01025df:	50                   	push   %eax
f01025e0:	68 5c 42 10 f0       	push   $0xf010425c
f01025e5:	6a 52                	push   $0x52
f01025e7:	68 bc 49 10 f0       	push   $0xf01049bc
f01025ec:	e8 9a da ff ff       	call   f010008b <_panic>
f01025f1:	52                   	push   %edx
f01025f2:	68 5c 42 10 f0       	push   $0xf010425c
f01025f7:	6a 52                	push   $0x52
f01025f9:	68 bc 49 10 f0       	push   $0xf01049bc
f01025fe:	e8 88 da ff ff       	call   f010008b <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102603:	68 31 4c 10 f0       	push   $0xf0104c31
f0102608:	68 d6 49 10 f0       	push   $0xf01049d6
f010260d:	68 60 03 00 00       	push   $0x360
f0102612:	68 b0 49 10 f0       	push   $0xf01049b0
f0102617:	e8 6f da ff ff       	call   f010008b <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010261c:	50                   	push   %eax
f010261d:	68 a0 43 10 f0       	push   $0xf01043a0
f0102622:	68 ad 00 00 00       	push   $0xad
f0102627:	68 b0 49 10 f0       	push   $0xf01049b0
f010262c:	e8 5a da ff ff       	call   f010008b <_panic>
f0102631:	50                   	push   %eax
f0102632:	68 a0 43 10 f0       	push   $0xf01043a0
f0102637:	68 b9 00 00 00       	push   $0xb9
f010263c:	68 b0 49 10 f0       	push   $0xf01049b0
f0102641:	e8 45 da ff ff       	call   f010008b <_panic>
f0102646:	ff 75 c8             	pushl  -0x38(%ebp)
f0102649:	68 a0 43 10 f0       	push   $0xf01043a0
f010264e:	68 a2 02 00 00       	push   $0x2a2
f0102653:	68 b0 49 10 f0       	push   $0xf01049b0
f0102658:	e8 2e da ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010265d:	68 1c 48 10 f0       	push   $0xf010481c
f0102662:	68 d6 49 10 f0       	push   $0xf01049d6
f0102667:	68 a2 02 00 00       	push   $0x2a2
f010266c:	68 b0 49 10 f0       	push   $0xf01049b0
f0102671:	e8 15 da ff ff       	call   f010008b <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102676:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102679:	c1 e7 0c             	shl    $0xc,%edi
f010267c:	be 00 00 00 00       	mov    $0x0,%esi
f0102681:	eb 17                	jmp    f010269a <mem_init+0x1375>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102683:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102689:	89 d8                	mov    %ebx,%eax
f010268b:	e8 f2 e5 ff ff       	call   f0100c82 <check_va2pa>
f0102690:	39 c6                	cmp    %eax,%esi
f0102692:	75 50                	jne    f01026e4 <mem_init+0x13bf>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102694:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010269a:	39 fe                	cmp    %edi,%esi
f010269c:	72 e5                	jb     f0102683 <mem_init+0x135e>
f010269e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026a3:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f01026a8:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f01026ae:	89 f2                	mov    %esi,%edx
f01026b0:	89 d8                	mov    %ebx,%eax
f01026b2:	e8 cb e5 ff ff       	call   f0100c82 <check_va2pa>
f01026b7:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01026ba:	39 c2                	cmp    %eax,%edx
f01026bc:	75 3f                	jne    f01026fd <mem_init+0x13d8>
f01026be:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01026c4:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01026ca:	75 e2                	jne    f01026ae <mem_init+0x1389>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01026cc:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01026d1:	89 d8                	mov    %ebx,%eax
f01026d3:	e8 aa e5 ff ff       	call   f0100c82 <check_va2pa>
f01026d8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026db:	75 39                	jne    f0102716 <mem_init+0x13f1>
	for (i = 0; i < NPDENTRIES; i++) {
f01026dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01026e2:	eb 74                	jmp    f0102758 <mem_init+0x1433>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01026e4:	68 50 48 10 f0       	push   $0xf0104850
f01026e9:	68 d6 49 10 f0       	push   $0xf01049d6
f01026ee:	68 a7 02 00 00       	push   $0x2a7
f01026f3:	68 b0 49 10 f0       	push   $0xf01049b0
f01026f8:	e8 8e d9 ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026fd:	68 78 48 10 f0       	push   $0xf0104878
f0102702:	68 d6 49 10 f0       	push   $0xf01049d6
f0102707:	68 ab 02 00 00       	push   $0x2ab
f010270c:	68 b0 49 10 f0       	push   $0xf01049b0
f0102711:	e8 75 d9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102716:	68 c0 48 10 f0       	push   $0xf01048c0
f010271b:	68 d6 49 10 f0       	push   $0xf01049d6
f0102720:	68 ac 02 00 00       	push   $0x2ac
f0102725:	68 b0 49 10 f0       	push   $0xf01049b0
f010272a:	e8 5c d9 ff ff       	call   f010008b <_panic>
			assert(pgdir[i] & PTE_P);
f010272f:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102733:	74 49                	je     f010277e <mem_init+0x1459>
	for (i = 0; i < NPDENTRIES; i++) {
f0102735:	83 c0 01             	add    $0x1,%eax
f0102738:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010273d:	0f 87 93 00 00 00    	ja     f01027d6 <mem_init+0x14b1>
		switch (i) {
f0102743:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102748:	72 0e                	jb     f0102758 <mem_init+0x1433>
f010274a:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010274f:	76 de                	jbe    f010272f <mem_init+0x140a>
f0102751:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102756:	74 d7                	je     f010272f <mem_init+0x140a>
			if (i >= PDX(KERNBASE)) {
f0102758:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010275d:	77 38                	ja     f0102797 <mem_init+0x1472>
				assert(pgdir[i] == 0);
f010275f:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102763:	74 d0                	je     f0102735 <mem_init+0x1410>
f0102765:	68 83 4c 10 f0       	push   $0xf0104c83
f010276a:	68 d6 49 10 f0       	push   $0xf01049d6
f010276f:	68 bb 02 00 00       	push   $0x2bb
f0102774:	68 b0 49 10 f0       	push   $0xf01049b0
f0102779:	e8 0d d9 ff ff       	call   f010008b <_panic>
			assert(pgdir[i] & PTE_P);
f010277e:	68 61 4c 10 f0       	push   $0xf0104c61
f0102783:	68 d6 49 10 f0       	push   $0xf01049d6
f0102788:	68 b4 02 00 00       	push   $0x2b4
f010278d:	68 b0 49 10 f0       	push   $0xf01049b0
f0102792:	e8 f4 d8 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f0102797:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010279a:	f6 c2 01             	test   $0x1,%dl
f010279d:	74 1e                	je     f01027bd <mem_init+0x1498>
				assert(pgdir[i] & PTE_W);
f010279f:	f6 c2 02             	test   $0x2,%dl
f01027a2:	75 91                	jne    f0102735 <mem_init+0x1410>
f01027a4:	68 72 4c 10 f0       	push   $0xf0104c72
f01027a9:	68 d6 49 10 f0       	push   $0xf01049d6
f01027ae:	68 b9 02 00 00       	push   $0x2b9
f01027b3:	68 b0 49 10 f0       	push   $0xf01049b0
f01027b8:	e8 ce d8 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f01027bd:	68 61 4c 10 f0       	push   $0xf0104c61
f01027c2:	68 d6 49 10 f0       	push   $0xf01049d6
f01027c7:	68 b8 02 00 00       	push   $0x2b8
f01027cc:	68 b0 49 10 f0       	push   $0xf01049b0
f01027d1:	e8 b5 d8 ff ff       	call   f010008b <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01027d6:	83 ec 0c             	sub    $0xc,%esp
f01027d9:	68 f0 48 10 f0       	push   $0xf01048f0
f01027de:	e8 fa 03 00 00       	call   f0102bdd <cprintf>
	lcr3(PADDR(kern_pgdir));
f01027e3:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f01027e8:	83 c4 10             	add    $0x10,%esp
f01027eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027f0:	0f 86 fe 01 00 00    	jbe    f01029f4 <mem_init+0x16cf>
	return (physaddr_t)kva - KERNBASE;
f01027f6:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01027fb:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01027fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0102803:	e8 de e4 ff ff       	call   f0100ce6 <check_page_free_list>
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102808:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010280b:	83 e0 f3             	and    $0xfffffff3,%eax
f010280e:	0d 23 00 05 80       	or     $0x80050023,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102813:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102816:	83 ec 0c             	sub    $0xc,%esp
f0102819:	6a 00                	push   $0x0
f010281b:	e8 1e e8 ff ff       	call   f010103e <page_alloc>
f0102820:	89 c3                	mov    %eax,%ebx
f0102822:	83 c4 10             	add    $0x10,%esp
f0102825:	85 c0                	test   %eax,%eax
f0102827:	0f 84 dc 01 00 00    	je     f0102a09 <mem_init+0x16e4>
	assert((pp1 = page_alloc(0)));
f010282d:	83 ec 0c             	sub    $0xc,%esp
f0102830:	6a 00                	push   $0x0
f0102832:	e8 07 e8 ff ff       	call   f010103e <page_alloc>
f0102837:	89 c7                	mov    %eax,%edi
f0102839:	83 c4 10             	add    $0x10,%esp
f010283c:	85 c0                	test   %eax,%eax
f010283e:	0f 84 de 01 00 00    	je     f0102a22 <mem_init+0x16fd>
	assert((pp2 = page_alloc(0)));
f0102844:	83 ec 0c             	sub    $0xc,%esp
f0102847:	6a 00                	push   $0x0
f0102849:	e8 f0 e7 ff ff       	call   f010103e <page_alloc>
f010284e:	89 c6                	mov    %eax,%esi
f0102850:	83 c4 10             	add    $0x10,%esp
f0102853:	85 c0                	test   %eax,%eax
f0102855:	0f 84 e0 01 00 00    	je     f0102a3b <mem_init+0x1716>
	page_free(pp0);
f010285b:	83 ec 0c             	sub    $0xc,%esp
f010285e:	53                   	push   %ebx
f010285f:	e8 46 e8 ff ff       	call   f01010aa <page_free>
	return (pp - pages) << PGSHIFT;
f0102864:	89 f8                	mov    %edi,%eax
f0102866:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010286c:	c1 f8 03             	sar    $0x3,%eax
f010286f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102872:	89 c2                	mov    %eax,%edx
f0102874:	c1 ea 0c             	shr    $0xc,%edx
f0102877:	83 c4 10             	add    $0x10,%esp
f010287a:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0102880:	0f 83 ce 01 00 00    	jae    f0102a54 <mem_init+0x172f>
	memset(page2kva(pp1), 1, PGSIZE);
f0102886:	83 ec 04             	sub    $0x4,%esp
f0102889:	68 00 10 00 00       	push   $0x1000
f010288e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102890:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102895:	50                   	push   %eax
f0102896:	e8 e3 0e 00 00       	call   f010377e <memset>
	return (pp - pages) << PGSHIFT;
f010289b:	89 f0                	mov    %esi,%eax
f010289d:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01028a3:	c1 f8 03             	sar    $0x3,%eax
f01028a6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01028a9:	89 c2                	mov    %eax,%edx
f01028ab:	c1 ea 0c             	shr    $0xc,%edx
f01028ae:	83 c4 10             	add    $0x10,%esp
f01028b1:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f01028b7:	0f 83 a9 01 00 00    	jae    f0102a66 <mem_init+0x1741>
	memset(page2kva(pp2), 2, PGSIZE);
f01028bd:	83 ec 04             	sub    $0x4,%esp
f01028c0:	68 00 10 00 00       	push   $0x1000
f01028c5:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01028c7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028cc:	50                   	push   %eax
f01028cd:	e8 ac 0e 00 00       	call   f010377e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01028d2:	6a 02                	push   $0x2
f01028d4:	68 00 10 00 00       	push   $0x1000
f01028d9:	57                   	push   %edi
f01028da:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01028e0:	e8 aa e9 ff ff       	call   f010128f <page_insert>
	assert(pp1->pp_ref == 1);
f01028e5:	83 c4 20             	add    $0x20,%esp
f01028e8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01028ed:	0f 85 85 01 00 00    	jne    f0102a78 <mem_init+0x1753>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01028f3:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01028fa:	01 01 01 
f01028fd:	0f 85 8e 01 00 00    	jne    f0102a91 <mem_init+0x176c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102903:	6a 02                	push   $0x2
f0102905:	68 00 10 00 00       	push   $0x1000
f010290a:	56                   	push   %esi
f010290b:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102911:	e8 79 e9 ff ff       	call   f010128f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102916:	83 c4 10             	add    $0x10,%esp
f0102919:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102920:	02 02 02 
f0102923:	0f 85 81 01 00 00    	jne    f0102aaa <mem_init+0x1785>
	assert(pp2->pp_ref == 1);
f0102929:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010292e:	0f 85 8f 01 00 00    	jne    f0102ac3 <mem_init+0x179e>
	assert(pp1->pp_ref == 0);
f0102934:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102939:	0f 85 9d 01 00 00    	jne    f0102adc <mem_init+0x17b7>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010293f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102946:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102949:	89 f0                	mov    %esi,%eax
f010294b:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0102951:	c1 f8 03             	sar    $0x3,%eax
f0102954:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102957:	89 c2                	mov    %eax,%edx
f0102959:	c1 ea 0c             	shr    $0xc,%edx
f010295c:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0102962:	0f 83 8d 01 00 00    	jae    f0102af5 <mem_init+0x17d0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102968:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010296f:	03 03 03 
f0102972:	0f 85 8f 01 00 00    	jne    f0102b07 <mem_init+0x17e2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102978:	83 ec 08             	sub    $0x8,%esp
f010297b:	68 00 10 00 00       	push   $0x1000
f0102980:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102986:	e8 c7 e8 ff ff       	call   f0101252 <page_remove>
	assert(pp2->pp_ref == 0);
f010298b:	83 c4 10             	add    $0x10,%esp
f010298e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102993:	0f 85 87 01 00 00    	jne    f0102b20 <mem_init+0x17fb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102999:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f010299f:	8b 11                	mov    (%ecx),%edx
f01029a1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f01029a7:	89 d8                	mov    %ebx,%eax
f01029a9:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01029af:	c1 f8 03             	sar    $0x3,%eax
f01029b2:	c1 e0 0c             	shl    $0xc,%eax
f01029b5:	39 c2                	cmp    %eax,%edx
f01029b7:	0f 85 7c 01 00 00    	jne    f0102b39 <mem_init+0x1814>
	kern_pgdir[0] = 0;
f01029bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01029c3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01029c8:	0f 85 84 01 00 00    	jne    f0102b52 <mem_init+0x182d>
	pp0->pp_ref = 0;
f01029ce:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01029d4:	83 ec 0c             	sub    $0xc,%esp
f01029d7:	53                   	push   %ebx
f01029d8:	e8 cd e6 ff ff       	call   f01010aa <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01029dd:	c7 04 24 84 49 10 f0 	movl   $0xf0104984,(%esp)
f01029e4:	e8 f4 01 00 00       	call   f0102bdd <cprintf>
}
f01029e9:	83 c4 10             	add    $0x10,%esp
f01029ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029ef:	5b                   	pop    %ebx
f01029f0:	5e                   	pop    %esi
f01029f1:	5f                   	pop    %edi
f01029f2:	5d                   	pop    %ebp
f01029f3:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029f4:	50                   	push   %eax
f01029f5:	68 a0 43 10 f0       	push   $0xf01043a0
f01029fa:	68 cd 00 00 00       	push   $0xcd
f01029ff:	68 b0 49 10 f0       	push   $0xf01049b0
f0102a04:	e8 82 d6 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0102a09:	68 7f 4a 10 f0       	push   $0xf0104a7f
f0102a0e:	68 d6 49 10 f0       	push   $0xf01049d6
f0102a13:	68 7b 03 00 00       	push   $0x37b
f0102a18:	68 b0 49 10 f0       	push   $0xf01049b0
f0102a1d:	e8 69 d6 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102a22:	68 95 4a 10 f0       	push   $0xf0104a95
f0102a27:	68 d6 49 10 f0       	push   $0xf01049d6
f0102a2c:	68 7c 03 00 00       	push   $0x37c
f0102a31:	68 b0 49 10 f0       	push   $0xf01049b0
f0102a36:	e8 50 d6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102a3b:	68 ab 4a 10 f0       	push   $0xf0104aab
f0102a40:	68 d6 49 10 f0       	push   $0xf01049d6
f0102a45:	68 7d 03 00 00       	push   $0x37d
f0102a4a:	68 b0 49 10 f0       	push   $0xf01049b0
f0102a4f:	e8 37 d6 ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a54:	50                   	push   %eax
f0102a55:	68 5c 42 10 f0       	push   $0xf010425c
f0102a5a:	6a 52                	push   $0x52
f0102a5c:	68 bc 49 10 f0       	push   $0xf01049bc
f0102a61:	e8 25 d6 ff ff       	call   f010008b <_panic>
f0102a66:	50                   	push   %eax
f0102a67:	68 5c 42 10 f0       	push   $0xf010425c
f0102a6c:	6a 52                	push   $0x52
f0102a6e:	68 bc 49 10 f0       	push   $0xf01049bc
f0102a73:	e8 13 d6 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0102a78:	68 7c 4b 10 f0       	push   $0xf0104b7c
f0102a7d:	68 d6 49 10 f0       	push   $0xf01049d6
f0102a82:	68 82 03 00 00       	push   $0x382
f0102a87:	68 b0 49 10 f0       	push   $0xf01049b0
f0102a8c:	e8 fa d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a91:	68 10 49 10 f0       	push   $0xf0104910
f0102a96:	68 d6 49 10 f0       	push   $0xf01049d6
f0102a9b:	68 83 03 00 00       	push   $0x383
f0102aa0:	68 b0 49 10 f0       	push   $0xf01049b0
f0102aa5:	e8 e1 d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102aaa:	68 34 49 10 f0       	push   $0xf0104934
f0102aaf:	68 d6 49 10 f0       	push   $0xf01049d6
f0102ab4:	68 85 03 00 00       	push   $0x385
f0102ab9:	68 b0 49 10 f0       	push   $0xf01049b0
f0102abe:	e8 c8 d5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102ac3:	68 9e 4b 10 f0       	push   $0xf0104b9e
f0102ac8:	68 d6 49 10 f0       	push   $0xf01049d6
f0102acd:	68 86 03 00 00       	push   $0x386
f0102ad2:	68 b0 49 10 f0       	push   $0xf01049b0
f0102ad7:	e8 af d5 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102adc:	68 08 4c 10 f0       	push   $0xf0104c08
f0102ae1:	68 d6 49 10 f0       	push   $0xf01049d6
f0102ae6:	68 87 03 00 00       	push   $0x387
f0102aeb:	68 b0 49 10 f0       	push   $0xf01049b0
f0102af0:	e8 96 d5 ff ff       	call   f010008b <_panic>
f0102af5:	50                   	push   %eax
f0102af6:	68 5c 42 10 f0       	push   $0xf010425c
f0102afb:	6a 52                	push   $0x52
f0102afd:	68 bc 49 10 f0       	push   $0xf01049bc
f0102b02:	e8 84 d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b07:	68 58 49 10 f0       	push   $0xf0104958
f0102b0c:	68 d6 49 10 f0       	push   $0xf01049d6
f0102b11:	68 89 03 00 00       	push   $0x389
f0102b16:	68 b0 49 10 f0       	push   $0xf01049b0
f0102b1b:	e8 6b d5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102b20:	68 d6 4b 10 f0       	push   $0xf0104bd6
f0102b25:	68 d6 49 10 f0       	push   $0xf01049d6
f0102b2a:	68 8b 03 00 00       	push   $0x38b
f0102b2f:	68 b0 49 10 f0       	push   $0xf01049b0
f0102b34:	e8 52 d5 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b39:	68 9c 44 10 f0       	push   $0xf010449c
f0102b3e:	68 d6 49 10 f0       	push   $0xf01049d6
f0102b43:	68 8e 03 00 00       	push   $0x38e
f0102b48:	68 b0 49 10 f0       	push   $0xf01049b0
f0102b4d:	e8 39 d5 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0102b52:	68 8d 4b 10 f0       	push   $0xf0104b8d
f0102b57:	68 d6 49 10 f0       	push   $0xf01049d6
f0102b5c:	68 90 03 00 00       	push   $0x390
f0102b61:	68 b0 49 10 f0       	push   $0xf01049b0
f0102b66:	e8 20 d5 ff ff       	call   f010008b <_panic>

f0102b6b <tlb_invalidate>:
{
f0102b6b:	55                   	push   %ebp
f0102b6c:	89 e5                	mov    %esp,%ebp
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b71:	0f 01 38             	invlpg (%eax)
}
f0102b74:	5d                   	pop    %ebp
f0102b75:	c3                   	ret    

f0102b76 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102b76:	55                   	push   %ebp
f0102b77:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b79:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b7c:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b81:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102b82:	ba 71 00 00 00       	mov    $0x71,%edx
f0102b87:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102b88:	0f b6 c0             	movzbl %al,%eax
}
f0102b8b:	5d                   	pop    %ebp
f0102b8c:	c3                   	ret    

f0102b8d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102b8d:	55                   	push   %ebp
f0102b8e:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b90:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b93:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b98:	ee                   	out    %al,(%dx)
f0102b99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b9c:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ba1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102ba2:	5d                   	pop    %ebp
f0102ba3:	c3                   	ret    

f0102ba4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102ba4:	55                   	push   %ebp
f0102ba5:	89 e5                	mov    %esp,%ebp
f0102ba7:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102baa:	ff 75 08             	pushl  0x8(%ebp)
f0102bad:	e8 73 da ff ff       	call   f0100625 <cputchar>
	*cnt++;
}
f0102bb2:	83 c4 10             	add    $0x10,%esp
f0102bb5:	c9                   	leave  
f0102bb6:	c3                   	ret    

f0102bb7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102bb7:	55                   	push   %ebp
f0102bb8:	89 e5                	mov    %esp,%ebp
f0102bba:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102bbd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102bc4:	ff 75 0c             	pushl  0xc(%ebp)
f0102bc7:	ff 75 08             	pushl  0x8(%ebp)
f0102bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102bcd:	50                   	push   %eax
f0102bce:	68 a4 2b 10 f0       	push   $0xf0102ba4
f0102bd3:	e8 0b 04 00 00       	call   f0102fe3 <vprintfmt>
	return cnt;
}
f0102bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102bdb:	c9                   	leave  
f0102bdc:	c3                   	ret    

f0102bdd <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102bdd:	55                   	push   %ebp
f0102bde:	89 e5                	mov    %esp,%ebp
f0102be0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102be3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102be6:	50                   	push   %eax
f0102be7:	ff 75 08             	pushl  0x8(%ebp)
f0102bea:	e8 c8 ff ff ff       	call   f0102bb7 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102bef:	c9                   	leave  
f0102bf0:	c3                   	ret    

f0102bf1 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102bf1:	55                   	push   %ebp
f0102bf2:	89 e5                	mov    %esp,%ebp
f0102bf4:	57                   	push   %edi
f0102bf5:	56                   	push   %esi
f0102bf6:	53                   	push   %ebx
f0102bf7:	83 ec 14             	sub    $0x14,%esp
f0102bfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102bfd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102c00:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c03:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c06:	8b 32                	mov    (%edx),%esi
f0102c08:	8b 01                	mov    (%ecx),%eax
f0102c0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102c14:	eb 2f                	jmp    f0102c45 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102c16:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0102c19:	39 c6                	cmp    %eax,%esi
f0102c1b:	7f 49                	jg     f0102c66 <stab_binsearch+0x75>
f0102c1d:	0f b6 0a             	movzbl (%edx),%ecx
f0102c20:	83 ea 0c             	sub    $0xc,%edx
f0102c23:	39 f9                	cmp    %edi,%ecx
f0102c25:	75 ef                	jne    f0102c16 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102c27:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102c2a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102c2d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102c31:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102c34:	73 35                	jae    f0102c6b <stab_binsearch+0x7a>
			*region_left = m;
f0102c36:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102c39:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0102c3b:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0102c3e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102c45:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0102c48:	7f 4e                	jg     f0102c98 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0102c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c4d:	01 f0                	add    %esi,%eax
f0102c4f:	89 c3                	mov    %eax,%ebx
f0102c51:	c1 eb 1f             	shr    $0x1f,%ebx
f0102c54:	01 c3                	add    %eax,%ebx
f0102c56:	d1 fb                	sar    %ebx
f0102c58:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102c5b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102c5e:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102c62:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102c64:	eb b3                	jmp    f0102c19 <stab_binsearch+0x28>
			l = true_m + 1;
f0102c66:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0102c69:	eb da                	jmp    f0102c45 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0102c6b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102c6e:	76 14                	jbe    f0102c84 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102c70:	83 e8 01             	sub    $0x1,%eax
f0102c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c76:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102c79:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0102c7b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102c82:	eb c1                	jmp    f0102c45 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102c84:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102c87:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102c89:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102c8d:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102c8f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102c96:	eb ad                	jmp    f0102c45 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0102c98:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102c9c:	74 16                	je     f0102cb4 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102c9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ca1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102ca3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102ca6:	8b 0e                	mov    (%esi),%ecx
f0102ca8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102cab:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102cae:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0102cb2:	eb 12                	jmp    f0102cc6 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0102cb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cb7:	8b 00                	mov    (%eax),%eax
f0102cb9:	83 e8 01             	sub    $0x1,%eax
f0102cbc:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102cbf:	89 07                	mov    %eax,(%edi)
f0102cc1:	eb 16                	jmp    f0102cd9 <stab_binsearch+0xe8>
		     l--)
f0102cc3:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0102cc6:	39 c1                	cmp    %eax,%ecx
f0102cc8:	7d 0a                	jge    f0102cd4 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0102cca:	0f b6 1a             	movzbl (%edx),%ebx
f0102ccd:	83 ea 0c             	sub    $0xc,%edx
f0102cd0:	39 fb                	cmp    %edi,%ebx
f0102cd2:	75 ef                	jne    f0102cc3 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0102cd4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cd7:	89 07                	mov    %eax,(%edi)
	}
}
f0102cd9:	83 c4 14             	add    $0x14,%esp
f0102cdc:	5b                   	pop    %ebx
f0102cdd:	5e                   	pop    %esi
f0102cde:	5f                   	pop    %edi
f0102cdf:	5d                   	pop    %ebp
f0102ce0:	c3                   	ret    

f0102ce1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102ce1:	55                   	push   %ebp
f0102ce2:	89 e5                	mov    %esp,%ebp
f0102ce4:	57                   	push   %edi
f0102ce5:	56                   	push   %esi
f0102ce6:	53                   	push   %ebx
f0102ce7:	83 ec 3c             	sub    $0x3c,%esp
f0102cea:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102cf0:	c7 03 91 4c 10 f0    	movl   $0xf0104c91,(%ebx)
	info->eip_line = 0;
f0102cf6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102cfd:	c7 43 08 91 4c 10 f0 	movl   $0xf0104c91,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102d04:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102d0b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102d0e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102d15:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102d1b:	0f 86 18 01 00 00    	jbe    f0102e39 <debuginfo_eip+0x158>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102d21:	b8 57 db 10 f0       	mov    $0xf010db57,%eax
f0102d26:	3d 5d bc 10 f0       	cmp    $0xf010bc5d,%eax
f0102d2b:	0f 86 a7 01 00 00    	jbe    f0102ed8 <debuginfo_eip+0x1f7>
f0102d31:	80 3d 56 db 10 f0 00 	cmpb   $0x0,0xf010db56
f0102d38:	0f 85 a1 01 00 00    	jne    f0102edf <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102d3e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102d45:	b8 5c bc 10 f0       	mov    $0xf010bc5c,%eax
f0102d4a:	2d d0 4e 10 f0       	sub    $0xf0104ed0,%eax
f0102d4f:	c1 f8 02             	sar    $0x2,%eax
f0102d52:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102d58:	83 e8 01             	sub    $0x1,%eax
f0102d5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102d5e:	83 ec 08             	sub    $0x8,%esp
f0102d61:	56                   	push   %esi
f0102d62:	6a 64                	push   $0x64
f0102d64:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102d67:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102d6a:	b8 d0 4e 10 f0       	mov    $0xf0104ed0,%eax
f0102d6f:	e8 7d fe ff ff       	call   f0102bf1 <stab_binsearch>
	if (lfile == 0)
f0102d74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d77:	83 c4 10             	add    $0x10,%esp
f0102d7a:	85 c0                	test   %eax,%eax
f0102d7c:	0f 84 64 01 00 00    	je     f0102ee6 <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102d82:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102d85:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d88:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102d8b:	83 ec 08             	sub    $0x8,%esp
f0102d8e:	56                   	push   %esi
f0102d8f:	6a 24                	push   $0x24
f0102d91:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102d94:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102d97:	b8 d0 4e 10 f0       	mov    $0xf0104ed0,%eax
f0102d9c:	e8 50 fe ff ff       	call   f0102bf1 <stab_binsearch>

	if (lfun <= rfun) {
f0102da1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102da4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102da7:	83 c4 10             	add    $0x10,%esp
f0102daa:	39 d0                	cmp    %edx,%eax
f0102dac:	0f 8f 9b 00 00 00    	jg     f0102e4d <debuginfo_eip+0x16c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102db2:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102db5:	c1 e1 02             	shl    $0x2,%ecx
f0102db8:	8d b9 d0 4e 10 f0    	lea    -0xfefb130(%ecx),%edi
f0102dbe:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102dc1:	8b b9 d0 4e 10 f0    	mov    -0xfefb130(%ecx),%edi
f0102dc7:	b9 57 db 10 f0       	mov    $0xf010db57,%ecx
f0102dcc:	81 e9 5d bc 10 f0    	sub    $0xf010bc5d,%ecx
f0102dd2:	39 cf                	cmp    %ecx,%edi
f0102dd4:	73 09                	jae    f0102ddf <debuginfo_eip+0xfe>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102dd6:	81 c7 5d bc 10 f0    	add    $0xf010bc5d,%edi
f0102ddc:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102ddf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102de2:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102de5:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102de8:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102dea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102ded:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102df0:	83 ec 08             	sub    $0x8,%esp
f0102df3:	6a 3a                	push   $0x3a
f0102df5:	ff 73 08             	pushl  0x8(%ebx)
f0102df8:	e8 65 09 00 00       	call   f0103762 <strfind>
f0102dfd:	2b 43 08             	sub    0x8(%ebx),%eax
f0102e00:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102e03:	83 c4 08             	add    $0x8,%esp
f0102e06:	56                   	push   %esi
f0102e07:	6a 44                	push   $0x44
f0102e09:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102e0c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102e0f:	b8 d0 4e 10 f0       	mov    $0xf0104ed0,%eax
f0102e14:	e8 d8 fd ff ff       	call   f0102bf1 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102e19:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e1c:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102e1f:	c1 e0 02             	shl    $0x2,%eax
f0102e22:	0f b7 88 d6 4e 10 f0 	movzwl -0xfefb12a(%eax),%ecx
f0102e29:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102e2c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102e2f:	05 d4 4e 10 f0       	add    $0xf0104ed4,%eax
f0102e34:	83 c4 10             	add    $0x10,%esp
f0102e37:	eb 2b                	jmp    f0102e64 <debuginfo_eip+0x183>
  	        panic("User address");
f0102e39:	83 ec 04             	sub    $0x4,%esp
f0102e3c:	68 9b 4c 10 f0       	push   $0xf0104c9b
f0102e41:	6a 7f                	push   $0x7f
f0102e43:	68 a8 4c 10 f0       	push   $0xf0104ca8
f0102e48:	e8 3e d2 ff ff       	call   f010008b <_panic>
		info->eip_fn_addr = addr;
f0102e4d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102e56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e59:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e5c:	eb 92                	jmp    f0102df0 <debuginfo_eip+0x10f>
f0102e5e:	83 ea 01             	sub    $0x1,%edx
f0102e61:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102e64:	39 d6                	cmp    %edx,%esi
f0102e66:	7f 33                	jg     f0102e9b <debuginfo_eip+0x1ba>
	       && stabs[lline].n_type != N_SOL
f0102e68:	0f b6 08             	movzbl (%eax),%ecx
f0102e6b:	80 f9 84             	cmp    $0x84,%cl
f0102e6e:	74 0b                	je     f0102e7b <debuginfo_eip+0x19a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102e70:	80 f9 64             	cmp    $0x64,%cl
f0102e73:	75 e9                	jne    f0102e5e <debuginfo_eip+0x17d>
f0102e75:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0102e79:	74 e3                	je     f0102e5e <debuginfo_eip+0x17d>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102e7b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102e7e:	8b 14 85 d0 4e 10 f0 	mov    -0xfefb130(,%eax,4),%edx
f0102e85:	b8 57 db 10 f0       	mov    $0xf010db57,%eax
f0102e8a:	2d 5d bc 10 f0       	sub    $0xf010bc5d,%eax
f0102e8f:	39 c2                	cmp    %eax,%edx
f0102e91:	73 08                	jae    f0102e9b <debuginfo_eip+0x1ba>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102e93:	81 c2 5d bc 10 f0    	add    $0xf010bc5d,%edx
f0102e99:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102e9b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e9e:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102ea1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0102ea6:	39 f2                	cmp    %esi,%edx
f0102ea8:	7d 48                	jge    f0102ef2 <debuginfo_eip+0x211>
		for (lline = lfun + 1;
f0102eaa:	83 c2 01             	add    $0x1,%edx
f0102ead:	89 d0                	mov    %edx,%eax
f0102eaf:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102eb2:	8d 14 95 d4 4e 10 f0 	lea    -0xfefb12c(,%edx,4),%edx
f0102eb9:	eb 04                	jmp    f0102ebf <debuginfo_eip+0x1de>
			info->eip_fn_narg++;
f0102ebb:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0102ebf:	39 c6                	cmp    %eax,%esi
f0102ec1:	7e 2a                	jle    f0102eed <debuginfo_eip+0x20c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102ec3:	0f b6 0a             	movzbl (%edx),%ecx
f0102ec6:	83 c0 01             	add    $0x1,%eax
f0102ec9:	83 c2 0c             	add    $0xc,%edx
f0102ecc:	80 f9 a0             	cmp    $0xa0,%cl
f0102ecf:	74 ea                	je     f0102ebb <debuginfo_eip+0x1da>
	return 0;
f0102ed1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ed6:	eb 1a                	jmp    f0102ef2 <debuginfo_eip+0x211>
		return -1;
f0102ed8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102edd:	eb 13                	jmp    f0102ef2 <debuginfo_eip+0x211>
f0102edf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ee4:	eb 0c                	jmp    f0102ef2 <debuginfo_eip+0x211>
		return -1;
f0102ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102eeb:	eb 05                	jmp    f0102ef2 <debuginfo_eip+0x211>
	return 0;
f0102eed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ef5:	5b                   	pop    %ebx
f0102ef6:	5e                   	pop    %esi
f0102ef7:	5f                   	pop    %edi
f0102ef8:	5d                   	pop    %ebp
f0102ef9:	c3                   	ret    

f0102efa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102efa:	55                   	push   %ebp
f0102efb:	89 e5                	mov    %esp,%ebp
f0102efd:	57                   	push   %edi
f0102efe:	56                   	push   %esi
f0102eff:	53                   	push   %ebx
f0102f00:	83 ec 1c             	sub    $0x1c,%esp
f0102f03:	89 c7                	mov    %eax,%edi
f0102f05:	89 d6                	mov    %edx,%esi
f0102f07:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f0a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102f0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f10:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102f13:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102f16:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f1b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102f1e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102f21:	39 d3                	cmp    %edx,%ebx
f0102f23:	72 05                	jb     f0102f2a <printnum+0x30>
f0102f25:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102f28:	77 7a                	ja     f0102fa4 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102f2a:	83 ec 0c             	sub    $0xc,%esp
f0102f2d:	ff 75 18             	pushl  0x18(%ebp)
f0102f30:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f33:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102f36:	53                   	push   %ebx
f0102f37:	ff 75 10             	pushl  0x10(%ebp)
f0102f3a:	83 ec 08             	sub    $0x8,%esp
f0102f3d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102f40:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f43:	ff 75 dc             	pushl  -0x24(%ebp)
f0102f46:	ff 75 d8             	pushl  -0x28(%ebp)
f0102f49:	e8 32 0a 00 00       	call   f0103980 <__udivdi3>
f0102f4e:	83 c4 18             	add    $0x18,%esp
f0102f51:	52                   	push   %edx
f0102f52:	50                   	push   %eax
f0102f53:	89 f2                	mov    %esi,%edx
f0102f55:	89 f8                	mov    %edi,%eax
f0102f57:	e8 9e ff ff ff       	call   f0102efa <printnum>
f0102f5c:	83 c4 20             	add    $0x20,%esp
f0102f5f:	eb 13                	jmp    f0102f74 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102f61:	83 ec 08             	sub    $0x8,%esp
f0102f64:	56                   	push   %esi
f0102f65:	ff 75 18             	pushl  0x18(%ebp)
f0102f68:	ff d7                	call   *%edi
f0102f6a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102f6d:	83 eb 01             	sub    $0x1,%ebx
f0102f70:	85 db                	test   %ebx,%ebx
f0102f72:	7f ed                	jg     f0102f61 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102f74:	83 ec 08             	sub    $0x8,%esp
f0102f77:	56                   	push   %esi
f0102f78:	83 ec 04             	sub    $0x4,%esp
f0102f7b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102f7e:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f81:	ff 75 dc             	pushl  -0x24(%ebp)
f0102f84:	ff 75 d8             	pushl  -0x28(%ebp)
f0102f87:	e8 14 0b 00 00       	call   f0103aa0 <__umoddi3>
f0102f8c:	83 c4 14             	add    $0x14,%esp
f0102f8f:	0f be 80 b6 4c 10 f0 	movsbl -0xfefb34a(%eax),%eax
f0102f96:	50                   	push   %eax
f0102f97:	ff d7                	call   *%edi
}
f0102f99:	83 c4 10             	add    $0x10,%esp
f0102f9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f9f:	5b                   	pop    %ebx
f0102fa0:	5e                   	pop    %esi
f0102fa1:	5f                   	pop    %edi
f0102fa2:	5d                   	pop    %ebp
f0102fa3:	c3                   	ret    
f0102fa4:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102fa7:	eb c4                	jmp    f0102f6d <printnum+0x73>

f0102fa9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102fa9:	55                   	push   %ebp
f0102faa:	89 e5                	mov    %esp,%ebp
f0102fac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102faf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102fb3:	8b 10                	mov    (%eax),%edx
f0102fb5:	3b 50 04             	cmp    0x4(%eax),%edx
f0102fb8:	73 0a                	jae    f0102fc4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102fba:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102fbd:	89 08                	mov    %ecx,(%eax)
f0102fbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fc2:	88 02                	mov    %al,(%edx)
}
f0102fc4:	5d                   	pop    %ebp
f0102fc5:	c3                   	ret    

f0102fc6 <printfmt>:
{
f0102fc6:	55                   	push   %ebp
f0102fc7:	89 e5                	mov    %esp,%ebp
f0102fc9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102fcc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102fcf:	50                   	push   %eax
f0102fd0:	ff 75 10             	pushl  0x10(%ebp)
f0102fd3:	ff 75 0c             	pushl  0xc(%ebp)
f0102fd6:	ff 75 08             	pushl  0x8(%ebp)
f0102fd9:	e8 05 00 00 00       	call   f0102fe3 <vprintfmt>
}
f0102fde:	83 c4 10             	add    $0x10,%esp
f0102fe1:	c9                   	leave  
f0102fe2:	c3                   	ret    

f0102fe3 <vprintfmt>:
{
f0102fe3:	55                   	push   %ebp
f0102fe4:	89 e5                	mov    %esp,%ebp
f0102fe6:	57                   	push   %edi
f0102fe7:	56                   	push   %esi
f0102fe8:	53                   	push   %ebx
f0102fe9:	83 ec 2c             	sub    $0x2c,%esp
f0102fec:	8b 75 08             	mov    0x8(%ebp),%esi
f0102fef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ff2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102ff5:	e9 1f 04 00 00       	jmp    f0103419 <vprintfmt+0x436>
				color = 0x0700; 
f0102ffa:	c7 05 64 89 11 f0 00 	movl   $0x700,0xf0118964
f0103001:	07 00 00 
}
f0103004:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103007:	5b                   	pop    %ebx
f0103008:	5e                   	pop    %esi
f0103009:	5f                   	pop    %edi
f010300a:	5d                   	pop    %ebp
f010300b:	c3                   	ret    
		padc = ' ';
f010300c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0103010:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0103017:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f010301e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103025:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010302a:	8d 47 01             	lea    0x1(%edi),%eax
f010302d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103030:	0f b6 17             	movzbl (%edi),%edx
f0103033:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103036:	3c 55                	cmp    $0x55,%al
f0103038:	0f 87 5e 04 00 00    	ja     f010349c <vprintfmt+0x4b9>
f010303e:	0f b6 c0             	movzbl %al,%eax
f0103041:	ff 24 85 40 4d 10 f0 	jmp    *-0xfefb2c0(,%eax,4)
f0103048:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010304b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010304f:	eb d9                	jmp    f010302a <vprintfmt+0x47>
		switch (ch = *(unsigned char *) fmt++) {
f0103051:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0103054:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103058:	eb d0                	jmp    f010302a <vprintfmt+0x47>
		switch (ch = *(unsigned char *) fmt++) {
f010305a:	0f b6 d2             	movzbl %dl,%edx
f010305d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0103060:	b8 00 00 00 00       	mov    $0x0,%eax
f0103065:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0103068:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010306b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010306f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103072:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103075:	83 f9 09             	cmp    $0x9,%ecx
f0103078:	0f 87 9d 00 00 00    	ja     f010311b <vprintfmt+0x138>
			for (precision = 0; ; ++fmt) {
f010307e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103081:	eb e5                	jmp    f0103068 <vprintfmt+0x85>
	if (lflag >= 2)
f0103083:	83 f9 01             	cmp    $0x1,%ecx
f0103086:	7e 18                	jle    f01030a0 <vprintfmt+0xbd>
		return va_arg(*ap, long long);
f0103088:	8b 45 14             	mov    0x14(%ebp),%eax
f010308b:	8b 00                	mov    (%eax),%eax
f010308d:	8b 7d 14             	mov    0x14(%ebp),%edi
f0103090:	8d 7f 08             	lea    0x8(%edi),%edi
f0103093:	89 7d 14             	mov    %edi,0x14(%ebp)
			color = num; 
f0103096:	a3 64 89 11 f0       	mov    %eax,0xf0118964
		switch (ch = *(unsigned char *) fmt++) {
f010309b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010309e:	eb 8a                	jmp    f010302a <vprintfmt+0x47>
	else if (lflag)
f01030a0:	85 c9                	test   %ecx,%ecx
f01030a2:	75 10                	jne    f01030b4 <vprintfmt+0xd1>
		return va_arg(*ap, int);
f01030a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01030a7:	8b 00                	mov    (%eax),%eax
f01030a9:	8b 7d 14             	mov    0x14(%ebp),%edi
f01030ac:	8d 7f 04             	lea    0x4(%edi),%edi
f01030af:	89 7d 14             	mov    %edi,0x14(%ebp)
f01030b2:	eb e2                	jmp    f0103096 <vprintfmt+0xb3>
		return va_arg(*ap, long);
f01030b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01030b7:	8b 00                	mov    (%eax),%eax
f01030b9:	8b 7d 14             	mov    0x14(%ebp),%edi
f01030bc:	8d 7f 04             	lea    0x4(%edi),%edi
f01030bf:	89 7d 14             	mov    %edi,0x14(%ebp)
f01030c2:	eb d2                	jmp    f0103096 <vprintfmt+0xb3>
			precision = va_arg(ap, int);
f01030c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01030c7:	8b 00                	mov    (%eax),%eax
f01030c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01030cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01030cf:	8d 40 04             	lea    0x4(%eax),%eax
f01030d2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01030d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01030d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01030dc:	0f 89 48 ff ff ff    	jns    f010302a <vprintfmt+0x47>
				width = precision, precision = -1;
f01030e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01030e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01030e8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01030ef:	e9 36 ff ff ff       	jmp    f010302a <vprintfmt+0x47>
f01030f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030f7:	85 c0                	test   %eax,%eax
f01030f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01030fe:	0f 49 d0             	cmovns %eax,%edx
f0103101:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103104:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103107:	e9 1e ff ff ff       	jmp    f010302a <vprintfmt+0x47>
f010310c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010310f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103116:	e9 0f ff ff ff       	jmp    f010302a <vprintfmt+0x47>
f010311b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010311e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103121:	eb b5                	jmp    f01030d8 <vprintfmt+0xf5>
			lflag++;
f0103123:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103126:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103129:	e9 fc fe ff ff       	jmp    f010302a <vprintfmt+0x47>
			putch(va_arg(ap, int), putdat);
f010312e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103131:	8d 78 04             	lea    0x4(%eax),%edi
f0103134:	83 ec 08             	sub    $0x8,%esp
f0103137:	53                   	push   %ebx
f0103138:	ff 30                	pushl  (%eax)
f010313a:	ff d6                	call   *%esi
			break;
f010313c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010313f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0103142:	e9 cf 02 00 00       	jmp    f0103416 <vprintfmt+0x433>
			err = va_arg(ap, int);
f0103147:	8b 45 14             	mov    0x14(%ebp),%eax
f010314a:	8d 78 04             	lea    0x4(%eax),%edi
f010314d:	8b 00                	mov    (%eax),%eax
f010314f:	99                   	cltd   
f0103150:	31 d0                	xor    %edx,%eax
f0103152:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103154:	83 f8 07             	cmp    $0x7,%eax
f0103157:	7f 23                	jg     f010317c <vprintfmt+0x199>
f0103159:	8b 14 85 a0 4e 10 f0 	mov    -0xfefb160(,%eax,4),%edx
f0103160:	85 d2                	test   %edx,%edx
f0103162:	74 18                	je     f010317c <vprintfmt+0x199>
				printfmt(putch, putdat, "%s", p);
f0103164:	52                   	push   %edx
f0103165:	68 e8 49 10 f0       	push   $0xf01049e8
f010316a:	53                   	push   %ebx
f010316b:	56                   	push   %esi
f010316c:	e8 55 fe ff ff       	call   f0102fc6 <printfmt>
f0103171:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103174:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103177:	e9 9a 02 00 00       	jmp    f0103416 <vprintfmt+0x433>
				printfmt(putch, putdat, "error %d", err);
f010317c:	50                   	push   %eax
f010317d:	68 ce 4c 10 f0       	push   $0xf0104cce
f0103182:	53                   	push   %ebx
f0103183:	56                   	push   %esi
f0103184:	e8 3d fe ff ff       	call   f0102fc6 <printfmt>
f0103189:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010318c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010318f:	e9 82 02 00 00       	jmp    f0103416 <vprintfmt+0x433>
			if ((p = va_arg(ap, char *)) == NULL)
f0103194:	8b 45 14             	mov    0x14(%ebp),%eax
f0103197:	83 c0 04             	add    $0x4,%eax
f010319a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010319d:	8b 45 14             	mov    0x14(%ebp),%eax
f01031a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01031a2:	85 ff                	test   %edi,%edi
f01031a4:	b8 c7 4c 10 f0       	mov    $0xf0104cc7,%eax
f01031a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01031ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01031b0:	0f 8e bd 00 00 00    	jle    f0103273 <vprintfmt+0x290>
f01031b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01031ba:	75 0e                	jne    f01031ca <vprintfmt+0x1e7>
f01031bc:	89 75 08             	mov    %esi,0x8(%ebp)
f01031bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01031c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01031c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01031c8:	eb 6d                	jmp    f0103237 <vprintfmt+0x254>
				for (width -= strnlen(p, precision); width > 0; width--)
f01031ca:	83 ec 08             	sub    $0x8,%esp
f01031cd:	ff 75 d0             	pushl  -0x30(%ebp)
f01031d0:	57                   	push   %edi
f01031d1:	e8 48 04 00 00       	call   f010361e <strnlen>
f01031d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01031d9:	29 c1                	sub    %eax,%ecx
f01031db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01031de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01031e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01031e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01031e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01031eb:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01031ed:	eb 0f                	jmp    f01031fe <vprintfmt+0x21b>
					putch(padc, putdat);
f01031ef:	83 ec 08             	sub    $0x8,%esp
f01031f2:	53                   	push   %ebx
f01031f3:	ff 75 e0             	pushl  -0x20(%ebp)
f01031f6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01031f8:	83 ef 01             	sub    $0x1,%edi
f01031fb:	83 c4 10             	add    $0x10,%esp
f01031fe:	85 ff                	test   %edi,%edi
f0103200:	7f ed                	jg     f01031ef <vprintfmt+0x20c>
f0103202:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103205:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103208:	85 c9                	test   %ecx,%ecx
f010320a:	b8 00 00 00 00       	mov    $0x0,%eax
f010320f:	0f 49 c1             	cmovns %ecx,%eax
f0103212:	29 c1                	sub    %eax,%ecx
f0103214:	89 75 08             	mov    %esi,0x8(%ebp)
f0103217:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010321a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010321d:	89 cb                	mov    %ecx,%ebx
f010321f:	eb 16                	jmp    f0103237 <vprintfmt+0x254>
				if (altflag && (ch < ' ' || ch > '~'))
f0103221:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103225:	75 31                	jne    f0103258 <vprintfmt+0x275>
					putch(ch, putdat);
f0103227:	83 ec 08             	sub    $0x8,%esp
f010322a:	ff 75 0c             	pushl  0xc(%ebp)
f010322d:	50                   	push   %eax
f010322e:	ff 55 08             	call   *0x8(%ebp)
f0103231:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103234:	83 eb 01             	sub    $0x1,%ebx
f0103237:	83 c7 01             	add    $0x1,%edi
f010323a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f010323e:	0f be c2             	movsbl %dl,%eax
f0103241:	85 c0                	test   %eax,%eax
f0103243:	74 59                	je     f010329e <vprintfmt+0x2bb>
f0103245:	85 f6                	test   %esi,%esi
f0103247:	78 d8                	js     f0103221 <vprintfmt+0x23e>
f0103249:	83 ee 01             	sub    $0x1,%esi
f010324c:	79 d3                	jns    f0103221 <vprintfmt+0x23e>
f010324e:	89 df                	mov    %ebx,%edi
f0103250:	8b 75 08             	mov    0x8(%ebp),%esi
f0103253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103256:	eb 37                	jmp    f010328f <vprintfmt+0x2ac>
				if (altflag && (ch < ' ' || ch > '~'))
f0103258:	0f be d2             	movsbl %dl,%edx
f010325b:	83 ea 20             	sub    $0x20,%edx
f010325e:	83 fa 5e             	cmp    $0x5e,%edx
f0103261:	76 c4                	jbe    f0103227 <vprintfmt+0x244>
					putch('?', putdat);
f0103263:	83 ec 08             	sub    $0x8,%esp
f0103266:	ff 75 0c             	pushl  0xc(%ebp)
f0103269:	6a 3f                	push   $0x3f
f010326b:	ff 55 08             	call   *0x8(%ebp)
f010326e:	83 c4 10             	add    $0x10,%esp
f0103271:	eb c1                	jmp    f0103234 <vprintfmt+0x251>
f0103273:	89 75 08             	mov    %esi,0x8(%ebp)
f0103276:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103279:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010327c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010327f:	eb b6                	jmp    f0103237 <vprintfmt+0x254>
				putch(' ', putdat);
f0103281:	83 ec 08             	sub    $0x8,%esp
f0103284:	53                   	push   %ebx
f0103285:	6a 20                	push   $0x20
f0103287:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103289:	83 ef 01             	sub    $0x1,%edi
f010328c:	83 c4 10             	add    $0x10,%esp
f010328f:	85 ff                	test   %edi,%edi
f0103291:	7f ee                	jg     f0103281 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
f0103293:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103296:	89 45 14             	mov    %eax,0x14(%ebp)
f0103299:	e9 78 01 00 00       	jmp    f0103416 <vprintfmt+0x433>
f010329e:	89 df                	mov    %ebx,%edi
f01032a0:	8b 75 08             	mov    0x8(%ebp),%esi
f01032a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01032a6:	eb e7                	jmp    f010328f <vprintfmt+0x2ac>
	if (lflag >= 2)
f01032a8:	83 f9 01             	cmp    $0x1,%ecx
f01032ab:	7e 3f                	jle    f01032ec <vprintfmt+0x309>
		return va_arg(*ap, long long);
f01032ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01032b0:	8b 50 04             	mov    0x4(%eax),%edx
f01032b3:	8b 00                	mov    (%eax),%eax
f01032b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01032bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01032be:	8d 40 08             	lea    0x8(%eax),%eax
f01032c1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01032c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01032c8:	79 5c                	jns    f0103326 <vprintfmt+0x343>
				putch('-', putdat);
f01032ca:	83 ec 08             	sub    $0x8,%esp
f01032cd:	53                   	push   %ebx
f01032ce:	6a 2d                	push   $0x2d
f01032d0:	ff d6                	call   *%esi
				num = -(long long) num;
f01032d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01032d8:	f7 da                	neg    %edx
f01032da:	83 d1 00             	adc    $0x0,%ecx
f01032dd:	f7 d9                	neg    %ecx
f01032df:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01032e2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01032e7:	e9 10 01 00 00       	jmp    f01033fc <vprintfmt+0x419>
	else if (lflag)
f01032ec:	85 c9                	test   %ecx,%ecx
f01032ee:	75 1b                	jne    f010330b <vprintfmt+0x328>
		return va_arg(*ap, int);
f01032f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01032f3:	8b 00                	mov    (%eax),%eax
f01032f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032f8:	89 c1                	mov    %eax,%ecx
f01032fa:	c1 f9 1f             	sar    $0x1f,%ecx
f01032fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103300:	8b 45 14             	mov    0x14(%ebp),%eax
f0103303:	8d 40 04             	lea    0x4(%eax),%eax
f0103306:	89 45 14             	mov    %eax,0x14(%ebp)
f0103309:	eb b9                	jmp    f01032c4 <vprintfmt+0x2e1>
		return va_arg(*ap, long);
f010330b:	8b 45 14             	mov    0x14(%ebp),%eax
f010330e:	8b 00                	mov    (%eax),%eax
f0103310:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103313:	89 c1                	mov    %eax,%ecx
f0103315:	c1 f9 1f             	sar    $0x1f,%ecx
f0103318:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010331b:	8b 45 14             	mov    0x14(%ebp),%eax
f010331e:	8d 40 04             	lea    0x4(%eax),%eax
f0103321:	89 45 14             	mov    %eax,0x14(%ebp)
f0103324:	eb 9e                	jmp    f01032c4 <vprintfmt+0x2e1>
			num = getint(&ap, lflag);
f0103326:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103329:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010332c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103331:	e9 c6 00 00 00       	jmp    f01033fc <vprintfmt+0x419>
	if (lflag >= 2)
f0103336:	83 f9 01             	cmp    $0x1,%ecx
f0103339:	7e 18                	jle    f0103353 <vprintfmt+0x370>
		return va_arg(*ap, unsigned long long);
f010333b:	8b 45 14             	mov    0x14(%ebp),%eax
f010333e:	8b 10                	mov    (%eax),%edx
f0103340:	8b 48 04             	mov    0x4(%eax),%ecx
f0103343:	8d 40 08             	lea    0x8(%eax),%eax
f0103346:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103349:	b8 0a 00 00 00       	mov    $0xa,%eax
f010334e:	e9 a9 00 00 00       	jmp    f01033fc <vprintfmt+0x419>
	else if (lflag)
f0103353:	85 c9                	test   %ecx,%ecx
f0103355:	75 1a                	jne    f0103371 <vprintfmt+0x38e>
		return va_arg(*ap, unsigned int);
f0103357:	8b 45 14             	mov    0x14(%ebp),%eax
f010335a:	8b 10                	mov    (%eax),%edx
f010335c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103361:	8d 40 04             	lea    0x4(%eax),%eax
f0103364:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103367:	b8 0a 00 00 00       	mov    $0xa,%eax
f010336c:	e9 8b 00 00 00       	jmp    f01033fc <vprintfmt+0x419>
		return va_arg(*ap, unsigned long);
f0103371:	8b 45 14             	mov    0x14(%ebp),%eax
f0103374:	8b 10                	mov    (%eax),%edx
f0103376:	b9 00 00 00 00       	mov    $0x0,%ecx
f010337b:	8d 40 04             	lea    0x4(%eax),%eax
f010337e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103381:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103386:	eb 74                	jmp    f01033fc <vprintfmt+0x419>
	if (lflag >= 2)
f0103388:	83 f9 01             	cmp    $0x1,%ecx
f010338b:	7e 15                	jle    f01033a2 <vprintfmt+0x3bf>
		return va_arg(*ap, unsigned long long);
f010338d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103390:	8b 10                	mov    (%eax),%edx
f0103392:	8b 48 04             	mov    0x4(%eax),%ecx
f0103395:	8d 40 08             	lea    0x8(%eax),%eax
f0103398:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010339b:	b8 08 00 00 00       	mov    $0x8,%eax
f01033a0:	eb 5a                	jmp    f01033fc <vprintfmt+0x419>
	else if (lflag)
f01033a2:	85 c9                	test   %ecx,%ecx
f01033a4:	75 17                	jne    f01033bd <vprintfmt+0x3da>
		return va_arg(*ap, unsigned int);
f01033a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01033a9:	8b 10                	mov    (%eax),%edx
f01033ab:	b9 00 00 00 00       	mov    $0x0,%ecx
f01033b0:	8d 40 04             	lea    0x4(%eax),%eax
f01033b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01033b6:	b8 08 00 00 00       	mov    $0x8,%eax
f01033bb:	eb 3f                	jmp    f01033fc <vprintfmt+0x419>
		return va_arg(*ap, unsigned long);
f01033bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01033c0:	8b 10                	mov    (%eax),%edx
f01033c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01033c7:	8d 40 04             	lea    0x4(%eax),%eax
f01033ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01033cd:	b8 08 00 00 00       	mov    $0x8,%eax
f01033d2:	eb 28                	jmp    f01033fc <vprintfmt+0x419>
			putch('0', putdat);
f01033d4:	83 ec 08             	sub    $0x8,%esp
f01033d7:	53                   	push   %ebx
f01033d8:	6a 30                	push   $0x30
f01033da:	ff d6                	call   *%esi
			putch('x', putdat);
f01033dc:	83 c4 08             	add    $0x8,%esp
f01033df:	53                   	push   %ebx
f01033e0:	6a 78                	push   $0x78
f01033e2:	ff d6                	call   *%esi
			num = (unsigned long long)
f01033e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01033e7:	8b 10                	mov    (%eax),%edx
f01033e9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01033ee:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01033f1:	8d 40 04             	lea    0x4(%eax),%eax
f01033f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01033f7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01033fc:	83 ec 0c             	sub    $0xc,%esp
f01033ff:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103403:	57                   	push   %edi
f0103404:	ff 75 e0             	pushl  -0x20(%ebp)
f0103407:	50                   	push   %eax
f0103408:	51                   	push   %ecx
f0103409:	52                   	push   %edx
f010340a:	89 da                	mov    %ebx,%edx
f010340c:	89 f0                	mov    %esi,%eax
f010340e:	e8 e7 fa ff ff       	call   f0102efa <printnum>
			break;
f0103413:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103419:	83 c7 01             	add    $0x1,%edi
f010341c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103420:	83 f8 25             	cmp    $0x25,%eax
f0103423:	0f 84 e3 fb ff ff    	je     f010300c <vprintfmt+0x29>
			if (ch == '\0'){
f0103429:	85 c0                	test   %eax,%eax
f010342b:	0f 84 c9 fb ff ff    	je     f0102ffa <vprintfmt+0x17>
			putch(ch, putdat);
f0103431:	83 ec 08             	sub    $0x8,%esp
f0103434:	53                   	push   %ebx
f0103435:	50                   	push   %eax
f0103436:	ff d6                	call   *%esi
f0103438:	83 c4 10             	add    $0x10,%esp
f010343b:	eb dc                	jmp    f0103419 <vprintfmt+0x436>
	if (lflag >= 2)
f010343d:	83 f9 01             	cmp    $0x1,%ecx
f0103440:	7e 15                	jle    f0103457 <vprintfmt+0x474>
		return va_arg(*ap, unsigned long long);
f0103442:	8b 45 14             	mov    0x14(%ebp),%eax
f0103445:	8b 10                	mov    (%eax),%edx
f0103447:	8b 48 04             	mov    0x4(%eax),%ecx
f010344a:	8d 40 08             	lea    0x8(%eax),%eax
f010344d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103450:	b8 10 00 00 00       	mov    $0x10,%eax
f0103455:	eb a5                	jmp    f01033fc <vprintfmt+0x419>
	else if (lflag)
f0103457:	85 c9                	test   %ecx,%ecx
f0103459:	75 17                	jne    f0103472 <vprintfmt+0x48f>
		return va_arg(*ap, unsigned int);
f010345b:	8b 45 14             	mov    0x14(%ebp),%eax
f010345e:	8b 10                	mov    (%eax),%edx
f0103460:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103465:	8d 40 04             	lea    0x4(%eax),%eax
f0103468:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010346b:	b8 10 00 00 00       	mov    $0x10,%eax
f0103470:	eb 8a                	jmp    f01033fc <vprintfmt+0x419>
		return va_arg(*ap, unsigned long);
f0103472:	8b 45 14             	mov    0x14(%ebp),%eax
f0103475:	8b 10                	mov    (%eax),%edx
f0103477:	b9 00 00 00 00       	mov    $0x0,%ecx
f010347c:	8d 40 04             	lea    0x4(%eax),%eax
f010347f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103482:	b8 10 00 00 00       	mov    $0x10,%eax
f0103487:	e9 70 ff ff ff       	jmp    f01033fc <vprintfmt+0x419>
			putch(ch, putdat);
f010348c:	83 ec 08             	sub    $0x8,%esp
f010348f:	53                   	push   %ebx
f0103490:	6a 25                	push   $0x25
f0103492:	ff d6                	call   *%esi
			break;
f0103494:	83 c4 10             	add    $0x10,%esp
f0103497:	e9 7a ff ff ff       	jmp    f0103416 <vprintfmt+0x433>
			putch('%', putdat);
f010349c:	83 ec 08             	sub    $0x8,%esp
f010349f:	53                   	push   %ebx
f01034a0:	6a 25                	push   $0x25
f01034a2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01034a4:	83 c4 10             	add    $0x10,%esp
f01034a7:	89 f8                	mov    %edi,%eax
f01034a9:	eb 03                	jmp    f01034ae <vprintfmt+0x4cb>
f01034ab:	83 e8 01             	sub    $0x1,%eax
f01034ae:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01034b2:	75 f7                	jne    f01034ab <vprintfmt+0x4c8>
f01034b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01034b7:	e9 5a ff ff ff       	jmp    f0103416 <vprintfmt+0x433>

f01034bc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01034bc:	55                   	push   %ebp
f01034bd:	89 e5                	mov    %esp,%ebp
f01034bf:	83 ec 18             	sub    $0x18,%esp
f01034c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01034c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01034cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01034cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01034d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01034d9:	85 c0                	test   %eax,%eax
f01034db:	74 26                	je     f0103503 <vsnprintf+0x47>
f01034dd:	85 d2                	test   %edx,%edx
f01034df:	7e 22                	jle    f0103503 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01034e1:	ff 75 14             	pushl  0x14(%ebp)
f01034e4:	ff 75 10             	pushl  0x10(%ebp)
f01034e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01034ea:	50                   	push   %eax
f01034eb:	68 a9 2f 10 f0       	push   $0xf0102fa9
f01034f0:	e8 ee fa ff ff       	call   f0102fe3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01034f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01034f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01034fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034fe:	83 c4 10             	add    $0x10,%esp
}
f0103501:	c9                   	leave  
f0103502:	c3                   	ret    
		return -E_INVAL;
f0103503:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103508:	eb f7                	jmp    f0103501 <vsnprintf+0x45>

f010350a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010350a:	55                   	push   %ebp
f010350b:	89 e5                	mov    %esp,%ebp
f010350d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103510:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103513:	50                   	push   %eax
f0103514:	ff 75 10             	pushl  0x10(%ebp)
f0103517:	ff 75 0c             	pushl  0xc(%ebp)
f010351a:	ff 75 08             	pushl  0x8(%ebp)
f010351d:	e8 9a ff ff ff       	call   f01034bc <vsnprintf>
	va_end(ap);

	return rc;
}
f0103522:	c9                   	leave  
f0103523:	c3                   	ret    

f0103524 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103524:	55                   	push   %ebp
f0103525:	89 e5                	mov    %esp,%ebp
f0103527:	57                   	push   %edi
f0103528:	56                   	push   %esi
f0103529:	53                   	push   %ebx
f010352a:	83 ec 0c             	sub    $0xc,%esp
f010352d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103530:	85 c0                	test   %eax,%eax
f0103532:	74 11                	je     f0103545 <readline+0x21>
		cprintf("%s", prompt);
f0103534:	83 ec 08             	sub    $0x8,%esp
f0103537:	50                   	push   %eax
f0103538:	68 e8 49 10 f0       	push   $0xf01049e8
f010353d:	e8 9b f6 ff ff       	call   f0102bdd <cprintf>
f0103542:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103545:	83 ec 0c             	sub    $0xc,%esp
f0103548:	6a 00                	push   $0x0
f010354a:	e8 f7 d0 ff ff       	call   f0100646 <iscons>
f010354f:	89 c7                	mov    %eax,%edi
f0103551:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103554:	be 00 00 00 00       	mov    $0x0,%esi
f0103559:	eb 3f                	jmp    f010359a <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010355b:	83 ec 08             	sub    $0x8,%esp
f010355e:	50                   	push   %eax
f010355f:	68 c0 4e 10 f0       	push   $0xf0104ec0
f0103564:	e8 74 f6 ff ff       	call   f0102bdd <cprintf>
			return NULL;
f0103569:	83 c4 10             	add    $0x10,%esp
f010356c:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103571:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103574:	5b                   	pop    %ebx
f0103575:	5e                   	pop    %esi
f0103576:	5f                   	pop    %edi
f0103577:	5d                   	pop    %ebp
f0103578:	c3                   	ret    
			if (echoing)
f0103579:	85 ff                	test   %edi,%edi
f010357b:	75 05                	jne    f0103582 <readline+0x5e>
			i--;
f010357d:	83 ee 01             	sub    $0x1,%esi
f0103580:	eb 18                	jmp    f010359a <readline+0x76>
				cputchar('\b');
f0103582:	83 ec 0c             	sub    $0xc,%esp
f0103585:	6a 08                	push   $0x8
f0103587:	e8 99 d0 ff ff       	call   f0100625 <cputchar>
f010358c:	83 c4 10             	add    $0x10,%esp
f010358f:	eb ec                	jmp    f010357d <readline+0x59>
			buf[i++] = c;
f0103591:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f0103597:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f010359a:	e8 96 d0 ff ff       	call   f0100635 <getchar>
f010359f:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01035a1:	85 c0                	test   %eax,%eax
f01035a3:	78 b6                	js     f010355b <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01035a5:	83 f8 08             	cmp    $0x8,%eax
f01035a8:	0f 94 c2             	sete   %dl
f01035ab:	83 f8 7f             	cmp    $0x7f,%eax
f01035ae:	0f 94 c0             	sete   %al
f01035b1:	08 c2                	or     %al,%dl
f01035b3:	74 04                	je     f01035b9 <readline+0x95>
f01035b5:	85 f6                	test   %esi,%esi
f01035b7:	7f c0                	jg     f0103579 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01035b9:	83 fb 1f             	cmp    $0x1f,%ebx
f01035bc:	7e 1a                	jle    f01035d8 <readline+0xb4>
f01035be:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01035c4:	7f 12                	jg     f01035d8 <readline+0xb4>
			if (echoing)
f01035c6:	85 ff                	test   %edi,%edi
f01035c8:	74 c7                	je     f0103591 <readline+0x6d>
				cputchar(c);
f01035ca:	83 ec 0c             	sub    $0xc,%esp
f01035cd:	53                   	push   %ebx
f01035ce:	e8 52 d0 ff ff       	call   f0100625 <cputchar>
f01035d3:	83 c4 10             	add    $0x10,%esp
f01035d6:	eb b9                	jmp    f0103591 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01035d8:	83 fb 0a             	cmp    $0xa,%ebx
f01035db:	74 05                	je     f01035e2 <readline+0xbe>
f01035dd:	83 fb 0d             	cmp    $0xd,%ebx
f01035e0:	75 b8                	jne    f010359a <readline+0x76>
			if (echoing)
f01035e2:	85 ff                	test   %edi,%edi
f01035e4:	75 11                	jne    f01035f7 <readline+0xd3>
			buf[i] = 0;
f01035e6:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f01035ed:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f01035f2:	e9 7a ff ff ff       	jmp    f0103571 <readline+0x4d>
				cputchar('\n');
f01035f7:	83 ec 0c             	sub    $0xc,%esp
f01035fa:	6a 0a                	push   $0xa
f01035fc:	e8 24 d0 ff ff       	call   f0100625 <cputchar>
f0103601:	83 c4 10             	add    $0x10,%esp
f0103604:	eb e0                	jmp    f01035e6 <readline+0xc2>

f0103606 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103606:	55                   	push   %ebp
f0103607:	89 e5                	mov    %esp,%ebp
f0103609:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010360c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103611:	eb 03                	jmp    f0103616 <strlen+0x10>
		n++;
f0103613:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103616:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010361a:	75 f7                	jne    f0103613 <strlen+0xd>
	return n;
}
f010361c:	5d                   	pop    %ebp
f010361d:	c3                   	ret    

f010361e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010361e:	55                   	push   %ebp
f010361f:	89 e5                	mov    %esp,%ebp
f0103621:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103624:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103627:	b8 00 00 00 00       	mov    $0x0,%eax
f010362c:	eb 03                	jmp    f0103631 <strnlen+0x13>
		n++;
f010362e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103631:	39 d0                	cmp    %edx,%eax
f0103633:	74 06                	je     f010363b <strnlen+0x1d>
f0103635:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103639:	75 f3                	jne    f010362e <strnlen+0x10>
	return n;
}
f010363b:	5d                   	pop    %ebp
f010363c:	c3                   	ret    

f010363d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010363d:	55                   	push   %ebp
f010363e:	89 e5                	mov    %esp,%ebp
f0103640:	53                   	push   %ebx
f0103641:	8b 45 08             	mov    0x8(%ebp),%eax
f0103644:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103647:	89 c2                	mov    %eax,%edx
f0103649:	83 c1 01             	add    $0x1,%ecx
f010364c:	83 c2 01             	add    $0x1,%edx
f010364f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103653:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103656:	84 db                	test   %bl,%bl
f0103658:	75 ef                	jne    f0103649 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010365a:	5b                   	pop    %ebx
f010365b:	5d                   	pop    %ebp
f010365c:	c3                   	ret    

f010365d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010365d:	55                   	push   %ebp
f010365e:	89 e5                	mov    %esp,%ebp
f0103660:	53                   	push   %ebx
f0103661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103664:	53                   	push   %ebx
f0103665:	e8 9c ff ff ff       	call   f0103606 <strlen>
f010366a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010366d:	ff 75 0c             	pushl  0xc(%ebp)
f0103670:	01 d8                	add    %ebx,%eax
f0103672:	50                   	push   %eax
f0103673:	e8 c5 ff ff ff       	call   f010363d <strcpy>
	return dst;
}
f0103678:	89 d8                	mov    %ebx,%eax
f010367a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010367d:	c9                   	leave  
f010367e:	c3                   	ret    

f010367f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010367f:	55                   	push   %ebp
f0103680:	89 e5                	mov    %esp,%ebp
f0103682:	56                   	push   %esi
f0103683:	53                   	push   %ebx
f0103684:	8b 75 08             	mov    0x8(%ebp),%esi
f0103687:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010368a:	89 f3                	mov    %esi,%ebx
f010368c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010368f:	89 f2                	mov    %esi,%edx
f0103691:	eb 0f                	jmp    f01036a2 <strncpy+0x23>
		*dst++ = *src;
f0103693:	83 c2 01             	add    $0x1,%edx
f0103696:	0f b6 01             	movzbl (%ecx),%eax
f0103699:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010369c:	80 39 01             	cmpb   $0x1,(%ecx)
f010369f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01036a2:	39 da                	cmp    %ebx,%edx
f01036a4:	75 ed                	jne    f0103693 <strncpy+0x14>
	}
	return ret;
}
f01036a6:	89 f0                	mov    %esi,%eax
f01036a8:	5b                   	pop    %ebx
f01036a9:	5e                   	pop    %esi
f01036aa:	5d                   	pop    %ebp
f01036ab:	c3                   	ret    

f01036ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01036ac:	55                   	push   %ebp
f01036ad:	89 e5                	mov    %esp,%ebp
f01036af:	56                   	push   %esi
f01036b0:	53                   	push   %ebx
f01036b1:	8b 75 08             	mov    0x8(%ebp),%esi
f01036b4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01036b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01036ba:	89 f0                	mov    %esi,%eax
f01036bc:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01036c0:	85 c9                	test   %ecx,%ecx
f01036c2:	75 0b                	jne    f01036cf <strlcpy+0x23>
f01036c4:	eb 17                	jmp    f01036dd <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01036c6:	83 c2 01             	add    $0x1,%edx
f01036c9:	83 c0 01             	add    $0x1,%eax
f01036cc:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01036cf:	39 d8                	cmp    %ebx,%eax
f01036d1:	74 07                	je     f01036da <strlcpy+0x2e>
f01036d3:	0f b6 0a             	movzbl (%edx),%ecx
f01036d6:	84 c9                	test   %cl,%cl
f01036d8:	75 ec                	jne    f01036c6 <strlcpy+0x1a>
		*dst = '\0';
f01036da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01036dd:	29 f0                	sub    %esi,%eax
}
f01036df:	5b                   	pop    %ebx
f01036e0:	5e                   	pop    %esi
f01036e1:	5d                   	pop    %ebp
f01036e2:	c3                   	ret    

f01036e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01036e3:	55                   	push   %ebp
f01036e4:	89 e5                	mov    %esp,%ebp
f01036e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01036ec:	eb 06                	jmp    f01036f4 <strcmp+0x11>
		p++, q++;
f01036ee:	83 c1 01             	add    $0x1,%ecx
f01036f1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01036f4:	0f b6 01             	movzbl (%ecx),%eax
f01036f7:	84 c0                	test   %al,%al
f01036f9:	74 04                	je     f01036ff <strcmp+0x1c>
f01036fb:	3a 02                	cmp    (%edx),%al
f01036fd:	74 ef                	je     f01036ee <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01036ff:	0f b6 c0             	movzbl %al,%eax
f0103702:	0f b6 12             	movzbl (%edx),%edx
f0103705:	29 d0                	sub    %edx,%eax
}
f0103707:	5d                   	pop    %ebp
f0103708:	c3                   	ret    

f0103709 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103709:	55                   	push   %ebp
f010370a:	89 e5                	mov    %esp,%ebp
f010370c:	53                   	push   %ebx
f010370d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103710:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103713:	89 c3                	mov    %eax,%ebx
f0103715:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103718:	eb 06                	jmp    f0103720 <strncmp+0x17>
		n--, p++, q++;
f010371a:	83 c0 01             	add    $0x1,%eax
f010371d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103720:	39 d8                	cmp    %ebx,%eax
f0103722:	74 16                	je     f010373a <strncmp+0x31>
f0103724:	0f b6 08             	movzbl (%eax),%ecx
f0103727:	84 c9                	test   %cl,%cl
f0103729:	74 04                	je     f010372f <strncmp+0x26>
f010372b:	3a 0a                	cmp    (%edx),%cl
f010372d:	74 eb                	je     f010371a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010372f:	0f b6 00             	movzbl (%eax),%eax
f0103732:	0f b6 12             	movzbl (%edx),%edx
f0103735:	29 d0                	sub    %edx,%eax
}
f0103737:	5b                   	pop    %ebx
f0103738:	5d                   	pop    %ebp
f0103739:	c3                   	ret    
		return 0;
f010373a:	b8 00 00 00 00       	mov    $0x0,%eax
f010373f:	eb f6                	jmp    f0103737 <strncmp+0x2e>

f0103741 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103741:	55                   	push   %ebp
f0103742:	89 e5                	mov    %esp,%ebp
f0103744:	8b 45 08             	mov    0x8(%ebp),%eax
f0103747:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010374b:	0f b6 10             	movzbl (%eax),%edx
f010374e:	84 d2                	test   %dl,%dl
f0103750:	74 09                	je     f010375b <strchr+0x1a>
		if (*s == c)
f0103752:	38 ca                	cmp    %cl,%dl
f0103754:	74 0a                	je     f0103760 <strchr+0x1f>
	for (; *s; s++)
f0103756:	83 c0 01             	add    $0x1,%eax
f0103759:	eb f0                	jmp    f010374b <strchr+0xa>
			return (char *) s;
	return 0;
f010375b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103760:	5d                   	pop    %ebp
f0103761:	c3                   	ret    

f0103762 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103762:	55                   	push   %ebp
f0103763:	89 e5                	mov    %esp,%ebp
f0103765:	8b 45 08             	mov    0x8(%ebp),%eax
f0103768:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010376c:	eb 03                	jmp    f0103771 <strfind+0xf>
f010376e:	83 c0 01             	add    $0x1,%eax
f0103771:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103774:	38 ca                	cmp    %cl,%dl
f0103776:	74 04                	je     f010377c <strfind+0x1a>
f0103778:	84 d2                	test   %dl,%dl
f010377a:	75 f2                	jne    f010376e <strfind+0xc>
			break;
	return (char *) s;
}
f010377c:	5d                   	pop    %ebp
f010377d:	c3                   	ret    

f010377e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010377e:	55                   	push   %ebp
f010377f:	89 e5                	mov    %esp,%ebp
f0103781:	57                   	push   %edi
f0103782:	56                   	push   %esi
f0103783:	53                   	push   %ebx
f0103784:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103787:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010378a:	85 c9                	test   %ecx,%ecx
f010378c:	74 13                	je     f01037a1 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010378e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103794:	75 05                	jne    f010379b <memset+0x1d>
f0103796:	f6 c1 03             	test   $0x3,%cl
f0103799:	74 0d                	je     f01037a8 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010379b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010379e:	fc                   	cld    
f010379f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01037a1:	89 f8                	mov    %edi,%eax
f01037a3:	5b                   	pop    %ebx
f01037a4:	5e                   	pop    %esi
f01037a5:	5f                   	pop    %edi
f01037a6:	5d                   	pop    %ebp
f01037a7:	c3                   	ret    
		c &= 0xFF;
f01037a8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01037ac:	89 d3                	mov    %edx,%ebx
f01037ae:	c1 e3 08             	shl    $0x8,%ebx
f01037b1:	89 d0                	mov    %edx,%eax
f01037b3:	c1 e0 18             	shl    $0x18,%eax
f01037b6:	89 d6                	mov    %edx,%esi
f01037b8:	c1 e6 10             	shl    $0x10,%esi
f01037bb:	09 f0                	or     %esi,%eax
f01037bd:	09 c2                	or     %eax,%edx
f01037bf:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01037c1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01037c4:	89 d0                	mov    %edx,%eax
f01037c6:	fc                   	cld    
f01037c7:	f3 ab                	rep stos %eax,%es:(%edi)
f01037c9:	eb d6                	jmp    f01037a1 <memset+0x23>

f01037cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01037cb:	55                   	push   %ebp
f01037cc:	89 e5                	mov    %esp,%ebp
f01037ce:	57                   	push   %edi
f01037cf:	56                   	push   %esi
f01037d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01037d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01037d9:	39 c6                	cmp    %eax,%esi
f01037db:	73 35                	jae    f0103812 <memmove+0x47>
f01037dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01037e0:	39 c2                	cmp    %eax,%edx
f01037e2:	76 2e                	jbe    f0103812 <memmove+0x47>
		s += n;
		d += n;
f01037e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037e7:	89 d6                	mov    %edx,%esi
f01037e9:	09 fe                	or     %edi,%esi
f01037eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01037f1:	74 0c                	je     f01037ff <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01037f3:	83 ef 01             	sub    $0x1,%edi
f01037f6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01037f9:	fd                   	std    
f01037fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01037fc:	fc                   	cld    
f01037fd:	eb 21                	jmp    f0103820 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037ff:	f6 c1 03             	test   $0x3,%cl
f0103802:	75 ef                	jne    f01037f3 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103804:	83 ef 04             	sub    $0x4,%edi
f0103807:	8d 72 fc             	lea    -0x4(%edx),%esi
f010380a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010380d:	fd                   	std    
f010380e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103810:	eb ea                	jmp    f01037fc <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103812:	89 f2                	mov    %esi,%edx
f0103814:	09 c2                	or     %eax,%edx
f0103816:	f6 c2 03             	test   $0x3,%dl
f0103819:	74 09                	je     f0103824 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010381b:	89 c7                	mov    %eax,%edi
f010381d:	fc                   	cld    
f010381e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103820:	5e                   	pop    %esi
f0103821:	5f                   	pop    %edi
f0103822:	5d                   	pop    %ebp
f0103823:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103824:	f6 c1 03             	test   $0x3,%cl
f0103827:	75 f2                	jne    f010381b <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103829:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010382c:	89 c7                	mov    %eax,%edi
f010382e:	fc                   	cld    
f010382f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103831:	eb ed                	jmp    f0103820 <memmove+0x55>

f0103833 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103833:	55                   	push   %ebp
f0103834:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103836:	ff 75 10             	pushl  0x10(%ebp)
f0103839:	ff 75 0c             	pushl  0xc(%ebp)
f010383c:	ff 75 08             	pushl  0x8(%ebp)
f010383f:	e8 87 ff ff ff       	call   f01037cb <memmove>
}
f0103844:	c9                   	leave  
f0103845:	c3                   	ret    

f0103846 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103846:	55                   	push   %ebp
f0103847:	89 e5                	mov    %esp,%ebp
f0103849:	56                   	push   %esi
f010384a:	53                   	push   %ebx
f010384b:	8b 45 08             	mov    0x8(%ebp),%eax
f010384e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103851:	89 c6                	mov    %eax,%esi
f0103853:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103856:	39 f0                	cmp    %esi,%eax
f0103858:	74 1c                	je     f0103876 <memcmp+0x30>
		if (*s1 != *s2)
f010385a:	0f b6 08             	movzbl (%eax),%ecx
f010385d:	0f b6 1a             	movzbl (%edx),%ebx
f0103860:	38 d9                	cmp    %bl,%cl
f0103862:	75 08                	jne    f010386c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103864:	83 c0 01             	add    $0x1,%eax
f0103867:	83 c2 01             	add    $0x1,%edx
f010386a:	eb ea                	jmp    f0103856 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010386c:	0f b6 c1             	movzbl %cl,%eax
f010386f:	0f b6 db             	movzbl %bl,%ebx
f0103872:	29 d8                	sub    %ebx,%eax
f0103874:	eb 05                	jmp    f010387b <memcmp+0x35>
	}

	return 0;
f0103876:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010387b:	5b                   	pop    %ebx
f010387c:	5e                   	pop    %esi
f010387d:	5d                   	pop    %ebp
f010387e:	c3                   	ret    

f010387f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010387f:	55                   	push   %ebp
f0103880:	89 e5                	mov    %esp,%ebp
f0103882:	8b 45 08             	mov    0x8(%ebp),%eax
f0103885:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103888:	89 c2                	mov    %eax,%edx
f010388a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010388d:	39 d0                	cmp    %edx,%eax
f010388f:	73 09                	jae    f010389a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103891:	38 08                	cmp    %cl,(%eax)
f0103893:	74 05                	je     f010389a <memfind+0x1b>
	for (; s < ends; s++)
f0103895:	83 c0 01             	add    $0x1,%eax
f0103898:	eb f3                	jmp    f010388d <memfind+0xe>
			break;
	return (void *) s;
}
f010389a:	5d                   	pop    %ebp
f010389b:	c3                   	ret    

f010389c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010389c:	55                   	push   %ebp
f010389d:	89 e5                	mov    %esp,%ebp
f010389f:	57                   	push   %edi
f01038a0:	56                   	push   %esi
f01038a1:	53                   	push   %ebx
f01038a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01038a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01038a8:	eb 03                	jmp    f01038ad <strtol+0x11>
		s++;
f01038aa:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01038ad:	0f b6 01             	movzbl (%ecx),%eax
f01038b0:	3c 20                	cmp    $0x20,%al
f01038b2:	74 f6                	je     f01038aa <strtol+0xe>
f01038b4:	3c 09                	cmp    $0x9,%al
f01038b6:	74 f2                	je     f01038aa <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01038b8:	3c 2b                	cmp    $0x2b,%al
f01038ba:	74 2e                	je     f01038ea <strtol+0x4e>
	int neg = 0;
f01038bc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01038c1:	3c 2d                	cmp    $0x2d,%al
f01038c3:	74 2f                	je     f01038f4 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01038c5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01038cb:	75 05                	jne    f01038d2 <strtol+0x36>
f01038cd:	80 39 30             	cmpb   $0x30,(%ecx)
f01038d0:	74 2c                	je     f01038fe <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01038d2:	85 db                	test   %ebx,%ebx
f01038d4:	75 0a                	jne    f01038e0 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01038d6:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01038db:	80 39 30             	cmpb   $0x30,(%ecx)
f01038de:	74 28                	je     f0103908 <strtol+0x6c>
		base = 10;
f01038e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e5:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01038e8:	eb 50                	jmp    f010393a <strtol+0x9e>
		s++;
f01038ea:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01038ed:	bf 00 00 00 00       	mov    $0x0,%edi
f01038f2:	eb d1                	jmp    f01038c5 <strtol+0x29>
		s++, neg = 1;
f01038f4:	83 c1 01             	add    $0x1,%ecx
f01038f7:	bf 01 00 00 00       	mov    $0x1,%edi
f01038fc:	eb c7                	jmp    f01038c5 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01038fe:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103902:	74 0e                	je     f0103912 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103904:	85 db                	test   %ebx,%ebx
f0103906:	75 d8                	jne    f01038e0 <strtol+0x44>
		s++, base = 8;
f0103908:	83 c1 01             	add    $0x1,%ecx
f010390b:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103910:	eb ce                	jmp    f01038e0 <strtol+0x44>
		s += 2, base = 16;
f0103912:	83 c1 02             	add    $0x2,%ecx
f0103915:	bb 10 00 00 00       	mov    $0x10,%ebx
f010391a:	eb c4                	jmp    f01038e0 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010391c:	8d 72 9f             	lea    -0x61(%edx),%esi
f010391f:	89 f3                	mov    %esi,%ebx
f0103921:	80 fb 19             	cmp    $0x19,%bl
f0103924:	77 29                	ja     f010394f <strtol+0xb3>
			dig = *s - 'a' + 10;
f0103926:	0f be d2             	movsbl %dl,%edx
f0103929:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010392c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010392f:	7d 30                	jge    f0103961 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0103931:	83 c1 01             	add    $0x1,%ecx
f0103934:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103938:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010393a:	0f b6 11             	movzbl (%ecx),%edx
f010393d:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103940:	89 f3                	mov    %esi,%ebx
f0103942:	80 fb 09             	cmp    $0x9,%bl
f0103945:	77 d5                	ja     f010391c <strtol+0x80>
			dig = *s - '0';
f0103947:	0f be d2             	movsbl %dl,%edx
f010394a:	83 ea 30             	sub    $0x30,%edx
f010394d:	eb dd                	jmp    f010392c <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010394f:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103952:	89 f3                	mov    %esi,%ebx
f0103954:	80 fb 19             	cmp    $0x19,%bl
f0103957:	77 08                	ja     f0103961 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0103959:	0f be d2             	movsbl %dl,%edx
f010395c:	83 ea 37             	sub    $0x37,%edx
f010395f:	eb cb                	jmp    f010392c <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103961:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103965:	74 05                	je     f010396c <strtol+0xd0>
		*endptr = (char *) s;
f0103967:	8b 75 0c             	mov    0xc(%ebp),%esi
f010396a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010396c:	89 c2                	mov    %eax,%edx
f010396e:	f7 da                	neg    %edx
f0103970:	85 ff                	test   %edi,%edi
f0103972:	0f 45 c2             	cmovne %edx,%eax
}
f0103975:	5b                   	pop    %ebx
f0103976:	5e                   	pop    %esi
f0103977:	5f                   	pop    %edi
f0103978:	5d                   	pop    %ebp
f0103979:	c3                   	ret    
f010397a:	66 90                	xchg   %ax,%ax
f010397c:	66 90                	xchg   %ax,%ax
f010397e:	66 90                	xchg   %ax,%ax

f0103980 <__udivdi3>:
f0103980:	55                   	push   %ebp
f0103981:	57                   	push   %edi
f0103982:	56                   	push   %esi
f0103983:	53                   	push   %ebx
f0103984:	83 ec 1c             	sub    $0x1c,%esp
f0103987:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010398b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010398f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103993:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103997:	85 d2                	test   %edx,%edx
f0103999:	75 35                	jne    f01039d0 <__udivdi3+0x50>
f010399b:	39 f3                	cmp    %esi,%ebx
f010399d:	0f 87 bd 00 00 00    	ja     f0103a60 <__udivdi3+0xe0>
f01039a3:	85 db                	test   %ebx,%ebx
f01039a5:	89 d9                	mov    %ebx,%ecx
f01039a7:	75 0b                	jne    f01039b4 <__udivdi3+0x34>
f01039a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01039ae:	31 d2                	xor    %edx,%edx
f01039b0:	f7 f3                	div    %ebx
f01039b2:	89 c1                	mov    %eax,%ecx
f01039b4:	31 d2                	xor    %edx,%edx
f01039b6:	89 f0                	mov    %esi,%eax
f01039b8:	f7 f1                	div    %ecx
f01039ba:	89 c6                	mov    %eax,%esi
f01039bc:	89 e8                	mov    %ebp,%eax
f01039be:	89 f7                	mov    %esi,%edi
f01039c0:	f7 f1                	div    %ecx
f01039c2:	89 fa                	mov    %edi,%edx
f01039c4:	83 c4 1c             	add    $0x1c,%esp
f01039c7:	5b                   	pop    %ebx
f01039c8:	5e                   	pop    %esi
f01039c9:	5f                   	pop    %edi
f01039ca:	5d                   	pop    %ebp
f01039cb:	c3                   	ret    
f01039cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01039d0:	39 f2                	cmp    %esi,%edx
f01039d2:	77 7c                	ja     f0103a50 <__udivdi3+0xd0>
f01039d4:	0f bd fa             	bsr    %edx,%edi
f01039d7:	83 f7 1f             	xor    $0x1f,%edi
f01039da:	0f 84 98 00 00 00    	je     f0103a78 <__udivdi3+0xf8>
f01039e0:	89 f9                	mov    %edi,%ecx
f01039e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01039e7:	29 f8                	sub    %edi,%eax
f01039e9:	d3 e2                	shl    %cl,%edx
f01039eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039ef:	89 c1                	mov    %eax,%ecx
f01039f1:	89 da                	mov    %ebx,%edx
f01039f3:	d3 ea                	shr    %cl,%edx
f01039f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01039f9:	09 d1                	or     %edx,%ecx
f01039fb:	89 f2                	mov    %esi,%edx
f01039fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103a01:	89 f9                	mov    %edi,%ecx
f0103a03:	d3 e3                	shl    %cl,%ebx
f0103a05:	89 c1                	mov    %eax,%ecx
f0103a07:	d3 ea                	shr    %cl,%edx
f0103a09:	89 f9                	mov    %edi,%ecx
f0103a0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103a0f:	d3 e6                	shl    %cl,%esi
f0103a11:	89 eb                	mov    %ebp,%ebx
f0103a13:	89 c1                	mov    %eax,%ecx
f0103a15:	d3 eb                	shr    %cl,%ebx
f0103a17:	09 de                	or     %ebx,%esi
f0103a19:	89 f0                	mov    %esi,%eax
f0103a1b:	f7 74 24 08          	divl   0x8(%esp)
f0103a1f:	89 d6                	mov    %edx,%esi
f0103a21:	89 c3                	mov    %eax,%ebx
f0103a23:	f7 64 24 0c          	mull   0xc(%esp)
f0103a27:	39 d6                	cmp    %edx,%esi
f0103a29:	72 0c                	jb     f0103a37 <__udivdi3+0xb7>
f0103a2b:	89 f9                	mov    %edi,%ecx
f0103a2d:	d3 e5                	shl    %cl,%ebp
f0103a2f:	39 c5                	cmp    %eax,%ebp
f0103a31:	73 5d                	jae    f0103a90 <__udivdi3+0x110>
f0103a33:	39 d6                	cmp    %edx,%esi
f0103a35:	75 59                	jne    f0103a90 <__udivdi3+0x110>
f0103a37:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103a3a:	31 ff                	xor    %edi,%edi
f0103a3c:	89 fa                	mov    %edi,%edx
f0103a3e:	83 c4 1c             	add    $0x1c,%esp
f0103a41:	5b                   	pop    %ebx
f0103a42:	5e                   	pop    %esi
f0103a43:	5f                   	pop    %edi
f0103a44:	5d                   	pop    %ebp
f0103a45:	c3                   	ret    
f0103a46:	8d 76 00             	lea    0x0(%esi),%esi
f0103a49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0103a50:	31 ff                	xor    %edi,%edi
f0103a52:	31 c0                	xor    %eax,%eax
f0103a54:	89 fa                	mov    %edi,%edx
f0103a56:	83 c4 1c             	add    $0x1c,%esp
f0103a59:	5b                   	pop    %ebx
f0103a5a:	5e                   	pop    %esi
f0103a5b:	5f                   	pop    %edi
f0103a5c:	5d                   	pop    %ebp
f0103a5d:	c3                   	ret    
f0103a5e:	66 90                	xchg   %ax,%ax
f0103a60:	31 ff                	xor    %edi,%edi
f0103a62:	89 e8                	mov    %ebp,%eax
f0103a64:	89 f2                	mov    %esi,%edx
f0103a66:	f7 f3                	div    %ebx
f0103a68:	89 fa                	mov    %edi,%edx
f0103a6a:	83 c4 1c             	add    $0x1c,%esp
f0103a6d:	5b                   	pop    %ebx
f0103a6e:	5e                   	pop    %esi
f0103a6f:	5f                   	pop    %edi
f0103a70:	5d                   	pop    %ebp
f0103a71:	c3                   	ret    
f0103a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103a78:	39 f2                	cmp    %esi,%edx
f0103a7a:	72 06                	jb     f0103a82 <__udivdi3+0x102>
f0103a7c:	31 c0                	xor    %eax,%eax
f0103a7e:	39 eb                	cmp    %ebp,%ebx
f0103a80:	77 d2                	ja     f0103a54 <__udivdi3+0xd4>
f0103a82:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a87:	eb cb                	jmp    f0103a54 <__udivdi3+0xd4>
f0103a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103a90:	89 d8                	mov    %ebx,%eax
f0103a92:	31 ff                	xor    %edi,%edi
f0103a94:	eb be                	jmp    f0103a54 <__udivdi3+0xd4>
f0103a96:	66 90                	xchg   %ax,%ax
f0103a98:	66 90                	xchg   %ax,%ax
f0103a9a:	66 90                	xchg   %ax,%ax
f0103a9c:	66 90                	xchg   %ax,%ax
f0103a9e:	66 90                	xchg   %ax,%ax

f0103aa0 <__umoddi3>:
f0103aa0:	55                   	push   %ebp
f0103aa1:	57                   	push   %edi
f0103aa2:	56                   	push   %esi
f0103aa3:	53                   	push   %ebx
f0103aa4:	83 ec 1c             	sub    $0x1c,%esp
f0103aa7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103aab:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103aaf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103ab3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103ab7:	85 ed                	test   %ebp,%ebp
f0103ab9:	89 f0                	mov    %esi,%eax
f0103abb:	89 da                	mov    %ebx,%edx
f0103abd:	75 19                	jne    f0103ad8 <__umoddi3+0x38>
f0103abf:	39 df                	cmp    %ebx,%edi
f0103ac1:	0f 86 b1 00 00 00    	jbe    f0103b78 <__umoddi3+0xd8>
f0103ac7:	f7 f7                	div    %edi
f0103ac9:	89 d0                	mov    %edx,%eax
f0103acb:	31 d2                	xor    %edx,%edx
f0103acd:	83 c4 1c             	add    $0x1c,%esp
f0103ad0:	5b                   	pop    %ebx
f0103ad1:	5e                   	pop    %esi
f0103ad2:	5f                   	pop    %edi
f0103ad3:	5d                   	pop    %ebp
f0103ad4:	c3                   	ret    
f0103ad5:	8d 76 00             	lea    0x0(%esi),%esi
f0103ad8:	39 dd                	cmp    %ebx,%ebp
f0103ada:	77 f1                	ja     f0103acd <__umoddi3+0x2d>
f0103adc:	0f bd cd             	bsr    %ebp,%ecx
f0103adf:	83 f1 1f             	xor    $0x1f,%ecx
f0103ae2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103ae6:	0f 84 b4 00 00 00    	je     f0103ba0 <__umoddi3+0x100>
f0103aec:	b8 20 00 00 00       	mov    $0x20,%eax
f0103af1:	89 c2                	mov    %eax,%edx
f0103af3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103af7:	29 c2                	sub    %eax,%edx
f0103af9:	89 c1                	mov    %eax,%ecx
f0103afb:	89 f8                	mov    %edi,%eax
f0103afd:	d3 e5                	shl    %cl,%ebp
f0103aff:	89 d1                	mov    %edx,%ecx
f0103b01:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b05:	d3 e8                	shr    %cl,%eax
f0103b07:	09 c5                	or     %eax,%ebp
f0103b09:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103b0d:	89 c1                	mov    %eax,%ecx
f0103b0f:	d3 e7                	shl    %cl,%edi
f0103b11:	89 d1                	mov    %edx,%ecx
f0103b13:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103b17:	89 df                	mov    %ebx,%edi
f0103b19:	d3 ef                	shr    %cl,%edi
f0103b1b:	89 c1                	mov    %eax,%ecx
f0103b1d:	89 f0                	mov    %esi,%eax
f0103b1f:	d3 e3                	shl    %cl,%ebx
f0103b21:	89 d1                	mov    %edx,%ecx
f0103b23:	89 fa                	mov    %edi,%edx
f0103b25:	d3 e8                	shr    %cl,%eax
f0103b27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103b2c:	09 d8                	or     %ebx,%eax
f0103b2e:	f7 f5                	div    %ebp
f0103b30:	d3 e6                	shl    %cl,%esi
f0103b32:	89 d1                	mov    %edx,%ecx
f0103b34:	f7 64 24 08          	mull   0x8(%esp)
f0103b38:	39 d1                	cmp    %edx,%ecx
f0103b3a:	89 c3                	mov    %eax,%ebx
f0103b3c:	89 d7                	mov    %edx,%edi
f0103b3e:	72 06                	jb     f0103b46 <__umoddi3+0xa6>
f0103b40:	75 0e                	jne    f0103b50 <__umoddi3+0xb0>
f0103b42:	39 c6                	cmp    %eax,%esi
f0103b44:	73 0a                	jae    f0103b50 <__umoddi3+0xb0>
f0103b46:	2b 44 24 08          	sub    0x8(%esp),%eax
f0103b4a:	19 ea                	sbb    %ebp,%edx
f0103b4c:	89 d7                	mov    %edx,%edi
f0103b4e:	89 c3                	mov    %eax,%ebx
f0103b50:	89 ca                	mov    %ecx,%edx
f0103b52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0103b57:	29 de                	sub    %ebx,%esi
f0103b59:	19 fa                	sbb    %edi,%edx
f0103b5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0103b5f:	89 d0                	mov    %edx,%eax
f0103b61:	d3 e0                	shl    %cl,%eax
f0103b63:	89 d9                	mov    %ebx,%ecx
f0103b65:	d3 ee                	shr    %cl,%esi
f0103b67:	d3 ea                	shr    %cl,%edx
f0103b69:	09 f0                	or     %esi,%eax
f0103b6b:	83 c4 1c             	add    $0x1c,%esp
f0103b6e:	5b                   	pop    %ebx
f0103b6f:	5e                   	pop    %esi
f0103b70:	5f                   	pop    %edi
f0103b71:	5d                   	pop    %ebp
f0103b72:	c3                   	ret    
f0103b73:	90                   	nop
f0103b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103b78:	85 ff                	test   %edi,%edi
f0103b7a:	89 f9                	mov    %edi,%ecx
f0103b7c:	75 0b                	jne    f0103b89 <__umoddi3+0xe9>
f0103b7e:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b83:	31 d2                	xor    %edx,%edx
f0103b85:	f7 f7                	div    %edi
f0103b87:	89 c1                	mov    %eax,%ecx
f0103b89:	89 d8                	mov    %ebx,%eax
f0103b8b:	31 d2                	xor    %edx,%edx
f0103b8d:	f7 f1                	div    %ecx
f0103b8f:	89 f0                	mov    %esi,%eax
f0103b91:	f7 f1                	div    %ecx
f0103b93:	e9 31 ff ff ff       	jmp    f0103ac9 <__umoddi3+0x29>
f0103b98:	90                   	nop
f0103b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ba0:	39 dd                	cmp    %ebx,%ebp
f0103ba2:	72 08                	jb     f0103bac <__umoddi3+0x10c>
f0103ba4:	39 f7                	cmp    %esi,%edi
f0103ba6:	0f 87 21 ff ff ff    	ja     f0103acd <__umoddi3+0x2d>
f0103bac:	89 da                	mov    %ebx,%edx
f0103bae:	89 f0                	mov    %esi,%eax
f0103bb0:	29 f8                	sub    %edi,%eax
f0103bb2:	19 ea                	sbb    %ebp,%edx
f0103bb4:	e9 14 ff ff ff       	jmp    f0103acd <__umoddi3+0x2d>
