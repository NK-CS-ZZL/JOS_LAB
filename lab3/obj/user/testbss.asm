
obj/user/testbss：     文件格式 elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 28 0f 80 00 	movl   $0x800f28,(%esp)
  800040:	e8 1b 02 00 00       	call   800260 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004a:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800051:	00 
  800052:	74 20                	je     800074 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800054:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800058:	c7 44 24 08 a3 0f 80 	movl   $0x800fa3,0x8(%esp)
  80005f:	00 
  800060:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  80006f:	e8 f3 00 00 00       	call   800167 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800074:	83 c0 01             	add    $0x1,%eax
  800077:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007c:	75 cc                	jne    80004a <umain+0x17>
  80007e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800083:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008a:	83 c0 01             	add    $0x1,%eax
  80008d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800092:	75 ef                	jne    800083 <umain+0x50>
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800099:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  8000a0:	74 20                	je     8000c2 <umain+0x8f>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 48 0f 80 	movl   $0x800f48,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  8000bd:	e8 a5 00 00 00       	call   800167 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000ca:	75 cd                	jne    800099 <umain+0x66>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000cc:	c7 04 24 70 0f 80 00 	movl   $0x800f70,(%esp)
  8000d3:	e8 88 01 00 00       	call   800260 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d8:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000df:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e2:	c7 44 24 08 cf 0f 80 	movl   $0x800fcf,0x8(%esp)
  8000e9:	00 
  8000ea:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000f1:	00 
  8000f2:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  8000f9:	e8 69 00 00 00       	call   800167 <_panic>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 10             	sub    $0x10,%esp
  800106:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800109:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010c:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  800113:	00 00 00 
	thisenv=envs+ENVX(sys_getenvid());
  800116:	e8 5a 0b 00 00       	call   800c75 <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800123:	c1 e0 05             	shl    $0x5,%eax
  800126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012b:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800130:	85 db                	test   %ebx,%ebx
  800132:	7e 07                	jle    80013b <libmain+0x3d>
		binaryname = argv[0];
  800134:	8b 06                	mov    (%esi),%eax
  800136:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80013f:	89 1c 24             	mov    %ebx,(%esp)
  800142:	e8 ec fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800147:	e8 07 00 00 00       	call   800153 <exit>
}
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800160:	e8 be 0a 00 00       	call   800c23 <sys_env_destroy>
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80016f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800172:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800178:	e8 f8 0a 00 00       	call   800c75 <sys_getenvid>
  80017d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800180:	89 54 24 10          	mov    %edx,0x10(%esp)
  800184:	8b 55 08             	mov    0x8(%ebp),%edx
  800187:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80018b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80018f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800193:	c7 04 24 f0 0f 80 00 	movl   $0x800ff0,(%esp)
  80019a:	e8 c1 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 51 00 00 00       	call   8001ff <vcprintf>
	cprintf("\n");
  8001ae:	c7 04 24 be 0f 80 00 	movl   $0x800fbe,(%esp)
  8001b5:	e8 a6 00 00 00       	call   800260 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ba:	cc                   	int3   
  8001bb:	eb fd                	jmp    8001ba <_panic+0x53>

008001bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 14             	sub    $0x14,%esp
  8001c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c7:	8b 13                	mov    (%ebx),%edx
  8001c9:	8d 42 01             	lea    0x1(%edx),%eax
  8001cc:	89 03                	mov    %eax,(%ebx)
  8001ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001da:	75 19                	jne    8001f5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001dc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e3:	00 
  8001e4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	e8 f7 09 00 00       	call   800be6 <sys_cputs>
		b->idx = 0;
  8001ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800208:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020f:	00 00 00 
	b.cnt = 0;
  800212:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800219:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	c7 04 24 bd 01 80 00 	movl   $0x8001bd,(%esp)
  80023b:	e8 ae 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 8e 09 00 00       	call   800be6 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 87 ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    
  80027a:	66 90                	xchg   %ax,%ax
  80027c:	66 90                	xchg   %ax,%ax
  80027e:	66 90                	xchg   %ax,%ax

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 c3                	mov    %eax,%ebx
  800299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ad:	39 d9                	cmp    %ebx,%ecx
  8002af:	72 05                	jb     8002b6 <printnum+0x36>
  8002b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b4:	77 69                	ja     80031f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bd:	83 ee 01             	sub    $0x1,%esi
  8002c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d0:	89 c3                	mov    %eax,%ebx
  8002d2:	89 d6                	mov    %edx,%esi
  8002d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 ac 09 00 00       	call   800ca0 <__udivdi3>
  8002f4:	89 d9                	mov    %ebx,%ecx
  8002f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	89 54 24 04          	mov    %edx,0x4(%esp)
  800305:	89 fa                	mov    %edi,%edx
  800307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030a:	e8 71 ff ff ff       	call   800280 <printnum>
  80030f:	eb 1b                	jmp    80032c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	8b 45 18             	mov    0x18(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff d3                	call   *%ebx
  80031d:	eb 03                	jmp    800322 <printnum+0xa2>
  80031f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800322:	83 ee 01             	sub    $0x1,%esi
  800325:	85 f6                	test   %esi,%esi
  800327:	7f e8                	jg     800311 <printnum+0x91>
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800337:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80033a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 7c 0a 00 00       	call   800dd0 <__umoddi3>
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	0f be 80 14 10 80 00 	movsbl 0x801014(%eax),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800365:	ff d0                	call   *%eax
}
  800367:	83 c4 3c             	add    $0x3c,%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800372:	83 fa 01             	cmp    $0x1,%edx
  800375:	7e 0e                	jle    800385 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800377:	8b 10                	mov    (%eax),%edx
  800379:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 02                	mov    (%edx),%eax
  800380:	8b 52 04             	mov    0x4(%edx),%edx
  800383:	eb 22                	jmp    8003a7 <getuint+0x38>
	else if (lflag)
  800385:	85 d2                	test   %edx,%edx
  800387:	74 10                	je     800399 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb 0e                	jmp    8003a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 0a                	jae    8003c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	88 02                	mov    %al,(%edx)
}
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	e8 02 00 00 00       	call   8003ee <vprintfmt>
	va_end(ap);
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 3c             	sub    $0x3c,%esp
  8003f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
  8003fa:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
  800401:	eb 17                	jmp    80041a <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800403:	85 c0                	test   %eax,%eax
  800405:	0f 84 ca 03 00 00    	je     8007d5 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80040b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80040e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800418:	89 fb                	mov    %edi,%ebx
  80041a:	8d 7b 01             	lea    0x1(%ebx),%edi
  80041d:	0f b6 03             	movzbl (%ebx),%eax
  800420:	83 f8 25             	cmp    $0x25,%eax
  800423:	75 de                	jne    800403 <vprintfmt+0x15>
  800425:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800430:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800435:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80043c:	ba 00 00 00 00       	mov    $0x0,%edx
  800441:	eb 18                	jmp    80045b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800445:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800449:	eb 10                	jmp    80045b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044d:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800451:	eb 08                	jmp    80045b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800453:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800456:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8d 5f 01             	lea    0x1(%edi),%ebx
  80045e:	0f b6 07             	movzbl (%edi),%eax
  800461:	0f b6 c8             	movzbl %al,%ecx
  800464:	83 e8 23             	sub    $0x23,%eax
  800467:	3c 55                	cmp    $0x55,%al
  800469:	0f 87 41 03 00 00    	ja     8007b0 <vprintfmt+0x3c2>
  80046f:	0f b6 c0             	movzbl %al,%eax
  800472:	ff 24 85 a4 10 80 00 	jmp    *0x8010a4(,%eax,4)
  800479:	89 df                	mov    %ebx,%edi
  80047b:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800480:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800483:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800487:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80048a:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80048d:	83 f8 09             	cmp    $0x9,%eax
  800490:	77 33                	ja     8004c5 <vprintfmt+0xd7>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800492:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800495:	eb e9                	jmp    800480 <vprintfmt+0x92>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 48 04             	lea    0x4(%eax),%ecx
  80049d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a0:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a4:	eb 1f                	jmp    8004c5 <vprintfmt+0xd7>
  8004a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a9:	85 c9                	test   %ecx,%ecx
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	0f 49 c1             	cmovns %ecx,%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	89 df                	mov    %ebx,%edi
  8004b8:	eb a1                	jmp    80045b <vprintfmt+0x6d>
  8004ba:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8004c3:	eb 96                	jmp    80045b <vprintfmt+0x6d>

		process_precision:
			if (width < 0)
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	79 90                	jns    80045b <vprintfmt+0x6d>
  8004cb:	eb 86                	jmp    800453 <vprintfmt+0x65>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004cd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004d2:	eb 87                	jmp    80045b <vprintfmt+0x6d>

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8004dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004e0:	89 74 24 04          	mov    %esi,0x4(%esp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8004e4:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e7:	0b 30                	or     (%eax),%esi
			putch(ch, putdat);
  8004e9:	89 34 24             	mov    %esi,(%esp)
  8004ec:	ff 55 08             	call   *0x8(%ebp)
                  	color=0x0700;
  8004ef:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
			break;
  8004f6:	e9 1f ff ff ff       	jmp    80041a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	89 df                	mov    %ebx,%edi
			ch=va_arg(ap,int)|color;
			putch(ch, putdat);
                  	color=0x0700;
			break;
		case 'B':
			color=0x0100;
  8004fd:	c7 45 d8 00 01 00 00 	movl   $0x100,-0x28(%ebp)
			goto reswitch;
  800504:	e9 52 ff ff ff       	jmp    80045b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	89 df                	mov    %ebx,%edi
			break;
		case 'B':
			color=0x0100;
			goto reswitch;
		case 'R':
			color=0x0400;
  80050b:	c7 45 d8 00 04 00 00 	movl   $0x400,-0x28(%ebp)
			goto reswitch;
  800512:	e9 44 ff ff ff       	jmp    80045b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	89 df                	mov    %ebx,%edi
			goto reswitch;
		case 'R':
			color=0x0400;
			goto reswitch;
		case 'G':
			color=0x0200;
  800519:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
			goto reswitch;
  800520:	e9 36 ff ff ff       	jmp    80045b <vprintfmt+0x6d>
		// error message
		case 'e':
			err = va_arg(ap, int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	99                   	cltd   
  800531:	31 d0                	xor    %edx,%eax
  800533:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800535:	83 f8 06             	cmp    $0x6,%eax
  800538:	7f 0b                	jg     800545 <vprintfmt+0x157>
  80053a:	8b 14 85 fc 11 80 00 	mov    0x8011fc(,%eax,4),%edx
  800541:	85 d2                	test   %edx,%edx
  800543:	75 23                	jne    800568 <vprintfmt+0x17a>
				printfmt(putch, putdat, "error %d", err);
  800545:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800549:	c7 44 24 08 2c 10 80 	movl   $0x80102c,0x8(%esp)
  800550:	00 
  800551:	8b 45 0c             	mov    0xc(%ebp),%eax
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 63 fe ff ff       	call   8003c6 <printfmt>
  800563:	e9 b2 fe ff ff       	jmp    80041a <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800568:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80056c:	c7 44 24 08 35 10 80 	movl   $0x801035,0x8(%esp)
  800573:	00 
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057b:	8b 45 08             	mov    0x8(%ebp),%eax
  80057e:	89 04 24             	mov    %eax,(%esp)
  800581:	e8 40 fe ff ff       	call   8003c6 <printfmt>
  800586:	e9 8f fe ff ff       	jmp    80041a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80059c:	85 ff                	test   %edi,%edi
  80059e:	b8 25 10 80 00       	mov    $0x801025,%eax
  8005a3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a6:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005aa:	0f 84 96 00 00 00    	je     800646 <vprintfmt+0x258>
  8005b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b4:	0f 8e 94 00 00 00    	jle    80064e <vprintfmt+0x260>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005be:	89 3c 24             	mov    %edi,(%esp)
  8005c1:	e8 b2 02 00 00       	call   800878 <strnlen>
  8005c6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005c9:	29 c1                	sub    %eax,%ecx
  8005cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
					putch(padc, putdat);
  8005ce:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8005d2:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005d5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005db:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005de:	89 cb                	mov    %ecx,%ebx
  8005e0:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e2:	eb 0f                	jmp    8005f3 <vprintfmt+0x205>
					putch(padc, putdat);
  8005e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005eb:	89 3c 24             	mov    %edi,(%esp)
  8005ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f0:	83 eb 01             	sub    $0x1,%ebx
  8005f3:	85 db                	test   %ebx,%ebx
  8005f5:	7f ed                	jg     8005e4 <vprintfmt+0x1f6>
  8005f7:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800600:	85 d2                	test   %edx,%edx
  800602:	b8 00 00 00 00       	mov    $0x0,%eax
  800607:	0f 49 c2             	cmovns %edx,%eax
  80060a:	29 c2                	sub    %eax,%edx
  80060c:	89 d3                	mov    %edx,%ebx
  80060e:	eb 44                	jmp    800654 <vprintfmt+0x266>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800610:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800614:	74 1e                	je     800634 <vprintfmt+0x246>
  800616:	0f be d2             	movsbl %dl,%edx
  800619:	83 ea 20             	sub    $0x20,%edx
  80061c:	83 fa 5e             	cmp    $0x5e,%edx
  80061f:	76 13                	jbe    800634 <vprintfmt+0x246>
					putch('?', putdat);
  800621:	8b 45 0c             	mov    0xc(%ebp),%eax
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x253>
				else
					putch(ch, putdat);
  800634:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800637:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	eb 0e                	jmp    800654 <vprintfmt+0x266>
  800646:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800649:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064c:	eb 06                	jmp    800654 <vprintfmt+0x266>
  80064e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800651:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800654:	83 c7 01             	add    $0x1,%edi
  800657:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80065b:	0f be c2             	movsbl %dl,%eax
  80065e:	85 c0                	test   %eax,%eax
  800660:	74 27                	je     800689 <vprintfmt+0x29b>
  800662:	85 f6                	test   %esi,%esi
  800664:	78 aa                	js     800610 <vprintfmt+0x222>
  800666:	83 ee 01             	sub    $0x1,%esi
  800669:	79 a5                	jns    800610 <vprintfmt+0x222>
  80066b:	89 d8                	mov    %ebx,%eax
  80066d:	8b 75 08             	mov    0x8(%ebp),%esi
  800670:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800673:	89 c3                	mov    %eax,%ebx
  800675:	eb 18                	jmp    80068f <vprintfmt+0x2a1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800677:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800682:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800684:	83 eb 01             	sub    $0x1,%ebx
  800687:	eb 06                	jmp    80068f <vprintfmt+0x2a1>
  800689:	8b 75 08             	mov    0x8(%ebp),%esi
  80068c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80068f:	85 db                	test   %ebx,%ebx
  800691:	7f e4                	jg     800677 <vprintfmt+0x289>
  800693:	89 75 08             	mov    %esi,0x8(%ebp)
  800696:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800699:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80069c:	e9 79 fd ff ff       	jmp    80041a <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a1:	83 fa 01             	cmp    $0x1,%edx
  8006a4:	7e 10                	jle    8006b6 <vprintfmt+0x2c8>
		return va_arg(*ap, long long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 08             	lea    0x8(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 30                	mov    (%eax),%esi
  8006b1:	8b 78 04             	mov    0x4(%eax),%edi
  8006b4:	eb 26                	jmp    8006dc <vprintfmt+0x2ee>
	else if (lflag)
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	74 12                	je     8006cc <vprintfmt+0x2de>
		return va_arg(*ap, long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c3:	8b 30                	mov    (%eax),%esi
  8006c5:	89 f7                	mov    %esi,%edi
  8006c7:	c1 ff 1f             	sar    $0x1f,%edi
  8006ca:	eb 10                	jmp    8006dc <vprintfmt+0x2ee>
	else
		return va_arg(*ap, int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 30                	mov    (%eax),%esi
  8006d7:	89 f7                	mov    %esi,%edi
  8006d9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	85 ff                	test   %edi,%edi
  8006e7:	0f 89 87 00 00 00    	jns    800774 <vprintfmt+0x386>
				putch('-', putdat);
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fe:	89 f0                	mov    %esi,%eax
  800700:	89 fa                	mov    %edi,%edx
  800702:	f7 d8                	neg    %eax
  800704:	83 d2 00             	adc    $0x0,%edx
  800707:	f7 da                	neg    %edx
			}
			base = 10;
  800709:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80070e:	eb 64                	jmp    800774 <vprintfmt+0x386>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
  800713:	e8 57 fc ff ff       	call   80036f <getuint>
			base = 10;
  800718:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80071d:	eb 55                	jmp    800774 <vprintfmt+0x386>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 48 fc ff ff       	call   80036f <getuint>
			base=8;
  800727:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80072c:	eb 46                	jmp    800774 <vprintfmt+0x386>

		// pointer
		case 'p':
			putch('0', putdat);
  80072e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80073c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8d 50 04             	lea    0x4(%eax),%edx
  800756:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800759:	8b 00                	mov    (%eax),%eax
  80075b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800760:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800765:	eb 0d                	jmp    800774 <vprintfmt+0x386>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800767:	8d 45 14             	lea    0x14(%ebp),%eax
  80076a:	e8 00 fc ff ff       	call   80036f <getuint>
			base = 16;
  80076f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800774:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800778:	89 74 24 10          	mov    %esi,0x10(%esp)
  80077c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800783:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	e8 e7 fa ff ff       	call   800280 <printnum>
			break;
  800799:	e9 7c fc ff ff       	jmp    80041a <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a5:	89 0c 24             	mov    %ecx,(%esp)
  8007a8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007ab:	e9 6a fc ff ff       	jmp    80041a <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007be:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c1:	89 fb                	mov    %edi,%ebx
  8007c3:	eb 03                	jmp    8007c8 <vprintfmt+0x3da>
  8007c5:	83 eb 01             	sub    $0x1,%ebx
  8007c8:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007cc:	75 f7                	jne    8007c5 <vprintfmt+0x3d7>
  8007ce:	66 90                	xchg   %ax,%ax
  8007d0:	e9 45 fc ff ff       	jmp    80041a <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8007d5:	83 c4 3c             	add    $0x3c,%esp
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5f                   	pop    %edi
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 28             	sub    $0x28,%esp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	74 30                	je     80082e <vsnprintf+0x51>
  8007fe:	85 d2                	test   %edx,%edx
  800800:	7e 2c                	jle    80082e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800809:	8b 45 10             	mov    0x10(%ebp),%eax
  80080c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800810:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	c7 04 24 a9 03 80 00 	movl   $0x8003a9,(%esp)
  80081e:	e8 cb fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800823:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800826:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	eb 05                	jmp    800833 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 82 ff ff ff       	call   8007dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    
  80085d:	66 90                	xchg   %ax,%ax
  80085f:	90                   	nop

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 06                	je     800895 <strnlen+0x1d>
  80088f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
		n++;
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c2 01             	add    $0x1,%edx
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b0:	84 db                	test   %bl,%bl
  8008b2:	75 ef                	jne    8008a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c1:	89 1c 24             	mov    %ebx,(%esp)
  8008c4:	e8 97 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d0:	01 d8                	add    %ebx,%eax
  8008d2:	89 04 24             	mov    %eax,(%esp)
  8008d5:	e8 bd ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008da:	89 d8                	mov    %ebx,%eax
  8008dc:	83 c4 08             	add    $0x8,%esp
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	89 f3                	mov    %esi,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	eb 0f                	jmp    800905 <strncpy+0x23>
		*dst++ = *src;
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800902:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	39 da                	cmp    %ebx,%edx
  800907:	75 ed                	jne    8008f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800923:	85 c9                	test   %ecx,%ecx
  800925:	75 0b                	jne    800932 <strlcpy+0x23>
  800927:	eb 1d                	jmp    800946 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800932:	39 d8                	cmp    %ebx,%eax
  800934:	74 0b                	je     800941 <strlcpy+0x32>
  800936:	0f b6 0a             	movzbl (%edx),%ecx
  800939:	84 c9                	test   %cl,%cl
  80093b:	75 ec                	jne    800929 <strlcpy+0x1a>
  80093d:	89 c2                	mov    %eax,%edx
  80093f:	eb 02                	jmp    800943 <strlcpy+0x34>
  800941:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 07                	jmp    8009de <strfind+0x13>
		if (*s == c)
  8009d7:	38 ca                	cmp    %cl,%dl
  8009d9:	74 0a                	je     8009e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	0f b6 10             	movzbl (%eax),%edx
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
  800a1b:	89 d0                	mov    %edx,%eax
  800a1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 79 ff ff ff       	call   800a34 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	eb 1a                	jmp    800ae9 <memcmp+0x2c>
		if (*s1 != *s2)
  800acf:	0f b6 02             	movzbl (%edx),%eax
  800ad2:	0f b6 19             	movzbl (%ecx),%ebx
  800ad5:	38 d8                	cmp    %bl,%al
  800ad7:	74 0a                	je     800ae3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ad9:	0f b6 c0             	movzbl %al,%eax
  800adc:	0f b6 db             	movzbl %bl,%ebx
  800adf:	29 d8                	sub    %ebx,%eax
  800ae1:	eb 0f                	jmp    800af2 <memcmp+0x35>
		s1++, s2++;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae9:	39 f2                	cmp    %esi,%edx
  800aeb:	75 e2                	jne    800acf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b04:	eb 07                	jmp    800b0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	38 08                	cmp    %cl,(%eax)
  800b08:	74 07                	je     800b11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	39 d0                	cmp    %edx,%eax
  800b0f:	72 f5                	jb     800b06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1f:	eb 03                	jmp    800b24 <strtol+0x11>
		s++;
  800b21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b24:	0f b6 0a             	movzbl (%edx),%ecx
  800b27:	80 f9 09             	cmp    $0x9,%cl
  800b2a:	74 f5                	je     800b21 <strtol+0xe>
  800b2c:	80 f9 20             	cmp    $0x20,%cl
  800b2f:	74 f0                	je     800b21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b31:	80 f9 2b             	cmp    $0x2b,%cl
  800b34:	75 0a                	jne    800b40 <strtol+0x2d>
		s++;
  800b36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3e:	eb 11                	jmp    800b51 <strtol+0x3e>
  800b40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b45:	80 f9 2d             	cmp    $0x2d,%cl
  800b48:	75 07                	jne    800b51 <strtol+0x3e>
		s++, neg = 1;
  800b4a:	8d 52 01             	lea    0x1(%edx),%edx
  800b4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b56:	75 15                	jne    800b6d <strtol+0x5a>
  800b58:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5b:	75 10                	jne    800b6d <strtol+0x5a>
  800b5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b61:	75 0a                	jne    800b6d <strtol+0x5a>
		s += 2, base = 16;
  800b63:	83 c2 02             	add    $0x2,%edx
  800b66:	b8 10 00 00 00       	mov    $0x10,%eax
  800b6b:	eb 10                	jmp    800b7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	75 0c                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b73:	80 3a 30             	cmpb   $0x30,(%edx)
  800b76:	75 05                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b85:	0f b6 0a             	movzbl (%edx),%ecx
  800b88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	3c 09                	cmp    $0x9,%al
  800b8f:	77 08                	ja     800b99 <strtol+0x86>
			dig = *s - '0';
  800b91:	0f be c9             	movsbl %cl,%ecx
  800b94:	83 e9 30             	sub    $0x30,%ecx
  800b97:	eb 20                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	3c 19                	cmp    $0x19,%al
  800ba0:	77 08                	ja     800baa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ba2:	0f be c9             	movsbl %cl,%ecx
  800ba5:	83 e9 57             	sub    $0x57,%ecx
  800ba8:	eb 0f                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800baa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	3c 19                	cmp    $0x19,%al
  800bb1:	77 16                	ja     800bc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bb3:	0f be c9             	movsbl %cl,%ecx
  800bb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bbc:	7d 0f                	jge    800bcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bc7:	eb bc                	jmp    800b85 <strtol+0x72>
  800bc9:	89 d8                	mov    %ebx,%eax
  800bcb:	eb 02                	jmp    800bcf <strtol+0xbc>
  800bcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd3:	74 05                	je     800bda <strtol+0xc7>
		*endptr = (char *) s;
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bda:	f7 d8                	neg    %eax
  800bdc:	85 ff                	test   %edi,%edi
  800bde:	0f 44 c3             	cmove  %ebx,%eax
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c14:	89 d1                	mov    %edx,%ecx
  800c16:	89 d3                	mov    %edx,%ebx
  800c18:	89 d7                	mov    %edx,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c31:	b8 03 00 00 00       	mov    $0x3,%eax
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 cb                	mov    %ecx,%ebx
  800c3b:	89 cf                	mov    %ecx,%edi
  800c3d:	89 ce                	mov    %ecx,%esi
  800c3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 28                	jle    800c6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c50:	00 
  800c51:	c7 44 24 08 18 12 80 	movl   $0x801218,0x8(%esp)
  800c58:	00 
  800c59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c60:	00 
  800c61:	c7 04 24 35 12 80 00 	movl   $0x801235,(%esp)
  800c68:	e8 fa f4 ff ff       	call   800167 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6d:	83 c4 2c             	add    $0x2c,%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 02 00 00 00       	mov    $0x2,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
  800c94:	66 90                	xchg   %ax,%ax
  800c96:	66 90                	xchg   %ax,%ax
  800c98:	66 90                	xchg   %ax,%ax
  800c9a:	66 90                	xchg   %ax,%ax
  800c9c:	66 90                	xchg   %ax,%ax
  800c9e:	66 90                	xchg   %ax,%ax

00800ca0 <__udivdi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800caa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800cae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800cb2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cbc:	89 ea                	mov    %ebp,%edx
  800cbe:	89 0c 24             	mov    %ecx,(%esp)
  800cc1:	75 2d                	jne    800cf0 <__udivdi3+0x50>
  800cc3:	39 e9                	cmp    %ebp,%ecx
  800cc5:	77 61                	ja     800d28 <__udivdi3+0x88>
  800cc7:	85 c9                	test   %ecx,%ecx
  800cc9:	89 ce                	mov    %ecx,%esi
  800ccb:	75 0b                	jne    800cd8 <__udivdi3+0x38>
  800ccd:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd2:	31 d2                	xor    %edx,%edx
  800cd4:	f7 f1                	div    %ecx
  800cd6:	89 c6                	mov    %eax,%esi
  800cd8:	31 d2                	xor    %edx,%edx
  800cda:	89 e8                	mov    %ebp,%eax
  800cdc:	f7 f6                	div    %esi
  800cde:	89 c5                	mov    %eax,%ebp
  800ce0:	89 f8                	mov    %edi,%eax
  800ce2:	f7 f6                	div    %esi
  800ce4:	89 ea                	mov    %ebp,%edx
  800ce6:	83 c4 0c             	add    $0xc,%esp
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    
  800ced:	8d 76 00             	lea    0x0(%esi),%esi
  800cf0:	39 e8                	cmp    %ebp,%eax
  800cf2:	77 24                	ja     800d18 <__udivdi3+0x78>
  800cf4:	0f bd e8             	bsr    %eax,%ebp
  800cf7:	83 f5 1f             	xor    $0x1f,%ebp
  800cfa:	75 3c                	jne    800d38 <__udivdi3+0x98>
  800cfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d00:	39 34 24             	cmp    %esi,(%esp)
  800d03:	0f 86 9f 00 00 00    	jbe    800da8 <__udivdi3+0x108>
  800d09:	39 d0                	cmp    %edx,%eax
  800d0b:	0f 82 97 00 00 00    	jb     800da8 <__udivdi3+0x108>
  800d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d18:	31 d2                	xor    %edx,%edx
  800d1a:	31 c0                	xor    %eax,%eax
  800d1c:	83 c4 0c             	add    $0xc,%esp
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    
  800d23:	90                   	nop
  800d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d28:	89 f8                	mov    %edi,%eax
  800d2a:	f7 f1                	div    %ecx
  800d2c:	31 d2                	xor    %edx,%edx
  800d2e:	83 c4 0c             	add    $0xc,%esp
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
  800d35:	8d 76 00             	lea    0x0(%esi),%esi
  800d38:	89 e9                	mov    %ebp,%ecx
  800d3a:	8b 3c 24             	mov    (%esp),%edi
  800d3d:	d3 e0                	shl    %cl,%eax
  800d3f:	89 c6                	mov    %eax,%esi
  800d41:	b8 20 00 00 00       	mov    $0x20,%eax
  800d46:	29 e8                	sub    %ebp,%eax
  800d48:	89 c1                	mov    %eax,%ecx
  800d4a:	d3 ef                	shr    %cl,%edi
  800d4c:	89 e9                	mov    %ebp,%ecx
  800d4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d52:	8b 3c 24             	mov    (%esp),%edi
  800d55:	09 74 24 08          	or     %esi,0x8(%esp)
  800d59:	89 d6                	mov    %edx,%esi
  800d5b:	d3 e7                	shl    %cl,%edi
  800d5d:	89 c1                	mov    %eax,%ecx
  800d5f:	89 3c 24             	mov    %edi,(%esp)
  800d62:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d66:	d3 ee                	shr    %cl,%esi
  800d68:	89 e9                	mov    %ebp,%ecx
  800d6a:	d3 e2                	shl    %cl,%edx
  800d6c:	89 c1                	mov    %eax,%ecx
  800d6e:	d3 ef                	shr    %cl,%edi
  800d70:	09 d7                	or     %edx,%edi
  800d72:	89 f2                	mov    %esi,%edx
  800d74:	89 f8                	mov    %edi,%eax
  800d76:	f7 74 24 08          	divl   0x8(%esp)
  800d7a:	89 d6                	mov    %edx,%esi
  800d7c:	89 c7                	mov    %eax,%edi
  800d7e:	f7 24 24             	mull   (%esp)
  800d81:	39 d6                	cmp    %edx,%esi
  800d83:	89 14 24             	mov    %edx,(%esp)
  800d86:	72 30                	jb     800db8 <__udivdi3+0x118>
  800d88:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d8c:	89 e9                	mov    %ebp,%ecx
  800d8e:	d3 e2                	shl    %cl,%edx
  800d90:	39 c2                	cmp    %eax,%edx
  800d92:	73 05                	jae    800d99 <__udivdi3+0xf9>
  800d94:	3b 34 24             	cmp    (%esp),%esi
  800d97:	74 1f                	je     800db8 <__udivdi3+0x118>
  800d99:	89 f8                	mov    %edi,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	e9 7a ff ff ff       	jmp    800d1c <__udivdi3+0x7c>
  800da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da8:	31 d2                	xor    %edx,%edx
  800daa:	b8 01 00 00 00       	mov    $0x1,%eax
  800daf:	e9 68 ff ff ff       	jmp    800d1c <__udivdi3+0x7c>
  800db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	83 c4 0c             	add    $0xc,%esp
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
  800dc4:	66 90                	xchg   %ax,%ax
  800dc6:	66 90                	xchg   %ax,%ax
  800dc8:	66 90                	xchg   %ax,%ax
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <__umoddi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	83 ec 14             	sub    $0x14,%esp
  800dd6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800dda:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800dde:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800de2:	89 c7                	mov    %eax,%edi
  800de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800dec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800df0:	89 34 24             	mov    %esi,(%esp)
  800df3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800df7:	85 c0                	test   %eax,%eax
  800df9:	89 c2                	mov    %eax,%edx
  800dfb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dff:	75 17                	jne    800e18 <__umoddi3+0x48>
  800e01:	39 fe                	cmp    %edi,%esi
  800e03:	76 4b                	jbe    800e50 <__umoddi3+0x80>
  800e05:	89 c8                	mov    %ecx,%eax
  800e07:	89 fa                	mov    %edi,%edx
  800e09:	f7 f6                	div    %esi
  800e0b:	89 d0                	mov    %edx,%eax
  800e0d:	31 d2                	xor    %edx,%edx
  800e0f:	83 c4 14             	add    $0x14,%esp
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	39 f8                	cmp    %edi,%eax
  800e1a:	77 54                	ja     800e70 <__umoddi3+0xa0>
  800e1c:	0f bd e8             	bsr    %eax,%ebp
  800e1f:	83 f5 1f             	xor    $0x1f,%ebp
  800e22:	75 5c                	jne    800e80 <__umoddi3+0xb0>
  800e24:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e28:	39 3c 24             	cmp    %edi,(%esp)
  800e2b:	0f 87 e7 00 00 00    	ja     800f18 <__umoddi3+0x148>
  800e31:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e35:	29 f1                	sub    %esi,%ecx
  800e37:	19 c7                	sbb    %eax,%edi
  800e39:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e3d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e41:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e45:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800e49:	83 c4 14             	add    $0x14,%esp
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    
  800e50:	85 f6                	test   %esi,%esi
  800e52:	89 f5                	mov    %esi,%ebp
  800e54:	75 0b                	jne    800e61 <__umoddi3+0x91>
  800e56:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 f6                	div    %esi
  800e5f:	89 c5                	mov    %eax,%ebp
  800e61:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e65:	31 d2                	xor    %edx,%edx
  800e67:	f7 f5                	div    %ebp
  800e69:	89 c8                	mov    %ecx,%eax
  800e6b:	f7 f5                	div    %ebp
  800e6d:	eb 9c                	jmp    800e0b <__umoddi3+0x3b>
  800e6f:	90                   	nop
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 fa                	mov    %edi,%edx
  800e74:	83 c4 14             	add    $0x14,%esp
  800e77:	5e                   	pop    %esi
  800e78:	5f                   	pop    %edi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    
  800e7b:	90                   	nop
  800e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e80:	8b 04 24             	mov    (%esp),%eax
  800e83:	be 20 00 00 00       	mov    $0x20,%esi
  800e88:	89 e9                	mov    %ebp,%ecx
  800e8a:	29 ee                	sub    %ebp,%esi
  800e8c:	d3 e2                	shl    %cl,%edx
  800e8e:	89 f1                	mov    %esi,%ecx
  800e90:	d3 e8                	shr    %cl,%eax
  800e92:	89 e9                	mov    %ebp,%ecx
  800e94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e98:	8b 04 24             	mov    (%esp),%eax
  800e9b:	09 54 24 04          	or     %edx,0x4(%esp)
  800e9f:	89 fa                	mov    %edi,%edx
  800ea1:	d3 e0                	shl    %cl,%eax
  800ea3:	89 f1                	mov    %esi,%ecx
  800ea5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800ead:	d3 ea                	shr    %cl,%edx
  800eaf:	89 e9                	mov    %ebp,%ecx
  800eb1:	d3 e7                	shl    %cl,%edi
  800eb3:	89 f1                	mov    %esi,%ecx
  800eb5:	d3 e8                	shr    %cl,%eax
  800eb7:	89 e9                	mov    %ebp,%ecx
  800eb9:	09 f8                	or     %edi,%eax
  800ebb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800ebf:	f7 74 24 04          	divl   0x4(%esp)
  800ec3:	d3 e7                	shl    %cl,%edi
  800ec5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	f7 64 24 08          	mull   0x8(%esp)
  800ecf:	39 d7                	cmp    %edx,%edi
  800ed1:	89 c1                	mov    %eax,%ecx
  800ed3:	89 14 24             	mov    %edx,(%esp)
  800ed6:	72 2c                	jb     800f04 <__umoddi3+0x134>
  800ed8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  800edc:	72 22                	jb     800f00 <__umoddi3+0x130>
  800ede:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ee2:	29 c8                	sub    %ecx,%eax
  800ee4:	19 d7                	sbb    %edx,%edi
  800ee6:	89 e9                	mov    %ebp,%ecx
  800ee8:	89 fa                	mov    %edi,%edx
  800eea:	d3 e8                	shr    %cl,%eax
  800eec:	89 f1                	mov    %esi,%ecx
  800eee:	d3 e2                	shl    %cl,%edx
  800ef0:	89 e9                	mov    %ebp,%ecx
  800ef2:	d3 ef                	shr    %cl,%edi
  800ef4:	09 d0                	or     %edx,%eax
  800ef6:	89 fa                	mov    %edi,%edx
  800ef8:	83 c4 14             	add    $0x14,%esp
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    
  800eff:	90                   	nop
  800f00:	39 d7                	cmp    %edx,%edi
  800f02:	75 da                	jne    800ede <__umoddi3+0x10e>
  800f04:	8b 14 24             	mov    (%esp),%edx
  800f07:	89 c1                	mov    %eax,%ecx
  800f09:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  800f0d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  800f11:	eb cb                	jmp    800ede <__umoddi3+0x10e>
  800f13:	90                   	nop
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800f1c:	0f 82 0f ff ff ff    	jb     800e31 <__umoddi3+0x61>
  800f22:	e9 1a ff ff ff       	jmp    800e41 <__umoddi3+0x71>
