
obj/kern/kernel：     文件格式 elf32-i386


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
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 73 00 00 00       	call   f01000b1 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:


// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{	cprintf(" %c\n", 'W');
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010004a:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0100051:	00 
f0100052:	c7 04 24 60 4f 10 f0 	movl   $0xf0104f60,(%esp)
f0100059:	e8 47 37 00 00       	call   f01037a5 <cprintf>
	cprintf("entering test_backtrace %d\n", x);
f010005e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100062:	c7 04 24 65 4f 10 f0 	movl   $0xf0104f65,(%esp)
f0100069:	e8 37 37 00 00       	call   f01037a5 <cprintf>
	if (x > 0)
f010006e:	85 db                	test   %ebx,%ebx
f0100070:	7e 0d                	jle    f010007f <test_backtrace+0x3f>
		test_backtrace(x-1);
f0100072:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100075:	89 04 24             	mov    %eax,(%esp)
f0100078:	e8 c3 ff ff ff       	call   f0100040 <test_backtrace>
f010007d:	eb 1c                	jmp    f010009b <test_backtrace+0x5b>
	else
		mon_backtrace(0, 0, 0);
f010007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100086:	00 
f0100087:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010008e:	00 
f010008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100096:	e8 40 07 00 00       	call   f01007db <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f010009b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010009f:	c7 04 24 81 4f 10 f0 	movl   $0xf0104f81,(%esp)
f01000a6:	e8 fa 36 00 00       	call   f01037a5 <cprintf>
}
f01000ab:	83 c4 14             	add    $0x14,%esp
f01000ae:	5b                   	pop    %ebx
f01000af:	5d                   	pop    %ebp
f01000b0:	c3                   	ret    

f01000b1 <i386_init>:


void
i386_init(void)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b7:	b8 90 ef 17 f0       	mov    $0xf017ef90,%eax
f01000bc:	2d 63 e0 17 f0       	sub    $0xf017e063,%eax
f01000c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000cc:	00 
f01000cd:	c7 04 24 63 e0 17 f0 	movl   $0xf017e063,(%esp)
f01000d4:	e8 ee 49 00 00       	call   f0104ac7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d9:	e8 b1 04 00 00       	call   f010058f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000de:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000e5:	00 
f01000e6:	c7 04 24 9c 4f 10 f0 	movl   $0xf0104f9c,(%esp)
f01000ed:	e8 b3 36 00 00       	call   f01037a5 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000f2:	e8 92 11 00 00       	call   f0101289 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000f7:	e8 75 30 00 00       	call   f0103171 <env_init>
	trap_init();
f01000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100100:	e8 18 37 00 00       	call   f010381d <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010010c:	00 
f010010d:	c7 04 24 1f 2d 13 f0 	movl   $0xf0132d1f,(%esp)
f0100114:	e8 26 32 00 00       	call   f010333f <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100119:	a1 cc e2 17 f0       	mov    0xf017e2cc,%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 a3 35 00 00       	call   f01036c9 <env_run>

f0100126 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100126:	55                   	push   %ebp
f0100127:	89 e5                	mov    %esp,%ebp
f0100129:	56                   	push   %esi
f010012a:	53                   	push   %ebx
f010012b:	83 ec 10             	sub    $0x10,%esp
f010012e:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100131:	83 3d 80 ef 17 f0 00 	cmpl   $0x0,0xf017ef80
f0100138:	75 3d                	jne    f0100177 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010013a:	89 35 80 ef 17 f0    	mov    %esi,0xf017ef80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100140:	fa                   	cli    
f0100141:	fc                   	cld    

	va_start(ap, fmt);
f0100142:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100145:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100148:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014c:	8b 45 08             	mov    0x8(%ebp),%eax
f010014f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100153:	c7 04 24 b7 4f 10 f0 	movl   $0xf0104fb7,(%esp)
f010015a:	e8 46 36 00 00       	call   f01037a5 <cprintf>
	vcprintf(fmt, ap);
f010015f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100163:	89 34 24             	mov    %esi,(%esp)
f0100166:	e8 07 36 00 00       	call   f0103772 <vcprintf>
	cprintf("\n");
f010016b:	c7 04 24 ea 57 10 f0 	movl   $0xf01057ea,(%esp)
f0100172:	e8 2e 36 00 00       	call   f01037a5 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010017e:	e8 43 07 00 00       	call   f01008c6 <monitor>
f0100183:	eb f2                	jmp    f0100177 <_panic+0x51>

f0100185 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100185:	55                   	push   %ebp
f0100186:	89 e5                	mov    %esp,%ebp
f0100188:	53                   	push   %ebx
f0100189:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010018c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010018f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100192:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100196:	8b 45 08             	mov    0x8(%ebp),%eax
f0100199:	89 44 24 04          	mov    %eax,0x4(%esp)
f010019d:	c7 04 24 cf 4f 10 f0 	movl   $0xf0104fcf,(%esp)
f01001a4:	e8 fc 35 00 00       	call   f01037a5 <cprintf>
	vcprintf(fmt, ap);
f01001a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01001ad:	8b 45 10             	mov    0x10(%ebp),%eax
f01001b0:	89 04 24             	mov    %eax,(%esp)
f01001b3:	e8 ba 35 00 00       	call   f0103772 <vcprintf>
	cprintf("\n");
f01001b8:	c7 04 24 ea 57 10 f0 	movl   $0xf01057ea,(%esp)
f01001bf:	e8 e1 35 00 00       	call   f01037a5 <cprintf>
	va_end(ap);
}
f01001c4:	83 c4 14             	add    $0x14,%esp
f01001c7:	5b                   	pop    %ebx
f01001c8:	5d                   	pop    %ebp
f01001c9:	c3                   	ret    
f01001ca:	66 90                	xchg   %ax,%ax
f01001cc:	66 90                	xchg   %ax,%ax
f01001ce:	66 90                	xchg   %ax,%ax

f01001d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001d0:	55                   	push   %ebp
f01001d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001d9:	a8 01                	test   $0x1,%al
f01001db:	74 08                	je     f01001e5 <serial_proc_data+0x15>
f01001dd:	b2 f8                	mov    $0xf8,%dl
f01001df:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e0:	0f b6 c0             	movzbl %al,%eax
f01001e3:	eb 05                	jmp    f01001ea <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001ea:	5d                   	pop    %ebp
f01001eb:	c3                   	ret    

f01001ec <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ec:	55                   	push   %ebp
f01001ed:	89 e5                	mov    %esp,%ebp
f01001ef:	53                   	push   %ebx
f01001f0:	83 ec 04             	sub    $0x4,%esp
f01001f3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001f5:	eb 2a                	jmp    f0100221 <cons_intr+0x35>
		if (c == 0)
f01001f7:	85 d2                	test   %edx,%edx
f01001f9:	74 26                	je     f0100221 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fb:	a1 a4 e2 17 f0       	mov    0xf017e2a4,%eax
f0100200:	8d 48 01             	lea    0x1(%eax),%ecx
f0100203:	89 0d a4 e2 17 f0    	mov    %ecx,0xf017e2a4
f0100209:	88 90 a0 e0 17 f0    	mov    %dl,-0xfe81f60(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010020f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100215:	75 0a                	jne    f0100221 <cons_intr+0x35>
			cons.wpos = 0;
f0100217:	c7 05 a4 e2 17 f0 00 	movl   $0x0,0xf017e2a4
f010021e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100221:	ff d3                	call   *%ebx
f0100223:	89 c2                	mov    %eax,%edx
f0100225:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100228:	75 cd                	jne    f01001f7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010022a:	83 c4 04             	add    $0x4,%esp
f010022d:	5b                   	pop    %ebx
f010022e:	5d                   	pop    %ebp
f010022f:	c3                   	ret    

f0100230 <kbd_proc_data>:
f0100230:	ba 64 00 00 00       	mov    $0x64,%edx
f0100235:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100236:	a8 01                	test   $0x1,%al
f0100238:	0f 84 ef 00 00 00    	je     f010032d <kbd_proc_data+0xfd>
f010023e:	b2 60                	mov    $0x60,%dl
f0100240:	ec                   	in     (%dx),%al
f0100241:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100243:	3c e0                	cmp    $0xe0,%al
f0100245:	75 0d                	jne    f0100254 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100247:	83 0d 80 e0 17 f0 40 	orl    $0x40,0xf017e080
		return 0;
f010024e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100253:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	53                   	push   %ebx
f0100258:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010025b:	84 c0                	test   %al,%al
f010025d:	79 37                	jns    f0100296 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010025f:	8b 0d 80 e0 17 f0    	mov    0xf017e080,%ecx
f0100265:	89 cb                	mov    %ecx,%ebx
f0100267:	83 e3 40             	and    $0x40,%ebx
f010026a:	83 e0 7f             	and    $0x7f,%eax
f010026d:	85 db                	test   %ebx,%ebx
f010026f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100272:	0f b6 d2             	movzbl %dl,%edx
f0100275:	0f b6 82 40 51 10 f0 	movzbl -0xfefaec0(%edx),%eax
f010027c:	83 c8 40             	or     $0x40,%eax
f010027f:	0f b6 c0             	movzbl %al,%eax
f0100282:	f7 d0                	not    %eax
f0100284:	21 c1                	and    %eax,%ecx
f0100286:	89 0d 80 e0 17 f0    	mov    %ecx,0xf017e080
		return 0;
f010028c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100291:	e9 9d 00 00 00       	jmp    f0100333 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100296:	8b 0d 80 e0 17 f0    	mov    0xf017e080,%ecx
f010029c:	f6 c1 40             	test   $0x40,%cl
f010029f:	74 0e                	je     f01002af <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01002a1:	83 c8 80             	or     $0xffffff80,%eax
f01002a4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002a6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002a9:	89 0d 80 e0 17 f0    	mov    %ecx,0xf017e080
	}

	shift |= shiftcode[data];
f01002af:	0f b6 d2             	movzbl %dl,%edx
f01002b2:	0f b6 82 40 51 10 f0 	movzbl -0xfefaec0(%edx),%eax
f01002b9:	0b 05 80 e0 17 f0    	or     0xf017e080,%eax
	shift ^= togglecode[data];
f01002bf:	0f b6 8a 40 50 10 f0 	movzbl -0xfefafc0(%edx),%ecx
f01002c6:	31 c8                	xor    %ecx,%eax
f01002c8:	a3 80 e0 17 f0       	mov    %eax,0xf017e080

	c = charcode[shift & (CTL | SHIFT)][data];
f01002cd:	89 c1                	mov    %eax,%ecx
f01002cf:	83 e1 03             	and    $0x3,%ecx
f01002d2:	8b 0c 8d 20 50 10 f0 	mov    -0xfefafe0(,%ecx,4),%ecx
f01002d9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002dd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002e0:	a8 08                	test   $0x8,%al
f01002e2:	74 1b                	je     f01002ff <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01002e4:	89 da                	mov    %ebx,%edx
f01002e6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002e9:	83 f9 19             	cmp    $0x19,%ecx
f01002ec:	77 05                	ja     f01002f3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01002ee:	83 eb 20             	sub    $0x20,%ebx
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01002f3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002f6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002f9:	83 fa 19             	cmp    $0x19,%edx
f01002fc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002ff:	f7 d0                	not    %eax
f0100301:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100303:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100305:	f6 c2 06             	test   $0x6,%dl
f0100308:	75 29                	jne    f0100333 <kbd_proc_data+0x103>
f010030a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100310:	75 21                	jne    f0100333 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100312:	c7 04 24 e9 4f 10 f0 	movl   $0xf0104fe9,(%esp)
f0100319:	e8 87 34 00 00       	call   f01037a5 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100323:	b8 03 00 00 00       	mov    $0x3,%eax
f0100328:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100329:	89 d8                	mov    %ebx,%eax
f010032b:	eb 06                	jmp    f0100333 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010032d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100332:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100333:	83 c4 14             	add    $0x14,%esp
f0100336:	5b                   	pop    %ebx
f0100337:	5d                   	pop    %ebp
f0100338:	c3                   	ret    

f0100339 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100339:	55                   	push   %ebp
f010033a:	89 e5                	mov    %esp,%ebp
f010033c:	57                   	push   %edi
f010033d:	56                   	push   %esi
f010033e:	53                   	push   %ebx
f010033f:	83 ec 1c             	sub    $0x1c,%esp
f0100342:	89 c7                	mov    %eax,%edi
f0100344:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100349:	be fd 03 00 00       	mov    $0x3fd,%esi
f010034e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100353:	eb 06                	jmp    f010035b <cons_putc+0x22>
f0100355:	89 ca                	mov    %ecx,%edx
f0100357:	ec                   	in     (%dx),%al
f0100358:	ec                   	in     (%dx),%al
f0100359:	ec                   	in     (%dx),%al
f010035a:	ec                   	in     (%dx),%al
f010035b:	89 f2                	mov    %esi,%edx
f010035d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010035e:	a8 20                	test   $0x20,%al
f0100360:	75 05                	jne    f0100367 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100362:	83 eb 01             	sub    $0x1,%ebx
f0100365:	75 ee                	jne    f0100355 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100367:	89 f8                	mov    %edi,%eax
f0100369:	0f b6 c0             	movzbl %al,%eax
f010036c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100374:	ee                   	out    %al,(%dx)
f0100375:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010037a:	be 79 03 00 00       	mov    $0x379,%esi
f010037f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100384:	eb 06                	jmp    f010038c <cons_putc+0x53>
f0100386:	89 ca                	mov    %ecx,%edx
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
f010038a:	ec                   	in     (%dx),%al
f010038b:	ec                   	in     (%dx),%al
f010038c:	89 f2                	mov    %esi,%edx
f010038e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010038f:	84 c0                	test   %al,%al
f0100391:	78 05                	js     f0100398 <cons_putc+0x5f>
f0100393:	83 eb 01             	sub    $0x1,%ebx
f0100396:	75 ee                	jne    f0100386 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100398:	ba 78 03 00 00       	mov    $0x378,%edx
f010039d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003a1:	ee                   	out    %al,(%dx)
f01003a2:	b2 7a                	mov    $0x7a,%dl
f01003a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003a9:	ee                   	out    %al,(%dx)
f01003aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01003af:	ee                   	out    %al,(%dx)
cga_putc(int c)
{
	// if no attribute given, then use black on white
	//需要更改这里，需要一个全局变量
	//更改字符串的话，好像不需要动这里？
	if (!(c & ~0xFF))
f01003b0:	89 fa                	mov    %edi,%edx
f01003b2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003b8:	89 f8                	mov    %edi,%eax
f01003ba:	80 cc 07             	or     $0x7,%ah
f01003bd:	85 d2                	test   %edx,%edx
f01003bf:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003c2:	89 f8                	mov    %edi,%eax
f01003c4:	0f b6 c0             	movzbl %al,%eax
f01003c7:	83 f8 09             	cmp    $0x9,%eax
f01003ca:	74 76                	je     f0100442 <cons_putc+0x109>
f01003cc:	83 f8 09             	cmp    $0x9,%eax
f01003cf:	7f 0a                	jg     f01003db <cons_putc+0xa2>
f01003d1:	83 f8 08             	cmp    $0x8,%eax
f01003d4:	74 16                	je     f01003ec <cons_putc+0xb3>
f01003d6:	e9 9b 00 00 00       	jmp    f0100476 <cons_putc+0x13d>
f01003db:	83 f8 0a             	cmp    $0xa,%eax
f01003de:	66 90                	xchg   %ax,%ax
f01003e0:	74 3a                	je     f010041c <cons_putc+0xe3>
f01003e2:	83 f8 0d             	cmp    $0xd,%eax
f01003e5:	74 3d                	je     f0100424 <cons_putc+0xeb>
f01003e7:	e9 8a 00 00 00       	jmp    f0100476 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f01003ec:	0f b7 05 a8 e2 17 f0 	movzwl 0xf017e2a8,%eax
f01003f3:	66 85 c0             	test   %ax,%ax
f01003f6:	0f 84 e5 00 00 00    	je     f01004e1 <cons_putc+0x1a8>
			crt_pos--;
f01003fc:	83 e8 01             	sub    $0x1,%eax
f01003ff:	66 a3 a8 e2 17 f0    	mov    %ax,0xf017e2a8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100405:	0f b7 c0             	movzwl %ax,%eax
f0100408:	66 81 e7 00 ff       	and    $0xff00,%di
f010040d:	83 cf 20             	or     $0x20,%edi
f0100410:	8b 15 ac e2 17 f0    	mov    0xf017e2ac,%edx
f0100416:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010041a:	eb 78                	jmp    f0100494 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010041c:	66 83 05 a8 e2 17 f0 	addw   $0x50,0xf017e2a8
f0100423:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100424:	0f b7 05 a8 e2 17 f0 	movzwl 0xf017e2a8,%eax
f010042b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100431:	c1 e8 16             	shr    $0x16,%eax
f0100434:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100437:	c1 e0 04             	shl    $0x4,%eax
f010043a:	66 a3 a8 e2 17 f0    	mov    %ax,0xf017e2a8
f0100440:	eb 52                	jmp    f0100494 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100442:	b8 20 00 00 00       	mov    $0x20,%eax
f0100447:	e8 ed fe ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f010044c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100451:	e8 e3 fe ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f0100456:	b8 20 00 00 00       	mov    $0x20,%eax
f010045b:	e8 d9 fe ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f0100460:	b8 20 00 00 00       	mov    $0x20,%eax
f0100465:	e8 cf fe ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f010046a:	b8 20 00 00 00       	mov    $0x20,%eax
f010046f:	e8 c5 fe ff ff       	call   f0100339 <cons_putc>
f0100474:	eb 1e                	jmp    f0100494 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100476:	0f b7 05 a8 e2 17 f0 	movzwl 0xf017e2a8,%eax
f010047d:	8d 50 01             	lea    0x1(%eax),%edx
f0100480:	66 89 15 a8 e2 17 f0 	mov    %dx,0xf017e2a8
f0100487:	0f b7 c0             	movzwl %ax,%eax
f010048a:	8b 15 ac e2 17 f0    	mov    0xf017e2ac,%edx
f0100490:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100494:	66 81 3d a8 e2 17 f0 	cmpw   $0x7cf,0xf017e2a8
f010049b:	cf 07 
f010049d:	76 42                	jbe    f01004e1 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010049f:	a1 ac e2 17 f0       	mov    0xf017e2ac,%eax
f01004a4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004ab:	00 
f01004ac:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004b6:	89 04 24             	mov    %eax,(%esp)
f01004b9:	e8 56 46 00 00       	call   f0104b14 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004be:	8b 15 ac e2 17 f0    	mov    0xf017e2ac,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004c9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004cf:	83 c0 01             	add    $0x1,%eax
f01004d2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004d7:	75 f0                	jne    f01004c9 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004d9:	66 83 2d a8 e2 17 f0 	subw   $0x50,0xf017e2a8
f01004e0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e1:	8b 0d b0 e2 17 f0    	mov    0xf017e2b0,%ecx
f01004e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ec:	89 ca                	mov    %ecx,%edx
f01004ee:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ef:	0f b7 1d a8 e2 17 f0 	movzwl 0xf017e2a8,%ebx
f01004f6:	8d 71 01             	lea    0x1(%ecx),%esi
f01004f9:	89 d8                	mov    %ebx,%eax
f01004fb:	66 c1 e8 08          	shr    $0x8,%ax
f01004ff:	89 f2                	mov    %esi,%edx
f0100501:	ee                   	out    %al,(%dx)
f0100502:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100507:	89 ca                	mov    %ecx,%edx
f0100509:	ee                   	out    %al,(%dx)
f010050a:	89 d8                	mov    %ebx,%eax
f010050c:	89 f2                	mov    %esi,%edx
f010050e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010050f:	83 c4 1c             	add    $0x1c,%esp
f0100512:	5b                   	pop    %ebx
f0100513:	5e                   	pop    %esi
f0100514:	5f                   	pop    %edi
f0100515:	5d                   	pop    %ebp
f0100516:	c3                   	ret    

f0100517 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100517:	80 3d b4 e2 17 f0 00 	cmpb   $0x0,0xf017e2b4
f010051e:	74 11                	je     f0100531 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100520:	55                   	push   %ebp
f0100521:	89 e5                	mov    %esp,%ebp
f0100523:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100526:	b8 d0 01 10 f0       	mov    $0xf01001d0,%eax
f010052b:	e8 bc fc ff ff       	call   f01001ec <cons_intr>
}
f0100530:	c9                   	leave  
f0100531:	f3 c3                	repz ret 

f0100533 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100533:	55                   	push   %ebp
f0100534:	89 e5                	mov    %esp,%ebp
f0100536:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100539:	b8 30 02 10 f0       	mov    $0xf0100230,%eax
f010053e:	e8 a9 fc ff ff       	call   f01001ec <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010054b:	e8 c7 ff ff ff       	call   f0100517 <serial_intr>
	kbd_intr();
f0100550:	e8 de ff ff ff       	call   f0100533 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100555:	a1 a0 e2 17 f0       	mov    0xf017e2a0,%eax
f010055a:	3b 05 a4 e2 17 f0    	cmp    0xf017e2a4,%eax
f0100560:	74 26                	je     f0100588 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100562:	8d 50 01             	lea    0x1(%eax),%edx
f0100565:	89 15 a0 e2 17 f0    	mov    %edx,0xf017e2a0
f010056b:	0f b6 88 a0 e0 17 f0 	movzbl -0xfe81f60(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100572:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100574:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010057a:	75 11                	jne    f010058d <cons_getc+0x48>
			cons.rpos = 0;
f010057c:	c7 05 a0 e2 17 f0 00 	movl   $0x0,0xf017e2a0
f0100583:	00 00 00 
f0100586:	eb 05                	jmp    f010058d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100588:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010058d:	c9                   	leave  
f010058e:	c3                   	ret    

f010058f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010058f:	55                   	push   %ebp
f0100590:	89 e5                	mov    %esp,%ebp
f0100592:	57                   	push   %edi
f0100593:	56                   	push   %esi
f0100594:	53                   	push   %ebx
f0100595:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100598:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010059f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005a6:	5a a5 
	if (*cp != 0xA55A) {
f01005a8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005af:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005b3:	74 11                	je     f01005c6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005b5:	c7 05 b0 e2 17 f0 b4 	movl   $0x3b4,0xf017e2b0
f01005bc:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005bf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01005c4:	eb 16                	jmp    f01005dc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005cd:	c7 05 b0 e2 17 f0 d4 	movl   $0x3d4,0xf017e2b0
f01005d4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005d7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005dc:	8b 0d b0 e2 17 f0    	mov    0xf017e2b0,%ecx
f01005e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005e7:	89 ca                	mov    %ecx,%edx
f01005e9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ea:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ed:	89 da                	mov    %ebx,%edx
f01005ef:	ec                   	in     (%dx),%al
f01005f0:	0f b6 f0             	movzbl %al,%esi
f01005f3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005fb:	89 ca                	mov    %ecx,%edx
f01005fd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fe:	89 da                	mov    %ebx,%edx
f0100600:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100601:	89 3d ac e2 17 f0    	mov    %edi,0xf017e2ac

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100607:	0f b6 d8             	movzbl %al,%ebx
f010060a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010060c:	66 89 35 a8 e2 17 f0 	mov    %si,0xf017e2a8
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100613:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100618:	b8 00 00 00 00       	mov    $0x0,%eax
f010061d:	89 f2                	mov    %esi,%edx
f010061f:	ee                   	out    %al,(%dx)
f0100620:	b2 fb                	mov    $0xfb,%dl
f0100622:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100627:	ee                   	out    %al,(%dx)
f0100628:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010062d:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100632:	89 da                	mov    %ebx,%edx
f0100634:	ee                   	out    %al,(%dx)
f0100635:	b2 f9                	mov    $0xf9,%dl
f0100637:	b8 00 00 00 00       	mov    $0x0,%eax
f010063c:	ee                   	out    %al,(%dx)
f010063d:	b2 fb                	mov    $0xfb,%dl
f010063f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100644:	ee                   	out    %al,(%dx)
f0100645:	b2 fc                	mov    $0xfc,%dl
f0100647:	b8 00 00 00 00       	mov    $0x0,%eax
f010064c:	ee                   	out    %al,(%dx)
f010064d:	b2 f9                	mov    $0xf9,%dl
f010064f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100654:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100655:	b2 fd                	mov    $0xfd,%dl
f0100657:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100658:	3c ff                	cmp    $0xff,%al
f010065a:	0f 95 c1             	setne  %cl
f010065d:	88 0d b4 e2 17 f0    	mov    %cl,0xf017e2b4
f0100663:	89 f2                	mov    %esi,%edx
f0100665:	ec                   	in     (%dx),%al
f0100666:	89 da                	mov    %ebx,%edx
f0100668:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100669:	84 c9                	test   %cl,%cl
f010066b:	75 0c                	jne    f0100679 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f010066d:	c7 04 24 f5 4f 10 f0 	movl   $0xf0104ff5,(%esp)
f0100674:	e8 2c 31 00 00       	call   f01037a5 <cprintf>
}
f0100679:	83 c4 1c             	add    $0x1c,%esp
f010067c:	5b                   	pop    %ebx
f010067d:	5e                   	pop    %esi
f010067e:	5f                   	pop    %edi
f010067f:	5d                   	pop    %ebp
f0100680:	c3                   	ret    

f0100681 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
f0100684:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100687:	8b 45 08             	mov    0x8(%ebp),%eax
f010068a:	e8 aa fc ff ff       	call   f0100339 <cons_putc>
}
f010068f:	c9                   	leave  
f0100690:	c3                   	ret    

f0100691 <getchar>:

int
getchar(void)
{
f0100691:	55                   	push   %ebp
f0100692:	89 e5                	mov    %esp,%ebp
f0100694:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100697:	e8 a9 fe ff ff       	call   f0100545 <cons_getc>
f010069c:	85 c0                	test   %eax,%eax
f010069e:	74 f7                	je     f0100697 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006a0:	c9                   	leave  
f01006a1:	c3                   	ret    

f01006a2 <iscons>:

int
iscons(int fdnum)
{
f01006a2:	55                   	push   %ebp
f01006a3:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006a5:	b8 01 00 00 00       	mov    $0x1,%eax
f01006aa:	5d                   	pop    %ebp
f01006ab:	c3                   	ret    
f01006ac:	66 90                	xchg   %ax,%ax
f01006ae:	66 90                	xchg   %ax,%ax

f01006b0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006b0:	55                   	push   %ebp
f01006b1:	89 e5                	mov    %esp,%ebp
f01006b3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006b6:	c7 44 24 08 40 52 10 	movl   $0xf0105240,0x8(%esp)
f01006bd:	f0 
f01006be:	c7 44 24 04 5e 52 10 	movl   $0xf010525e,0x4(%esp)
f01006c5:	f0 
f01006c6:	c7 04 24 63 52 10 f0 	movl   $0xf0105263,(%esp)
f01006cd:	e8 d3 30 00 00       	call   f01037a5 <cprintf>
f01006d2:	c7 44 24 08 18 53 10 	movl   $0xf0105318,0x8(%esp)
f01006d9:	f0 
f01006da:	c7 44 24 04 6c 52 10 	movl   $0xf010526c,0x4(%esp)
f01006e1:	f0 
f01006e2:	c7 04 24 63 52 10 f0 	movl   $0xf0105263,(%esp)
f01006e9:	e8 b7 30 00 00       	call   f01037a5 <cprintf>
f01006ee:	c7 44 24 08 75 52 10 	movl   $0xf0105275,0x8(%esp)
f01006f5:	f0 
f01006f6:	c7 44 24 04 7a 52 10 	movl   $0xf010527a,0x4(%esp)
f01006fd:	f0 
f01006fe:	c7 04 24 63 52 10 f0 	movl   $0xf0105263,(%esp)
f0100705:	e8 9b 30 00 00       	call   f01037a5 <cprintf>
	return 0;
}
f010070a:	b8 00 00 00 00       	mov    $0x0,%eax
f010070f:	c9                   	leave  
f0100710:	c3                   	ret    

f0100711 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100711:	55                   	push   %ebp
f0100712:	89 e5                	mov    %esp,%ebp
f0100714:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100717:	c7 04 24 84 52 10 f0 	movl   $0xf0105284,(%esp)
f010071e:	e8 82 30 00 00       	call   f01037a5 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100723:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010072a:	00 
f010072b:	c7 04 24 40 53 10 f0 	movl   $0xf0105340,(%esp)
f0100732:	e8 6e 30 00 00       	call   f01037a5 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100737:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010073e:	00 
f010073f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100746:	f0 
f0100747:	c7 04 24 68 53 10 f0 	movl   $0xf0105368,(%esp)
f010074e:	e8 52 30 00 00       	call   f01037a5 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100753:	c7 44 24 08 57 4f 10 	movl   $0x104f57,0x8(%esp)
f010075a:	00 
f010075b:	c7 44 24 04 57 4f 10 	movl   $0xf0104f57,0x4(%esp)
f0100762:	f0 
f0100763:	c7 04 24 8c 53 10 f0 	movl   $0xf010538c,(%esp)
f010076a:	e8 36 30 00 00       	call   f01037a5 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010076f:	c7 44 24 08 63 e0 17 	movl   $0x17e063,0x8(%esp)
f0100776:	00 
f0100777:	c7 44 24 04 63 e0 17 	movl   $0xf017e063,0x4(%esp)
f010077e:	f0 
f010077f:	c7 04 24 b0 53 10 f0 	movl   $0xf01053b0,(%esp)
f0100786:	e8 1a 30 00 00       	call   f01037a5 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010078b:	c7 44 24 08 90 ef 17 	movl   $0x17ef90,0x8(%esp)
f0100792:	00 
f0100793:	c7 44 24 04 90 ef 17 	movl   $0xf017ef90,0x4(%esp)
f010079a:	f0 
f010079b:	c7 04 24 d4 53 10 f0 	movl   $0xf01053d4,(%esp)
f01007a2:	e8 fe 2f 00 00       	call   f01037a5 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01007a7:	b8 8f f3 17 f0       	mov    $0xf017f38f,%eax
f01007ac:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007b1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007b6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007bc:	85 c0                	test   %eax,%eax
f01007be:	0f 48 c2             	cmovs  %edx,%eax
f01007c1:	c1 f8 0a             	sar    $0xa,%eax
f01007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c8:	c7 04 24 f8 53 10 f0 	movl   $0xf01053f8,(%esp)
f01007cf:	e8 d1 2f 00 00       	call   f01037a5 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d9:	c9                   	leave  
f01007da:	c3                   	ret    

f01007db <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{       
f01007db:	55                   	push   %ebp
f01007dc:	89 e5                	mov    %esp,%ebp
f01007de:	56                   	push   %esi
f01007df:	53                   	push   %ebx
f01007e0:	83 ec 40             	sub    $0x40,%esp
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f01007e3:	c7 04 24 9d 52 10 f0 	movl   $0xf010529d,(%esp)
f01007ea:	e8 b6 2f 00 00       	call   f01037a5 <cprintf>
	uint32_t *  ebp=(uint32_t *)read_ebp();
f01007ef:	89 eb                	mov    %ebp,%ebx
	while(ebp!=0x0){
	debuginfo_eip(*(ebp+1),&info);
f01007f1:	8d 75 e0             	lea    -0x20(%ebp),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{       
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	uint32_t *  ebp=(uint32_t *)read_ebp();
	while(ebp!=0x0){
f01007f4:	e9 b9 00 00 00       	jmp    f01008b2 <mon_backtrace+0xd7>
	debuginfo_eip(*(ebp+1),&info);
f01007f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007fd:	8b 43 04             	mov    0x4(%ebx),%eax
f0100800:	89 04 24             	mov    %eax,(%esp)
f0100803:	e8 a9 37 00 00       	call   f0103fb1 <debuginfo_eip>
	cprintf("ebp %08x eip %08x",ebp,*(ebp+1));
f0100808:	8b 43 04             	mov    0x4(%ebx),%eax
f010080b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010080f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100813:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010081a:	e8 86 2f 00 00       	call   f01037a5 <cprintf>
	cprintf(" args %08x",*(ebp+2));
f010081f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100822:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100826:	c7 04 24 c1 52 10 f0 	movl   $0xf01052c1,(%esp)
f010082d:	e8 73 2f 00 00       	call   f01037a5 <cprintf>
	cprintf(" %08x",*(ebp+3));
f0100832:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100835:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100839:	c7 04 24 bb 52 10 f0 	movl   $0xf01052bb,(%esp)
f0100840:	e8 60 2f 00 00       	call   f01037a5 <cprintf>
	cprintf(" %08x",*(ebp+4));
f0100845:	8b 43 10             	mov    0x10(%ebx),%eax
f0100848:	89 44 24 04          	mov    %eax,0x4(%esp)
f010084c:	c7 04 24 bb 52 10 f0 	movl   $0xf01052bb,(%esp)
f0100853:	e8 4d 2f 00 00       	call   f01037a5 <cprintf>
	cprintf(" %08x",*(ebp+5));
f0100858:	8b 43 14             	mov    0x14(%ebx),%eax
f010085b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010085f:	c7 04 24 bb 52 10 f0 	movl   $0xf01052bb,(%esp)
f0100866:	e8 3a 2f 00 00       	call   f01037a5 <cprintf>
	cprintf(" %08x\n",*(ebp+6));
f010086b:	8b 43 18             	mov    0x18(%ebx),%eax
f010086e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100872:	c7 04 24 01 66 10 f0 	movl   $0xf0106601,(%esp)
f0100879:	e8 27 2f 00 00       	call   f01037a5 <cprintf>
	cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,*(ebp+1)-info.eip_fn_addr);
f010087e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100881:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100884:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100888:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010088b:	89 44 24 10          	mov    %eax,0x10(%esp)
f010088f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100892:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100896:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100899:	89 44 24 08          	mov    %eax,0x8(%esp)
f010089d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a4:	c7 04 24 cc 52 10 f0 	movl   $0xf01052cc,(%esp)
f01008ab:	e8 f5 2e 00 00       	call   f01037a5 <cprintf>
	ebp=(uint32_t *) *(ebp);
f01008b0:	8b 1b                	mov    (%ebx),%ebx
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{       
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	uint32_t *  ebp=(uint32_t *)read_ebp();
	while(ebp!=0x0){
f01008b2:	85 db                	test   %ebx,%ebx
f01008b4:	0f 85 3f ff ff ff    	jne    f01007f9 <mon_backtrace+0x1e>
	cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,*(ebp+1)-info.eip_fn_addr);
	ebp=(uint32_t *) *(ebp);
	}
 
	return 0;
}
f01008ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01008bf:	83 c4 40             	add    $0x40,%esp
f01008c2:	5b                   	pop    %ebx
f01008c3:	5e                   	pop    %esi
f01008c4:	5d                   	pop    %ebp
f01008c5:	c3                   	ret    

f01008c6 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008c6:	55                   	push   %ebp
f01008c7:	89 e5                	mov    %esp,%ebp
f01008c9:	57                   	push   %edi
f01008ca:	56                   	push   %esi
f01008cb:	53                   	push   %ebx
f01008cc:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008cf:	c7 04 24 24 54 10 f0 	movl   $0xf0105424,(%esp)
f01008d6:	e8 ca 2e 00 00       	call   f01037a5 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008db:	c7 04 24 48 54 10 f0 	movl   $0xf0105448,(%esp)
f01008e2:	e8 be 2e 00 00       	call   f01037a5 <cprintf>


	if (tf != NULL)
f01008e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008eb:	74 0b                	je     f01008f8 <monitor+0x32>
		print_trapframe(tf);
f01008ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01008f0:	89 04 24             	mov    %eax,(%esp)
f01008f3:	e8 c4 30 00 00       	call   f01039bc <print_trapframe>



 	while (1) {

		buf = readline("K> ");
f01008f8:	c7 04 24 dc 52 10 f0 	movl   $0xf01052dc,(%esp)
f01008ff:	e8 6c 3f 00 00       	call   f0104870 <readline>
f0100904:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100906:	85 c0                	test   %eax,%eax
f0100908:	74 ee                	je     f01008f8 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010090a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100911:	be 00 00 00 00       	mov    $0x0,%esi
f0100916:	eb 0a                	jmp    f0100922 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100918:	c6 03 00             	movb   $0x0,(%ebx)
f010091b:	89 f7                	mov    %esi,%edi
f010091d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100920:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100922:	0f b6 03             	movzbl (%ebx),%eax
f0100925:	84 c0                	test   %al,%al
f0100927:	74 63                	je     f010098c <monitor+0xc6>
f0100929:	0f be c0             	movsbl %al,%eax
f010092c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100930:	c7 04 24 e0 52 10 f0 	movl   $0xf01052e0,(%esp)
f0100937:	e8 4e 41 00 00       	call   f0104a8a <strchr>
f010093c:	85 c0                	test   %eax,%eax
f010093e:	75 d8                	jne    f0100918 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100940:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100943:	74 47                	je     f010098c <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100945:	83 fe 0f             	cmp    $0xf,%esi
f0100948:	75 16                	jne    f0100960 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010094a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100951:	00 
f0100952:	c7 04 24 e5 52 10 f0 	movl   $0xf01052e5,(%esp)
f0100959:	e8 47 2e 00 00       	call   f01037a5 <cprintf>
f010095e:	eb 98                	jmp    f01008f8 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100960:	8d 7e 01             	lea    0x1(%esi),%edi
f0100963:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100967:	eb 03                	jmp    f010096c <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100969:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010096c:	0f b6 03             	movzbl (%ebx),%eax
f010096f:	84 c0                	test   %al,%al
f0100971:	74 ad                	je     f0100920 <monitor+0x5a>
f0100973:	0f be c0             	movsbl %al,%eax
f0100976:	89 44 24 04          	mov    %eax,0x4(%esp)
f010097a:	c7 04 24 e0 52 10 f0 	movl   $0xf01052e0,(%esp)
f0100981:	e8 04 41 00 00       	call   f0104a8a <strchr>
f0100986:	85 c0                	test   %eax,%eax
f0100988:	74 df                	je     f0100969 <monitor+0xa3>
f010098a:	eb 94                	jmp    f0100920 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f010098c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100993:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100994:	85 f6                	test   %esi,%esi
f0100996:	0f 84 5c ff ff ff    	je     f01008f8 <monitor+0x32>
f010099c:	bb 00 00 00 00       	mov    $0x0,%ebx
f01009a1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009a4:	8b 04 85 80 54 10 f0 	mov    -0xfefab80(,%eax,4),%eax
f01009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009af:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009b2:	89 04 24             	mov    %eax,(%esp)
f01009b5:	e8 72 40 00 00       	call   f0104a2c <strcmp>
f01009ba:	85 c0                	test   %eax,%eax
f01009bc:	75 24                	jne    f01009e2 <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f01009be:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009c1:	8b 55 08             	mov    0x8(%ebp),%edx
f01009c4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01009c8:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01009cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01009cf:	89 34 24             	mov    %esi,(%esp)
f01009d2:	ff 14 85 88 54 10 f0 	call   *-0xfefab78(,%eax,4)

 	while (1) {

		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009d9:	85 c0                	test   %eax,%eax
f01009db:	78 25                	js     f0100a02 <monitor+0x13c>
f01009dd:	e9 16 ff ff ff       	jmp    f01008f8 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009e2:	83 c3 01             	add    $0x1,%ebx
f01009e5:	83 fb 03             	cmp    $0x3,%ebx
f01009e8:	75 b7                	jne    f01009a1 <monitor+0xdb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009ea:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f1:	c7 04 24 02 53 10 f0 	movl   $0xf0105302,(%esp)
f01009f8:	e8 a8 2d 00 00       	call   f01037a5 <cprintf>
f01009fd:	e9 f6 fe ff ff       	jmp    f01008f8 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a02:	83 c4 5c             	add    $0x5c,%esp
f0100a05:	5b                   	pop    %ebx
f0100a06:	5e                   	pop    %esi
f0100a07:	5f                   	pop    %edi
f0100a08:	5d                   	pop    %ebp
f0100a09:	c3                   	ret    
f0100a0a:	66 90                	xchg   %ax,%ax
f0100a0c:	66 90                	xchg   %ax,%ax
f0100a0e:	66 90                	xchg   %ax,%ax

f0100a10 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
f0100a13:	53                   	push   %ebx
f0100a14:	83 ec 14             	sub    $0x14,%esp
f0100a17:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a19:	83 3d b8 e2 17 f0 00 	cmpl   $0x0,0xf017e2b8
f0100a20:	75 0f                	jne    f0100a31 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a22:	b8 8f ff 17 f0       	mov    $0xf017ff8f,%eax
f0100a27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a2c:	a3 b8 e2 17 f0       	mov    %eax,0xf017e2b8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100a31:	a1 b8 e2 17 f0       	mov    0xf017e2b8,%eax
f0100a36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3a:	c7 04 24 a4 54 10 f0 	movl   $0xf01054a4,(%esp)
f0100a41:	e8 5f 2d 00 00       	call   f01037a5 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100a46:	89 d8                	mov    %ebx,%eax
f0100a48:	03 05 b8 e2 17 f0    	add    0xf017e2b8,%eax
f0100a4e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100a53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a5c:	c7 04 24 bd 54 10 f0 	movl   $0xf01054bd,(%esp)
f0100a63:	e8 3d 2d 00 00       	call   f01037a5 <cprintf>
	if (n != 0) {
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f0100a68:	a1 b8 e2 17 f0       	mov    0xf017e2b8,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
f0100a6d:	85 db                	test   %ebx,%ebx
f0100a6f:	74 13                	je     f0100a84 <boot_alloc+0x74>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100a71:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100a78:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a7e:	89 15 b8 e2 17 f0    	mov    %edx,0xf017e2b8
		return next;
	} else return nextfree;

	return NULL;
}
f0100a84:	83 c4 14             	add    $0x14,%esp
f0100a87:	5b                   	pop    %ebx
f0100a88:	5d                   	pop    %ebp
f0100a89:	c3                   	ret    

f0100a8a <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a8a:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f0100a90:	c1 f8 03             	sar    $0x3,%eax
f0100a93:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a96:	89 c2                	mov    %eax,%edx
f0100a98:	c1 ea 0c             	shr    $0xc,%edx
f0100a9b:	3b 15 84 ef 17 f0    	cmp    0xf017ef84,%edx
f0100aa1:	72 26                	jb     f0100ac9 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100aa3:	55                   	push   %ebp
f0100aa4:	89 e5                	mov    %esp,%ebp
f0100aa6:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100aad:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0100ab4:	f0 
f0100ab5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100abc:	00 
f0100abd:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f0100ac4:	e8 5d f6 ff ff       	call   f0100126 <_panic>
	return (void *)(pa + KERNBASE);
f0100ac9:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100ace:	c3                   	ret    

f0100acf <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100acf:	89 d1                	mov    %edx,%ecx
f0100ad1:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ad4:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad7:	a8 01                	test   $0x1,%al
f0100ad9:	74 5d                	je     f0100b38 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100adb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ae0:	89 c1                	mov    %eax,%ecx
f0100ae2:	c1 e9 0c             	shr    $0xc,%ecx
f0100ae5:	3b 0d 84 ef 17 f0    	cmp    0xf017ef84,%ecx
f0100aeb:	72 26                	jb     f0100b13 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100aed:	55                   	push   %ebp
f0100aee:	89 e5                	mov    %esp,%ebp
f0100af0:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100af3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100af7:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0100afe:	f0 
f0100aff:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0100b06:	00 
f0100b07:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100b0e:	e8 13 f6 ff ff       	call   f0100126 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b13:	c1 ea 0c             	shr    $0xc,%edx
f0100b16:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b1c:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b23:	89 c2                	mov    %eax,%edx
f0100b25:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b2d:	85 d2                	test   %edx,%edx
f0100b2f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b34:	0f 44 c2             	cmove  %edx,%eax
f0100b37:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b3d:	c3                   	ret    

f0100b3e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b3e:	55                   	push   %ebp
f0100b3f:	89 e5                	mov    %esp,%ebp
f0100b41:	57                   	push   %edi
f0100b42:	56                   	push   %esi
f0100b43:	53                   	push   %ebx
f0100b44:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b47:	84 c0                	test   %al,%al
f0100b49:	0f 85 15 03 00 00    	jne    f0100e64 <check_page_free_list+0x326>
f0100b4f:	e9 22 03 00 00       	jmp    f0100e76 <check_page_free_list+0x338>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b54:	c7 44 24 08 68 58 10 	movl   $0xf0105868,0x8(%esp)
f0100b5b:	f0 
f0100b5c:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
f0100b63:	00 
f0100b64:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100b6b:	e8 b6 f5 ff ff       	call   f0100126 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b70:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b73:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b76:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b7c:	89 c2                	mov    %eax,%edx
f0100b7e:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b84:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b8a:	0f 95 c2             	setne  %dl
f0100b8d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b90:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b94:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b96:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b9a:	8b 00                	mov    (%eax),%eax
f0100b9c:	85 c0                	test   %eax,%eax
f0100b9e:	75 dc                	jne    f0100b7c <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ba3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100baf:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bb4:	a3 c0 e2 17 f0       	mov    %eax,0xf017e2c0
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb9:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bbe:	8b 1d c0 e2 17 f0    	mov    0xf017e2c0,%ebx
f0100bc4:	eb 63                	jmp    f0100c29 <check_page_free_list+0xeb>
f0100bc6:	89 d8                	mov    %ebx,%eax
f0100bc8:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f0100bce:	c1 f8 03             	sar    $0x3,%eax
f0100bd1:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bd4:	89 c2                	mov    %eax,%edx
f0100bd6:	c1 ea 16             	shr    $0x16,%edx
f0100bd9:	39 f2                	cmp    %esi,%edx
f0100bdb:	73 4a                	jae    f0100c27 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bdd:	89 c2                	mov    %eax,%edx
f0100bdf:	c1 ea 0c             	shr    $0xc,%edx
f0100be2:	3b 15 84 ef 17 f0    	cmp    0xf017ef84,%edx
f0100be8:	72 20                	jb     f0100c0a <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bee:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0100bf5:	f0 
f0100bf6:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100bfd:	00 
f0100bfe:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f0100c05:	e8 1c f5 ff ff       	call   f0100126 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c0a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c11:	00 
f0100c12:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c19:	00 
	return (void *)(pa + KERNBASE);
f0100c1a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c1f:	89 04 24             	mov    %eax,(%esp)
f0100c22:	e8 a0 3e 00 00       	call   f0104ac7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c27:	8b 1b                	mov    (%ebx),%ebx
f0100c29:	85 db                	test   %ebx,%ebx
f0100c2b:	75 99                	jne    f0100bc6 <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c32:	e8 d9 fd ff ff       	call   f0100a10 <boot_alloc>
f0100c37:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3a:	8b 15 c0 e2 17 f0    	mov    0xf017e2c0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c40:	8b 0d 8c ef 17 f0    	mov    0xf017ef8c,%ecx
		assert(pp < pages + npages);
f0100c46:	a1 84 ef 17 f0       	mov    0xf017ef84,%eax
f0100c4b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c4e:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c54:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c57:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c5c:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c5f:	e9 97 01 00 00       	jmp    f0100dfb <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c64:	39 ca                	cmp    %ecx,%edx
f0100c66:	73 24                	jae    f0100c8c <check_page_free_list+0x14e>
f0100c68:	c7 44 24 0c ea 54 10 	movl   $0xf01054ea,0xc(%esp)
f0100c6f:	f0 
f0100c70:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100c77:	f0 
f0100c78:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
f0100c7f:	00 
f0100c80:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100c87:	e8 9a f4 ff ff       	call   f0100126 <_panic>
		assert(pp < pages + npages);
f0100c8c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c8f:	72 24                	jb     f0100cb5 <check_page_free_list+0x177>
f0100c91:	c7 44 24 0c 0b 55 10 	movl   $0xf010550b,0xc(%esp)
f0100c98:	f0 
f0100c99:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100ca0:	f0 
f0100ca1:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
f0100ca8:	00 
f0100ca9:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100cb0:	e8 71 f4 ff ff       	call   f0100126 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb5:	89 d0                	mov    %edx,%eax
f0100cb7:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cba:	a8 07                	test   $0x7,%al
f0100cbc:	74 24                	je     f0100ce2 <check_page_free_list+0x1a4>
f0100cbe:	c7 44 24 0c 8c 58 10 	movl   $0xf010588c,0xc(%esp)
f0100cc5:	f0 
f0100cc6:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100ccd:	f0 
f0100cce:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f0100cd5:	00 
f0100cd6:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100cdd:	e8 44 f4 ff ff       	call   f0100126 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ce2:	c1 f8 03             	sar    $0x3,%eax
f0100ce5:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ce8:	85 c0                	test   %eax,%eax
f0100cea:	75 24                	jne    f0100d10 <check_page_free_list+0x1d2>
f0100cec:	c7 44 24 0c 1f 55 10 	movl   $0xf010551f,0xc(%esp)
f0100cf3:	f0 
f0100cf4:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100cfb:	f0 
f0100cfc:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f0100d03:	00 
f0100d04:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100d0b:	e8 16 f4 ff ff       	call   f0100126 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d10:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d15:	75 24                	jne    f0100d3b <check_page_free_list+0x1fd>
f0100d17:	c7 44 24 0c 30 55 10 	movl   $0xf0105530,0xc(%esp)
f0100d1e:	f0 
f0100d1f:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100d26:	f0 
f0100d27:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f0100d2e:	00 
f0100d2f:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100d36:	e8 eb f3 ff ff       	call   f0100126 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d3b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d40:	75 24                	jne    f0100d66 <check_page_free_list+0x228>
f0100d42:	c7 44 24 0c c0 58 10 	movl   $0xf01058c0,0xc(%esp)
f0100d49:	f0 
f0100d4a:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100d51:	f0 
f0100d52:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
f0100d59:	00 
f0100d5a:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100d61:	e8 c0 f3 ff ff       	call   f0100126 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d66:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d6b:	75 24                	jne    f0100d91 <check_page_free_list+0x253>
f0100d6d:	c7 44 24 0c 49 55 10 	movl   $0xf0105549,0xc(%esp)
f0100d74:	f0 
f0100d75:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100d7c:	f0 
f0100d7d:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0100d84:	00 
f0100d85:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100d8c:	e8 95 f3 ff ff       	call   f0100126 <_panic>
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d91:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d96:	76 58                	jbe    f0100df0 <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d98:	89 c3                	mov    %eax,%ebx
f0100d9a:	c1 eb 0c             	shr    $0xc,%ebx
f0100d9d:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100da0:	77 20                	ja     f0100dc2 <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100da2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100da6:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0100dad:	f0 
f0100dae:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100db5:	00 
f0100db6:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f0100dbd:	e8 64 f3 ff ff       	call   f0100126 <_panic>
	return (void *)(pa + KERNBASE);
f0100dc2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dc7:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100dca:	76 2a                	jbe    f0100df6 <check_page_free_list+0x2b8>
f0100dcc:	c7 44 24 0c e4 58 10 	movl   $0xf01058e4,0xc(%esp)
f0100dd3:	f0 
f0100dd4:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100ddb:	f0 
f0100ddc:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
f0100de3:	00 
f0100de4:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100deb:	e8 36 f3 ff ff       	call   f0100126 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100df0:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100df4:	eb 03                	jmp    f0100df9 <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100df6:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100df9:	8b 12                	mov    (%edx),%edx
f0100dfb:	85 d2                	test   %edx,%edx
f0100dfd:	0f 85 61 fe ff ff    	jne    f0100c64 <check_page_free_list+0x126>
f0100e03:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e06:	85 db                	test   %ebx,%ebx
f0100e08:	7f 24                	jg     f0100e2e <check_page_free_list+0x2f0>
f0100e0a:	c7 44 24 0c 63 55 10 	movl   $0xf0105563,0xc(%esp)
f0100e11:	f0 
f0100e12:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100e19:	f0 
f0100e1a:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
f0100e21:	00 
f0100e22:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100e29:	e8 f8 f2 ff ff       	call   f0100126 <_panic>
	assert(nfree_extmem > 0);
f0100e2e:	85 ff                	test   %edi,%edi
f0100e30:	7f 24                	jg     f0100e56 <check_page_free_list+0x318>
f0100e32:	c7 44 24 0c 75 55 10 	movl   $0xf0105575,0xc(%esp)
f0100e39:	f0 
f0100e3a:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0100e41:	f0 
f0100e42:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0100e49:	00 
f0100e4a:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0100e51:	e8 d0 f2 ff ff       	call   f0100126 <_panic>
	cprintf("check_page_free_list done\n");
f0100e56:	c7 04 24 86 55 10 f0 	movl   $0xf0105586,(%esp)
f0100e5d:	e8 43 29 00 00       	call   f01037a5 <cprintf>
f0100e62:	eb 29                	jmp    f0100e8d <check_page_free_list+0x34f>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e64:	a1 c0 e2 17 f0       	mov    0xf017e2c0,%eax
f0100e69:	85 c0                	test   %eax,%eax
f0100e6b:	0f 85 ff fc ff ff    	jne    f0100b70 <check_page_free_list+0x32>
f0100e71:	e9 de fc ff ff       	jmp    f0100b54 <check_page_free_list+0x16>
f0100e76:	83 3d c0 e2 17 f0 00 	cmpl   $0x0,0xf017e2c0
f0100e7d:	0f 84 d1 fc ff ff    	je     f0100b54 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e83:	be 00 04 00 00       	mov    $0x400,%esi
f0100e88:	e9 31 fd ff ff       	jmp    f0100bbe <check_page_free_list+0x80>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list done\n");
}
f0100e8d:	83 c4 4c             	add    $0x4c,%esp
f0100e90:	5b                   	pop    %ebx
f0100e91:	5e                   	pop    %esi
f0100e92:	5f                   	pop    %edi
f0100e93:	5d                   	pop    %ebp
f0100e94:	c3                   	ret    

f0100e95 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e95:	55                   	push   %ebp
f0100e96:	89 e5                	mov    %esp,%ebp
f0100e98:	56                   	push   %esi
f0100e99:	53                   	push   %ebx
f0100e9a:	83 ec 10             	sub    $0x10,%esp
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100e9d:	8b 35 c4 e2 17 f0    	mov    0xf017e2c4,%esi
f0100ea3:	8b 1d c0 e2 17 f0    	mov    0xf017e2c0,%ebx
f0100ea9:	b8 01 00 00 00       	mov    $0x1,%eax
f0100eae:	eb 22                	jmp    f0100ed2 <page_init+0x3d>
f0100eb0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100eb7:	89 d1                	mov    %edx,%ecx
f0100eb9:	03 0d 8c ef 17 f0    	add    0xf017ef8c,%ecx
f0100ebf:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ec5:	89 19                	mov    %ebx,(%ecx)
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100ec7:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100eca:	03 15 8c ef 17 f0    	add    0xf017ef8c,%edx
f0100ed0:	89 d3                	mov    %edx,%ebx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100ed2:	39 f0                	cmp    %esi,%eax
f0100ed4:	72 da                	jb     f0100eb0 <page_init+0x1b>
f0100ed6:	89 1d c0 e2 17 f0    	mov    %ebx,0xf017e2c0
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0100edc:	8b 15 cc e2 17 f0    	mov    0xf017e2cc,%edx
f0100ee2:	8d 82 ff 8f 01 10    	lea    0x10018fff(%edx),%eax
f0100ee8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100eed:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f0100ef3:	85 c0                	test   %eax,%eax
f0100ef5:	0f 49 f0             	cmovns %eax,%esi
f0100ef8:	c1 fe 0c             	sar    $0xc,%esi
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
f0100efb:	81 c2 00 80 01 00    	add    $0x18000,%edx
f0100f01:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f05:	c7 04 24 0e 58 10 f0 	movl   $0xf010580e,(%esp)
f0100f0c:	e8 94 28 00 00       	call   f01037a5 <cprintf>
	cprintf("med=%d\n", med);
f0100f11:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f15:	c7 04 24 a1 55 10 f0 	movl   $0xf01055a1,(%esp)
f0100f1c:	e8 84 28 00 00       	call   f01037a5 <cprintf>
	for (i = med; i < npages; i++) {
f0100f21:	89 f2                	mov    %esi,%edx
f0100f23:	8b 1d c0 e2 17 f0    	mov    0xf017e2c0,%ebx
f0100f29:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
f0100f30:	eb 1e                	jmp    f0100f50 <page_init+0xbb>
		pages[i].pp_ref = 0;
f0100f32:	89 c1                	mov    %eax,%ecx
f0100f34:	03 0d 8c ef 17 f0    	add    0xf017ef8c,%ecx
f0100f3a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f40:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100f42:	89 c3                	mov    %eax,%ebx
f0100f44:	03 1d 8c ef 17 f0    	add    0xf017ef8c,%ebx
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
f0100f4a:	83 c2 01             	add    $0x1,%edx
f0100f4d:	83 c0 08             	add    $0x8,%eax
f0100f50:	3b 15 84 ef 17 f0    	cmp    0xf017ef84,%edx
f0100f56:	72 da                	jb     f0100f32 <page_init+0x9d>
f0100f58:	89 1d c0 e2 17 f0    	mov    %ebx,0xf017e2c0
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100f5e:	83 c4 10             	add    $0x10,%esp
f0100f61:	5b                   	pop    %ebx
f0100f62:	5e                   	pop    %esi
f0100f63:	5d                   	pop    %ebp
f0100f64:	c3                   	ret    

f0100f65 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f65:	55                   	push   %ebp
f0100f66:	89 e5                	mov    %esp,%ebp
f0100f68:	53                   	push   %ebx
f0100f69:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) {
f0100f6c:	8b 1d c0 e2 17 f0    	mov    0xf017e2c0,%ebx
f0100f72:	85 db                	test   %ebx,%ebx
f0100f74:	74 69                	je     f0100fdf <page_alloc+0x7a>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100f76:	8b 03                	mov    (%ebx),%eax
f0100f78:	a3 c0 e2 17 f0       	mov    %eax,0xf017e2c0
		if (alloc_flags & ALLOC_ZERO) 
			memset(page2kva(ret), 0, PGSIZE);
		return ret;
f0100f7d:	89 d8                	mov    %ebx,%eax
page_alloc(int alloc_flags)
{
	if (page_free_list) {
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
		if (alloc_flags & ALLOC_ZERO) 
f0100f7f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f83:	74 5f                	je     f0100fe4 <page_alloc+0x7f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f85:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f0100f8b:	c1 f8 03             	sar    $0x3,%eax
f0100f8e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f91:	89 c2                	mov    %eax,%edx
f0100f93:	c1 ea 0c             	shr    $0xc,%edx
f0100f96:	3b 15 84 ef 17 f0    	cmp    0xf017ef84,%edx
f0100f9c:	72 20                	jb     f0100fbe <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa2:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0100fa9:	f0 
f0100faa:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100fb1:	00 
f0100fb2:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f0100fb9:	e8 68 f1 ff ff       	call   f0100126 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0100fbe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fc5:	00 
f0100fc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fcd:	00 
	return (void *)(pa + KERNBASE);
f0100fce:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fd3:	89 04 24             	mov    %eax,(%esp)
f0100fd6:	e8 ec 3a 00 00       	call   f0104ac7 <memset>
		return ret;
f0100fdb:	89 d8                	mov    %ebx,%eax
f0100fdd:	eb 05                	jmp    f0100fe4 <page_alloc+0x7f>
	}
	return NULL;
f0100fdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fe4:	83 c4 14             	add    $0x14,%esp
f0100fe7:	5b                   	pop    %ebx
f0100fe8:	5d                   	pop    %ebp
f0100fe9:	c3                   	ret    

f0100fea <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0100ff0:	8b 15 c0 e2 17 f0    	mov    0xf017e2c0,%edx
f0100ff6:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ff8:	a3 c0 e2 17 f0       	mov    %eax,0xf017e2c0
}
f0100ffd:	5d                   	pop    %ebp
f0100ffe:	c3                   	ret    

f0100fff <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fff:	55                   	push   %ebp
f0101000:	89 e5                	mov    %esp,%ebp
f0101002:	83 ec 04             	sub    $0x4,%esp
f0101005:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101008:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010100c:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010100f:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101013:	66 85 d2             	test   %dx,%dx
f0101016:	75 08                	jne    f0101020 <page_decref+0x21>
		page_free(pp);
f0101018:	89 04 24             	mov    %eax,(%esp)
f010101b:	e8 ca ff ff ff       	call   f0100fea <page_free>
}
f0101020:	c9                   	leave  
f0101021:	c3                   	ret    

f0101022 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101022:	55                   	push   %ebp
f0101023:	89 e5                	mov    %esp,%ebp
f0101025:	56                   	push   %esi
f0101026:	53                   	push   %ebx
f0101027:	83 ec 10             	sub    $0x10,%esp
f010102a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int dindex = PDX(va), tindex = PTX(va);
f010102d:	89 de                	mov    %ebx,%esi
f010102f:	c1 ee 0c             	shr    $0xc,%esi
f0101032:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101038:	c1 eb 16             	shr    $0x16,%ebx
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f010103b:	c1 e3 02             	shl    $0x2,%ebx
f010103e:	03 5d 08             	add    0x8(%ebp),%ebx
f0101041:	f6 03 01             	testb  $0x1,(%ebx)
f0101044:	75 2c                	jne    f0101072 <pgdir_walk+0x50>
		if (create) {
f0101046:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010104a:	74 63                	je     f01010af <pgdir_walk+0x8d>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f010104c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101053:	e8 0d ff ff ff       	call   f0100f65 <page_alloc>
			if (!pg) return NULL;	//allocation fails
f0101058:	85 c0                	test   %eax,%eax
f010105a:	74 5a                	je     f01010b6 <pgdir_walk+0x94>
			pg->pp_ref++;
f010105c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101061:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f0101067:	c1 f8 03             	sar    $0x3,%eax
f010106a:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f010106d:	83 c8 07             	or     $0x7,%eax
f0101070:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0101072:	8b 03                	mov    (%ebx),%eax
f0101074:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101079:	89 c2                	mov    %eax,%edx
f010107b:	c1 ea 0c             	shr    $0xc,%edx
f010107e:	3b 15 84 ef 17 f0    	cmp    0xf017ef84,%edx
f0101084:	72 20                	jb     f01010a6 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101086:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010108a:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0101091:	f0 
f0101092:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0101099:	00 
f010109a:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01010a1:	e8 80 f0 ff ff       	call   f0100126 <_panic>
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f01010a6:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f01010ad:	eb 0c                	jmp    f01010bb <pgdir_walk+0x99>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f01010af:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b4:	eb 05                	jmp    f01010bb <pgdir_walk+0x99>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f01010b6:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f01010bb:	83 c4 10             	add    $0x10,%esp
f01010be:	5b                   	pop    %ebx
f01010bf:	5e                   	pop    %esi
f01010c0:	5d                   	pop    %ebp
f01010c1:	c3                   	ret    

f01010c2 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010c2:	55                   	push   %ebp
f01010c3:	89 e5                	mov    %esp,%ebp
f01010c5:	57                   	push   %edi
f01010c6:	56                   	push   %esi
f01010c7:	53                   	push   %ebx
f01010c8:	83 ec 2c             	sub    $0x2c,%esp
f01010cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010ce:	89 d7                	mov    %edx,%edi
f01010d0:	89 cb                	mov    %ecx,%ebx
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f01010d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01010d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010d9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010dd:	c7 04 24 2c 59 10 f0 	movl   $0xf010592c,(%esp)
f01010e4:	e8 bc 26 00 00       	call   f01037a5 <cprintf>
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01010e9:	c1 eb 0c             	shr    $0xc,%ebx
f01010ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010f2:	be 00 00 00 00       	mov    $0x0,%esi
f01010f7:	29 df                	sub    %ebx,%edi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f01010f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010fc:	83 c8 01             	or     $0x1,%eax
f01010ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101102:	eb 4a                	jmp    f010114e <boot_map_region+0x8c>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f0101104:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010110b:	00 
f010110c:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010110f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101113:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101116:	89 04 24             	mov    %eax,(%esp)
f0101119:	e8 04 ff ff ff       	call   f0101022 <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f010111e:	85 c0                	test   %eax,%eax
f0101120:	75 1c                	jne    f010113e <boot_map_region+0x7c>
f0101122:	c7 44 24 08 60 59 10 	movl   $0xf0105960,0x8(%esp)
f0101129:	f0 
f010112a:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f0101131:	00 
f0101132:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101139:	e8 e8 ef ff ff       	call   f0100126 <_panic>
		*pte = pa | perm | PTE_P;
f010113e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101141:	09 da                	or     %ebx,%edx
f0101143:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101145:	83 c6 01             	add    $0x1,%esi
f0101148:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010114e:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101151:	75 b1                	jne    f0101104 <boot_map_region+0x42>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f0101153:	83 c4 2c             	add    $0x2c,%esp
f0101156:	5b                   	pop    %ebx
f0101157:	5e                   	pop    %esi
f0101158:	5f                   	pop    %edi
f0101159:	5d                   	pop    %ebp
f010115a:	c3                   	ret    

f010115b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010115b:	55                   	push   %ebp
f010115c:	89 e5                	mov    %esp,%ebp
f010115e:	53                   	push   %ebx
f010115f:	83 ec 14             	sub    $0x14,%esp
f0101162:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f0101165:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010116c:	00 
f010116d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101170:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101174:	8b 45 08             	mov    0x8(%ebp),%eax
f0101177:	89 04 24             	mov    %eax,(%esp)
f010117a:	e8 a3 fe ff ff       	call   f0101022 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f010117f:	85 c0                	test   %eax,%eax
f0101181:	74 3f                	je     f01011c2 <page_lookup+0x67>
f0101183:	f6 00 01             	testb  $0x1,(%eax)
f0101186:	74 41                	je     f01011c9 <page_lookup+0x6e>
	if (pte_store)
f0101188:	85 db                	test   %ebx,%ebx
f010118a:	74 02                	je     f010118e <page_lookup+0x33>
		*pte_store = pte;	//found and set
f010118c:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));		
f010118e:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101190:	c1 e8 0c             	shr    $0xc,%eax
f0101193:	3b 05 84 ef 17 f0    	cmp    0xf017ef84,%eax
f0101199:	72 1c                	jb     f01011b7 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f010119b:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f01011a2:	f0 
f01011a3:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01011aa:	00 
f01011ab:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f01011b2:	e8 6f ef ff ff       	call   f0100126 <_panic>
	return &pages[PGNUM(pa)];
f01011b7:	8b 15 8c ef 17 f0    	mov    0xf017ef8c,%edx
f01011bd:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01011c0:	eb 0c                	jmp    f01011ce <page_lookup+0x73>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f01011c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c7:	eb 05                	jmp    f01011ce <page_lookup+0x73>
f01011c9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f01011ce:	83 c4 14             	add    $0x14,%esp
f01011d1:	5b                   	pop    %ebx
f01011d2:	5d                   	pop    %ebp
f01011d3:	c3                   	ret    

f01011d4 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011d4:	55                   	push   %ebp
f01011d5:	89 e5                	mov    %esp,%ebp
f01011d7:	53                   	push   %ebx
f01011d8:	83 ec 24             	sub    $0x24,%esp
f01011db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f01011de:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ec:	89 04 24             	mov    %eax,(%esp)
f01011ef:	e8 67 ff ff ff       	call   f010115b <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f01011f4:	85 c0                	test   %eax,%eax
f01011f6:	74 1c                	je     f0101214 <page_remove+0x40>
f01011f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01011fb:	f6 02 01             	testb  $0x1,(%edx)
f01011fe:	74 14                	je     f0101214 <page_remove+0x40>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f0101200:	89 04 24             	mov    %eax,(%esp)
f0101203:	e8 f7 fd ff ff       	call   f0100fff <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f0101208:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010120b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101211:	0f 01 3b             	invlpg (%ebx)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
}
f0101214:	83 c4 24             	add    $0x24,%esp
f0101217:	5b                   	pop    %ebx
f0101218:	5d                   	pop    %ebp
f0101219:	c3                   	ret    

f010121a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010121a:	55                   	push   %ebp
f010121b:	89 e5                	mov    %esp,%ebp
f010121d:	57                   	push   %edi
f010121e:	56                   	push   %esi
f010121f:	53                   	push   %ebx
f0101220:	83 ec 1c             	sub    $0x1c,%esp
f0101223:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101226:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f0101229:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101230:	00 
f0101231:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101235:	8b 45 08             	mov    0x8(%ebp),%eax
f0101238:	89 04 24             	mov    %eax,(%esp)
f010123b:	e8 e2 fd ff ff       	call   f0101022 <pgdir_walk>
f0101240:	89 c3                	mov    %eax,%ebx
	if (!pte) 	//page table not allocated
f0101242:	85 c0                	test   %eax,%eax
f0101244:	74 36                	je     f010127c <page_insert+0x62>
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f0101246:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f010124b:	f6 00 01             	testb  $0x1,(%eax)
f010124e:	74 0f                	je     f010125f <page_insert+0x45>
		page_remove(pgdir, va);
f0101250:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101254:	8b 45 08             	mov    0x8(%ebp),%eax
f0101257:	89 04 24             	mov    %eax,(%esp)
f010125a:	e8 75 ff ff ff       	call   f01011d4 <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f010125f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101262:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101265:	2b 35 8c ef 17 f0    	sub    0xf017ef8c,%esi
f010126b:	c1 fe 03             	sar    $0x3,%esi
f010126e:	c1 e6 0c             	shl    $0xc,%esi
f0101271:	09 c6                	or     %eax,%esi
f0101273:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101275:	b8 00 00 00 00       	mov    $0x0,%eax
f010127a:	eb 05                	jmp    f0101281 <page_insert+0x67>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f010127c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101281:	83 c4 1c             	add    $0x1c,%esp
f0101284:	5b                   	pop    %ebx
f0101285:	5e                   	pop    %esi
f0101286:	5f                   	pop    %edi
f0101287:	5d                   	pop    %ebp
f0101288:	c3                   	ret    

f0101289 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101289:	55                   	push   %ebp
f010128a:	89 e5                	mov    %esp,%ebp
f010128c:	57                   	push   %edi
f010128d:	56                   	push   %esi
f010128e:	53                   	push   %ebx
f010128f:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101292:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101299:	e8 97 24 00 00       	call   f0103735 <mc146818_read>
f010129e:	89 c3                	mov    %eax,%ebx
f01012a0:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01012a7:	e8 89 24 00 00       	call   f0103735 <mc146818_read>
f01012ac:	c1 e0 08             	shl    $0x8,%eax
f01012af:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012b1:	89 d8                	mov    %ebx,%eax
f01012b3:	c1 e0 0a             	shl    $0xa,%eax
f01012b6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012bc:	85 c0                	test   %eax,%eax
f01012be:	0f 48 c2             	cmovs  %edx,%eax
f01012c1:	c1 f8 0c             	sar    $0xc,%eax
f01012c4:	a3 c4 e2 17 f0       	mov    %eax,0xf017e2c4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012c9:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01012d0:	e8 60 24 00 00       	call   f0103735 <mc146818_read>
f01012d5:	89 c3                	mov    %eax,%ebx
f01012d7:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01012de:	e8 52 24 00 00       	call   f0103735 <mc146818_read>
f01012e3:	c1 e0 08             	shl    $0x8,%eax
f01012e6:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01012e8:	89 d8                	mov    %ebx,%eax
f01012ea:	c1 e0 0a             	shl    $0xa,%eax
f01012ed:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012f3:	85 c0                	test   %eax,%eax
f01012f5:	0f 48 c2             	cmovs  %edx,%eax
f01012f8:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01012fb:	85 c0                	test   %eax,%eax
f01012fd:	74 0e                	je     f010130d <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01012ff:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101305:	89 15 84 ef 17 f0    	mov    %edx,0xf017ef84
f010130b:	eb 0c                	jmp    f0101319 <mem_init+0x90>
	else
		npages = npages_basemem;
f010130d:	8b 15 c4 e2 17 f0    	mov    0xf017e2c4,%edx
f0101313:	89 15 84 ef 17 f0    	mov    %edx,0xf017ef84

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101319:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010131c:	c1 e8 0a             	shr    $0xa,%eax
f010131f:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101323:	a1 c4 e2 17 f0       	mov    0xf017e2c4,%eax
f0101328:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010132b:	c1 e8 0a             	shr    $0xa,%eax
f010132e:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101332:	a1 84 ef 17 f0       	mov    0xf017ef84,%eax
f0101337:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010133a:	c1 e8 0a             	shr    $0xa,%eax
f010133d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101341:	c7 04 24 a8 59 10 f0 	movl   $0xf01059a8,(%esp)
f0101348:	e8 58 24 00 00       	call   f01037a5 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010134d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101352:	e8 b9 f6 ff ff       	call   f0100a10 <boot_alloc>
f0101357:	a3 88 ef 17 f0       	mov    %eax,0xf017ef88
	memset(kern_pgdir, 0, PGSIZE);
f010135c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101363:	00 
f0101364:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010136b:	00 
f010136c:	89 04 24             	mov    %eax,(%esp)
f010136f:	e8 53 37 00 00       	call   f0104ac7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101374:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101379:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010137e:	77 20                	ja     f01013a0 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101380:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101384:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f010138b:	f0 
f010138c:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0101393:	00 
f0101394:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010139b:	e8 86 ed ff ff       	call   f0100126 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01013a0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013a6:	83 ca 05             	or     $0x5,%edx
f01013a9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f01013af:	a1 84 ef 17 f0       	mov    0xf017ef84,%eax
f01013b4:	c1 e0 03             	shl    $0x3,%eax
f01013b7:	e8 54 f6 ff ff       	call   f0100a10 <boot_alloc>
f01013bc:	a3 8c ef 17 f0       	mov    %eax,0xf017ef8c

	cprintf("npages: %d\n", npages);
f01013c1:	a1 84 ef 17 f0       	mov    0xf017ef84,%eax
f01013c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013ca:	c7 04 24 a9 55 10 f0 	movl   $0xf01055a9,(%esp)
f01013d1:	e8 cf 23 00 00       	call   f01037a5 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f01013d6:	a1 c4 e2 17 f0       	mov    0xf017e2c4,%eax
f01013db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013df:	c7 04 24 b5 55 10 f0 	movl   $0xf01055b5,(%esp)
f01013e6:	e8 ba 23 00 00       	call   f01037a5 <cprintf>
	cprintf("pages: %x\n", pages);
f01013eb:	a1 8c ef 17 f0       	mov    0xf017ef8c,%eax
f01013f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013f4:	c7 04 24 c9 55 10 f0 	movl   $0xf01055c9,(%esp)
f01013fb:	e8 a5 23 00 00       	call   f01037a5 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101400:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101405:	e8 06 f6 ff ff       	call   f0100a10 <boot_alloc>
f010140a:	a3 cc e2 17 f0       	mov    %eax,0xf017e2cc
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010140f:	e8 81 fa ff ff       	call   f0100e95 <page_init>

	check_page_free_list(1);
f0101414:	b8 01 00 00 00       	mov    $0x1,%eax
f0101419:	e8 20 f7 ff ff       	call   f0100b3e <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010141e:	83 3d 8c ef 17 f0 00 	cmpl   $0x0,0xf017ef8c
f0101425:	75 1c                	jne    f0101443 <mem_init+0x1ba>
		panic("'pages' is a null pointer!");
f0101427:	c7 44 24 08 d4 55 10 	movl   $0xf01055d4,0x8(%esp)
f010142e:	f0 
f010142f:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f0101436:	00 
f0101437:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010143e:	e8 e3 ec ff ff       	call   f0100126 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101443:	a1 c0 e2 17 f0       	mov    0xf017e2c0,%eax
f0101448:	bb 00 00 00 00       	mov    $0x0,%ebx
f010144d:	eb 05                	jmp    f0101454 <mem_init+0x1cb>
		++nfree;
f010144f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101452:	8b 00                	mov    (%eax),%eax
f0101454:	85 c0                	test   %eax,%eax
f0101456:	75 f7                	jne    f010144f <mem_init+0x1c6>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010145f:	e8 01 fb ff ff       	call   f0100f65 <page_alloc>
f0101464:	89 c7                	mov    %eax,%edi
f0101466:	85 c0                	test   %eax,%eax
f0101468:	75 24                	jne    f010148e <mem_init+0x205>
f010146a:	c7 44 24 0c ef 55 10 	movl   $0xf01055ef,0xc(%esp)
f0101471:	f0 
f0101472:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101479:	f0 
f010147a:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f0101481:	00 
f0101482:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101489:	e8 98 ec ff ff       	call   f0100126 <_panic>
	assert((pp1 = page_alloc(0)));
f010148e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101495:	e8 cb fa ff ff       	call   f0100f65 <page_alloc>
f010149a:	89 c6                	mov    %eax,%esi
f010149c:	85 c0                	test   %eax,%eax
f010149e:	75 24                	jne    f01014c4 <mem_init+0x23b>
f01014a0:	c7 44 24 0c 05 56 10 	movl   $0xf0105605,0xc(%esp)
f01014a7:	f0 
f01014a8:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01014af:	f0 
f01014b0:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f01014b7:	00 
f01014b8:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01014bf:	e8 62 ec ff ff       	call   f0100126 <_panic>
	assert((pp2 = page_alloc(0)));
f01014c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014cb:	e8 95 fa ff ff       	call   f0100f65 <page_alloc>
f01014d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014d3:	85 c0                	test   %eax,%eax
f01014d5:	75 24                	jne    f01014fb <mem_init+0x272>
f01014d7:	c7 44 24 0c 1b 56 10 	movl   $0xf010561b,0xc(%esp)
f01014de:	f0 
f01014df:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01014e6:	f0 
f01014e7:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
f01014ee:	00 
f01014ef:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01014f6:	e8 2b ec ff ff       	call   f0100126 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014fb:	39 f7                	cmp    %esi,%edi
f01014fd:	75 24                	jne    f0101523 <mem_init+0x29a>
f01014ff:	c7 44 24 0c 31 56 10 	movl   $0xf0105631,0xc(%esp)
f0101506:	f0 
f0101507:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010150e:	f0 
f010150f:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
f0101516:	00 
f0101517:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010151e:	e8 03 ec ff ff       	call   f0100126 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101523:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101526:	39 c6                	cmp    %eax,%esi
f0101528:	74 04                	je     f010152e <mem_init+0x2a5>
f010152a:	39 c7                	cmp    %eax,%edi
f010152c:	75 24                	jne    f0101552 <mem_init+0x2c9>
f010152e:	c7 44 24 0c 08 5a 10 	movl   $0xf0105a08,0xc(%esp)
f0101535:	f0 
f0101536:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010153d:	f0 
f010153e:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
f0101545:	00 
f0101546:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010154d:	e8 d4 eb ff ff       	call   f0100126 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101552:	8b 15 8c ef 17 f0    	mov    0xf017ef8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101558:	a1 84 ef 17 f0       	mov    0xf017ef84,%eax
f010155d:	c1 e0 0c             	shl    $0xc,%eax
f0101560:	89 f9                	mov    %edi,%ecx
f0101562:	29 d1                	sub    %edx,%ecx
f0101564:	c1 f9 03             	sar    $0x3,%ecx
f0101567:	c1 e1 0c             	shl    $0xc,%ecx
f010156a:	39 c1                	cmp    %eax,%ecx
f010156c:	72 24                	jb     f0101592 <mem_init+0x309>
f010156e:	c7 44 24 0c 43 56 10 	movl   $0xf0105643,0xc(%esp)
f0101575:	f0 
f0101576:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010157d:	f0 
f010157e:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f0101585:	00 
f0101586:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010158d:	e8 94 eb ff ff       	call   f0100126 <_panic>
f0101592:	89 f1                	mov    %esi,%ecx
f0101594:	29 d1                	sub    %edx,%ecx
f0101596:	c1 f9 03             	sar    $0x3,%ecx
f0101599:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010159c:	39 c8                	cmp    %ecx,%eax
f010159e:	77 24                	ja     f01015c4 <mem_init+0x33b>
f01015a0:	c7 44 24 0c 60 56 10 	movl   $0xf0105660,0xc(%esp)
f01015a7:	f0 
f01015a8:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01015af:	f0 
f01015b0:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f01015b7:	00 
f01015b8:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01015bf:	e8 62 eb ff ff       	call   f0100126 <_panic>
f01015c4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015c7:	29 d1                	sub    %edx,%ecx
f01015c9:	89 ca                	mov    %ecx,%edx
f01015cb:	c1 fa 03             	sar    $0x3,%edx
f01015ce:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01015d1:	39 d0                	cmp    %edx,%eax
f01015d3:	77 24                	ja     f01015f9 <mem_init+0x370>
f01015d5:	c7 44 24 0c 7d 56 10 	movl   $0xf010567d,0xc(%esp)
f01015dc:	f0 
f01015dd:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01015e4:	f0 
f01015e5:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01015ec:	00 
f01015ed:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01015f4:	e8 2d eb ff ff       	call   f0100126 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01015f9:	a1 c0 e2 17 f0       	mov    0xf017e2c0,%eax
f01015fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101601:	c7 05 c0 e2 17 f0 00 	movl   $0x0,0xf017e2c0
f0101608:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010160b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101612:	e8 4e f9 ff ff       	call   f0100f65 <page_alloc>
f0101617:	85 c0                	test   %eax,%eax
f0101619:	74 24                	je     f010163f <mem_init+0x3b6>
f010161b:	c7 44 24 0c 9a 56 10 	movl   $0xf010569a,0xc(%esp)
f0101622:	f0 
f0101623:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010162a:	f0 
f010162b:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0101632:	00 
f0101633:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010163a:	e8 e7 ea ff ff       	call   f0100126 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010163f:	89 3c 24             	mov    %edi,(%esp)
f0101642:	e8 a3 f9 ff ff       	call   f0100fea <page_free>
	page_free(pp1);
f0101647:	89 34 24             	mov    %esi,(%esp)
f010164a:	e8 9b f9 ff ff       	call   f0100fea <page_free>
	page_free(pp2);
f010164f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101652:	89 04 24             	mov    %eax,(%esp)
f0101655:	e8 90 f9 ff ff       	call   f0100fea <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010165a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101661:	e8 ff f8 ff ff       	call   f0100f65 <page_alloc>
f0101666:	89 c6                	mov    %eax,%esi
f0101668:	85 c0                	test   %eax,%eax
f010166a:	75 24                	jne    f0101690 <mem_init+0x407>
f010166c:	c7 44 24 0c ef 55 10 	movl   $0xf01055ef,0xc(%esp)
f0101673:	f0 
f0101674:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010167b:	f0 
f010167c:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
f0101683:	00 
f0101684:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010168b:	e8 96 ea ff ff       	call   f0100126 <_panic>
	assert((pp1 = page_alloc(0)));
f0101690:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101697:	e8 c9 f8 ff ff       	call   f0100f65 <page_alloc>
f010169c:	89 c7                	mov    %eax,%edi
f010169e:	85 c0                	test   %eax,%eax
f01016a0:	75 24                	jne    f01016c6 <mem_init+0x43d>
f01016a2:	c7 44 24 0c 05 56 10 	movl   $0xf0105605,0xc(%esp)
f01016a9:	f0 
f01016aa:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01016b1:	f0 
f01016b2:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f01016b9:	00 
f01016ba:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01016c1:	e8 60 ea ff ff       	call   f0100126 <_panic>
	assert((pp2 = page_alloc(0)));
f01016c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016cd:	e8 93 f8 ff ff       	call   f0100f65 <page_alloc>
f01016d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016d5:	85 c0                	test   %eax,%eax
f01016d7:	75 24                	jne    f01016fd <mem_init+0x474>
f01016d9:	c7 44 24 0c 1b 56 10 	movl   $0xf010561b,0xc(%esp)
f01016e0:	f0 
f01016e1:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01016e8:	f0 
f01016e9:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f01016f0:	00 
f01016f1:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01016f8:	e8 29 ea ff ff       	call   f0100126 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016fd:	39 fe                	cmp    %edi,%esi
f01016ff:	75 24                	jne    f0101725 <mem_init+0x49c>
f0101701:	c7 44 24 0c 31 56 10 	movl   $0xf0105631,0xc(%esp)
f0101708:	f0 
f0101709:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101710:	f0 
f0101711:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
f0101718:	00 
f0101719:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101720:	e8 01 ea ff ff       	call   f0100126 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101725:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101728:	39 c7                	cmp    %eax,%edi
f010172a:	74 04                	je     f0101730 <mem_init+0x4a7>
f010172c:	39 c6                	cmp    %eax,%esi
f010172e:	75 24                	jne    f0101754 <mem_init+0x4cb>
f0101730:	c7 44 24 0c 08 5a 10 	movl   $0xf0105a08,0xc(%esp)
f0101737:	f0 
f0101738:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010173f:	f0 
f0101740:	c7 44 24 04 c5 02 00 	movl   $0x2c5,0x4(%esp)
f0101747:	00 
f0101748:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010174f:	e8 d2 e9 ff ff       	call   f0100126 <_panic>
	assert(!page_alloc(0));
f0101754:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010175b:	e8 05 f8 ff ff       	call   f0100f65 <page_alloc>
f0101760:	85 c0                	test   %eax,%eax
f0101762:	74 24                	je     f0101788 <mem_init+0x4ff>
f0101764:	c7 44 24 0c 9a 56 10 	movl   $0xf010569a,0xc(%esp)
f010176b:	f0 
f010176c:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101773:	f0 
f0101774:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010177b:	00 
f010177c:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101783:	e8 9e e9 ff ff       	call   f0100126 <_panic>
f0101788:	89 f0                	mov    %esi,%eax
f010178a:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f0101790:	c1 f8 03             	sar    $0x3,%eax
f0101793:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101796:	89 c2                	mov    %eax,%edx
f0101798:	c1 ea 0c             	shr    $0xc,%edx
f010179b:	3b 15 84 ef 17 f0    	cmp    0xf017ef84,%edx
f01017a1:	72 20                	jb     f01017c3 <mem_init+0x53a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017a7:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f01017ae:	f0 
f01017af:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01017b6:	00 
f01017b7:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f01017be:	e8 63 e9 ff ff       	call   f0100126 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01017c3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017ca:	00 
f01017cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01017d2:	00 
	return (void *)(pa + KERNBASE);
f01017d3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017d8:	89 04 24             	mov    %eax,(%esp)
f01017db:	e8 e7 32 00 00       	call   f0104ac7 <memset>
	page_free(pp0);
f01017e0:	89 34 24             	mov    %esi,(%esp)
f01017e3:	e8 02 f8 ff ff       	call   f0100fea <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01017ef:	e8 71 f7 ff ff       	call   f0100f65 <page_alloc>
f01017f4:	85 c0                	test   %eax,%eax
f01017f6:	75 24                	jne    f010181c <mem_init+0x593>
f01017f8:	c7 44 24 0c a9 56 10 	movl   $0xf01056a9,0xc(%esp)
f01017ff:	f0 
f0101800:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101807:	f0 
f0101808:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f010180f:	00 
f0101810:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101817:	e8 0a e9 ff ff       	call   f0100126 <_panic>
	assert(pp && pp0 == pp);
f010181c:	39 c6                	cmp    %eax,%esi
f010181e:	74 24                	je     f0101844 <mem_init+0x5bb>
f0101820:	c7 44 24 0c c7 56 10 	movl   $0xf01056c7,0xc(%esp)
f0101827:	f0 
f0101828:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010182f:	f0 
f0101830:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101837:	00 
f0101838:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010183f:	e8 e2 e8 ff ff       	call   f0100126 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101844:	89 f0                	mov    %esi,%eax
f0101846:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f010184c:	c1 f8 03             	sar    $0x3,%eax
f010184f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101852:	89 c2                	mov    %eax,%edx
f0101854:	c1 ea 0c             	shr    $0xc,%edx
f0101857:	3b 15 84 ef 17 f0    	cmp    0xf017ef84,%edx
f010185d:	72 20                	jb     f010187f <mem_init+0x5f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010185f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101863:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f010186a:	f0 
f010186b:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101872:	00 
f0101873:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f010187a:	e8 a7 e8 ff ff       	call   f0100126 <_panic>
f010187f:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101885:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010188b:	80 38 00             	cmpb   $0x0,(%eax)
f010188e:	74 24                	je     f01018b4 <mem_init+0x62b>
f0101890:	c7 44 24 0c d7 56 10 	movl   $0xf01056d7,0xc(%esp)
f0101897:	f0 
f0101898:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010189f:	f0 
f01018a0:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f01018a7:	00 
f01018a8:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01018af:	e8 72 e8 ff ff       	call   f0100126 <_panic>
f01018b4:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018b7:	39 d0                	cmp    %edx,%eax
f01018b9:	75 d0                	jne    f010188b <mem_init+0x602>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018be:	a3 c0 e2 17 f0       	mov    %eax,0xf017e2c0

	// free the pages we took
	page_free(pp0);
f01018c3:	89 34 24             	mov    %esi,(%esp)
f01018c6:	e8 1f f7 ff ff       	call   f0100fea <page_free>
	page_free(pp1);
f01018cb:	89 3c 24             	mov    %edi,(%esp)
f01018ce:	e8 17 f7 ff ff       	call   f0100fea <page_free>
	page_free(pp2);
f01018d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018d6:	89 04 24             	mov    %eax,(%esp)
f01018d9:	e8 0c f7 ff ff       	call   f0100fea <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018de:	a1 c0 e2 17 f0       	mov    0xf017e2c0,%eax
f01018e3:	eb 05                	jmp    f01018ea <mem_init+0x661>
		--nfree;
f01018e5:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018e8:	8b 00                	mov    (%eax),%eax
f01018ea:	85 c0                	test   %eax,%eax
f01018ec:	75 f7                	jne    f01018e5 <mem_init+0x65c>
		--nfree;
	assert(nfree == 0);
f01018ee:	85 db                	test   %ebx,%ebx
f01018f0:	74 24                	je     f0101916 <mem_init+0x68d>
f01018f2:	c7 44 24 0c e1 56 10 	movl   $0xf01056e1,0xc(%esp)
f01018f9:	f0 
f01018fa:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101901:	f0 
f0101902:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0101909:	00 
f010190a:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101911:	e8 10 e8 ff ff       	call   f0100126 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101916:	c7 04 24 28 5a 10 f0 	movl   $0xf0105a28,(%esp)
f010191d:	e8 83 1e 00 00       	call   f01037a5 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101922:	c7 04 24 ec 56 10 f0 	movl   $0xf01056ec,(%esp)
f0101929:	e8 77 1e 00 00       	call   f01037a5 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010192e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101935:	e8 2b f6 ff ff       	call   f0100f65 <page_alloc>
f010193a:	89 c6                	mov    %eax,%esi
f010193c:	85 c0                	test   %eax,%eax
f010193e:	75 24                	jne    f0101964 <mem_init+0x6db>
f0101940:	c7 44 24 0c ef 55 10 	movl   $0xf01055ef,0xc(%esp)
f0101947:	f0 
f0101948:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010194f:	f0 
f0101950:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101957:	00 
f0101958:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010195f:	e8 c2 e7 ff ff       	call   f0100126 <_panic>
	assert((pp1 = page_alloc(0)));
f0101964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010196b:	e8 f5 f5 ff ff       	call   f0100f65 <page_alloc>
f0101970:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101973:	85 c0                	test   %eax,%eax
f0101975:	75 24                	jne    f010199b <mem_init+0x712>
f0101977:	c7 44 24 0c 05 56 10 	movl   $0xf0105605,0xc(%esp)
f010197e:	f0 
f010197f:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101986:	f0 
f0101987:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f010198e:	00 
f010198f:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101996:	e8 8b e7 ff ff       	call   f0100126 <_panic>
	assert((pp2 = page_alloc(0)));
f010199b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019a2:	e8 be f5 ff ff       	call   f0100f65 <page_alloc>
f01019a7:	89 c3                	mov    %eax,%ebx
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	75 24                	jne    f01019d1 <mem_init+0x748>
f01019ad:	c7 44 24 0c 1b 56 10 	movl   $0xf010561b,0xc(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01019bc:	f0 
f01019bd:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01019c4:	00 
f01019c5:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01019cc:	e8 55 e7 ff ff       	call   f0100126 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019d1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01019d4:	75 24                	jne    f01019fa <mem_init+0x771>
f01019d6:	c7 44 24 0c 31 56 10 	movl   $0xf0105631,0xc(%esp)
f01019dd:	f0 
f01019de:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01019e5:	f0 
f01019e6:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f01019ed:	00 
f01019ee:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01019f5:	e8 2c e7 ff ff       	call   f0100126 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019fa:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01019fd:	74 04                	je     f0101a03 <mem_init+0x77a>
f01019ff:	39 c6                	cmp    %eax,%esi
f0101a01:	75 24                	jne    f0101a27 <mem_init+0x79e>
f0101a03:	c7 44 24 0c 08 5a 10 	movl   $0xf0105a08,0xc(%esp)
f0101a0a:	f0 
f0101a0b:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101a12:	f0 
f0101a13:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101a1a:	00 
f0101a1b:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101a22:	e8 ff e6 ff ff       	call   f0100126 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a27:	a1 c0 e2 17 f0       	mov    0xf017e2c0,%eax
f0101a2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a2f:	c7 05 c0 e2 17 f0 00 	movl   $0x0,0xf017e2c0
f0101a36:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a40:	e8 20 f5 ff ff       	call   f0100f65 <page_alloc>
f0101a45:	85 c0                	test   %eax,%eax
f0101a47:	74 24                	je     f0101a6d <mem_init+0x7e4>
f0101a49:	c7 44 24 0c 9a 56 10 	movl   $0xf010569a,0xc(%esp)
f0101a50:	f0 
f0101a51:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101a58:	f0 
f0101a59:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101a60:	00 
f0101a61:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101a68:	e8 b9 e6 ff ff       	call   f0100126 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a70:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101a7b:	00 
f0101a7c:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101a81:	89 04 24             	mov    %eax,(%esp)
f0101a84:	e8 d2 f6 ff ff       	call   f010115b <page_lookup>
f0101a89:	85 c0                	test   %eax,%eax
f0101a8b:	74 24                	je     f0101ab1 <mem_init+0x828>
f0101a8d:	c7 44 24 0c 48 5a 10 	movl   $0xf0105a48,0xc(%esp)
f0101a94:	f0 
f0101a95:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101a9c:	f0 
f0101a9d:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0101aa4:	00 
f0101aa5:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101aac:	e8 75 e6 ff ff       	call   f0100126 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ab1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ab8:	00 
f0101ab9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ac0:	00 
f0101ac1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ac8:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101acd:	89 04 24             	mov    %eax,(%esp)
f0101ad0:	e8 45 f7 ff ff       	call   f010121a <page_insert>
f0101ad5:	85 c0                	test   %eax,%eax
f0101ad7:	78 24                	js     f0101afd <mem_init+0x874>
f0101ad9:	c7 44 24 0c 80 5a 10 	movl   $0xf0105a80,0xc(%esp)
f0101ae0:	f0 
f0101ae1:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101ae8:	f0 
f0101ae9:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101af0:	00 
f0101af1:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101af8:	e8 29 e6 ff ff       	call   f0100126 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101afd:	89 34 24             	mov    %esi,(%esp)
f0101b00:	e8 e5 f4 ff ff       	call   f0100fea <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b05:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b0c:	00 
f0101b0d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b14:	00 
f0101b15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b1c:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101b21:	89 04 24             	mov    %eax,(%esp)
f0101b24:	e8 f1 f6 ff ff       	call   f010121a <page_insert>
f0101b29:	85 c0                	test   %eax,%eax
f0101b2b:	74 24                	je     f0101b51 <mem_init+0x8c8>
f0101b2d:	c7 44 24 0c b0 5a 10 	movl   $0xf0105ab0,0xc(%esp)
f0101b34:	f0 
f0101b35:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101b3c:	f0 
f0101b3d:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101b44:	00 
f0101b45:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101b4c:	e8 d5 e5 ff ff       	call   f0100126 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b51:	8b 3d 88 ef 17 f0    	mov    0xf017ef88,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b57:	a1 8c ef 17 f0       	mov    0xf017ef8c,%eax
f0101b5c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b5f:	8b 17                	mov    (%edi),%edx
f0101b61:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b67:	89 f1                	mov    %esi,%ecx
f0101b69:	29 c1                	sub    %eax,%ecx
f0101b6b:	89 c8                	mov    %ecx,%eax
f0101b6d:	c1 f8 03             	sar    $0x3,%eax
f0101b70:	c1 e0 0c             	shl    $0xc,%eax
f0101b73:	39 c2                	cmp    %eax,%edx
f0101b75:	74 24                	je     f0101b9b <mem_init+0x912>
f0101b77:	c7 44 24 0c e0 5a 10 	movl   $0xf0105ae0,0xc(%esp)
f0101b7e:	f0 
f0101b7f:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101b86:	f0 
f0101b87:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101b8e:	00 
f0101b8f:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101b96:	e8 8b e5 ff ff       	call   f0100126 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ba0:	89 f8                	mov    %edi,%eax
f0101ba2:	e8 28 ef ff ff       	call   f0100acf <check_va2pa>
f0101ba7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101baa:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101bad:	c1 fa 03             	sar    $0x3,%edx
f0101bb0:	c1 e2 0c             	shl    $0xc,%edx
f0101bb3:	39 d0                	cmp    %edx,%eax
f0101bb5:	74 24                	je     f0101bdb <mem_init+0x952>
f0101bb7:	c7 44 24 0c 08 5b 10 	movl   $0xf0105b08,0xc(%esp)
f0101bbe:	f0 
f0101bbf:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101bc6:	f0 
f0101bc7:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101bce:	00 
f0101bcf:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101bd6:	e8 4b e5 ff ff       	call   f0100126 <_panic>
	assert(pp1->pp_ref == 1);
f0101bdb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bde:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101be3:	74 24                	je     f0101c09 <mem_init+0x980>
f0101be5:	c7 44 24 0c fc 56 10 	movl   $0xf01056fc,0xc(%esp)
f0101bec:	f0 
f0101bed:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101bf4:	f0 
f0101bf5:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101bfc:	00 
f0101bfd:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101c04:	e8 1d e5 ff ff       	call   f0100126 <_panic>
	assert(pp0->pp_ref == 1);
f0101c09:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c0e:	74 24                	je     f0101c34 <mem_init+0x9ab>
f0101c10:	c7 44 24 0c 0d 57 10 	movl   $0xf010570d,0xc(%esp)
f0101c17:	f0 
f0101c18:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101c1f:	f0 
f0101c20:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101c27:	00 
f0101c28:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101c2f:	e8 f2 e4 ff ff       	call   f0100126 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c34:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c3b:	00 
f0101c3c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c43:	00 
f0101c44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c48:	89 3c 24             	mov    %edi,(%esp)
f0101c4b:	e8 ca f5 ff ff       	call   f010121a <page_insert>
f0101c50:	85 c0                	test   %eax,%eax
f0101c52:	74 24                	je     f0101c78 <mem_init+0x9ef>
f0101c54:	c7 44 24 0c 38 5b 10 	movl   $0xf0105b38,0xc(%esp)
f0101c5b:	f0 
f0101c5c:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101c63:	f0 
f0101c64:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101c6b:	00 
f0101c6c:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101c73:	e8 ae e4 ff ff       	call   f0100126 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c78:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c7d:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101c82:	e8 48 ee ff ff       	call   f0100acf <check_va2pa>
f0101c87:	89 da                	mov    %ebx,%edx
f0101c89:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
f0101c8f:	c1 fa 03             	sar    $0x3,%edx
f0101c92:	c1 e2 0c             	shl    $0xc,%edx
f0101c95:	39 d0                	cmp    %edx,%eax
f0101c97:	74 24                	je     f0101cbd <mem_init+0xa34>
f0101c99:	c7 44 24 0c 74 5b 10 	movl   $0xf0105b74,0xc(%esp)
f0101ca0:	f0 
f0101ca1:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101ca8:	f0 
f0101ca9:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101cb0:	00 
f0101cb1:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101cb8:	e8 69 e4 ff ff       	call   f0100126 <_panic>
	assert(pp2->pp_ref == 1);
f0101cbd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cc2:	74 24                	je     f0101ce8 <mem_init+0xa5f>
f0101cc4:	c7 44 24 0c 1e 57 10 	movl   $0xf010571e,0xc(%esp)
f0101ccb:	f0 
f0101ccc:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101cd3:	f0 
f0101cd4:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101cdb:	00 
f0101cdc:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101ce3:	e8 3e e4 ff ff       	call   f0100126 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ce8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cef:	e8 71 f2 ff ff       	call   f0100f65 <page_alloc>
f0101cf4:	85 c0                	test   %eax,%eax
f0101cf6:	74 24                	je     f0101d1c <mem_init+0xa93>
f0101cf8:	c7 44 24 0c 9a 56 10 	movl   $0xf010569a,0xc(%esp)
f0101cff:	f0 
f0101d00:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101d07:	f0 
f0101d08:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101d0f:	00 
f0101d10:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101d17:	e8 0a e4 ff ff       	call   f0100126 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d1c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d23:	00 
f0101d24:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d2b:	00 
f0101d2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d30:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101d35:	89 04 24             	mov    %eax,(%esp)
f0101d38:	e8 dd f4 ff ff       	call   f010121a <page_insert>
f0101d3d:	85 c0                	test   %eax,%eax
f0101d3f:	74 24                	je     f0101d65 <mem_init+0xadc>
f0101d41:	c7 44 24 0c 38 5b 10 	movl   $0xf0105b38,0xc(%esp)
f0101d48:	f0 
f0101d49:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101d58:	00 
f0101d59:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101d60:	e8 c1 e3 ff ff       	call   f0100126 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d65:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d6a:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101d6f:	e8 5b ed ff ff       	call   f0100acf <check_va2pa>
f0101d74:	89 da                	mov    %ebx,%edx
f0101d76:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
f0101d7c:	c1 fa 03             	sar    $0x3,%edx
f0101d7f:	c1 e2 0c             	shl    $0xc,%edx
f0101d82:	39 d0                	cmp    %edx,%eax
f0101d84:	74 24                	je     f0101daa <mem_init+0xb21>
f0101d86:	c7 44 24 0c 74 5b 10 	movl   $0xf0105b74,0xc(%esp)
f0101d8d:	f0 
f0101d8e:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101d95:	f0 
f0101d96:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101d9d:	00 
f0101d9e:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101da5:	e8 7c e3 ff ff       	call   f0100126 <_panic>
	assert(pp2->pp_ref == 1);
f0101daa:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101daf:	74 24                	je     f0101dd5 <mem_init+0xb4c>
f0101db1:	c7 44 24 0c 1e 57 10 	movl   $0xf010571e,0xc(%esp)
f0101db8:	f0 
f0101db9:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101dc0:	f0 
f0101dc1:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101dc8:	00 
f0101dc9:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101dd0:	e8 51 e3 ff ff       	call   f0100126 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101dd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ddc:	e8 84 f1 ff ff       	call   f0100f65 <page_alloc>
f0101de1:	85 c0                	test   %eax,%eax
f0101de3:	74 24                	je     f0101e09 <mem_init+0xb80>
f0101de5:	c7 44 24 0c 9a 56 10 	movl   $0xf010569a,0xc(%esp)
f0101dec:	f0 
f0101ded:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101df4:	f0 
f0101df5:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101dfc:	00 
f0101dfd:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101e04:	e8 1d e3 ff ff       	call   f0100126 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e09:	8b 15 88 ef 17 f0    	mov    0xf017ef88,%edx
f0101e0f:	8b 02                	mov    (%edx),%eax
f0101e11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e16:	89 c1                	mov    %eax,%ecx
f0101e18:	c1 e9 0c             	shr    $0xc,%ecx
f0101e1b:	3b 0d 84 ef 17 f0    	cmp    0xf017ef84,%ecx
f0101e21:	72 20                	jb     f0101e43 <mem_init+0xbba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e23:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e27:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0101e2e:	f0 
f0101e2f:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101e36:	00 
f0101e37:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101e3e:	e8 e3 e2 ff ff       	call   f0100126 <_panic>
	return (void *)(pa + KERNBASE);
f0101e43:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e52:	00 
f0101e53:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e5a:	00 
f0101e5b:	89 14 24             	mov    %edx,(%esp)
f0101e5e:	e8 bf f1 ff ff       	call   f0101022 <pgdir_walk>
f0101e63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101e66:	8d 57 04             	lea    0x4(%edi),%edx
f0101e69:	39 d0                	cmp    %edx,%eax
f0101e6b:	74 24                	je     f0101e91 <mem_init+0xc08>
f0101e6d:	c7 44 24 0c a4 5b 10 	movl   $0xf0105ba4,0xc(%esp)
f0101e74:	f0 
f0101e75:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101e7c:	f0 
f0101e7d:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101e84:	00 
f0101e85:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101e8c:	e8 95 e2 ff ff       	call   f0100126 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101e98:	00 
f0101e99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ea0:	00 
f0101ea1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ea5:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101eaa:	89 04 24             	mov    %eax,(%esp)
f0101ead:	e8 68 f3 ff ff       	call   f010121a <page_insert>
f0101eb2:	85 c0                	test   %eax,%eax
f0101eb4:	74 24                	je     f0101eda <mem_init+0xc51>
f0101eb6:	c7 44 24 0c e4 5b 10 	movl   $0xf0105be4,0xc(%esp)
f0101ebd:	f0 
f0101ebe:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101ec5:	f0 
f0101ec6:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101ecd:	00 
f0101ece:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101ed5:	e8 4c e2 ff ff       	call   f0100126 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eda:	8b 3d 88 ef 17 f0    	mov    0xf017ef88,%edi
f0101ee0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee5:	89 f8                	mov    %edi,%eax
f0101ee7:	e8 e3 eb ff ff       	call   f0100acf <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101eec:	89 da                	mov    %ebx,%edx
f0101eee:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
f0101ef4:	c1 fa 03             	sar    $0x3,%edx
f0101ef7:	c1 e2 0c             	shl    $0xc,%edx
f0101efa:	39 d0                	cmp    %edx,%eax
f0101efc:	74 24                	je     f0101f22 <mem_init+0xc99>
f0101efe:	c7 44 24 0c 74 5b 10 	movl   $0xf0105b74,0xc(%esp)
f0101f05:	f0 
f0101f06:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101f0d:	f0 
f0101f0e:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101f15:	00 
f0101f16:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101f1d:	e8 04 e2 ff ff       	call   f0100126 <_panic>
	assert(pp2->pp_ref == 1);
f0101f22:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f27:	74 24                	je     f0101f4d <mem_init+0xcc4>
f0101f29:	c7 44 24 0c 1e 57 10 	movl   $0xf010571e,0xc(%esp)
f0101f30:	f0 
f0101f31:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101f38:	f0 
f0101f39:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101f40:	00 
f0101f41:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101f48:	e8 d9 e1 ff ff       	call   f0100126 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f54:	00 
f0101f55:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f5c:	00 
f0101f5d:	89 3c 24             	mov    %edi,(%esp)
f0101f60:	e8 bd f0 ff ff       	call   f0101022 <pgdir_walk>
f0101f65:	f6 00 04             	testb  $0x4,(%eax)
f0101f68:	75 24                	jne    f0101f8e <mem_init+0xd05>
f0101f6a:	c7 44 24 0c 24 5c 10 	movl   $0xf0105c24,0xc(%esp)
f0101f71:	f0 
f0101f72:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101f79:	f0 
f0101f7a:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0101f81:	00 
f0101f82:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101f89:	e8 98 e1 ff ff       	call   f0100126 <_panic>
	cprintf("pp2 %x\n", pp2);
f0101f8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f92:	c7 04 24 2f 57 10 f0 	movl   $0xf010572f,(%esp)
f0101f99:	e8 07 18 00 00       	call   f01037a5 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0101f9e:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fa7:	c7 04 24 37 57 10 f0 	movl   $0xf0105737,(%esp)
f0101fae:	e8 f2 17 00 00       	call   f01037a5 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101fb3:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101fb8:	8b 00                	mov    (%eax),%eax
f0101fba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fbe:	c7 04 24 46 57 10 f0 	movl   $0xf0105746,(%esp)
f0101fc5:	e8 db 17 00 00       	call   f01037a5 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0101fca:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0101fcf:	f6 00 04             	testb  $0x4,(%eax)
f0101fd2:	75 24                	jne    f0101ff8 <mem_init+0xd6f>
f0101fd4:	c7 44 24 0c 5b 57 10 	movl   $0xf010575b,0xc(%esp)
f0101fdb:	f0 
f0101fdc:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0101fe3:	f0 
f0101fe4:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101feb:	00 
f0101fec:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0101ff3:	e8 2e e1 ff ff       	call   f0100126 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ff8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fff:	00 
f0102000:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102007:	00 
f0102008:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010200c:	89 04 24             	mov    %eax,(%esp)
f010200f:	e8 06 f2 ff ff       	call   f010121a <page_insert>
f0102014:	85 c0                	test   %eax,%eax
f0102016:	74 24                	je     f010203c <mem_init+0xdb3>
f0102018:	c7 44 24 0c 38 5b 10 	movl   $0xf0105b38,0xc(%esp)
f010201f:	f0 
f0102020:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102027:	f0 
f0102028:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f010202f:	00 
f0102030:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102037:	e8 ea e0 ff ff       	call   f0100126 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010203c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102043:	00 
f0102044:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010204b:	00 
f010204c:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102051:	89 04 24             	mov    %eax,(%esp)
f0102054:	e8 c9 ef ff ff       	call   f0101022 <pgdir_walk>
f0102059:	f6 00 02             	testb  $0x2,(%eax)
f010205c:	75 24                	jne    f0102082 <mem_init+0xdf9>
f010205e:	c7 44 24 0c 58 5c 10 	movl   $0xf0105c58,0xc(%esp)
f0102065:	f0 
f0102066:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010206d:	f0 
f010206e:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0102075:	00 
f0102076:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010207d:	e8 a4 e0 ff ff       	call   f0100126 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102082:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102089:	00 
f010208a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102091:	00 
f0102092:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102097:	89 04 24             	mov    %eax,(%esp)
f010209a:	e8 83 ef ff ff       	call   f0101022 <pgdir_walk>
f010209f:	f6 00 04             	testb  $0x4,(%eax)
f01020a2:	74 24                	je     f01020c8 <mem_init+0xe3f>
f01020a4:	c7 44 24 0c 8c 5c 10 	movl   $0xf0105c8c,0xc(%esp)
f01020ab:	f0 
f01020ac:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01020b3:	f0 
f01020b4:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01020bb:	00 
f01020bc:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01020c3:	e8 5e e0 ff ff       	call   f0100126 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020c8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020cf:	00 
f01020d0:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01020d7:	00 
f01020d8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020dc:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f01020e1:	89 04 24             	mov    %eax,(%esp)
f01020e4:	e8 31 f1 ff ff       	call   f010121a <page_insert>
f01020e9:	85 c0                	test   %eax,%eax
f01020eb:	78 24                	js     f0102111 <mem_init+0xe88>
f01020ed:	c7 44 24 0c c4 5c 10 	movl   $0xf0105cc4,0xc(%esp)
f01020f4:	f0 
f01020f5:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01020fc:	f0 
f01020fd:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0102104:	00 
f0102105:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010210c:	e8 15 e0 ff ff       	call   f0100126 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102111:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102118:	00 
f0102119:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102120:	00 
f0102121:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102124:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102128:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f010212d:	89 04 24             	mov    %eax,(%esp)
f0102130:	e8 e5 f0 ff ff       	call   f010121a <page_insert>
f0102135:	85 c0                	test   %eax,%eax
f0102137:	74 24                	je     f010215d <mem_init+0xed4>
f0102139:	c7 44 24 0c fc 5c 10 	movl   $0xf0105cfc,0xc(%esp)
f0102140:	f0 
f0102141:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102148:	f0 
f0102149:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102150:	00 
f0102151:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102158:	e8 c9 df ff ff       	call   f0100126 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010215d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102164:	00 
f0102165:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010216c:	00 
f010216d:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102172:	89 04 24             	mov    %eax,(%esp)
f0102175:	e8 a8 ee ff ff       	call   f0101022 <pgdir_walk>
f010217a:	f6 00 04             	testb  $0x4,(%eax)
f010217d:	74 24                	je     f01021a3 <mem_init+0xf1a>
f010217f:	c7 44 24 0c 8c 5c 10 	movl   $0xf0105c8c,0xc(%esp)
f0102186:	f0 
f0102187:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010218e:	f0 
f010218f:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0102196:	00 
f0102197:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010219e:	e8 83 df ff ff       	call   f0100126 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021a3:	8b 3d 88 ef 17 f0    	mov    0xf017ef88,%edi
f01021a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01021ae:	89 f8                	mov    %edi,%eax
f01021b0:	e8 1a e9 ff ff       	call   f0100acf <check_va2pa>
f01021b5:	89 c1                	mov    %eax,%ecx
f01021b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bd:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f01021c3:	c1 f8 03             	sar    $0x3,%eax
f01021c6:	c1 e0 0c             	shl    $0xc,%eax
f01021c9:	39 c1                	cmp    %eax,%ecx
f01021cb:	74 24                	je     f01021f1 <mem_init+0xf68>
f01021cd:	c7 44 24 0c 38 5d 10 	movl   $0xf0105d38,0xc(%esp)
f01021d4:	f0 
f01021d5:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01021dc:	f0 
f01021dd:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f01021e4:	00 
f01021e5:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01021ec:	e8 35 df ff ff       	call   f0100126 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021f1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021f6:	89 f8                	mov    %edi,%eax
f01021f8:	e8 d2 e8 ff ff       	call   f0100acf <check_va2pa>
f01021fd:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102200:	74 24                	je     f0102226 <mem_init+0xf9d>
f0102202:	c7 44 24 0c 64 5d 10 	movl   $0xf0105d64,0xc(%esp)
f0102209:	f0 
f010220a:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102211:	f0 
f0102212:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0102219:	00 
f010221a:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102221:	e8 00 df ff ff       	call   f0100126 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102226:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102229:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f010222e:	74 24                	je     f0102254 <mem_init+0xfcb>
f0102230:	c7 44 24 0c 71 57 10 	movl   $0xf0105771,0xc(%esp)
f0102237:	f0 
f0102238:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010223f:	f0 
f0102240:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0102247:	00 
f0102248:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010224f:	e8 d2 de ff ff       	call   f0100126 <_panic>
	assert(pp2->pp_ref == 0);
f0102254:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102259:	74 24                	je     f010227f <mem_init+0xff6>
f010225b:	c7 44 24 0c 82 57 10 	movl   $0xf0105782,0xc(%esp)
f0102262:	f0 
f0102263:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010226a:	f0 
f010226b:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102272:	00 
f0102273:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010227a:	e8 a7 de ff ff       	call   f0100126 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010227f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102286:	e8 da ec ff ff       	call   f0100f65 <page_alloc>
f010228b:	85 c0                	test   %eax,%eax
f010228d:	74 04                	je     f0102293 <mem_init+0x100a>
f010228f:	39 c3                	cmp    %eax,%ebx
f0102291:	74 24                	je     f01022b7 <mem_init+0x102e>
f0102293:	c7 44 24 0c 94 5d 10 	movl   $0xf0105d94,0xc(%esp)
f010229a:	f0 
f010229b:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01022a2:	f0 
f01022a3:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f01022aa:	00 
f01022ab:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01022b2:	e8 6f de ff ff       	call   f0100126 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01022b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022be:	00 
f01022bf:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f01022c4:	89 04 24             	mov    %eax,(%esp)
f01022c7:	e8 08 ef ff ff       	call   f01011d4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022cc:	8b 3d 88 ef 17 f0    	mov    0xf017ef88,%edi
f01022d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01022d7:	89 f8                	mov    %edi,%eax
f01022d9:	e8 f1 e7 ff ff       	call   f0100acf <check_va2pa>
f01022de:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022e1:	74 24                	je     f0102307 <mem_init+0x107e>
f01022e3:	c7 44 24 0c b8 5d 10 	movl   $0xf0105db8,0xc(%esp)
f01022ea:	f0 
f01022eb:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01022fa:	00 
f01022fb:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102302:	e8 1f de ff ff       	call   f0100126 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102307:	ba 00 10 00 00       	mov    $0x1000,%edx
f010230c:	89 f8                	mov    %edi,%eax
f010230e:	e8 bc e7 ff ff       	call   f0100acf <check_va2pa>
f0102313:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102316:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
f010231c:	c1 fa 03             	sar    $0x3,%edx
f010231f:	c1 e2 0c             	shl    $0xc,%edx
f0102322:	39 d0                	cmp    %edx,%eax
f0102324:	74 24                	je     f010234a <mem_init+0x10c1>
f0102326:	c7 44 24 0c 64 5d 10 	movl   $0xf0105d64,0xc(%esp)
f010232d:	f0 
f010232e:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102335:	f0 
f0102336:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f010233d:	00 
f010233e:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102345:	e8 dc dd ff ff       	call   f0100126 <_panic>
	assert(pp1->pp_ref == 1);
f010234a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010234d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102352:	74 24                	je     f0102378 <mem_init+0x10ef>
f0102354:	c7 44 24 0c fc 56 10 	movl   $0xf01056fc,0xc(%esp)
f010235b:	f0 
f010235c:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102363:	f0 
f0102364:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f010236b:	00 
f010236c:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102373:	e8 ae dd ff ff       	call   f0100126 <_panic>
	assert(pp2->pp_ref == 0);
f0102378:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010237d:	74 24                	je     f01023a3 <mem_init+0x111a>
f010237f:	c7 44 24 0c 82 57 10 	movl   $0xf0105782,0xc(%esp)
f0102386:	f0 
f0102387:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010238e:	f0 
f010238f:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102396:	00 
f0102397:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010239e:	e8 83 dd ff ff       	call   f0100126 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023a3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023aa:	00 
f01023ab:	89 3c 24             	mov    %edi,(%esp)
f01023ae:	e8 21 ee ff ff       	call   f01011d4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023b3:	8b 3d 88 ef 17 f0    	mov    0xf017ef88,%edi
f01023b9:	ba 00 00 00 00       	mov    $0x0,%edx
f01023be:	89 f8                	mov    %edi,%eax
f01023c0:	e8 0a e7 ff ff       	call   f0100acf <check_va2pa>
f01023c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023c8:	74 24                	je     f01023ee <mem_init+0x1165>
f01023ca:	c7 44 24 0c b8 5d 10 	movl   $0xf0105db8,0xc(%esp)
f01023d1:	f0 
f01023d2:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01023d9:	f0 
f01023da:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f01023e1:	00 
f01023e2:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01023e9:	e8 38 dd ff ff       	call   f0100126 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01023ee:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023f3:	89 f8                	mov    %edi,%eax
f01023f5:	e8 d5 e6 ff ff       	call   f0100acf <check_va2pa>
f01023fa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023fd:	74 24                	je     f0102423 <mem_init+0x119a>
f01023ff:	c7 44 24 0c dc 5d 10 	movl   $0xf0105ddc,0xc(%esp)
f0102406:	f0 
f0102407:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010240e:	f0 
f010240f:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102416:	00 
f0102417:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010241e:	e8 03 dd ff ff       	call   f0100126 <_panic>
	assert(pp1->pp_ref == 0);
f0102423:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102426:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010242b:	74 24                	je     f0102451 <mem_init+0x11c8>
f010242d:	c7 44 24 0c 93 57 10 	movl   $0xf0105793,0xc(%esp)
f0102434:	f0 
f0102435:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010243c:	f0 
f010243d:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102444:	00 
f0102445:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010244c:	e8 d5 dc ff ff       	call   f0100126 <_panic>
	assert(pp2->pp_ref == 0);
f0102451:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102456:	74 24                	je     f010247c <mem_init+0x11f3>
f0102458:	c7 44 24 0c 82 57 10 	movl   $0xf0105782,0xc(%esp)
f010245f:	f0 
f0102460:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102467:	f0 
f0102468:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f010246f:	00 
f0102470:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102477:	e8 aa dc ff ff       	call   f0100126 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010247c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102483:	e8 dd ea ff ff       	call   f0100f65 <page_alloc>
f0102488:	85 c0                	test   %eax,%eax
f010248a:	74 05                	je     f0102491 <mem_init+0x1208>
f010248c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010248f:	74 24                	je     f01024b5 <mem_init+0x122c>
f0102491:	c7 44 24 0c 04 5e 10 	movl   $0xf0105e04,0xc(%esp)
f0102498:	f0 
f0102499:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01024a0:	f0 
f01024a1:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f01024a8:	00 
f01024a9:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01024b0:	e8 71 dc ff ff       	call   f0100126 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01024b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024bc:	e8 a4 ea ff ff       	call   f0100f65 <page_alloc>
f01024c1:	85 c0                	test   %eax,%eax
f01024c3:	74 24                	je     f01024e9 <mem_init+0x1260>
f01024c5:	c7 44 24 0c 9a 56 10 	movl   $0xf010569a,0xc(%esp)
f01024cc:	f0 
f01024cd:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01024d4:	f0 
f01024d5:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01024dc:	00 
f01024dd:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01024e4:	e8 3d dc ff ff       	call   f0100126 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024e9:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f01024ee:	8b 08                	mov    (%eax),%ecx
f01024f0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01024f6:	89 f2                	mov    %esi,%edx
f01024f8:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
f01024fe:	c1 fa 03             	sar    $0x3,%edx
f0102501:	c1 e2 0c             	shl    $0xc,%edx
f0102504:	39 d1                	cmp    %edx,%ecx
f0102506:	74 24                	je     f010252c <mem_init+0x12a3>
f0102508:	c7 44 24 0c e0 5a 10 	movl   $0xf0105ae0,0xc(%esp)
f010250f:	f0 
f0102510:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102517:	f0 
f0102518:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010251f:	00 
f0102520:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102527:	e8 fa db ff ff       	call   f0100126 <_panic>
	kern_pgdir[0] = 0;
f010252c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102532:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102537:	74 24                	je     f010255d <mem_init+0x12d4>
f0102539:	c7 44 24 0c 0d 57 10 	movl   $0xf010570d,0xc(%esp)
f0102540:	f0 
f0102541:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102548:	f0 
f0102549:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102550:	00 
f0102551:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102558:	e8 c9 db ff ff       	call   f0100126 <_panic>
	pp0->pp_ref = 0;
f010255d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102563:	89 34 24             	mov    %esi,(%esp)
f0102566:	e8 7f ea ff ff       	call   f0100fea <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010256b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102572:	00 
f0102573:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010257a:	00 
f010257b:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102580:	89 04 24             	mov    %eax,(%esp)
f0102583:	e8 9a ea ff ff       	call   f0101022 <pgdir_walk>
f0102588:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010258b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010258e:	8b 15 88 ef 17 f0    	mov    0xf017ef88,%edx
f0102594:	8b 7a 04             	mov    0x4(%edx),%edi
f0102597:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010259d:	8b 0d 84 ef 17 f0    	mov    0xf017ef84,%ecx
f01025a3:	89 f8                	mov    %edi,%eax
f01025a5:	c1 e8 0c             	shr    $0xc,%eax
f01025a8:	39 c8                	cmp    %ecx,%eax
f01025aa:	72 20                	jb     f01025cc <mem_init+0x1343>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025ac:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01025b0:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01025bf:	00 
f01025c0:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01025c7:	e8 5a db ff ff       	call   f0100126 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01025cc:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01025d2:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01025d5:	74 24                	je     f01025fb <mem_init+0x1372>
f01025d7:	c7 44 24 0c a4 57 10 	movl   $0xf01057a4,0xc(%esp)
f01025de:	f0 
f01025df:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01025e6:	f0 
f01025e7:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f01025ee:	00 
f01025ef:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01025f6:	e8 2b db ff ff       	call   f0100126 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01025fb:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102602:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102608:	89 f0                	mov    %esi,%eax
f010260a:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f0102610:	c1 f8 03             	sar    $0x3,%eax
f0102613:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102616:	89 c2                	mov    %eax,%edx
f0102618:	c1 ea 0c             	shr    $0xc,%edx
f010261b:	39 d1                	cmp    %edx,%ecx
f010261d:	77 20                	ja     f010263f <mem_init+0x13b6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010261f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102623:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f010262a:	f0 
f010262b:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102632:	00 
f0102633:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f010263a:	e8 e7 da ff ff       	call   f0100126 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010263f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102646:	00 
f0102647:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010264e:	00 
	return (void *)(pa + KERNBASE);
f010264f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102654:	89 04 24             	mov    %eax,(%esp)
f0102657:	e8 6b 24 00 00       	call   f0104ac7 <memset>
	page_free(pp0);
f010265c:	89 34 24             	mov    %esi,(%esp)
f010265f:	e8 86 e9 ff ff       	call   f0100fea <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102664:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010266b:	00 
f010266c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102673:	00 
f0102674:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102679:	89 04 24             	mov    %eax,(%esp)
f010267c:	e8 a1 e9 ff ff       	call   f0101022 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102681:	89 f2                	mov    %esi,%edx
f0102683:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
f0102689:	c1 fa 03             	sar    $0x3,%edx
f010268c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010268f:	89 d0                	mov    %edx,%eax
f0102691:	c1 e8 0c             	shr    $0xc,%eax
f0102694:	3b 05 84 ef 17 f0    	cmp    0xf017ef84,%eax
f010269a:	72 20                	jb     f01026bc <mem_init+0x1433>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010269c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01026a0:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f01026a7:	f0 
f01026a8:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01026af:	00 
f01026b0:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f01026b7:	e8 6a da ff ff       	call   f0100126 <_panic>
	return (void *)(pa + KERNBASE);
f01026bc:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01026c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01026c5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01026cb:	f6 00 01             	testb  $0x1,(%eax)
f01026ce:	74 24                	je     f01026f4 <mem_init+0x146b>
f01026d0:	c7 44 24 0c bc 57 10 	movl   $0xf01057bc,0xc(%esp)
f01026d7:	f0 
f01026d8:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f01026e7:	00 
f01026e8:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01026ef:	e8 32 da ff ff       	call   f0100126 <_panic>
f01026f4:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01026f7:	39 d0                	cmp    %edx,%eax
f01026f9:	75 d0                	jne    f01026cb <mem_init+0x1442>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01026fb:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102700:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102706:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010270c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010270f:	a3 c0 e2 17 f0       	mov    %eax,0xf017e2c0

	// free the pages we took
	page_free(pp0);
f0102714:	89 34 24             	mov    %esi,(%esp)
f0102717:	e8 ce e8 ff ff       	call   f0100fea <page_free>
	page_free(pp1);
f010271c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010271f:	89 04 24             	mov    %eax,(%esp)
f0102722:	e8 c3 e8 ff ff       	call   f0100fea <page_free>
	page_free(pp2);
f0102727:	89 1c 24             	mov    %ebx,(%esp)
f010272a:	e8 bb e8 ff ff       	call   f0100fea <page_free>

	cprintf("check_page() succeeded!\n");
f010272f:	c7 04 24 d3 57 10 f0 	movl   $0xf01057d3,(%esp)
f0102736:	e8 6a 10 00 00       	call   f01037a5 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f010273b:	a1 8c ef 17 f0       	mov    0xf017ef8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102740:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102745:	77 20                	ja     f0102767 <mem_init+0x14de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102747:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010274b:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f0102752:	f0 
f0102753:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
f010275a:	00 
f010275b:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102762:	e8 bf d9 ff ff       	call   f0100126 <_panic>
f0102767:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f010276e:	00 
	return (physaddr_t)kva - KERNBASE;
f010276f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102774:	89 04 24             	mov    %eax,(%esp)
f0102777:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010277c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102781:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102786:	e8 37 e9 ff ff       	call   f01010c2 <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f010278b:	a1 8c ef 17 f0       	mov    0xf017ef8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102790:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102795:	77 20                	ja     f01027b7 <mem_init+0x152e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102797:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010279b:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f01027a2:	f0 
f01027a3:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f01027aa:	00 
f01027ab:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01027b2:	e8 6f d9 ff ff       	call   f0100126 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01027b7:	05 00 00 00 10       	add    $0x10000000,%eax
f01027bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027c0:	c7 04 24 ec 57 10 f0 	movl   $0xf01057ec,(%esp)
f01027c7:	e8 d9 0f 00 00       	call   f01037a5 <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f01027cc:	a1 cc e2 17 f0       	mov    0xf017e2cc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027d6:	77 20                	ja     f01027f8 <mem_init+0x156f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027dc:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f01027e3:	f0 
f01027e4:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
f01027eb:	00 
f01027ec:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01027f3:	e8 2e d9 ff ff       	call   f0100126 <_panic>
f01027f8:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01027ff:	00 
	return (physaddr_t)kva - KERNBASE;
f0102800:	05 00 00 00 10       	add    $0x10000000,%eax
f0102805:	89 04 24             	mov    %eax,(%esp)
f0102808:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010280d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102812:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102817:	e8 a6 e8 ff ff       	call   f01010c2 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010281c:	bb 00 20 11 f0       	mov    $0xf0112000,%ebx
f0102821:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102827:	77 20                	ja     f0102849 <mem_init+0x15c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102829:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010282d:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f0102834:	f0 
f0102835:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
f010283c:	00 
f010283d:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102844:	e8 dd d8 ff ff       	call   f0100126 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102849:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102850:	00 
f0102851:	c7 04 24 00 20 11 00 	movl   $0x112000,(%esp)
f0102858:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010285d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102862:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102867:	e8 56 e8 ff ff       	call   f01010c2 <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f010286c:	c7 44 24 04 00 20 11 	movl   $0x112000,0x4(%esp)
f0102873:	00 
f0102874:	c7 04 24 fd 57 10 f0 	movl   $0xf01057fd,(%esp)
f010287b:	e8 25 0f 00 00       	call   f01037a5 <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102880:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102887:	00 
f0102888:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010288f:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102894:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102899:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f010289e:	e8 1f e8 ff ff       	call   f01010c2 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01028a3:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f01028a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01028ab:	a1 84 ef 17 f0       	mov    0xf017ef84,%eax
f01028b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01028b3:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01028ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01028bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028c2:	8b 3d 8c ef 17 f0    	mov    0xf017ef8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028c8:	89 7d c8             	mov    %edi,-0x38(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01028cb:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01028d1:	89 45 c4             	mov    %eax,-0x3c(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028d4:	be 00 00 00 00       	mov    $0x0,%esi
f01028d9:	eb 6b                	jmp    f0102946 <mem_init+0x16bd>
f01028db:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028e4:	e8 e6 e1 ff ff       	call   f0100acf <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028e9:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f01028f0:	77 20                	ja     f0102912 <mem_init+0x1689>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028f2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01028f6:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f01028fd:	f0 
f01028fe:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0102905:	00 
f0102906:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010290d:	e8 14 d8 ff ff       	call   f0100126 <_panic>
f0102912:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102915:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102918:	39 d0                	cmp    %edx,%eax
f010291a:	74 24                	je     f0102940 <mem_init+0x16b7>
f010291c:	c7 44 24 0c 28 5e 10 	movl   $0xf0105e28,0xc(%esp)
f0102923:	f0 
f0102924:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f010292b:	f0 
f010292c:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0102933:	00 
f0102934:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f010293b:	e8 e6 d7 ff ff       	call   f0100126 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102940:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102946:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0102949:	77 90                	ja     f01028db <mem_init+0x1652>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010294b:	8b 35 cc e2 17 f0    	mov    0xf017e2cc,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102951:	89 f7                	mov    %esi,%edi
f0102953:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102958:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010295b:	e8 6f e1 ff ff       	call   f0100acf <check_va2pa>
f0102960:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102966:	77 20                	ja     f0102988 <mem_init+0x16ff>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102968:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010296c:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f0102973:	f0 
f0102974:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f010297b:	00 
f010297c:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102983:	e8 9e d7 ff ff       	call   f0100126 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102988:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f010298d:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f0102993:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102996:	39 c2                	cmp    %eax,%edx
f0102998:	74 24                	je     f01029be <mem_init+0x1735>
f010299a:	c7 44 24 0c 5c 5e 10 	movl   $0xf0105e5c,0xc(%esp)
f01029a1:	f0 
f01029a2:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01029a9:	f0 
f01029aa:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f01029b1:	00 
f01029b2:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f01029b9:	e8 68 d7 ff ff       	call   f0100126 <_panic>
f01029be:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01029c4:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01029ca:	0f 85 26 05 00 00    	jne    f0102ef6 <mem_init+0x1c6d>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029d0:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01029d3:	c1 e7 0c             	shl    $0xc,%edi
f01029d6:	be 00 00 00 00       	mov    $0x0,%esi
f01029db:	eb 3c                	jmp    f0102a19 <mem_init+0x1790>
f01029dd:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029e6:	e8 e4 e0 ff ff       	call   f0100acf <check_va2pa>
f01029eb:	39 c6                	cmp    %eax,%esi
f01029ed:	74 24                	je     f0102a13 <mem_init+0x178a>
f01029ef:	c7 44 24 0c 90 5e 10 	movl   $0xf0105e90,0xc(%esp)
f01029f6:	f0 
f01029f7:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f01029fe:	f0 
f01029ff:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0102a06:	00 
f0102a07:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102a0e:	e8 13 d7 ff ff       	call   f0100126 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a13:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a19:	39 fe                	cmp    %edi,%esi
f0102a1b:	72 c0                	jb     f01029dd <mem_init+0x1754>
f0102a1d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a22:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a28:	89 f2                	mov    %esi,%edx
f0102a2a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a2d:	e8 9d e0 ff ff       	call   f0100acf <check_va2pa>
f0102a32:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102a35:	39 d0                	cmp    %edx,%eax
f0102a37:	74 24                	je     f0102a5d <mem_init+0x17d4>
f0102a39:	c7 44 24 0c b8 5e 10 	movl   $0xf0105eb8,0xc(%esp)
f0102a40:	f0 
f0102a41:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102a48:	f0 
f0102a49:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0102a50:	00 
f0102a51:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102a58:	e8 c9 d6 ff ff       	call   f0100126 <_panic>
f0102a5d:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a63:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102a69:	75 bd                	jne    f0102a28 <mem_init+0x179f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a6b:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a70:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102a73:	89 f8                	mov    %edi,%eax
f0102a75:	e8 55 e0 ff ff       	call   f0100acf <check_va2pa>
f0102a7a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a7d:	75 0c                	jne    f0102a8b <mem_init+0x1802>
f0102a7f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a84:	89 fa                	mov    %edi,%edx
f0102a86:	e9 f0 00 00 00       	jmp    f0102b7b <mem_init+0x18f2>
f0102a8b:	c7 44 24 0c 00 5f 10 	movl   $0xf0105f00,0xc(%esp)
f0102a92:	f0 
f0102a93:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102a9a:	f0 
f0102a9b:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0102aa2:	00 
f0102aa3:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102aaa:	e8 77 d6 ff ff       	call   f0100126 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102aaf:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102ab4:	72 3c                	jb     f0102af2 <mem_init+0x1869>
f0102ab6:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102abb:	76 07                	jbe    f0102ac4 <mem_init+0x183b>
f0102abd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ac2:	75 2e                	jne    f0102af2 <mem_init+0x1869>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102ac4:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f0102ac8:	0f 85 aa 00 00 00    	jne    f0102b78 <mem_init+0x18ef>
f0102ace:	c7 44 24 0c 12 58 10 	movl   $0xf0105812,0xc(%esp)
f0102ad5:	f0 
f0102ad6:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0102ae5:	00 
f0102ae6:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102aed:	e8 34 d6 ff ff       	call   f0100126 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102af2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102af7:	76 55                	jbe    f0102b4e <mem_init+0x18c5>
				assert(pgdir[i] & PTE_P);
f0102af9:	8b 0c 82             	mov    (%edx,%eax,4),%ecx
f0102afc:	f6 c1 01             	test   $0x1,%cl
f0102aff:	75 24                	jne    f0102b25 <mem_init+0x189c>
f0102b01:	c7 44 24 0c 12 58 10 	movl   $0xf0105812,0xc(%esp)
f0102b08:	f0 
f0102b09:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102b10:	f0 
f0102b11:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0102b18:	00 
f0102b19:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102b20:	e8 01 d6 ff ff       	call   f0100126 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b25:	f6 c1 02             	test   $0x2,%cl
f0102b28:	75 4e                	jne    f0102b78 <mem_init+0x18ef>
f0102b2a:	c7 44 24 0c 23 58 10 	movl   $0xf0105823,0xc(%esp)
f0102b31:	f0 
f0102b32:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102b39:	f0 
f0102b3a:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0102b41:	00 
f0102b42:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102b49:	e8 d8 d5 ff ff       	call   f0100126 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b4e:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
f0102b52:	74 24                	je     f0102b78 <mem_init+0x18ef>
f0102b54:	c7 44 24 0c 34 58 10 	movl   $0xf0105834,0xc(%esp)
f0102b5b:	f0 
f0102b5c:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102b63:	f0 
f0102b64:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f0102b6b:	00 
f0102b6c:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102b73:	e8 ae d5 ff ff       	call   f0100126 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b78:	83 c0 01             	add    $0x1,%eax
f0102b7b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102b80:	0f 85 29 ff ff ff    	jne    f0102aaf <mem_init+0x1826>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b86:	c7 04 24 30 5f 10 f0 	movl   $0xf0105f30,(%esp)
f0102b8d:	e8 13 0c 00 00       	call   f01037a5 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102b92:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102b97:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b9c:	77 20                	ja     f0102bbe <mem_init+0x1935>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ba2:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f0102ba9:	f0 
f0102baa:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
f0102bb1:	00 
f0102bb2:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102bb9:	e8 68 d5 ff ff       	call   f0100126 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102bbe:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102bc3:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102bc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bcb:	e8 6e df ff ff       	call   f0100b3e <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102bd0:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102bd3:	83 e0 f3             	and    $0xfffffff3,%eax
f0102bd6:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102bdb:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102be5:	e8 7b e3 ff ff       	call   f0100f65 <page_alloc>
f0102bea:	89 c3                	mov    %eax,%ebx
f0102bec:	85 c0                	test   %eax,%eax
f0102bee:	75 24                	jne    f0102c14 <mem_init+0x198b>
f0102bf0:	c7 44 24 0c ef 55 10 	movl   $0xf01055ef,0xc(%esp)
f0102bf7:	f0 
f0102bf8:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102bff:	f0 
f0102c00:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102c07:	00 
f0102c08:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102c0f:	e8 12 d5 ff ff       	call   f0100126 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c1b:	e8 45 e3 ff ff       	call   f0100f65 <page_alloc>
f0102c20:	89 c7                	mov    %eax,%edi
f0102c22:	85 c0                	test   %eax,%eax
f0102c24:	75 24                	jne    f0102c4a <mem_init+0x19c1>
f0102c26:	c7 44 24 0c 05 56 10 	movl   $0xf0105605,0xc(%esp)
f0102c2d:	f0 
f0102c2e:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102c35:	f0 
f0102c36:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0102c3d:	00 
f0102c3e:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102c45:	e8 dc d4 ff ff       	call   f0100126 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c51:	e8 0f e3 ff ff       	call   f0100f65 <page_alloc>
f0102c56:	89 c6                	mov    %eax,%esi
f0102c58:	85 c0                	test   %eax,%eax
f0102c5a:	75 24                	jne    f0102c80 <mem_init+0x19f7>
f0102c5c:	c7 44 24 0c 1b 56 10 	movl   $0xf010561b,0xc(%esp)
f0102c63:	f0 
f0102c64:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102c6b:	f0 
f0102c6c:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0102c73:	00 
f0102c74:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102c7b:	e8 a6 d4 ff ff       	call   f0100126 <_panic>
	page_free(pp0);
f0102c80:	89 1c 24             	mov    %ebx,(%esp)
f0102c83:	e8 62 e3 ff ff       	call   f0100fea <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c88:	89 f8                	mov    %edi,%eax
f0102c8a:	e8 fb dd ff ff       	call   f0100a8a <page2kva>
f0102c8f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c96:	00 
f0102c97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102c9e:	00 
f0102c9f:	89 04 24             	mov    %eax,(%esp)
f0102ca2:	e8 20 1e 00 00       	call   f0104ac7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ca7:	89 f0                	mov    %esi,%eax
f0102ca9:	e8 dc dd ff ff       	call   f0100a8a <page2kva>
f0102cae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cb5:	00 
f0102cb6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102cbd:	00 
f0102cbe:	89 04 24             	mov    %eax,(%esp)
f0102cc1:	e8 01 1e 00 00       	call   f0104ac7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cc6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102ccd:	00 
f0102cce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cd5:	00 
f0102cd6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102cda:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102cdf:	89 04 24             	mov    %eax,(%esp)
f0102ce2:	e8 33 e5 ff ff       	call   f010121a <page_insert>
	assert(pp1->pp_ref == 1);
f0102ce7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cec:	74 24                	je     f0102d12 <mem_init+0x1a89>
f0102cee:	c7 44 24 0c fc 56 10 	movl   $0xf01056fc,0xc(%esp)
f0102cf5:	f0 
f0102cf6:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102cfd:	f0 
f0102cfe:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0102d05:	00 
f0102d06:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102d0d:	e8 14 d4 ff ff       	call   f0100126 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d12:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d19:	01 01 01 
f0102d1c:	74 24                	je     f0102d42 <mem_init+0x1ab9>
f0102d1e:	c7 44 24 0c 50 5f 10 	movl   $0xf0105f50,0xc(%esp)
f0102d25:	f0 
f0102d26:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102d2d:	f0 
f0102d2e:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0102d35:	00 
f0102d36:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102d3d:	e8 e4 d3 ff ff       	call   f0100126 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102d49:	00 
f0102d4a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d51:	00 
f0102d52:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102d56:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102d5b:	89 04 24             	mov    %eax,(%esp)
f0102d5e:	e8 b7 e4 ff ff       	call   f010121a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d63:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d6a:	02 02 02 
f0102d6d:	74 24                	je     f0102d93 <mem_init+0x1b0a>
f0102d6f:	c7 44 24 0c 74 5f 10 	movl   $0xf0105f74,0xc(%esp)
f0102d76:	f0 
f0102d77:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102d7e:	f0 
f0102d7f:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102d86:	00 
f0102d87:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102d8e:	e8 93 d3 ff ff       	call   f0100126 <_panic>
	assert(pp2->pp_ref == 1);
f0102d93:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d98:	74 24                	je     f0102dbe <mem_init+0x1b35>
f0102d9a:	c7 44 24 0c 1e 57 10 	movl   $0xf010571e,0xc(%esp)
f0102da1:	f0 
f0102da2:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102da9:	f0 
f0102daa:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102db1:	00 
f0102db2:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102db9:	e8 68 d3 ff ff       	call   f0100126 <_panic>
	assert(pp1->pp_ref == 0);
f0102dbe:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102dc3:	74 24                	je     f0102de9 <mem_init+0x1b60>
f0102dc5:	c7 44 24 0c 93 57 10 	movl   $0xf0105793,0xc(%esp)
f0102dcc:	f0 
f0102dcd:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102dd4:	f0 
f0102dd5:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102ddc:	00 
f0102ddd:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102de4:	e8 3d d3 ff ff       	call   f0100126 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102de9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102df0:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102df3:	89 f0                	mov    %esi,%eax
f0102df5:	e8 90 dc ff ff       	call   f0100a8a <page2kva>
f0102dfa:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0102e00:	74 24                	je     f0102e26 <mem_init+0x1b9d>
f0102e02:	c7 44 24 0c 98 5f 10 	movl   $0xf0105f98,0xc(%esp)
f0102e09:	f0 
f0102e0a:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102e11:	f0 
f0102e12:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102e19:	00 
f0102e1a:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102e21:	e8 00 d3 ff ff       	call   f0100126 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e26:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102e2d:	00 
f0102e2e:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102e33:	89 04 24             	mov    %eax,(%esp)
f0102e36:	e8 99 e3 ff ff       	call   f01011d4 <page_remove>
	assert(pp2->pp_ref == 0);
f0102e3b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e40:	74 24                	je     f0102e66 <mem_init+0x1bdd>
f0102e42:	c7 44 24 0c 82 57 10 	movl   $0xf0105782,0xc(%esp)
f0102e49:	f0 
f0102e4a:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102e51:	f0 
f0102e52:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102e59:	00 
f0102e5a:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102e61:	e8 c0 d2 ff ff       	call   f0100126 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e66:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0102e6b:	8b 08                	mov    (%eax),%ecx
f0102e6d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e73:	89 da                	mov    %ebx,%edx
f0102e75:	2b 15 8c ef 17 f0    	sub    0xf017ef8c,%edx
f0102e7b:	c1 fa 03             	sar    $0x3,%edx
f0102e7e:	c1 e2 0c             	shl    $0xc,%edx
f0102e81:	39 d1                	cmp    %edx,%ecx
f0102e83:	74 24                	je     f0102ea9 <mem_init+0x1c20>
f0102e85:	c7 44 24 0c e0 5a 10 	movl   $0xf0105ae0,0xc(%esp)
f0102e8c:	f0 
f0102e8d:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102e94:	f0 
f0102e95:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0102e9c:	00 
f0102e9d:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102ea4:	e8 7d d2 ff ff       	call   f0100126 <_panic>
	kern_pgdir[0] = 0;
f0102ea9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102eaf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102eb4:	74 24                	je     f0102eda <mem_init+0x1c51>
f0102eb6:	c7 44 24 0c 0d 57 10 	movl   $0xf010570d,0xc(%esp)
f0102ebd:	f0 
f0102ebe:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0102ec5:	f0 
f0102ec6:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102ecd:	00 
f0102ece:	c7 04 24 de 54 10 f0 	movl   $0xf01054de,(%esp)
f0102ed5:	e8 4c d2 ff ff       	call   f0100126 <_panic>
	pp0->pp_ref = 0;
f0102eda:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102ee0:	89 1c 24             	mov    %ebx,(%esp)
f0102ee3:	e8 02 e1 ff ff       	call   f0100fea <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ee8:	c7 04 24 c4 5f 10 f0 	movl   $0xf0105fc4,(%esp)
f0102eef:	e8 b1 08 00 00       	call   f01037a5 <cprintf>
f0102ef4:	eb 0f                	jmp    f0102f05 <mem_init+0x1c7c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ef6:	89 f2                	mov    %esi,%edx
f0102ef8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102efb:	e8 cf db ff ff       	call   f0100acf <check_va2pa>
f0102f00:	e9 8e fa ff ff       	jmp    f0102993 <mem_init+0x170a>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f05:	83 c4 4c             	add    $0x4c,%esp
f0102f08:	5b                   	pop    %ebx
f0102f09:	5e                   	pop    %esi
f0102f0a:	5f                   	pop    %edi
f0102f0b:	5d                   	pop    %ebp
f0102f0c:	c3                   	ret    

f0102f0d <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102f0d:	55                   	push   %ebp
f0102f0e:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102f10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f13:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102f16:	5d                   	pop    %ebp
f0102f17:	c3                   	ret    

f0102f18 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f18:	55                   	push   %ebp
f0102f19:	89 e5                	mov    %esp,%ebp
f0102f1b:	57                   	push   %edi
f0102f1c:	56                   	push   %esi
f0102f1d:	53                   	push   %ebx
f0102f1e:	83 ec 1c             	sub    $0x1c,%esp
f0102f21:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102f24:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	cprintf("user_mem_check va: %x, len: %x\n", va, len);
f0102f27:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f2a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f35:	c7 04 24 f0 5f 10 f0 	movl   $0xf0105ff0,(%esp)
f0102f3c:	e8 64 08 00 00       	call   f01037a5 <cprintf>
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102f41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f44:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f4d:	8b 55 10             	mov    0x10(%ebp),%edx
f0102f50:	8d 84 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%eax
f0102f57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102f5f:	eb 49                	jmp    f0102faa <user_mem_check+0x92>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102f61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f68:	00 
f0102f69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f6d:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102f70:	89 04 24             	mov    %eax,(%esp)
f0102f73:	e8 aa e0 ff ff       	call   f0101022 <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102f78:	85 c0                	test   %eax,%eax
f0102f7a:	74 14                	je     f0102f90 <user_mem_check+0x78>
f0102f7c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f82:	77 0c                	ja     f0102f90 <user_mem_check+0x78>
f0102f84:	8b 00                	mov    (%eax),%eax
f0102f86:	a8 01                	test   $0x1,%al
f0102f88:	74 06                	je     f0102f90 <user_mem_check+0x78>
f0102f8a:	21 f0                	and    %esi,%eax
f0102f8c:	39 c6                	cmp    %eax,%esi
f0102f8e:	74 14                	je     f0102fa4 <user_mem_check+0x8c>
f0102f90:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102f93:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102f97:	89 1d bc e2 17 f0    	mov    %ebx,0xf017e2bc
			return -E_FAULT;
f0102f9d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102fa2:	eb 2a                	jmp    f0102fce <user_mem_check+0xb6>
	// LAB 3: Your code here.
	cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102fa4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102faa:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102fad:	72 b2                	jb     f0102f61 <user_mem_check+0x49>
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	cprintf("user_mem_check success va: %x, len: %x\n", va, len);
f0102faf:	8b 45 10             	mov    0x10(%ebp),%eax
f0102fb2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fbd:	c7 04 24 10 60 10 f0 	movl   $0xf0106010,(%esp)
f0102fc4:	e8 dc 07 00 00       	call   f01037a5 <cprintf>
	return 0;
f0102fc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fce:	83 c4 1c             	add    $0x1c,%esp
f0102fd1:	5b                   	pop    %ebx
f0102fd2:	5e                   	pop    %esi
f0102fd3:	5f                   	pop    %edi
f0102fd4:	5d                   	pop    %ebp
f0102fd5:	c3                   	ret    

f0102fd6 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102fd6:	55                   	push   %ebp
f0102fd7:	89 e5                	mov    %esp,%ebp
f0102fd9:	53                   	push   %ebx
f0102fda:	83 ec 14             	sub    $0x14,%esp
f0102fdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102fe0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fe3:	83 c8 04             	or     $0x4,%eax
f0102fe6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102fea:	8b 45 10             	mov    0x10(%ebp),%eax
f0102fed:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ff8:	89 1c 24             	mov    %ebx,(%esp)
f0102ffb:	e8 18 ff ff ff       	call   f0102f18 <user_mem_check>
f0103000:	85 c0                	test   %eax,%eax
f0103002:	79 24                	jns    f0103028 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103004:	a1 bc e2 17 f0       	mov    0xf017e2bc,%eax
f0103009:	89 44 24 08          	mov    %eax,0x8(%esp)
f010300d:	8b 43 48             	mov    0x48(%ebx),%eax
f0103010:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103014:	c7 04 24 38 60 10 f0 	movl   $0xf0106038,(%esp)
f010301b:	e8 85 07 00 00       	call   f01037a5 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103020:	89 1c 24             	mov    %ebx,(%esp)
f0103023:	e8 4a 06 00 00       	call   f0103672 <env_destroy>
	}
}
f0103028:	83 c4 14             	add    $0x14,%esp
f010302b:	5b                   	pop    %ebx
f010302c:	5d                   	pop    %ebp
f010302d:	c3                   	ret    

f010302e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010302e:	55                   	push   %ebp
f010302f:	89 e5                	mov    %esp,%ebp
f0103031:	57                   	push   %edi
f0103032:	56                   	push   %esi
f0103033:	53                   	push   %ebx
f0103034:	83 ec 1c             	sub    $0x1c,%esp
f0103037:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

    void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
f0103039:	89 d3                	mov    %edx,%ebx
f010303b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0103041:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103048:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    struct PageInfo *p = NULL;
     void* i;
    int r;
    for(i=start; i<end; i+=PGSIZE){
f010304e:	eb 6d                	jmp    f01030bd <region_alloc+0x8f>
         p = page_alloc(0);
f0103050:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103057:	e8 09 df ff ff       	call   f0100f65 <page_alloc>
         if(p == NULL)
f010305c:	85 c0                	test   %eax,%eax
f010305e:	75 1c                	jne    f010307c <region_alloc+0x4e>
            panic(" region alloc, allocation failed.");
f0103060:	c7 44 24 08 70 60 10 	movl   $0xf0106070,0x8(%esp)
f0103067:	f0 
f0103068:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f010306f:	00 
f0103070:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f0103077:	e8 aa d0 ff ff       	call   f0100126 <_panic>
 
         r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f010307c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103083:	00 
f0103084:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103088:	89 44 24 04          	mov    %eax,0x4(%esp)
f010308c:	8b 47 5c             	mov    0x5c(%edi),%eax
f010308f:	89 04 24             	mov    %eax,(%esp)
f0103092:	e8 83 e1 ff ff       	call   f010121a <page_insert>
        if(r != 0) {
f0103097:	85 c0                	test   %eax,%eax
f0103099:	74 1c                	je     f01030b7 <region_alloc+0x89>
            panic("region alloc error");
f010309b:	c7 44 24 08 65 61 10 	movl   $0xf0106165,0x8(%esp)
f01030a2:	f0 
f01030a3:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f01030aa:	00 
f01030ab:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f01030b2:	e8 6f d0 ff ff       	call   f0100126 <_panic>
    void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
    void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
    struct PageInfo *p = NULL;
     void* i;
    int r;
    for(i=start; i<end; i+=PGSIZE){
f01030b7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01030bd:	39 f3                	cmp    %esi,%ebx
f01030bf:	72 8f                	jb     f0103050 <region_alloc+0x22>
         r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
        if(r != 0) {
            panic("region alloc error");
        }
     }
}
f01030c1:	83 c4 1c             	add    $0x1c,%esp
f01030c4:	5b                   	pop    %ebx
f01030c5:	5e                   	pop    %esi
f01030c6:	5f                   	pop    %edi
f01030c7:	5d                   	pop    %ebp
f01030c8:	c3                   	ret    

f01030c9 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01030c9:	55                   	push   %ebp
f01030ca:	89 e5                	mov    %esp,%ebp
f01030cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01030cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01030d2:	85 c0                	test   %eax,%eax
f01030d4:	75 11                	jne    f01030e7 <envid2env+0x1e>
		*env_store = curenv;
f01030d6:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f01030db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030de:	89 01                	mov    %eax,(%ecx)
		return 0;
f01030e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e5:	eb 5e                	jmp    f0103145 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01030e7:	89 c2                	mov    %eax,%edx
f01030e9:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01030ef:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01030f2:	c1 e2 05             	shl    $0x5,%edx
f01030f5:	03 15 cc e2 17 f0    	add    0xf017e2cc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030fb:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01030ff:	74 05                	je     f0103106 <envid2env+0x3d>
f0103101:	39 42 48             	cmp    %eax,0x48(%edx)
f0103104:	74 10                	je     f0103116 <envid2env+0x4d>
		*env_store = 0;
f0103106:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103109:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010310f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103114:	eb 2f                	jmp    f0103145 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103116:	84 c9                	test   %cl,%cl
f0103118:	74 21                	je     f010313b <envid2env+0x72>
f010311a:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f010311f:	39 c2                	cmp    %eax,%edx
f0103121:	74 18                	je     f010313b <envid2env+0x72>
f0103123:	8b 40 48             	mov    0x48(%eax),%eax
f0103126:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0103129:	74 10                	je     f010313b <envid2env+0x72>
		*env_store = 0;
f010312b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010312e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103134:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103139:	eb 0a                	jmp    f0103145 <envid2env+0x7c>
	}

	*env_store = e;
f010313b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010313e:	89 10                	mov    %edx,(%eax)
	return 0;
f0103140:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103145:	5d                   	pop    %ebp
f0103146:	c3                   	ret    

f0103147 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103147:	55                   	push   %ebp
f0103148:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010314a:	b8 00 c3 11 f0       	mov    $0xf011c300,%eax
f010314f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103152:	b8 23 00 00 00       	mov    $0x23,%eax
f0103157:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103159:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010315b:	b0 10                	mov    $0x10,%al
f010315d:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010315f:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103161:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103163:	ea 6a 31 10 f0 08 00 	ljmp   $0x8,$0xf010316a
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010316a:	b0 00                	mov    $0x0,%al
f010316c:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010316f:	5d                   	pop    %ebp
f0103170:	c3                   	ret    

f0103171 <env_init>:
{
	// Set up envs array
	// LAB 3: Your code here.
 int i;
      env_free_list = NULL;
	env_free_list=&envs[0];
f0103171:	a1 cc e2 17 f0       	mov    0xf017e2cc,%eax
f0103176:	a3 d0 e2 17 f0       	mov    %eax,0xf017e2d0
	envs[0].env_id=0;
f010317b:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
	envs[0].env_status = ENV_FREE;
f0103182:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0103189:	83 c0 60             	add    $0x60,%eax
f010318c:	ba ff 03 00 00       	mov    $0x3ff,%edx
     for(i=1; i<=NENV-1; i++){
        envs[i].env_id = 0;
f0103191:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0103198:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
        envs[i-1].env_link = &envs[i];
f010319f:	89 40 e4             	mov    %eax,-0x1c(%eax)
f01031a2:	83 c0 60             	add    $0x60,%eax
 int i;
      env_free_list = NULL;
	env_free_list=&envs[0];
	envs[0].env_id=0;
	envs[0].env_status = ENV_FREE;
     for(i=1; i<=NENV-1; i++){
f01031a5:	83 ea 01             	sub    $0x1,%edx
f01031a8:	75 e7                	jne    f0103191 <env_init+0x20>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01031aa:	55                   	push   %ebp
f01031ab:	89 e5                	mov    %esp,%ebp
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        envs[i-1].env_link = &envs[i];
    }
	// Per-CPU part of the initialization
	env_init_percpu();
f01031ad:	e8 95 ff ff ff       	call   f0103147 <env_init_percpu>
}
f01031b2:	5d                   	pop    %ebp
f01031b3:	c3                   	ret    

f01031b4 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01031b4:	55                   	push   %ebp
f01031b5:	89 e5                	mov    %esp,%ebp
f01031b7:	57                   	push   %edi
f01031b8:	56                   	push   %esi
f01031b9:	53                   	push   %ebx
f01031ba:	83 ec 1c             	sub    $0x1c,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01031bd:	8b 1d d0 e2 17 f0    	mov    0xf017e2d0,%ebx
f01031c3:	85 db                	test   %ebx,%ebx
f01031c5:	0f 84 60 01 00 00    	je     f010332b <env_alloc+0x177>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01031cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01031d2:	e8 8e dd ff ff       	call   f0100f65 <page_alloc>
f01031d7:	85 c0                	test   %eax,%eax
f01031d9:	0f 84 53 01 00 00    	je     f0103332 <env_alloc+0x17e>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	(p->pp_ref)++;
f01031df:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031e4:	2b 05 8c ef 17 f0    	sub    0xf017ef8c,%eax
f01031ea:	c1 f8 03             	sar    $0x3,%eax
f01031ed:	c1 e0 0c             	shl    $0xc,%eax
f01031f0:	89 c7                	mov    %eax,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031f2:	c1 e8 0c             	shr    $0xc,%eax
f01031f5:	3b 05 84 ef 17 f0    	cmp    0xf017ef84,%eax
f01031fb:	72 20                	jb     f010321d <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103201:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0103208:	f0 
f0103209:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103210:	00 
f0103211:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f0103218:	e8 09 cf ff ff       	call   f0100126 <_panic>
	return (void *)(pa + KERNBASE);
f010321d:	8d b7 00 00 00 f0    	lea    -0x10000000(%edi),%esi
	pde_t* page_dir = page2kva(p);
	memcpy(page_dir,kern_pgdir,PGSIZE);
f0103223:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010322a:	00 
f010322b:	a1 88 ef 17 f0       	mov    0xf017ef88,%eax
f0103230:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103234:	89 34 24             	mov    %esi,(%esp)
f0103237:	e8 40 19 00 00       	call   f0104b7c <memcpy>
	e->env_pgdir = page_dir;
f010323c:	89 73 5c             	mov    %esi,0x5c(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323f:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0103245:	77 20                	ja     f0103267 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103247:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010324b:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f0103252:	f0 
f0103253:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
f010325a:	00 
f010325b:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f0103262:	e8 bf ce ff ff       	call   f0100126 <_panic>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103267:	83 cf 05             	or     $0x5,%edi
f010326a:	89 be f4 0e 00 00    	mov    %edi,0xef4(%esi)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103270:	8b 43 48             	mov    0x48(%ebx),%eax
f0103273:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103278:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010327d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103282:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103285:	89 da                	mov    %ebx,%edx
f0103287:	2b 15 cc e2 17 f0    	sub    0xf017e2cc,%edx
f010328d:	c1 fa 05             	sar    $0x5,%edx
f0103290:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103296:	09 d0                	or     %edx,%eax
f0103298:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010329b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010329e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01032a1:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01032a8:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01032af:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01032b6:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01032bd:	00 
f01032be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01032c5:	00 
f01032c6:	89 1c 24             	mov    %ebx,(%esp)
f01032c9:	e8 f9 17 00 00       	call   f0104ac7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01032ce:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01032d4:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01032da:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01032e0:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01032e7:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01032ed:	8b 43 44             	mov    0x44(%ebx),%eax
f01032f0:	a3 d0 e2 17 f0       	mov    %eax,0xf017e2d0
	*newenv_store = e;
f01032f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032fa:	8b 53 48             	mov    0x48(%ebx),%edx
f01032fd:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0103302:	85 c0                	test   %eax,%eax
f0103304:	74 05                	je     f010330b <env_alloc+0x157>
f0103306:	8b 40 48             	mov    0x48(%eax),%eax
f0103309:	eb 05                	jmp    f0103310 <env_alloc+0x15c>
f010330b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103310:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103314:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103318:	c7 04 24 78 61 10 f0 	movl   $0xf0106178,(%esp)
f010331f:	e8 81 04 00 00       	call   f01037a5 <cprintf>
	return 0;
f0103324:	b8 00 00 00 00       	mov    $0x0,%eax
f0103329:	eb 0c                	jmp    f0103337 <env_alloc+0x183>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010332b:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103330:	eb 05                	jmp    f0103337 <env_alloc+0x183>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103332:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103337:	83 c4 1c             	add    $0x1c,%esp
f010333a:	5b                   	pop    %ebx
f010333b:	5e                   	pop    %esi
f010333c:	5f                   	pop    %edi
f010333d:	5d                   	pop    %ebp
f010333e:	c3                   	ret    

f010333f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010333f:	55                   	push   %ebp
f0103340:	89 e5                	mov    %esp,%ebp
f0103342:	57                   	push   %edi
f0103343:	56                   	push   %esi
f0103344:	53                   	push   %ebx
f0103345:	83 ec 3c             	sub    $0x3c,%esp
f0103348:	8b 7d 08             	mov    0x8(%ebp),%edi
	      struct Env *e;
      int rc;
     if((rc = env_alloc(&e, 0)) != 0) {
f010334b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103352:	00 
f0103353:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103356:	89 04 24             	mov    %eax,(%esp)
f0103359:	e8 56 fe ff ff       	call   f01031b4 <env_alloc>
f010335e:	85 c0                	test   %eax,%eax
f0103360:	74 1c                	je     f010337e <env_create+0x3f>
         panic("env_create failed: env_alloc failed.\n");
f0103362:	c7 44 24 08 94 60 10 	movl   $0xf0106094,0x8(%esp)
f0103369:	f0 
f010336a:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f0103371:	00 
f0103372:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f0103379:	e8 a8 cd ff ff       	call   f0100126 <_panic>
     }
   load_icode(e, binary);
f010337e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103381:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	    struct Elf* header = (struct Elf*)binary;
    
    if(header->e_magic != ELF_MAGIC) {
f0103384:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010338a:	74 1c                	je     f01033a8 <env_create+0x69>
        panic("load_icode failed: The binary we load is not elf.\n");
f010338c:	c7 44 24 08 bc 60 10 	movl   $0xf01060bc,0x8(%esp)
f0103393:	f0 
f0103394:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f010339b:	00 
f010339c:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f01033a3:	e8 7e cd ff ff       	call   f0100126 <_panic>
    }

    if(header->e_entry == 0){
f01033a8:	8b 47 18             	mov    0x18(%edi),%eax
f01033ab:	85 c0                	test   %eax,%eax
f01033ad:	75 1c                	jne    f01033cb <env_create+0x8c>
        panic("load_icode failed: The elf file can't be excuterd.\n");
f01033af:	c7 44 24 08 f0 60 10 	movl   $0xf01060f0,0x8(%esp)
f01033b6:	f0 
f01033b7:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f01033be:	00 
f01033bf:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f01033c6:	e8 5b cd ff ff       	call   f0100126 <_panic>
    }

    e->env_tf.tf_eip = header->e_entry;
f01033cb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01033ce:	89 41 30             	mov    %eax,0x30(%ecx)

    lcr3(PADDR(e->env_pgdir));   
f01033d1:	8b 41 5c             	mov    0x5c(%ecx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033d9:	77 20                	ja     f01033fb <env_create+0xbc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033df:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f01033e6:	f0 
f01033e7:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f01033ee:	00 
f01033ef:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f01033f6:	e8 2b cd ff ff       	call   f0100126 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01033fb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103400:	0f 22 d8             	mov    %eax,%cr3

    struct Proghdr *ph, *eph;
    ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f0103403:	89 fb                	mov    %edi,%ebx
f0103405:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + header->e_phnum;
f0103408:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010340c:	c1 e6 05             	shl    $0x5,%esi
f010340f:	01 de                	add    %ebx,%esi
f0103411:	eb 50                	jmp    f0103463 <env_create+0x124>
    for(; ph < eph; ph++) {
        if(ph->p_type == ELF_PROG_LOAD) {
f0103413:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103416:	75 48                	jne    f0103460 <env_create+0x121>
            if(ph->p_memsz - ph->p_filesz < 0) {
                panic("load icode failed : p_memsz < p_filesz.\n");
            }

            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103418:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010341b:	8b 53 08             	mov    0x8(%ebx),%edx
f010341e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103421:	e8 08 fc ff ff       	call   f010302e <region_alloc>
            memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103426:	8b 43 10             	mov    0x10(%ebx),%eax
f0103429:	89 44 24 08          	mov    %eax,0x8(%esp)
f010342d:	89 f8                	mov    %edi,%eax
f010342f:	03 43 04             	add    0x4(%ebx),%eax
f0103432:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103436:	8b 43 08             	mov    0x8(%ebx),%eax
f0103439:	89 04 24             	mov    %eax,(%esp)
f010343c:	e8 d3 16 00 00       	call   f0104b14 <memmove>
            memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103441:	8b 43 10             	mov    0x10(%ebx),%eax
f0103444:	8b 53 14             	mov    0x14(%ebx),%edx
f0103447:	29 c2                	sub    %eax,%edx
f0103449:	89 54 24 08          	mov    %edx,0x8(%esp)
f010344d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103454:	00 
f0103455:	03 43 08             	add    0x8(%ebx),%eax
f0103458:	89 04 24             	mov    %eax,(%esp)
f010345b:	e8 67 16 00 00       	call   f0104ac7 <memset>
    lcr3(PADDR(e->env_pgdir));   

    struct Proghdr *ph, *eph;
    ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
    eph = ph + header->e_phnum;
    for(; ph < eph; ph++) {
f0103460:	83 c3 20             	add    $0x20,%ebx
f0103463:	39 de                	cmp    %ebx,%esi
f0103465:	77 ac                	ja     f0103413 <env_create+0xd4>



	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	 region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f0103467:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010346c:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103474:	e8 b5 fb ff ff       	call   f010302e <region_alloc>
      int rc;
     if((rc = env_alloc(&e, 0)) != 0) {
         panic("env_create failed: env_alloc failed.\n");
     }
   load_icode(e, binary);
    e->env_type = type;// LAB 3: Your code here.
f0103479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010347c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010347f:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103482:	83 c4 3c             	add    $0x3c,%esp
f0103485:	5b                   	pop    %ebx
f0103486:	5e                   	pop    %esi
f0103487:	5f                   	pop    %edi
f0103488:	5d                   	pop    %ebp
f0103489:	c3                   	ret    

f010348a <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010348a:	55                   	push   %ebp
f010348b:	89 e5                	mov    %esp,%ebp
f010348d:	57                   	push   %edi
f010348e:	56                   	push   %esi
f010348f:	53                   	push   %ebx
f0103490:	83 ec 2c             	sub    $0x2c,%esp
f0103493:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103496:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f010349b:	39 c7                	cmp    %eax,%edi
f010349d:	75 37                	jne    f01034d6 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f010349f:	8b 15 88 ef 17 f0    	mov    0xf017ef88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034a5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01034ab:	77 20                	ja     f01034cd <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01034b1:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f01034b8:	f0 
f01034b9:	c7 44 24 04 b0 01 00 	movl   $0x1b0,0x4(%esp)
f01034c0:	00 
f01034c1:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f01034c8:	e8 59 cc ff ff       	call   f0100126 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01034cd:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01034d3:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01034d6:	8b 57 48             	mov    0x48(%edi),%edx
f01034d9:	85 c0                	test   %eax,%eax
f01034db:	74 05                	je     f01034e2 <env_free+0x58>
f01034dd:	8b 40 48             	mov    0x48(%eax),%eax
f01034e0:	eb 05                	jmp    f01034e7 <env_free+0x5d>
f01034e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01034e7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01034eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034ef:	c7 04 24 8d 61 10 f0 	movl   $0xf010618d,(%esp)
f01034f6:	e8 aa 02 00 00       	call   f01037a5 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034fb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103502:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103505:	89 c8                	mov    %ecx,%eax
f0103507:	c1 e0 02             	shl    $0x2,%eax
f010350a:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010350d:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103510:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103513:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103519:	0f 84 b7 00 00 00    	je     f01035d6 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010351f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103525:	89 f0                	mov    %esi,%eax
f0103527:	c1 e8 0c             	shr    $0xc,%eax
f010352a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010352d:	3b 05 84 ef 17 f0    	cmp    0xf017ef84,%eax
f0103533:	72 20                	jb     f0103555 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103535:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103539:	c7 44 24 08 44 58 10 	movl   $0xf0105844,0x8(%esp)
f0103540:	f0 
f0103541:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
f0103548:	00 
f0103549:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f0103550:	e8 d1 cb ff ff       	call   f0100126 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103555:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103558:	c1 e0 16             	shl    $0x16,%eax
f010355b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010355e:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103563:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010356a:	01 
f010356b:	74 17                	je     f0103584 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010356d:	89 d8                	mov    %ebx,%eax
f010356f:	c1 e0 0c             	shl    $0xc,%eax
f0103572:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103575:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103579:	8b 47 5c             	mov    0x5c(%edi),%eax
f010357c:	89 04 24             	mov    %eax,(%esp)
f010357f:	e8 50 dc ff ff       	call   f01011d4 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103584:	83 c3 01             	add    $0x1,%ebx
f0103587:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010358d:	75 d4                	jne    f0103563 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010358f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103592:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103595:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010359c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010359f:	3b 05 84 ef 17 f0    	cmp    0xf017ef84,%eax
f01035a5:	72 1c                	jb     f01035c3 <env_free+0x139>
		panic("pa2page called with invalid pa");
f01035a7:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f01035ae:	f0 
f01035af:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01035b6:	00 
f01035b7:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f01035be:	e8 63 cb ff ff       	call   f0100126 <_panic>
	return &pages[PGNUM(pa)];
f01035c3:	a1 8c ef 17 f0       	mov    0xf017ef8c,%eax
f01035c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035cb:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f01035ce:	89 04 24             	mov    %eax,(%esp)
f01035d1:	e8 29 da ff ff       	call   f0100fff <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035d6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01035da:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01035e1:	0f 85 1b ff ff ff    	jne    f0103502 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035e7:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035ef:	77 20                	ja     f0103611 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035f5:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f01035fc:	f0 
f01035fd:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
f0103604:	00 
f0103605:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f010360c:	e8 15 cb ff ff       	call   f0100126 <_panic>
	e->env_pgdir = 0;
f0103611:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103618:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010361d:	c1 e8 0c             	shr    $0xc,%eax
f0103620:	3b 05 84 ef 17 f0    	cmp    0xf017ef84,%eax
f0103626:	72 1c                	jb     f0103644 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f0103628:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f010362f:	f0 
f0103630:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103637:	00 
f0103638:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f010363f:	e8 e2 ca ff ff       	call   f0100126 <_panic>
	return &pages[PGNUM(pa)];
f0103644:	8b 15 8c ef 17 f0    	mov    0xf017ef8c,%edx
f010364a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f010364d:	89 04 24             	mov    %eax,(%esp)
f0103650:	e8 aa d9 ff ff       	call   f0100fff <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103655:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010365c:	a1 d0 e2 17 f0       	mov    0xf017e2d0,%eax
f0103661:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103664:	89 3d d0 e2 17 f0    	mov    %edi,0xf017e2d0
}
f010366a:	83 c4 2c             	add    $0x2c,%esp
f010366d:	5b                   	pop    %ebx
f010366e:	5e                   	pop    %esi
f010366f:	5f                   	pop    %edi
f0103670:	5d                   	pop    %ebp
f0103671:	c3                   	ret    

f0103672 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103672:	55                   	push   %ebp
f0103673:	89 e5                	mov    %esp,%ebp
f0103675:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103678:	8b 45 08             	mov    0x8(%ebp),%eax
f010367b:	89 04 24             	mov    %eax,(%esp)
f010367e:	e8 07 fe ff ff       	call   f010348a <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103683:	c7 04 24 24 61 10 f0 	movl   $0xf0106124,(%esp)
f010368a:	e8 16 01 00 00       	call   f01037a5 <cprintf>
	while (1)
		monitor(NULL);
f010368f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103696:	e8 2b d2 ff ff       	call   f01008c6 <monitor>
f010369b:	eb f2                	jmp    f010368f <env_destroy+0x1d>

f010369d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010369d:	55                   	push   %ebp
f010369e:	89 e5                	mov    %esp,%ebp
f01036a0:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01036a3:	8b 65 08             	mov    0x8(%ebp),%esp
f01036a6:	61                   	popa   
f01036a7:	07                   	pop    %es
f01036a8:	1f                   	pop    %ds
f01036a9:	83 c4 08             	add    $0x8,%esp
f01036ac:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036ad:	c7 44 24 08 a3 61 10 	movl   $0xf01061a3,0x8(%esp)
f01036b4:	f0 
f01036b5:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
f01036bc:	00 
f01036bd:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f01036c4:	e8 5d ca ff ff       	call   f0100126 <_panic>

f01036c9 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036c9:	55                   	push   %ebp
f01036ca:	89 e5                	mov    %esp,%ebp
f01036cc:	83 ec 18             	sub    $0x18,%esp
f01036cf:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	  if(curenv != NULL && curenv->env_status == ENV_RUNNING) {
f01036d2:	8b 15 c8 e2 17 f0    	mov    0xf017e2c8,%edx
f01036d8:	85 d2                	test   %edx,%edx
f01036da:	74 0d                	je     f01036e9 <env_run+0x20>
f01036dc:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f01036e0:	75 07                	jne    f01036e9 <env_run+0x20>
        curenv->env_status = ENV_RUNNABLE;
f01036e2:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
    }

     curenv = e;
f01036e9:	a3 c8 e2 17 f0       	mov    %eax,0xf017e2c8
     curenv->env_status = ENV_RUNNING;
f01036ee:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f01036f5:	83 40 58 01          	addl   $0x1,0x58(%eax)
     lcr3(PADDR(curenv->env_pgdir));
f01036f9:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036fc:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103702:	77 20                	ja     f0103724 <env_run+0x5b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103704:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103708:	c7 44 24 08 e4 59 10 	movl   $0xf01059e4,0x8(%esp)
f010370f:	f0 
f0103710:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
f0103717:	00 
f0103718:	c7 04 24 5a 61 10 f0 	movl   $0xf010615a,(%esp)
f010371f:	e8 02 ca ff ff       	call   f0100126 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103724:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010372a:	0f 22 da             	mov    %edx,%cr3
 
     env_pop_tf(&curenv->env_tf);
f010372d:	89 04 24             	mov    %eax,(%esp)
f0103730:	e8 68 ff ff ff       	call   f010369d <env_pop_tf>

f0103735 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103735:	55                   	push   %ebp
f0103736:	89 e5                	mov    %esp,%ebp
f0103738:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010373c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103741:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103742:	b2 71                	mov    $0x71,%dl
f0103744:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103745:	0f b6 c0             	movzbl %al,%eax
}
f0103748:	5d                   	pop    %ebp
f0103749:	c3                   	ret    

f010374a <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010374a:	55                   	push   %ebp
f010374b:	89 e5                	mov    %esp,%ebp
f010374d:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103751:	ba 70 00 00 00       	mov    $0x70,%edx
f0103756:	ee                   	out    %al,(%dx)
f0103757:	b2 71                	mov    $0x71,%dl
f0103759:	8b 45 0c             	mov    0xc(%ebp),%eax
f010375c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010375d:	5d                   	pop    %ebp
f010375e:	c3                   	ret    

f010375f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010375f:	55                   	push   %ebp
f0103760:	89 e5                	mov    %esp,%ebp
f0103762:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103765:	8b 45 08             	mov    0x8(%ebp),%eax
f0103768:	89 04 24             	mov    %eax,(%esp)
f010376b:	e8 11 cf ff ff       	call   f0100681 <cputchar>
	*cnt++;
}
f0103770:	c9                   	leave  
f0103771:	c3                   	ret    

f0103772 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103772:	55                   	push   %ebp
f0103773:	89 e5                	mov    %esp,%ebp
f0103775:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010377f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103782:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103786:	8b 45 08             	mov    0x8(%ebp),%eax
f0103789:	89 44 24 08          	mov    %eax,0x8(%esp)
f010378d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103790:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103794:	c7 04 24 5f 37 10 f0 	movl   $0xf010375f,(%esp)
f010379b:	e8 5e 0c 00 00       	call   f01043fe <vprintfmt>
	return cnt;
}
f01037a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037a3:	c9                   	leave  
f01037a4:	c3                   	ret    

f01037a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01037a5:	55                   	push   %ebp
f01037a6:	89 e5                	mov    %esp,%ebp
f01037a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01037ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01037ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01037b5:	89 04 24             	mov    %eax,(%esp)
f01037b8:	e8 b5 ff ff ff       	call   f0103772 <vcprintf>
	va_end(ap);

	return cnt;
}
f01037bd:	c9                   	leave  
f01037be:	c3                   	ret    
f01037bf:	90                   	nop

f01037c0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01037c0:	55                   	push   %ebp
f01037c1:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01037c3:	c7 05 04 eb 17 f0 00 	movl   $0xf0000000,0xf017eb04
f01037ca:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01037cd:	66 c7 05 08 eb 17 f0 	movw   $0x10,0xf017eb08
f01037d4:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01037d6:	66 c7 05 48 c3 11 f0 	movw   $0x68,0xf011c348
f01037dd:	68 00 
f01037df:	b8 00 eb 17 f0       	mov    $0xf017eb00,%eax
f01037e4:	66 a3 4a c3 11 f0    	mov    %ax,0xf011c34a
f01037ea:	89 c2                	mov    %eax,%edx
f01037ec:	c1 ea 10             	shr    $0x10,%edx
f01037ef:	88 15 4c c3 11 f0    	mov    %dl,0xf011c34c
f01037f5:	c6 05 4e c3 11 f0 40 	movb   $0x40,0xf011c34e
f01037fc:	c1 e8 18             	shr    $0x18,%eax
f01037ff:	a2 4f c3 11 f0       	mov    %al,0xf011c34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103804:	c6 05 4d c3 11 f0 89 	movb   $0x89,0xf011c34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010380b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103810:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103813:	b8 50 c3 11 f0       	mov    $0xf011c350,%eax
f0103818:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010381b:	5d                   	pop    %ebp
f010381c:	c3                   	ret    

f010381d <trap_init>:



void
trap_init(void)
{
f010381d:	55                   	push   %ebp
f010381e:	89 e5                	mov    %esp,%ebp
f0103820:	83 ec 18             	sub    $0x18,%esp
	// SETGATE(idt[14], 0, GD_KT, th14, 0);
	// SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Challenge:
	extern void (*funs[])();
	cprintf("funs %x\n", funs);
f0103823:	c7 44 24 04 58 c3 11 	movl   $0xf011c358,0x4(%esp)
f010382a:	f0 
f010382b:	c7 04 24 af 61 10 f0 	movl   $0xf01061af,(%esp)
f0103832:	e8 6e ff ff ff       	call   f01037a5 <cprintf>
	cprintf("funs[0] %x\n", funs[0]);
f0103837:	a1 58 c3 11 f0       	mov    0xf011c358,%eax
f010383c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103840:	c7 04 24 b8 61 10 f0 	movl   $0xf01061b8,(%esp)
f0103847:	e8 59 ff ff ff       	call   f01037a5 <cprintf>
	cprintf("funs[48] %x\n", funs[48]);
f010384c:	a1 18 c4 11 f0       	mov    0xf011c418,%eax
f0103851:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103855:	c7 04 24 c4 61 10 f0 	movl   $0xf01061c4,(%esp)
f010385c:	e8 44 ff ff ff       	call   f01037a5 <cprintf>
	int i;
	for (i = 0; i <= 16; ++i)
f0103861:	b8 00 00 00 00       	mov    $0x0,%eax
f0103866:	eb 76                	jmp    f01038de <trap_init+0xc1>
		if (i==T_BRKPT)
f0103868:	83 f8 03             	cmp    $0x3,%eax
f010386b:	75 30                	jne    f010389d <trap_init+0x80>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f010386d:	8b 15 64 c3 11 f0    	mov    0xf011c364,%edx
f0103873:	66 89 15 f8 e2 17 f0 	mov    %dx,0xf017e2f8
f010387a:	66 c7 05 fa e2 17 f0 	movw   $0x8,0xf017e2fa
f0103881:	08 00 
f0103883:	c6 05 fc e2 17 f0 00 	movb   $0x0,0xf017e2fc
f010388a:	c6 05 fd e2 17 f0 ee 	movb   $0xee,0xf017e2fd
f0103891:	c1 ea 10             	shr    $0x10,%edx
f0103894:	66 89 15 fe e2 17 f0 	mov    %dx,0xf017e2fe
f010389b:	eb 3e                	jmp    f01038db <trap_init+0xbe>
		else if (i!=2 && i!=15) {
f010389d:	83 f8 0f             	cmp    $0xf,%eax
f01038a0:	74 39                	je     f01038db <trap_init+0xbe>
f01038a2:	83 f8 02             	cmp    $0x2,%eax
f01038a5:	74 34                	je     f01038db <trap_init+0xbe>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f01038a7:	8b 14 85 58 c3 11 f0 	mov    -0xfee3ca8(,%eax,4),%edx
f01038ae:	66 89 14 c5 e0 e2 17 	mov    %dx,-0xfe81d20(,%eax,8)
f01038b5:	f0 
f01038b6:	66 c7 04 c5 e2 e2 17 	movw   $0x8,-0xfe81d1e(,%eax,8)
f01038bd:	f0 08 00 
f01038c0:	c6 04 c5 e4 e2 17 f0 	movb   $0x0,-0xfe81d1c(,%eax,8)
f01038c7:	00 
f01038c8:	c6 04 c5 e5 e2 17 f0 	movb   $0x8e,-0xfe81d1b(,%eax,8)
f01038cf:	8e 
f01038d0:	c1 ea 10             	shr    $0x10,%edx
f01038d3:	66 89 14 c5 e6 e2 17 	mov    %dx,-0xfe81d1a(,%eax,8)
f01038da:	f0 
	extern void (*funs[])();
	cprintf("funs %x\n", funs);
	cprintf("funs[0] %x\n", funs[0]);
	cprintf("funs[48] %x\n", funs[48]);
	int i;
	for (i = 0; i <= 16; ++i)
f01038db:	83 c0 01             	add    $0x1,%eax
f01038de:	83 f8 11             	cmp    $0x11,%eax
f01038e1:	75 85                	jne    f0103868 <trap_init+0x4b>
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f01038e3:	a1 18 c4 11 f0       	mov    0xf011c418,%eax
f01038e8:	66 a3 60 e4 17 f0    	mov    %ax,0xf017e460
f01038ee:	66 c7 05 62 e4 17 f0 	movw   $0x8,0xf017e462
f01038f5:	08 00 
f01038f7:	c6 05 64 e4 17 f0 00 	movb   $0x0,0xf017e464
f01038fe:	c6 05 65 e4 17 f0 ee 	movb   $0xee,0xf017e465
f0103905:	c1 e8 10             	shr    $0x10,%eax
f0103908:	66 a3 66 e4 17 f0    	mov    %ax,0xf017e466
	// Per-CPU setup 
	trap_init_percpu();
f010390e:	e8 ad fe ff ff       	call   f01037c0 <trap_init_percpu>
}
f0103913:	c9                   	leave  
f0103914:	c3                   	ret    

f0103915 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103915:	55                   	push   %ebp
f0103916:	89 e5                	mov    %esp,%ebp
f0103918:	53                   	push   %ebx
f0103919:	83 ec 14             	sub    $0x14,%esp
f010391c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010391f:	8b 03                	mov    (%ebx),%eax
f0103921:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103925:	c7 04 24 d1 61 10 f0 	movl   $0xf01061d1,(%esp)
f010392c:	e8 74 fe ff ff       	call   f01037a5 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103931:	8b 43 04             	mov    0x4(%ebx),%eax
f0103934:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103938:	c7 04 24 e0 61 10 f0 	movl   $0xf01061e0,(%esp)
f010393f:	e8 61 fe ff ff       	call   f01037a5 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103944:	8b 43 08             	mov    0x8(%ebx),%eax
f0103947:	89 44 24 04          	mov    %eax,0x4(%esp)
f010394b:	c7 04 24 ef 61 10 f0 	movl   $0xf01061ef,(%esp)
f0103952:	e8 4e fe ff ff       	call   f01037a5 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103957:	8b 43 0c             	mov    0xc(%ebx),%eax
f010395a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010395e:	c7 04 24 fe 61 10 f0 	movl   $0xf01061fe,(%esp)
f0103965:	e8 3b fe ff ff       	call   f01037a5 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010396a:	8b 43 10             	mov    0x10(%ebx),%eax
f010396d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103971:	c7 04 24 0d 62 10 f0 	movl   $0xf010620d,(%esp)
f0103978:	e8 28 fe ff ff       	call   f01037a5 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010397d:	8b 43 14             	mov    0x14(%ebx),%eax
f0103980:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103984:	c7 04 24 1c 62 10 f0 	movl   $0xf010621c,(%esp)
f010398b:	e8 15 fe ff ff       	call   f01037a5 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103990:	8b 43 18             	mov    0x18(%ebx),%eax
f0103993:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103997:	c7 04 24 2b 62 10 f0 	movl   $0xf010622b,(%esp)
f010399e:	e8 02 fe ff ff       	call   f01037a5 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01039a3:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01039a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039aa:	c7 04 24 3a 62 10 f0 	movl   $0xf010623a,(%esp)
f01039b1:	e8 ef fd ff ff       	call   f01037a5 <cprintf>
}
f01039b6:	83 c4 14             	add    $0x14,%esp
f01039b9:	5b                   	pop    %ebx
f01039ba:	5d                   	pop    %ebp
f01039bb:	c3                   	ret    

f01039bc <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01039bc:	55                   	push   %ebp
f01039bd:	89 e5                	mov    %esp,%ebp
f01039bf:	56                   	push   %esi
f01039c0:	53                   	push   %ebx
f01039c1:	83 ec 10             	sub    $0x10,%esp
f01039c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01039c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01039cb:	c7 04 24 83 63 10 f0 	movl   $0xf0106383,(%esp)
f01039d2:	e8 ce fd ff ff       	call   f01037a5 <cprintf>
	print_regs(&tf->tf_regs);
f01039d7:	89 1c 24             	mov    %ebx,(%esp)
f01039da:	e8 36 ff ff ff       	call   f0103915 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01039df:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01039e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039e7:	c7 04 24 8b 62 10 f0 	movl   $0xf010628b,(%esp)
f01039ee:	e8 b2 fd ff ff       	call   f01037a5 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01039f3:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01039f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039fb:	c7 04 24 9e 62 10 f0 	movl   $0xf010629e,(%esp)
f0103a02:	e8 9e fd ff ff       	call   f01037a5 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103a07:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103a0a:	83 f8 13             	cmp    $0x13,%eax
f0103a0d:	77 09                	ja     f0103a18 <print_trapframe+0x5c>
		return excnames[trapno];
f0103a0f:	8b 14 85 80 65 10 f0 	mov    -0xfef9a80(,%eax,4),%edx
f0103a16:	eb 10                	jmp    f0103a28 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f0103a18:	83 f8 30             	cmp    $0x30,%eax
f0103a1b:	ba 49 62 10 f0       	mov    $0xf0106249,%edx
f0103a20:	b9 55 62 10 f0       	mov    $0xf0106255,%ecx
f0103a25:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103a28:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a30:	c7 04 24 b1 62 10 f0 	movl   $0xf01062b1,(%esp)
f0103a37:	e8 69 fd ff ff       	call   f01037a5 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103a3c:	3b 1d e0 ea 17 f0    	cmp    0xf017eae0,%ebx
f0103a42:	75 19                	jne    f0103a5d <print_trapframe+0xa1>
f0103a44:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103a48:	75 13                	jne    f0103a5d <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103a4a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a51:	c7 04 24 c3 62 10 f0 	movl   $0xf01062c3,(%esp)
f0103a58:	e8 48 fd ff ff       	call   f01037a5 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103a5d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103a60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a64:	c7 04 24 d2 62 10 f0 	movl   $0xf01062d2,(%esp)
f0103a6b:	e8 35 fd ff ff       	call   f01037a5 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103a70:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103a74:	75 51                	jne    f0103ac7 <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103a76:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103a79:	89 c2                	mov    %eax,%edx
f0103a7b:	83 e2 01             	and    $0x1,%edx
f0103a7e:	ba 64 62 10 f0       	mov    $0xf0106264,%edx
f0103a83:	b9 6f 62 10 f0       	mov    $0xf010626f,%ecx
f0103a88:	0f 45 ca             	cmovne %edx,%ecx
f0103a8b:	89 c2                	mov    %eax,%edx
f0103a8d:	83 e2 02             	and    $0x2,%edx
f0103a90:	ba 7b 62 10 f0       	mov    $0xf010627b,%edx
f0103a95:	be 81 62 10 f0       	mov    $0xf0106281,%esi
f0103a9a:	0f 44 d6             	cmove  %esi,%edx
f0103a9d:	83 e0 04             	and    $0x4,%eax
f0103aa0:	b8 86 62 10 f0       	mov    $0xf0106286,%eax
f0103aa5:	be d4 63 10 f0       	mov    $0xf01063d4,%esi
f0103aaa:	0f 44 c6             	cmove  %esi,%eax
f0103aad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103ab1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ab9:	c7 04 24 e0 62 10 f0 	movl   $0xf01062e0,(%esp)
f0103ac0:	e8 e0 fc ff ff       	call   f01037a5 <cprintf>
f0103ac5:	eb 0c                	jmp    f0103ad3 <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103ac7:	c7 04 24 ea 57 10 f0 	movl   $0xf01057ea,(%esp)
f0103ace:	e8 d2 fc ff ff       	call   f01037a5 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ad3:	8b 43 30             	mov    0x30(%ebx),%eax
f0103ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ada:	c7 04 24 ef 62 10 f0 	movl   $0xf01062ef,(%esp)
f0103ae1:	e8 bf fc ff ff       	call   f01037a5 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ae6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103aea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aee:	c7 04 24 fe 62 10 f0 	movl   $0xf01062fe,(%esp)
f0103af5:	e8 ab fc ff ff       	call   f01037a5 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103afa:	8b 43 38             	mov    0x38(%ebx),%eax
f0103afd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b01:	c7 04 24 11 63 10 f0 	movl   $0xf0106311,(%esp)
f0103b08:	e8 98 fc ff ff       	call   f01037a5 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103b0d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103b11:	74 27                	je     f0103b3a <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103b13:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103b16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b1a:	c7 04 24 20 63 10 f0 	movl   $0xf0106320,(%esp)
f0103b21:	e8 7f fc ff ff       	call   f01037a5 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103b26:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2e:	c7 04 24 2f 63 10 f0 	movl   $0xf010632f,(%esp)
f0103b35:	e8 6b fc ff ff       	call   f01037a5 <cprintf>
	}
}
f0103b3a:	83 c4 10             	add    $0x10,%esp
f0103b3d:	5b                   	pop    %ebx
f0103b3e:	5e                   	pop    %esi
f0103b3f:	5d                   	pop    %ebp
f0103b40:	c3                   	ret    

f0103b41 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103b41:	55                   	push   %ebp
f0103b42:	89 e5                	mov    %esp,%ebp
f0103b44:	53                   	push   %ebx
f0103b45:	83 ec 14             	sub    $0x14,%esp
f0103b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103b4b:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0)
f0103b4e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103b52:	75 1c                	jne    f0103b70 <page_fault_handler+0x2f>
		panic("Kernel page fault!");
f0103b54:	c7 44 24 08 42 63 10 	movl   $0xf0106342,0x8(%esp)
f0103b5b:	f0 
f0103b5c:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
f0103b63:	00 
f0103b64:	c7 04 24 55 63 10 f0 	movl   $0xf0106355,(%esp)
f0103b6b:	e8 b6 c5 ff ff       	call   f0100126 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b70:	8b 53 30             	mov    0x30(%ebx),%edx
f0103b73:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b77:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b7b:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0103b80:	8b 40 48             	mov    0x48(%eax),%eax
f0103b83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b87:	c7 04 24 20 65 10 f0 	movl   $0xf0106520,(%esp)
f0103b8e:	e8 12 fc ff ff       	call   f01037a5 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103b93:	89 1c 24             	mov    %ebx,(%esp)
f0103b96:	e8 21 fe ff ff       	call   f01039bc <print_trapframe>
	env_destroy(curenv);
f0103b9b:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0103ba0:	89 04 24             	mov    %eax,(%esp)
f0103ba3:	e8 ca fa ff ff       	call   f0103672 <env_destroy>
}
f0103ba8:	83 c4 14             	add    $0x14,%esp
f0103bab:	5b                   	pop    %ebx
f0103bac:	5d                   	pop    %ebp
f0103bad:	c3                   	ret    

f0103bae <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103bae:	55                   	push   %ebp
f0103baf:	89 e5                	mov    %esp,%ebp
f0103bb1:	57                   	push   %edi
f0103bb2:	56                   	push   %esi
f0103bb3:	83 ec 20             	sub    $0x20,%esp
f0103bb6:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103bb9:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103bba:	9c                   	pushf  
f0103bbb:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103bbc:	f6 c4 02             	test   $0x2,%ah
f0103bbf:	74 24                	je     f0103be5 <trap+0x37>
f0103bc1:	c7 44 24 0c 61 63 10 	movl   $0xf0106361,0xc(%esp)
f0103bc8:	f0 
f0103bc9:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0103bd0:	f0 
f0103bd1:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
f0103bd8:	00 
f0103bd9:	c7 04 24 55 63 10 f0 	movl   $0xf0106355,(%esp)
f0103be0:	e8 41 c5 ff ff       	call   f0100126 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103be5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103be9:	c7 04 24 7a 63 10 f0 	movl   $0xf010637a,(%esp)
f0103bf0:	e8 b0 fb ff ff       	call   f01037a5 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103bf5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103bf9:	83 e0 03             	and    $0x3,%eax
f0103bfc:	66 83 f8 03          	cmp    $0x3,%ax
f0103c00:	75 3c                	jne    f0103c3e <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f0103c02:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0103c07:	85 c0                	test   %eax,%eax
f0103c09:	75 24                	jne    f0103c2f <trap+0x81>
f0103c0b:	c7 44 24 0c 95 63 10 	movl   $0xf0106395,0xc(%esp)
f0103c12:	f0 
f0103c13:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0103c1a:	f0 
f0103c1b:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f0103c22:	00 
f0103c23:	c7 04 24 55 63 10 f0 	movl   $0xf0106355,(%esp)
f0103c2a:	e8 f7 c4 ff ff       	call   f0100126 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103c2f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c34:	89 c7                	mov    %eax,%edi
f0103c36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103c38:	8b 35 c8 e2 17 f0    	mov    0xf017e2c8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103c3e:	89 35 e0 ea 17 f0    	mov    %esi,0xf017eae0
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f0103c44:	8b 46 28             	mov    0x28(%esi),%eax
f0103c47:	83 f8 0e             	cmp    $0xe,%eax
f0103c4a:	75 19                	jne    f0103c65 <trap+0xb7>
		cprintf("PAGE FAULT\n");
f0103c4c:	c7 04 24 9c 63 10 f0 	movl   $0xf010639c,(%esp)
f0103c53:	e8 4d fb ff ff       	call   f01037a5 <cprintf>
		page_fault_handler(tf);
f0103c58:	89 34 24             	mov    %esi,(%esp)
f0103c5b:	e8 e1 fe ff ff       	call   f0103b41 <page_fault_handler>
f0103c60:	e9 96 00 00 00       	jmp    f0103cfb <trap+0x14d>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0103c65:	83 f8 03             	cmp    $0x3,%eax
f0103c68:	75 16                	jne    f0103c80 <trap+0xd2>
		cprintf("BREAK POINT\n");
f0103c6a:	c7 04 24 a8 63 10 f0 	movl   $0xf01063a8,(%esp)
f0103c71:	e8 2f fb ff ff       	call   f01037a5 <cprintf>
		monitor(tf);
f0103c76:	89 34 24             	mov    %esi,(%esp)
f0103c79:	e8 48 cc ff ff       	call   f01008c6 <monitor>
f0103c7e:	eb 7b                	jmp    f0103cfb <trap+0x14d>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0103c80:	83 f8 30             	cmp    $0x30,%eax
f0103c83:	75 3e                	jne    f0103cc3 <trap+0x115>
		cprintf("SYSTEM CALL\n");
f0103c85:	c7 04 24 b5 63 10 f0 	movl   $0xf01063b5,(%esp)
f0103c8c:	e8 14 fb ff ff       	call   f01037a5 <cprintf>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0103c91:	8b 46 04             	mov    0x4(%esi),%eax
f0103c94:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103c98:	8b 06                	mov    (%esi),%eax
f0103c9a:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103c9e:	8b 46 10             	mov    0x10(%esi),%eax
f0103ca1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ca5:	8b 46 18             	mov    0x18(%esi),%eax
f0103ca8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103cac:	8b 46 14             	mov    0x14(%esi),%eax
f0103caf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cb3:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103cb6:	89 04 24             	mov    %eax,(%esp)
f0103cb9:	e8 e2 00 00 00       	call   f0103da0 <syscall>
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
f0103cbe:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103cc1:	eb 38                	jmp    f0103cfb <trap+0x14d>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103cc3:	89 34 24             	mov    %esi,(%esp)
f0103cc6:	e8 f1 fc ff ff       	call   f01039bc <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103ccb:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103cd0:	75 1c                	jne    f0103cee <trap+0x140>
		panic("unhandled trap in kernel");
f0103cd2:	c7 44 24 08 c2 63 10 	movl   $0xf01063c2,0x8(%esp)
f0103cd9:	f0 
f0103cda:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f0103ce1:	00 
f0103ce2:	c7 04 24 55 63 10 f0 	movl   $0xf0106355,(%esp)
f0103ce9:	e8 38 c4 ff ff       	call   f0100126 <_panic>
	else {
		env_destroy(curenv);
f0103cee:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0103cf3:	89 04 24             	mov    %eax,(%esp)
f0103cf6:	e8 77 f9 ff ff       	call   f0103672 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103cfb:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0103d00:	85 c0                	test   %eax,%eax
f0103d02:	74 06                	je     f0103d0a <trap+0x15c>
f0103d04:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d08:	74 24                	je     f0103d2e <trap+0x180>
f0103d0a:	c7 44 24 0c 44 65 10 	movl   $0xf0106544,0xc(%esp)
f0103d11:	f0 
f0103d12:	c7 44 24 08 f6 54 10 	movl   $0xf01054f6,0x8(%esp)
f0103d19:	f0 
f0103d1a:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f0103d21:	00 
f0103d22:	c7 04 24 55 63 10 f0 	movl   $0xf0106355,(%esp)
f0103d29:	e8 f8 c3 ff ff       	call   f0100126 <_panic>
	env_run(curenv);
f0103d2e:	89 04 24             	mov    %eax,(%esp)
f0103d31:	e8 93 f9 ff ff       	call   f01036c9 <env_run>

f0103d36 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec(th0, 0)
f0103d36:	6a 00                	push   $0x0
f0103d38:	6a 00                	push   $0x0
f0103d3a:	eb 4e                	jmp    f0103d8a <_alltraps>

f0103d3c <th1>:
	noec(th1, 1)
f0103d3c:	6a 00                	push   $0x0
f0103d3e:	6a 01                	push   $0x1
f0103d40:	eb 48                	jmp    f0103d8a <_alltraps>

f0103d42 <th3>:
	zhanwei()
	noec(th3, 3)
f0103d42:	6a 00                	push   $0x0
f0103d44:	6a 03                	push   $0x3
f0103d46:	eb 42                	jmp    f0103d8a <_alltraps>

f0103d48 <th4>:
	noec(th4, 4)
f0103d48:	6a 00                	push   $0x0
f0103d4a:	6a 04                	push   $0x4
f0103d4c:	eb 3c                	jmp    f0103d8a <_alltraps>

f0103d4e <th5>:
	noec(th5, 5)
f0103d4e:	6a 00                	push   $0x0
f0103d50:	6a 05                	push   $0x5
f0103d52:	eb 36                	jmp    f0103d8a <_alltraps>

f0103d54 <th6>:
	noec(th6, 6)
f0103d54:	6a 00                	push   $0x0
f0103d56:	6a 06                	push   $0x6
f0103d58:	eb 30                	jmp    f0103d8a <_alltraps>

f0103d5a <th7>:
	noec(th7, 7)
f0103d5a:	6a 00                	push   $0x0
f0103d5c:	6a 07                	push   $0x7
f0103d5e:	eb 2a                	jmp    f0103d8a <_alltraps>

f0103d60 <th8>:
	ec(th8, 8)
f0103d60:	6a 08                	push   $0x8
f0103d62:	eb 26                	jmp    f0103d8a <_alltraps>

f0103d64 <th9>:
	noec(th9, 9)
f0103d64:	6a 00                	push   $0x0
f0103d66:	6a 09                	push   $0x9
f0103d68:	eb 20                	jmp    f0103d8a <_alltraps>

f0103d6a <th10>:
	ec(th10, 10)
f0103d6a:	6a 0a                	push   $0xa
f0103d6c:	eb 1c                	jmp    f0103d8a <_alltraps>

f0103d6e <th11>:
	ec(th11, 11)
f0103d6e:	6a 0b                	push   $0xb
f0103d70:	eb 18                	jmp    f0103d8a <_alltraps>

f0103d72 <th12>:
	ec(th12, 12)
f0103d72:	6a 0c                	push   $0xc
f0103d74:	eb 14                	jmp    f0103d8a <_alltraps>

f0103d76 <th13>:
	ec(th13, 13)
f0103d76:	6a 0d                	push   $0xd
f0103d78:	eb 10                	jmp    f0103d8a <_alltraps>

f0103d7a <th14>:
	ec(th14, 14)
f0103d7a:	6a 0e                	push   $0xe
f0103d7c:	eb 0c                	jmp    f0103d8a <_alltraps>

f0103d7e <th16>:
	zhanwei()
	noec(th16, 16)
f0103d7e:	6a 00                	push   $0x0
f0103d80:	6a 10                	push   $0x10
f0103d82:	eb 06                	jmp    f0103d8a <_alltraps>

f0103d84 <th48>:
.data
	.space 124
.text
	noec(th48, 48)
f0103d84:	6a 00                	push   $0x0
f0103d86:	6a 30                	push   $0x30
f0103d88:	eb 00                	jmp    f0103d8a <_alltraps>

f0103d8a <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0103d8a:	1e                   	push   %ds
	pushl %es
f0103d8b:	06                   	push   %es
	pushal
f0103d8c:	60                   	pusha  
	pushl $GD_KD
f0103d8d:	6a 10                	push   $0x10
	popl %ds
f0103d8f:	1f                   	pop    %ds
	pushl $GD_KD
f0103d90:	6a 10                	push   $0x10
	popl %es
f0103d92:	07                   	pop    %es
	pushl %esp
f0103d93:	54                   	push   %esp
	call trap
f0103d94:	e8 15 fe ff ff       	call   f0103bae <trap>
f0103d99:	66 90                	xchg   %ax,%ax
f0103d9b:	66 90                	xchg   %ax,%ax
f0103d9d:	66 90                	xchg   %ax,%ax
f0103d9f:	90                   	nop

f0103da0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103da0:	55                   	push   %ebp
f0103da1:	89 e5                	mov    %esp,%ebp
f0103da3:	83 ec 28             	sub    $0x28,%esp
f0103da6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
f0103da9:	83 f8 01             	cmp    $0x1,%eax
f0103dac:	74 7b                	je     f0103e29 <syscall+0x89>
f0103dae:	83 f8 01             	cmp    $0x1,%eax
f0103db1:	72 12                	jb     f0103dc5 <syscall+0x25>
f0103db3:	83 f8 02             	cmp    $0x2,%eax
f0103db6:	74 7a                	je     f0103e32 <syscall+0x92>
f0103db8:	83 f8 03             	cmp    $0x3,%eax
f0103dbb:	74 7f                	je     f0103e3c <syscall+0x9c>
f0103dbd:	8d 76 00             	lea    0x0(%esi),%esi
f0103dc0:	e9 e3 00 00 00       	jmp    f0103ea8 <syscall+0x108>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0103dc5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103dcc:	00 
f0103dcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103dd4:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0103dd9:	8b 40 48             	mov    0x48(%eax),%eax
f0103ddc:	89 04 24             	mov    %eax,(%esp)
f0103ddf:	e8 e5 f2 ff ff       	call   f01030c9 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0103de4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103deb:	00 
f0103dec:	8b 45 10             	mov    0x10(%ebp),%eax
f0103def:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103df3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103df6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103dfd:	89 04 24             	mov    %eax,(%esp)
f0103e00:	e8 d1 f1 ff ff       	call   f0102fd6 <user_mem_assert>
	//user_mem_check(struct Env *env, const void *va, size_t len, int perm)

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103e05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e0c:	8b 45 10             	mov    0x10(%ebp),%eax
f0103e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e13:	c7 04 24 d0 65 10 f0 	movl   $0xf01065d0,(%esp)
f0103e1a:	e8 86 f9 ff ff       	call   f01037a5 <cprintf>
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f0103e1f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e24:	e9 84 00 00 00       	jmp    f0103ead <syscall+0x10d>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103e29:	e8 17 c7 ff ff       	call   f0100545 <cons_getc>
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0103e2e:	66 90                	xchg   %ax,%ax
f0103e30:	eb 7b                	jmp    f0103ead <syscall+0x10d>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103e32:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0103e37:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f0103e3a:	eb 71                	jmp    f0103ead <syscall+0x10d>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103e3c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103e43:	00 
f0103e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e4e:	89 04 24             	mov    %eax,(%esp)
f0103e51:	e8 73 f2 ff ff       	call   f01030c9 <envid2env>
f0103e56:	85 c0                	test   %eax,%eax
f0103e58:	78 47                	js     f0103ea1 <syscall+0x101>
		return r;
	if (e == curenv)
f0103e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e5d:	8b 15 c8 e2 17 f0    	mov    0xf017e2c8,%edx
f0103e63:	39 d0                	cmp    %edx,%eax
f0103e65:	75 15                	jne    f0103e7c <syscall+0xdc>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103e67:	8b 40 48             	mov    0x48(%eax),%eax
f0103e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e6e:	c7 04 24 d5 65 10 f0 	movl   $0xf01065d5,(%esp)
f0103e75:	e8 2b f9 ff ff       	call   f01037a5 <cprintf>
f0103e7a:	eb 1a                	jmp    f0103e96 <syscall+0xf6>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103e7c:	8b 40 48             	mov    0x48(%eax),%eax
f0103e7f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e83:	8b 42 48             	mov    0x48(%edx),%eax
f0103e86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e8a:	c7 04 24 f0 65 10 f0 	movl   $0xf01065f0,(%esp)
f0103e91:	e8 0f f9 ff ff       	call   f01037a5 <cprintf>
	env_destroy(e);
f0103e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e99:	89 04 24             	mov    %eax,(%esp)
f0103e9c:	e8 d1 f7 ff ff       	call   f0103672 <env_destroy>
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f0103ea1:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ea6:	eb 05                	jmp    f0103ead <syscall+0x10d>
			break;
		default:
			ret = -E_INVAL;
f0103ea8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
f0103ead:	c9                   	leave  
f0103eae:	c3                   	ret    

f0103eaf <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103eaf:	55                   	push   %ebp
f0103eb0:	89 e5                	mov    %esp,%ebp
f0103eb2:	57                   	push   %edi
f0103eb3:	56                   	push   %esi
f0103eb4:	53                   	push   %ebx
f0103eb5:	83 ec 14             	sub    $0x14,%esp
f0103eb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ebb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103ebe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103ec1:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103ec4:	8b 1a                	mov    (%edx),%ebx
f0103ec6:	8b 01                	mov    (%ecx),%eax
f0103ec8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103ecb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103ed2:	e9 88 00 00 00       	jmp    f0103f5f <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0103ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103eda:	01 d8                	add    %ebx,%eax
f0103edc:	89 c7                	mov    %eax,%edi
f0103ede:	c1 ef 1f             	shr    $0x1f,%edi
f0103ee1:	01 c7                	add    %eax,%edi
f0103ee3:	d1 ff                	sar    %edi
f0103ee5:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103ee8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103eeb:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103eee:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ef0:	eb 03                	jmp    f0103ef5 <stab_binsearch+0x46>
			m--;
f0103ef2:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ef5:	39 c3                	cmp    %eax,%ebx
f0103ef7:	7f 1f                	jg     f0103f18 <stab_binsearch+0x69>
f0103ef9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103efd:	83 ea 0c             	sub    $0xc,%edx
f0103f00:	39 f1                	cmp    %esi,%ecx
f0103f02:	75 ee                	jne    f0103ef2 <stab_binsearch+0x43>
f0103f04:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103f07:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f0a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103f0d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103f11:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103f14:	76 18                	jbe    f0103f2e <stab_binsearch+0x7f>
f0103f16:	eb 05                	jmp    f0103f1d <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103f18:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103f1b:	eb 42                	jmp    f0103f5f <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103f1d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103f20:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103f22:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f25:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103f2c:	eb 31                	jmp    f0103f5f <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103f2e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103f31:	73 17                	jae    f0103f4a <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103f33:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103f36:	83 e8 01             	sub    $0x1,%eax
f0103f39:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f3c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103f3f:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f41:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103f48:	eb 15                	jmp    f0103f5f <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103f4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f4d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103f50:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0103f52:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103f56:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f58:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103f5f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103f62:	0f 8e 6f ff ff ff    	jle    f0103ed7 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103f68:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103f6c:	75 0f                	jne    f0103f7d <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0103f6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103f71:	8b 00                	mov    (%eax),%eax
f0103f73:	83 e8 01             	sub    $0x1,%eax
f0103f76:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103f79:	89 07                	mov    %eax,(%edi)
f0103f7b:	eb 2c                	jmp    f0103fa9 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f80:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103f82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f85:	8b 0f                	mov    (%edi),%ecx
f0103f87:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f8a:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103f8d:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f90:	eb 03                	jmp    f0103f95 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103f92:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f95:	39 c8                	cmp    %ecx,%eax
f0103f97:	7e 0b                	jle    f0103fa4 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0103f99:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0103f9d:	83 ea 0c             	sub    $0xc,%edx
f0103fa0:	39 f3                	cmp    %esi,%ebx
f0103fa2:	75 ee                	jne    f0103f92 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103fa4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103fa7:	89 07                	mov    %eax,(%edi)
	}
}
f0103fa9:	83 c4 14             	add    $0x14,%esp
f0103fac:	5b                   	pop    %ebx
f0103fad:	5e                   	pop    %esi
f0103fae:	5f                   	pop    %edi
f0103faf:	5d                   	pop    %ebp
f0103fb0:	c3                   	ret    

f0103fb1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103fb1:	55                   	push   %ebp
f0103fb2:	89 e5                	mov    %esp,%ebp
f0103fb4:	57                   	push   %edi
f0103fb5:	56                   	push   %esi
f0103fb6:	53                   	push   %ebx
f0103fb7:	83 ec 4c             	sub    $0x4c,%esp
f0103fba:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fbd:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103fc0:	c7 07 08 66 10 f0    	movl   $0xf0106608,(%edi)
	info->eip_line = 0;
f0103fc6:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0103fcd:	c7 47 08 08 66 10 f0 	movl   $0xf0106608,0x8(%edi)
	info->eip_fn_namelen = 9;
f0103fd4:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0103fdb:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0103fde:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103fe5:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103feb:	0f 87 a5 00 00 00    	ja     f0104096 <debuginfo_eip+0xe5>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0103ff1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103ff8:	00 
f0103ff9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0104000:	00 
f0104001:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0104008:	00 
f0104009:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f010400e:	89 04 24             	mov    %eax,(%esp)
f0104011:	e8 02 ef ff ff       	call   f0102f18 <user_mem_check>
f0104016:	85 c0                	test   %eax,%eax
f0104018:	0f 85 36 02 00 00    	jne    f0104254 <debuginfo_eip+0x2a3>
			return -1;

		stabs = usd->stabs;
f010401e:	a1 00 00 20 00       	mov    0x200000,%eax
f0104023:	89 c1                	mov    %eax,%ecx
f0104025:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104028:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010402e:	a1 08 00 20 00       	mov    0x200008,%eax
f0104033:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104036:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010403c:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010403f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104046:	00 
f0104047:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f010404e:	00 
f010404f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104053:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0104058:	89 04 24             	mov    %eax,(%esp)
f010405b:	e8 b8 ee ff ff       	call   f0102f18 <user_mem_check>
f0104060:	85 c0                	test   %eax,%eax
f0104062:	0f 85 f3 01 00 00    	jne    f010425b <debuginfo_eip+0x2aa>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104068:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010406f:	00 
f0104070:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104073:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104076:	29 ca                	sub    %ecx,%edx
f0104078:	89 54 24 08          	mov    %edx,0x8(%esp)
f010407c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104080:	a1 c8 e2 17 f0       	mov    0xf017e2c8,%eax
f0104085:	89 04 24             	mov    %eax,(%esp)
f0104088:	e8 8b ee ff ff       	call   f0102f18 <user_mem_check>
f010408d:	85 c0                	test   %eax,%eax
f010408f:	74 1f                	je     f01040b0 <debuginfo_eip+0xff>
f0104091:	e9 cc 01 00 00       	jmp    f0104262 <debuginfo_eip+0x2b1>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104096:	c7 45 bc 47 10 11 f0 	movl   $0xf0111047,-0x44(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010409d:	c7 45 c0 d9 e5 10 f0 	movl   $0xf010e5d9,-0x40(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01040a4:	be d8 e5 10 f0       	mov    $0xf010e5d8,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01040a9:	c7 45 c4 20 68 10 f0 	movl   $0xf0106820,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01040b0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01040b3:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01040b6:	0f 83 ad 01 00 00    	jae    f0104269 <debuginfo_eip+0x2b8>
f01040bc:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01040c0:	0f 85 aa 01 00 00    	jne    f0104270 <debuginfo_eip+0x2bf>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01040c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01040cd:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f01040d0:	c1 fe 02             	sar    $0x2,%esi
f01040d3:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01040d9:	83 e8 01             	sub    $0x1,%eax
f01040dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01040df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01040e3:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01040ea:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01040ed:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01040f0:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01040f3:	89 f0                	mov    %esi,%eax
f01040f5:	e8 b5 fd ff ff       	call   f0103eaf <stab_binsearch>
	if (lfile == 0)
f01040fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040fd:	85 c0                	test   %eax,%eax
f01040ff:	0f 84 72 01 00 00    	je     f0104277 <debuginfo_eip+0x2c6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104105:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104108:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010410b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010410e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104112:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104119:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010411c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010411f:	89 f0                	mov    %esi,%eax
f0104121:	e8 89 fd ff ff       	call   f0103eaf <stab_binsearch>

	if (lfun <= rfun) {
f0104126:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104129:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010412c:	39 f0                	cmp    %esi,%eax
f010412e:	7f 32                	jg     f0104162 <debuginfo_eip+0x1b1>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104130:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104133:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104136:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0104139:	8b 0a                	mov    (%edx),%ecx
f010413b:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f010413e:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104141:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f0104144:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f0104147:	73 09                	jae    f0104152 <debuginfo_eip+0x1a1>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104149:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010414c:	03 4d c0             	add    -0x40(%ebp),%ecx
f010414f:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104152:	8b 52 08             	mov    0x8(%edx),%edx
f0104155:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0104158:	29 d3                	sub    %edx,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f010415a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010415d:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0104160:	eb 0f                	jmp    f0104171 <debuginfo_eip+0x1c0>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104162:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0104165:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104168:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010416b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010416e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104171:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104178:	00 
f0104179:	8b 47 08             	mov    0x8(%edi),%eax
f010417c:	89 04 24             	mov    %eax,(%esp)
f010417f:	e8 27 09 00 00       	call   f0104aab <strfind>
f0104184:	2b 47 08             	sub    0x8(%edi),%eax
f0104187:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010418a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010418e:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0104195:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104198:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010419b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010419e:	89 f0                	mov    %esi,%eax
f01041a0:	e8 0a fd ff ff       	call   f0103eaf <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01041a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01041a8:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f01041ab:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f01041ae:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01041b3:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01041b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041b9:	89 c3                	mov    %eax,%ebx
f01041bb:	89 d0                	mov    %edx,%eax
f01041bd:	01 ca                	add    %ecx,%edx
f01041bf:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01041c2:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01041c5:	89 df                	mov    %ebx,%edi
f01041c7:	eb 06                	jmp    f01041cf <debuginfo_eip+0x21e>
f01041c9:	83 e8 01             	sub    $0x1,%eax
f01041cc:	83 ea 0c             	sub    $0xc,%edx
f01041cf:	89 c6                	mov    %eax,%esi
f01041d1:	39 c7                	cmp    %eax,%edi
f01041d3:	7f 3c                	jg     f0104211 <debuginfo_eip+0x260>
	       && stabs[lline].n_type != N_SOL
f01041d5:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01041d9:	80 f9 84             	cmp    $0x84,%cl
f01041dc:	75 08                	jne    f01041e6 <debuginfo_eip+0x235>
f01041de:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01041e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01041e4:	eb 11                	jmp    f01041f7 <debuginfo_eip+0x246>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01041e6:	80 f9 64             	cmp    $0x64,%cl
f01041e9:	75 de                	jne    f01041c9 <debuginfo_eip+0x218>
f01041eb:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01041ef:	74 d8                	je     f01041c9 <debuginfo_eip+0x218>
f01041f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01041f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01041f7:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01041fa:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01041fd:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f0104200:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104203:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104206:	39 d0                	cmp    %edx,%eax
f0104208:	73 0a                	jae    f0104214 <debuginfo_eip+0x263>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010420a:	03 45 c0             	add    -0x40(%ebp),%eax
f010420d:	89 07                	mov    %eax,(%edi)
f010420f:	eb 03                	jmp    f0104214 <debuginfo_eip+0x263>
f0104211:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104214:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104217:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010421a:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010421f:	39 da                	cmp    %ebx,%edx
f0104221:	7d 60                	jge    f0104283 <debuginfo_eip+0x2d2>
		for (lline = lfun + 1;
f0104223:	83 c2 01             	add    $0x1,%edx
f0104226:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104229:	89 d0                	mov    %edx,%eax
f010422b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010422e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104231:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104234:	eb 04                	jmp    f010423a <debuginfo_eip+0x289>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104236:	83 47 14 01          	addl   $0x1,0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010423a:	39 c3                	cmp    %eax,%ebx
f010423c:	7e 40                	jle    f010427e <debuginfo_eip+0x2cd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010423e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104242:	83 c0 01             	add    $0x1,%eax
f0104245:	83 c2 0c             	add    $0xc,%edx
f0104248:	80 f9 a0             	cmp    $0xa0,%cl
f010424b:	74 e9                	je     f0104236 <debuginfo_eip+0x285>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010424d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104252:	eb 2f                	jmp    f0104283 <debuginfo_eip+0x2d2>
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104254:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104259:	eb 28                	jmp    f0104283 <debuginfo_eip+0x2d2>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f010425b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104260:	eb 21                	jmp    f0104283 <debuginfo_eip+0x2d2>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0104262:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104267:	eb 1a                	jmp    f0104283 <debuginfo_eip+0x2d2>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010426e:	eb 13                	jmp    f0104283 <debuginfo_eip+0x2d2>
f0104270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104275:	eb 0c                	jmp    f0104283 <debuginfo_eip+0x2d2>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010427c:	eb 05                	jmp    f0104283 <debuginfo_eip+0x2d2>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010427e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104283:	83 c4 4c             	add    $0x4c,%esp
f0104286:	5b                   	pop    %ebx
f0104287:	5e                   	pop    %esi
f0104288:	5f                   	pop    %edi
f0104289:	5d                   	pop    %ebp
f010428a:	c3                   	ret    
f010428b:	66 90                	xchg   %ax,%ax
f010428d:	66 90                	xchg   %ax,%ax
f010428f:	90                   	nop

f0104290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104290:	55                   	push   %ebp
f0104291:	89 e5                	mov    %esp,%ebp
f0104293:	57                   	push   %edi
f0104294:	56                   	push   %esi
f0104295:	53                   	push   %ebx
f0104296:	83 ec 3c             	sub    $0x3c,%esp
f0104299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010429c:	89 d7                	mov    %edx,%edi
f010429e:	8b 45 08             	mov    0x8(%ebp),%eax
f01042a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01042a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042a7:	89 c3                	mov    %eax,%ebx
f01042a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01042ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01042af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01042b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01042b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01042bd:	39 d9                	cmp    %ebx,%ecx
f01042bf:	72 05                	jb     f01042c6 <printnum+0x36>
f01042c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01042c4:	77 69                	ja     f010432f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01042c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01042c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01042cd:	83 ee 01             	sub    $0x1,%esi
f01042d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01042d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042d8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01042dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01042e0:	89 c3                	mov    %eax,%ebx
f01042e2:	89 d6                	mov    %edx,%esi
f01042e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01042e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01042ea:	89 54 24 08          	mov    %edx,0x8(%esp)
f01042ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01042f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042f5:	89 04 24             	mov    %eax,(%esp)
f01042f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01042fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042ff:	e8 cc 09 00 00       	call   f0104cd0 <__udivdi3>
f0104304:	89 d9                	mov    %ebx,%ecx
f0104306:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010430a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010430e:	89 04 24             	mov    %eax,(%esp)
f0104311:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104315:	89 fa                	mov    %edi,%edx
f0104317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010431a:	e8 71 ff ff ff       	call   f0104290 <printnum>
f010431f:	eb 1b                	jmp    f010433c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104321:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104325:	8b 45 18             	mov    0x18(%ebp),%eax
f0104328:	89 04 24             	mov    %eax,(%esp)
f010432b:	ff d3                	call   *%ebx
f010432d:	eb 03                	jmp    f0104332 <printnum+0xa2>
f010432f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104332:	83 ee 01             	sub    $0x1,%esi
f0104335:	85 f6                	test   %esi,%esi
f0104337:	7f e8                	jg     f0104321 <printnum+0x91>
f0104339:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010433c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104340:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104344:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104347:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010434a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010434e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104352:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104355:	89 04 24             	mov    %eax,(%esp)
f0104358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010435b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010435f:	e8 9c 0a 00 00       	call   f0104e00 <__umoddi3>
f0104364:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104368:	0f be 80 12 66 10 f0 	movsbl -0xfef99ee(%eax),%eax
f010436f:	89 04 24             	mov    %eax,(%esp)
f0104372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104375:	ff d0                	call   *%eax
}
f0104377:	83 c4 3c             	add    $0x3c,%esp
f010437a:	5b                   	pop    %ebx
f010437b:	5e                   	pop    %esi
f010437c:	5f                   	pop    %edi
f010437d:	5d                   	pop    %ebp
f010437e:	c3                   	ret    

f010437f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010437f:	55                   	push   %ebp
f0104380:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104382:	83 fa 01             	cmp    $0x1,%edx
f0104385:	7e 0e                	jle    f0104395 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104387:	8b 10                	mov    (%eax),%edx
f0104389:	8d 4a 08             	lea    0x8(%edx),%ecx
f010438c:	89 08                	mov    %ecx,(%eax)
f010438e:	8b 02                	mov    (%edx),%eax
f0104390:	8b 52 04             	mov    0x4(%edx),%edx
f0104393:	eb 22                	jmp    f01043b7 <getuint+0x38>
	else if (lflag)
f0104395:	85 d2                	test   %edx,%edx
f0104397:	74 10                	je     f01043a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104399:	8b 10                	mov    (%eax),%edx
f010439b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010439e:	89 08                	mov    %ecx,(%eax)
f01043a0:	8b 02                	mov    (%edx),%eax
f01043a2:	ba 00 00 00 00       	mov    $0x0,%edx
f01043a7:	eb 0e                	jmp    f01043b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01043a9:	8b 10                	mov    (%eax),%edx
f01043ab:	8d 4a 04             	lea    0x4(%edx),%ecx
f01043ae:	89 08                	mov    %ecx,(%eax)
f01043b0:	8b 02                	mov    (%edx),%eax
f01043b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01043b7:	5d                   	pop    %ebp
f01043b8:	c3                   	ret    

f01043b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01043b9:	55                   	push   %ebp
f01043ba:	89 e5                	mov    %esp,%ebp
f01043bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01043bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01043c3:	8b 10                	mov    (%eax),%edx
f01043c5:	3b 50 04             	cmp    0x4(%eax),%edx
f01043c8:	73 0a                	jae    f01043d4 <sprintputch+0x1b>
		*b->buf++ = ch;
f01043ca:	8d 4a 01             	lea    0x1(%edx),%ecx
f01043cd:	89 08                	mov    %ecx,(%eax)
f01043cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01043d2:	88 02                	mov    %al,(%edx)
}
f01043d4:	5d                   	pop    %ebp
f01043d5:	c3                   	ret    

f01043d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01043d6:	55                   	push   %ebp
f01043d7:	89 e5                	mov    %esp,%ebp
f01043d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01043dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01043df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043e3:	8b 45 10             	mov    0x10(%ebp),%eax
f01043e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01043f4:	89 04 24             	mov    %eax,(%esp)
f01043f7:	e8 02 00 00 00       	call   f01043fe <vprintfmt>
	va_end(ap);
}
f01043fc:	c9                   	leave  
f01043fd:	c3                   	ret    

f01043fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01043fe:	55                   	push   %ebp
f01043ff:	89 e5                	mov    %esp,%ebp
f0104401:	57                   	push   %edi
f0104402:	56                   	push   %esi
f0104403:	53                   	push   %ebx
f0104404:	83 ec 3c             	sub    $0x3c,%esp
f0104407:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
f010440a:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
f0104411:	eb 17                	jmp    f010442a <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104413:	85 c0                	test   %eax,%eax
f0104415:	0f 84 ca 03 00 00    	je     f01047e5 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
f010441b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010441e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104422:	89 04 24             	mov    %eax,(%esp)
f0104425:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104428:	89 fb                	mov    %edi,%ebx
f010442a:	8d 7b 01             	lea    0x1(%ebx),%edi
f010442d:	0f b6 03             	movzbl (%ebx),%eax
f0104430:	83 f8 25             	cmp    $0x25,%eax
f0104433:	75 de                	jne    f0104413 <vprintfmt+0x15>
f0104435:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0104439:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104440:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0104445:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010444c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104451:	eb 18                	jmp    f010446b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104453:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104455:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0104459:	eb 10                	jmp    f010446b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010445b:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010445d:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0104461:	eb 08                	jmp    f010446b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104463:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104466:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010446b:	8d 5f 01             	lea    0x1(%edi),%ebx
f010446e:	0f b6 07             	movzbl (%edi),%eax
f0104471:	0f b6 c8             	movzbl %al,%ecx
f0104474:	83 e8 23             	sub    $0x23,%eax
f0104477:	3c 55                	cmp    $0x55,%al
f0104479:	0f 87 41 03 00 00    	ja     f01047c0 <vprintfmt+0x3c2>
f010447f:	0f b6 c0             	movzbl %al,%eax
f0104482:	ff 24 85 9c 66 10 f0 	jmp    *-0xfef9964(,%eax,4)
f0104489:	89 df                	mov    %ebx,%edi
f010448b:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104490:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f0104493:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
f0104497:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010449a:	8d 41 d0             	lea    -0x30(%ecx),%eax
f010449d:	83 f8 09             	cmp    $0x9,%eax
f01044a0:	77 33                	ja     f01044d5 <vprintfmt+0xd7>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01044a2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01044a5:	eb e9                	jmp    f0104490 <vprintfmt+0x92>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01044a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01044aa:	8d 48 04             	lea    0x4(%eax),%ecx
f01044ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01044b0:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044b2:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01044b4:	eb 1f                	jmp    f01044d5 <vprintfmt+0xd7>
f01044b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01044b9:	85 c9                	test   %ecx,%ecx
f01044bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01044c0:	0f 49 c1             	cmovns %ecx,%eax
f01044c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044c6:	89 df                	mov    %ebx,%edi
f01044c8:	eb a1                	jmp    f010446b <vprintfmt+0x6d>
f01044ca:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01044cc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
f01044d3:	eb 96                	jmp    f010446b <vprintfmt+0x6d>

		process_precision:
			if (width < 0)
f01044d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01044d9:	79 90                	jns    f010446b <vprintfmt+0x6d>
f01044db:	eb 86                	jmp    f0104463 <vprintfmt+0x65>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01044dd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044e0:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01044e2:	eb 87                	jmp    f010446b <vprintfmt+0x6d>

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
f01044e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01044e7:	8d 50 04             	lea    0x4(%eax),%edx
f01044ea:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
f01044ed:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044f0:	89 74 24 04          	mov    %esi,0x4(%esp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
f01044f4:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01044f7:	0b 30                	or     (%eax),%esi
			putch(ch, putdat);
f01044f9:	89 34 24             	mov    %esi,(%esp)
f01044fc:	ff 55 08             	call   *0x8(%ebp)
                  	color=0x0700;
f01044ff:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
			break;
f0104506:	e9 1f ff ff ff       	jmp    f010442a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010450b:	89 df                	mov    %ebx,%edi
			ch=va_arg(ap,int)|color;
			putch(ch, putdat);
                  	color=0x0700;
			break;
		case 'B':
			color=0x0100;
f010450d:	c7 45 d8 00 01 00 00 	movl   $0x100,-0x28(%ebp)
			goto reswitch;
f0104514:	e9 52 ff ff ff       	jmp    f010446b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104519:	89 df                	mov    %ebx,%edi
			break;
		case 'B':
			color=0x0100;
			goto reswitch;
		case 'R':
			color=0x0400;
f010451b:	c7 45 d8 00 04 00 00 	movl   $0x400,-0x28(%ebp)
			goto reswitch;
f0104522:	e9 44 ff ff ff       	jmp    f010446b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104527:	89 df                	mov    %ebx,%edi
			goto reswitch;
		case 'R':
			color=0x0400;
			goto reswitch;
		case 'G':
			color=0x0200;
f0104529:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
			goto reswitch;
f0104530:	e9 36 ff ff ff       	jmp    f010446b <vprintfmt+0x6d>
		// error message
		case 'e':
			err = va_arg(ap, int);
f0104535:	8b 45 14             	mov    0x14(%ebp),%eax
f0104538:	8d 50 04             	lea    0x4(%eax),%edx
f010453b:	89 55 14             	mov    %edx,0x14(%ebp)
f010453e:	8b 00                	mov    (%eax),%eax
f0104540:	99                   	cltd   
f0104541:	31 d0                	xor    %edx,%eax
f0104543:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104545:	83 f8 06             	cmp    $0x6,%eax
f0104548:	7f 0b                	jg     f0104555 <vprintfmt+0x157>
f010454a:	8b 14 85 f4 67 10 f0 	mov    -0xfef980c(,%eax,4),%edx
f0104551:	85 d2                	test   %edx,%edx
f0104553:	75 23                	jne    f0104578 <vprintfmt+0x17a>
				printfmt(putch, putdat, "error %d", err);
f0104555:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104559:	c7 44 24 08 2a 66 10 	movl   $0xf010662a,0x8(%esp)
f0104560:	f0 
f0104561:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104564:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104568:	8b 45 08             	mov    0x8(%ebp),%eax
f010456b:	89 04 24             	mov    %eax,(%esp)
f010456e:	e8 63 fe ff ff       	call   f01043d6 <printfmt>
f0104573:	e9 b2 fe ff ff       	jmp    f010442a <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
f0104578:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010457c:	c7 44 24 08 08 55 10 	movl   $0xf0105508,0x8(%esp)
f0104583:	f0 
f0104584:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104587:	89 44 24 04          	mov    %eax,0x4(%esp)
f010458b:	8b 45 08             	mov    0x8(%ebp),%eax
f010458e:	89 04 24             	mov    %eax,(%esp)
f0104591:	e8 40 fe ff ff       	call   f01043d6 <printfmt>
f0104596:	e9 8f fe ff ff       	jmp    f010442a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010459b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010459e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01045a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01045a4:	8d 50 04             	lea    0x4(%eax),%edx
f01045a7:	89 55 14             	mov    %edx,0x14(%ebp)
f01045aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01045ac:	85 ff                	test   %edi,%edi
f01045ae:	b8 23 66 10 f0       	mov    $0xf0106623,%eax
f01045b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01045b6:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01045ba:	0f 84 96 00 00 00    	je     f0104656 <vprintfmt+0x258>
f01045c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01045c4:	0f 8e 94 00 00 00    	jle    f010465e <vprintfmt+0x260>
				for (width -= strnlen(p, precision); width > 0; width--)
f01045ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01045ce:	89 3c 24             	mov    %edi,(%esp)
f01045d1:	e8 82 03 00 00       	call   f0104958 <strnlen>
f01045d6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01045d9:	29 c1                	sub    %eax,%ecx
f01045db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
					putch(padc, putdat);
f01045de:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f01045e2:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01045e5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01045e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01045eb:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01045ee:	89 cb                	mov    %ecx,%ebx
f01045f0:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01045f2:	eb 0f                	jmp    f0104603 <vprintfmt+0x205>
					putch(padc, putdat);
f01045f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045fb:	89 3c 24             	mov    %edi,(%esp)
f01045fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104600:	83 eb 01             	sub    $0x1,%ebx
f0104603:	85 db                	test   %ebx,%ebx
f0104605:	7f ed                	jg     f01045f4 <vprintfmt+0x1f6>
f0104607:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010460a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010460d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104610:	85 d2                	test   %edx,%edx
f0104612:	b8 00 00 00 00       	mov    $0x0,%eax
f0104617:	0f 49 c2             	cmovns %edx,%eax
f010461a:	29 c2                	sub    %eax,%edx
f010461c:	89 d3                	mov    %edx,%ebx
f010461e:	eb 44                	jmp    f0104664 <vprintfmt+0x266>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104620:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104624:	74 1e                	je     f0104644 <vprintfmt+0x246>
f0104626:	0f be d2             	movsbl %dl,%edx
f0104629:	83 ea 20             	sub    $0x20,%edx
f010462c:	83 fa 5e             	cmp    $0x5e,%edx
f010462f:	76 13                	jbe    f0104644 <vprintfmt+0x246>
					putch('?', putdat);
f0104631:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104634:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104638:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010463f:	ff 55 08             	call   *0x8(%ebp)
f0104642:	eb 0d                	jmp    f0104651 <vprintfmt+0x253>
				else
					putch(ch, putdat);
f0104644:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104647:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010464b:	89 04 24             	mov    %eax,(%esp)
f010464e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104651:	83 eb 01             	sub    $0x1,%ebx
f0104654:	eb 0e                	jmp    f0104664 <vprintfmt+0x266>
f0104656:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104659:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010465c:	eb 06                	jmp    f0104664 <vprintfmt+0x266>
f010465e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104661:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104664:	83 c7 01             	add    $0x1,%edi
f0104667:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f010466b:	0f be c2             	movsbl %dl,%eax
f010466e:	85 c0                	test   %eax,%eax
f0104670:	74 27                	je     f0104699 <vprintfmt+0x29b>
f0104672:	85 f6                	test   %esi,%esi
f0104674:	78 aa                	js     f0104620 <vprintfmt+0x222>
f0104676:	83 ee 01             	sub    $0x1,%esi
f0104679:	79 a5                	jns    f0104620 <vprintfmt+0x222>
f010467b:	89 d8                	mov    %ebx,%eax
f010467d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104680:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104683:	89 c3                	mov    %eax,%ebx
f0104685:	eb 18                	jmp    f010469f <vprintfmt+0x2a1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104687:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010468b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104692:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104694:	83 eb 01             	sub    $0x1,%ebx
f0104697:	eb 06                	jmp    f010469f <vprintfmt+0x2a1>
f0104699:	8b 75 08             	mov    0x8(%ebp),%esi
f010469c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010469f:	85 db                	test   %ebx,%ebx
f01046a1:	7f e4                	jg     f0104687 <vprintfmt+0x289>
f01046a3:	89 75 08             	mov    %esi,0x8(%ebp)
f01046a6:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01046a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01046ac:	e9 79 fd ff ff       	jmp    f010442a <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01046b1:	83 fa 01             	cmp    $0x1,%edx
f01046b4:	7e 10                	jle    f01046c6 <vprintfmt+0x2c8>
		return va_arg(*ap, long long);
f01046b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01046b9:	8d 50 08             	lea    0x8(%eax),%edx
f01046bc:	89 55 14             	mov    %edx,0x14(%ebp)
f01046bf:	8b 30                	mov    (%eax),%esi
f01046c1:	8b 78 04             	mov    0x4(%eax),%edi
f01046c4:	eb 26                	jmp    f01046ec <vprintfmt+0x2ee>
	else if (lflag)
f01046c6:	85 d2                	test   %edx,%edx
f01046c8:	74 12                	je     f01046dc <vprintfmt+0x2de>
		return va_arg(*ap, long);
f01046ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01046cd:	8d 50 04             	lea    0x4(%eax),%edx
f01046d0:	89 55 14             	mov    %edx,0x14(%ebp)
f01046d3:	8b 30                	mov    (%eax),%esi
f01046d5:	89 f7                	mov    %esi,%edi
f01046d7:	c1 ff 1f             	sar    $0x1f,%edi
f01046da:	eb 10                	jmp    f01046ec <vprintfmt+0x2ee>
	else
		return va_arg(*ap, int);
f01046dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01046df:	8d 50 04             	lea    0x4(%eax),%edx
f01046e2:	89 55 14             	mov    %edx,0x14(%ebp)
f01046e5:	8b 30                	mov    (%eax),%esi
f01046e7:	89 f7                	mov    %esi,%edi
f01046e9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01046ec:	89 f0                	mov    %esi,%eax
f01046ee:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01046f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01046f5:	85 ff                	test   %edi,%edi
f01046f7:	0f 89 87 00 00 00    	jns    f0104784 <vprintfmt+0x386>
				putch('-', putdat);
f01046fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104700:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104704:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010470b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010470e:	89 f0                	mov    %esi,%eax
f0104710:	89 fa                	mov    %edi,%edx
f0104712:	f7 d8                	neg    %eax
f0104714:	83 d2 00             	adc    $0x0,%edx
f0104717:	f7 da                	neg    %edx
			}
			base = 10;
f0104719:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010471e:	eb 64                	jmp    f0104784 <vprintfmt+0x386>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104720:	8d 45 14             	lea    0x14(%ebp),%eax
f0104723:	e8 57 fc ff ff       	call   f010437f <getuint>
			base = 10;
f0104728:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010472d:	eb 55                	jmp    f0104784 <vprintfmt+0x386>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010472f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104732:	e8 48 fc ff ff       	call   f010437f <getuint>
			base=8;
f0104737:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010473c:	eb 46                	jmp    f0104784 <vprintfmt+0x386>

		// pointer
		case 'p':
			putch('0', putdat);
f010473e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104741:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104745:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010474c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010474f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104752:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104756:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010475d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104760:	8b 45 14             	mov    0x14(%ebp),%eax
f0104763:	8d 50 04             	lea    0x4(%eax),%edx
f0104766:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104769:	8b 00                	mov    (%eax),%eax
f010476b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104770:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104775:	eb 0d                	jmp    f0104784 <vprintfmt+0x386>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104777:	8d 45 14             	lea    0x14(%ebp),%eax
f010477a:	e8 00 fc ff ff       	call   f010437f <getuint>
			base = 16;
f010477f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104784:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
f0104788:	89 74 24 10          	mov    %esi,0x10(%esp)
f010478c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010478f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104793:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104797:	89 04 24             	mov    %eax,(%esp)
f010479a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010479e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01047a4:	e8 e7 fa ff ff       	call   f0104290 <printnum>
			break;
f01047a9:	e9 7c fc ff ff       	jmp    f010442a <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01047ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047b5:	89 0c 24             	mov    %ecx,(%esp)
f01047b8:	ff 55 08             	call   *0x8(%ebp)
			break;
f01047bb:	e9 6a fc ff ff       	jmp    f010442a <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01047c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047c7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01047ce:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01047d1:	89 fb                	mov    %edi,%ebx
f01047d3:	eb 03                	jmp    f01047d8 <vprintfmt+0x3da>
f01047d5:	83 eb 01             	sub    $0x1,%ebx
f01047d8:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01047dc:	75 f7                	jne    f01047d5 <vprintfmt+0x3d7>
f01047de:	66 90                	xchg   %ax,%ax
f01047e0:	e9 45 fc ff ff       	jmp    f010442a <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
f01047e5:	83 c4 3c             	add    $0x3c,%esp
f01047e8:	5b                   	pop    %ebx
f01047e9:	5e                   	pop    %esi
f01047ea:	5f                   	pop    %edi
f01047eb:	5d                   	pop    %ebp
f01047ec:	c3                   	ret    

f01047ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01047ed:	55                   	push   %ebp
f01047ee:	89 e5                	mov    %esp,%ebp
f01047f0:	83 ec 28             	sub    $0x28,%esp
f01047f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01047f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01047f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104800:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104803:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010480a:	85 c0                	test   %eax,%eax
f010480c:	74 30                	je     f010483e <vsnprintf+0x51>
f010480e:	85 d2                	test   %edx,%edx
f0104810:	7e 2c                	jle    f010483e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104812:	8b 45 14             	mov    0x14(%ebp),%eax
f0104815:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104819:	8b 45 10             	mov    0x10(%ebp),%eax
f010481c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104820:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104823:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104827:	c7 04 24 b9 43 10 f0 	movl   $0xf01043b9,(%esp)
f010482e:	e8 cb fb ff ff       	call   f01043fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104833:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104836:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104839:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010483c:	eb 05                	jmp    f0104843 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010483e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104843:	c9                   	leave  
f0104844:	c3                   	ret    

f0104845 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104845:	55                   	push   %ebp
f0104846:	89 e5                	mov    %esp,%ebp
f0104848:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010484b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010484e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104852:	8b 45 10             	mov    0x10(%ebp),%eax
f0104855:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104859:	8b 45 0c             	mov    0xc(%ebp),%eax
f010485c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104860:	8b 45 08             	mov    0x8(%ebp),%eax
f0104863:	89 04 24             	mov    %eax,(%esp)
f0104866:	e8 82 ff ff ff       	call   f01047ed <vsnprintf>
	va_end(ap);

	return rc;
}
f010486b:	c9                   	leave  
f010486c:	c3                   	ret    
f010486d:	66 90                	xchg   %ax,%ax
f010486f:	90                   	nop

f0104870 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104870:	55                   	push   %ebp
f0104871:	89 e5                	mov    %esp,%ebp
f0104873:	57                   	push   %edi
f0104874:	56                   	push   %esi
f0104875:	53                   	push   %ebx
f0104876:	83 ec 1c             	sub    $0x1c,%esp
f0104879:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010487c:	85 c0                	test   %eax,%eax
f010487e:	74 10                	je     f0104890 <readline+0x20>
		cprintf("%s", prompt);
f0104880:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104884:	c7 04 24 08 55 10 f0 	movl   $0xf0105508,(%esp)
f010488b:	e8 15 ef ff ff       	call   f01037a5 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104890:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104897:	e8 06 be ff ff       	call   f01006a2 <iscons>
f010489c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010489e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01048a3:	e8 e9 bd ff ff       	call   f0100691 <getchar>
f01048a8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01048aa:	85 c0                	test   %eax,%eax
f01048ac:	79 17                	jns    f01048c5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01048ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048b2:	c7 04 24 10 68 10 f0 	movl   $0xf0106810,(%esp)
f01048b9:	e8 e7 ee ff ff       	call   f01037a5 <cprintf>
			return NULL;
f01048be:	b8 00 00 00 00       	mov    $0x0,%eax
f01048c3:	eb 6d                	jmp    f0104932 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01048c5:	83 f8 7f             	cmp    $0x7f,%eax
f01048c8:	74 05                	je     f01048cf <readline+0x5f>
f01048ca:	83 f8 08             	cmp    $0x8,%eax
f01048cd:	75 19                	jne    f01048e8 <readline+0x78>
f01048cf:	85 f6                	test   %esi,%esi
f01048d1:	7e 15                	jle    f01048e8 <readline+0x78>
			if (echoing)
f01048d3:	85 ff                	test   %edi,%edi
f01048d5:	74 0c                	je     f01048e3 <readline+0x73>
				cputchar('\b');
f01048d7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01048de:	e8 9e bd ff ff       	call   f0100681 <cputchar>
			i--;
f01048e3:	83 ee 01             	sub    $0x1,%esi
f01048e6:	eb bb                	jmp    f01048a3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01048e8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01048ee:	7f 1c                	jg     f010490c <readline+0x9c>
f01048f0:	83 fb 1f             	cmp    $0x1f,%ebx
f01048f3:	7e 17                	jle    f010490c <readline+0x9c>
			if (echoing)
f01048f5:	85 ff                	test   %edi,%edi
f01048f7:	74 08                	je     f0104901 <readline+0x91>
				cputchar(c);
f01048f9:	89 1c 24             	mov    %ebx,(%esp)
f01048fc:	e8 80 bd ff ff       	call   f0100681 <cputchar>
			buf[i++] = c;
f0104901:	88 9e 80 eb 17 f0    	mov    %bl,-0xfe81480(%esi)
f0104907:	8d 76 01             	lea    0x1(%esi),%esi
f010490a:	eb 97                	jmp    f01048a3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010490c:	83 fb 0d             	cmp    $0xd,%ebx
f010490f:	74 05                	je     f0104916 <readline+0xa6>
f0104911:	83 fb 0a             	cmp    $0xa,%ebx
f0104914:	75 8d                	jne    f01048a3 <readline+0x33>
			if (echoing)
f0104916:	85 ff                	test   %edi,%edi
f0104918:	74 0c                	je     f0104926 <readline+0xb6>
				cputchar('\n');
f010491a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104921:	e8 5b bd ff ff       	call   f0100681 <cputchar>
			buf[i] = 0;
f0104926:	c6 86 80 eb 17 f0 00 	movb   $0x0,-0xfe81480(%esi)
			return buf;
f010492d:	b8 80 eb 17 f0       	mov    $0xf017eb80,%eax
		}
	}
}
f0104932:	83 c4 1c             	add    $0x1c,%esp
f0104935:	5b                   	pop    %ebx
f0104936:	5e                   	pop    %esi
f0104937:	5f                   	pop    %edi
f0104938:	5d                   	pop    %ebp
f0104939:	c3                   	ret    
f010493a:	66 90                	xchg   %ax,%ax
f010493c:	66 90                	xchg   %ax,%ax
f010493e:	66 90                	xchg   %ax,%ax

f0104940 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104940:	55                   	push   %ebp
f0104941:	89 e5                	mov    %esp,%ebp
f0104943:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104946:	b8 00 00 00 00       	mov    $0x0,%eax
f010494b:	eb 03                	jmp    f0104950 <strlen+0x10>
		n++;
f010494d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104950:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104954:	75 f7                	jne    f010494d <strlen+0xd>
		n++;
	return n;
}
f0104956:	5d                   	pop    %ebp
f0104957:	c3                   	ret    

f0104958 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104958:	55                   	push   %ebp
f0104959:	89 e5                	mov    %esp,%ebp
f010495b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010495e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104961:	b8 00 00 00 00       	mov    $0x0,%eax
f0104966:	eb 03                	jmp    f010496b <strnlen+0x13>
		n++;
f0104968:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010496b:	39 d0                	cmp    %edx,%eax
f010496d:	74 06                	je     f0104975 <strnlen+0x1d>
f010496f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104973:	75 f3                	jne    f0104968 <strnlen+0x10>
		n++;
	return n;
}
f0104975:	5d                   	pop    %ebp
f0104976:	c3                   	ret    

f0104977 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104977:	55                   	push   %ebp
f0104978:	89 e5                	mov    %esp,%ebp
f010497a:	53                   	push   %ebx
f010497b:	8b 45 08             	mov    0x8(%ebp),%eax
f010497e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104981:	89 c2                	mov    %eax,%edx
f0104983:	83 c2 01             	add    $0x1,%edx
f0104986:	83 c1 01             	add    $0x1,%ecx
f0104989:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010498d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104990:	84 db                	test   %bl,%bl
f0104992:	75 ef                	jne    f0104983 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104994:	5b                   	pop    %ebx
f0104995:	5d                   	pop    %ebp
f0104996:	c3                   	ret    

f0104997 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104997:	55                   	push   %ebp
f0104998:	89 e5                	mov    %esp,%ebp
f010499a:	53                   	push   %ebx
f010499b:	83 ec 08             	sub    $0x8,%esp
f010499e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01049a1:	89 1c 24             	mov    %ebx,(%esp)
f01049a4:	e8 97 ff ff ff       	call   f0104940 <strlen>
	strcpy(dst + len, src);
f01049a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049ac:	89 54 24 04          	mov    %edx,0x4(%esp)
f01049b0:	01 d8                	add    %ebx,%eax
f01049b2:	89 04 24             	mov    %eax,(%esp)
f01049b5:	e8 bd ff ff ff       	call   f0104977 <strcpy>
	return dst;
}
f01049ba:	89 d8                	mov    %ebx,%eax
f01049bc:	83 c4 08             	add    $0x8,%esp
f01049bf:	5b                   	pop    %ebx
f01049c0:	5d                   	pop    %ebp
f01049c1:	c3                   	ret    

f01049c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01049c2:	55                   	push   %ebp
f01049c3:	89 e5                	mov    %esp,%ebp
f01049c5:	56                   	push   %esi
f01049c6:	53                   	push   %ebx
f01049c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01049ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01049cd:	89 f3                	mov    %esi,%ebx
f01049cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01049d2:	89 f2                	mov    %esi,%edx
f01049d4:	eb 0f                	jmp    f01049e5 <strncpy+0x23>
		*dst++ = *src;
f01049d6:	83 c2 01             	add    $0x1,%edx
f01049d9:	0f b6 01             	movzbl (%ecx),%eax
f01049dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01049df:	80 39 01             	cmpb   $0x1,(%ecx)
f01049e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01049e5:	39 da                	cmp    %ebx,%edx
f01049e7:	75 ed                	jne    f01049d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01049e9:	89 f0                	mov    %esi,%eax
f01049eb:	5b                   	pop    %ebx
f01049ec:	5e                   	pop    %esi
f01049ed:	5d                   	pop    %ebp
f01049ee:	c3                   	ret    

f01049ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01049ef:	55                   	push   %ebp
f01049f0:	89 e5                	mov    %esp,%ebp
f01049f2:	56                   	push   %esi
f01049f3:	53                   	push   %ebx
f01049f4:	8b 75 08             	mov    0x8(%ebp),%esi
f01049f7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01049fd:	89 f0                	mov    %esi,%eax
f01049ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104a03:	85 c9                	test   %ecx,%ecx
f0104a05:	75 0b                	jne    f0104a12 <strlcpy+0x23>
f0104a07:	eb 1d                	jmp    f0104a26 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104a09:	83 c0 01             	add    $0x1,%eax
f0104a0c:	83 c2 01             	add    $0x1,%edx
f0104a0f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104a12:	39 d8                	cmp    %ebx,%eax
f0104a14:	74 0b                	je     f0104a21 <strlcpy+0x32>
f0104a16:	0f b6 0a             	movzbl (%edx),%ecx
f0104a19:	84 c9                	test   %cl,%cl
f0104a1b:	75 ec                	jne    f0104a09 <strlcpy+0x1a>
f0104a1d:	89 c2                	mov    %eax,%edx
f0104a1f:	eb 02                	jmp    f0104a23 <strlcpy+0x34>
f0104a21:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104a23:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104a26:	29 f0                	sub    %esi,%eax
}
f0104a28:	5b                   	pop    %ebx
f0104a29:	5e                   	pop    %esi
f0104a2a:	5d                   	pop    %ebp
f0104a2b:	c3                   	ret    

f0104a2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104a2c:	55                   	push   %ebp
f0104a2d:	89 e5                	mov    %esp,%ebp
f0104a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104a35:	eb 06                	jmp    f0104a3d <strcmp+0x11>
		p++, q++;
f0104a37:	83 c1 01             	add    $0x1,%ecx
f0104a3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104a3d:	0f b6 01             	movzbl (%ecx),%eax
f0104a40:	84 c0                	test   %al,%al
f0104a42:	74 04                	je     f0104a48 <strcmp+0x1c>
f0104a44:	3a 02                	cmp    (%edx),%al
f0104a46:	74 ef                	je     f0104a37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a48:	0f b6 c0             	movzbl %al,%eax
f0104a4b:	0f b6 12             	movzbl (%edx),%edx
f0104a4e:	29 d0                	sub    %edx,%eax
}
f0104a50:	5d                   	pop    %ebp
f0104a51:	c3                   	ret    

f0104a52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104a52:	55                   	push   %ebp
f0104a53:	89 e5                	mov    %esp,%ebp
f0104a55:	53                   	push   %ebx
f0104a56:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a59:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a5c:	89 c3                	mov    %eax,%ebx
f0104a5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104a61:	eb 06                	jmp    f0104a69 <strncmp+0x17>
		n--, p++, q++;
f0104a63:	83 c0 01             	add    $0x1,%eax
f0104a66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104a69:	39 d8                	cmp    %ebx,%eax
f0104a6b:	74 15                	je     f0104a82 <strncmp+0x30>
f0104a6d:	0f b6 08             	movzbl (%eax),%ecx
f0104a70:	84 c9                	test   %cl,%cl
f0104a72:	74 04                	je     f0104a78 <strncmp+0x26>
f0104a74:	3a 0a                	cmp    (%edx),%cl
f0104a76:	74 eb                	je     f0104a63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a78:	0f b6 00             	movzbl (%eax),%eax
f0104a7b:	0f b6 12             	movzbl (%edx),%edx
f0104a7e:	29 d0                	sub    %edx,%eax
f0104a80:	eb 05                	jmp    f0104a87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104a82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104a87:	5b                   	pop    %ebx
f0104a88:	5d                   	pop    %ebp
f0104a89:	c3                   	ret    

f0104a8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104a8a:	55                   	push   %ebp
f0104a8b:	89 e5                	mov    %esp,%ebp
f0104a8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a94:	eb 07                	jmp    f0104a9d <strchr+0x13>
		if (*s == c)
f0104a96:	38 ca                	cmp    %cl,%dl
f0104a98:	74 0f                	je     f0104aa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104a9a:	83 c0 01             	add    $0x1,%eax
f0104a9d:	0f b6 10             	movzbl (%eax),%edx
f0104aa0:	84 d2                	test   %dl,%dl
f0104aa2:	75 f2                	jne    f0104a96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104aa9:	5d                   	pop    %ebp
f0104aaa:	c3                   	ret    

f0104aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104aab:	55                   	push   %ebp
f0104aac:	89 e5                	mov    %esp,%ebp
f0104aae:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ab5:	eb 07                	jmp    f0104abe <strfind+0x13>
		if (*s == c)
f0104ab7:	38 ca                	cmp    %cl,%dl
f0104ab9:	74 0a                	je     f0104ac5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104abb:	83 c0 01             	add    $0x1,%eax
f0104abe:	0f b6 10             	movzbl (%eax),%edx
f0104ac1:	84 d2                	test   %dl,%dl
f0104ac3:	75 f2                	jne    f0104ab7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0104ac5:	5d                   	pop    %ebp
f0104ac6:	c3                   	ret    

f0104ac7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104ac7:	55                   	push   %ebp
f0104ac8:	89 e5                	mov    %esp,%ebp
f0104aca:	57                   	push   %edi
f0104acb:	56                   	push   %esi
f0104acc:	53                   	push   %ebx
f0104acd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104ad3:	85 c9                	test   %ecx,%ecx
f0104ad5:	74 36                	je     f0104b0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104ad7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104add:	75 28                	jne    f0104b07 <memset+0x40>
f0104adf:	f6 c1 03             	test   $0x3,%cl
f0104ae2:	75 23                	jne    f0104b07 <memset+0x40>
		c &= 0xFF;
f0104ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104ae8:	89 d3                	mov    %edx,%ebx
f0104aea:	c1 e3 08             	shl    $0x8,%ebx
f0104aed:	89 d6                	mov    %edx,%esi
f0104aef:	c1 e6 18             	shl    $0x18,%esi
f0104af2:	89 d0                	mov    %edx,%eax
f0104af4:	c1 e0 10             	shl    $0x10,%eax
f0104af7:	09 f0                	or     %esi,%eax
f0104af9:	09 c2                	or     %eax,%edx
f0104afb:	89 d0                	mov    %edx,%eax
f0104afd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104aff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104b02:	fc                   	cld    
f0104b03:	f3 ab                	rep stos %eax,%es:(%edi)
f0104b05:	eb 06                	jmp    f0104b0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104b07:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b0a:	fc                   	cld    
f0104b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104b0d:	89 f8                	mov    %edi,%eax
f0104b0f:	5b                   	pop    %ebx
f0104b10:	5e                   	pop    %esi
f0104b11:	5f                   	pop    %edi
f0104b12:	5d                   	pop    %ebp
f0104b13:	c3                   	ret    

f0104b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104b14:	55                   	push   %ebp
f0104b15:	89 e5                	mov    %esp,%ebp
f0104b17:	57                   	push   %edi
f0104b18:	56                   	push   %esi
f0104b19:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104b22:	39 c6                	cmp    %eax,%esi
f0104b24:	73 35                	jae    f0104b5b <memmove+0x47>
f0104b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104b29:	39 d0                	cmp    %edx,%eax
f0104b2b:	73 2e                	jae    f0104b5b <memmove+0x47>
		s += n;
		d += n;
f0104b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0104b30:	89 d6                	mov    %edx,%esi
f0104b32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b34:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104b3a:	75 13                	jne    f0104b4f <memmove+0x3b>
f0104b3c:	f6 c1 03             	test   $0x3,%cl
f0104b3f:	75 0e                	jne    f0104b4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104b41:	83 ef 04             	sub    $0x4,%edi
f0104b44:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104b47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104b4a:	fd                   	std    
f0104b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b4d:	eb 09                	jmp    f0104b58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104b4f:	83 ef 01             	sub    $0x1,%edi
f0104b52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104b55:	fd                   	std    
f0104b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104b58:	fc                   	cld    
f0104b59:	eb 1d                	jmp    f0104b78 <memmove+0x64>
f0104b5b:	89 f2                	mov    %esi,%edx
f0104b5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b5f:	f6 c2 03             	test   $0x3,%dl
f0104b62:	75 0f                	jne    f0104b73 <memmove+0x5f>
f0104b64:	f6 c1 03             	test   $0x3,%cl
f0104b67:	75 0a                	jne    f0104b73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104b69:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104b6c:	89 c7                	mov    %eax,%edi
f0104b6e:	fc                   	cld    
f0104b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b71:	eb 05                	jmp    f0104b78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104b73:	89 c7                	mov    %eax,%edi
f0104b75:	fc                   	cld    
f0104b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104b78:	5e                   	pop    %esi
f0104b79:	5f                   	pop    %edi
f0104b7a:	5d                   	pop    %ebp
f0104b7b:	c3                   	ret    

f0104b7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104b7c:	55                   	push   %ebp
f0104b7d:	89 e5                	mov    %esp,%ebp
f0104b7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104b82:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b85:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b90:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b93:	89 04 24             	mov    %eax,(%esp)
f0104b96:	e8 79 ff ff ff       	call   f0104b14 <memmove>
}
f0104b9b:	c9                   	leave  
f0104b9c:	c3                   	ret    

f0104b9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104b9d:	55                   	push   %ebp
f0104b9e:	89 e5                	mov    %esp,%ebp
f0104ba0:	56                   	push   %esi
f0104ba1:	53                   	push   %ebx
f0104ba2:	8b 55 08             	mov    0x8(%ebp),%edx
f0104ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ba8:	89 d6                	mov    %edx,%esi
f0104baa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104bad:	eb 1a                	jmp    f0104bc9 <memcmp+0x2c>
		if (*s1 != *s2)
f0104baf:	0f b6 02             	movzbl (%edx),%eax
f0104bb2:	0f b6 19             	movzbl (%ecx),%ebx
f0104bb5:	38 d8                	cmp    %bl,%al
f0104bb7:	74 0a                	je     f0104bc3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104bb9:	0f b6 c0             	movzbl %al,%eax
f0104bbc:	0f b6 db             	movzbl %bl,%ebx
f0104bbf:	29 d8                	sub    %ebx,%eax
f0104bc1:	eb 0f                	jmp    f0104bd2 <memcmp+0x35>
		s1++, s2++;
f0104bc3:	83 c2 01             	add    $0x1,%edx
f0104bc6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104bc9:	39 f2                	cmp    %esi,%edx
f0104bcb:	75 e2                	jne    f0104baf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bd2:	5b                   	pop    %ebx
f0104bd3:	5e                   	pop    %esi
f0104bd4:	5d                   	pop    %ebp
f0104bd5:	c3                   	ret    

f0104bd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104bd6:	55                   	push   %ebp
f0104bd7:	89 e5                	mov    %esp,%ebp
f0104bd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104bdf:	89 c2                	mov    %eax,%edx
f0104be1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104be4:	eb 07                	jmp    f0104bed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104be6:	38 08                	cmp    %cl,(%eax)
f0104be8:	74 07                	je     f0104bf1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104bea:	83 c0 01             	add    $0x1,%eax
f0104bed:	39 d0                	cmp    %edx,%eax
f0104bef:	72 f5                	jb     f0104be6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104bf1:	5d                   	pop    %ebp
f0104bf2:	c3                   	ret    

f0104bf3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104bf3:	55                   	push   %ebp
f0104bf4:	89 e5                	mov    %esp,%ebp
f0104bf6:	57                   	push   %edi
f0104bf7:	56                   	push   %esi
f0104bf8:	53                   	push   %ebx
f0104bf9:	8b 55 08             	mov    0x8(%ebp),%edx
f0104bfc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104bff:	eb 03                	jmp    f0104c04 <strtol+0x11>
		s++;
f0104c01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104c04:	0f b6 0a             	movzbl (%edx),%ecx
f0104c07:	80 f9 09             	cmp    $0x9,%cl
f0104c0a:	74 f5                	je     f0104c01 <strtol+0xe>
f0104c0c:	80 f9 20             	cmp    $0x20,%cl
f0104c0f:	74 f0                	je     f0104c01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104c11:	80 f9 2b             	cmp    $0x2b,%cl
f0104c14:	75 0a                	jne    f0104c20 <strtol+0x2d>
		s++;
f0104c16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104c19:	bf 00 00 00 00       	mov    $0x0,%edi
f0104c1e:	eb 11                	jmp    f0104c31 <strtol+0x3e>
f0104c20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104c25:	80 f9 2d             	cmp    $0x2d,%cl
f0104c28:	75 07                	jne    f0104c31 <strtol+0x3e>
		s++, neg = 1;
f0104c2a:	8d 52 01             	lea    0x1(%edx),%edx
f0104c2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0104c36:	75 15                	jne    f0104c4d <strtol+0x5a>
f0104c38:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c3b:	75 10                	jne    f0104c4d <strtol+0x5a>
f0104c3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104c41:	75 0a                	jne    f0104c4d <strtol+0x5a>
		s += 2, base = 16;
f0104c43:	83 c2 02             	add    $0x2,%edx
f0104c46:	b8 10 00 00 00       	mov    $0x10,%eax
f0104c4b:	eb 10                	jmp    f0104c5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0104c4d:	85 c0                	test   %eax,%eax
f0104c4f:	75 0c                	jne    f0104c5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104c51:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104c53:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c56:	75 05                	jne    f0104c5d <strtol+0x6a>
		s++, base = 8;
f0104c58:	83 c2 01             	add    $0x1,%edx
f0104c5b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0104c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104c65:	0f b6 0a             	movzbl (%edx),%ecx
f0104c68:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0104c6b:	89 f0                	mov    %esi,%eax
f0104c6d:	3c 09                	cmp    $0x9,%al
f0104c6f:	77 08                	ja     f0104c79 <strtol+0x86>
			dig = *s - '0';
f0104c71:	0f be c9             	movsbl %cl,%ecx
f0104c74:	83 e9 30             	sub    $0x30,%ecx
f0104c77:	eb 20                	jmp    f0104c99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0104c79:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0104c7c:	89 f0                	mov    %esi,%eax
f0104c7e:	3c 19                	cmp    $0x19,%al
f0104c80:	77 08                	ja     f0104c8a <strtol+0x97>
			dig = *s - 'a' + 10;
f0104c82:	0f be c9             	movsbl %cl,%ecx
f0104c85:	83 e9 57             	sub    $0x57,%ecx
f0104c88:	eb 0f                	jmp    f0104c99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0104c8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0104c8d:	89 f0                	mov    %esi,%eax
f0104c8f:	3c 19                	cmp    $0x19,%al
f0104c91:	77 16                	ja     f0104ca9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0104c93:	0f be c9             	movsbl %cl,%ecx
f0104c96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104c99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0104c9c:	7d 0f                	jge    f0104cad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0104c9e:	83 c2 01             	add    $0x1,%edx
f0104ca1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0104ca5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0104ca7:	eb bc                	jmp    f0104c65 <strtol+0x72>
f0104ca9:	89 d8                	mov    %ebx,%eax
f0104cab:	eb 02                	jmp    f0104caf <strtol+0xbc>
f0104cad:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0104caf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104cb3:	74 05                	je     f0104cba <strtol+0xc7>
		*endptr = (char *) s;
f0104cb5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104cb8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0104cba:	f7 d8                	neg    %eax
f0104cbc:	85 ff                	test   %edi,%edi
f0104cbe:	0f 44 c3             	cmove  %ebx,%eax
}
f0104cc1:	5b                   	pop    %ebx
f0104cc2:	5e                   	pop    %esi
f0104cc3:	5f                   	pop    %edi
f0104cc4:	5d                   	pop    %ebp
f0104cc5:	c3                   	ret    
f0104cc6:	66 90                	xchg   %ax,%ax
f0104cc8:	66 90                	xchg   %ax,%ax
f0104cca:	66 90                	xchg   %ax,%ax
f0104ccc:	66 90                	xchg   %ax,%ax
f0104cce:	66 90                	xchg   %ax,%ax

f0104cd0 <__udivdi3>:
f0104cd0:	55                   	push   %ebp
f0104cd1:	57                   	push   %edi
f0104cd2:	56                   	push   %esi
f0104cd3:	83 ec 0c             	sub    $0xc,%esp
f0104cd6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104cda:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0104cde:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104ce2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104ce6:	85 c0                	test   %eax,%eax
f0104ce8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104cec:	89 ea                	mov    %ebp,%edx
f0104cee:	89 0c 24             	mov    %ecx,(%esp)
f0104cf1:	75 2d                	jne    f0104d20 <__udivdi3+0x50>
f0104cf3:	39 e9                	cmp    %ebp,%ecx
f0104cf5:	77 61                	ja     f0104d58 <__udivdi3+0x88>
f0104cf7:	85 c9                	test   %ecx,%ecx
f0104cf9:	89 ce                	mov    %ecx,%esi
f0104cfb:	75 0b                	jne    f0104d08 <__udivdi3+0x38>
f0104cfd:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d02:	31 d2                	xor    %edx,%edx
f0104d04:	f7 f1                	div    %ecx
f0104d06:	89 c6                	mov    %eax,%esi
f0104d08:	31 d2                	xor    %edx,%edx
f0104d0a:	89 e8                	mov    %ebp,%eax
f0104d0c:	f7 f6                	div    %esi
f0104d0e:	89 c5                	mov    %eax,%ebp
f0104d10:	89 f8                	mov    %edi,%eax
f0104d12:	f7 f6                	div    %esi
f0104d14:	89 ea                	mov    %ebp,%edx
f0104d16:	83 c4 0c             	add    $0xc,%esp
f0104d19:	5e                   	pop    %esi
f0104d1a:	5f                   	pop    %edi
f0104d1b:	5d                   	pop    %ebp
f0104d1c:	c3                   	ret    
f0104d1d:	8d 76 00             	lea    0x0(%esi),%esi
f0104d20:	39 e8                	cmp    %ebp,%eax
f0104d22:	77 24                	ja     f0104d48 <__udivdi3+0x78>
f0104d24:	0f bd e8             	bsr    %eax,%ebp
f0104d27:	83 f5 1f             	xor    $0x1f,%ebp
f0104d2a:	75 3c                	jne    f0104d68 <__udivdi3+0x98>
f0104d2c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104d30:	39 34 24             	cmp    %esi,(%esp)
f0104d33:	0f 86 9f 00 00 00    	jbe    f0104dd8 <__udivdi3+0x108>
f0104d39:	39 d0                	cmp    %edx,%eax
f0104d3b:	0f 82 97 00 00 00    	jb     f0104dd8 <__udivdi3+0x108>
f0104d41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104d48:	31 d2                	xor    %edx,%edx
f0104d4a:	31 c0                	xor    %eax,%eax
f0104d4c:	83 c4 0c             	add    $0xc,%esp
f0104d4f:	5e                   	pop    %esi
f0104d50:	5f                   	pop    %edi
f0104d51:	5d                   	pop    %ebp
f0104d52:	c3                   	ret    
f0104d53:	90                   	nop
f0104d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d58:	89 f8                	mov    %edi,%eax
f0104d5a:	f7 f1                	div    %ecx
f0104d5c:	31 d2                	xor    %edx,%edx
f0104d5e:	83 c4 0c             	add    $0xc,%esp
f0104d61:	5e                   	pop    %esi
f0104d62:	5f                   	pop    %edi
f0104d63:	5d                   	pop    %ebp
f0104d64:	c3                   	ret    
f0104d65:	8d 76 00             	lea    0x0(%esi),%esi
f0104d68:	89 e9                	mov    %ebp,%ecx
f0104d6a:	8b 3c 24             	mov    (%esp),%edi
f0104d6d:	d3 e0                	shl    %cl,%eax
f0104d6f:	89 c6                	mov    %eax,%esi
f0104d71:	b8 20 00 00 00       	mov    $0x20,%eax
f0104d76:	29 e8                	sub    %ebp,%eax
f0104d78:	89 c1                	mov    %eax,%ecx
f0104d7a:	d3 ef                	shr    %cl,%edi
f0104d7c:	89 e9                	mov    %ebp,%ecx
f0104d7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104d82:	8b 3c 24             	mov    (%esp),%edi
f0104d85:	09 74 24 08          	or     %esi,0x8(%esp)
f0104d89:	89 d6                	mov    %edx,%esi
f0104d8b:	d3 e7                	shl    %cl,%edi
f0104d8d:	89 c1                	mov    %eax,%ecx
f0104d8f:	89 3c 24             	mov    %edi,(%esp)
f0104d92:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104d96:	d3 ee                	shr    %cl,%esi
f0104d98:	89 e9                	mov    %ebp,%ecx
f0104d9a:	d3 e2                	shl    %cl,%edx
f0104d9c:	89 c1                	mov    %eax,%ecx
f0104d9e:	d3 ef                	shr    %cl,%edi
f0104da0:	09 d7                	or     %edx,%edi
f0104da2:	89 f2                	mov    %esi,%edx
f0104da4:	89 f8                	mov    %edi,%eax
f0104da6:	f7 74 24 08          	divl   0x8(%esp)
f0104daa:	89 d6                	mov    %edx,%esi
f0104dac:	89 c7                	mov    %eax,%edi
f0104dae:	f7 24 24             	mull   (%esp)
f0104db1:	39 d6                	cmp    %edx,%esi
f0104db3:	89 14 24             	mov    %edx,(%esp)
f0104db6:	72 30                	jb     f0104de8 <__udivdi3+0x118>
f0104db8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104dbc:	89 e9                	mov    %ebp,%ecx
f0104dbe:	d3 e2                	shl    %cl,%edx
f0104dc0:	39 c2                	cmp    %eax,%edx
f0104dc2:	73 05                	jae    f0104dc9 <__udivdi3+0xf9>
f0104dc4:	3b 34 24             	cmp    (%esp),%esi
f0104dc7:	74 1f                	je     f0104de8 <__udivdi3+0x118>
f0104dc9:	89 f8                	mov    %edi,%eax
f0104dcb:	31 d2                	xor    %edx,%edx
f0104dcd:	e9 7a ff ff ff       	jmp    f0104d4c <__udivdi3+0x7c>
f0104dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104dd8:	31 d2                	xor    %edx,%edx
f0104dda:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ddf:	e9 68 ff ff ff       	jmp    f0104d4c <__udivdi3+0x7c>
f0104de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104de8:	8d 47 ff             	lea    -0x1(%edi),%eax
f0104deb:	31 d2                	xor    %edx,%edx
f0104ded:	83 c4 0c             	add    $0xc,%esp
f0104df0:	5e                   	pop    %esi
f0104df1:	5f                   	pop    %edi
f0104df2:	5d                   	pop    %ebp
f0104df3:	c3                   	ret    
f0104df4:	66 90                	xchg   %ax,%ax
f0104df6:	66 90                	xchg   %ax,%ax
f0104df8:	66 90                	xchg   %ax,%ax
f0104dfa:	66 90                	xchg   %ax,%ax
f0104dfc:	66 90                	xchg   %ax,%ax
f0104dfe:	66 90                	xchg   %ax,%ax

f0104e00 <__umoddi3>:
f0104e00:	55                   	push   %ebp
f0104e01:	57                   	push   %edi
f0104e02:	56                   	push   %esi
f0104e03:	83 ec 14             	sub    $0x14,%esp
f0104e06:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104e0a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104e0e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0104e12:	89 c7                	mov    %eax,%edi
f0104e14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e18:	8b 44 24 30          	mov    0x30(%esp),%eax
f0104e1c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104e20:	89 34 24             	mov    %esi,(%esp)
f0104e23:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104e27:	85 c0                	test   %eax,%eax
f0104e29:	89 c2                	mov    %eax,%edx
f0104e2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104e2f:	75 17                	jne    f0104e48 <__umoddi3+0x48>
f0104e31:	39 fe                	cmp    %edi,%esi
f0104e33:	76 4b                	jbe    f0104e80 <__umoddi3+0x80>
f0104e35:	89 c8                	mov    %ecx,%eax
f0104e37:	89 fa                	mov    %edi,%edx
f0104e39:	f7 f6                	div    %esi
f0104e3b:	89 d0                	mov    %edx,%eax
f0104e3d:	31 d2                	xor    %edx,%edx
f0104e3f:	83 c4 14             	add    $0x14,%esp
f0104e42:	5e                   	pop    %esi
f0104e43:	5f                   	pop    %edi
f0104e44:	5d                   	pop    %ebp
f0104e45:	c3                   	ret    
f0104e46:	66 90                	xchg   %ax,%ax
f0104e48:	39 f8                	cmp    %edi,%eax
f0104e4a:	77 54                	ja     f0104ea0 <__umoddi3+0xa0>
f0104e4c:	0f bd e8             	bsr    %eax,%ebp
f0104e4f:	83 f5 1f             	xor    $0x1f,%ebp
f0104e52:	75 5c                	jne    f0104eb0 <__umoddi3+0xb0>
f0104e54:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104e58:	39 3c 24             	cmp    %edi,(%esp)
f0104e5b:	0f 87 e7 00 00 00    	ja     f0104f48 <__umoddi3+0x148>
f0104e61:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104e65:	29 f1                	sub    %esi,%ecx
f0104e67:	19 c7                	sbb    %eax,%edi
f0104e69:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104e6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104e71:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104e75:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104e79:	83 c4 14             	add    $0x14,%esp
f0104e7c:	5e                   	pop    %esi
f0104e7d:	5f                   	pop    %edi
f0104e7e:	5d                   	pop    %ebp
f0104e7f:	c3                   	ret    
f0104e80:	85 f6                	test   %esi,%esi
f0104e82:	89 f5                	mov    %esi,%ebp
f0104e84:	75 0b                	jne    f0104e91 <__umoddi3+0x91>
f0104e86:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e8b:	31 d2                	xor    %edx,%edx
f0104e8d:	f7 f6                	div    %esi
f0104e8f:	89 c5                	mov    %eax,%ebp
f0104e91:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104e95:	31 d2                	xor    %edx,%edx
f0104e97:	f7 f5                	div    %ebp
f0104e99:	89 c8                	mov    %ecx,%eax
f0104e9b:	f7 f5                	div    %ebp
f0104e9d:	eb 9c                	jmp    f0104e3b <__umoddi3+0x3b>
f0104e9f:	90                   	nop
f0104ea0:	89 c8                	mov    %ecx,%eax
f0104ea2:	89 fa                	mov    %edi,%edx
f0104ea4:	83 c4 14             	add    $0x14,%esp
f0104ea7:	5e                   	pop    %esi
f0104ea8:	5f                   	pop    %edi
f0104ea9:	5d                   	pop    %ebp
f0104eaa:	c3                   	ret    
f0104eab:	90                   	nop
f0104eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104eb0:	8b 04 24             	mov    (%esp),%eax
f0104eb3:	be 20 00 00 00       	mov    $0x20,%esi
f0104eb8:	89 e9                	mov    %ebp,%ecx
f0104eba:	29 ee                	sub    %ebp,%esi
f0104ebc:	d3 e2                	shl    %cl,%edx
f0104ebe:	89 f1                	mov    %esi,%ecx
f0104ec0:	d3 e8                	shr    %cl,%eax
f0104ec2:	89 e9                	mov    %ebp,%ecx
f0104ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ec8:	8b 04 24             	mov    (%esp),%eax
f0104ecb:	09 54 24 04          	or     %edx,0x4(%esp)
f0104ecf:	89 fa                	mov    %edi,%edx
f0104ed1:	d3 e0                	shl    %cl,%eax
f0104ed3:	89 f1                	mov    %esi,%ecx
f0104ed5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ed9:	8b 44 24 10          	mov    0x10(%esp),%eax
f0104edd:	d3 ea                	shr    %cl,%edx
f0104edf:	89 e9                	mov    %ebp,%ecx
f0104ee1:	d3 e7                	shl    %cl,%edi
f0104ee3:	89 f1                	mov    %esi,%ecx
f0104ee5:	d3 e8                	shr    %cl,%eax
f0104ee7:	89 e9                	mov    %ebp,%ecx
f0104ee9:	09 f8                	or     %edi,%eax
f0104eeb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0104eef:	f7 74 24 04          	divl   0x4(%esp)
f0104ef3:	d3 e7                	shl    %cl,%edi
f0104ef5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104ef9:	89 d7                	mov    %edx,%edi
f0104efb:	f7 64 24 08          	mull   0x8(%esp)
f0104eff:	39 d7                	cmp    %edx,%edi
f0104f01:	89 c1                	mov    %eax,%ecx
f0104f03:	89 14 24             	mov    %edx,(%esp)
f0104f06:	72 2c                	jb     f0104f34 <__umoddi3+0x134>
f0104f08:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0104f0c:	72 22                	jb     f0104f30 <__umoddi3+0x130>
f0104f0e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104f12:	29 c8                	sub    %ecx,%eax
f0104f14:	19 d7                	sbb    %edx,%edi
f0104f16:	89 e9                	mov    %ebp,%ecx
f0104f18:	89 fa                	mov    %edi,%edx
f0104f1a:	d3 e8                	shr    %cl,%eax
f0104f1c:	89 f1                	mov    %esi,%ecx
f0104f1e:	d3 e2                	shl    %cl,%edx
f0104f20:	89 e9                	mov    %ebp,%ecx
f0104f22:	d3 ef                	shr    %cl,%edi
f0104f24:	09 d0                	or     %edx,%eax
f0104f26:	89 fa                	mov    %edi,%edx
f0104f28:	83 c4 14             	add    $0x14,%esp
f0104f2b:	5e                   	pop    %esi
f0104f2c:	5f                   	pop    %edi
f0104f2d:	5d                   	pop    %ebp
f0104f2e:	c3                   	ret    
f0104f2f:	90                   	nop
f0104f30:	39 d7                	cmp    %edx,%edi
f0104f32:	75 da                	jne    f0104f0e <__umoddi3+0x10e>
f0104f34:	8b 14 24             	mov    (%esp),%edx
f0104f37:	89 c1                	mov    %eax,%ecx
f0104f39:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0104f3d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0104f41:	eb cb                	jmp    f0104f0e <__umoddi3+0x10e>
f0104f43:	90                   	nop
f0104f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104f48:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0104f4c:	0f 82 0f ff ff ff    	jb     f0104e61 <__umoddi3+0x61>
f0104f52:	e9 1a ff ff ff       	jmp    f0104e71 <__umoddi3+0x71>
