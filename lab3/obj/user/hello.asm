
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 2e 00 00 00       	call   80005f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  800039:	c7 04 24 88 0e 80 00 	movl   $0x800e88,(%esp)
  800040:	e8 26 01 00 00       	call   80016b <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800045:	a1 04 20 80 00       	mov    0x802004,%eax
  80004a:	8b 40 48             	mov    0x48(%eax),%eax
  80004d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800051:	c7 04 24 96 0e 80 00 	movl   $0x800e96,(%esp)
  800058:	e8 0e 01 00 00       	call   80016b <cprintf>
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	83 ec 10             	sub    $0x10,%esp
  800067:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800074:	00 00 00 
	thisenv=envs+ENVX(sys_getenvid());
  800077:	e8 09 0b 00 00       	call   800b85 <sys_getenvid>
  80007c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800081:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800084:	c1 e0 05             	shl    $0x5,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 db                	test   %ebx,%ebx
  800093:	7e 07                	jle    80009c <libmain+0x3d>
		binaryname = argv[0];
  800095:	8b 06                	mov    (%esi),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 07 00 00 00       	call   8000b4 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	5b                   	pop    %ebx
  8000b1:	5e                   	pop    %esi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 6d 0a 00 00       	call   800b33 <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 13                	mov    (%ebx),%edx
  8000d4:	8d 42 01             	lea    0x1(%edx),%eax
  8000d7:	89 03                	mov    %eax,(%ebx)
  8000d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e5:	75 19                	jne    800100 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ee:	00 
  8000ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f2:	89 04 24             	mov    %eax,(%esp)
  8000f5:	e8 fc 09 00 00       	call   800af6 <sys_cputs>
		b->idx = 0;
  8000fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800100:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800104:	83 c4 14             	add    $0x14,%esp
  800107:	5b                   	pop    %ebx
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800113:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011a:	00 00 00 
	b.cnt = 0;
  80011d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800124:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800127:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012e:	8b 45 08             	mov    0x8(%ebp),%eax
  800131:	89 44 24 08          	mov    %eax,0x8(%esp)
  800135:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013f:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800146:	e8 b3 01 00 00       	call   8002fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800151:	89 44 24 04          	mov    %eax,0x4(%esp)
  800155:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 93 09 00 00       	call   800af6 <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	8b 45 08             	mov    0x8(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	e8 87 ff ff ff       	call   80010a <vcprintf>
	va_end(ap);

	return cnt;
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    
  800185:	66 90                	xchg   %ax,%ax
  800187:	66 90                	xchg   %ax,%ax
  800189:	66 90                	xchg   %ax,%ax
  80018b:	66 90                	xchg   %ax,%ax
  80018d:	66 90                	xchg   %ax,%ax
  80018f:	90                   	nop

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 c3                	mov    %eax,%ebx
  8001a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bd:	39 d9                	cmp    %ebx,%ecx
  8001bf:	72 05                	jb     8001c6 <printnum+0x36>
  8001c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001c4:	77 69                	ja     80022f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001cd:	83 ee 01             	sub    $0x1,%esi
  8001d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001e0:	89 c3                	mov    %eax,%ebx
  8001e2:	89 d6                	mov    %edx,%esi
  8001e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	e8 fc 09 00 00       	call   800c00 <__udivdi3>
  800204:	89 d9                	mov    %ebx,%ecx
  800206:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	89 54 24 04          	mov    %edx,0x4(%esp)
  800215:	89 fa                	mov    %edi,%edx
  800217:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021a:	e8 71 ff ff ff       	call   800190 <printnum>
  80021f:	eb 1b                	jmp    80023c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800225:	8b 45 18             	mov    0x18(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	ff d3                	call   *%ebx
  80022d:	eb 03                	jmp    800232 <printnum+0xa2>
  80022f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800232:	83 ee 01             	sub    $0x1,%esi
  800235:	85 f6                	test   %esi,%esi
  800237:	7f e8                	jg     800221 <printnum+0x91>
  800239:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800247:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80024a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800252:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	e8 cc 0a 00 00       	call   800d30 <__umoddi3>
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	0f be 80 b7 0e 80 00 	movsbl 0x800eb7(%eax),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800275:	ff d0                	call   *%eax
}
  800277:	83 c4 3c             	add    $0x3c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800282:	83 fa 01             	cmp    $0x1,%edx
  800285:	7e 0e                	jle    800295 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800287:	8b 10                	mov    (%eax),%edx
  800289:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 02                	mov    (%edx),%eax
  800290:	8b 52 04             	mov    0x4(%edx),%edx
  800293:	eb 22                	jmp    8002b7 <getuint+0x38>
	else if (lflag)
  800295:	85 d2                	test   %edx,%edx
  800297:	74 10                	je     8002a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	eb 0e                	jmp    8002b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c8:	73 0a                	jae    8002d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	88 02                	mov    %al,(%edx)
}
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 02 00 00 00       	call   8002fe <vprintfmt>
	va_end(ap);
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	57                   	push   %edi
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 3c             	sub    $0x3c,%esp
  800307:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
  80030a:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
  800311:	eb 17                	jmp    80032a <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800313:	85 c0                	test   %eax,%eax
  800315:	0f 84 ca 03 00 00    	je     8006e5 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80031b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800328:	89 fb                	mov    %edi,%ebx
  80032a:	8d 7b 01             	lea    0x1(%ebx),%edi
  80032d:	0f b6 03             	movzbl (%ebx),%eax
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	75 de                	jne    800313 <vprintfmt+0x15>
  800335:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800339:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800340:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800345:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	eb 18                	jmp    80036b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800353:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800359:	eb 10                	jmp    80036b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035d:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800361:	eb 08                	jmp    80036b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800363:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800366:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8d 5f 01             	lea    0x1(%edi),%ebx
  80036e:	0f b6 07             	movzbl (%edi),%eax
  800371:	0f b6 c8             	movzbl %al,%ecx
  800374:	83 e8 23             	sub    $0x23,%eax
  800377:	3c 55                	cmp    $0x55,%al
  800379:	0f 87 41 03 00 00    	ja     8006c0 <vprintfmt+0x3c2>
  80037f:	0f b6 c0             	movzbl %al,%eax
  800382:	ff 24 85 44 0f 80 00 	jmp    *0x800f44(,%eax,4)
  800389:	89 df                	mov    %ebx,%edi
  80038b:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800390:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800393:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800397:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039a:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80039d:	83 f8 09             	cmp    $0x9,%eax
  8003a0:	77 33                	ja     8003d5 <vprintfmt+0xd7>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a5:	eb e9                	jmp    800390 <vprintfmt+0x92>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b0:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b4:	eb 1f                	jmp    8003d5 <vprintfmt+0xd7>
  8003b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003b9:	85 c9                	test   %ecx,%ecx
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	0f 49 c1             	cmovns %ecx,%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 df                	mov    %ebx,%edi
  8003c8:	eb a1                	jmp    80036b <vprintfmt+0x6d>
  8003ca:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003cc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003d3:	eb 96                	jmp    80036b <vprintfmt+0x6d>

		process_precision:
			if (width < 0)
  8003d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d9:	79 90                	jns    80036b <vprintfmt+0x6d>
  8003db:	eb 86                	jmp    800363 <vprintfmt+0x65>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003dd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e2:	eb 87                	jmp    80036b <vprintfmt+0x6d>

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8003ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003f0:	89 74 24 04          	mov    %esi,0x4(%esp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8003f4:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8003f7:	0b 30                	or     (%eax),%esi
			putch(ch, putdat);
  8003f9:	89 34 24             	mov    %esi,(%esp)
  8003fc:	ff 55 08             	call   *0x8(%ebp)
                  	color=0x0700;
  8003ff:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
			break;
  800406:	e9 1f ff ff ff       	jmp    80032a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	89 df                	mov    %ebx,%edi
			ch=va_arg(ap,int)|color;
			putch(ch, putdat);
                  	color=0x0700;
			break;
		case 'B':
			color=0x0100;
  80040d:	c7 45 d8 00 01 00 00 	movl   $0x100,-0x28(%ebp)
			goto reswitch;
  800414:	e9 52 ff ff ff       	jmp    80036b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	89 df                	mov    %ebx,%edi
			break;
		case 'B':
			color=0x0100;
			goto reswitch;
		case 'R':
			color=0x0400;
  80041b:	c7 45 d8 00 04 00 00 	movl   $0x400,-0x28(%ebp)
			goto reswitch;
  800422:	e9 44 ff ff ff       	jmp    80036b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	89 df                	mov    %ebx,%edi
			goto reswitch;
		case 'R':
			color=0x0400;
			goto reswitch;
		case 'G':
			color=0x0200;
  800429:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
			goto reswitch;
  800430:	e9 36 ff ff ff       	jmp    80036b <vprintfmt+0x6d>
		// error message
		case 'e':
			err = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	99                   	cltd   
  800441:	31 d0                	xor    %edx,%eax
  800443:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800445:	83 f8 06             	cmp    $0x6,%eax
  800448:	7f 0b                	jg     800455 <vprintfmt+0x157>
  80044a:	8b 14 85 9c 10 80 00 	mov    0x80109c(,%eax,4),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	75 23                	jne    800478 <vprintfmt+0x17a>
				printfmt(putch, putdat, "error %d", err);
  800455:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800459:	c7 44 24 08 cf 0e 80 	movl   $0x800ecf,0x8(%esp)
  800460:	00 
  800461:	8b 45 0c             	mov    0xc(%ebp),%eax
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	8b 45 08             	mov    0x8(%ebp),%eax
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	e8 63 fe ff ff       	call   8002d6 <printfmt>
  800473:	e9 b2 fe ff ff       	jmp    80032a <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800478:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047c:	c7 44 24 08 d8 0e 80 	movl   $0x800ed8,0x8(%esp)
  800483:	00 
  800484:	8b 45 0c             	mov    0xc(%ebp),%eax
  800487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	e8 40 fe ff ff       	call   8002d6 <printfmt>
  800496:	e9 8f fe ff ff       	jmp    80032a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 c8 0e 80 00       	mov    $0x800ec8,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004ba:	0f 84 96 00 00 00    	je     800556 <vprintfmt+0x258>
  8004c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c4:	0f 8e 94 00 00 00    	jle    80055e <vprintfmt+0x260>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ce:	89 3c 24             	mov    %edi,(%esp)
  8004d1:	e8 b2 02 00 00       	call   800788 <strnlen>
  8004d6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
					putch(padc, putdat);
  8004de:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004e2:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8004e5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004eb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004ee:	89 cb                	mov    %ecx,%ebx
  8004f0:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f2:	eb 0f                	jmp    800503 <vprintfmt+0x205>
					putch(padc, putdat);
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fb:	89 3c 24             	mov    %edi,(%esp)
  8004fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 eb 01             	sub    $0x1,%ebx
  800503:	85 db                	test   %ebx,%ebx
  800505:	7f ed                	jg     8004f4 <vprintfmt+0x1f6>
  800507:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80050a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80050d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800510:	85 d2                	test   %edx,%edx
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
  800517:	0f 49 c2             	cmovns %edx,%eax
  80051a:	29 c2                	sub    %eax,%edx
  80051c:	89 d3                	mov    %edx,%ebx
  80051e:	eb 44                	jmp    800564 <vprintfmt+0x266>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800520:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800524:	74 1e                	je     800544 <vprintfmt+0x246>
  800526:	0f be d2             	movsbl %dl,%edx
  800529:	83 ea 20             	sub    $0x20,%edx
  80052c:	83 fa 5e             	cmp    $0x5e,%edx
  80052f:	76 13                	jbe    800544 <vprintfmt+0x246>
					putch('?', putdat);
  800531:	8b 45 0c             	mov    0xc(%ebp),%eax
  800534:	89 44 24 04          	mov    %eax,0x4(%esp)
  800538:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	eb 0d                	jmp    800551 <vprintfmt+0x253>
				else
					putch(ch, putdat);
  800544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800547:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800551:	83 eb 01             	sub    $0x1,%ebx
  800554:	eb 0e                	jmp    800564 <vprintfmt+0x266>
  800556:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800559:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055c:	eb 06                	jmp    800564 <vprintfmt+0x266>
  80055e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80056b:	0f be c2             	movsbl %dl,%eax
  80056e:	85 c0                	test   %eax,%eax
  800570:	74 27                	je     800599 <vprintfmt+0x29b>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 aa                	js     800520 <vprintfmt+0x222>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 a5                	jns    800520 <vprintfmt+0x222>
  80057b:	89 d8                	mov    %ebx,%eax
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800583:	89 c3                	mov    %eax,%ebx
  800585:	eb 18                	jmp    80059f <vprintfmt+0x2a1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800592:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800594:	83 eb 01             	sub    $0x1,%ebx
  800597:	eb 06                	jmp    80059f <vprintfmt+0x2a1>
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80059f:	85 db                	test   %ebx,%ebx
  8005a1:	7f e4                	jg     800587 <vprintfmt+0x289>
  8005a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a6:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005ac:	e9 79 fd ff ff       	jmp    80032a <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b1:	83 fa 01             	cmp    $0x1,%edx
  8005b4:	7e 10                	jle    8005c6 <vprintfmt+0x2c8>
		return va_arg(*ap, long long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 08             	lea    0x8(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 30                	mov    (%eax),%esi
  8005c1:	8b 78 04             	mov    0x4(%eax),%edi
  8005c4:	eb 26                	jmp    8005ec <vprintfmt+0x2ee>
	else if (lflag)
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 12                	je     8005dc <vprintfmt+0x2de>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 30                	mov    (%eax),%esi
  8005d5:	89 f7                	mov    %esi,%edi
  8005d7:	c1 ff 1f             	sar    $0x1f,%edi
  8005da:	eb 10                	jmp    8005ec <vprintfmt+0x2ee>
	else
		return va_arg(*ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 30                	mov    (%eax),%esi
  8005e7:	89 f7                	mov    %esi,%edi
  8005e9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	89 f0                	mov    %esi,%eax
  8005ee:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f5:	85 ff                	test   %edi,%edi
  8005f7:	0f 89 87 00 00 00    	jns    800684 <vprintfmt+0x386>
				putch('-', putdat);
  8005fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060e:	89 f0                	mov    %esi,%eax
  800610:	89 fa                	mov    %edi,%edx
  800612:	f7 d8                	neg    %eax
  800614:	83 d2 00             	adc    $0x0,%edx
  800617:	f7 da                	neg    %edx
			}
			base = 10;
  800619:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80061e:	eb 64                	jmp    800684 <vprintfmt+0x386>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800620:	8d 45 14             	lea    0x14(%ebp),%eax
  800623:	e8 57 fc ff ff       	call   80027f <getuint>
			base = 10;
  800628:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80062d:	eb 55                	jmp    800684 <vprintfmt+0x386>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 48 fc ff ff       	call   80027f <getuint>
			base=8;
  800637:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80063c:	eb 46                	jmp    800684 <vprintfmt+0x386>

		// pointer
		case 'p':
			putch('0', putdat);
  80063e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800641:	89 44 24 04          	mov    %eax,0x4(%esp)
  800645:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800652:	89 44 24 04          	mov    %eax,0x4(%esp)
  800656:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800670:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800675:	eb 0d                	jmp    800684 <vprintfmt+0x386>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 00 fc ff ff       	call   80027f <getuint>
			base = 16;
  80067f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800684:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800688:	89 74 24 10          	mov    %esi,0x10(%esp)
  80068c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800693:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	e8 e7 fa ff ff       	call   800190 <printnum>
			break;
  8006a9:	e9 7c fc ff ff       	jmp    80032a <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b5:	89 0c 24             	mov    %ecx,(%esp)
  8006b8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006bb:	e9 6a fc ff ff       	jmp    80032a <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d1:	89 fb                	mov    %edi,%ebx
  8006d3:	eb 03                	jmp    8006d8 <vprintfmt+0x3da>
  8006d5:	83 eb 01             	sub    $0x1,%ebx
  8006d8:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006dc:	75 f7                	jne    8006d5 <vprintfmt+0x3d7>
  8006de:	66 90                	xchg   %ax,%ax
  8006e0:	e9 45 fc ff ff       	jmp    80032a <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8006e5:	83 c4 3c             	add    $0x3c,%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 28             	sub    $0x28,%esp
  8006f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800700:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 30                	je     80073e <vsnprintf+0x51>
  80070e:	85 d2                	test   %edx,%edx
  800710:	7e 2c                	jle    80073e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800719:	8b 45 10             	mov    0x10(%ebp),%eax
  80071c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	c7 04 24 b9 02 80 00 	movl   $0x8002b9,(%esp)
  80072e:	e8 cb fb ff ff       	call   8002fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800733:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800736:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073c:	eb 05                	jmp    800743 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800752:	8b 45 10             	mov    0x10(%ebp),%eax
  800755:	89 44 24 08          	mov    %eax,0x8(%esp)
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	e8 82 ff ff ff       	call   8006ed <vsnprintf>
	va_end(ap);

	return rc;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    
  80076d:	66 90                	xchg   %ax,%ax
  80076f:	90                   	nop

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	eb 03                	jmp    800780 <strlen+0x10>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800780:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800784:	75 f7                	jne    80077d <strlen+0xd>
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	eb 03                	jmp    80079b <strnlen+0x13>
		n++;
  800798:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 06                	je     8007a5 <strnlen+0x1d>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	75 f3                	jne    800798 <strnlen+0x10>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	83 c2 01             	add    $0x1,%edx
  8007b6:	83 c1 01             	add    $0x1,%ecx
  8007b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c0:	84 db                	test   %bl,%bl
  8007c2:	75 ef                	jne    8007b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d1:	89 1c 24             	mov    %ebx,(%esp)
  8007d4:	e8 97 ff ff ff       	call   800770 <strlen>
	strcpy(dst + len, src);
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e0:	01 d8                	add    %ebx,%eax
  8007e2:	89 04 24             	mov    %eax,(%esp)
  8007e5:	e8 bd ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007ea:	89 d8                	mov    %ebx,%eax
  8007ec:	83 c4 08             	add    $0x8,%esp
  8007ef:	5b                   	pop    %ebx
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	89 f3                	mov    %esi,%ebx
  8007ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800802:	89 f2                	mov    %esi,%edx
  800804:	eb 0f                	jmp    800815 <strncpy+0x23>
		*dst++ = *src;
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	0f b6 01             	movzbl (%ecx),%eax
  80080c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080f:	80 39 01             	cmpb   $0x1,(%ecx)
  800812:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800815:	39 da                	cmp    %ebx,%edx
  800817:	75 ed                	jne    800806 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800819:	89 f0                	mov    %esi,%eax
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	8b 75 08             	mov    0x8(%ebp),%esi
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80082d:	89 f0                	mov    %esi,%eax
  80082f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800833:	85 c9                	test   %ecx,%ecx
  800835:	75 0b                	jne    800842 <strlcpy+0x23>
  800837:	eb 1d                	jmp    800856 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800842:	39 d8                	cmp    %ebx,%eax
  800844:	74 0b                	je     800851 <strlcpy+0x32>
  800846:	0f b6 0a             	movzbl (%edx),%ecx
  800849:	84 c9                	test   %cl,%cl
  80084b:	75 ec                	jne    800839 <strlcpy+0x1a>
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	eb 02                	jmp    800853 <strlcpy+0x34>
  800851:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800853:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800856:	29 f0                	sub    %esi,%eax
}
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800865:	eb 06                	jmp    80086d <strcmp+0x11>
		p++, q++;
  800867:	83 c1 01             	add    $0x1,%ecx
  80086a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086d:	0f b6 01             	movzbl (%ecx),%eax
  800870:	84 c0                	test   %al,%al
  800872:	74 04                	je     800878 <strcmp+0x1c>
  800874:	3a 02                	cmp    (%edx),%al
  800876:	74 ef                	je     800867 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800878:	0f b6 c0             	movzbl %al,%eax
  80087b:	0f b6 12             	movzbl (%edx),%edx
  80087e:	29 d0                	sub    %edx,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 c3                	mov    %eax,%ebx
  80088e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800891:	eb 06                	jmp    800899 <strncmp+0x17>
		n--, p++, q++;
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800899:	39 d8                	cmp    %ebx,%eax
  80089b:	74 15                	je     8008b2 <strncmp+0x30>
  80089d:	0f b6 08             	movzbl (%eax),%ecx
  8008a0:	84 c9                	test   %cl,%cl
  8008a2:	74 04                	je     8008a8 <strncmp+0x26>
  8008a4:	3a 0a                	cmp    (%edx),%cl
  8008a6:	74 eb                	je     800893 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 00             	movzbl (%eax),%eax
  8008ab:	0f b6 12             	movzbl (%edx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
  8008b0:	eb 05                	jmp    8008b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	eb 07                	jmp    8008cd <strchr+0x13>
		if (*s == c)
  8008c6:	38 ca                	cmp    %cl,%dl
  8008c8:	74 0f                	je     8008d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	0f b6 10             	movzbl (%eax),%edx
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f2                	jne    8008c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 07                	jmp    8008ee <strfind+0x13>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 0a                	je     8008f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f2                	jne    8008e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800903:	85 c9                	test   %ecx,%ecx
  800905:	74 36                	je     80093d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800907:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090d:	75 28                	jne    800937 <memset+0x40>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 23                	jne    800937 <memset+0x40>
		c &= 0xFF;
  800914:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800918:	89 d3                	mov    %edx,%ebx
  80091a:	c1 e3 08             	shl    $0x8,%ebx
  80091d:	89 d6                	mov    %edx,%esi
  80091f:	c1 e6 18             	shl    $0x18,%esi
  800922:	89 d0                	mov    %edx,%eax
  800924:	c1 e0 10             	shl    $0x10,%eax
  800927:	09 f0                	or     %esi,%eax
  800929:	09 c2                	or     %eax,%edx
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800932:	fc                   	cld    
  800933:	f3 ab                	rep stos %eax,%es:(%edi)
  800935:	eb 06                	jmp    80093d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	fc                   	cld    
  80093b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5f                   	pop    %edi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800952:	39 c6                	cmp    %eax,%esi
  800954:	73 35                	jae    80098b <memmove+0x47>
  800956:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800959:	39 d0                	cmp    %edx,%eax
  80095b:	73 2e                	jae    80098b <memmove+0x47>
		s += n;
		d += n;
  80095d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800960:	89 d6                	mov    %edx,%esi
  800962:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096a:	75 13                	jne    80097f <memmove+0x3b>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 0e                	jne    80097f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800971:	83 ef 04             	sub    $0x4,%edi
  800974:	8d 72 fc             	lea    -0x4(%edx),%esi
  800977:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097a:	fd                   	std    
  80097b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097d:	eb 09                	jmp    800988 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097f:	83 ef 01             	sub    $0x1,%edi
  800982:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800985:	fd                   	std    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800988:	fc                   	cld    
  800989:	eb 1d                	jmp    8009a8 <memmove+0x64>
  80098b:	89 f2                	mov    %esi,%edx
  80098d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	f6 c2 03             	test   $0x3,%dl
  800992:	75 0f                	jne    8009a3 <memmove+0x5f>
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 0a                	jne    8009a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800999:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a1:	eb 05                	jmp    8009a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a3:	89 c7                	mov    %eax,%edi
  8009a5:	fc                   	cld    
  8009a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a8:	5e                   	pop    %esi
  8009a9:	5f                   	pop    %edi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	e8 79 ff ff ff       	call   800944 <memmove>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d8:	89 d6                	mov    %edx,%esi
  8009da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dd:	eb 1a                	jmp    8009f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009df:	0f b6 02             	movzbl (%edx),%eax
  8009e2:	0f b6 19             	movzbl (%ecx),%ebx
  8009e5:	38 d8                	cmp    %bl,%al
  8009e7:	74 0a                	je     8009f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e9:	0f b6 c0             	movzbl %al,%eax
  8009ec:	0f b6 db             	movzbl %bl,%ebx
  8009ef:	29 d8                	sub    %ebx,%eax
  8009f1:	eb 0f                	jmp    800a02 <memcmp+0x35>
		s1++, s2++;
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f2                	cmp    %esi,%edx
  8009fb:	75 e2                	jne    8009df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0f:	89 c2                	mov    %eax,%edx
  800a11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a14:	eb 07                	jmp    800a1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	38 08                	cmp    %cl,(%eax)
  800a18:	74 07                	je     800a21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	72 f5                	jb     800a16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	eb 03                	jmp    800a34 <strtol+0x11>
		s++;
  800a31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	0f b6 0a             	movzbl (%edx),%ecx
  800a37:	80 f9 09             	cmp    $0x9,%cl
  800a3a:	74 f5                	je     800a31 <strtol+0xe>
  800a3c:	80 f9 20             	cmp    $0x20,%cl
  800a3f:	74 f0                	je     800a31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a41:	80 f9 2b             	cmp    $0x2b,%cl
  800a44:	75 0a                	jne    800a50 <strtol+0x2d>
		s++;
  800a46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb 11                	jmp    800a61 <strtol+0x3e>
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a55:	80 f9 2d             	cmp    $0x2d,%cl
  800a58:	75 07                	jne    800a61 <strtol+0x3e>
		s++, neg = 1;
  800a5a:	8d 52 01             	lea    0x1(%edx),%edx
  800a5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a66:	75 15                	jne    800a7d <strtol+0x5a>
  800a68:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6b:	75 10                	jne    800a7d <strtol+0x5a>
  800a6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a71:	75 0a                	jne    800a7d <strtol+0x5a>
		s += 2, base = 16;
  800a73:	83 c2 02             	add    $0x2,%edx
  800a76:	b8 10 00 00 00       	mov    $0x10,%eax
  800a7b:	eb 10                	jmp    800a8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	75 0c                	jne    800a8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a83:	80 3a 30             	cmpb   $0x30,(%edx)
  800a86:	75 05                	jne    800a8d <strtol+0x6a>
		s++, base = 8;
  800a88:	83 c2 01             	add    $0x1,%edx
  800a8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800a8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 0a             	movzbl (%edx),%ecx
  800a98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a9b:	89 f0                	mov    %esi,%eax
  800a9d:	3c 09                	cmp    $0x9,%al
  800a9f:	77 08                	ja     800aa9 <strtol+0x86>
			dig = *s - '0';
  800aa1:	0f be c9             	movsbl %cl,%ecx
  800aa4:	83 e9 30             	sub    $0x30,%ecx
  800aa7:	eb 20                	jmp    800ac9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aac:	89 f0                	mov    %esi,%eax
  800aae:	3c 19                	cmp    $0x19,%al
  800ab0:	77 08                	ja     800aba <strtol+0x97>
			dig = *s - 'a' + 10;
  800ab2:	0f be c9             	movsbl %cl,%ecx
  800ab5:	83 e9 57             	sub    $0x57,%ecx
  800ab8:	eb 0f                	jmp    800ac9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800abd:	89 f0                	mov    %esi,%eax
  800abf:	3c 19                	cmp    $0x19,%al
  800ac1:	77 16                	ja     800ad9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ac3:	0f be c9             	movsbl %cl,%ecx
  800ac6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800acc:	7d 0f                	jge    800add <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800ace:	83 c2 01             	add    $0x1,%edx
  800ad1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ad5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ad7:	eb bc                	jmp    800a95 <strtol+0x72>
  800ad9:	89 d8                	mov    %ebx,%eax
  800adb:	eb 02                	jmp    800adf <strtol+0xbc>
  800add:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae3:	74 05                	je     800aea <strtol+0xc7>
		*endptr = (char *) s;
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800aea:	f7 d8                	neg    %eax
  800aec:	85 ff                	test   %edi,%edi
  800aee:	0f 44 c3             	cmove  %ebx,%eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	89 c3                	mov    %eax,%ebx
  800b09:	89 c7                	mov    %eax,%edi
  800b0b:	89 c6                	mov    %eax,%esi
  800b0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b24:	89 d1                	mov    %edx,%ecx
  800b26:	89 d3                	mov    %edx,%ebx
  800b28:	89 d7                	mov    %edx,%edi
  800b2a:	89 d6                	mov    %edx,%esi
  800b2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b41:	b8 03 00 00 00       	mov    $0x3,%eax
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 cb                	mov    %ecx,%ebx
  800b4b:	89 cf                	mov    %ecx,%edi
  800b4d:	89 ce                	mov    %ecx,%esi
  800b4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	7e 28                	jle    800b7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b60:	00 
  800b61:	c7 44 24 08 b8 10 80 	movl   $0x8010b8,0x8(%esp)
  800b68:	00 
  800b69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b70:	00 
  800b71:	c7 04 24 d5 10 80 00 	movl   $0x8010d5,(%esp)
  800b78:	e8 27 00 00 00       	call   800ba4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7d:	83 c4 2c             	add    $0x2c,%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 02 00 00 00       	mov    $0x2,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800bac:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800baf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800bb5:	e8 cb ff ff ff       	call   800b85 <sys_getenvid>
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bc8:	89 74 24 08          	mov    %esi,0x8(%esp)
  800bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd0:	c7 04 24 e4 10 80 00 	movl   $0x8010e4,(%esp)
  800bd7:	e8 8f f5 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bdc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800be0:	8b 45 10             	mov    0x10(%ebp),%eax
  800be3:	89 04 24             	mov    %eax,(%esp)
  800be6:	e8 1f f5 ff ff       	call   80010a <vcprintf>
	cprintf("\n");
  800beb:	c7 04 24 94 0e 80 00 	movl   $0x800e94,(%esp)
  800bf2:	e8 74 f5 ff ff       	call   80016b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bf7:	cc                   	int3   
  800bf8:	eb fd                	jmp    800bf7 <_panic+0x53>
  800bfa:	66 90                	xchg   %ax,%ax
  800bfc:	66 90                	xchg   %ax,%ax
  800bfe:	66 90                	xchg   %ax,%ax

00800c00 <__udivdi3>:
  800c00:	55                   	push   %ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	8b 44 24 28          	mov    0x28(%esp),%eax
  800c0a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800c0e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800c12:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800c16:	85 c0                	test   %eax,%eax
  800c18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c1c:	89 ea                	mov    %ebp,%edx
  800c1e:	89 0c 24             	mov    %ecx,(%esp)
  800c21:	75 2d                	jne    800c50 <__udivdi3+0x50>
  800c23:	39 e9                	cmp    %ebp,%ecx
  800c25:	77 61                	ja     800c88 <__udivdi3+0x88>
  800c27:	85 c9                	test   %ecx,%ecx
  800c29:	89 ce                	mov    %ecx,%esi
  800c2b:	75 0b                	jne    800c38 <__udivdi3+0x38>
  800c2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c32:	31 d2                	xor    %edx,%edx
  800c34:	f7 f1                	div    %ecx
  800c36:	89 c6                	mov    %eax,%esi
  800c38:	31 d2                	xor    %edx,%edx
  800c3a:	89 e8                	mov    %ebp,%eax
  800c3c:	f7 f6                	div    %esi
  800c3e:	89 c5                	mov    %eax,%ebp
  800c40:	89 f8                	mov    %edi,%eax
  800c42:	f7 f6                	div    %esi
  800c44:	89 ea                	mov    %ebp,%edx
  800c46:	83 c4 0c             	add    $0xc,%esp
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    
  800c4d:	8d 76 00             	lea    0x0(%esi),%esi
  800c50:	39 e8                	cmp    %ebp,%eax
  800c52:	77 24                	ja     800c78 <__udivdi3+0x78>
  800c54:	0f bd e8             	bsr    %eax,%ebp
  800c57:	83 f5 1f             	xor    $0x1f,%ebp
  800c5a:	75 3c                	jne    800c98 <__udivdi3+0x98>
  800c5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c60:	39 34 24             	cmp    %esi,(%esp)
  800c63:	0f 86 9f 00 00 00    	jbe    800d08 <__udivdi3+0x108>
  800c69:	39 d0                	cmp    %edx,%eax
  800c6b:	0f 82 97 00 00 00    	jb     800d08 <__udivdi3+0x108>
  800c71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c78:	31 d2                	xor    %edx,%edx
  800c7a:	31 c0                	xor    %eax,%eax
  800c7c:	83 c4 0c             	add    $0xc,%esp
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
  800c83:	90                   	nop
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	89 f8                	mov    %edi,%eax
  800c8a:	f7 f1                	div    %ecx
  800c8c:	31 d2                	xor    %edx,%edx
  800c8e:	83 c4 0c             	add    $0xc,%esp
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    
  800c95:	8d 76 00             	lea    0x0(%esi),%esi
  800c98:	89 e9                	mov    %ebp,%ecx
  800c9a:	8b 3c 24             	mov    (%esp),%edi
  800c9d:	d3 e0                	shl    %cl,%eax
  800c9f:	89 c6                	mov    %eax,%esi
  800ca1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ca6:	29 e8                	sub    %ebp,%eax
  800ca8:	89 c1                	mov    %eax,%ecx
  800caa:	d3 ef                	shr    %cl,%edi
  800cac:	89 e9                	mov    %ebp,%ecx
  800cae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cb2:	8b 3c 24             	mov    (%esp),%edi
  800cb5:	09 74 24 08          	or     %esi,0x8(%esp)
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	d3 e7                	shl    %cl,%edi
  800cbd:	89 c1                	mov    %eax,%ecx
  800cbf:	89 3c 24             	mov    %edi,(%esp)
  800cc2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cc6:	d3 ee                	shr    %cl,%esi
  800cc8:	89 e9                	mov    %ebp,%ecx
  800cca:	d3 e2                	shl    %cl,%edx
  800ccc:	89 c1                	mov    %eax,%ecx
  800cce:	d3 ef                	shr    %cl,%edi
  800cd0:	09 d7                	or     %edx,%edi
  800cd2:	89 f2                	mov    %esi,%edx
  800cd4:	89 f8                	mov    %edi,%eax
  800cd6:	f7 74 24 08          	divl   0x8(%esp)
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	f7 24 24             	mull   (%esp)
  800ce1:	39 d6                	cmp    %edx,%esi
  800ce3:	89 14 24             	mov    %edx,(%esp)
  800ce6:	72 30                	jb     800d18 <__udivdi3+0x118>
  800ce8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cec:	89 e9                	mov    %ebp,%ecx
  800cee:	d3 e2                	shl    %cl,%edx
  800cf0:	39 c2                	cmp    %eax,%edx
  800cf2:	73 05                	jae    800cf9 <__udivdi3+0xf9>
  800cf4:	3b 34 24             	cmp    (%esp),%esi
  800cf7:	74 1f                	je     800d18 <__udivdi3+0x118>
  800cf9:	89 f8                	mov    %edi,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	e9 7a ff ff ff       	jmp    800c7c <__udivdi3+0x7c>
  800d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d08:	31 d2                	xor    %edx,%edx
  800d0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0f:	e9 68 ff ff ff       	jmp    800c7c <__udivdi3+0x7c>
  800d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d18:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	83 c4 0c             	add    $0xc,%esp
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
  800d24:	66 90                	xchg   %ax,%ax
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	83 ec 14             	sub    $0x14,%esp
  800d36:	8b 44 24 28          	mov    0x28(%esp),%eax
  800d3a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800d3e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800d42:	89 c7                	mov    %eax,%edi
  800d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d48:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d4c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d50:	89 34 24             	mov    %esi,(%esp)
  800d53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	89 c2                	mov    %eax,%edx
  800d5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d5f:	75 17                	jne    800d78 <__umoddi3+0x48>
  800d61:	39 fe                	cmp    %edi,%esi
  800d63:	76 4b                	jbe    800db0 <__umoddi3+0x80>
  800d65:	89 c8                	mov    %ecx,%eax
  800d67:	89 fa                	mov    %edi,%edx
  800d69:	f7 f6                	div    %esi
  800d6b:	89 d0                	mov    %edx,%eax
  800d6d:	31 d2                	xor    %edx,%edx
  800d6f:	83 c4 14             	add    $0x14,%esp
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
  800d76:	66 90                	xchg   %ax,%ax
  800d78:	39 f8                	cmp    %edi,%eax
  800d7a:	77 54                	ja     800dd0 <__umoddi3+0xa0>
  800d7c:	0f bd e8             	bsr    %eax,%ebp
  800d7f:	83 f5 1f             	xor    $0x1f,%ebp
  800d82:	75 5c                	jne    800de0 <__umoddi3+0xb0>
  800d84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d88:	39 3c 24             	cmp    %edi,(%esp)
  800d8b:	0f 87 e7 00 00 00    	ja     800e78 <__umoddi3+0x148>
  800d91:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d95:	29 f1                	sub    %esi,%ecx
  800d97:	19 c7                	sbb    %eax,%edi
  800d99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d9d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800da1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800da9:	83 c4 14             	add    $0x14,%esp
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    
  800db0:	85 f6                	test   %esi,%esi
  800db2:	89 f5                	mov    %esi,%ebp
  800db4:	75 0b                	jne    800dc1 <__umoddi3+0x91>
  800db6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	f7 f6                	div    %esi
  800dbf:	89 c5                	mov    %eax,%ebp
  800dc1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dc5:	31 d2                	xor    %edx,%edx
  800dc7:	f7 f5                	div    %ebp
  800dc9:	89 c8                	mov    %ecx,%eax
  800dcb:	f7 f5                	div    %ebp
  800dcd:	eb 9c                	jmp    800d6b <__umoddi3+0x3b>
  800dcf:	90                   	nop
  800dd0:	89 c8                	mov    %ecx,%eax
  800dd2:	89 fa                	mov    %edi,%edx
  800dd4:	83 c4 14             	add    $0x14,%esp
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    
  800ddb:	90                   	nop
  800ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de0:	8b 04 24             	mov    (%esp),%eax
  800de3:	be 20 00 00 00       	mov    $0x20,%esi
  800de8:	89 e9                	mov    %ebp,%ecx
  800dea:	29 ee                	sub    %ebp,%esi
  800dec:	d3 e2                	shl    %cl,%edx
  800dee:	89 f1                	mov    %esi,%ecx
  800df0:	d3 e8                	shr    %cl,%eax
  800df2:	89 e9                	mov    %ebp,%ecx
  800df4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df8:	8b 04 24             	mov    (%esp),%eax
  800dfb:	09 54 24 04          	or     %edx,0x4(%esp)
  800dff:	89 fa                	mov    %edi,%edx
  800e01:	d3 e0                	shl    %cl,%eax
  800e03:	89 f1                	mov    %esi,%ecx
  800e05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e09:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e0d:	d3 ea                	shr    %cl,%edx
  800e0f:	89 e9                	mov    %ebp,%ecx
  800e11:	d3 e7                	shl    %cl,%edi
  800e13:	89 f1                	mov    %esi,%ecx
  800e15:	d3 e8                	shr    %cl,%eax
  800e17:	89 e9                	mov    %ebp,%ecx
  800e19:	09 f8                	or     %edi,%eax
  800e1b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800e1f:	f7 74 24 04          	divl   0x4(%esp)
  800e23:	d3 e7                	shl    %cl,%edi
  800e25:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e29:	89 d7                	mov    %edx,%edi
  800e2b:	f7 64 24 08          	mull   0x8(%esp)
  800e2f:	39 d7                	cmp    %edx,%edi
  800e31:	89 c1                	mov    %eax,%ecx
  800e33:	89 14 24             	mov    %edx,(%esp)
  800e36:	72 2c                	jb     800e64 <__umoddi3+0x134>
  800e38:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  800e3c:	72 22                	jb     800e60 <__umoddi3+0x130>
  800e3e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e42:	29 c8                	sub    %ecx,%eax
  800e44:	19 d7                	sbb    %edx,%edi
  800e46:	89 e9                	mov    %ebp,%ecx
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	d3 e8                	shr    %cl,%eax
  800e4c:	89 f1                	mov    %esi,%ecx
  800e4e:	d3 e2                	shl    %cl,%edx
  800e50:	89 e9                	mov    %ebp,%ecx
  800e52:	d3 ef                	shr    %cl,%edi
  800e54:	09 d0                	or     %edx,%eax
  800e56:	89 fa                	mov    %edi,%edx
  800e58:	83 c4 14             	add    $0x14,%esp
  800e5b:	5e                   	pop    %esi
  800e5c:	5f                   	pop    %edi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    
  800e5f:	90                   	nop
  800e60:	39 d7                	cmp    %edx,%edi
  800e62:	75 da                	jne    800e3e <__umoddi3+0x10e>
  800e64:	8b 14 24             	mov    (%esp),%edx
  800e67:	89 c1                	mov    %eax,%ecx
  800e69:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  800e6d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  800e71:	eb cb                	jmp    800e3e <__umoddi3+0x10e>
  800e73:	90                   	nop
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e7c:	0f 82 0f ff ff ff    	jb     800d91 <__umoddi3+0x61>
  800e82:	e9 1a ff ff ff       	jmp    800da1 <__umoddi3+0x71>
