
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
f0100058:	e8 83 36 00 00       	call   f01036e0 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 b5 04 00 00       	call   f0100517 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 20 3b 10 f0       	push   $0xf0103b20
f010006f:	e8 cb 2a 00 00       	call   f0102b3f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 0e 12 00 00       	call   f0101287 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 ef 09 00 00       	call   f0100a75 <monitor>
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
f01000a1:	e8 cf 09 00 00       	call   f0100a75 <monitor>
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
f01000bf:	68 3b 3b 10 f0       	push   $0xf0103b3b
f01000c4:	e8 76 2a 00 00       	call   f0102b3f <cprintf>
	vcprintf(fmt, ap);
f01000c9:	83 c4 08             	add    $0x8,%esp
f01000cc:	53                   	push   %ebx
f01000cd:	56                   	push   %esi
f01000ce:	e8 46 2a 00 00       	call   f0102b19 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 7f 4b 10 f0 	movl   $0xf0104b7f,(%esp)
f01000da:	e8 60 2a 00 00       	call   f0102b3f <cprintf>
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
f01000f4:	68 53 3b 10 f0       	push   $0xf0103b53
f01000f9:	e8 41 2a 00 00       	call   f0102b3f <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	53                   	push   %ebx
f0100102:	ff 75 10             	pushl  0x10(%ebp)
f0100105:	e8 0f 2a 00 00       	call   f0102b19 <vcprintf>
	cprintf("\n");
f010010a:	c7 04 24 7f 4b 10 f0 	movl   $0xf0104b7f,(%esp)
f0100111:	e8 29 2a 00 00       	call   f0102b3f <cprintf>
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
f01001c9:	0f b6 82 c0 3c 10 f0 	movzbl -0xfefc340(%edx),%eax
f01001d0:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f01001d6:	0f b6 8a c0 3b 10 f0 	movzbl -0xfefc440(%edx),%ecx
f01001dd:	31 c8                	xor    %ecx,%eax
f01001df:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f01001e4:	89 c1                	mov    %eax,%ecx
f01001e6:	83 e1 03             	and    $0x3,%ecx
f01001e9:	8b 0c 8d a0 3b 10 f0 	mov    -0xfefc460(,%ecx,4),%ecx
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
f0100219:	68 6d 3b 10 f0       	push   $0xf0103b6d
f010021e:	e8 1c 29 00 00       	call   f0102b3f <cprintf>
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
f010025c:	0f b6 82 c0 3c 10 f0 	movzbl -0xfefc340(%edx),%eax
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
f010046c:	e8 bc 32 00 00       	call   f010372d <memmove>
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
f0100616:	68 79 3b 10 f0       	push   $0xf0103b79
f010061b:	e8 1f 25 00 00       	call   f0102b3f <cprintf>
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
f010065f:	ff b3 44 41 10 f0    	pushl  -0xfefbebc(%ebx)
f0100665:	ff b3 40 41 10 f0    	pushl  -0xfefbec0(%ebx)
f010066b:	68 c0 3d 10 f0       	push   $0xf0103dc0
f0100670:	e8 ca 24 00 00       	call   f0102b3f <cprintf>
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
f0100690:	68 c9 3d 10 f0       	push   $0xf0103dc9
f0100695:	e8 a5 24 00 00       	call   f0102b3f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010069a:	83 c4 08             	add    $0x8,%esp
f010069d:	68 0c 00 10 00       	push   $0x10000c
f01006a2:	68 70 3f 10 f0       	push   $0xf0103f70
f01006a7:	e8 93 24 00 00       	call   f0102b3f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ac:	83 c4 0c             	add    $0xc,%esp
f01006af:	68 0c 00 10 00       	push   $0x10000c
f01006b4:	68 0c 00 10 f0       	push   $0xf010000c
f01006b9:	68 98 3f 10 f0       	push   $0xf0103f98
f01006be:	e8 7c 24 00 00       	call   f0102b3f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c3:	83 c4 0c             	add    $0xc,%esp
f01006c6:	68 19 3b 10 00       	push   $0x103b19
f01006cb:	68 19 3b 10 f0       	push   $0xf0103b19
f01006d0:	68 bc 3f 10 f0       	push   $0xf0103fbc
f01006d5:	e8 65 24 00 00       	call   f0102b3f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006da:	83 c4 0c             	add    $0xc,%esp
f01006dd:	68 00 83 11 00       	push   $0x118300
f01006e2:	68 00 83 11 f0       	push   $0xf0118300
f01006e7:	68 e0 3f 10 f0       	push   $0xf0103fe0
f01006ec:	e8 4e 24 00 00       	call   f0102b3f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006f1:	83 c4 0c             	add    $0xc,%esp
f01006f4:	68 74 89 11 00       	push   $0x118974
f01006f9:	68 74 89 11 f0       	push   $0xf0118974
f01006fe:	68 04 40 10 f0       	push   $0xf0104004
f0100703:	e8 37 24 00 00       	call   f0102b3f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100708:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010070b:	b8 73 8d 11 f0       	mov    $0xf0118d73,%eax
f0100710:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100715:	c1 f8 0a             	sar    $0xa,%eax
f0100718:	50                   	push   %eax
f0100719:	68 28 40 10 f0       	push   $0xf0104028
f010071e:	e8 1c 24 00 00       	call   f0102b3f <cprintf>
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
f0100735:	68 e2 3d 10 f0       	push   $0xf0103de2
f010073a:	68 08 49 10 f0       	push   $0xf0104908
f010073f:	e8 fb 23 00 00       	call   f0102b3f <cprintf>
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
f0100754:	68 f4 3d 10 f0       	push   $0xf0103df4
f0100759:	e8 e1 23 00 00       	call   f0102b3f <cprintf>
f010075e:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100761:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100764:	83 c4 10             	add    $0x10,%esp
		for(int i = 2; i < 7; ++i){
				cprintf(" %08.x", *(ebp+i));
f0100767:	83 ec 08             	sub    $0x8,%esp
f010076a:	ff 33                	pushl  (%ebx)
f010076c:	68 0f 3e 10 f0       	push   $0xf0103e0f
f0100771:	e8 c9 23 00 00       	call   f0102b3f <cprintf>
f0100776:	83 c3 04             	add    $0x4,%ebx
		for(int i = 2; i < 7; ++i){
f0100779:	83 c4 10             	add    $0x10,%esp
f010077c:	39 fb                	cmp    %edi,%ebx
f010077e:	75 e7                	jne    f0100767 <mon_backtrace+0x3d>
		}
		cprintf("\n");
f0100780:	83 ec 0c             	sub    $0xc,%esp
f0100783:	68 7f 4b 10 f0       	push   $0xf0104b7f
f0100788:	e8 b2 23 00 00       	call   f0102b3f <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f010078d:	83 c4 08             	add    $0x8,%esp
f0100790:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100793:	50                   	push   %eax
f0100794:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100797:	57                   	push   %edi
f0100798:	e8 a6 24 00 00       	call   f0102c43 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f010079d:	83 c4 08             	add    $0x8,%esp
f01007a0:	89 f8                	mov    %edi,%eax
f01007a2:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007a5:	50                   	push   %eax
f01007a6:	ff 75 d8             	pushl  -0x28(%ebp)
f01007a9:	ff 75 dc             	pushl  -0x24(%ebp)
f01007ac:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007af:	ff 75 d0             	pushl  -0x30(%ebp)
f01007b2:	68 16 3e 10 f0       	push   $0xf0103e16
f01007b7:	e8 83 23 00 00       	call   f0102b3f <cprintf>
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
f0100815:	0f 84 93 00 00 00    	je     f01008ae <showmappings+0xa8>
		cprintf("Format: showmappings 0xBEGIN_ADRR 0xEND_ADRR\n");
		return 0;
	}
	else if(argc < 3){
f010081b:	83 f8 02             	cmp    $0x2,%eax
f010081e:	0f 8e 9c 00 00 00    	jle    f01008c0 <showmappings+0xba>
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
f0100845:	89 c6                	mov    %eax,%esi
	cprintf("BEGIN_ADDR: %x	END_ADDR: %x\n", beg, end);
f0100847:	50                   	push   %eax
f0100848:	53                   	push   %ebx
f0100849:	68 35 3e 10 f0       	push   $0xf0103e35
f010084e:	e8 ec 22 00 00       	call   f0102b3f <cprintf>
	while(beg <= end){
f0100853:	83 c4 10             	add    $0x10,%esp
f0100856:	39 f3                	cmp    %esi,%ebx
f0100858:	77 76                	ja     f01008d0 <showmappings+0xca>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*)beg, 1);
f010085a:	83 ec 04             	sub    $0x4,%esp
f010085d:	6a 01                	push   $0x1
f010085f:	53                   	push   %ebx
f0100860:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0100866:	e8 d9 07 00 00       	call   f0101044 <pgdir_walk>
f010086b:	89 c7                	mov    %eax,%edi
		if(pte == NULL)
f010086d:	83 c4 10             	add    $0x10,%esp
f0100870:	85 c0                	test   %eax,%eax
f0100872:	74 69                	je     f01008dd <showmappings+0xd7>
			panic("OOM");
		if(*pte | PTE_P){
			cprintf("page %x	", beg);
f0100874:	83 ec 08             	sub    $0x8,%esp
f0100877:	53                   	push   %ebx
f0100878:	68 65 3e 10 f0       	push   $0xf0103e65
f010087d:	e8 bd 22 00 00       	call   f0102b3f <cprintf>
			cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte&PTE_P, (*pte&PTE_W)>>1, (*pte&PTE_U)>>2);
f0100882:	8b 07                	mov    (%edi),%eax
f0100884:	89 c2                	mov    %eax,%edx
f0100886:	c1 ea 02             	shr    $0x2,%edx
f0100889:	83 e2 01             	and    $0x1,%edx
f010088c:	52                   	push   %edx
f010088d:	89 c2                	mov    %eax,%edx
f010088f:	d1 ea                	shr    %edx
f0100891:	83 e2 01             	and    $0x1,%edx
f0100894:	52                   	push   %edx
f0100895:	83 e0 01             	and    $0x1,%eax
f0100898:	50                   	push   %eax
f0100899:	68 84 40 10 f0       	push   $0xf0104084
f010089e:	e8 9c 22 00 00       	call   f0102b3f <cprintf>
		}
		else{
			cprintf("page %x	not exist", beg);
		}
		beg += PGSIZE;
f01008a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01008a9:	83 c4 20             	add    $0x20,%esp
f01008ac:	eb a8                	jmp    f0100856 <showmappings+0x50>
		cprintf("Format: showmappings 0xBEGIN_ADRR 0xEND_ADRR\n");
f01008ae:	83 ec 0c             	sub    $0xc,%esp
f01008b1:	68 54 40 10 f0       	push   $0xf0104054
f01008b6:	e8 84 22 00 00       	call   f0102b3f <cprintf>
		return 0;
f01008bb:	83 c4 10             	add    $0x10,%esp
f01008be:	eb 10                	jmp    f01008d0 <showmappings+0xca>
		cprintf("WRONG FORMAT\n");
f01008c0:	83 ec 0c             	sub    $0xc,%esp
f01008c3:	68 27 3e 10 f0       	push   $0xf0103e27
f01008c8:	e8 72 22 00 00       	call   f0102b3f <cprintf>
		return 0;	
f01008cd:	83 c4 10             	add    $0x10,%esp
	}
	return 0;
}
f01008d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d8:	5b                   	pop    %ebx
f01008d9:	5e                   	pop    %esi
f01008da:	5f                   	pop    %edi
f01008db:	5d                   	pop    %ebp
f01008dc:	c3                   	ret    
			panic("OOM");
f01008dd:	83 ec 04             	sub    $0x4,%esp
f01008e0:	68 52 3e 10 f0       	push   $0xf0103e52
f01008e5:	6a 77                	push   $0x77
f01008e7:	68 56 3e 10 f0       	push   $0xf0103e56
f01008ec:	e8 9a f7 ff ff       	call   f010008b <_panic>

f01008f1 <setm>:

int
setm(int argc, char** argv, struct Trapframe *tf){
f01008f1:	55                   	push   %ebp
f01008f2:	89 e5                	mov    %esp,%ebp
f01008f4:	57                   	push   %edi
f01008f5:	56                   	push   %esi
f01008f6:	53                   	push   %ebx
f01008f7:	83 ec 0c             	sub    $0xc,%esp
f01008fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01008fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc == 1){
f0100900:	83 f8 01             	cmp    $0x1,%eax
f0100903:	0f 84 c0 00 00 00    	je     f01009c9 <setm+0xd8>
		cprintf("Format: setm 0xADDR 0(SET)|1(CLEAN) P|W|U\n");
		return 0;
	}
	if(argc < 4){
f0100909:	83 f8 03             	cmp    $0x3,%eax
f010090c:	0f 8e c9 00 00 00    	jle    f01009db <setm+0xea>
		cprintf("WRONG FORMAT\n");
		return 0;
	}
	uint32_t addr = hex2addr(argv[1]);
f0100912:	83 ec 0c             	sub    $0xc,%esp
f0100915:	ff 73 04             	pushl  0x4(%ebx)
f0100918:	e8 b5 fe ff ff       	call   f01007d2 <hex2addr>
f010091d:	83 c4 0c             	add    $0xc,%esp
f0100920:	89 c7                	mov    %eax,%edi
	pte_t* pte = pgdir_walk(kern_pgdir, (void*)addr, 1);
f0100922:	6a 01                	push   $0x1
f0100924:	50                   	push   %eax
f0100925:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010092b:	e8 14 07 00 00       	call   f0101044 <pgdir_walk>
f0100930:	89 c6                	mov    %eax,%esi
	cprintf("address: %x before setting: ", addr);
f0100932:	83 c4 08             	add    $0x8,%esp
f0100935:	57                   	push   %edi
f0100936:	68 6e 3e 10 f0       	push   $0xf0103e6e
f010093b:	e8 ff 21 00 00       	call   f0102b3f <cprintf>
	cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte|PTE_P, *pte|PTE_W, *pte|PTE_U);
f0100940:	8b 06                	mov    (%esi),%eax
f0100942:	89 c2                	mov    %eax,%edx
f0100944:	83 ca 04             	or     $0x4,%edx
f0100947:	52                   	push   %edx
f0100948:	89 c2                	mov    %eax,%edx
f010094a:	83 ca 02             	or     $0x2,%edx
f010094d:	52                   	push   %edx
f010094e:	83 c8 01             	or     $0x1,%eax
f0100951:	50                   	push   %eax
f0100952:	68 84 40 10 f0       	push   $0xf0104084
f0100957:	e8 e3 21 00 00       	call   f0102b3f <cprintf>
	uint32_t perm = 0;
	if(argv[3][0] == 'P')
f010095c:	8b 43 0c             	mov    0xc(%ebx),%eax
f010095f:	0f b6 10             	movzbl (%eax),%edx
f0100962:	83 c4 20             	add    $0x20,%esp
		perm |= PTE_P;
f0100965:	b8 01 00 00 00       	mov    $0x1,%eax
	if(argv[3][0] == 'P')
f010096a:	80 fa 50             	cmp    $0x50,%dl
f010096d:	74 16                	je     f0100985 <setm+0x94>
	else if(argv[3][0] == 'W')
		perm |= PTE_W;
f010096f:	b8 02 00 00 00       	mov    $0x2,%eax
	else if(argv[3][0] == 'W')
f0100974:	80 fa 57             	cmp    $0x57,%dl
f0100977:	74 0c                	je     f0100985 <setm+0x94>
	else if(argv[3][0] == 'U')
		perm |= PTE_U;
f0100979:	80 fa 55             	cmp    $0x55,%dl
f010097c:	0f 94 c0             	sete   %al
f010097f:	0f b6 c0             	movzbl %al,%eax
f0100982:	c1 e0 02             	shl    $0x2,%eax
	if(argv[2][0] == '0')
f0100985:	8b 53 08             	mov    0x8(%ebx),%edx
f0100988:	80 3a 30             	cmpb   $0x30,(%edx)
f010098b:	74 60                	je     f01009ed <setm+0xfc>
		*pte &= ~perm;
	else
		*pte |= perm;
f010098d:	09 06                	or     %eax,(%esi)
	cprintf("address: %x after setting: ", addr);
f010098f:	83 ec 08             	sub    $0x8,%esp
f0100992:	57                   	push   %edi
f0100993:	68 8b 3e 10 f0       	push   $0xf0103e8b
f0100998:	e8 a2 21 00 00       	call   f0102b3f <cprintf>
	cprintf("PTE_P: %x	PTE_W: %x	PTE_U: %x\n", *pte|PTE_P, *pte|PTE_W, *pte|PTE_U);
f010099d:	8b 06                	mov    (%esi),%eax
f010099f:	89 c2                	mov    %eax,%edx
f01009a1:	83 ca 04             	or     $0x4,%edx
f01009a4:	52                   	push   %edx
f01009a5:	89 c2                	mov    %eax,%edx
f01009a7:	83 ca 02             	or     $0x2,%edx
f01009aa:	52                   	push   %edx
f01009ab:	83 c8 01             	or     $0x1,%eax
f01009ae:	50                   	push   %eax
f01009af:	68 84 40 10 f0       	push   $0xf0104084
f01009b4:	e8 86 21 00 00       	call   f0102b3f <cprintf>
	return 0;
f01009b9:	83 c4 20             	add    $0x20,%esp
}
f01009bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009c4:	5b                   	pop    %ebx
f01009c5:	5e                   	pop    %esi
f01009c6:	5f                   	pop    %edi
f01009c7:	5d                   	pop    %ebp
f01009c8:	c3                   	ret    
		cprintf("Format: setm 0xADDR 0(SET)|1(CLEAN) P|W|U\n");
f01009c9:	83 ec 0c             	sub    $0xc,%esp
f01009cc:	68 a4 40 10 f0       	push   $0xf01040a4
f01009d1:	e8 69 21 00 00       	call   f0102b3f <cprintf>
		return 0;
f01009d6:	83 c4 10             	add    $0x10,%esp
f01009d9:	eb e1                	jmp    f01009bc <setm+0xcb>
		cprintf("WRONG FORMAT\n");
f01009db:	83 ec 0c             	sub    $0xc,%esp
f01009de:	68 27 3e 10 f0       	push   $0xf0103e27
f01009e3:	e8 57 21 00 00       	call   f0102b3f <cprintf>
		return 0;
f01009e8:	83 c4 10             	add    $0x10,%esp
f01009eb:	eb cf                	jmp    f01009bc <setm+0xcb>
		*pte &= ~perm;
f01009ed:	f7 d0                	not    %eax
f01009ef:	21 06                	and    %eax,(%esi)
f01009f1:	eb 9c                	jmp    f010098f <setm+0x9e>

f01009f3 <showvm>:

int
showvm(int argc, char** argv, struct Trapframe *tf){
f01009f3:	55                   	push   %ebp
f01009f4:	89 e5                	mov    %esp,%ebp
f01009f6:	56                   	push   %esi
f01009f7:	53                   	push   %ebx
f01009f8:	8b 45 08             	mov    0x8(%ebp),%eax
	if(argc == 1){
f01009fb:	83 f8 01             	cmp    $0x1,%eax
f01009fe:	74 2b                	je     f0100a2b <showvm+0x38>
		cprintf("Format: showvm 0xADDR 0xNUM\n");
		return 0;
	}
	if(argc < 3){
f0100a00:	83 f8 02             	cmp    $0x2,%eax
f0100a03:	7e 38                	jle    f0100a3d <showvm+0x4a>
		cprintf("WRONG FORMAT\n");
		return 0;
	}
	void** addr = (void**)hex2addr(argv[1]);
f0100a05:	83 ec 0c             	sub    $0xc,%esp
f0100a08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a0b:	ff 70 04             	pushl  0x4(%eax)
f0100a0e:	e8 bf fd ff ff       	call   f01007d2 <hex2addr>
f0100a13:	83 c4 04             	add    $0x4,%esp
f0100a16:	89 c3                	mov    %eax,%ebx
	uint32_t num = hex2addr(argv[2]);
f0100a18:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a1b:	ff 70 08             	pushl  0x8(%eax)
f0100a1e:	e8 af fd ff ff       	call   f01007d2 <hex2addr>
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	8d 34 83             	lea    (%ebx,%eax,4),%esi
	for(int i = 0; i < num; i++)
f0100a29:	eb 3a                	jmp    f0100a65 <showvm+0x72>
		cprintf("Format: showvm 0xADDR 0xNUM\n");
f0100a2b:	83 ec 0c             	sub    $0xc,%esp
f0100a2e:	68 a7 3e 10 f0       	push   $0xf0103ea7
f0100a33:	e8 07 21 00 00       	call   f0102b3f <cprintf>
		return 0;
f0100a38:	83 c4 10             	add    $0x10,%esp
f0100a3b:	eb 2c                	jmp    f0100a69 <showvm+0x76>
		cprintf("WRONG FORMAT\n");
f0100a3d:	83 ec 0c             	sub    $0xc,%esp
f0100a40:	68 27 3e 10 f0       	push   $0xf0103e27
f0100a45:	e8 f5 20 00 00       	call   f0102b3f <cprintf>
		return 0;
f0100a4a:	83 c4 10             	add    $0x10,%esp
f0100a4d:	eb 1a                	jmp    f0100a69 <showvm+0x76>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100a4f:	83 ec 04             	sub    $0x4,%esp
f0100a52:	ff 33                	pushl  (%ebx)
f0100a54:	53                   	push   %ebx
f0100a55:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0100a5a:	e8 e0 20 00 00       	call   f0102b3f <cprintf>
f0100a5f:	83 c3 04             	add    $0x4,%ebx
f0100a62:	83 c4 10             	add    $0x10,%esp
	for(int i = 0; i < num; i++)
f0100a65:	39 f3                	cmp    %esi,%ebx
f0100a67:	75 e6                	jne    f0100a4f <showvm+0x5c>
	return 0;
}
f0100a69:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a71:	5b                   	pop    %ebx
f0100a72:	5e                   	pop    %esi
f0100a73:	5d                   	pop    %ebp
f0100a74:	c3                   	ret    

f0100a75 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a75:	55                   	push   %ebp
f0100a76:	89 e5                	mov    %esp,%ebp
f0100a78:	57                   	push   %edi
f0100a79:	56                   	push   %esi
f0100a7a:	53                   	push   %ebx
f0100a7b:	83 ec 58             	sub    $0x58,%esp
	char *buf;
	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a7e:	68 d0 40 10 f0       	push   $0xf01040d0
f0100a83:	e8 b7 20 00 00       	call   f0102b3f <cprintf>
	cprintf("Type help for a list of commands.\n");
f0100a88:	c7 04 24 f4 40 10 f0 	movl   $0xf01040f4,(%esp)
f0100a8f:	e8 ab 20 00 00       	call   f0102b3f <cprintf>
f0100a94:	83 c4 10             	add    $0x10,%esp
f0100a97:	eb 47                	jmp    f0100ae0 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a99:	83 ec 08             	sub    $0x8,%esp
f0100a9c:	0f be c0             	movsbl %al,%eax
f0100a9f:	50                   	push   %eax
f0100aa0:	68 d8 3e 10 f0       	push   $0xf0103ed8
f0100aa5:	e8 f9 2b 00 00       	call   f01036a3 <strchr>
f0100aaa:	83 c4 10             	add    $0x10,%esp
f0100aad:	85 c0                	test   %eax,%eax
f0100aaf:	74 0a                	je     f0100abb <monitor+0x46>
			*buf++ = 0;
f0100ab1:	c6 03 00             	movb   $0x0,(%ebx)
f0100ab4:	89 fe                	mov    %edi,%esi
f0100ab6:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100ab9:	eb 6b                	jmp    f0100b26 <monitor+0xb1>
		if (*buf == 0)
f0100abb:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100abe:	74 73                	je     f0100b33 <monitor+0xbe>
		if (argc == MAXARGS-1) {
f0100ac0:	83 ff 0f             	cmp    $0xf,%edi
f0100ac3:	74 09                	je     f0100ace <monitor+0x59>
		argv[argc++] = buf;
f0100ac5:	8d 77 01             	lea    0x1(%edi),%esi
f0100ac8:	89 5c bd a8          	mov    %ebx,-0x58(%ebp,%edi,4)
f0100acc:	eb 39                	jmp    f0100b07 <monitor+0x92>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ace:	83 ec 08             	sub    $0x8,%esp
f0100ad1:	6a 10                	push   $0x10
f0100ad3:	68 dd 3e 10 f0       	push   $0xf0103edd
f0100ad8:	e8 62 20 00 00       	call   f0102b3f <cprintf>
f0100add:	83 c4 10             	add    $0x10,%esp
	while (1) {
		buf = readline("K> ");
f0100ae0:	83 ec 0c             	sub    $0xc,%esp
f0100ae3:	68 d4 3e 10 f0       	push   $0xf0103ed4
f0100ae8:	e8 99 29 00 00       	call   f0103486 <readline>
f0100aed:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100aef:	83 c4 10             	add    $0x10,%esp
f0100af2:	85 c0                	test   %eax,%eax
f0100af4:	74 ea                	je     f0100ae0 <monitor+0x6b>
	argv[argc] = 0;
f0100af6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100afd:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b02:	eb 24                	jmp    f0100b28 <monitor+0xb3>
			buf++;
f0100b04:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b07:	0f b6 03             	movzbl (%ebx),%eax
f0100b0a:	84 c0                	test   %al,%al
f0100b0c:	74 18                	je     f0100b26 <monitor+0xb1>
f0100b0e:	83 ec 08             	sub    $0x8,%esp
f0100b11:	0f be c0             	movsbl %al,%eax
f0100b14:	50                   	push   %eax
f0100b15:	68 d8 3e 10 f0       	push   $0xf0103ed8
f0100b1a:	e8 84 2b 00 00       	call   f01036a3 <strchr>
f0100b1f:	83 c4 10             	add    $0x10,%esp
f0100b22:	85 c0                	test   %eax,%eax
f0100b24:	74 de                	je     f0100b04 <monitor+0x8f>
			*buf++ = 0;
f0100b26:	89 f7                	mov    %esi,%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100b28:	0f b6 03             	movzbl (%ebx),%eax
f0100b2b:	84 c0                	test   %al,%al
f0100b2d:	0f 85 66 ff ff ff    	jne    f0100a99 <monitor+0x24>
	argv[argc] = 0;
f0100b33:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100b3a:	00 
	if (argc == 0)
f0100b3b:	85 ff                	test   %edi,%edi
f0100b3d:	74 a1                	je     f0100ae0 <monitor+0x6b>
	for (i = 0; i < NCOMMANDS; i++) {
f0100b3f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b44:	83 ec 08             	sub    $0x8,%esp
f0100b47:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b4a:	ff 34 85 40 41 10 f0 	pushl  -0xfefbec0(,%eax,4)
f0100b51:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b54:	e8 ec 2a 00 00       	call   f0103645 <strcmp>
f0100b59:	83 c4 10             	add    $0x10,%esp
f0100b5c:	85 c0                	test   %eax,%eax
f0100b5e:	74 20                	je     f0100b80 <monitor+0x10b>
	for (i = 0; i < NCOMMANDS; i++) {
f0100b60:	83 c3 01             	add    $0x1,%ebx
f0100b63:	83 fb 05             	cmp    $0x5,%ebx
f0100b66:	75 dc                	jne    f0100b44 <monitor+0xcf>
	cprintf("Unknown command %s\n", argv[0]);
f0100b68:	83 ec 08             	sub    $0x8,%esp
f0100b6b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b6e:	68 fa 3e 10 f0       	push   $0xf0103efa
f0100b73:	e8 c7 1f 00 00       	call   f0102b3f <cprintf>
f0100b78:	83 c4 10             	add    $0x10,%esp
f0100b7b:	e9 60 ff ff ff       	jmp    f0100ae0 <monitor+0x6b>
			return commands[i].func(argc, argv, tf);
f0100b80:	83 ec 04             	sub    $0x4,%esp
f0100b83:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b86:	ff 75 08             	pushl  0x8(%ebp)
f0100b89:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b8c:	52                   	push   %edx
f0100b8d:	57                   	push   %edi
f0100b8e:	ff 14 85 48 41 10 f0 	call   *-0xfefbeb8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b95:	83 c4 10             	add    $0x10,%esp
f0100b98:	85 c0                	test   %eax,%eax
f0100b9a:	0f 89 40 ff ff ff    	jns    f0100ae0 <monitor+0x6b>
				break;
	}
}
f0100ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ba3:	5b                   	pop    %ebx
f0100ba4:	5e                   	pop    %esi
f0100ba5:	5f                   	pop    %edi
f0100ba6:	5d                   	pop    %ebp
f0100ba7:	c3                   	ret    

f0100ba8 <boot_alloc>:
// If were out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ba8:	55                   	push   %ebp
f0100ba9:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// end is a magic symbol automatically generated by the linker,
	// which points to the end of the kernels bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100bab:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
f0100bb2:	74 1d                	je     f0100bd1 <boot_alloc+0x29>
	// Allocate a chunk large enough to hold n bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100bb4:	8b 0d 38 85 11 f0    	mov    0xf0118538,%ecx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100bba:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100bc1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bc7:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
	return result;
}
f0100bcd:	89 c8                	mov    %ecx,%eax
f0100bcf:	5d                   	pop    %ebp
f0100bd0:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100bd1:	ba 73 99 11 f0       	mov    $0xf0119973,%edx
f0100bd6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bdc:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
f0100be2:	eb d0                	jmp    f0100bb4 <boot_alloc+0xc>

f0100be4 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100be4:	89 d1                	mov    %edx,%ecx
f0100be6:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100be9:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100bec:	a8 01                	test   $0x1,%al
f0100bee:	74 52                	je     f0100c42 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100bf0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bf5:	89 c1                	mov    %eax,%ecx
f0100bf7:	c1 e9 0c             	shr    $0xc,%ecx
f0100bfa:	3b 0d 68 89 11 f0    	cmp    0xf0118968,%ecx
f0100c00:	73 25                	jae    f0100c27 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100c02:	c1 ea 0c             	shr    $0xc,%edx
f0100c05:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c0b:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c12:	89 c2                	mov    %eax,%edx
f0100c14:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c1c:	85 d2                	test   %edx,%edx
f0100c1e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c23:	0f 44 c2             	cmove  %edx,%eax
f0100c26:	c3                   	ret    
{
f0100c27:	55                   	push   %ebp
f0100c28:	89 e5                	mov    %esp,%ebp
f0100c2a:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c2d:	50                   	push   %eax
f0100c2e:	68 7c 41 10 f0       	push   $0xf010417c
f0100c33:	68 cf 02 00 00       	push   $0x2cf
f0100c38:	68 d0 48 10 f0       	push   $0xf01048d0
f0100c3d:	e8 49 f4 ff ff       	call   f010008b <_panic>
		return ~0;
f0100c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c47:	c3                   	ret    

f0100c48 <check_page_free_list>:
{
f0100c48:	55                   	push   %ebp
f0100c49:	89 e5                	mov    %esp,%ebp
f0100c4b:	57                   	push   %edi
f0100c4c:	56                   	push   %esi
f0100c4d:	53                   	push   %ebx
f0100c4e:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c51:	84 c0                	test   %al,%al
f0100c53:	0f 85 48 02 00 00    	jne    f0100ea1 <check_page_free_list+0x259>
	if (!page_free_list)
f0100c59:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f0100c60:	74 0a                	je     f0100c6c <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c62:	be 00 04 00 00       	mov    $0x400,%esi
f0100c67:	e9 90 02 00 00       	jmp    f0100efc <check_page_free_list+0x2b4>
		panic("page_free_list is a null pointer!");
f0100c6c:	83 ec 04             	sub    $0x4,%esp
f0100c6f:	68 a0 41 10 f0       	push   $0xf01041a0
f0100c74:	68 12 02 00 00       	push   $0x212
f0100c79:	68 d0 48 10 f0       	push   $0xf01048d0
f0100c7e:	e8 08 f4 ff ff       	call   f010008b <_panic>
f0100c83:	50                   	push   %eax
f0100c84:	68 7c 41 10 f0       	push   $0xf010417c
f0100c89:	6a 52                	push   $0x52
f0100c8b:	68 dc 48 10 f0       	push   $0xf01048dc
f0100c90:	e8 f6 f3 ff ff       	call   f010008b <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c95:	8b 1b                	mov    (%ebx),%ebx
f0100c97:	85 db                	test   %ebx,%ebx
f0100c99:	74 41                	je     f0100cdc <check_page_free_list+0x94>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c9b:	89 d8                	mov    %ebx,%eax
f0100c9d:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100ca3:	c1 f8 03             	sar    $0x3,%eax
f0100ca6:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ca9:	89 c2                	mov    %eax,%edx
f0100cab:	c1 ea 16             	shr    $0x16,%edx
f0100cae:	39 f2                	cmp    %esi,%edx
f0100cb0:	73 e3                	jae    f0100c95 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100cb2:	89 c2                	mov    %eax,%edx
f0100cb4:	c1 ea 0c             	shr    $0xc,%edx
f0100cb7:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0100cbd:	73 c4                	jae    f0100c83 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100cbf:	83 ec 04             	sub    $0x4,%esp
f0100cc2:	68 80 00 00 00       	push   $0x80
f0100cc7:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100ccc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cd1:	50                   	push   %eax
f0100cd2:	e8 09 2a 00 00       	call   f01036e0 <memset>
f0100cd7:	83 c4 10             	add    $0x10,%esp
f0100cda:	eb b9                	jmp    f0100c95 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100cdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ce1:	e8 c2 fe ff ff       	call   f0100ba8 <boot_alloc>
f0100ce6:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce9:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		assert(pp >= pages);
f0100cef:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
		assert(pp < pages + npages);
f0100cf5:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100cfa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cfd:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d00:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d03:	be 00 00 00 00       	mov    $0x0,%esi
f0100d08:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d0b:	e9 c9 00 00 00       	jmp    f0100dd9 <check_page_free_list+0x191>
		assert(pp >= pages);
f0100d10:	68 ea 48 10 f0       	push   $0xf01048ea
f0100d15:	68 f6 48 10 f0       	push   $0xf01048f6
f0100d1a:	68 2c 02 00 00       	push   $0x22c
f0100d1f:	68 d0 48 10 f0       	push   $0xf01048d0
f0100d24:	e8 62 f3 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100d29:	68 0b 49 10 f0       	push   $0xf010490b
f0100d2e:	68 f6 48 10 f0       	push   $0xf01048f6
f0100d33:	68 2d 02 00 00       	push   $0x22d
f0100d38:	68 d0 48 10 f0       	push   $0xf01048d0
f0100d3d:	e8 49 f3 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d42:	68 c4 41 10 f0       	push   $0xf01041c4
f0100d47:	68 f6 48 10 f0       	push   $0xf01048f6
f0100d4c:	68 2e 02 00 00       	push   $0x22e
f0100d51:	68 d0 48 10 f0       	push   $0xf01048d0
f0100d56:	e8 30 f3 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != 0);
f0100d5b:	68 1f 49 10 f0       	push   $0xf010491f
f0100d60:	68 f6 48 10 f0       	push   $0xf01048f6
f0100d65:	68 31 02 00 00       	push   $0x231
f0100d6a:	68 d0 48 10 f0       	push   $0xf01048d0
f0100d6f:	e8 17 f3 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d74:	68 30 49 10 f0       	push   $0xf0104930
f0100d79:	68 f6 48 10 f0       	push   $0xf01048f6
f0100d7e:	68 32 02 00 00       	push   $0x232
f0100d83:	68 d0 48 10 f0       	push   $0xf01048d0
f0100d88:	e8 fe f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8d:	68 f8 41 10 f0       	push   $0xf01041f8
f0100d92:	68 f6 48 10 f0       	push   $0xf01048f6
f0100d97:	68 33 02 00 00       	push   $0x233
f0100d9c:	68 d0 48 10 f0       	push   $0xf01048d0
f0100da1:	e8 e5 f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da6:	68 49 49 10 f0       	push   $0xf0104949
f0100dab:	68 f6 48 10 f0       	push   $0xf01048f6
f0100db0:	68 34 02 00 00       	push   $0x234
f0100db5:	68 d0 48 10 f0       	push   $0xf01048d0
f0100dba:	e8 cc f2 ff ff       	call   f010008b <_panic>
	if (PGNUM(pa) >= npages)
f0100dbf:	89 c3                	mov    %eax,%ebx
f0100dc1:	c1 eb 0c             	shr    $0xc,%ebx
f0100dc4:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100dc7:	76 68                	jbe    f0100e31 <check_page_free_list+0x1e9>
	return (void *)(pa + KERNBASE);
f0100dc9:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dce:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100dd1:	77 70                	ja     f0100e43 <check_page_free_list+0x1fb>
			++nfree_extmem;
f0100dd3:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dd7:	8b 12                	mov    (%edx),%edx
f0100dd9:	85 d2                	test   %edx,%edx
f0100ddb:	74 7f                	je     f0100e5c <check_page_free_list+0x214>
		assert(pp >= pages);
f0100ddd:	39 d1                	cmp    %edx,%ecx
f0100ddf:	0f 87 2b ff ff ff    	ja     f0100d10 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100de5:	39 d7                	cmp    %edx,%edi
f0100de7:	0f 86 3c ff ff ff    	jbe    f0100d29 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ded:	89 d0                	mov    %edx,%eax
f0100def:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100df2:	a8 07                	test   $0x7,%al
f0100df4:	0f 85 48 ff ff ff    	jne    f0100d42 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100dfa:	c1 f8 03             	sar    $0x3,%eax
f0100dfd:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100e00:	85 c0                	test   %eax,%eax
f0100e02:	0f 84 53 ff ff ff    	je     f0100d5b <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e08:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e0d:	0f 84 61 ff ff ff    	je     f0100d74 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e13:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e18:	0f 84 6f ff ff ff    	je     f0100d8d <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e1e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e23:	74 81                	je     f0100da6 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e25:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e2a:	77 93                	ja     f0100dbf <check_page_free_list+0x177>
			++nfree_basemem;
f0100e2c:	83 c6 01             	add    $0x1,%esi
f0100e2f:	eb a6                	jmp    f0100dd7 <check_page_free_list+0x18f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e31:	50                   	push   %eax
f0100e32:	68 7c 41 10 f0       	push   $0xf010417c
f0100e37:	6a 52                	push   $0x52
f0100e39:	68 dc 48 10 f0       	push   $0xf01048dc
f0100e3e:	e8 48 f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e43:	68 1c 42 10 f0       	push   $0xf010421c
f0100e48:	68 f6 48 10 f0       	push   $0xf01048f6
f0100e4d:	68 35 02 00 00       	push   $0x235
f0100e52:	68 d0 48 10 f0       	push   $0xf01048d0
f0100e57:	e8 2f f2 ff ff       	call   f010008b <_panic>
f0100e5c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100e5f:	85 f6                	test   %esi,%esi
f0100e61:	7e 0c                	jle    f0100e6f <check_page_free_list+0x227>
	assert(nfree_extmem > 0);
f0100e63:	85 db                	test   %ebx,%ebx
f0100e65:	7e 21                	jle    f0100e88 <check_page_free_list+0x240>
}
f0100e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e6a:	5b                   	pop    %ebx
f0100e6b:	5e                   	pop    %esi
f0100e6c:	5f                   	pop    %edi
f0100e6d:	5d                   	pop    %ebp
f0100e6e:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e6f:	68 63 49 10 f0       	push   $0xf0104963
f0100e74:	68 f6 48 10 f0       	push   $0xf01048f6
f0100e79:	68 3d 02 00 00       	push   $0x23d
f0100e7e:	68 d0 48 10 f0       	push   $0xf01048d0
f0100e83:	e8 03 f2 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100e88:	68 75 49 10 f0       	push   $0xf0104975
f0100e8d:	68 f6 48 10 f0       	push   $0xf01048f6
f0100e92:	68 3e 02 00 00       	push   $0x23e
f0100e97:	68 d0 48 10 f0       	push   $0xf01048d0
f0100e9c:	e8 ea f1 ff ff       	call   f010008b <_panic>
	if (!page_free_list)
f0100ea1:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0100ea6:	85 c0                	test   %eax,%eax
f0100ea8:	0f 84 be fd ff ff    	je     f0100c6c <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100eae:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100eb1:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100eb4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100eb7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100eba:	89 c2                	mov    %eax,%edx
f0100ebc:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ec2:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ec8:	0f 95 c2             	setne  %dl
f0100ecb:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ece:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ed2:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ed4:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ed8:	8b 00                	mov    (%eax),%eax
f0100eda:	85 c0                	test   %eax,%eax
f0100edc:	75 dc                	jne    f0100eba <check_page_free_list+0x272>
		*tp[1] = 0;
f0100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ee1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ee7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eed:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100eef:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ef2:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ef7:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100efc:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100f02:	e9 90 fd ff ff       	jmp    f0100c97 <check_page_free_list+0x4f>

f0100f07 <page_init>:
{
f0100f07:	55                   	push   %ebp
f0100f08:	89 e5                	mov    %esp,%ebp
f0100f0a:	53                   	push   %ebx
	pages[0].pp_ref = 1;
f0100f0b:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0100f10:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0100f16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	for(i = 1; i<npages;i++){
f0100f1c:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100f21:	eb 4c                	jmp    f0100f6f <page_init+0x68>
		if(i >= IOPHYSMEM/PGSIZE && (i < EXTPHYSMEM/PGSIZE || i < ((int)(boot_alloc(0) - KERNBASE)/PGSIZE))){
f0100f23:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f28:	e8 7b fc ff ff       	call   f0100ba8 <boot_alloc>
f0100f2d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100f33:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0100f38:	85 d2                	test   %edx,%edx
f0100f3a:	0f 49 c2             	cmovns %edx,%eax
f0100f3d:	c1 f8 0c             	sar    $0xc,%eax
f0100f40:	39 d8                	cmp    %ebx,%eax
f0100f42:	77 43                	ja     f0100f87 <page_init+0x80>
			pages[i].pp_ref = 0;
f0100f44:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f4b:	89 c2                	mov    %eax,%edx
f0100f4d:	03 15 70 89 11 f0    	add    0xf0118970,%edx
f0100f53:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f59:	8b 0d 3c 85 11 f0    	mov    0xf011853c,%ecx
f0100f5f:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f61:	03 05 70 89 11 f0    	add    0xf0118970,%eax
f0100f67:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	for(i = 1; i<npages;i++){
f0100f6c:	83 c3 01             	add    $0x1,%ebx
f0100f6f:	39 1d 68 89 11 f0    	cmp    %ebx,0xf0118968
f0100f75:	76 26                	jbe    f0100f9d <page_init+0x96>
		if(i >= IOPHYSMEM/PGSIZE && (i < EXTPHYSMEM/PGSIZE || i < ((int)(boot_alloc(0) - KERNBASE)/PGSIZE))){
f0100f77:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100f7d:	76 c5                	jbe    f0100f44 <page_init+0x3d>
f0100f7f:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100f85:	77 9c                	ja     f0100f23 <page_init+0x1c>
			pages[i].pp_ref = 1;
f0100f87:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0100f8c:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f8f:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f9b:	eb cf                	jmp    f0100f6c <page_init+0x65>
}
f0100f9d:	5b                   	pop    %ebx
f0100f9e:	5d                   	pop    %ebp
f0100f9f:	c3                   	ret    

f0100fa0 <page_alloc>:
{
f0100fa0:	55                   	push   %ebp
f0100fa1:	89 e5                	mov    %esp,%ebp
f0100fa3:	53                   	push   %ebx
f0100fa4:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list){
f0100fa7:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100fad:	85 db                	test   %ebx,%ebx
f0100faf:	74 0d                	je     f0100fbe <page_alloc+0x1e>
		page_free_list = page_free_list->pp_link;
f0100fb1:	8b 03                	mov    (%ebx),%eax
f0100fb3:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
		if(alloc_flags & ALLOC_ZERO){
f0100fb8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fbc:	75 07                	jne    f0100fc5 <page_alloc+0x25>
}
f0100fbe:	89 d8                	mov    %ebx,%eax
f0100fc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fc3:	c9                   	leave  
f0100fc4:	c3                   	ret    
f0100fc5:	89 d8                	mov    %ebx,%eax
f0100fc7:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100fcd:	c1 f8 03             	sar    $0x3,%eax
f0100fd0:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100fd3:	89 c2                	mov    %eax,%edx
f0100fd5:	c1 ea 0c             	shr    $0xc,%edx
f0100fd8:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0100fde:	73 1a                	jae    f0100ffa <page_alloc+0x5a>
			memset(page2kva(pg), 0, PGSIZE);
f0100fe0:	83 ec 04             	sub    $0x4,%esp
f0100fe3:	68 00 10 00 00       	push   $0x1000
f0100fe8:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fef:	50                   	push   %eax
f0100ff0:	e8 eb 26 00 00       	call   f01036e0 <memset>
f0100ff5:	83 c4 10             	add    $0x10,%esp
f0100ff8:	eb c4                	jmp    f0100fbe <page_alloc+0x1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ffa:	50                   	push   %eax
f0100ffb:	68 7c 41 10 f0       	push   $0xf010417c
f0101000:	6a 52                	push   $0x52
f0101002:	68 dc 48 10 f0       	push   $0xf01048dc
f0101007:	e8 7f f0 ff ff       	call   f010008b <_panic>

f010100c <page_free>:
{
f010100c:	55                   	push   %ebp
f010100d:	89 e5                	mov    %esp,%ebp
f010100f:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0101012:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f0101018:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010101a:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
}
f010101f:	5d                   	pop    %ebp
f0101020:	c3                   	ret    

f0101021 <page_decref>:
{
f0101021:	55                   	push   %ebp
f0101022:	89 e5                	mov    %esp,%ebp
f0101024:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101027:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010102b:	83 e8 01             	sub    $0x1,%eax
f010102e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101032:	66 85 c0             	test   %ax,%ax
f0101035:	74 02                	je     f0101039 <page_decref+0x18>
}
f0101037:	c9                   	leave  
f0101038:	c3                   	ret    
		page_free(pp);
f0101039:	52                   	push   %edx
f010103a:	e8 cd ff ff ff       	call   f010100c <page_free>
f010103f:	83 c4 04             	add    $0x4,%esp
}
f0101042:	eb f3                	jmp    f0101037 <page_decref+0x16>

f0101044 <pgdir_walk>:
{
f0101044:	55                   	push   %ebp
f0101045:	89 e5                	mov    %esp,%ebp
f0101047:	56                   	push   %esi
f0101048:	53                   	push   %ebx
f0101049:	8b 75 0c             	mov    0xc(%ebp),%esi
	if(!(pgdir[PDX(va)] & PTE_P)){
f010104c:	89 f3                	mov    %esi,%ebx
f010104e:	c1 eb 16             	shr    $0x16,%ebx
f0101051:	c1 e3 02             	shl    $0x2,%ebx
f0101054:	03 5d 08             	add    0x8(%ebp),%ebx
f0101057:	f6 03 01             	testb  $0x1,(%ebx)
f010105a:	75 2d                	jne    f0101089 <pgdir_walk+0x45>
		if(create){
f010105c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101060:	74 67                	je     f01010c9 <pgdir_walk+0x85>
			struct PageInfo* pg = page_alloc(ALLOC_ZERO);
f0101062:	83 ec 0c             	sub    $0xc,%esp
f0101065:	6a 01                	push   $0x1
f0101067:	e8 34 ff ff ff       	call   f0100fa0 <page_alloc>
			if(pg == NULL)
f010106c:	83 c4 10             	add    $0x10,%esp
f010106f:	85 c0                	test   %eax,%eax
f0101071:	74 5d                	je     f01010d0 <pgdir_walk+0x8c>
			pg->pp_ref++;
f0101073:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101078:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010107e:	c1 f8 03             	sar    $0x3,%eax
f0101081:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[PDX(va)]= page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0101084:	83 c8 07             	or     $0x7,%eax
f0101087:	89 03                	mov    %eax,(%ebx)
	pte_t* pt = KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0101089:	8b 03                	mov    (%ebx),%eax
f010108b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101090:	89 c2                	mov    %eax,%edx
f0101092:	c1 ea 0c             	shr    $0xc,%edx
f0101095:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f010109b:	73 17                	jae    f01010b4 <pgdir_walk+0x70>
	return pt + PTX(va);
f010109d:	c1 ee 0a             	shr    $0xa,%esi
f01010a0:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010a6:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f01010ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010b0:	5b                   	pop    %ebx
f01010b1:	5e                   	pop    %esi
f01010b2:	5d                   	pop    %ebp
f01010b3:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b4:	50                   	push   %eax
f01010b5:	68 7c 41 10 f0       	push   $0xf010417c
f01010ba:	68 6c 01 00 00       	push   $0x16c
f01010bf:	68 d0 48 10 f0       	push   $0xf01048d0
f01010c4:	e8 c2 ef ff ff       	call   f010008b <_panic>
			return NULL;
f01010c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ce:	eb dd                	jmp    f01010ad <pgdir_walk+0x69>
				return NULL;
f01010d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01010d5:	eb d6                	jmp    f01010ad <pgdir_walk+0x69>

f01010d7 <boot_map_region>:
{
f01010d7:	55                   	push   %ebp
f01010d8:	89 e5                	mov    %esp,%ebp
f01010da:	57                   	push   %edi
f01010db:	56                   	push   %esi
f01010dc:	53                   	push   %ebx
f01010dd:	83 ec 1c             	sub    $0x1c,%esp
f01010e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010e3:	8b 45 08             	mov    0x8(%ebp),%eax
	for(int i = 0; i<size/PGSIZE; i++, va+=PGSIZE, pa+=PGSIZE){
f01010e6:	c1 e9 0c             	shr    $0xc,%ecx
f01010e9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01010ec:	89 c3                	mov    %eax,%ebx
f01010ee:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t* pte = pgdir_walk(pgdir, (void*)va, true);
f01010f3:	89 d7                	mov    %edx,%edi
f01010f5:	29 c7                	sub    %eax,%edi
		*pte = pa | perm | PTE_P;
f01010f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010fa:	83 c8 01             	or     $0x1,%eax
f01010fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for(int i = 0; i<size/PGSIZE; i++, va+=PGSIZE, pa+=PGSIZE){
f0101100:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101103:	74 41                	je     f0101146 <boot_map_region+0x6f>
		pte_t* pte = pgdir_walk(pgdir, (void*)va, true);
f0101105:	83 ec 04             	sub    $0x4,%esp
f0101108:	6a 01                	push   $0x1
f010110a:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010110d:	50                   	push   %eax
f010110e:	ff 75 e0             	pushl  -0x20(%ebp)
f0101111:	e8 2e ff ff ff       	call   f0101044 <pgdir_walk>
		if(pte == NULL)
f0101116:	83 c4 10             	add    $0x10,%esp
f0101119:	85 c0                	test   %eax,%eax
f010111b:	74 12                	je     f010112f <boot_map_region+0x58>
		*pte = pa | perm | PTE_P;
f010111d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101120:	09 da                	or     %ebx,%edx
f0101122:	89 10                	mov    %edx,(%eax)
	for(int i = 0; i<size/PGSIZE; i++, va+=PGSIZE, pa+=PGSIZE){
f0101124:	83 c6 01             	add    $0x1,%esi
f0101127:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010112d:	eb d1                	jmp    f0101100 <boot_map_region+0x29>
			panic("OOM");
f010112f:	83 ec 04             	sub    $0x4,%esp
f0101132:	68 52 3e 10 f0       	push   $0xf0103e52
f0101137:	68 83 01 00 00       	push   $0x183
f010113c:	68 d0 48 10 f0       	push   $0xf01048d0
f0101141:	e8 45 ef ff ff       	call   f010008b <_panic>
}
f0101146:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101149:	5b                   	pop    %ebx
f010114a:	5e                   	pop    %esi
f010114b:	5f                   	pop    %edi
f010114c:	5d                   	pop    %ebp
f010114d:	c3                   	ret    

f010114e <page_lookup>:
{
f010114e:	55                   	push   %ebp
f010114f:	89 e5                	mov    %esp,%ebp
f0101151:	53                   	push   %ebx
f0101152:	83 ec 08             	sub    $0x8,%esp
f0101155:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, false);
f0101158:	6a 00                	push   $0x0
f010115a:	ff 75 0c             	pushl  0xc(%ebp)
f010115d:	ff 75 08             	pushl  0x8(%ebp)
f0101160:	e8 df fe ff ff       	call   f0101044 <pgdir_walk>
	if(pte == NULL || !(*pte & PTE_P))
f0101165:	83 c4 10             	add    $0x10,%esp
f0101168:	85 c0                	test   %eax,%eax
f010116a:	74 3a                	je     f01011a6 <page_lookup+0x58>
f010116c:	f6 00 01             	testb  $0x1,(%eax)
f010116f:	74 3c                	je     f01011ad <page_lookup+0x5f>
	if(pte_store)
f0101171:	85 db                	test   %ebx,%ebx
f0101173:	74 02                	je     f0101177 <page_lookup+0x29>
		*pte_store = pte;
f0101175:	89 03                	mov    %eax,(%ebx)
f0101177:	8b 00                	mov    (%eax),%eax
f0101179:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010117c:	39 05 68 89 11 f0    	cmp    %eax,0xf0118968
f0101182:	76 0e                	jbe    f0101192 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101184:	8b 15 70 89 11 f0    	mov    0xf0118970,%edx
f010118a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010118d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101190:	c9                   	leave  
f0101191:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101192:	83 ec 04             	sub    $0x4,%esp
f0101195:	68 64 42 10 f0       	push   $0xf0104264
f010119a:	6a 4b                	push   $0x4b
f010119c:	68 dc 48 10 f0       	push   $0xf01048dc
f01011a1:	e8 e5 ee ff ff       	call   f010008b <_panic>
		return NULL;
f01011a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ab:	eb e0                	jmp    f010118d <page_lookup+0x3f>
f01011ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01011b2:	eb d9                	jmp    f010118d <page_lookup+0x3f>

f01011b4 <page_remove>:
{
f01011b4:	55                   	push   %ebp
f01011b5:	89 e5                	mov    %esp,%ebp
f01011b7:	53                   	push   %ebx
f01011b8:	83 ec 18             	sub    $0x18,%esp
f01011bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f01011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011c1:	50                   	push   %eax
f01011c2:	53                   	push   %ebx
f01011c3:	ff 75 08             	pushl  0x8(%ebp)
f01011c6:	e8 83 ff ff ff       	call   f010114e <page_lookup>
	if (!pg) 
f01011cb:	83 c4 10             	add    $0x10,%esp
f01011ce:	85 c0                	test   %eax,%eax
f01011d0:	75 05                	jne    f01011d7 <page_remove+0x23>
}
f01011d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011d5:	c9                   	leave  
f01011d6:	c3                   	ret    
	page_decref(pg);
f01011d7:	83 ec 0c             	sub    $0xc,%esp
f01011da:	50                   	push   %eax
f01011db:	e8 41 fe ff ff       	call   f0101021 <page_decref>
	*pte = 0;
f01011e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011e9:	0f 01 3b             	invlpg (%ebx)
f01011ec:	83 c4 10             	add    $0x10,%esp
f01011ef:	eb e1                	jmp    f01011d2 <page_remove+0x1e>

f01011f1 <page_insert>:
{
f01011f1:	55                   	push   %ebp
f01011f2:	89 e5                	mov    %esp,%ebp
f01011f4:	57                   	push   %edi
f01011f5:	56                   	push   %esi
f01011f6:	53                   	push   %ebx
f01011f7:	83 ec 10             	sub    $0x10,%esp
f01011fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011fd:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir,va,0);
f0101200:	6a 00                	push   $0x0
f0101202:	57                   	push   %edi
f0101203:	ff 75 08             	pushl  0x8(%ebp)
f0101206:	e8 39 fe ff ff       	call   f0101044 <pgdir_walk>
	if(pte)
f010120b:	83 c4 10             	add    $0x10,%esp
f010120e:	85 c0                	test   %eax,%eax
f0101210:	74 57                	je     f0101269 <page_insert+0x78>
f0101212:	89 c6                	mov    %eax,%esi
		if(*pte & PTE_P)
f0101214:	f6 00 01             	testb  $0x1,(%eax)
f0101217:	75 36                	jne    f010124f <page_insert+0x5e>
		if(page_free_list == pp)
f0101219:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f010121e:	39 d8                	cmp    %ebx,%eax
f0101220:	74 3e                	je     f0101260 <page_insert+0x6f>
	return (pp - pages) << PGSHIFT;
f0101222:	89 d8                	mov    %ebx,%eax
f0101224:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010122a:	c1 f8 03             	sar    $0x3,%eax
f010122d:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101230:	8b 55 14             	mov    0x14(%ebp),%edx
f0101233:	83 ca 01             	or     $0x1,%edx
f0101236:	09 d0                	or     %edx,%eax
f0101238:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f010123a:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
f010123f:	0f 01 3f             	invlpg (%edi)
	return 0;
f0101242:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101247:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010124a:	5b                   	pop    %ebx
f010124b:	5e                   	pop    %esi
f010124c:	5f                   	pop    %edi
f010124d:	5d                   	pop    %ebp
f010124e:	c3                   	ret    
			page_remove(pgdir,va);//取消va与之物理页之间的关联
f010124f:	83 ec 08             	sub    $0x8,%esp
f0101252:	57                   	push   %edi
f0101253:	ff 75 08             	pushl  0x8(%ebp)
f0101256:	e8 59 ff ff ff       	call   f01011b4 <page_remove>
f010125b:	83 c4 10             	add    $0x10,%esp
f010125e:	eb b9                	jmp    f0101219 <page_insert+0x28>
			page_free_list = page_free_list->pp_link;//update the new free_list header
f0101260:	8b 00                	mov    (%eax),%eax
f0101262:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
f0101267:	eb b9                	jmp    f0101222 <page_insert+0x31>
		pte = pgdir_walk(pgdir,va,1);
f0101269:	83 ec 04             	sub    $0x4,%esp
f010126c:	6a 01                	push   $0x1
f010126e:	57                   	push   %edi
f010126f:	ff 75 08             	pushl  0x8(%ebp)
f0101272:	e8 cd fd ff ff       	call   f0101044 <pgdir_walk>
f0101277:	89 c6                	mov    %eax,%esi
		if(pte == NULL)
f0101279:	83 c4 10             	add    $0x10,%esp
f010127c:	85 c0                	test   %eax,%eax
f010127e:	75 a2                	jne    f0101222 <page_insert+0x31>
			return -E_NO_MEM;
f0101280:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101285:	eb c0                	jmp    f0101247 <page_insert+0x56>

f0101287 <mem_init>:
{
f0101287:	55                   	push   %ebp
f0101288:	89 e5                	mov    %esp,%ebp
f010128a:	57                   	push   %edi
f010128b:	56                   	push   %esi
f010128c:	53                   	push   %ebx
f010128d:	83 ec 38             	sub    $0x38,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101290:	6a 15                	push   $0x15
f0101292:	e8 41 18 00 00       	call   f0102ad8 <mc146818_read>
f0101297:	89 c3                	mov    %eax,%ebx
f0101299:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01012a0:	e8 33 18 00 00       	call   f0102ad8 <mc146818_read>
f01012a5:	c1 e0 08             	shl    $0x8,%eax
f01012a8:	09 d8                	or     %ebx,%eax
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012aa:	c1 e0 0a             	shl    $0xa,%eax
f01012ad:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012b3:	85 c0                	test   %eax,%eax
f01012b5:	0f 48 c2             	cmovs  %edx,%eax
f01012b8:	c1 f8 0c             	sar    $0xc,%eax
f01012bb:	a3 40 85 11 f0       	mov    %eax,0xf0118540
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012c0:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01012c7:	e8 0c 18 00 00       	call   f0102ad8 <mc146818_read>
f01012cc:	89 c3                	mov    %eax,%ebx
f01012ce:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01012d5:	e8 fe 17 00 00       	call   f0102ad8 <mc146818_read>
f01012da:	c1 e0 08             	shl    $0x8,%eax
f01012dd:	09 d8                	or     %ebx,%eax
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01012df:	c1 e0 0a             	shl    $0xa,%eax
f01012e2:	89 c2                	mov    %eax,%edx
f01012e4:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f01012ea:	83 c4 10             	add    $0x10,%esp
f01012ed:	85 d2                	test   %edx,%edx
f01012ef:	0f 49 c2             	cmovns %edx,%eax
f01012f2:	c1 f8 0c             	sar    $0xc,%eax
	if (npages_extmem)
f01012f5:	85 c0                	test   %eax,%eax
f01012f7:	0f 85 c4 00 00 00    	jne    f01013c1 <mem_init+0x13a>
		npages = npages_basemem;
f01012fd:	8b 15 40 85 11 f0    	mov    0xf0118540,%edx
f0101303:	89 15 68 89 11 f0    	mov    %edx,0xf0118968
		npages_extmem * PGSIZE / 1024);
f0101309:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010130c:	c1 e8 0a             	shr    $0xa,%eax
f010130f:	50                   	push   %eax
		npages_basemem * PGSIZE / 1024,
f0101310:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f0101315:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101318:	c1 e8 0a             	shr    $0xa,%eax
f010131b:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010131c:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101321:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101324:	c1 e8 0a             	shr    $0xa,%eax
f0101327:	50                   	push   %eax
f0101328:	68 84 42 10 f0       	push   $0xf0104284
f010132d:	e8 0d 18 00 00       	call   f0102b3f <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101332:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101337:	e8 6c f8 ff ff       	call   f0100ba8 <boot_alloc>
f010133c:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(kern_pgdir, 0, PGSIZE);
f0101341:	83 c4 0c             	add    $0xc,%esp
f0101344:	68 00 10 00 00       	push   $0x1000
f0101349:	6a 00                	push   $0x0
f010134b:	50                   	push   %eax
f010134c:	e8 8f 23 00 00       	call   f01036e0 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101351:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101356:	83 c4 10             	add    $0x10,%esp
f0101359:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010135e:	76 72                	jbe    f01013d2 <mem_init+0x14b>
	return (physaddr_t)kva - KERNBASE;
f0101360:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101366:	83 ca 05             	or     $0x5,%edx
f0101369:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*)boot_alloc(npages * sizeof(struct PageInfo));
f010136f:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101374:	c1 e0 03             	shl    $0x3,%eax
f0101377:	e8 2c f8 ff ff       	call   f0100ba8 <boot_alloc>
f010137c:	a3 70 89 11 f0       	mov    %eax,0xf0118970
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f0101381:	83 ec 04             	sub    $0x4,%esp
f0101384:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f010138a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101391:	52                   	push   %edx
f0101392:	6a 00                	push   $0x0
f0101394:	50                   	push   %eax
f0101395:	e8 46 23 00 00       	call   f01036e0 <memset>
	page_init();
f010139a:	e8 68 fb ff ff       	call   f0100f07 <page_init>
	check_page_free_list(1);
f010139f:	b8 01 00 00 00       	mov    $0x1,%eax
f01013a4:	e8 9f f8 ff ff       	call   f0100c48 <check_page_free_list>
	if (!pages)
f01013a9:	83 c4 10             	add    $0x10,%esp
f01013ac:	83 3d 70 89 11 f0 00 	cmpl   $0x0,0xf0118970
f01013b3:	74 32                	je     f01013e7 <mem_init+0x160>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013b5:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01013ba:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013bf:	eb 42                	jmp    f0101403 <mem_init+0x17c>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01013c1:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01013c7:	89 15 68 89 11 f0    	mov    %edx,0xf0118968
f01013cd:	e9 37 ff ff ff       	jmp    f0101309 <mem_init+0x82>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013d2:	50                   	push   %eax
f01013d3:	68 c0 42 10 f0       	push   $0xf01042c0
f01013d8:	68 8b 00 00 00       	push   $0x8b
f01013dd:	68 d0 48 10 f0       	push   $0xf01048d0
f01013e2:	e8 a4 ec ff ff       	call   f010008b <_panic>
		panic("pages is a null pointer!");
f01013e7:	83 ec 04             	sub    $0x4,%esp
f01013ea:	68 86 49 10 f0       	push   $0xf0104986
f01013ef:	68 4f 02 00 00       	push   $0x24f
f01013f4:	68 d0 48 10 f0       	push   $0xf01048d0
f01013f9:	e8 8d ec ff ff       	call   f010008b <_panic>
		++nfree;
f01013fe:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101401:	8b 00                	mov    (%eax),%eax
f0101403:	85 c0                	test   %eax,%eax
f0101405:	75 f7                	jne    f01013fe <mem_init+0x177>
	assert((pp0 = page_alloc(0)));
f0101407:	83 ec 0c             	sub    $0xc,%esp
f010140a:	6a 00                	push   $0x0
f010140c:	e8 8f fb ff ff       	call   f0100fa0 <page_alloc>
f0101411:	89 c7                	mov    %eax,%edi
f0101413:	83 c4 10             	add    $0x10,%esp
f0101416:	85 c0                	test   %eax,%eax
f0101418:	0f 84 12 02 00 00    	je     f0101630 <mem_init+0x3a9>
	assert((pp1 = page_alloc(0)));
f010141e:	83 ec 0c             	sub    $0xc,%esp
f0101421:	6a 00                	push   $0x0
f0101423:	e8 78 fb ff ff       	call   f0100fa0 <page_alloc>
f0101428:	89 c6                	mov    %eax,%esi
f010142a:	83 c4 10             	add    $0x10,%esp
f010142d:	85 c0                	test   %eax,%eax
f010142f:	0f 84 14 02 00 00    	je     f0101649 <mem_init+0x3c2>
	assert((pp2 = page_alloc(0)));
f0101435:	83 ec 0c             	sub    $0xc,%esp
f0101438:	6a 00                	push   $0x0
f010143a:	e8 61 fb ff ff       	call   f0100fa0 <page_alloc>
f010143f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101442:	83 c4 10             	add    $0x10,%esp
f0101445:	85 c0                	test   %eax,%eax
f0101447:	0f 84 15 02 00 00    	je     f0101662 <mem_init+0x3db>
	assert(pp1 && pp1 != pp0);
f010144d:	39 f7                	cmp    %esi,%edi
f010144f:	0f 84 26 02 00 00    	je     f010167b <mem_init+0x3f4>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101455:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101458:	39 c6                	cmp    %eax,%esi
f010145a:	0f 84 34 02 00 00    	je     f0101694 <mem_init+0x40d>
f0101460:	39 c7                	cmp    %eax,%edi
f0101462:	0f 84 2c 02 00 00    	je     f0101694 <mem_init+0x40d>
	return (pp - pages) << PGSHIFT;
f0101468:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010146e:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0101474:	c1 e2 0c             	shl    $0xc,%edx
f0101477:	89 f8                	mov    %edi,%eax
f0101479:	29 c8                	sub    %ecx,%eax
f010147b:	c1 f8 03             	sar    $0x3,%eax
f010147e:	c1 e0 0c             	shl    $0xc,%eax
f0101481:	39 d0                	cmp    %edx,%eax
f0101483:	0f 83 24 02 00 00    	jae    f01016ad <mem_init+0x426>
f0101489:	89 f0                	mov    %esi,%eax
f010148b:	29 c8                	sub    %ecx,%eax
f010148d:	c1 f8 03             	sar    $0x3,%eax
f0101490:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101493:	39 c2                	cmp    %eax,%edx
f0101495:	0f 86 2b 02 00 00    	jbe    f01016c6 <mem_init+0x43f>
f010149b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010149e:	29 c8                	sub    %ecx,%eax
f01014a0:	c1 f8 03             	sar    $0x3,%eax
f01014a3:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014a6:	39 c2                	cmp    %eax,%edx
f01014a8:	0f 86 31 02 00 00    	jbe    f01016df <mem_init+0x458>
	fl = page_free_list;
f01014ae:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01014b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014b6:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01014bd:	00 00 00 
	assert(!page_alloc(0));
f01014c0:	83 ec 0c             	sub    $0xc,%esp
f01014c3:	6a 00                	push   $0x0
f01014c5:	e8 d6 fa ff ff       	call   f0100fa0 <page_alloc>
f01014ca:	83 c4 10             	add    $0x10,%esp
f01014cd:	85 c0                	test   %eax,%eax
f01014cf:	0f 85 23 02 00 00    	jne    f01016f8 <mem_init+0x471>
	page_free(pp0);
f01014d5:	83 ec 0c             	sub    $0xc,%esp
f01014d8:	57                   	push   %edi
f01014d9:	e8 2e fb ff ff       	call   f010100c <page_free>
	page_free(pp1);
f01014de:	89 34 24             	mov    %esi,(%esp)
f01014e1:	e8 26 fb ff ff       	call   f010100c <page_free>
	page_free(pp2);
f01014e6:	83 c4 04             	add    $0x4,%esp
f01014e9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014ec:	e8 1b fb ff ff       	call   f010100c <page_free>
	assert((pp0 = page_alloc(0)));
f01014f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f8:	e8 a3 fa ff ff       	call   f0100fa0 <page_alloc>
f01014fd:	89 c6                	mov    %eax,%esi
f01014ff:	83 c4 10             	add    $0x10,%esp
f0101502:	85 c0                	test   %eax,%eax
f0101504:	0f 84 07 02 00 00    	je     f0101711 <mem_init+0x48a>
	assert((pp1 = page_alloc(0)));
f010150a:	83 ec 0c             	sub    $0xc,%esp
f010150d:	6a 00                	push   $0x0
f010150f:	e8 8c fa ff ff       	call   f0100fa0 <page_alloc>
f0101514:	89 c7                	mov    %eax,%edi
f0101516:	83 c4 10             	add    $0x10,%esp
f0101519:	85 c0                	test   %eax,%eax
f010151b:	0f 84 09 02 00 00    	je     f010172a <mem_init+0x4a3>
	assert((pp2 = page_alloc(0)));
f0101521:	83 ec 0c             	sub    $0xc,%esp
f0101524:	6a 00                	push   $0x0
f0101526:	e8 75 fa ff ff       	call   f0100fa0 <page_alloc>
f010152b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010152e:	83 c4 10             	add    $0x10,%esp
f0101531:	85 c0                	test   %eax,%eax
f0101533:	0f 84 0a 02 00 00    	je     f0101743 <mem_init+0x4bc>
	assert(pp1 && pp1 != pp0);
f0101539:	39 fe                	cmp    %edi,%esi
f010153b:	0f 84 1b 02 00 00    	je     f010175c <mem_init+0x4d5>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101541:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101544:	39 c7                	cmp    %eax,%edi
f0101546:	0f 84 29 02 00 00    	je     f0101775 <mem_init+0x4ee>
f010154c:	39 c6                	cmp    %eax,%esi
f010154e:	0f 84 21 02 00 00    	je     f0101775 <mem_init+0x4ee>
	assert(!page_alloc(0));
f0101554:	83 ec 0c             	sub    $0xc,%esp
f0101557:	6a 00                	push   $0x0
f0101559:	e8 42 fa ff ff       	call   f0100fa0 <page_alloc>
f010155e:	83 c4 10             	add    $0x10,%esp
f0101561:	85 c0                	test   %eax,%eax
f0101563:	0f 85 25 02 00 00    	jne    f010178e <mem_init+0x507>
f0101569:	89 f0                	mov    %esi,%eax
f010156b:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101571:	c1 f8 03             	sar    $0x3,%eax
f0101574:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101577:	89 c2                	mov    %eax,%edx
f0101579:	c1 ea 0c             	shr    $0xc,%edx
f010157c:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0101582:	0f 83 1f 02 00 00    	jae    f01017a7 <mem_init+0x520>
	memset(page2kva(pp0), 1, PGSIZE);
f0101588:	83 ec 04             	sub    $0x4,%esp
f010158b:	68 00 10 00 00       	push   $0x1000
f0101590:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101592:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101597:	50                   	push   %eax
f0101598:	e8 43 21 00 00       	call   f01036e0 <memset>
	page_free(pp0);
f010159d:	89 34 24             	mov    %esi,(%esp)
f01015a0:	e8 67 fa ff ff       	call   f010100c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015ac:	e8 ef f9 ff ff       	call   f0100fa0 <page_alloc>
f01015b1:	83 c4 10             	add    $0x10,%esp
f01015b4:	85 c0                	test   %eax,%eax
f01015b6:	0f 84 fd 01 00 00    	je     f01017b9 <mem_init+0x532>
	assert(pp && pp0 == pp);
f01015bc:	39 c6                	cmp    %eax,%esi
f01015be:	0f 85 0e 02 00 00    	jne    f01017d2 <mem_init+0x54b>
	return (pp - pages) << PGSHIFT;
f01015c4:	89 f2                	mov    %esi,%edx
f01015c6:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f01015cc:	c1 fa 03             	sar    $0x3,%edx
f01015cf:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015d2:	89 d0                	mov    %edx,%eax
f01015d4:	c1 e8 0c             	shr    $0xc,%eax
f01015d7:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01015dd:	0f 83 08 02 00 00    	jae    f01017eb <mem_init+0x564>
	return (void *)(pa + KERNBASE);
f01015e3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015e9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015ef:	80 38 00             	cmpb   $0x0,(%eax)
f01015f2:	0f 85 05 02 00 00    	jne    f01017fd <mem_init+0x576>
f01015f8:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01015fb:	39 d0                	cmp    %edx,%eax
f01015fd:	75 f0                	jne    f01015ef <mem_init+0x368>
	page_free_list = fl;
f01015ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101602:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	page_free(pp0);
f0101607:	83 ec 0c             	sub    $0xc,%esp
f010160a:	56                   	push   %esi
f010160b:	e8 fc f9 ff ff       	call   f010100c <page_free>
	page_free(pp1);
f0101610:	89 3c 24             	mov    %edi,(%esp)
f0101613:	e8 f4 f9 ff ff       	call   f010100c <page_free>
	page_free(pp2);
f0101618:	83 c4 04             	add    $0x4,%esp
f010161b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010161e:	e8 e9 f9 ff ff       	call   f010100c <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101623:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101628:	83 c4 10             	add    $0x10,%esp
f010162b:	e9 eb 01 00 00       	jmp    f010181b <mem_init+0x594>
	assert((pp0 = page_alloc(0)));
f0101630:	68 9f 49 10 f0       	push   $0xf010499f
f0101635:	68 f6 48 10 f0       	push   $0xf01048f6
f010163a:	68 57 02 00 00       	push   $0x257
f010163f:	68 d0 48 10 f0       	push   $0xf01048d0
f0101644:	e8 42 ea ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101649:	68 b5 49 10 f0       	push   $0xf01049b5
f010164e:	68 f6 48 10 f0       	push   $0xf01048f6
f0101653:	68 58 02 00 00       	push   $0x258
f0101658:	68 d0 48 10 f0       	push   $0xf01048d0
f010165d:	e8 29 ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101662:	68 cb 49 10 f0       	push   $0xf01049cb
f0101667:	68 f6 48 10 f0       	push   $0xf01048f6
f010166c:	68 59 02 00 00       	push   $0x259
f0101671:	68 d0 48 10 f0       	push   $0xf01048d0
f0101676:	e8 10 ea ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f010167b:	68 e1 49 10 f0       	push   $0xf01049e1
f0101680:	68 f6 48 10 f0       	push   $0xf01048f6
f0101685:	68 5c 02 00 00       	push   $0x25c
f010168a:	68 d0 48 10 f0       	push   $0xf01048d0
f010168f:	e8 f7 e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101694:	68 e4 42 10 f0       	push   $0xf01042e4
f0101699:	68 f6 48 10 f0       	push   $0xf01048f6
f010169e:	68 5d 02 00 00       	push   $0x25d
f01016a3:	68 d0 48 10 f0       	push   $0xf01048d0
f01016a8:	e8 de e9 ff ff       	call   f010008b <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016ad:	68 f3 49 10 f0       	push   $0xf01049f3
f01016b2:	68 f6 48 10 f0       	push   $0xf01048f6
f01016b7:	68 5e 02 00 00       	push   $0x25e
f01016bc:	68 d0 48 10 f0       	push   $0xf01048d0
f01016c1:	e8 c5 e9 ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016c6:	68 10 4a 10 f0       	push   $0xf0104a10
f01016cb:	68 f6 48 10 f0       	push   $0xf01048f6
f01016d0:	68 5f 02 00 00       	push   $0x25f
f01016d5:	68 d0 48 10 f0       	push   $0xf01048d0
f01016da:	e8 ac e9 ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016df:	68 2d 4a 10 f0       	push   $0xf0104a2d
f01016e4:	68 f6 48 10 f0       	push   $0xf01048f6
f01016e9:	68 60 02 00 00       	push   $0x260
f01016ee:	68 d0 48 10 f0       	push   $0xf01048d0
f01016f3:	e8 93 e9 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01016f8:	68 4a 4a 10 f0       	push   $0xf0104a4a
f01016fd:	68 f6 48 10 f0       	push   $0xf01048f6
f0101702:	68 67 02 00 00       	push   $0x267
f0101707:	68 d0 48 10 f0       	push   $0xf01048d0
f010170c:	e8 7a e9 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0101711:	68 9f 49 10 f0       	push   $0xf010499f
f0101716:	68 f6 48 10 f0       	push   $0xf01048f6
f010171b:	68 6e 02 00 00       	push   $0x26e
f0101720:	68 d0 48 10 f0       	push   $0xf01048d0
f0101725:	e8 61 e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010172a:	68 b5 49 10 f0       	push   $0xf01049b5
f010172f:	68 f6 48 10 f0       	push   $0xf01048f6
f0101734:	68 6f 02 00 00       	push   $0x26f
f0101739:	68 d0 48 10 f0       	push   $0xf01048d0
f010173e:	e8 48 e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101743:	68 cb 49 10 f0       	push   $0xf01049cb
f0101748:	68 f6 48 10 f0       	push   $0xf01048f6
f010174d:	68 70 02 00 00       	push   $0x270
f0101752:	68 d0 48 10 f0       	push   $0xf01048d0
f0101757:	e8 2f e9 ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f010175c:	68 e1 49 10 f0       	push   $0xf01049e1
f0101761:	68 f6 48 10 f0       	push   $0xf01048f6
f0101766:	68 72 02 00 00       	push   $0x272
f010176b:	68 d0 48 10 f0       	push   $0xf01048d0
f0101770:	e8 16 e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101775:	68 e4 42 10 f0       	push   $0xf01042e4
f010177a:	68 f6 48 10 f0       	push   $0xf01048f6
f010177f:	68 73 02 00 00       	push   $0x273
f0101784:	68 d0 48 10 f0       	push   $0xf01048d0
f0101789:	e8 fd e8 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010178e:	68 4a 4a 10 f0       	push   $0xf0104a4a
f0101793:	68 f6 48 10 f0       	push   $0xf01048f6
f0101798:	68 74 02 00 00       	push   $0x274
f010179d:	68 d0 48 10 f0       	push   $0xf01048d0
f01017a2:	e8 e4 e8 ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017a7:	50                   	push   %eax
f01017a8:	68 7c 41 10 f0       	push   $0xf010417c
f01017ad:	6a 52                	push   $0x52
f01017af:	68 dc 48 10 f0       	push   $0xf01048dc
f01017b4:	e8 d2 e8 ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017b9:	68 59 4a 10 f0       	push   $0xf0104a59
f01017be:	68 f6 48 10 f0       	push   $0xf01048f6
f01017c3:	68 79 02 00 00       	push   $0x279
f01017c8:	68 d0 48 10 f0       	push   $0xf01048d0
f01017cd:	e8 b9 e8 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01017d2:	68 77 4a 10 f0       	push   $0xf0104a77
f01017d7:	68 f6 48 10 f0       	push   $0xf01048f6
f01017dc:	68 7a 02 00 00       	push   $0x27a
f01017e1:	68 d0 48 10 f0       	push   $0xf01048d0
f01017e6:	e8 a0 e8 ff ff       	call   f010008b <_panic>
f01017eb:	52                   	push   %edx
f01017ec:	68 7c 41 10 f0       	push   $0xf010417c
f01017f1:	6a 52                	push   $0x52
f01017f3:	68 dc 48 10 f0       	push   $0xf01048dc
f01017f8:	e8 8e e8 ff ff       	call   f010008b <_panic>
		assert(c[i] == 0);
f01017fd:	68 87 4a 10 f0       	push   $0xf0104a87
f0101802:	68 f6 48 10 f0       	push   $0xf01048f6
f0101807:	68 7d 02 00 00       	push   $0x27d
f010180c:	68 d0 48 10 f0       	push   $0xf01048d0
f0101811:	e8 75 e8 ff ff       	call   f010008b <_panic>
		--nfree;
f0101816:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101819:	8b 00                	mov    (%eax),%eax
f010181b:	85 c0                	test   %eax,%eax
f010181d:	75 f7                	jne    f0101816 <mem_init+0x58f>
	assert(nfree == 0);
f010181f:	85 db                	test   %ebx,%ebx
f0101821:	0f 85 91 07 00 00    	jne    f0101fb8 <mem_init+0xd31>
	cprintf("check_page_alloc() succeeded!\n");
f0101827:	83 ec 0c             	sub    $0xc,%esp
f010182a:	68 04 43 10 f0       	push   $0xf0104304
f010182f:	e8 0b 13 00 00       	call   f0102b3f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101834:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010183b:	e8 60 f7 ff ff       	call   f0100fa0 <page_alloc>
f0101840:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101843:	83 c4 10             	add    $0x10,%esp
f0101846:	85 c0                	test   %eax,%eax
f0101848:	0f 84 83 07 00 00    	je     f0101fd1 <mem_init+0xd4a>
	assert((pp1 = page_alloc(0)));
f010184e:	83 ec 0c             	sub    $0xc,%esp
f0101851:	6a 00                	push   $0x0
f0101853:	e8 48 f7 ff ff       	call   f0100fa0 <page_alloc>
f0101858:	89 c3                	mov    %eax,%ebx
f010185a:	83 c4 10             	add    $0x10,%esp
f010185d:	85 c0                	test   %eax,%eax
f010185f:	0f 84 85 07 00 00    	je     f0101fea <mem_init+0xd63>
	assert((pp2 = page_alloc(0)));
f0101865:	83 ec 0c             	sub    $0xc,%esp
f0101868:	6a 00                	push   $0x0
f010186a:	e8 31 f7 ff ff       	call   f0100fa0 <page_alloc>
f010186f:	89 c6                	mov    %eax,%esi
f0101871:	83 c4 10             	add    $0x10,%esp
f0101874:	85 c0                	test   %eax,%eax
f0101876:	0f 84 87 07 00 00    	je     f0102003 <mem_init+0xd7c>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010187c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010187f:	0f 84 97 07 00 00    	je     f010201c <mem_init+0xd95>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101885:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101888:	0f 84 a7 07 00 00    	je     f0102035 <mem_init+0xdae>
f010188e:	39 c3                	cmp    %eax,%ebx
f0101890:	0f 84 9f 07 00 00    	je     f0102035 <mem_init+0xdae>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101896:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f010189b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010189e:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01018a5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018a8:	83 ec 0c             	sub    $0xc,%esp
f01018ab:	6a 00                	push   $0x0
f01018ad:	e8 ee f6 ff ff       	call   f0100fa0 <page_alloc>
f01018b2:	83 c4 10             	add    $0x10,%esp
f01018b5:	85 c0                	test   %eax,%eax
f01018b7:	0f 85 91 07 00 00    	jne    f010204e <mem_init+0xdc7>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018bd:	83 ec 04             	sub    $0x4,%esp
f01018c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018c3:	50                   	push   %eax
f01018c4:	6a 00                	push   $0x0
f01018c6:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01018cc:	e8 7d f8 ff ff       	call   f010114e <page_lookup>
f01018d1:	83 c4 10             	add    $0x10,%esp
f01018d4:	85 c0                	test   %eax,%eax
f01018d6:	0f 85 8b 07 00 00    	jne    f0102067 <mem_init+0xde0>

	// there is no free memory, so we cant allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018dc:	6a 02                	push   $0x2
f01018de:	6a 00                	push   $0x0
f01018e0:	53                   	push   %ebx
f01018e1:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01018e7:	e8 05 f9 ff ff       	call   f01011f1 <page_insert>
f01018ec:	83 c4 10             	add    $0x10,%esp
f01018ef:	85 c0                	test   %eax,%eax
f01018f1:	0f 89 89 07 00 00    	jns    f0102080 <mem_init+0xdf9>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018f7:	83 ec 0c             	sub    $0xc,%esp
f01018fa:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018fd:	e8 0a f7 ff ff       	call   f010100c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101902:	6a 02                	push   $0x2
f0101904:	6a 00                	push   $0x0
f0101906:	53                   	push   %ebx
f0101907:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010190d:	e8 df f8 ff ff       	call   f01011f1 <page_insert>
f0101912:	83 c4 20             	add    $0x20,%esp
f0101915:	85 c0                	test   %eax,%eax
f0101917:	0f 85 7c 07 00 00    	jne    f0102099 <mem_init+0xe12>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010191d:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
	return (pp - pages) << PGSHIFT;
f0101923:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
f0101929:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010192c:	8b 17                	mov    (%edi),%edx
f010192e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101934:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101937:	29 c8                	sub    %ecx,%eax
f0101939:	c1 f8 03             	sar    $0x3,%eax
f010193c:	c1 e0 0c             	shl    $0xc,%eax
f010193f:	39 c2                	cmp    %eax,%edx
f0101941:	0f 85 6b 07 00 00    	jne    f01020b2 <mem_init+0xe2b>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101947:	ba 00 00 00 00       	mov    $0x0,%edx
f010194c:	89 f8                	mov    %edi,%eax
f010194e:	e8 91 f2 ff ff       	call   f0100be4 <check_va2pa>
f0101953:	89 da                	mov    %ebx,%edx
f0101955:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101958:	c1 fa 03             	sar    $0x3,%edx
f010195b:	c1 e2 0c             	shl    $0xc,%edx
f010195e:	39 d0                	cmp    %edx,%eax
f0101960:	0f 85 65 07 00 00    	jne    f01020cb <mem_init+0xe44>
	assert(pp1->pp_ref == 1);
f0101966:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010196b:	0f 85 73 07 00 00    	jne    f01020e4 <mem_init+0xe5d>
	assert(pp0->pp_ref == 1);
f0101971:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101974:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101979:	0f 85 7e 07 00 00    	jne    f01020fd <mem_init+0xe76>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010197f:	6a 02                	push   $0x2
f0101981:	68 00 10 00 00       	push   $0x1000
f0101986:	56                   	push   %esi
f0101987:	57                   	push   %edi
f0101988:	e8 64 f8 ff ff       	call   f01011f1 <page_insert>
f010198d:	83 c4 10             	add    $0x10,%esp
f0101990:	85 c0                	test   %eax,%eax
f0101992:	0f 85 7e 07 00 00    	jne    f0102116 <mem_init+0xe8f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101998:	ba 00 10 00 00       	mov    $0x1000,%edx
f010199d:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f01019a2:	e8 3d f2 ff ff       	call   f0100be4 <check_va2pa>
f01019a7:	89 f2                	mov    %esi,%edx
f01019a9:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f01019af:	c1 fa 03             	sar    $0x3,%edx
f01019b2:	c1 e2 0c             	shl    $0xc,%edx
f01019b5:	39 d0                	cmp    %edx,%eax
f01019b7:	0f 85 72 07 00 00    	jne    f010212f <mem_init+0xea8>
	assert(pp2->pp_ref == 1);
f01019bd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019c2:	0f 85 80 07 00 00    	jne    f0102148 <mem_init+0xec1>

	// should be no free memory
	assert(!page_alloc(0));
f01019c8:	83 ec 0c             	sub    $0xc,%esp
f01019cb:	6a 00                	push   $0x0
f01019cd:	e8 ce f5 ff ff       	call   f0100fa0 <page_alloc>
f01019d2:	83 c4 10             	add    $0x10,%esp
f01019d5:	85 c0                	test   %eax,%eax
f01019d7:	0f 85 84 07 00 00    	jne    f0102161 <mem_init+0xeda>

	// should be able to map pp2 at PGSIZE because its already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019dd:	6a 02                	push   $0x2
f01019df:	68 00 10 00 00       	push   $0x1000
f01019e4:	56                   	push   %esi
f01019e5:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01019eb:	e8 01 f8 ff ff       	call   f01011f1 <page_insert>
f01019f0:	83 c4 10             	add    $0x10,%esp
f01019f3:	85 c0                	test   %eax,%eax
f01019f5:	0f 85 7f 07 00 00    	jne    f010217a <mem_init+0xef3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019fb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a00:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101a05:	e8 da f1 ff ff       	call   f0100be4 <check_va2pa>
f0101a0a:	89 f2                	mov    %esi,%edx
f0101a0c:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101a12:	c1 fa 03             	sar    $0x3,%edx
f0101a15:	c1 e2 0c             	shl    $0xc,%edx
f0101a18:	39 d0                	cmp    %edx,%eax
f0101a1a:	0f 85 73 07 00 00    	jne    f0102193 <mem_init+0xf0c>
	assert(pp2->pp_ref == 1);
f0101a20:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a25:	0f 85 81 07 00 00    	jne    f01021ac <mem_init+0xf25>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a2b:	83 ec 0c             	sub    $0xc,%esp
f0101a2e:	6a 00                	push   $0x0
f0101a30:	e8 6b f5 ff ff       	call   f0100fa0 <page_alloc>
f0101a35:	83 c4 10             	add    $0x10,%esp
f0101a38:	85 c0                	test   %eax,%eax
f0101a3a:	0f 85 85 07 00 00    	jne    f01021c5 <mem_init+0xf3e>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a40:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
f0101a46:	8b 02                	mov    (%edx),%eax
f0101a48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101a4d:	89 c1                	mov    %eax,%ecx
f0101a4f:	c1 e9 0c             	shr    $0xc,%ecx
f0101a52:	3b 0d 68 89 11 f0    	cmp    0xf0118968,%ecx
f0101a58:	0f 83 80 07 00 00    	jae    f01021de <mem_init+0xf57>
	return (void *)(pa + KERNBASE);
f0101a5e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a66:	83 ec 04             	sub    $0x4,%esp
f0101a69:	6a 00                	push   $0x0
f0101a6b:	68 00 10 00 00       	push   $0x1000
f0101a70:	52                   	push   %edx
f0101a71:	e8 ce f5 ff ff       	call   f0101044 <pgdir_walk>
f0101a76:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a79:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a7c:	83 c4 10             	add    $0x10,%esp
f0101a7f:	39 d0                	cmp    %edx,%eax
f0101a81:	0f 85 6c 07 00 00    	jne    f01021f3 <mem_init+0xf6c>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a87:	6a 06                	push   $0x6
f0101a89:	68 00 10 00 00       	push   $0x1000
f0101a8e:	56                   	push   %esi
f0101a8f:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a95:	e8 57 f7 ff ff       	call   f01011f1 <page_insert>
f0101a9a:	83 c4 10             	add    $0x10,%esp
f0101a9d:	85 c0                	test   %eax,%eax
f0101a9f:	0f 85 67 07 00 00    	jne    f010220c <mem_init+0xf85>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa5:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101aab:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ab0:	89 f8                	mov    %edi,%eax
f0101ab2:	e8 2d f1 ff ff       	call   f0100be4 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101ab7:	89 f2                	mov    %esi,%edx
f0101ab9:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101abf:	c1 fa 03             	sar    $0x3,%edx
f0101ac2:	c1 e2 0c             	shl    $0xc,%edx
f0101ac5:	39 d0                	cmp    %edx,%eax
f0101ac7:	0f 85 58 07 00 00    	jne    f0102225 <mem_init+0xf9e>
	assert(pp2->pp_ref == 1);
f0101acd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ad2:	0f 85 66 07 00 00    	jne    f010223e <mem_init+0xfb7>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ad8:	83 ec 04             	sub    $0x4,%esp
f0101adb:	6a 00                	push   $0x0
f0101add:	68 00 10 00 00       	push   $0x1000
f0101ae2:	57                   	push   %edi
f0101ae3:	e8 5c f5 ff ff       	call   f0101044 <pgdir_walk>
f0101ae8:	83 c4 10             	add    $0x10,%esp
f0101aeb:	f6 00 04             	testb  $0x4,(%eax)
f0101aee:	0f 84 63 07 00 00    	je     f0102257 <mem_init+0xfd0>
	assert(kern_pgdir[0] & PTE_U);
f0101af4:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101af9:	f6 00 04             	testb  $0x4,(%eax)
f0101afc:	0f 84 6e 07 00 00    	je     f0102270 <mem_init+0xfe9>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b02:	6a 02                	push   $0x2
f0101b04:	68 00 10 00 00       	push   $0x1000
f0101b09:	56                   	push   %esi
f0101b0a:	50                   	push   %eax
f0101b0b:	e8 e1 f6 ff ff       	call   f01011f1 <page_insert>
f0101b10:	83 c4 10             	add    $0x10,%esp
f0101b13:	85 c0                	test   %eax,%eax
f0101b15:	0f 85 6e 07 00 00    	jne    f0102289 <mem_init+0x1002>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b1b:	83 ec 04             	sub    $0x4,%esp
f0101b1e:	6a 00                	push   $0x0
f0101b20:	68 00 10 00 00       	push   $0x1000
f0101b25:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101b2b:	e8 14 f5 ff ff       	call   f0101044 <pgdir_walk>
f0101b30:	83 c4 10             	add    $0x10,%esp
f0101b33:	f6 00 02             	testb  $0x2,(%eax)
f0101b36:	0f 84 66 07 00 00    	je     f01022a2 <mem_init+0x101b>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b3c:	83 ec 04             	sub    $0x4,%esp
f0101b3f:	6a 00                	push   $0x0
f0101b41:	68 00 10 00 00       	push   $0x1000
f0101b46:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101b4c:	e8 f3 f4 ff ff       	call   f0101044 <pgdir_walk>
f0101b51:	83 c4 10             	add    $0x10,%esp
f0101b54:	f6 00 04             	testb  $0x4,(%eax)
f0101b57:	0f 85 5e 07 00 00    	jne    f01022bb <mem_init+0x1034>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b5d:	6a 02                	push   $0x2
f0101b5f:	68 00 00 40 00       	push   $0x400000
f0101b64:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b67:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101b6d:	e8 7f f6 ff ff       	call   f01011f1 <page_insert>
f0101b72:	83 c4 10             	add    $0x10,%esp
f0101b75:	85 c0                	test   %eax,%eax
f0101b77:	0f 89 57 07 00 00    	jns    f01022d4 <mem_init+0x104d>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b7d:	6a 02                	push   $0x2
f0101b7f:	68 00 10 00 00       	push   $0x1000
f0101b84:	53                   	push   %ebx
f0101b85:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101b8b:	e8 61 f6 ff ff       	call   f01011f1 <page_insert>
f0101b90:	83 c4 10             	add    $0x10,%esp
f0101b93:	85 c0                	test   %eax,%eax
f0101b95:	0f 85 52 07 00 00    	jne    f01022ed <mem_init+0x1066>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b9b:	83 ec 04             	sub    $0x4,%esp
f0101b9e:	6a 00                	push   $0x0
f0101ba0:	68 00 10 00 00       	push   $0x1000
f0101ba5:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101bab:	e8 94 f4 ff ff       	call   f0101044 <pgdir_walk>
f0101bb0:	83 c4 10             	add    $0x10,%esp
f0101bb3:	f6 00 04             	testb  $0x4,(%eax)
f0101bb6:	0f 85 4a 07 00 00    	jne    f0102306 <mem_init+0x107f>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bbc:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101bc2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc7:	89 f8                	mov    %edi,%eax
f0101bc9:	e8 16 f0 ff ff       	call   f0100be4 <check_va2pa>
f0101bce:	89 c1                	mov    %eax,%ecx
f0101bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bd3:	89 d8                	mov    %ebx,%eax
f0101bd5:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101bdb:	c1 f8 03             	sar    $0x3,%eax
f0101bde:	c1 e0 0c             	shl    $0xc,%eax
f0101be1:	39 c1                	cmp    %eax,%ecx
f0101be3:	0f 85 36 07 00 00    	jne    f010231f <mem_init+0x1098>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101be9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bee:	89 f8                	mov    %edi,%eax
f0101bf0:	e8 ef ef ff ff       	call   f0100be4 <check_va2pa>
f0101bf5:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101bf8:	0f 85 3a 07 00 00    	jne    f0102338 <mem_init+0x10b1>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101bfe:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c03:	0f 85 48 07 00 00    	jne    f0102351 <mem_init+0x10ca>
	assert(pp2->pp_ref == 0);
f0101c09:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c0e:	0f 85 56 07 00 00    	jne    f010236a <mem_init+0x10e3>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c14:	83 ec 0c             	sub    $0xc,%esp
f0101c17:	6a 00                	push   $0x0
f0101c19:	e8 82 f3 ff ff       	call   f0100fa0 <page_alloc>
f0101c1e:	83 c4 10             	add    $0x10,%esp
f0101c21:	39 c6                	cmp    %eax,%esi
f0101c23:	0f 85 5a 07 00 00    	jne    f0102383 <mem_init+0x10fc>
f0101c29:	85 c0                	test   %eax,%eax
f0101c2b:	0f 84 52 07 00 00    	je     f0102383 <mem_init+0x10fc>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c31:	83 ec 08             	sub    $0x8,%esp
f0101c34:	6a 00                	push   $0x0
f0101c36:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101c3c:	e8 73 f5 ff ff       	call   f01011b4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c41:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101c47:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c4c:	89 f8                	mov    %edi,%eax
f0101c4e:	e8 91 ef ff ff       	call   f0100be4 <check_va2pa>
f0101c53:	83 c4 10             	add    $0x10,%esp
f0101c56:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c59:	0f 85 3d 07 00 00    	jne    f010239c <mem_init+0x1115>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c5f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c64:	89 f8                	mov    %edi,%eax
f0101c66:	e8 79 ef ff ff       	call   f0100be4 <check_va2pa>
f0101c6b:	89 da                	mov    %ebx,%edx
f0101c6d:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101c73:	c1 fa 03             	sar    $0x3,%edx
f0101c76:	c1 e2 0c             	shl    $0xc,%edx
f0101c79:	39 d0                	cmp    %edx,%eax
f0101c7b:	0f 85 34 07 00 00    	jne    f01023b5 <mem_init+0x112e>
	assert(pp1->pp_ref == 1);
f0101c81:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c86:	0f 85 42 07 00 00    	jne    f01023ce <mem_init+0x1147>
	assert(pp2->pp_ref == 0);
f0101c8c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c91:	0f 85 50 07 00 00    	jne    f01023e7 <mem_init+0x1160>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101c97:	6a 00                	push   $0x0
f0101c99:	68 00 10 00 00       	push   $0x1000
f0101c9e:	53                   	push   %ebx
f0101c9f:	57                   	push   %edi
f0101ca0:	e8 4c f5 ff ff       	call   f01011f1 <page_insert>
f0101ca5:	83 c4 10             	add    $0x10,%esp
f0101ca8:	85 c0                	test   %eax,%eax
f0101caa:	0f 85 50 07 00 00    	jne    f0102400 <mem_init+0x1179>
	assert(pp1->pp_ref);
f0101cb0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cb5:	0f 84 5e 07 00 00    	je     f0102419 <mem_init+0x1192>
	assert(pp1->pp_link == NULL);
f0101cbb:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101cbe:	0f 85 6e 07 00 00    	jne    f0102432 <mem_init+0x11ab>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101cc4:	83 ec 08             	sub    $0x8,%esp
f0101cc7:	68 00 10 00 00       	push   $0x1000
f0101ccc:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101cd2:	e8 dd f4 ff ff       	call   f01011b4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cd7:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101cdd:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ce2:	89 f8                	mov    %edi,%eax
f0101ce4:	e8 fb ee ff ff       	call   f0100be4 <check_va2pa>
f0101ce9:	83 c4 10             	add    $0x10,%esp
f0101cec:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cef:	0f 85 56 07 00 00    	jne    f010244b <mem_init+0x11c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101cf5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cfa:	89 f8                	mov    %edi,%eax
f0101cfc:	e8 e3 ee ff ff       	call   f0100be4 <check_va2pa>
f0101d01:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d04:	0f 85 5a 07 00 00    	jne    f0102464 <mem_init+0x11dd>
	assert(pp1->pp_ref == 0);
f0101d0a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d0f:	0f 85 68 07 00 00    	jne    f010247d <mem_init+0x11f6>
	assert(pp2->pp_ref == 0);
f0101d15:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d1a:	0f 85 76 07 00 00    	jne    f0102496 <mem_init+0x120f>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d20:	83 ec 0c             	sub    $0xc,%esp
f0101d23:	6a 00                	push   $0x0
f0101d25:	e8 76 f2 ff ff       	call   f0100fa0 <page_alloc>
f0101d2a:	83 c4 10             	add    $0x10,%esp
f0101d2d:	85 c0                	test   %eax,%eax
f0101d2f:	0f 84 7a 07 00 00    	je     f01024af <mem_init+0x1228>
f0101d35:	39 c3                	cmp    %eax,%ebx
f0101d37:	0f 85 72 07 00 00    	jne    f01024af <mem_init+0x1228>

	// should be no free memory
	assert(!page_alloc(0));
f0101d3d:	83 ec 0c             	sub    $0xc,%esp
f0101d40:	6a 00                	push   $0x0
f0101d42:	e8 59 f2 ff ff       	call   f0100fa0 <page_alloc>
f0101d47:	83 c4 10             	add    $0x10,%esp
f0101d4a:	85 c0                	test   %eax,%eax
f0101d4c:	0f 85 76 07 00 00    	jne    f01024c8 <mem_init+0x1241>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d52:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101d58:	8b 11                	mov    (%ecx),%edx
f0101d5a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d63:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101d69:	c1 f8 03             	sar    $0x3,%eax
f0101d6c:	c1 e0 0c             	shl    $0xc,%eax
f0101d6f:	39 c2                	cmp    %eax,%edx
f0101d71:	0f 85 6a 07 00 00    	jne    f01024e1 <mem_init+0x125a>
	kern_pgdir[0] = 0;
f0101d77:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d80:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d85:	0f 85 6f 07 00 00    	jne    f01024fa <mem_init+0x1273>
	pp0->pp_ref = 0;
f0101d8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d8e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101d94:	83 ec 0c             	sub    $0xc,%esp
f0101d97:	50                   	push   %eax
f0101d98:	e8 6f f2 ff ff       	call   f010100c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101d9d:	83 c4 0c             	add    $0xc,%esp
f0101da0:	6a 01                	push   $0x1
f0101da2:	68 00 10 40 00       	push   $0x401000
f0101da7:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101dad:	e8 92 f2 ff ff       	call   f0101044 <pgdir_walk>
f0101db2:	89 c7                	mov    %eax,%edi
f0101db4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101db7:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101dbc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dbf:	8b 40 04             	mov    0x4(%eax),%eax
f0101dc2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101dc7:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0101dcd:	89 c2                	mov    %eax,%edx
f0101dcf:	c1 ea 0c             	shr    $0xc,%edx
f0101dd2:	83 c4 10             	add    $0x10,%esp
f0101dd5:	39 ca                	cmp    %ecx,%edx
f0101dd7:	0f 83 36 07 00 00    	jae    f0102513 <mem_init+0x128c>
	assert(ptep == ptep1 + PTX(va));
f0101ddd:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101de2:	39 c7                	cmp    %eax,%edi
f0101de4:	0f 85 3e 07 00 00    	jne    f0102528 <mem_init+0x12a1>
	kern_pgdir[PDX(va)] = 0;
f0101dea:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ded:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101df4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101df7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101dfd:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101e03:	c1 f8 03             	sar    $0x3,%eax
f0101e06:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e09:	89 c2                	mov    %eax,%edx
f0101e0b:	c1 ea 0c             	shr    $0xc,%edx
f0101e0e:	39 d1                	cmp    %edx,%ecx
f0101e10:	0f 86 2b 07 00 00    	jbe    f0102541 <mem_init+0x12ba>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e16:	83 ec 04             	sub    $0x4,%esp
f0101e19:	68 00 10 00 00       	push   $0x1000
f0101e1e:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e23:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e28:	50                   	push   %eax
f0101e29:	e8 b2 18 00 00       	call   f01036e0 <memset>
	page_free(pp0);
f0101e2e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101e31:	89 3c 24             	mov    %edi,(%esp)
f0101e34:	e8 d3 f1 ff ff       	call   f010100c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e39:	83 c4 0c             	add    $0xc,%esp
f0101e3c:	6a 01                	push   $0x1
f0101e3e:	6a 00                	push   $0x0
f0101e40:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101e46:	e8 f9 f1 ff ff       	call   f0101044 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e4b:	89 fa                	mov    %edi,%edx
f0101e4d:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
f0101e53:	c1 fa 03             	sar    $0x3,%edx
f0101e56:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e59:	89 d0                	mov    %edx,%eax
f0101e5b:	c1 e8 0c             	shr    $0xc,%eax
f0101e5e:	83 c4 10             	add    $0x10,%esp
f0101e61:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101e67:	0f 83 e6 06 00 00    	jae    f0102553 <mem_init+0x12cc>
	return (void *)(pa + KERNBASE);
f0101e6d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101e73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101e76:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e7c:	f6 00 01             	testb  $0x1,(%eax)
f0101e7f:	0f 85 e0 06 00 00    	jne    f0102565 <mem_init+0x12de>
f0101e85:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101e88:	39 c2                	cmp    %eax,%edx
f0101e8a:	75 f0                	jne    f0101e7c <mem_init+0xbf5>
	kern_pgdir[0] = 0;
f0101e8c:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101e91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101e97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e9a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101ea0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ea3:	89 0d 3c 85 11 f0    	mov    %ecx,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101ea9:	83 ec 0c             	sub    $0xc,%esp
f0101eac:	50                   	push   %eax
f0101ead:	e8 5a f1 ff ff       	call   f010100c <page_free>
	page_free(pp1);
f0101eb2:	89 1c 24             	mov    %ebx,(%esp)
f0101eb5:	e8 52 f1 ff ff       	call   f010100c <page_free>
	page_free(pp2);
f0101eba:	89 34 24             	mov    %esi,(%esp)
f0101ebd:	e8 4a f1 ff ff       	call   f010100c <page_free>

	cprintf("check_page() succeeded!\n");
f0101ec2:	c7 04 24 68 4b 10 f0 	movl   $0xf0104b68,(%esp)
f0101ec9:	e8 71 0c 00 00       	call   f0102b3f <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0101ece:	a1 70 89 11 f0       	mov    0xf0118970,%eax
	if ((uint32_t)kva < KERNBASE)
f0101ed3:	83 c4 10             	add    $0x10,%esp
f0101ed6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101edb:	0f 86 9d 06 00 00    	jbe    f010257e <mem_init+0x12f7>
f0101ee1:	83 ec 08             	sub    $0x8,%esp
f0101ee4:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0101ee6:	05 00 00 00 10       	add    $0x10000000,%eax
f0101eeb:	50                   	push   %eax
f0101eec:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101ef1:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101ef6:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101efb:	e8 d7 f1 ff ff       	call   f01010d7 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101f00:	83 c4 10             	add    $0x10,%esp
f0101f03:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0101f08:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101f0d:	0f 86 80 06 00 00    	jbe    f0102593 <mem_init+0x130c>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0101f13:	83 ec 08             	sub    $0x8,%esp
f0101f16:	6a 02                	push   $0x2
f0101f18:	68 00 e0 10 00       	push   $0x10e000
f0101f1d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101f22:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101f27:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101f2c:	e8 a6 f1 ff ff       	call   f01010d7 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0101f31:	83 c4 08             	add    $0x8,%esp
f0101f34:	6a 02                	push   $0x2
f0101f36:	6a 00                	push   $0x0
f0101f38:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101f3d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101f42:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101f47:	e8 8b f1 ff ff       	call   f01010d7 <boot_map_region>
	pgdir = kern_pgdir;
f0101f4c:	8b 1d 6c 89 11 f0    	mov    0xf011896c,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101f52:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101f57:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f5a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101f61:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101f66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101f69:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0101f6e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101f71:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101f74:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0101f7a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f0101f7d:	be 00 00 00 00       	mov    $0x0,%esi
f0101f82:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0101f85:	0f 86 4d 06 00 00    	jbe    f01025d8 <mem_init+0x1351>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101f8b:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0101f91:	89 d8                	mov    %ebx,%eax
f0101f93:	e8 4c ec ff ff       	call   f0100be4 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101f98:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0101f9f:	0f 86 03 06 00 00    	jbe    f01025a8 <mem_init+0x1321>
f0101fa5:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0101fa8:	39 c2                	cmp    %eax,%edx
f0101faa:	0f 85 0f 06 00 00    	jne    f01025bf <mem_init+0x1338>
	for (i = 0; i < n; i += PGSIZE)
f0101fb0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101fb6:	eb ca                	jmp    f0101f82 <mem_init+0xcfb>
	assert(nfree == 0);
f0101fb8:	68 91 4a 10 f0       	push   $0xf0104a91
f0101fbd:	68 f6 48 10 f0       	push   $0xf01048f6
f0101fc2:	68 8a 02 00 00       	push   $0x28a
f0101fc7:	68 d0 48 10 f0       	push   $0xf01048d0
f0101fcc:	e8 ba e0 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0101fd1:	68 9f 49 10 f0       	push   $0xf010499f
f0101fd6:	68 f6 48 10 f0       	push   $0xf01048f6
f0101fdb:	68 e3 02 00 00       	push   $0x2e3
f0101fe0:	68 d0 48 10 f0       	push   $0xf01048d0
f0101fe5:	e8 a1 e0 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101fea:	68 b5 49 10 f0       	push   $0xf01049b5
f0101fef:	68 f6 48 10 f0       	push   $0xf01048f6
f0101ff4:	68 e4 02 00 00       	push   $0x2e4
f0101ff9:	68 d0 48 10 f0       	push   $0xf01048d0
f0101ffe:	e8 88 e0 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102003:	68 cb 49 10 f0       	push   $0xf01049cb
f0102008:	68 f6 48 10 f0       	push   $0xf01048f6
f010200d:	68 e5 02 00 00       	push   $0x2e5
f0102012:	68 d0 48 10 f0       	push   $0xf01048d0
f0102017:	e8 6f e0 ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f010201c:	68 e1 49 10 f0       	push   $0xf01049e1
f0102021:	68 f6 48 10 f0       	push   $0xf01048f6
f0102026:	68 e8 02 00 00       	push   $0x2e8
f010202b:	68 d0 48 10 f0       	push   $0xf01048d0
f0102030:	e8 56 e0 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102035:	68 e4 42 10 f0       	push   $0xf01042e4
f010203a:	68 f6 48 10 f0       	push   $0xf01048f6
f010203f:	68 e9 02 00 00       	push   $0x2e9
f0102044:	68 d0 48 10 f0       	push   $0xf01048d0
f0102049:	e8 3d e0 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010204e:	68 4a 4a 10 f0       	push   $0xf0104a4a
f0102053:	68 f6 48 10 f0       	push   $0xf01048f6
f0102058:	68 f0 02 00 00       	push   $0x2f0
f010205d:	68 d0 48 10 f0       	push   $0xf01048d0
f0102062:	e8 24 e0 ff ff       	call   f010008b <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102067:	68 24 43 10 f0       	push   $0xf0104324
f010206c:	68 f6 48 10 f0       	push   $0xf01048f6
f0102071:	68 f3 02 00 00       	push   $0x2f3
f0102076:	68 d0 48 10 f0       	push   $0xf01048d0
f010207b:	e8 0b e0 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102080:	68 5c 43 10 f0       	push   $0xf010435c
f0102085:	68 f6 48 10 f0       	push   $0xf01048f6
f010208a:	68 f6 02 00 00       	push   $0x2f6
f010208f:	68 d0 48 10 f0       	push   $0xf01048d0
f0102094:	e8 f2 df ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102099:	68 8c 43 10 f0       	push   $0xf010438c
f010209e:	68 f6 48 10 f0       	push   $0xf01048f6
f01020a3:	68 fa 02 00 00       	push   $0x2fa
f01020a8:	68 d0 48 10 f0       	push   $0xf01048d0
f01020ad:	e8 d9 df ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01020b2:	68 bc 43 10 f0       	push   $0xf01043bc
f01020b7:	68 f6 48 10 f0       	push   $0xf01048f6
f01020bc:	68 fb 02 00 00       	push   $0x2fb
f01020c1:	68 d0 48 10 f0       	push   $0xf01048d0
f01020c6:	e8 c0 df ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01020cb:	68 e4 43 10 f0       	push   $0xf01043e4
f01020d0:	68 f6 48 10 f0       	push   $0xf01048f6
f01020d5:	68 fc 02 00 00       	push   $0x2fc
f01020da:	68 d0 48 10 f0       	push   $0xf01048d0
f01020df:	e8 a7 df ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01020e4:	68 9c 4a 10 f0       	push   $0xf0104a9c
f01020e9:	68 f6 48 10 f0       	push   $0xf01048f6
f01020ee:	68 fd 02 00 00       	push   $0x2fd
f01020f3:	68 d0 48 10 f0       	push   $0xf01048d0
f01020f8:	e8 8e df ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01020fd:	68 ad 4a 10 f0       	push   $0xf0104aad
f0102102:	68 f6 48 10 f0       	push   $0xf01048f6
f0102107:	68 fe 02 00 00       	push   $0x2fe
f010210c:	68 d0 48 10 f0       	push   $0xf01048d0
f0102111:	e8 75 df ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102116:	68 14 44 10 f0       	push   $0xf0104414
f010211b:	68 f6 48 10 f0       	push   $0xf01048f6
f0102120:	68 01 03 00 00       	push   $0x301
f0102125:	68 d0 48 10 f0       	push   $0xf01048d0
f010212a:	e8 5c df ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010212f:	68 50 44 10 f0       	push   $0xf0104450
f0102134:	68 f6 48 10 f0       	push   $0xf01048f6
f0102139:	68 02 03 00 00       	push   $0x302
f010213e:	68 d0 48 10 f0       	push   $0xf01048d0
f0102143:	e8 43 df ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102148:	68 be 4a 10 f0       	push   $0xf0104abe
f010214d:	68 f6 48 10 f0       	push   $0xf01048f6
f0102152:	68 03 03 00 00       	push   $0x303
f0102157:	68 d0 48 10 f0       	push   $0xf01048d0
f010215c:	e8 2a df ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0102161:	68 4a 4a 10 f0       	push   $0xf0104a4a
f0102166:	68 f6 48 10 f0       	push   $0xf01048f6
f010216b:	68 06 03 00 00       	push   $0x306
f0102170:	68 d0 48 10 f0       	push   $0xf01048d0
f0102175:	e8 11 df ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010217a:	68 14 44 10 f0       	push   $0xf0104414
f010217f:	68 f6 48 10 f0       	push   $0xf01048f6
f0102184:	68 09 03 00 00       	push   $0x309
f0102189:	68 d0 48 10 f0       	push   $0xf01048d0
f010218e:	e8 f8 de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102193:	68 50 44 10 f0       	push   $0xf0104450
f0102198:	68 f6 48 10 f0       	push   $0xf01048f6
f010219d:	68 0a 03 00 00       	push   $0x30a
f01021a2:	68 d0 48 10 f0       	push   $0xf01048d0
f01021a7:	e8 df de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01021ac:	68 be 4a 10 f0       	push   $0xf0104abe
f01021b1:	68 f6 48 10 f0       	push   $0xf01048f6
f01021b6:	68 0b 03 00 00       	push   $0x30b
f01021bb:	68 d0 48 10 f0       	push   $0xf01048d0
f01021c0:	e8 c6 de ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01021c5:	68 4a 4a 10 f0       	push   $0xf0104a4a
f01021ca:	68 f6 48 10 f0       	push   $0xf01048f6
f01021cf:	68 0f 03 00 00       	push   $0x30f
f01021d4:	68 d0 48 10 f0       	push   $0xf01048d0
f01021d9:	e8 ad de ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021de:	50                   	push   %eax
f01021df:	68 7c 41 10 f0       	push   $0xf010417c
f01021e4:	68 12 03 00 00       	push   $0x312
f01021e9:	68 d0 48 10 f0       	push   $0xf01048d0
f01021ee:	e8 98 de ff ff       	call   f010008b <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01021f3:	68 80 44 10 f0       	push   $0xf0104480
f01021f8:	68 f6 48 10 f0       	push   $0xf01048f6
f01021fd:	68 13 03 00 00       	push   $0x313
f0102202:	68 d0 48 10 f0       	push   $0xf01048d0
f0102207:	e8 7f de ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010220c:	68 c0 44 10 f0       	push   $0xf01044c0
f0102211:	68 f6 48 10 f0       	push   $0xf01048f6
f0102216:	68 16 03 00 00       	push   $0x316
f010221b:	68 d0 48 10 f0       	push   $0xf01048d0
f0102220:	e8 66 de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102225:	68 50 44 10 f0       	push   $0xf0104450
f010222a:	68 f6 48 10 f0       	push   $0xf01048f6
f010222f:	68 17 03 00 00       	push   $0x317
f0102234:	68 d0 48 10 f0       	push   $0xf01048d0
f0102239:	e8 4d de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010223e:	68 be 4a 10 f0       	push   $0xf0104abe
f0102243:	68 f6 48 10 f0       	push   $0xf01048f6
f0102248:	68 18 03 00 00       	push   $0x318
f010224d:	68 d0 48 10 f0       	push   $0xf01048d0
f0102252:	e8 34 de ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102257:	68 00 45 10 f0       	push   $0xf0104500
f010225c:	68 f6 48 10 f0       	push   $0xf01048f6
f0102261:	68 19 03 00 00       	push   $0x319
f0102266:	68 d0 48 10 f0       	push   $0xf01048d0
f010226b:	e8 1b de ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102270:	68 cf 4a 10 f0       	push   $0xf0104acf
f0102275:	68 f6 48 10 f0       	push   $0xf01048f6
f010227a:	68 1a 03 00 00       	push   $0x31a
f010227f:	68 d0 48 10 f0       	push   $0xf01048d0
f0102284:	e8 02 de ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102289:	68 14 44 10 f0       	push   $0xf0104414
f010228e:	68 f6 48 10 f0       	push   $0xf01048f6
f0102293:	68 1d 03 00 00       	push   $0x31d
f0102298:	68 d0 48 10 f0       	push   $0xf01048d0
f010229d:	e8 e9 dd ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01022a2:	68 34 45 10 f0       	push   $0xf0104534
f01022a7:	68 f6 48 10 f0       	push   $0xf01048f6
f01022ac:	68 1e 03 00 00       	push   $0x31e
f01022b1:	68 d0 48 10 f0       	push   $0xf01048d0
f01022b6:	e8 d0 dd ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01022bb:	68 68 45 10 f0       	push   $0xf0104568
f01022c0:	68 f6 48 10 f0       	push   $0xf01048f6
f01022c5:	68 1f 03 00 00       	push   $0x31f
f01022ca:	68 d0 48 10 f0       	push   $0xf01048d0
f01022cf:	e8 b7 dd ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01022d4:	68 a0 45 10 f0       	push   $0xf01045a0
f01022d9:	68 f6 48 10 f0       	push   $0xf01048f6
f01022de:	68 22 03 00 00       	push   $0x322
f01022e3:	68 d0 48 10 f0       	push   $0xf01048d0
f01022e8:	e8 9e dd ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01022ed:	68 d8 45 10 f0       	push   $0xf01045d8
f01022f2:	68 f6 48 10 f0       	push   $0xf01048f6
f01022f7:	68 25 03 00 00       	push   $0x325
f01022fc:	68 d0 48 10 f0       	push   $0xf01048d0
f0102301:	e8 85 dd ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102306:	68 68 45 10 f0       	push   $0xf0104568
f010230b:	68 f6 48 10 f0       	push   $0xf01048f6
f0102310:	68 26 03 00 00       	push   $0x326
f0102315:	68 d0 48 10 f0       	push   $0xf01048d0
f010231a:	e8 6c dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010231f:	68 14 46 10 f0       	push   $0xf0104614
f0102324:	68 f6 48 10 f0       	push   $0xf01048f6
f0102329:	68 29 03 00 00       	push   $0x329
f010232e:	68 d0 48 10 f0       	push   $0xf01048d0
f0102333:	e8 53 dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102338:	68 40 46 10 f0       	push   $0xf0104640
f010233d:	68 f6 48 10 f0       	push   $0xf01048f6
f0102342:	68 2a 03 00 00       	push   $0x32a
f0102347:	68 d0 48 10 f0       	push   $0xf01048d0
f010234c:	e8 3a dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 2);
f0102351:	68 e5 4a 10 f0       	push   $0xf0104ae5
f0102356:	68 f6 48 10 f0       	push   $0xf01048f6
f010235b:	68 2c 03 00 00       	push   $0x32c
f0102360:	68 d0 48 10 f0       	push   $0xf01048d0
f0102365:	e8 21 dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f010236a:	68 f6 4a 10 f0       	push   $0xf0104af6
f010236f:	68 f6 48 10 f0       	push   $0xf01048f6
f0102374:	68 2d 03 00 00       	push   $0x32d
f0102379:	68 d0 48 10 f0       	push   $0xf01048d0
f010237e:	e8 08 dd ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102383:	68 70 46 10 f0       	push   $0xf0104670
f0102388:	68 f6 48 10 f0       	push   $0xf01048f6
f010238d:	68 30 03 00 00       	push   $0x330
f0102392:	68 d0 48 10 f0       	push   $0xf01048d0
f0102397:	e8 ef dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010239c:	68 94 46 10 f0       	push   $0xf0104694
f01023a1:	68 f6 48 10 f0       	push   $0xf01048f6
f01023a6:	68 34 03 00 00       	push   $0x334
f01023ab:	68 d0 48 10 f0       	push   $0xf01048d0
f01023b0:	e8 d6 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023b5:	68 40 46 10 f0       	push   $0xf0104640
f01023ba:	68 f6 48 10 f0       	push   $0xf01048f6
f01023bf:	68 35 03 00 00       	push   $0x335
f01023c4:	68 d0 48 10 f0       	push   $0xf01048d0
f01023c9:	e8 bd dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01023ce:	68 9c 4a 10 f0       	push   $0xf0104a9c
f01023d3:	68 f6 48 10 f0       	push   $0xf01048f6
f01023d8:	68 36 03 00 00       	push   $0x336
f01023dd:	68 d0 48 10 f0       	push   $0xf01048d0
f01023e2:	e8 a4 dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01023e7:	68 f6 4a 10 f0       	push   $0xf0104af6
f01023ec:	68 f6 48 10 f0       	push   $0xf01048f6
f01023f1:	68 37 03 00 00       	push   $0x337
f01023f6:	68 d0 48 10 f0       	push   $0xf01048d0
f01023fb:	e8 8b dc ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102400:	68 b8 46 10 f0       	push   $0xf01046b8
f0102405:	68 f6 48 10 f0       	push   $0xf01048f6
f010240a:	68 3a 03 00 00       	push   $0x33a
f010240f:	68 d0 48 10 f0       	push   $0xf01048d0
f0102414:	e8 72 dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0102419:	68 07 4b 10 f0       	push   $0xf0104b07
f010241e:	68 f6 48 10 f0       	push   $0xf01048f6
f0102423:	68 3b 03 00 00       	push   $0x33b
f0102428:	68 d0 48 10 f0       	push   $0xf01048d0
f010242d:	e8 59 dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0102432:	68 13 4b 10 f0       	push   $0xf0104b13
f0102437:	68 f6 48 10 f0       	push   $0xf01048f6
f010243c:	68 3c 03 00 00       	push   $0x33c
f0102441:	68 d0 48 10 f0       	push   $0xf01048d0
f0102446:	e8 40 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010244b:	68 94 46 10 f0       	push   $0xf0104694
f0102450:	68 f6 48 10 f0       	push   $0xf01048f6
f0102455:	68 40 03 00 00       	push   $0x340
f010245a:	68 d0 48 10 f0       	push   $0xf01048d0
f010245f:	e8 27 dc ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102464:	68 f0 46 10 f0       	push   $0xf01046f0
f0102469:	68 f6 48 10 f0       	push   $0xf01048f6
f010246e:	68 41 03 00 00       	push   $0x341
f0102473:	68 d0 48 10 f0       	push   $0xf01048d0
f0102478:	e8 0e dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010247d:	68 28 4b 10 f0       	push   $0xf0104b28
f0102482:	68 f6 48 10 f0       	push   $0xf01048f6
f0102487:	68 42 03 00 00       	push   $0x342
f010248c:	68 d0 48 10 f0       	push   $0xf01048d0
f0102491:	e8 f5 db ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102496:	68 f6 4a 10 f0       	push   $0xf0104af6
f010249b:	68 f6 48 10 f0       	push   $0xf01048f6
f01024a0:	68 43 03 00 00       	push   $0x343
f01024a5:	68 d0 48 10 f0       	push   $0xf01048d0
f01024aa:	e8 dc db ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01024af:	68 18 47 10 f0       	push   $0xf0104718
f01024b4:	68 f6 48 10 f0       	push   $0xf01048f6
f01024b9:	68 46 03 00 00       	push   $0x346
f01024be:	68 d0 48 10 f0       	push   $0xf01048d0
f01024c3:	e8 c3 db ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01024c8:	68 4a 4a 10 f0       	push   $0xf0104a4a
f01024cd:	68 f6 48 10 f0       	push   $0xf01048f6
f01024d2:	68 49 03 00 00       	push   $0x349
f01024d7:	68 d0 48 10 f0       	push   $0xf01048d0
f01024dc:	e8 aa db ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024e1:	68 bc 43 10 f0       	push   $0xf01043bc
f01024e6:	68 f6 48 10 f0       	push   $0xf01048f6
f01024eb:	68 4c 03 00 00       	push   $0x34c
f01024f0:	68 d0 48 10 f0       	push   $0xf01048d0
f01024f5:	e8 91 db ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01024fa:	68 ad 4a 10 f0       	push   $0xf0104aad
f01024ff:	68 f6 48 10 f0       	push   $0xf01048f6
f0102504:	68 4e 03 00 00       	push   $0x34e
f0102509:	68 d0 48 10 f0       	push   $0xf01048d0
f010250e:	e8 78 db ff ff       	call   f010008b <_panic>
f0102513:	50                   	push   %eax
f0102514:	68 7c 41 10 f0       	push   $0xf010417c
f0102519:	68 55 03 00 00       	push   $0x355
f010251e:	68 d0 48 10 f0       	push   $0xf01048d0
f0102523:	e8 63 db ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102528:	68 39 4b 10 f0       	push   $0xf0104b39
f010252d:	68 f6 48 10 f0       	push   $0xf01048f6
f0102532:	68 56 03 00 00       	push   $0x356
f0102537:	68 d0 48 10 f0       	push   $0xf01048d0
f010253c:	e8 4a db ff ff       	call   f010008b <_panic>
f0102541:	50                   	push   %eax
f0102542:	68 7c 41 10 f0       	push   $0xf010417c
f0102547:	6a 52                	push   $0x52
f0102549:	68 dc 48 10 f0       	push   $0xf01048dc
f010254e:	e8 38 db ff ff       	call   f010008b <_panic>
f0102553:	52                   	push   %edx
f0102554:	68 7c 41 10 f0       	push   $0xf010417c
f0102559:	6a 52                	push   $0x52
f010255b:	68 dc 48 10 f0       	push   $0xf01048dc
f0102560:	e8 26 db ff ff       	call   f010008b <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102565:	68 51 4b 10 f0       	push   $0xf0104b51
f010256a:	68 f6 48 10 f0       	push   $0xf01048f6
f010256f:	68 60 03 00 00       	push   $0x360
f0102574:	68 d0 48 10 f0       	push   $0xf01048d0
f0102579:	e8 0d db ff ff       	call   f010008b <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010257e:	50                   	push   %eax
f010257f:	68 c0 42 10 f0       	push   $0xf01042c0
f0102584:	68 ad 00 00 00       	push   $0xad
f0102589:	68 d0 48 10 f0       	push   $0xf01048d0
f010258e:	e8 f8 da ff ff       	call   f010008b <_panic>
f0102593:	50                   	push   %eax
f0102594:	68 c0 42 10 f0       	push   $0xf01042c0
f0102599:	68 b9 00 00 00       	push   $0xb9
f010259e:	68 d0 48 10 f0       	push   $0xf01048d0
f01025a3:	e8 e3 da ff ff       	call   f010008b <_panic>
f01025a8:	ff 75 c8             	pushl  -0x38(%ebp)
f01025ab:	68 c0 42 10 f0       	push   $0xf01042c0
f01025b0:	68 a2 02 00 00       	push   $0x2a2
f01025b5:	68 d0 48 10 f0       	push   $0xf01048d0
f01025ba:	e8 cc da ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025bf:	68 3c 47 10 f0       	push   $0xf010473c
f01025c4:	68 f6 48 10 f0       	push   $0xf01048f6
f01025c9:	68 a2 02 00 00       	push   $0x2a2
f01025ce:	68 d0 48 10 f0       	push   $0xf01048d0
f01025d3:	e8 b3 da ff ff       	call   f010008b <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01025d8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01025db:	c1 e7 0c             	shl    $0xc,%edi
f01025de:	be 00 00 00 00       	mov    $0x0,%esi
f01025e3:	eb 17                	jmp    f01025fc <mem_init+0x1375>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01025e5:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01025eb:	89 d8                	mov    %ebx,%eax
f01025ed:	e8 f2 e5 ff ff       	call   f0100be4 <check_va2pa>
f01025f2:	39 c6                	cmp    %eax,%esi
f01025f4:	75 50                	jne    f0102646 <mem_init+0x13bf>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01025f6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01025fc:	39 fe                	cmp    %edi,%esi
f01025fe:	72 e5                	jb     f01025e5 <mem_init+0x135e>
f0102600:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102605:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f010260a:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f0102610:	89 f2                	mov    %esi,%edx
f0102612:	89 d8                	mov    %ebx,%eax
f0102614:	e8 cb e5 ff ff       	call   f0100be4 <check_va2pa>
f0102619:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010261c:	39 c2                	cmp    %eax,%edx
f010261e:	75 3f                	jne    f010265f <mem_init+0x13d8>
f0102620:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102626:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010262c:	75 e2                	jne    f0102610 <mem_init+0x1389>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010262e:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102633:	89 d8                	mov    %ebx,%eax
f0102635:	e8 aa e5 ff ff       	call   f0100be4 <check_va2pa>
f010263a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010263d:	75 39                	jne    f0102678 <mem_init+0x13f1>
	for (i = 0; i < NPDENTRIES; i++) {
f010263f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102644:	eb 74                	jmp    f01026ba <mem_init+0x1433>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102646:	68 70 47 10 f0       	push   $0xf0104770
f010264b:	68 f6 48 10 f0       	push   $0xf01048f6
f0102650:	68 a7 02 00 00       	push   $0x2a7
f0102655:	68 d0 48 10 f0       	push   $0xf01048d0
f010265a:	e8 2c da ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010265f:	68 98 47 10 f0       	push   $0xf0104798
f0102664:	68 f6 48 10 f0       	push   $0xf01048f6
f0102669:	68 ab 02 00 00       	push   $0x2ab
f010266e:	68 d0 48 10 f0       	push   $0xf01048d0
f0102673:	e8 13 da ff ff       	call   f010008b <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102678:	68 e0 47 10 f0       	push   $0xf01047e0
f010267d:	68 f6 48 10 f0       	push   $0xf01048f6
f0102682:	68 ac 02 00 00       	push   $0x2ac
f0102687:	68 d0 48 10 f0       	push   $0xf01048d0
f010268c:	e8 fa d9 ff ff       	call   f010008b <_panic>
			assert(pgdir[i] & PTE_P);
f0102691:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102695:	74 49                	je     f01026e0 <mem_init+0x1459>
	for (i = 0; i < NPDENTRIES; i++) {
f0102697:	83 c0 01             	add    $0x1,%eax
f010269a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010269f:	0f 87 93 00 00 00    	ja     f0102738 <mem_init+0x14b1>
		switch (i) {
f01026a5:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01026aa:	72 0e                	jb     f01026ba <mem_init+0x1433>
f01026ac:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01026b1:	76 de                	jbe    f0102691 <mem_init+0x140a>
f01026b3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01026b8:	74 d7                	je     f0102691 <mem_init+0x140a>
			if (i >= PDX(KERNBASE)) {
f01026ba:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01026bf:	77 38                	ja     f01026f9 <mem_init+0x1472>
				assert(pgdir[i] == 0);
f01026c1:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01026c5:	74 d0                	je     f0102697 <mem_init+0x1410>
f01026c7:	68 a3 4b 10 f0       	push   $0xf0104ba3
f01026cc:	68 f6 48 10 f0       	push   $0xf01048f6
f01026d1:	68 bb 02 00 00       	push   $0x2bb
f01026d6:	68 d0 48 10 f0       	push   $0xf01048d0
f01026db:	e8 ab d9 ff ff       	call   f010008b <_panic>
			assert(pgdir[i] & PTE_P);
f01026e0:	68 81 4b 10 f0       	push   $0xf0104b81
f01026e5:	68 f6 48 10 f0       	push   $0xf01048f6
f01026ea:	68 b4 02 00 00       	push   $0x2b4
f01026ef:	68 d0 48 10 f0       	push   $0xf01048d0
f01026f4:	e8 92 d9 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f01026f9:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01026fc:	f6 c2 01             	test   $0x1,%dl
f01026ff:	74 1e                	je     f010271f <mem_init+0x1498>
				assert(pgdir[i] & PTE_W);
f0102701:	f6 c2 02             	test   $0x2,%dl
f0102704:	75 91                	jne    f0102697 <mem_init+0x1410>
f0102706:	68 92 4b 10 f0       	push   $0xf0104b92
f010270b:	68 f6 48 10 f0       	push   $0xf01048f6
f0102710:	68 b9 02 00 00       	push   $0x2b9
f0102715:	68 d0 48 10 f0       	push   $0xf01048d0
f010271a:	e8 6c d9 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f010271f:	68 81 4b 10 f0       	push   $0xf0104b81
f0102724:	68 f6 48 10 f0       	push   $0xf01048f6
f0102729:	68 b8 02 00 00       	push   $0x2b8
f010272e:	68 d0 48 10 f0       	push   $0xf01048d0
f0102733:	e8 53 d9 ff ff       	call   f010008b <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102738:	83 ec 0c             	sub    $0xc,%esp
f010273b:	68 10 48 10 f0       	push   $0xf0104810
f0102740:	e8 fa 03 00 00       	call   f0102b3f <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102745:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f010274a:	83 c4 10             	add    $0x10,%esp
f010274d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102752:	0f 86 fe 01 00 00    	jbe    f0102956 <mem_init+0x16cf>
	return (physaddr_t)kva - KERNBASE;
f0102758:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010275d:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102760:	b8 00 00 00 00       	mov    $0x0,%eax
f0102765:	e8 de e4 ff ff       	call   f0100c48 <check_page_free_list>
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010276a:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010276d:	83 e0 f3             	and    $0xfffffff3,%eax
f0102770:	0d 23 00 05 80       	or     $0x80050023,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102775:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102778:	83 ec 0c             	sub    $0xc,%esp
f010277b:	6a 00                	push   $0x0
f010277d:	e8 1e e8 ff ff       	call   f0100fa0 <page_alloc>
f0102782:	89 c3                	mov    %eax,%ebx
f0102784:	83 c4 10             	add    $0x10,%esp
f0102787:	85 c0                	test   %eax,%eax
f0102789:	0f 84 dc 01 00 00    	je     f010296b <mem_init+0x16e4>
	assert((pp1 = page_alloc(0)));
f010278f:	83 ec 0c             	sub    $0xc,%esp
f0102792:	6a 00                	push   $0x0
f0102794:	e8 07 e8 ff ff       	call   f0100fa0 <page_alloc>
f0102799:	89 c7                	mov    %eax,%edi
f010279b:	83 c4 10             	add    $0x10,%esp
f010279e:	85 c0                	test   %eax,%eax
f01027a0:	0f 84 de 01 00 00    	je     f0102984 <mem_init+0x16fd>
	assert((pp2 = page_alloc(0)));
f01027a6:	83 ec 0c             	sub    $0xc,%esp
f01027a9:	6a 00                	push   $0x0
f01027ab:	e8 f0 e7 ff ff       	call   f0100fa0 <page_alloc>
f01027b0:	89 c6                	mov    %eax,%esi
f01027b2:	83 c4 10             	add    $0x10,%esp
f01027b5:	85 c0                	test   %eax,%eax
f01027b7:	0f 84 e0 01 00 00    	je     f010299d <mem_init+0x1716>
	page_free(pp0);
f01027bd:	83 ec 0c             	sub    $0xc,%esp
f01027c0:	53                   	push   %ebx
f01027c1:	e8 46 e8 ff ff       	call   f010100c <page_free>
	return (pp - pages) << PGSHIFT;
f01027c6:	89 f8                	mov    %edi,%eax
f01027c8:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01027ce:	c1 f8 03             	sar    $0x3,%eax
f01027d1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01027d4:	89 c2                	mov    %eax,%edx
f01027d6:	c1 ea 0c             	shr    $0xc,%edx
f01027d9:	83 c4 10             	add    $0x10,%esp
f01027dc:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f01027e2:	0f 83 ce 01 00 00    	jae    f01029b6 <mem_init+0x172f>
	memset(page2kva(pp1), 1, PGSIZE);
f01027e8:	83 ec 04             	sub    $0x4,%esp
f01027eb:	68 00 10 00 00       	push   $0x1000
f01027f0:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01027f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027f7:	50                   	push   %eax
f01027f8:	e8 e3 0e 00 00       	call   f01036e0 <memset>
	return (pp - pages) << PGSHIFT;
f01027fd:	89 f0                	mov    %esi,%eax
f01027ff:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0102805:	c1 f8 03             	sar    $0x3,%eax
f0102808:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010280b:	89 c2                	mov    %eax,%edx
f010280d:	c1 ea 0c             	shr    $0xc,%edx
f0102810:	83 c4 10             	add    $0x10,%esp
f0102813:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0102819:	0f 83 a9 01 00 00    	jae    f01029c8 <mem_init+0x1741>
	memset(page2kva(pp2), 2, PGSIZE);
f010281f:	83 ec 04             	sub    $0x4,%esp
f0102822:	68 00 10 00 00       	push   $0x1000
f0102827:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102829:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010282e:	50                   	push   %eax
f010282f:	e8 ac 0e 00 00       	call   f01036e0 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102834:	6a 02                	push   $0x2
f0102836:	68 00 10 00 00       	push   $0x1000
f010283b:	57                   	push   %edi
f010283c:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102842:	e8 aa e9 ff ff       	call   f01011f1 <page_insert>
	assert(pp1->pp_ref == 1);
f0102847:	83 c4 20             	add    $0x20,%esp
f010284a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010284f:	0f 85 85 01 00 00    	jne    f01029da <mem_init+0x1753>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102855:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010285c:	01 01 01 
f010285f:	0f 85 8e 01 00 00    	jne    f01029f3 <mem_init+0x176c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102865:	6a 02                	push   $0x2
f0102867:	68 00 10 00 00       	push   $0x1000
f010286c:	56                   	push   %esi
f010286d:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102873:	e8 79 e9 ff ff       	call   f01011f1 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102878:	83 c4 10             	add    $0x10,%esp
f010287b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102882:	02 02 02 
f0102885:	0f 85 81 01 00 00    	jne    f0102a0c <mem_init+0x1785>
	assert(pp2->pp_ref == 1);
f010288b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102890:	0f 85 8f 01 00 00    	jne    f0102a25 <mem_init+0x179e>
	assert(pp1->pp_ref == 0);
f0102896:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010289b:	0f 85 9d 01 00 00    	jne    f0102a3e <mem_init+0x17b7>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01028a1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01028a8:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01028ab:	89 f0                	mov    %esi,%eax
f01028ad:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01028b3:	c1 f8 03             	sar    $0x3,%eax
f01028b6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01028b9:	89 c2                	mov    %eax,%edx
f01028bb:	c1 ea 0c             	shr    $0xc,%edx
f01028be:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f01028c4:	0f 83 8d 01 00 00    	jae    f0102a57 <mem_init+0x17d0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01028ca:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01028d1:	03 03 03 
f01028d4:	0f 85 8f 01 00 00    	jne    f0102a69 <mem_init+0x17e2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01028da:	83 ec 08             	sub    $0x8,%esp
f01028dd:	68 00 10 00 00       	push   $0x1000
f01028e2:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01028e8:	e8 c7 e8 ff ff       	call   f01011b4 <page_remove>
	assert(pp2->pp_ref == 0);
f01028ed:	83 c4 10             	add    $0x10,%esp
f01028f0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028f5:	0f 85 87 01 00 00    	jne    f0102a82 <mem_init+0x17fb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028fb:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0102901:	8b 11                	mov    (%ecx),%edx
f0102903:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102909:	89 d8                	mov    %ebx,%eax
f010290b:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0102911:	c1 f8 03             	sar    $0x3,%eax
f0102914:	c1 e0 0c             	shl    $0xc,%eax
f0102917:	39 c2                	cmp    %eax,%edx
f0102919:	0f 85 7c 01 00 00    	jne    f0102a9b <mem_init+0x1814>
	kern_pgdir[0] = 0;
f010291f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102925:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010292a:	0f 85 84 01 00 00    	jne    f0102ab4 <mem_init+0x182d>
	pp0->pp_ref = 0;
f0102930:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102936:	83 ec 0c             	sub    $0xc,%esp
f0102939:	53                   	push   %ebx
f010293a:	e8 cd e6 ff ff       	call   f010100c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010293f:	c7 04 24 a4 48 10 f0 	movl   $0xf01048a4,(%esp)
f0102946:	e8 f4 01 00 00       	call   f0102b3f <cprintf>
}
f010294b:	83 c4 10             	add    $0x10,%esp
f010294e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102951:	5b                   	pop    %ebx
f0102952:	5e                   	pop    %esi
f0102953:	5f                   	pop    %edi
f0102954:	5d                   	pop    %ebp
f0102955:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102956:	50                   	push   %eax
f0102957:	68 c0 42 10 f0       	push   $0xf01042c0
f010295c:	68 cd 00 00 00       	push   $0xcd
f0102961:	68 d0 48 10 f0       	push   $0xf01048d0
f0102966:	e8 20 d7 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f010296b:	68 9f 49 10 f0       	push   $0xf010499f
f0102970:	68 f6 48 10 f0       	push   $0xf01048f6
f0102975:	68 7b 03 00 00       	push   $0x37b
f010297a:	68 d0 48 10 f0       	push   $0xf01048d0
f010297f:	e8 07 d7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102984:	68 b5 49 10 f0       	push   $0xf01049b5
f0102989:	68 f6 48 10 f0       	push   $0xf01048f6
f010298e:	68 7c 03 00 00       	push   $0x37c
f0102993:	68 d0 48 10 f0       	push   $0xf01048d0
f0102998:	e8 ee d6 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010299d:	68 cb 49 10 f0       	push   $0xf01049cb
f01029a2:	68 f6 48 10 f0       	push   $0xf01048f6
f01029a7:	68 7d 03 00 00       	push   $0x37d
f01029ac:	68 d0 48 10 f0       	push   $0xf01048d0
f01029b1:	e8 d5 d6 ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029b6:	50                   	push   %eax
f01029b7:	68 7c 41 10 f0       	push   $0xf010417c
f01029bc:	6a 52                	push   $0x52
f01029be:	68 dc 48 10 f0       	push   $0xf01048dc
f01029c3:	e8 c3 d6 ff ff       	call   f010008b <_panic>
f01029c8:	50                   	push   %eax
f01029c9:	68 7c 41 10 f0       	push   $0xf010417c
f01029ce:	6a 52                	push   $0x52
f01029d0:	68 dc 48 10 f0       	push   $0xf01048dc
f01029d5:	e8 b1 d6 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01029da:	68 9c 4a 10 f0       	push   $0xf0104a9c
f01029df:	68 f6 48 10 f0       	push   $0xf01048f6
f01029e4:	68 82 03 00 00       	push   $0x382
f01029e9:	68 d0 48 10 f0       	push   $0xf01048d0
f01029ee:	e8 98 d6 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01029f3:	68 30 48 10 f0       	push   $0xf0104830
f01029f8:	68 f6 48 10 f0       	push   $0xf01048f6
f01029fd:	68 83 03 00 00       	push   $0x383
f0102a02:	68 d0 48 10 f0       	push   $0xf01048d0
f0102a07:	e8 7f d6 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a0c:	68 54 48 10 f0       	push   $0xf0104854
f0102a11:	68 f6 48 10 f0       	push   $0xf01048f6
f0102a16:	68 85 03 00 00       	push   $0x385
f0102a1b:	68 d0 48 10 f0       	push   $0xf01048d0
f0102a20:	e8 66 d6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102a25:	68 be 4a 10 f0       	push   $0xf0104abe
f0102a2a:	68 f6 48 10 f0       	push   $0xf01048f6
f0102a2f:	68 86 03 00 00       	push   $0x386
f0102a34:	68 d0 48 10 f0       	push   $0xf01048d0
f0102a39:	e8 4d d6 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102a3e:	68 28 4b 10 f0       	push   $0xf0104b28
f0102a43:	68 f6 48 10 f0       	push   $0xf01048f6
f0102a48:	68 87 03 00 00       	push   $0x387
f0102a4d:	68 d0 48 10 f0       	push   $0xf01048d0
f0102a52:	e8 34 d6 ff ff       	call   f010008b <_panic>
f0102a57:	50                   	push   %eax
f0102a58:	68 7c 41 10 f0       	push   $0xf010417c
f0102a5d:	6a 52                	push   $0x52
f0102a5f:	68 dc 48 10 f0       	push   $0xf01048dc
f0102a64:	e8 22 d6 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102a69:	68 78 48 10 f0       	push   $0xf0104878
f0102a6e:	68 f6 48 10 f0       	push   $0xf01048f6
f0102a73:	68 89 03 00 00       	push   $0x389
f0102a78:	68 d0 48 10 f0       	push   $0xf01048d0
f0102a7d:	e8 09 d6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102a82:	68 f6 4a 10 f0       	push   $0xf0104af6
f0102a87:	68 f6 48 10 f0       	push   $0xf01048f6
f0102a8c:	68 8b 03 00 00       	push   $0x38b
f0102a91:	68 d0 48 10 f0       	push   $0xf01048d0
f0102a96:	e8 f0 d5 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102a9b:	68 bc 43 10 f0       	push   $0xf01043bc
f0102aa0:	68 f6 48 10 f0       	push   $0xf01048f6
f0102aa5:	68 8e 03 00 00       	push   $0x38e
f0102aaa:	68 d0 48 10 f0       	push   $0xf01048d0
f0102aaf:	e8 d7 d5 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0102ab4:	68 ad 4a 10 f0       	push   $0xf0104aad
f0102ab9:	68 f6 48 10 f0       	push   $0xf01048f6
f0102abe:	68 90 03 00 00       	push   $0x390
f0102ac3:	68 d0 48 10 f0       	push   $0xf01048d0
f0102ac8:	e8 be d5 ff ff       	call   f010008b <_panic>

f0102acd <tlb_invalidate>:
{
f0102acd:	55                   	push   %ebp
f0102ace:	89 e5                	mov    %esp,%ebp
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ad3:	0f 01 38             	invlpg (%eax)
}
f0102ad6:	5d                   	pop    %ebp
f0102ad7:	c3                   	ret    

f0102ad8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ad8:	55                   	push   %ebp
f0102ad9:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102adb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ade:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ae3:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102ae4:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ae9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102aea:	0f b6 c0             	movzbl %al,%eax
}
f0102aed:	5d                   	pop    %ebp
f0102aee:	c3                   	ret    

f0102aef <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102aef:	55                   	push   %ebp
f0102af0:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102af2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102af5:	ba 70 00 00 00       	mov    $0x70,%edx
f0102afa:	ee                   	out    %al,(%dx)
f0102afb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102afe:	ba 71 00 00 00       	mov    $0x71,%edx
f0102b03:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102b04:	5d                   	pop    %ebp
f0102b05:	c3                   	ret    

f0102b06 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102b06:	55                   	push   %ebp
f0102b07:	89 e5                	mov    %esp,%ebp
f0102b09:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102b0c:	ff 75 08             	pushl  0x8(%ebp)
f0102b0f:	e8 11 db ff ff       	call   f0100625 <cputchar>
	*cnt++;
}
f0102b14:	83 c4 10             	add    $0x10,%esp
f0102b17:	c9                   	leave  
f0102b18:	c3                   	ret    

f0102b19 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102b19:	55                   	push   %ebp
f0102b1a:	89 e5                	mov    %esp,%ebp
f0102b1c:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102b1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102b26:	ff 75 0c             	pushl  0xc(%ebp)
f0102b29:	ff 75 08             	pushl  0x8(%ebp)
f0102b2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102b2f:	50                   	push   %eax
f0102b30:	68 06 2b 10 f0       	push   $0xf0102b06
f0102b35:	e8 0b 04 00 00       	call   f0102f45 <vprintfmt>
	return cnt;
}
f0102b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b3d:	c9                   	leave  
f0102b3e:	c3                   	ret    

f0102b3f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102b3f:	55                   	push   %ebp
f0102b40:	89 e5                	mov    %esp,%ebp
f0102b42:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102b45:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102b48:	50                   	push   %eax
f0102b49:	ff 75 08             	pushl  0x8(%ebp)
f0102b4c:	e8 c8 ff ff ff       	call   f0102b19 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102b51:	c9                   	leave  
f0102b52:	c3                   	ret    

f0102b53 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102b53:	55                   	push   %ebp
f0102b54:	89 e5                	mov    %esp,%ebp
f0102b56:	57                   	push   %edi
f0102b57:	56                   	push   %esi
f0102b58:	53                   	push   %ebx
f0102b59:	83 ec 14             	sub    $0x14,%esp
f0102b5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102b5f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102b62:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102b65:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102b68:	8b 32                	mov    (%edx),%esi
f0102b6a:	8b 01                	mov    (%ecx),%eax
f0102b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102b6f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102b76:	eb 2f                	jmp    f0102ba7 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102b78:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0102b7b:	39 c6                	cmp    %eax,%esi
f0102b7d:	7f 49                	jg     f0102bc8 <stab_binsearch+0x75>
f0102b7f:	0f b6 0a             	movzbl (%edx),%ecx
f0102b82:	83 ea 0c             	sub    $0xc,%edx
f0102b85:	39 f9                	cmp    %edi,%ecx
f0102b87:	75 ef                	jne    f0102b78 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102b89:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102b8c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102b8f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102b93:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102b96:	73 35                	jae    f0102bcd <stab_binsearch+0x7a>
			*region_left = m;
f0102b98:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102b9b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0102b9d:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0102ba0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102ba7:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0102baa:	7f 4e                	jg     f0102bfa <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0102bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102baf:	01 f0                	add    %esi,%eax
f0102bb1:	89 c3                	mov    %eax,%ebx
f0102bb3:	c1 eb 1f             	shr    $0x1f,%ebx
f0102bb6:	01 c3                	add    %eax,%ebx
f0102bb8:	d1 fb                	sar    %ebx
f0102bba:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102bbd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102bc0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102bc4:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102bc6:	eb b3                	jmp    f0102b7b <stab_binsearch+0x28>
			l = true_m + 1;
f0102bc8:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0102bcb:	eb da                	jmp    f0102ba7 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0102bcd:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102bd0:	76 14                	jbe    f0102be6 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102bd2:	83 e8 01             	sub    $0x1,%eax
f0102bd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102bd8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102bdb:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0102bdd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102be4:	eb c1                	jmp    f0102ba7 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102be6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102be9:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102beb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102bef:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102bf1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102bf8:	eb ad                	jmp    f0102ba7 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0102bfa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102bfe:	74 16                	je     f0102c16 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c03:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102c05:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102c08:	8b 0e                	mov    (%esi),%ecx
f0102c0a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102c0d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102c10:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0102c14:	eb 12                	jmp    f0102c28 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0102c16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c19:	8b 00                	mov    (%eax),%eax
f0102c1b:	83 e8 01             	sub    $0x1,%eax
f0102c1e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102c21:	89 07                	mov    %eax,(%edi)
f0102c23:	eb 16                	jmp    f0102c3b <stab_binsearch+0xe8>
		     l--)
f0102c25:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0102c28:	39 c1                	cmp    %eax,%ecx
f0102c2a:	7d 0a                	jge    f0102c36 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0102c2c:	0f b6 1a             	movzbl (%edx),%ebx
f0102c2f:	83 ea 0c             	sub    $0xc,%edx
f0102c32:	39 fb                	cmp    %edi,%ebx
f0102c34:	75 ef                	jne    f0102c25 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0102c36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c39:	89 07                	mov    %eax,(%edi)
	}
}
f0102c3b:	83 c4 14             	add    $0x14,%esp
f0102c3e:	5b                   	pop    %ebx
f0102c3f:	5e                   	pop    %esi
f0102c40:	5f                   	pop    %edi
f0102c41:	5d                   	pop    %ebp
f0102c42:	c3                   	ret    

f0102c43 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102c43:	55                   	push   %ebp
f0102c44:	89 e5                	mov    %esp,%ebp
f0102c46:	57                   	push   %edi
f0102c47:	56                   	push   %esi
f0102c48:	53                   	push   %ebx
f0102c49:	83 ec 3c             	sub    $0x3c,%esp
f0102c4c:	8b 75 08             	mov    0x8(%ebp),%esi
f0102c4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102c52:	c7 03 b1 4b 10 f0    	movl   $0xf0104bb1,(%ebx)
	info->eip_line = 0;
f0102c58:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102c5f:	c7 43 08 b1 4b 10 f0 	movl   $0xf0104bb1,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102c66:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102c6d:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102c70:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102c77:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102c7d:	0f 86 18 01 00 00    	jbe    f0102d9b <debuginfo_eip+0x158>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102c83:	b8 d1 d9 10 f0       	mov    $0xf010d9d1,%eax
f0102c88:	3d e1 ba 10 f0       	cmp    $0xf010bae1,%eax
f0102c8d:	0f 86 a7 01 00 00    	jbe    f0102e3a <debuginfo_eip+0x1f7>
f0102c93:	80 3d d0 d9 10 f0 00 	cmpb   $0x0,0xf010d9d0
f0102c9a:	0f 85 a1 01 00 00    	jne    f0102e41 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102ca0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102ca7:	b8 e0 ba 10 f0       	mov    $0xf010bae0,%eax
f0102cac:	2d f0 4d 10 f0       	sub    $0xf0104df0,%eax
f0102cb1:	c1 f8 02             	sar    $0x2,%eax
f0102cb4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102cba:	83 e8 01             	sub    $0x1,%eax
f0102cbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102cc0:	83 ec 08             	sub    $0x8,%esp
f0102cc3:	56                   	push   %esi
f0102cc4:	6a 64                	push   $0x64
f0102cc6:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102cc9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102ccc:	b8 f0 4d 10 f0       	mov    $0xf0104df0,%eax
f0102cd1:	e8 7d fe ff ff       	call   f0102b53 <stab_binsearch>
	if (lfile == 0)
f0102cd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cd9:	83 c4 10             	add    $0x10,%esp
f0102cdc:	85 c0                	test   %eax,%eax
f0102cde:	0f 84 64 01 00 00    	je     f0102e48 <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102ce4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cea:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102ced:	83 ec 08             	sub    $0x8,%esp
f0102cf0:	56                   	push   %esi
f0102cf1:	6a 24                	push   $0x24
f0102cf3:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102cf6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102cf9:	b8 f0 4d 10 f0       	mov    $0xf0104df0,%eax
f0102cfe:	e8 50 fe ff ff       	call   f0102b53 <stab_binsearch>

	if (lfun <= rfun) {
f0102d03:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d06:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d09:	83 c4 10             	add    $0x10,%esp
f0102d0c:	39 d0                	cmp    %edx,%eax
f0102d0e:	0f 8f 9b 00 00 00    	jg     f0102daf <debuginfo_eip+0x16c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102d14:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102d17:	c1 e1 02             	shl    $0x2,%ecx
f0102d1a:	8d b9 f0 4d 10 f0    	lea    -0xfefb210(%ecx),%edi
f0102d20:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102d23:	8b b9 f0 4d 10 f0    	mov    -0xfefb210(%ecx),%edi
f0102d29:	b9 d1 d9 10 f0       	mov    $0xf010d9d1,%ecx
f0102d2e:	81 e9 e1 ba 10 f0    	sub    $0xf010bae1,%ecx
f0102d34:	39 cf                	cmp    %ecx,%edi
f0102d36:	73 09                	jae    f0102d41 <debuginfo_eip+0xfe>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102d38:	81 c7 e1 ba 10 f0    	add    $0xf010bae1,%edi
f0102d3e:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102d41:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102d44:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102d47:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102d4a:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102d4c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102d4f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102d52:	83 ec 08             	sub    $0x8,%esp
f0102d55:	6a 3a                	push   $0x3a
f0102d57:	ff 73 08             	pushl  0x8(%ebx)
f0102d5a:	e8 65 09 00 00       	call   f01036c4 <strfind>
f0102d5f:	2b 43 08             	sub    0x8(%ebx),%eax
f0102d62:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102d65:	83 c4 08             	add    $0x8,%esp
f0102d68:	56                   	push   %esi
f0102d69:	6a 44                	push   $0x44
f0102d6b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102d6e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102d71:	b8 f0 4d 10 f0       	mov    $0xf0104df0,%eax
f0102d76:	e8 d8 fd ff ff       	call   f0102b53 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102d7b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102d7e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102d81:	c1 e0 02             	shl    $0x2,%eax
f0102d84:	0f b7 88 f6 4d 10 f0 	movzwl -0xfefb20a(%eax),%ecx
f0102d8b:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102d8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102d91:	05 f4 4d 10 f0       	add    $0xf0104df4,%eax
f0102d96:	83 c4 10             	add    $0x10,%esp
f0102d99:	eb 2b                	jmp    f0102dc6 <debuginfo_eip+0x183>
  	        panic("User address");
f0102d9b:	83 ec 04             	sub    $0x4,%esp
f0102d9e:	68 bb 4b 10 f0       	push   $0xf0104bbb
f0102da3:	6a 7f                	push   $0x7f
f0102da5:	68 c8 4b 10 f0       	push   $0xf0104bc8
f0102daa:	e8 dc d2 ff ff       	call   f010008b <_panic>
		info->eip_fn_addr = addr;
f0102daf:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102db2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102db5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102db8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dbb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102dbe:	eb 92                	jmp    f0102d52 <debuginfo_eip+0x10f>
f0102dc0:	83 ea 01             	sub    $0x1,%edx
f0102dc3:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102dc6:	39 d6                	cmp    %edx,%esi
f0102dc8:	7f 33                	jg     f0102dfd <debuginfo_eip+0x1ba>
	       && stabs[lline].n_type != N_SOL
f0102dca:	0f b6 08             	movzbl (%eax),%ecx
f0102dcd:	80 f9 84             	cmp    $0x84,%cl
f0102dd0:	74 0b                	je     f0102ddd <debuginfo_eip+0x19a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102dd2:	80 f9 64             	cmp    $0x64,%cl
f0102dd5:	75 e9                	jne    f0102dc0 <debuginfo_eip+0x17d>
f0102dd7:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0102ddb:	74 e3                	je     f0102dc0 <debuginfo_eip+0x17d>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102ddd:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102de0:	8b 14 85 f0 4d 10 f0 	mov    -0xfefb210(,%eax,4),%edx
f0102de7:	b8 d1 d9 10 f0       	mov    $0xf010d9d1,%eax
f0102dec:	2d e1 ba 10 f0       	sub    $0xf010bae1,%eax
f0102df1:	39 c2                	cmp    %eax,%edx
f0102df3:	73 08                	jae    f0102dfd <debuginfo_eip+0x1ba>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102df5:	81 c2 e1 ba 10 f0    	add    $0xf010bae1,%edx
f0102dfb:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102dfd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e00:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102e03:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0102e08:	39 f2                	cmp    %esi,%edx
f0102e0a:	7d 48                	jge    f0102e54 <debuginfo_eip+0x211>
		for (lline = lfun + 1;
f0102e0c:	83 c2 01             	add    $0x1,%edx
f0102e0f:	89 d0                	mov    %edx,%eax
f0102e11:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102e14:	8d 14 95 f4 4d 10 f0 	lea    -0xfefb20c(,%edx,4),%edx
f0102e1b:	eb 04                	jmp    f0102e21 <debuginfo_eip+0x1de>
			info->eip_fn_narg++;
f0102e1d:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0102e21:	39 c6                	cmp    %eax,%esi
f0102e23:	7e 2a                	jle    f0102e4f <debuginfo_eip+0x20c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102e25:	0f b6 0a             	movzbl (%edx),%ecx
f0102e28:	83 c0 01             	add    $0x1,%eax
f0102e2b:	83 c2 0c             	add    $0xc,%edx
f0102e2e:	80 f9 a0             	cmp    $0xa0,%cl
f0102e31:	74 ea                	je     f0102e1d <debuginfo_eip+0x1da>
	return 0;
f0102e33:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e38:	eb 1a                	jmp    f0102e54 <debuginfo_eip+0x211>
		return -1;
f0102e3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102e3f:	eb 13                	jmp    f0102e54 <debuginfo_eip+0x211>
f0102e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102e46:	eb 0c                	jmp    f0102e54 <debuginfo_eip+0x211>
		return -1;
f0102e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102e4d:	eb 05                	jmp    f0102e54 <debuginfo_eip+0x211>
	return 0;
f0102e4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e57:	5b                   	pop    %ebx
f0102e58:	5e                   	pop    %esi
f0102e59:	5f                   	pop    %edi
f0102e5a:	5d                   	pop    %ebp
f0102e5b:	c3                   	ret    

f0102e5c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102e5c:	55                   	push   %ebp
f0102e5d:	89 e5                	mov    %esp,%ebp
f0102e5f:	57                   	push   %edi
f0102e60:	56                   	push   %esi
f0102e61:	53                   	push   %ebx
f0102e62:	83 ec 1c             	sub    $0x1c,%esp
f0102e65:	89 c7                	mov    %eax,%edi
f0102e67:	89 d6                	mov    %edx,%esi
f0102e69:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e6c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102e6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e72:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102e75:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102e78:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e7d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102e80:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102e83:	39 d3                	cmp    %edx,%ebx
f0102e85:	72 05                	jb     f0102e8c <printnum+0x30>
f0102e87:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102e8a:	77 7a                	ja     f0102f06 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102e8c:	83 ec 0c             	sub    $0xc,%esp
f0102e8f:	ff 75 18             	pushl  0x18(%ebp)
f0102e92:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e95:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102e98:	53                   	push   %ebx
f0102e99:	ff 75 10             	pushl  0x10(%ebp)
f0102e9c:	83 ec 08             	sub    $0x8,%esp
f0102e9f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102ea2:	ff 75 e0             	pushl  -0x20(%ebp)
f0102ea5:	ff 75 dc             	pushl  -0x24(%ebp)
f0102ea8:	ff 75 d8             	pushl  -0x28(%ebp)
f0102eab:	e8 30 0a 00 00       	call   f01038e0 <__udivdi3>
f0102eb0:	83 c4 18             	add    $0x18,%esp
f0102eb3:	52                   	push   %edx
f0102eb4:	50                   	push   %eax
f0102eb5:	89 f2                	mov    %esi,%edx
f0102eb7:	89 f8                	mov    %edi,%eax
f0102eb9:	e8 9e ff ff ff       	call   f0102e5c <printnum>
f0102ebe:	83 c4 20             	add    $0x20,%esp
f0102ec1:	eb 13                	jmp    f0102ed6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102ec3:	83 ec 08             	sub    $0x8,%esp
f0102ec6:	56                   	push   %esi
f0102ec7:	ff 75 18             	pushl  0x18(%ebp)
f0102eca:	ff d7                	call   *%edi
f0102ecc:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102ecf:	83 eb 01             	sub    $0x1,%ebx
f0102ed2:	85 db                	test   %ebx,%ebx
f0102ed4:	7f ed                	jg     f0102ec3 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102ed6:	83 ec 08             	sub    $0x8,%esp
f0102ed9:	56                   	push   %esi
f0102eda:	83 ec 04             	sub    $0x4,%esp
f0102edd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102ee0:	ff 75 e0             	pushl  -0x20(%ebp)
f0102ee3:	ff 75 dc             	pushl  -0x24(%ebp)
f0102ee6:	ff 75 d8             	pushl  -0x28(%ebp)
f0102ee9:	e8 12 0b 00 00       	call   f0103a00 <__umoddi3>
f0102eee:	83 c4 14             	add    $0x14,%esp
f0102ef1:	0f be 80 d6 4b 10 f0 	movsbl -0xfefb42a(%eax),%eax
f0102ef8:	50                   	push   %eax
f0102ef9:	ff d7                	call   *%edi
}
f0102efb:	83 c4 10             	add    $0x10,%esp
f0102efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f01:	5b                   	pop    %ebx
f0102f02:	5e                   	pop    %esi
f0102f03:	5f                   	pop    %edi
f0102f04:	5d                   	pop    %ebp
f0102f05:	c3                   	ret    
f0102f06:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102f09:	eb c4                	jmp    f0102ecf <printnum+0x73>

f0102f0b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102f0b:	55                   	push   %ebp
f0102f0c:	89 e5                	mov    %esp,%ebp
f0102f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102f11:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102f15:	8b 10                	mov    (%eax),%edx
f0102f17:	3b 50 04             	cmp    0x4(%eax),%edx
f0102f1a:	73 0a                	jae    f0102f26 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102f1c:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102f1f:	89 08                	mov    %ecx,(%eax)
f0102f21:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f24:	88 02                	mov    %al,(%edx)
}
f0102f26:	5d                   	pop    %ebp
f0102f27:	c3                   	ret    

f0102f28 <printfmt>:
{
f0102f28:	55                   	push   %ebp
f0102f29:	89 e5                	mov    %esp,%ebp
f0102f2b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102f2e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102f31:	50                   	push   %eax
f0102f32:	ff 75 10             	pushl  0x10(%ebp)
f0102f35:	ff 75 0c             	pushl  0xc(%ebp)
f0102f38:	ff 75 08             	pushl  0x8(%ebp)
f0102f3b:	e8 05 00 00 00       	call   f0102f45 <vprintfmt>
}
f0102f40:	83 c4 10             	add    $0x10,%esp
f0102f43:	c9                   	leave  
f0102f44:	c3                   	ret    

f0102f45 <vprintfmt>:
{
f0102f45:	55                   	push   %ebp
f0102f46:	89 e5                	mov    %esp,%ebp
f0102f48:	57                   	push   %edi
f0102f49:	56                   	push   %esi
f0102f4a:	53                   	push   %ebx
f0102f4b:	83 ec 2c             	sub    $0x2c,%esp
f0102f4e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102f51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f54:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102f57:	e9 1f 04 00 00       	jmp    f010337b <vprintfmt+0x436>
				color = 0x0700; 
f0102f5c:	c7 05 64 89 11 f0 00 	movl   $0x700,0xf0118964
f0102f63:	07 00 00 
}
f0102f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f69:	5b                   	pop    %ebx
f0102f6a:	5e                   	pop    %esi
f0102f6b:	5f                   	pop    %edi
f0102f6c:	5d                   	pop    %ebp
f0102f6d:	c3                   	ret    
		padc = ' ';
f0102f6e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0102f72:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0102f79:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0102f80:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0102f87:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102f8c:	8d 47 01             	lea    0x1(%edi),%eax
f0102f8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f92:	0f b6 17             	movzbl (%edi),%edx
f0102f95:	8d 42 dd             	lea    -0x23(%edx),%eax
f0102f98:	3c 55                	cmp    $0x55,%al
f0102f9a:	0f 87 5e 04 00 00    	ja     f01033fe <vprintfmt+0x4b9>
f0102fa0:	0f b6 c0             	movzbl %al,%eax
f0102fa3:	ff 24 85 60 4c 10 f0 	jmp    *-0xfefb3a0(,%eax,4)
f0102faa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0102fad:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0102fb1:	eb d9                	jmp    f0102f8c <vprintfmt+0x47>
		switch (ch = *(unsigned char *) fmt++) {
f0102fb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0102fb6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102fba:	eb d0                	jmp    f0102f8c <vprintfmt+0x47>
		switch (ch = *(unsigned char *) fmt++) {
f0102fbc:	0f b6 d2             	movzbl %dl,%edx
f0102fbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0102fc2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fc7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0102fca:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102fcd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0102fd1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102fd4:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102fd7:	83 f9 09             	cmp    $0x9,%ecx
f0102fda:	0f 87 9d 00 00 00    	ja     f010307d <vprintfmt+0x138>
			for (precision = 0; ; ++fmt) {
f0102fe0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0102fe3:	eb e5                	jmp    f0102fca <vprintfmt+0x85>
	if (lflag >= 2)
f0102fe5:	83 f9 01             	cmp    $0x1,%ecx
f0102fe8:	7e 18                	jle    f0103002 <vprintfmt+0xbd>
		return va_arg(*ap, long long);
f0102fea:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fed:	8b 00                	mov    (%eax),%eax
f0102fef:	8b 7d 14             	mov    0x14(%ebp),%edi
f0102ff2:	8d 7f 08             	lea    0x8(%edi),%edi
f0102ff5:	89 7d 14             	mov    %edi,0x14(%ebp)
			color = num; 
f0102ff8:	a3 64 89 11 f0       	mov    %eax,0xf0118964
		switch (ch = *(unsigned char *) fmt++) {
f0102ffd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103000:	eb 8a                	jmp    f0102f8c <vprintfmt+0x47>
	else if (lflag)
f0103002:	85 c9                	test   %ecx,%ecx
f0103004:	75 10                	jne    f0103016 <vprintfmt+0xd1>
		return va_arg(*ap, int);
f0103006:	8b 45 14             	mov    0x14(%ebp),%eax
f0103009:	8b 00                	mov    (%eax),%eax
f010300b:	8b 7d 14             	mov    0x14(%ebp),%edi
f010300e:	8d 7f 04             	lea    0x4(%edi),%edi
f0103011:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103014:	eb e2                	jmp    f0102ff8 <vprintfmt+0xb3>
		return va_arg(*ap, long);
f0103016:	8b 45 14             	mov    0x14(%ebp),%eax
f0103019:	8b 00                	mov    (%eax),%eax
f010301b:	8b 7d 14             	mov    0x14(%ebp),%edi
f010301e:	8d 7f 04             	lea    0x4(%edi),%edi
f0103021:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103024:	eb d2                	jmp    f0102ff8 <vprintfmt+0xb3>
			precision = va_arg(ap, int);
f0103026:	8b 45 14             	mov    0x14(%ebp),%eax
f0103029:	8b 00                	mov    (%eax),%eax
f010302b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010302e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103031:	8d 40 04             	lea    0x4(%eax),%eax
f0103034:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103037:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010303a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010303e:	0f 89 48 ff ff ff    	jns    f0102f8c <vprintfmt+0x47>
				width = precision, precision = -1;
f0103044:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103047:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010304a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103051:	e9 36 ff ff ff       	jmp    f0102f8c <vprintfmt+0x47>
f0103056:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103059:	85 c0                	test   %eax,%eax
f010305b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103060:	0f 49 d0             	cmovns %eax,%edx
f0103063:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103066:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103069:	e9 1e ff ff ff       	jmp    f0102f8c <vprintfmt+0x47>
f010306e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0103071:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103078:	e9 0f ff ff ff       	jmp    f0102f8c <vprintfmt+0x47>
f010307d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103080:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103083:	eb b5                	jmp    f010303a <vprintfmt+0xf5>
			lflag++;
f0103085:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103088:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010308b:	e9 fc fe ff ff       	jmp    f0102f8c <vprintfmt+0x47>
			putch(va_arg(ap, int), putdat);
f0103090:	8b 45 14             	mov    0x14(%ebp),%eax
f0103093:	8d 78 04             	lea    0x4(%eax),%edi
f0103096:	83 ec 08             	sub    $0x8,%esp
f0103099:	53                   	push   %ebx
f010309a:	ff 30                	pushl  (%eax)
f010309c:	ff d6                	call   *%esi
			break;
f010309e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01030a1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01030a4:	e9 cf 02 00 00       	jmp    f0103378 <vprintfmt+0x433>
			err = va_arg(ap, int);
f01030a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01030ac:	8d 78 04             	lea    0x4(%eax),%edi
f01030af:	8b 00                	mov    (%eax),%eax
f01030b1:	99                   	cltd   
f01030b2:	31 d0                	xor    %edx,%eax
f01030b4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01030b6:	83 f8 07             	cmp    $0x7,%eax
f01030b9:	7f 23                	jg     f01030de <vprintfmt+0x199>
f01030bb:	8b 14 85 c0 4d 10 f0 	mov    -0xfefb240(,%eax,4),%edx
f01030c2:	85 d2                	test   %edx,%edx
f01030c4:	74 18                	je     f01030de <vprintfmt+0x199>
				printfmt(putch, putdat, "%s", p);
f01030c6:	52                   	push   %edx
f01030c7:	68 08 49 10 f0       	push   $0xf0104908
f01030cc:	53                   	push   %ebx
f01030cd:	56                   	push   %esi
f01030ce:	e8 55 fe ff ff       	call   f0102f28 <printfmt>
f01030d3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01030d6:	89 7d 14             	mov    %edi,0x14(%ebp)
f01030d9:	e9 9a 02 00 00       	jmp    f0103378 <vprintfmt+0x433>
				printfmt(putch, putdat, "error %d", err);
f01030de:	50                   	push   %eax
f01030df:	68 ee 4b 10 f0       	push   $0xf0104bee
f01030e4:	53                   	push   %ebx
f01030e5:	56                   	push   %esi
f01030e6:	e8 3d fe ff ff       	call   f0102f28 <printfmt>
f01030eb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01030ee:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01030f1:	e9 82 02 00 00       	jmp    f0103378 <vprintfmt+0x433>
			if ((p = va_arg(ap, char *)) == NULL)
f01030f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01030f9:	83 c0 04             	add    $0x4,%eax
f01030fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01030ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0103102:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103104:	85 ff                	test   %edi,%edi
f0103106:	b8 e7 4b 10 f0       	mov    $0xf0104be7,%eax
f010310b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010310e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103112:	0f 8e bd 00 00 00    	jle    f01031d5 <vprintfmt+0x290>
f0103118:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010311c:	75 0e                	jne    f010312c <vprintfmt+0x1e7>
f010311e:	89 75 08             	mov    %esi,0x8(%ebp)
f0103121:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103124:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103127:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010312a:	eb 6d                	jmp    f0103199 <vprintfmt+0x254>
				for (width -= strnlen(p, precision); width > 0; width--)
f010312c:	83 ec 08             	sub    $0x8,%esp
f010312f:	ff 75 d0             	pushl  -0x30(%ebp)
f0103132:	57                   	push   %edi
f0103133:	e8 48 04 00 00       	call   f0103580 <strnlen>
f0103138:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010313b:	29 c1                	sub    %eax,%ecx
f010313d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103140:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103143:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103147:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010314a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010314d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010314f:	eb 0f                	jmp    f0103160 <vprintfmt+0x21b>
					putch(padc, putdat);
f0103151:	83 ec 08             	sub    $0x8,%esp
f0103154:	53                   	push   %ebx
f0103155:	ff 75 e0             	pushl  -0x20(%ebp)
f0103158:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010315a:	83 ef 01             	sub    $0x1,%edi
f010315d:	83 c4 10             	add    $0x10,%esp
f0103160:	85 ff                	test   %edi,%edi
f0103162:	7f ed                	jg     f0103151 <vprintfmt+0x20c>
f0103164:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103167:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010316a:	85 c9                	test   %ecx,%ecx
f010316c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103171:	0f 49 c1             	cmovns %ecx,%eax
f0103174:	29 c1                	sub    %eax,%ecx
f0103176:	89 75 08             	mov    %esi,0x8(%ebp)
f0103179:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010317c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010317f:	89 cb                	mov    %ecx,%ebx
f0103181:	eb 16                	jmp    f0103199 <vprintfmt+0x254>
				if (altflag && (ch < ' ' || ch > '~'))
f0103183:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103187:	75 31                	jne    f01031ba <vprintfmt+0x275>
					putch(ch, putdat);
f0103189:	83 ec 08             	sub    $0x8,%esp
f010318c:	ff 75 0c             	pushl  0xc(%ebp)
f010318f:	50                   	push   %eax
f0103190:	ff 55 08             	call   *0x8(%ebp)
f0103193:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103196:	83 eb 01             	sub    $0x1,%ebx
f0103199:	83 c7 01             	add    $0x1,%edi
f010319c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01031a0:	0f be c2             	movsbl %dl,%eax
f01031a3:	85 c0                	test   %eax,%eax
f01031a5:	74 59                	je     f0103200 <vprintfmt+0x2bb>
f01031a7:	85 f6                	test   %esi,%esi
f01031a9:	78 d8                	js     f0103183 <vprintfmt+0x23e>
f01031ab:	83 ee 01             	sub    $0x1,%esi
f01031ae:	79 d3                	jns    f0103183 <vprintfmt+0x23e>
f01031b0:	89 df                	mov    %ebx,%edi
f01031b2:	8b 75 08             	mov    0x8(%ebp),%esi
f01031b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031b8:	eb 37                	jmp    f01031f1 <vprintfmt+0x2ac>
				if (altflag && (ch < ' ' || ch > '~'))
f01031ba:	0f be d2             	movsbl %dl,%edx
f01031bd:	83 ea 20             	sub    $0x20,%edx
f01031c0:	83 fa 5e             	cmp    $0x5e,%edx
f01031c3:	76 c4                	jbe    f0103189 <vprintfmt+0x244>
					putch('?', putdat);
f01031c5:	83 ec 08             	sub    $0x8,%esp
f01031c8:	ff 75 0c             	pushl  0xc(%ebp)
f01031cb:	6a 3f                	push   $0x3f
f01031cd:	ff 55 08             	call   *0x8(%ebp)
f01031d0:	83 c4 10             	add    $0x10,%esp
f01031d3:	eb c1                	jmp    f0103196 <vprintfmt+0x251>
f01031d5:	89 75 08             	mov    %esi,0x8(%ebp)
f01031d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01031db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01031de:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01031e1:	eb b6                	jmp    f0103199 <vprintfmt+0x254>
				putch(' ', putdat);
f01031e3:	83 ec 08             	sub    $0x8,%esp
f01031e6:	53                   	push   %ebx
f01031e7:	6a 20                	push   $0x20
f01031e9:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01031eb:	83 ef 01             	sub    $0x1,%edi
f01031ee:	83 c4 10             	add    $0x10,%esp
f01031f1:	85 ff                	test   %edi,%edi
f01031f3:	7f ee                	jg     f01031e3 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
f01031f5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01031f8:	89 45 14             	mov    %eax,0x14(%ebp)
f01031fb:	e9 78 01 00 00       	jmp    f0103378 <vprintfmt+0x433>
f0103200:	89 df                	mov    %ebx,%edi
f0103202:	8b 75 08             	mov    0x8(%ebp),%esi
f0103205:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103208:	eb e7                	jmp    f01031f1 <vprintfmt+0x2ac>
	if (lflag >= 2)
f010320a:	83 f9 01             	cmp    $0x1,%ecx
f010320d:	7e 3f                	jle    f010324e <vprintfmt+0x309>
		return va_arg(*ap, long long);
f010320f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103212:	8b 50 04             	mov    0x4(%eax),%edx
f0103215:	8b 00                	mov    (%eax),%eax
f0103217:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010321a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010321d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103220:	8d 40 08             	lea    0x8(%eax),%eax
f0103223:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103226:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010322a:	79 5c                	jns    f0103288 <vprintfmt+0x343>
				putch('-', putdat);
f010322c:	83 ec 08             	sub    $0x8,%esp
f010322f:	53                   	push   %ebx
f0103230:	6a 2d                	push   $0x2d
f0103232:	ff d6                	call   *%esi
				num = -(long long) num;
f0103234:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010323a:	f7 da                	neg    %edx
f010323c:	83 d1 00             	adc    $0x0,%ecx
f010323f:	f7 d9                	neg    %ecx
f0103241:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103244:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103249:	e9 10 01 00 00       	jmp    f010335e <vprintfmt+0x419>
	else if (lflag)
f010324e:	85 c9                	test   %ecx,%ecx
f0103250:	75 1b                	jne    f010326d <vprintfmt+0x328>
		return va_arg(*ap, int);
f0103252:	8b 45 14             	mov    0x14(%ebp),%eax
f0103255:	8b 00                	mov    (%eax),%eax
f0103257:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010325a:	89 c1                	mov    %eax,%ecx
f010325c:	c1 f9 1f             	sar    $0x1f,%ecx
f010325f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103262:	8b 45 14             	mov    0x14(%ebp),%eax
f0103265:	8d 40 04             	lea    0x4(%eax),%eax
f0103268:	89 45 14             	mov    %eax,0x14(%ebp)
f010326b:	eb b9                	jmp    f0103226 <vprintfmt+0x2e1>
		return va_arg(*ap, long);
f010326d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103270:	8b 00                	mov    (%eax),%eax
f0103272:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103275:	89 c1                	mov    %eax,%ecx
f0103277:	c1 f9 1f             	sar    $0x1f,%ecx
f010327a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010327d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103280:	8d 40 04             	lea    0x4(%eax),%eax
f0103283:	89 45 14             	mov    %eax,0x14(%ebp)
f0103286:	eb 9e                	jmp    f0103226 <vprintfmt+0x2e1>
			num = getint(&ap, lflag);
f0103288:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010328b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010328e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103293:	e9 c6 00 00 00       	jmp    f010335e <vprintfmt+0x419>
	if (lflag >= 2)
f0103298:	83 f9 01             	cmp    $0x1,%ecx
f010329b:	7e 18                	jle    f01032b5 <vprintfmt+0x370>
		return va_arg(*ap, unsigned long long);
f010329d:	8b 45 14             	mov    0x14(%ebp),%eax
f01032a0:	8b 10                	mov    (%eax),%edx
f01032a2:	8b 48 04             	mov    0x4(%eax),%ecx
f01032a5:	8d 40 08             	lea    0x8(%eax),%eax
f01032a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01032ab:	b8 0a 00 00 00       	mov    $0xa,%eax
f01032b0:	e9 a9 00 00 00       	jmp    f010335e <vprintfmt+0x419>
	else if (lflag)
f01032b5:	85 c9                	test   %ecx,%ecx
f01032b7:	75 1a                	jne    f01032d3 <vprintfmt+0x38e>
		return va_arg(*ap, unsigned int);
f01032b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01032bc:	8b 10                	mov    (%eax),%edx
f01032be:	b9 00 00 00 00       	mov    $0x0,%ecx
f01032c3:	8d 40 04             	lea    0x4(%eax),%eax
f01032c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01032c9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01032ce:	e9 8b 00 00 00       	jmp    f010335e <vprintfmt+0x419>
		return va_arg(*ap, unsigned long);
f01032d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01032d6:	8b 10                	mov    (%eax),%edx
f01032d8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01032dd:	8d 40 04             	lea    0x4(%eax),%eax
f01032e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01032e3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01032e8:	eb 74                	jmp    f010335e <vprintfmt+0x419>
	if (lflag >= 2)
f01032ea:	83 f9 01             	cmp    $0x1,%ecx
f01032ed:	7e 15                	jle    f0103304 <vprintfmt+0x3bf>
		return va_arg(*ap, unsigned long long);
f01032ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01032f2:	8b 10                	mov    (%eax),%edx
f01032f4:	8b 48 04             	mov    0x4(%eax),%ecx
f01032f7:	8d 40 08             	lea    0x8(%eax),%eax
f01032fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01032fd:	b8 08 00 00 00       	mov    $0x8,%eax
f0103302:	eb 5a                	jmp    f010335e <vprintfmt+0x419>
	else if (lflag)
f0103304:	85 c9                	test   %ecx,%ecx
f0103306:	75 17                	jne    f010331f <vprintfmt+0x3da>
		return va_arg(*ap, unsigned int);
f0103308:	8b 45 14             	mov    0x14(%ebp),%eax
f010330b:	8b 10                	mov    (%eax),%edx
f010330d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103312:	8d 40 04             	lea    0x4(%eax),%eax
f0103315:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103318:	b8 08 00 00 00       	mov    $0x8,%eax
f010331d:	eb 3f                	jmp    f010335e <vprintfmt+0x419>
		return va_arg(*ap, unsigned long);
f010331f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103322:	8b 10                	mov    (%eax),%edx
f0103324:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103329:	8d 40 04             	lea    0x4(%eax),%eax
f010332c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010332f:	b8 08 00 00 00       	mov    $0x8,%eax
f0103334:	eb 28                	jmp    f010335e <vprintfmt+0x419>
			putch('0', putdat);
f0103336:	83 ec 08             	sub    $0x8,%esp
f0103339:	53                   	push   %ebx
f010333a:	6a 30                	push   $0x30
f010333c:	ff d6                	call   *%esi
			putch('x', putdat);
f010333e:	83 c4 08             	add    $0x8,%esp
f0103341:	53                   	push   %ebx
f0103342:	6a 78                	push   $0x78
f0103344:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103346:	8b 45 14             	mov    0x14(%ebp),%eax
f0103349:	8b 10                	mov    (%eax),%edx
f010334b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103350:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103353:	8d 40 04             	lea    0x4(%eax),%eax
f0103356:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103359:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010335e:	83 ec 0c             	sub    $0xc,%esp
f0103361:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103365:	57                   	push   %edi
f0103366:	ff 75 e0             	pushl  -0x20(%ebp)
f0103369:	50                   	push   %eax
f010336a:	51                   	push   %ecx
f010336b:	52                   	push   %edx
f010336c:	89 da                	mov    %ebx,%edx
f010336e:	89 f0                	mov    %esi,%eax
f0103370:	e8 e7 fa ff ff       	call   f0102e5c <printnum>
			break;
f0103375:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010337b:	83 c7 01             	add    $0x1,%edi
f010337e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103382:	83 f8 25             	cmp    $0x25,%eax
f0103385:	0f 84 e3 fb ff ff    	je     f0102f6e <vprintfmt+0x29>
			if (ch == '\0'){
f010338b:	85 c0                	test   %eax,%eax
f010338d:	0f 84 c9 fb ff ff    	je     f0102f5c <vprintfmt+0x17>
			putch(ch, putdat);
f0103393:	83 ec 08             	sub    $0x8,%esp
f0103396:	53                   	push   %ebx
f0103397:	50                   	push   %eax
f0103398:	ff d6                	call   *%esi
f010339a:	83 c4 10             	add    $0x10,%esp
f010339d:	eb dc                	jmp    f010337b <vprintfmt+0x436>
	if (lflag >= 2)
f010339f:	83 f9 01             	cmp    $0x1,%ecx
f01033a2:	7e 15                	jle    f01033b9 <vprintfmt+0x474>
		return va_arg(*ap, unsigned long long);
f01033a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01033a7:	8b 10                	mov    (%eax),%edx
f01033a9:	8b 48 04             	mov    0x4(%eax),%ecx
f01033ac:	8d 40 08             	lea    0x8(%eax),%eax
f01033af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01033b2:	b8 10 00 00 00       	mov    $0x10,%eax
f01033b7:	eb a5                	jmp    f010335e <vprintfmt+0x419>
	else if (lflag)
f01033b9:	85 c9                	test   %ecx,%ecx
f01033bb:	75 17                	jne    f01033d4 <vprintfmt+0x48f>
		return va_arg(*ap, unsigned int);
f01033bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01033c0:	8b 10                	mov    (%eax),%edx
f01033c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01033c7:	8d 40 04             	lea    0x4(%eax),%eax
f01033ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01033cd:	b8 10 00 00 00       	mov    $0x10,%eax
f01033d2:	eb 8a                	jmp    f010335e <vprintfmt+0x419>
		return va_arg(*ap, unsigned long);
f01033d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01033d7:	8b 10                	mov    (%eax),%edx
f01033d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01033de:	8d 40 04             	lea    0x4(%eax),%eax
f01033e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01033e4:	b8 10 00 00 00       	mov    $0x10,%eax
f01033e9:	e9 70 ff ff ff       	jmp    f010335e <vprintfmt+0x419>
			putch(ch, putdat);
f01033ee:	83 ec 08             	sub    $0x8,%esp
f01033f1:	53                   	push   %ebx
f01033f2:	6a 25                	push   $0x25
f01033f4:	ff d6                	call   *%esi
			break;
f01033f6:	83 c4 10             	add    $0x10,%esp
f01033f9:	e9 7a ff ff ff       	jmp    f0103378 <vprintfmt+0x433>
			putch('%', putdat);
f01033fe:	83 ec 08             	sub    $0x8,%esp
f0103401:	53                   	push   %ebx
f0103402:	6a 25                	push   $0x25
f0103404:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103406:	83 c4 10             	add    $0x10,%esp
f0103409:	89 f8                	mov    %edi,%eax
f010340b:	eb 03                	jmp    f0103410 <vprintfmt+0x4cb>
f010340d:	83 e8 01             	sub    $0x1,%eax
f0103410:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103414:	75 f7                	jne    f010340d <vprintfmt+0x4c8>
f0103416:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103419:	e9 5a ff ff ff       	jmp    f0103378 <vprintfmt+0x433>

f010341e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010341e:	55                   	push   %ebp
f010341f:	89 e5                	mov    %esp,%ebp
f0103421:	83 ec 18             	sub    $0x18,%esp
f0103424:	8b 45 08             	mov    0x8(%ebp),%eax
f0103427:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010342a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010342d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103431:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103434:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010343b:	85 c0                	test   %eax,%eax
f010343d:	74 26                	je     f0103465 <vsnprintf+0x47>
f010343f:	85 d2                	test   %edx,%edx
f0103441:	7e 22                	jle    f0103465 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103443:	ff 75 14             	pushl  0x14(%ebp)
f0103446:	ff 75 10             	pushl  0x10(%ebp)
f0103449:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010344c:	50                   	push   %eax
f010344d:	68 0b 2f 10 f0       	push   $0xf0102f0b
f0103452:	e8 ee fa ff ff       	call   f0102f45 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010345a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010345d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103460:	83 c4 10             	add    $0x10,%esp
}
f0103463:	c9                   	leave  
f0103464:	c3                   	ret    
		return -E_INVAL;
f0103465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010346a:	eb f7                	jmp    f0103463 <vsnprintf+0x45>

f010346c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010346c:	55                   	push   %ebp
f010346d:	89 e5                	mov    %esp,%ebp
f010346f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103472:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103475:	50                   	push   %eax
f0103476:	ff 75 10             	pushl  0x10(%ebp)
f0103479:	ff 75 0c             	pushl  0xc(%ebp)
f010347c:	ff 75 08             	pushl  0x8(%ebp)
f010347f:	e8 9a ff ff ff       	call   f010341e <vsnprintf>
	va_end(ap);

	return rc;
}
f0103484:	c9                   	leave  
f0103485:	c3                   	ret    

f0103486 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103486:	55                   	push   %ebp
f0103487:	89 e5                	mov    %esp,%ebp
f0103489:	57                   	push   %edi
f010348a:	56                   	push   %esi
f010348b:	53                   	push   %ebx
f010348c:	83 ec 0c             	sub    $0xc,%esp
f010348f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103492:	85 c0                	test   %eax,%eax
f0103494:	74 11                	je     f01034a7 <readline+0x21>
		cprintf("%s", prompt);
f0103496:	83 ec 08             	sub    $0x8,%esp
f0103499:	50                   	push   %eax
f010349a:	68 08 49 10 f0       	push   $0xf0104908
f010349f:	e8 9b f6 ff ff       	call   f0102b3f <cprintf>
f01034a4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01034a7:	83 ec 0c             	sub    $0xc,%esp
f01034aa:	6a 00                	push   $0x0
f01034ac:	e8 95 d1 ff ff       	call   f0100646 <iscons>
f01034b1:	89 c7                	mov    %eax,%edi
f01034b3:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01034b6:	be 00 00 00 00       	mov    $0x0,%esi
f01034bb:	eb 3f                	jmp    f01034fc <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01034bd:	83 ec 08             	sub    $0x8,%esp
f01034c0:	50                   	push   %eax
f01034c1:	68 e0 4d 10 f0       	push   $0xf0104de0
f01034c6:	e8 74 f6 ff ff       	call   f0102b3f <cprintf>
			return NULL;
f01034cb:	83 c4 10             	add    $0x10,%esp
f01034ce:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01034d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034d6:	5b                   	pop    %ebx
f01034d7:	5e                   	pop    %esi
f01034d8:	5f                   	pop    %edi
f01034d9:	5d                   	pop    %ebp
f01034da:	c3                   	ret    
			if (echoing)
f01034db:	85 ff                	test   %edi,%edi
f01034dd:	75 05                	jne    f01034e4 <readline+0x5e>
			i--;
f01034df:	83 ee 01             	sub    $0x1,%esi
f01034e2:	eb 18                	jmp    f01034fc <readline+0x76>
				cputchar('\b');
f01034e4:	83 ec 0c             	sub    $0xc,%esp
f01034e7:	6a 08                	push   $0x8
f01034e9:	e8 37 d1 ff ff       	call   f0100625 <cputchar>
f01034ee:	83 c4 10             	add    $0x10,%esp
f01034f1:	eb ec                	jmp    f01034df <readline+0x59>
			buf[i++] = c;
f01034f3:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f01034f9:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01034fc:	e8 34 d1 ff ff       	call   f0100635 <getchar>
f0103501:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103503:	85 c0                	test   %eax,%eax
f0103505:	78 b6                	js     f01034bd <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103507:	83 f8 08             	cmp    $0x8,%eax
f010350a:	0f 94 c2             	sete   %dl
f010350d:	83 f8 7f             	cmp    $0x7f,%eax
f0103510:	0f 94 c0             	sete   %al
f0103513:	08 c2                	or     %al,%dl
f0103515:	74 04                	je     f010351b <readline+0x95>
f0103517:	85 f6                	test   %esi,%esi
f0103519:	7f c0                	jg     f01034db <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010351b:	83 fb 1f             	cmp    $0x1f,%ebx
f010351e:	7e 1a                	jle    f010353a <readline+0xb4>
f0103520:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103526:	7f 12                	jg     f010353a <readline+0xb4>
			if (echoing)
f0103528:	85 ff                	test   %edi,%edi
f010352a:	74 c7                	je     f01034f3 <readline+0x6d>
				cputchar(c);
f010352c:	83 ec 0c             	sub    $0xc,%esp
f010352f:	53                   	push   %ebx
f0103530:	e8 f0 d0 ff ff       	call   f0100625 <cputchar>
f0103535:	83 c4 10             	add    $0x10,%esp
f0103538:	eb b9                	jmp    f01034f3 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f010353a:	83 fb 0a             	cmp    $0xa,%ebx
f010353d:	74 05                	je     f0103544 <readline+0xbe>
f010353f:	83 fb 0d             	cmp    $0xd,%ebx
f0103542:	75 b8                	jne    f01034fc <readline+0x76>
			if (echoing)
f0103544:	85 ff                	test   %edi,%edi
f0103546:	75 11                	jne    f0103559 <readline+0xd3>
			buf[i] = 0;
f0103548:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f010354f:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f0103554:	e9 7a ff ff ff       	jmp    f01034d3 <readline+0x4d>
				cputchar('\n');
f0103559:	83 ec 0c             	sub    $0xc,%esp
f010355c:	6a 0a                	push   $0xa
f010355e:	e8 c2 d0 ff ff       	call   f0100625 <cputchar>
f0103563:	83 c4 10             	add    $0x10,%esp
f0103566:	eb e0                	jmp    f0103548 <readline+0xc2>

f0103568 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103568:	55                   	push   %ebp
f0103569:	89 e5                	mov    %esp,%ebp
f010356b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010356e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103573:	eb 03                	jmp    f0103578 <strlen+0x10>
		n++;
f0103575:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103578:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010357c:	75 f7                	jne    f0103575 <strlen+0xd>
	return n;
}
f010357e:	5d                   	pop    %ebp
f010357f:	c3                   	ret    

f0103580 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103580:	55                   	push   %ebp
f0103581:	89 e5                	mov    %esp,%ebp
f0103583:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103586:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103589:	b8 00 00 00 00       	mov    $0x0,%eax
f010358e:	eb 03                	jmp    f0103593 <strnlen+0x13>
		n++;
f0103590:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103593:	39 d0                	cmp    %edx,%eax
f0103595:	74 06                	je     f010359d <strnlen+0x1d>
f0103597:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010359b:	75 f3                	jne    f0103590 <strnlen+0x10>
	return n;
}
f010359d:	5d                   	pop    %ebp
f010359e:	c3                   	ret    

f010359f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010359f:	55                   	push   %ebp
f01035a0:	89 e5                	mov    %esp,%ebp
f01035a2:	53                   	push   %ebx
f01035a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01035a9:	89 c2                	mov    %eax,%edx
f01035ab:	83 c1 01             	add    $0x1,%ecx
f01035ae:	83 c2 01             	add    $0x1,%edx
f01035b1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01035b5:	88 5a ff             	mov    %bl,-0x1(%edx)
f01035b8:	84 db                	test   %bl,%bl
f01035ba:	75 ef                	jne    f01035ab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01035bc:	5b                   	pop    %ebx
f01035bd:	5d                   	pop    %ebp
f01035be:	c3                   	ret    

f01035bf <strcat>:

char *
strcat(char *dst, const char *src)
{
f01035bf:	55                   	push   %ebp
f01035c0:	89 e5                	mov    %esp,%ebp
f01035c2:	53                   	push   %ebx
f01035c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01035c6:	53                   	push   %ebx
f01035c7:	e8 9c ff ff ff       	call   f0103568 <strlen>
f01035cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01035cf:	ff 75 0c             	pushl  0xc(%ebp)
f01035d2:	01 d8                	add    %ebx,%eax
f01035d4:	50                   	push   %eax
f01035d5:	e8 c5 ff ff ff       	call   f010359f <strcpy>
	return dst;
}
f01035da:	89 d8                	mov    %ebx,%eax
f01035dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035df:	c9                   	leave  
f01035e0:	c3                   	ret    

f01035e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01035e1:	55                   	push   %ebp
f01035e2:	89 e5                	mov    %esp,%ebp
f01035e4:	56                   	push   %esi
f01035e5:	53                   	push   %ebx
f01035e6:	8b 75 08             	mov    0x8(%ebp),%esi
f01035e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01035ec:	89 f3                	mov    %esi,%ebx
f01035ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01035f1:	89 f2                	mov    %esi,%edx
f01035f3:	eb 0f                	jmp    f0103604 <strncpy+0x23>
		*dst++ = *src;
f01035f5:	83 c2 01             	add    $0x1,%edx
f01035f8:	0f b6 01             	movzbl (%ecx),%eax
f01035fb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01035fe:	80 39 01             	cmpb   $0x1,(%ecx)
f0103601:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0103604:	39 da                	cmp    %ebx,%edx
f0103606:	75 ed                	jne    f01035f5 <strncpy+0x14>
	}
	return ret;
}
f0103608:	89 f0                	mov    %esi,%eax
f010360a:	5b                   	pop    %ebx
f010360b:	5e                   	pop    %esi
f010360c:	5d                   	pop    %ebp
f010360d:	c3                   	ret    

f010360e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010360e:	55                   	push   %ebp
f010360f:	89 e5                	mov    %esp,%ebp
f0103611:	56                   	push   %esi
f0103612:	53                   	push   %ebx
f0103613:	8b 75 08             	mov    0x8(%ebp),%esi
f0103616:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103619:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010361c:	89 f0                	mov    %esi,%eax
f010361e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103622:	85 c9                	test   %ecx,%ecx
f0103624:	75 0b                	jne    f0103631 <strlcpy+0x23>
f0103626:	eb 17                	jmp    f010363f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103628:	83 c2 01             	add    $0x1,%edx
f010362b:	83 c0 01             	add    $0x1,%eax
f010362e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103631:	39 d8                	cmp    %ebx,%eax
f0103633:	74 07                	je     f010363c <strlcpy+0x2e>
f0103635:	0f b6 0a             	movzbl (%edx),%ecx
f0103638:	84 c9                	test   %cl,%cl
f010363a:	75 ec                	jne    f0103628 <strlcpy+0x1a>
		*dst = '\0';
f010363c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010363f:	29 f0                	sub    %esi,%eax
}
f0103641:	5b                   	pop    %ebx
f0103642:	5e                   	pop    %esi
f0103643:	5d                   	pop    %ebp
f0103644:	c3                   	ret    

f0103645 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103645:	55                   	push   %ebp
f0103646:	89 e5                	mov    %esp,%ebp
f0103648:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010364b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010364e:	eb 06                	jmp    f0103656 <strcmp+0x11>
		p++, q++;
f0103650:	83 c1 01             	add    $0x1,%ecx
f0103653:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103656:	0f b6 01             	movzbl (%ecx),%eax
f0103659:	84 c0                	test   %al,%al
f010365b:	74 04                	je     f0103661 <strcmp+0x1c>
f010365d:	3a 02                	cmp    (%edx),%al
f010365f:	74 ef                	je     f0103650 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103661:	0f b6 c0             	movzbl %al,%eax
f0103664:	0f b6 12             	movzbl (%edx),%edx
f0103667:	29 d0                	sub    %edx,%eax
}
f0103669:	5d                   	pop    %ebp
f010366a:	c3                   	ret    

f010366b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010366b:	55                   	push   %ebp
f010366c:	89 e5                	mov    %esp,%ebp
f010366e:	53                   	push   %ebx
f010366f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103672:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103675:	89 c3                	mov    %eax,%ebx
f0103677:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010367a:	eb 06                	jmp    f0103682 <strncmp+0x17>
		n--, p++, q++;
f010367c:	83 c0 01             	add    $0x1,%eax
f010367f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103682:	39 d8                	cmp    %ebx,%eax
f0103684:	74 16                	je     f010369c <strncmp+0x31>
f0103686:	0f b6 08             	movzbl (%eax),%ecx
f0103689:	84 c9                	test   %cl,%cl
f010368b:	74 04                	je     f0103691 <strncmp+0x26>
f010368d:	3a 0a                	cmp    (%edx),%cl
f010368f:	74 eb                	je     f010367c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103691:	0f b6 00             	movzbl (%eax),%eax
f0103694:	0f b6 12             	movzbl (%edx),%edx
f0103697:	29 d0                	sub    %edx,%eax
}
f0103699:	5b                   	pop    %ebx
f010369a:	5d                   	pop    %ebp
f010369b:	c3                   	ret    
		return 0;
f010369c:	b8 00 00 00 00       	mov    $0x0,%eax
f01036a1:	eb f6                	jmp    f0103699 <strncmp+0x2e>

f01036a3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01036a3:	55                   	push   %ebp
f01036a4:	89 e5                	mov    %esp,%ebp
f01036a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01036ad:	0f b6 10             	movzbl (%eax),%edx
f01036b0:	84 d2                	test   %dl,%dl
f01036b2:	74 09                	je     f01036bd <strchr+0x1a>
		if (*s == c)
f01036b4:	38 ca                	cmp    %cl,%dl
f01036b6:	74 0a                	je     f01036c2 <strchr+0x1f>
	for (; *s; s++)
f01036b8:	83 c0 01             	add    $0x1,%eax
f01036bb:	eb f0                	jmp    f01036ad <strchr+0xa>
			return (char *) s;
	return 0;
f01036bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036c2:	5d                   	pop    %ebp
f01036c3:	c3                   	ret    

f01036c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01036c4:	55                   	push   %ebp
f01036c5:	89 e5                	mov    %esp,%ebp
f01036c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01036ce:	eb 03                	jmp    f01036d3 <strfind+0xf>
f01036d0:	83 c0 01             	add    $0x1,%eax
f01036d3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01036d6:	38 ca                	cmp    %cl,%dl
f01036d8:	74 04                	je     f01036de <strfind+0x1a>
f01036da:	84 d2                	test   %dl,%dl
f01036dc:	75 f2                	jne    f01036d0 <strfind+0xc>
			break;
	return (char *) s;
}
f01036de:	5d                   	pop    %ebp
f01036df:	c3                   	ret    

f01036e0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01036e0:	55                   	push   %ebp
f01036e1:	89 e5                	mov    %esp,%ebp
f01036e3:	57                   	push   %edi
f01036e4:	56                   	push   %esi
f01036e5:	53                   	push   %ebx
f01036e6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01036e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01036ec:	85 c9                	test   %ecx,%ecx
f01036ee:	74 13                	je     f0103703 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01036f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01036f6:	75 05                	jne    f01036fd <memset+0x1d>
f01036f8:	f6 c1 03             	test   $0x3,%cl
f01036fb:	74 0d                	je     f010370a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01036fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103700:	fc                   	cld    
f0103701:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103703:	89 f8                	mov    %edi,%eax
f0103705:	5b                   	pop    %ebx
f0103706:	5e                   	pop    %esi
f0103707:	5f                   	pop    %edi
f0103708:	5d                   	pop    %ebp
f0103709:	c3                   	ret    
		c &= 0xFF;
f010370a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010370e:	89 d3                	mov    %edx,%ebx
f0103710:	c1 e3 08             	shl    $0x8,%ebx
f0103713:	89 d0                	mov    %edx,%eax
f0103715:	c1 e0 18             	shl    $0x18,%eax
f0103718:	89 d6                	mov    %edx,%esi
f010371a:	c1 e6 10             	shl    $0x10,%esi
f010371d:	09 f0                	or     %esi,%eax
f010371f:	09 c2                	or     %eax,%edx
f0103721:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103723:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103726:	89 d0                	mov    %edx,%eax
f0103728:	fc                   	cld    
f0103729:	f3 ab                	rep stos %eax,%es:(%edi)
f010372b:	eb d6                	jmp    f0103703 <memset+0x23>

f010372d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010372d:	55                   	push   %ebp
f010372e:	89 e5                	mov    %esp,%ebp
f0103730:	57                   	push   %edi
f0103731:	56                   	push   %esi
f0103732:	8b 45 08             	mov    0x8(%ebp),%eax
f0103735:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103738:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010373b:	39 c6                	cmp    %eax,%esi
f010373d:	73 35                	jae    f0103774 <memmove+0x47>
f010373f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103742:	39 c2                	cmp    %eax,%edx
f0103744:	76 2e                	jbe    f0103774 <memmove+0x47>
		s += n;
		d += n;
f0103746:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103749:	89 d6                	mov    %edx,%esi
f010374b:	09 fe                	or     %edi,%esi
f010374d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103753:	74 0c                	je     f0103761 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103755:	83 ef 01             	sub    $0x1,%edi
f0103758:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010375b:	fd                   	std    
f010375c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010375e:	fc                   	cld    
f010375f:	eb 21                	jmp    f0103782 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103761:	f6 c1 03             	test   $0x3,%cl
f0103764:	75 ef                	jne    f0103755 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103766:	83 ef 04             	sub    $0x4,%edi
f0103769:	8d 72 fc             	lea    -0x4(%edx),%esi
f010376c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010376f:	fd                   	std    
f0103770:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103772:	eb ea                	jmp    f010375e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103774:	89 f2                	mov    %esi,%edx
f0103776:	09 c2                	or     %eax,%edx
f0103778:	f6 c2 03             	test   $0x3,%dl
f010377b:	74 09                	je     f0103786 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010377d:	89 c7                	mov    %eax,%edi
f010377f:	fc                   	cld    
f0103780:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103782:	5e                   	pop    %esi
f0103783:	5f                   	pop    %edi
f0103784:	5d                   	pop    %ebp
f0103785:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103786:	f6 c1 03             	test   $0x3,%cl
f0103789:	75 f2                	jne    f010377d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010378b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010378e:	89 c7                	mov    %eax,%edi
f0103790:	fc                   	cld    
f0103791:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103793:	eb ed                	jmp    f0103782 <memmove+0x55>

f0103795 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103795:	55                   	push   %ebp
f0103796:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103798:	ff 75 10             	pushl  0x10(%ebp)
f010379b:	ff 75 0c             	pushl  0xc(%ebp)
f010379e:	ff 75 08             	pushl  0x8(%ebp)
f01037a1:	e8 87 ff ff ff       	call   f010372d <memmove>
}
f01037a6:	c9                   	leave  
f01037a7:	c3                   	ret    

f01037a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01037a8:	55                   	push   %ebp
f01037a9:	89 e5                	mov    %esp,%ebp
f01037ab:	56                   	push   %esi
f01037ac:	53                   	push   %ebx
f01037ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01037b0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037b3:	89 c6                	mov    %eax,%esi
f01037b5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01037b8:	39 f0                	cmp    %esi,%eax
f01037ba:	74 1c                	je     f01037d8 <memcmp+0x30>
		if (*s1 != *s2)
f01037bc:	0f b6 08             	movzbl (%eax),%ecx
f01037bf:	0f b6 1a             	movzbl (%edx),%ebx
f01037c2:	38 d9                	cmp    %bl,%cl
f01037c4:	75 08                	jne    f01037ce <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01037c6:	83 c0 01             	add    $0x1,%eax
f01037c9:	83 c2 01             	add    $0x1,%edx
f01037cc:	eb ea                	jmp    f01037b8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01037ce:	0f b6 c1             	movzbl %cl,%eax
f01037d1:	0f b6 db             	movzbl %bl,%ebx
f01037d4:	29 d8                	sub    %ebx,%eax
f01037d6:	eb 05                	jmp    f01037dd <memcmp+0x35>
	}

	return 0;
f01037d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037dd:	5b                   	pop    %ebx
f01037de:	5e                   	pop    %esi
f01037df:	5d                   	pop    %ebp
f01037e0:	c3                   	ret    

f01037e1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01037e1:	55                   	push   %ebp
f01037e2:	89 e5                	mov    %esp,%ebp
f01037e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01037ea:	89 c2                	mov    %eax,%edx
f01037ec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01037ef:	39 d0                	cmp    %edx,%eax
f01037f1:	73 09                	jae    f01037fc <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01037f3:	38 08                	cmp    %cl,(%eax)
f01037f5:	74 05                	je     f01037fc <memfind+0x1b>
	for (; s < ends; s++)
f01037f7:	83 c0 01             	add    $0x1,%eax
f01037fa:	eb f3                	jmp    f01037ef <memfind+0xe>
			break;
	return (void *) s;
}
f01037fc:	5d                   	pop    %ebp
f01037fd:	c3                   	ret    

f01037fe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01037fe:	55                   	push   %ebp
f01037ff:	89 e5                	mov    %esp,%ebp
f0103801:	57                   	push   %edi
f0103802:	56                   	push   %esi
f0103803:	53                   	push   %ebx
f0103804:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103807:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010380a:	eb 03                	jmp    f010380f <strtol+0x11>
		s++;
f010380c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010380f:	0f b6 01             	movzbl (%ecx),%eax
f0103812:	3c 20                	cmp    $0x20,%al
f0103814:	74 f6                	je     f010380c <strtol+0xe>
f0103816:	3c 09                	cmp    $0x9,%al
f0103818:	74 f2                	je     f010380c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010381a:	3c 2b                	cmp    $0x2b,%al
f010381c:	74 2e                	je     f010384c <strtol+0x4e>
	int neg = 0;
f010381e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103823:	3c 2d                	cmp    $0x2d,%al
f0103825:	74 2f                	je     f0103856 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103827:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010382d:	75 05                	jne    f0103834 <strtol+0x36>
f010382f:	80 39 30             	cmpb   $0x30,(%ecx)
f0103832:	74 2c                	je     f0103860 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103834:	85 db                	test   %ebx,%ebx
f0103836:	75 0a                	jne    f0103842 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103838:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010383d:	80 39 30             	cmpb   $0x30,(%ecx)
f0103840:	74 28                	je     f010386a <strtol+0x6c>
		base = 10;
f0103842:	b8 00 00 00 00       	mov    $0x0,%eax
f0103847:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010384a:	eb 50                	jmp    f010389c <strtol+0x9e>
		s++;
f010384c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010384f:	bf 00 00 00 00       	mov    $0x0,%edi
f0103854:	eb d1                	jmp    f0103827 <strtol+0x29>
		s++, neg = 1;
f0103856:	83 c1 01             	add    $0x1,%ecx
f0103859:	bf 01 00 00 00       	mov    $0x1,%edi
f010385e:	eb c7                	jmp    f0103827 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103860:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103864:	74 0e                	je     f0103874 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103866:	85 db                	test   %ebx,%ebx
f0103868:	75 d8                	jne    f0103842 <strtol+0x44>
		s++, base = 8;
f010386a:	83 c1 01             	add    $0x1,%ecx
f010386d:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103872:	eb ce                	jmp    f0103842 <strtol+0x44>
		s += 2, base = 16;
f0103874:	83 c1 02             	add    $0x2,%ecx
f0103877:	bb 10 00 00 00       	mov    $0x10,%ebx
f010387c:	eb c4                	jmp    f0103842 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010387e:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103881:	89 f3                	mov    %esi,%ebx
f0103883:	80 fb 19             	cmp    $0x19,%bl
f0103886:	77 29                	ja     f01038b1 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0103888:	0f be d2             	movsbl %dl,%edx
f010388b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010388e:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103891:	7d 30                	jge    f01038c3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0103893:	83 c1 01             	add    $0x1,%ecx
f0103896:	0f af 45 10          	imul   0x10(%ebp),%eax
f010389a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010389c:	0f b6 11             	movzbl (%ecx),%edx
f010389f:	8d 72 d0             	lea    -0x30(%edx),%esi
f01038a2:	89 f3                	mov    %esi,%ebx
f01038a4:	80 fb 09             	cmp    $0x9,%bl
f01038a7:	77 d5                	ja     f010387e <strtol+0x80>
			dig = *s - '0';
f01038a9:	0f be d2             	movsbl %dl,%edx
f01038ac:	83 ea 30             	sub    $0x30,%edx
f01038af:	eb dd                	jmp    f010388e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01038b1:	8d 72 bf             	lea    -0x41(%edx),%esi
f01038b4:	89 f3                	mov    %esi,%ebx
f01038b6:	80 fb 19             	cmp    $0x19,%bl
f01038b9:	77 08                	ja     f01038c3 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01038bb:	0f be d2             	movsbl %dl,%edx
f01038be:	83 ea 37             	sub    $0x37,%edx
f01038c1:	eb cb                	jmp    f010388e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01038c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01038c7:	74 05                	je     f01038ce <strtol+0xd0>
		*endptr = (char *) s;
f01038c9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01038cc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01038ce:	89 c2                	mov    %eax,%edx
f01038d0:	f7 da                	neg    %edx
f01038d2:	85 ff                	test   %edi,%edi
f01038d4:	0f 45 c2             	cmovne %edx,%eax
}
f01038d7:	5b                   	pop    %ebx
f01038d8:	5e                   	pop    %esi
f01038d9:	5f                   	pop    %edi
f01038da:	5d                   	pop    %ebp
f01038db:	c3                   	ret    
f01038dc:	66 90                	xchg   %ax,%ax
f01038de:	66 90                	xchg   %ax,%ax

f01038e0 <__udivdi3>:
f01038e0:	55                   	push   %ebp
f01038e1:	57                   	push   %edi
f01038e2:	56                   	push   %esi
f01038e3:	53                   	push   %ebx
f01038e4:	83 ec 1c             	sub    $0x1c,%esp
f01038e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01038eb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01038ef:	8b 74 24 34          	mov    0x34(%esp),%esi
f01038f3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01038f7:	85 d2                	test   %edx,%edx
f01038f9:	75 35                	jne    f0103930 <__udivdi3+0x50>
f01038fb:	39 f3                	cmp    %esi,%ebx
f01038fd:	0f 87 bd 00 00 00    	ja     f01039c0 <__udivdi3+0xe0>
f0103903:	85 db                	test   %ebx,%ebx
f0103905:	89 d9                	mov    %ebx,%ecx
f0103907:	75 0b                	jne    f0103914 <__udivdi3+0x34>
f0103909:	b8 01 00 00 00       	mov    $0x1,%eax
f010390e:	31 d2                	xor    %edx,%edx
f0103910:	f7 f3                	div    %ebx
f0103912:	89 c1                	mov    %eax,%ecx
f0103914:	31 d2                	xor    %edx,%edx
f0103916:	89 f0                	mov    %esi,%eax
f0103918:	f7 f1                	div    %ecx
f010391a:	89 c6                	mov    %eax,%esi
f010391c:	89 e8                	mov    %ebp,%eax
f010391e:	89 f7                	mov    %esi,%edi
f0103920:	f7 f1                	div    %ecx
f0103922:	89 fa                	mov    %edi,%edx
f0103924:	83 c4 1c             	add    $0x1c,%esp
f0103927:	5b                   	pop    %ebx
f0103928:	5e                   	pop    %esi
f0103929:	5f                   	pop    %edi
f010392a:	5d                   	pop    %ebp
f010392b:	c3                   	ret    
f010392c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103930:	39 f2                	cmp    %esi,%edx
f0103932:	77 7c                	ja     f01039b0 <__udivdi3+0xd0>
f0103934:	0f bd fa             	bsr    %edx,%edi
f0103937:	83 f7 1f             	xor    $0x1f,%edi
f010393a:	0f 84 98 00 00 00    	je     f01039d8 <__udivdi3+0xf8>
f0103940:	89 f9                	mov    %edi,%ecx
f0103942:	b8 20 00 00 00       	mov    $0x20,%eax
f0103947:	29 f8                	sub    %edi,%eax
f0103949:	d3 e2                	shl    %cl,%edx
f010394b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010394f:	89 c1                	mov    %eax,%ecx
f0103951:	89 da                	mov    %ebx,%edx
f0103953:	d3 ea                	shr    %cl,%edx
f0103955:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103959:	09 d1                	or     %edx,%ecx
f010395b:	89 f2                	mov    %esi,%edx
f010395d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103961:	89 f9                	mov    %edi,%ecx
f0103963:	d3 e3                	shl    %cl,%ebx
f0103965:	89 c1                	mov    %eax,%ecx
f0103967:	d3 ea                	shr    %cl,%edx
f0103969:	89 f9                	mov    %edi,%ecx
f010396b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010396f:	d3 e6                	shl    %cl,%esi
f0103971:	89 eb                	mov    %ebp,%ebx
f0103973:	89 c1                	mov    %eax,%ecx
f0103975:	d3 eb                	shr    %cl,%ebx
f0103977:	09 de                	or     %ebx,%esi
f0103979:	89 f0                	mov    %esi,%eax
f010397b:	f7 74 24 08          	divl   0x8(%esp)
f010397f:	89 d6                	mov    %edx,%esi
f0103981:	89 c3                	mov    %eax,%ebx
f0103983:	f7 64 24 0c          	mull   0xc(%esp)
f0103987:	39 d6                	cmp    %edx,%esi
f0103989:	72 0c                	jb     f0103997 <__udivdi3+0xb7>
f010398b:	89 f9                	mov    %edi,%ecx
f010398d:	d3 e5                	shl    %cl,%ebp
f010398f:	39 c5                	cmp    %eax,%ebp
f0103991:	73 5d                	jae    f01039f0 <__udivdi3+0x110>
f0103993:	39 d6                	cmp    %edx,%esi
f0103995:	75 59                	jne    f01039f0 <__udivdi3+0x110>
f0103997:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010399a:	31 ff                	xor    %edi,%edi
f010399c:	89 fa                	mov    %edi,%edx
f010399e:	83 c4 1c             	add    $0x1c,%esp
f01039a1:	5b                   	pop    %ebx
f01039a2:	5e                   	pop    %esi
f01039a3:	5f                   	pop    %edi
f01039a4:	5d                   	pop    %ebp
f01039a5:	c3                   	ret    
f01039a6:	8d 76 00             	lea    0x0(%esi),%esi
f01039a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01039b0:	31 ff                	xor    %edi,%edi
f01039b2:	31 c0                	xor    %eax,%eax
f01039b4:	89 fa                	mov    %edi,%edx
f01039b6:	83 c4 1c             	add    $0x1c,%esp
f01039b9:	5b                   	pop    %ebx
f01039ba:	5e                   	pop    %esi
f01039bb:	5f                   	pop    %edi
f01039bc:	5d                   	pop    %ebp
f01039bd:	c3                   	ret    
f01039be:	66 90                	xchg   %ax,%ax
f01039c0:	31 ff                	xor    %edi,%edi
f01039c2:	89 e8                	mov    %ebp,%eax
f01039c4:	89 f2                	mov    %esi,%edx
f01039c6:	f7 f3                	div    %ebx
f01039c8:	89 fa                	mov    %edi,%edx
f01039ca:	83 c4 1c             	add    $0x1c,%esp
f01039cd:	5b                   	pop    %ebx
f01039ce:	5e                   	pop    %esi
f01039cf:	5f                   	pop    %edi
f01039d0:	5d                   	pop    %ebp
f01039d1:	c3                   	ret    
f01039d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01039d8:	39 f2                	cmp    %esi,%edx
f01039da:	72 06                	jb     f01039e2 <__udivdi3+0x102>
f01039dc:	31 c0                	xor    %eax,%eax
f01039de:	39 eb                	cmp    %ebp,%ebx
f01039e0:	77 d2                	ja     f01039b4 <__udivdi3+0xd4>
f01039e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01039e7:	eb cb                	jmp    f01039b4 <__udivdi3+0xd4>
f01039e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01039f0:	89 d8                	mov    %ebx,%eax
f01039f2:	31 ff                	xor    %edi,%edi
f01039f4:	eb be                	jmp    f01039b4 <__udivdi3+0xd4>
f01039f6:	66 90                	xchg   %ax,%ax
f01039f8:	66 90                	xchg   %ax,%ax
f01039fa:	66 90                	xchg   %ax,%ax
f01039fc:	66 90                	xchg   %ax,%ax
f01039fe:	66 90                	xchg   %ax,%ax

f0103a00 <__umoddi3>:
f0103a00:	55                   	push   %ebp
f0103a01:	57                   	push   %edi
f0103a02:	56                   	push   %esi
f0103a03:	53                   	push   %ebx
f0103a04:	83 ec 1c             	sub    $0x1c,%esp
f0103a07:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103a0b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103a0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103a13:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103a17:	85 ed                	test   %ebp,%ebp
f0103a19:	89 f0                	mov    %esi,%eax
f0103a1b:	89 da                	mov    %ebx,%edx
f0103a1d:	75 19                	jne    f0103a38 <__umoddi3+0x38>
f0103a1f:	39 df                	cmp    %ebx,%edi
f0103a21:	0f 86 b1 00 00 00    	jbe    f0103ad8 <__umoddi3+0xd8>
f0103a27:	f7 f7                	div    %edi
f0103a29:	89 d0                	mov    %edx,%eax
f0103a2b:	31 d2                	xor    %edx,%edx
f0103a2d:	83 c4 1c             	add    $0x1c,%esp
f0103a30:	5b                   	pop    %ebx
f0103a31:	5e                   	pop    %esi
f0103a32:	5f                   	pop    %edi
f0103a33:	5d                   	pop    %ebp
f0103a34:	c3                   	ret    
f0103a35:	8d 76 00             	lea    0x0(%esi),%esi
f0103a38:	39 dd                	cmp    %ebx,%ebp
f0103a3a:	77 f1                	ja     f0103a2d <__umoddi3+0x2d>
f0103a3c:	0f bd cd             	bsr    %ebp,%ecx
f0103a3f:	83 f1 1f             	xor    $0x1f,%ecx
f0103a42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103a46:	0f 84 b4 00 00 00    	je     f0103b00 <__umoddi3+0x100>
f0103a4c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a51:	89 c2                	mov    %eax,%edx
f0103a53:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103a57:	29 c2                	sub    %eax,%edx
f0103a59:	89 c1                	mov    %eax,%ecx
f0103a5b:	89 f8                	mov    %edi,%eax
f0103a5d:	d3 e5                	shl    %cl,%ebp
f0103a5f:	89 d1                	mov    %edx,%ecx
f0103a61:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103a65:	d3 e8                	shr    %cl,%eax
f0103a67:	09 c5                	or     %eax,%ebp
f0103a69:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103a6d:	89 c1                	mov    %eax,%ecx
f0103a6f:	d3 e7                	shl    %cl,%edi
f0103a71:	89 d1                	mov    %edx,%ecx
f0103a73:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103a77:	89 df                	mov    %ebx,%edi
f0103a79:	d3 ef                	shr    %cl,%edi
f0103a7b:	89 c1                	mov    %eax,%ecx
f0103a7d:	89 f0                	mov    %esi,%eax
f0103a7f:	d3 e3                	shl    %cl,%ebx
f0103a81:	89 d1                	mov    %edx,%ecx
f0103a83:	89 fa                	mov    %edi,%edx
f0103a85:	d3 e8                	shr    %cl,%eax
f0103a87:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103a8c:	09 d8                	or     %ebx,%eax
f0103a8e:	f7 f5                	div    %ebp
f0103a90:	d3 e6                	shl    %cl,%esi
f0103a92:	89 d1                	mov    %edx,%ecx
f0103a94:	f7 64 24 08          	mull   0x8(%esp)
f0103a98:	39 d1                	cmp    %edx,%ecx
f0103a9a:	89 c3                	mov    %eax,%ebx
f0103a9c:	89 d7                	mov    %edx,%edi
f0103a9e:	72 06                	jb     f0103aa6 <__umoddi3+0xa6>
f0103aa0:	75 0e                	jne    f0103ab0 <__umoddi3+0xb0>
f0103aa2:	39 c6                	cmp    %eax,%esi
f0103aa4:	73 0a                	jae    f0103ab0 <__umoddi3+0xb0>
f0103aa6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0103aaa:	19 ea                	sbb    %ebp,%edx
f0103aac:	89 d7                	mov    %edx,%edi
f0103aae:	89 c3                	mov    %eax,%ebx
f0103ab0:	89 ca                	mov    %ecx,%edx
f0103ab2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0103ab7:	29 de                	sub    %ebx,%esi
f0103ab9:	19 fa                	sbb    %edi,%edx
f0103abb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0103abf:	89 d0                	mov    %edx,%eax
f0103ac1:	d3 e0                	shl    %cl,%eax
f0103ac3:	89 d9                	mov    %ebx,%ecx
f0103ac5:	d3 ee                	shr    %cl,%esi
f0103ac7:	d3 ea                	shr    %cl,%edx
f0103ac9:	09 f0                	or     %esi,%eax
f0103acb:	83 c4 1c             	add    $0x1c,%esp
f0103ace:	5b                   	pop    %ebx
f0103acf:	5e                   	pop    %esi
f0103ad0:	5f                   	pop    %edi
f0103ad1:	5d                   	pop    %ebp
f0103ad2:	c3                   	ret    
f0103ad3:	90                   	nop
f0103ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ad8:	85 ff                	test   %edi,%edi
f0103ada:	89 f9                	mov    %edi,%ecx
f0103adc:	75 0b                	jne    f0103ae9 <__umoddi3+0xe9>
f0103ade:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ae3:	31 d2                	xor    %edx,%edx
f0103ae5:	f7 f7                	div    %edi
f0103ae7:	89 c1                	mov    %eax,%ecx
f0103ae9:	89 d8                	mov    %ebx,%eax
f0103aeb:	31 d2                	xor    %edx,%edx
f0103aed:	f7 f1                	div    %ecx
f0103aef:	89 f0                	mov    %esi,%eax
f0103af1:	f7 f1                	div    %ecx
f0103af3:	e9 31 ff ff ff       	jmp    f0103a29 <__umoddi3+0x29>
f0103af8:	90                   	nop
f0103af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103b00:	39 dd                	cmp    %ebx,%ebp
f0103b02:	72 08                	jb     f0103b0c <__umoddi3+0x10c>
f0103b04:	39 f7                	cmp    %esi,%edi
f0103b06:	0f 87 21 ff ff ff    	ja     f0103a2d <__umoddi3+0x2d>
f0103b0c:	89 da                	mov    %ebx,%edx
f0103b0e:	89 f0                	mov    %esi,%eax
f0103b10:	29 f8                	sub    %edi,%eax
f0103b12:	19 ea                	sbb    %ebp,%edx
f0103b14:	e9 14 ff ff ff       	jmp    f0103a2d <__umoddi3+0x2d>
