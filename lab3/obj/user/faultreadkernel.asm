
obj/user/faultreadkernel：     文件格式 elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  800049:	e8 0e 01 00 00       	call   80015c <cprintf>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800065:	00 00 00 
	thisenv=envs+ENVX(sys_getenvid());
  800068:	e8 08 0b 00 00       	call   800b75 <sys_getenvid>
  80006d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800072:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800075:	c1 e0 05             	shl    $0x5,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x3d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800091:	89 1c 24             	mov    %ebx,(%esp)
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 07 00 00 00       	call   8000a5 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 6c 0a 00 00       	call   800b23 <sys_env_destroy>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 14             	sub    $0x14,%esp
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c3:	8b 13                	mov    (%ebx),%edx
  8000c5:	8d 42 01             	lea    0x1(%edx),%eax
  8000c8:	89 03                	mov    %eax,(%ebx)
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d6:	75 19                	jne    8000f1 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000df:	00 
  8000e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 fb 09 00 00       	call   800ae6 <sys_cputs>
		b->idx = 0;
  8000eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	83 c4 14             	add    $0x14,%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011f:	8b 45 08             	mov    0x8(%ebp),%eax
  800122:	89 44 24 08          	mov    %eax,0x8(%esp)
  800126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 b9 00 80 00 	movl   $0x8000b9,(%esp)
  800137:	e8 b2 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 92 09 00 00       	call   800ae6 <sys_cputs>

	return b.cnt;
}
  800154:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800162:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	8b 45 08             	mov    0x8(%ebp),%eax
  80016c:	89 04 24             	mov    %eax,(%esp)
  80016f:	e8 87 ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    
  800176:	66 90                	xchg   %ax,%ax
  800178:	66 90                	xchg   %ax,%ax
  80017a:	66 90                	xchg   %ax,%ax
  80017c:	66 90                	xchg   %ax,%ax
  80017e:	66 90                	xchg   %ax,%ax

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 c3                	mov    %eax,%ebx
  800199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ad:	39 d9                	cmp    %ebx,%ecx
  8001af:	72 05                	jb     8001b6 <printnum+0x36>
  8001b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b4:	77 69                	ja     80021f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001bd:	83 ee 01             	sub    $0x1,%esi
  8001c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001d0:	89 c3                	mov    %eax,%ebx
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ef:	e8 fc 09 00 00       	call   800bf0 <__udivdi3>
  8001f4:	89 d9                	mov    %ebx,%ecx
  8001f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	89 54 24 04          	mov    %edx,0x4(%esp)
  800205:	89 fa                	mov    %edi,%edx
  800207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020a:	e8 71 ff ff ff       	call   800180 <printnum>
  80020f:	eb 1b                	jmp    80022c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800215:	8b 45 18             	mov    0x18(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	ff d3                	call   *%ebx
  80021d:	eb 03                	jmp    800222 <printnum+0xa2>
  80021f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 ee 01             	sub    $0x1,%esi
  800225:	85 f6                	test   %esi,%esi
  800227:	7f e8                	jg     800211 <printnum+0x91>
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800230:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800234:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800237:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80023a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 cc 0a 00 00       	call   800d20 <__umoddi3>
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	0f be 80 a9 0e 80 00 	movsbl 0x800ea9(%eax),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800265:	ff d0                	call   *%eax
}
  800267:	83 c4 3c             	add    $0x3c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800272:	83 fa 01             	cmp    $0x1,%edx
  800275:	7e 0e                	jle    800285 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	8b 52 04             	mov    0x4(%edx),%edx
  800283:	eb 22                	jmp    8002a7 <getuint+0x38>
	else if (lflag)
  800285:	85 d2                	test   %edx,%edx
  800287:	74 10                	je     800299 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	eb 0e                	jmp    8002a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	88 02                	mov    %al,(%edx)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	e8 02 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 3c             	sub    $0x3c,%esp
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
  8002fa:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
  800301:	eb 17                	jmp    80031a <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800303:	85 c0                	test   %eax,%eax
  800305:	0f 84 ca 03 00 00    	je     8006d5 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80030b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	register int color=0x0700;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800318:	89 fb                	mov    %edi,%ebx
  80031a:	8d 7b 01             	lea    0x1(%ebx),%edi
  80031d:	0f b6 03             	movzbl (%ebx),%eax
  800320:	83 f8 25             	cmp    $0x25,%eax
  800323:	75 de                	jne    800303 <vprintfmt+0x15>
  800325:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800329:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800330:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800335:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80033c:	ba 00 00 00 00       	mov    $0x0,%edx
  800341:	eb 18                	jmp    80035b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800345:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800349:	eb 10                	jmp    80035b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034d:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800351:	eb 08                	jmp    80035b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800353:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800356:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8d 5f 01             	lea    0x1(%edi),%ebx
  80035e:	0f b6 07             	movzbl (%edi),%eax
  800361:	0f b6 c8             	movzbl %al,%ecx
  800364:	83 e8 23             	sub    $0x23,%eax
  800367:	3c 55                	cmp    $0x55,%al
  800369:	0f 87 41 03 00 00    	ja     8006b0 <vprintfmt+0x3c2>
  80036f:	0f b6 c0             	movzbl %al,%eax
  800372:	ff 24 85 38 0f 80 00 	jmp    *0x800f38(,%eax,4)
  800379:	89 df                	mov    %ebx,%edi
  80037b:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800380:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800383:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800387:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80038a:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80038d:	83 f8 09             	cmp    $0x9,%eax
  800390:	77 33                	ja     8003c5 <vprintfmt+0xd7>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800392:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800395:	eb e9                	jmp    800380 <vprintfmt+0x92>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 48 04             	lea    0x4(%eax),%ecx
  80039d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a0:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a4:	eb 1f                	jmp    8003c5 <vprintfmt+0xd7>
  8003a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a9:	85 c9                	test   %ecx,%ecx
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	0f 49 c1             	cmovns %ecx,%eax
  8003b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 df                	mov    %ebx,%edi
  8003b8:	eb a1                	jmp    80035b <vprintfmt+0x6d>
  8003ba:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003c3:	eb 96                	jmp    80035b <vprintfmt+0x6d>

		process_precision:
			if (width < 0)
  8003c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c9:	79 90                	jns    80035b <vprintfmt+0x6d>
  8003cb:	eb 86                	jmp    800353 <vprintfmt+0x65>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d2:	eb 87                	jmp    80035b <vprintfmt+0x6d>

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8003dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003e0:	89 74 24 04          	mov    %esi,0x4(%esp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			ch=va_arg(ap,int)|color;
  8003e4:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8003e7:	0b 30                	or     (%eax),%esi
			putch(ch, putdat);
  8003e9:	89 34 24             	mov    %esi,(%esp)
  8003ec:	ff 55 08             	call   *0x8(%ebp)
                  	color=0x0700;
  8003ef:	c7 45 d8 00 07 00 00 	movl   $0x700,-0x28(%ebp)
			break;
  8003f6:	e9 1f ff ff ff       	jmp    80031a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	89 df                	mov    %ebx,%edi
			ch=va_arg(ap,int)|color;
			putch(ch, putdat);
                  	color=0x0700;
			break;
		case 'B':
			color=0x0100;
  8003fd:	c7 45 d8 00 01 00 00 	movl   $0x100,-0x28(%ebp)
			goto reswitch;
  800404:	e9 52 ff ff ff       	jmp    80035b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	89 df                	mov    %ebx,%edi
			break;
		case 'B':
			color=0x0100;
			goto reswitch;
		case 'R':
			color=0x0400;
  80040b:	c7 45 d8 00 04 00 00 	movl   $0x400,-0x28(%ebp)
			goto reswitch;
  800412:	e9 44 ff ff ff       	jmp    80035b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	89 df                	mov    %ebx,%edi
			goto reswitch;
		case 'R':
			color=0x0400;
			goto reswitch;
		case 'G':
			color=0x0200;
  800419:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
			goto reswitch;
  800420:	e9 36 ff ff ff       	jmp    80035b <vprintfmt+0x6d>
		// error message
		case 'e':
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 06             	cmp    $0x6,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x157>
  80043a:	8b 14 85 90 10 80 00 	mov    0x801090(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 23                	jne    800468 <vprintfmt+0x17a>
				printfmt(putch, putdat, "error %d", err);
  800445:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800449:	c7 44 24 08 c1 0e 80 	movl   $0x800ec1,0x8(%esp)
  800450:	00 
  800451:	8b 45 0c             	mov    0xc(%ebp),%eax
  800454:	89 44 24 04          	mov    %eax,0x4(%esp)
  800458:	8b 45 08             	mov    0x8(%ebp),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	e8 63 fe ff ff       	call   8002c6 <printfmt>
  800463:	e9 b2 fe ff ff       	jmp    80031a <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046c:	c7 44 24 08 ca 0e 80 	movl   $0x800eca,0x8(%esp)
  800473:	00 
  800474:	8b 45 0c             	mov    0xc(%ebp),%eax
  800477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	89 04 24             	mov    %eax,(%esp)
  800481:	e8 40 fe ff ff       	call   8002c6 <printfmt>
  800486:	e9 8f fe ff ff       	jmp    80031a <vprintfmt+0x2c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049c:	85 ff                	test   %edi,%edi
  80049e:	b8 ba 0e 80 00       	mov    $0x800eba,%eax
  8004a3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a6:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004aa:	0f 84 96 00 00 00    	je     800546 <vprintfmt+0x258>
  8004b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b4:	0f 8e 94 00 00 00    	jle    80054e <vprintfmt+0x260>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004be:	89 3c 24             	mov    %edi,(%esp)
  8004c1:	e8 b2 02 00 00       	call   800778 <strnlen>
  8004c6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004c9:	29 c1                	sub    %eax,%ecx
  8004cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
					putch(padc, putdat);
  8004ce:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004d2:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8004d5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004db:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004de:	89 cb                	mov    %ecx,%ebx
  8004e0:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e2:	eb 0f                	jmp    8004f3 <vprintfmt+0x205>
					putch(padc, putdat);
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004eb:	89 3c 24             	mov    %edi,(%esp)
  8004ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 eb 01             	sub    $0x1,%ebx
  8004f3:	85 db                	test   %ebx,%ebx
  8004f5:	7f ed                	jg     8004e4 <vprintfmt+0x1f6>
  8004f7:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8004fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c2             	cmovns %edx,%eax
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 d3                	mov    %edx,%ebx
  80050e:	eb 44                	jmp    800554 <vprintfmt+0x266>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	74 1e                	je     800534 <vprintfmt+0x246>
  800516:	0f be d2             	movsbl %dl,%edx
  800519:	83 ea 20             	sub    $0x20,%edx
  80051c:	83 fa 5e             	cmp    $0x5e,%edx
  80051f:	76 13                	jbe    800534 <vprintfmt+0x246>
					putch('?', putdat);
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
  800524:	89 44 24 04          	mov    %eax,0x4(%esp)
  800528:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
  800532:	eb 0d                	jmp    800541 <vprintfmt+0x253>
				else
					putch(ch, putdat);
  800534:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800537:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800541:	83 eb 01             	sub    $0x1,%ebx
  800544:	eb 0e                	jmp    800554 <vprintfmt+0x266>
  800546:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800549:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054c:	eb 06                	jmp    800554 <vprintfmt+0x266>
  80054e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800551:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800554:	83 c7 01             	add    $0x1,%edi
  800557:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80055b:	0f be c2             	movsbl %dl,%eax
  80055e:	85 c0                	test   %eax,%eax
  800560:	74 27                	je     800589 <vprintfmt+0x29b>
  800562:	85 f6                	test   %esi,%esi
  800564:	78 aa                	js     800510 <vprintfmt+0x222>
  800566:	83 ee 01             	sub    $0x1,%esi
  800569:	79 a5                	jns    800510 <vprintfmt+0x222>
  80056b:	89 d8                	mov    %ebx,%eax
  80056d:	8b 75 08             	mov    0x8(%ebp),%esi
  800570:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800573:	89 c3                	mov    %eax,%ebx
  800575:	eb 18                	jmp    80058f <vprintfmt+0x2a1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800577:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800582:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	eb 06                	jmp    80058f <vprintfmt+0x2a1>
  800589:	8b 75 08             	mov    0x8(%ebp),%esi
  80058c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058f:	85 db                	test   %ebx,%ebx
  800591:	7f e4                	jg     800577 <vprintfmt+0x289>
  800593:	89 75 08             	mov    %esi,0x8(%ebp)
  800596:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800599:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059c:	e9 79 fd ff ff       	jmp    80031a <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a1:	83 fa 01             	cmp    $0x1,%edx
  8005a4:	7e 10                	jle    8005b6 <vprintfmt+0x2c8>
		return va_arg(*ap, long long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 30                	mov    (%eax),%esi
  8005b1:	8b 78 04             	mov    0x4(%eax),%edi
  8005b4:	eb 26                	jmp    8005dc <vprintfmt+0x2ee>
	else if (lflag)
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	74 12                	je     8005cc <vprintfmt+0x2de>
		return va_arg(*ap, long);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c3:	8b 30                	mov    (%eax),%esi
  8005c5:	89 f7                	mov    %esi,%edi
  8005c7:	c1 ff 1f             	sar    $0x1f,%edi
  8005ca:	eb 10                	jmp    8005dc <vprintfmt+0x2ee>
	else
		return va_arg(*ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 30                	mov    (%eax),%esi
  8005d7:	89 f7                	mov    %esi,%edi
  8005d9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	89 f0                	mov    %esi,%eax
  8005de:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	0f 89 87 00 00 00    	jns    800674 <vprintfmt+0x386>
				putch('-', putdat);
  8005ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fe:	89 f0                	mov    %esi,%eax
  800600:	89 fa                	mov    %edi,%edx
  800602:	f7 d8                	neg    %eax
  800604:	83 d2 00             	adc    $0x0,%edx
  800607:	f7 da                	neg    %edx
			}
			base = 10;
  800609:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060e:	eb 64                	jmp    800674 <vprintfmt+0x386>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 57 fc ff ff       	call   80026f <getuint>
			base = 10;
  800618:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061d:	eb 55                	jmp    800674 <vprintfmt+0x386>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 48 fc ff ff       	call   80026f <getuint>
			base=8;
  800627:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80062c:	eb 46                	jmp    800674 <vprintfmt+0x386>

		// pointer
		case 'p':
			putch('0', putdat);
  80062e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800631:	89 44 24 04          	mov    %eax,0x4(%esp)
  800635:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80063c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80063f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800642:	89 44 24 04          	mov    %eax,0x4(%esp)
  800646:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 04             	lea    0x4(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800660:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x386>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 00 fc ff ff       	call   80026f <getuint>
			base = 16;
  80066f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800674:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800678:	89 74 24 10          	mov    %esi,0x10(%esp)
  80067c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800683:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800687:	89 04 24             	mov    %eax,(%esp)
  80068a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800691:	8b 45 08             	mov    0x8(%ebp),%eax
  800694:	e8 e7 fa ff ff       	call   800180 <printnum>
			break;
  800699:	e9 7c fc ff ff       	jmp    80031a <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a5:	89 0c 24             	mov    %ecx,(%esp)
  8006a8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ab:	e9 6a fc ff ff       	jmp    80031a <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006be:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c1:	89 fb                	mov    %edi,%ebx
  8006c3:	eb 03                	jmp    8006c8 <vprintfmt+0x3da>
  8006c5:	83 eb 01             	sub    $0x1,%ebx
  8006c8:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006cc:	75 f7                	jne    8006c5 <vprintfmt+0x3d7>
  8006ce:	66 90                	xchg   %ax,%ax
  8006d0:	e9 45 fc ff ff       	jmp    80031a <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8006d5:	83 c4 3c             	add    $0x3c,%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 28             	sub    $0x28,%esp
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	74 30                	je     80072e <vsnprintf+0x51>
  8006fe:	85 d2                	test   %edx,%edx
  800700:	7e 2c                	jle    80072e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800709:	8b 45 10             	mov    0x10(%ebp),%eax
  80070c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800710:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	c7 04 24 a9 02 80 00 	movl   $0x8002a9,(%esp)
  80071e:	e8 cb fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800723:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800726:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072c:	eb 05                	jmp    800733 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800742:	8b 45 10             	mov    0x10(%ebp),%eax
  800745:	89 44 24 08          	mov    %eax,0x8(%esp)
  800749:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 82 ff ff ff       	call   8006dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    
  80075d:	66 90                	xchg   %ax,%ax
  80075f:	90                   	nop

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	eb 03                	jmp    800770 <strlen+0x10>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	75 f7                	jne    80076d <strlen+0xd>
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
  800786:	eb 03                	jmp    80078b <strnlen+0x13>
		n++;
  800788:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 d0                	cmp    %edx,%eax
  80078d:	74 06                	je     800795 <strnlen+0x1d>
  80078f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800793:	75 f3                	jne    800788 <strnlen+0x10>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	89 1c 24             	mov    %ebx,(%esp)
  8007c4:	e8 97 ff ff ff       	call   800760 <strlen>
	strcpy(dst + len, src);
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d0:	01 d8                	add    %ebx,%eax
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	e8 bd ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	83 c4 08             	add    $0x8,%esp
  8007df:	5b                   	pop    %ebx
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	89 f3                	mov    %esi,%ebx
  8007ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f2:	89 f2                	mov    %esi,%edx
  8007f4:	eb 0f                	jmp    800805 <strncpy+0x23>
		*dst++ = *src;
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	0f b6 01             	movzbl (%ecx),%eax
  8007fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800802:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800805:	39 da                	cmp    %ebx,%edx
  800807:	75 ed                	jne    8007f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800809:	89 f0                	mov    %esi,%eax
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	8b 75 08             	mov    0x8(%ebp),%esi
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80081d:	89 f0                	mov    %esi,%eax
  80081f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	85 c9                	test   %ecx,%ecx
  800825:	75 0b                	jne    800832 <strlcpy+0x23>
  800827:	eb 1d                	jmp    800846 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800832:	39 d8                	cmp    %ebx,%eax
  800834:	74 0b                	je     800841 <strlcpy+0x32>
  800836:	0f b6 0a             	movzbl (%edx),%ecx
  800839:	84 c9                	test   %cl,%cl
  80083b:	75 ec                	jne    800829 <strlcpy+0x1a>
  80083d:	89 c2                	mov    %eax,%edx
  80083f:	eb 02                	jmp    800843 <strlcpy+0x34>
  800841:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800843:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800846:	29 f0                	sub    %esi,%eax
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800855:	eb 06                	jmp    80085d <strcmp+0x11>
		p++, q++;
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	84 c0                	test   %al,%al
  800862:	74 04                	je     800868 <strcmp+0x1c>
  800864:	3a 02                	cmp    (%edx),%al
  800866:	74 ef                	je     800857 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800868:	0f b6 c0             	movzbl %al,%eax
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	29 d0                	sub    %edx,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 c3                	mov    %eax,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800881:	eb 06                	jmp    800889 <strncmp+0x17>
		n--, p++, q++;
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 15                	je     8008a2 <strncmp+0x30>
  80088d:	0f b6 08             	movzbl (%eax),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	74 04                	je     800898 <strncmp+0x26>
  800894:	3a 0a                	cmp    (%edx),%cl
  800896:	74 eb                	je     800883 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 00             	movzbl (%eax),%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
  8008a0:	eb 05                	jmp    8008a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b4:	eb 07                	jmp    8008bd <strchr+0x13>
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	74 0f                	je     8008c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	75 f2                	jne    8008b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d5:	eb 07                	jmp    8008de <strfind+0x13>
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	74 0a                	je     8008e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	0f b6 10             	movzbl (%eax),%edx
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f2                	jne    8008d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	74 36                	je     80092d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fd:	75 28                	jne    800927 <memset+0x40>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 23                	jne    800927 <memset+0x40>
		c &= 0xFF;
  800904:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800908:	89 d3                	mov    %edx,%ebx
  80090a:	c1 e3 08             	shl    $0x8,%ebx
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	c1 e6 18             	shl    $0x18,%esi
  800912:	89 d0                	mov    %edx,%eax
  800914:	c1 e0 10             	shl    $0x10,%eax
  800917:	09 f0                	or     %esi,%eax
  800919:	09 c2                	or     %eax,%edx
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800922:	fc                   	cld    
  800923:	f3 ab                	rep stos %eax,%es:(%edi)
  800925:	eb 06                	jmp    80092d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800942:	39 c6                	cmp    %eax,%esi
  800944:	73 35                	jae    80097b <memmove+0x47>
  800946:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800949:	39 d0                	cmp    %edx,%eax
  80094b:	73 2e                	jae    80097b <memmove+0x47>
		s += n;
		d += n;
  80094d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800950:	89 d6                	mov    %edx,%esi
  800952:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	75 13                	jne    80096f <memmove+0x3b>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 0e                	jne    80096f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800961:	83 ef 04             	sub    $0x4,%edi
  800964:	8d 72 fc             	lea    -0x4(%edx),%esi
  800967:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096a:	fd                   	std    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 09                	jmp    800978 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096f:	83 ef 01             	sub    $0x1,%edi
  800972:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800975:	fd                   	std    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800978:	fc                   	cld    
  800979:	eb 1d                	jmp    800998 <memmove+0x64>
  80097b:	89 f2                	mov    %esi,%edx
  80097d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	f6 c2 03             	test   $0x3,%dl
  800982:	75 0f                	jne    800993 <memmove+0x5f>
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 0a                	jne    800993 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800989:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098c:	89 c7                	mov    %eax,%edi
  80098e:	fc                   	cld    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 05                	jmp    800998 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 79 ff ff ff       	call   800934 <memmove>
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c8:	89 d6                	mov    %edx,%esi
  8009ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	eb 1a                	jmp    8009e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cf:	0f b6 02             	movzbl (%edx),%eax
  8009d2:	0f b6 19             	movzbl (%ecx),%ebx
  8009d5:	38 d8                	cmp    %bl,%al
  8009d7:	74 0a                	je     8009e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 db             	movzbl %bl,%ebx
  8009df:	29 d8                	sub    %ebx,%eax
  8009e1:	eb 0f                	jmp    8009f2 <memcmp+0x35>
		s1++, s2++;
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e9:	39 f2                	cmp    %esi,%edx
  8009eb:	75 e2                	jne    8009cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a04:	eb 07                	jmp    800a0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	38 08                	cmp    %cl,(%eax)
  800a08:	74 07                	je     800a11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	72 f5                	jb     800a06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	eb 03                	jmp    800a24 <strtol+0x11>
		s++;
  800a21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a24:	0f b6 0a             	movzbl (%edx),%ecx
  800a27:	80 f9 09             	cmp    $0x9,%cl
  800a2a:	74 f5                	je     800a21 <strtol+0xe>
  800a2c:	80 f9 20             	cmp    $0x20,%cl
  800a2f:	74 f0                	je     800a21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a31:	80 f9 2b             	cmp    $0x2b,%cl
  800a34:	75 0a                	jne    800a40 <strtol+0x2d>
		s++;
  800a36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3e:	eb 11                	jmp    800a51 <strtol+0x3e>
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a45:	80 f9 2d             	cmp    $0x2d,%cl
  800a48:	75 07                	jne    800a51 <strtol+0x3e>
		s++, neg = 1;
  800a4a:	8d 52 01             	lea    0x1(%edx),%edx
  800a4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a56:	75 15                	jne    800a6d <strtol+0x5a>
  800a58:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5b:	75 10                	jne    800a6d <strtol+0x5a>
  800a5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a61:	75 0a                	jne    800a6d <strtol+0x5a>
		s += 2, base = 16;
  800a63:	83 c2 02             	add    $0x2,%edx
  800a66:	b8 10 00 00 00       	mov    $0x10,%eax
  800a6b:	eb 10                	jmp    800a7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	75 0c                	jne    800a7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a73:	80 3a 30             	cmpb   $0x30,(%edx)
  800a76:	75 05                	jne    800a7d <strtol+0x6a>
		s++, base = 8;
  800a78:	83 c2 01             	add    $0x1,%edx
  800a7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800a7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a85:	0f b6 0a             	movzbl (%edx),%ecx
  800a88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	3c 09                	cmp    $0x9,%al
  800a8f:	77 08                	ja     800a99 <strtol+0x86>
			dig = *s - '0';
  800a91:	0f be c9             	movsbl %cl,%ecx
  800a94:	83 e9 30             	sub    $0x30,%ecx
  800a97:	eb 20                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800a99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a9c:	89 f0                	mov    %esi,%eax
  800a9e:	3c 19                	cmp    $0x19,%al
  800aa0:	77 08                	ja     800aaa <strtol+0x97>
			dig = *s - 'a' + 10;
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 57             	sub    $0x57,%ecx
  800aa8:	eb 0f                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aaa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	3c 19                	cmp    $0x19,%al
  800ab1:	77 16                	ja     800ac9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ab3:	0f be c9             	movsbl %cl,%ecx
  800ab6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800abc:	7d 0f                	jge    800acd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800abe:	83 c2 01             	add    $0x1,%edx
  800ac1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ac5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ac7:	eb bc                	jmp    800a85 <strtol+0x72>
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	eb 02                	jmp    800acf <strtol+0xbc>
  800acd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800acf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad3:	74 05                	je     800ada <strtol+0xc7>
		*endptr = (char *) s;
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ada:	f7 d8                	neg    %eax
  800adc:	85 ff                	test   %edi,%edi
  800ade:	0f 44 c3             	cmove  %ebx,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	89 c7                	mov    %eax,%edi
  800afb:	89 c6                	mov    %eax,%esi
  800afd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b31:	b8 03 00 00 00       	mov    $0x3,%eax
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 cb                	mov    %ecx,%ebx
  800b3b:	89 cf                	mov    %ecx,%edi
  800b3d:	89 ce                	mov    %ecx,%esi
  800b3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 28                	jle    800b6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b50:	00 
  800b51:	c7 44 24 08 ac 10 80 	movl   $0x8010ac,0x8(%esp)
  800b58:	00 
  800b59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b60:	00 
  800b61:	c7 04 24 c9 10 80 00 	movl   $0x8010c9,(%esp)
  800b68:	e8 27 00 00 00       	call   800b94 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6d:	83 c4 2c             	add    $0x2c,%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 02 00 00 00       	mov    $0x2,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800b9c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b9f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ba5:	e8 cb ff ff ff       	call   800b75 <sys_getenvid>
  800baa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bad:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bb8:	89 74 24 08          	mov    %esi,0x8(%esp)
  800bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc0:	c7 04 24 d8 10 80 00 	movl   $0x8010d8,(%esp)
  800bc7:	e8 90 f5 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bcc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd3:	89 04 24             	mov    %eax,(%esp)
  800bd6:	e8 20 f5 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800bdb:	c7 04 24 fc 10 80 00 	movl   $0x8010fc,(%esp)
  800be2:	e8 75 f5 ff ff       	call   80015c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800be7:	cc                   	int3   
  800be8:	eb fd                	jmp    800be7 <_panic+0x53>
  800bea:	66 90                	xchg   %ax,%ax
  800bec:	66 90                	xchg   %ax,%ax
  800bee:	66 90                	xchg   %ax,%ax

00800bf0 <__udivdi3>:
  800bf0:	55                   	push   %ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800bfa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800bfe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800c02:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800c06:	85 c0                	test   %eax,%eax
  800c08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c0c:	89 ea                	mov    %ebp,%edx
  800c0e:	89 0c 24             	mov    %ecx,(%esp)
  800c11:	75 2d                	jne    800c40 <__udivdi3+0x50>
  800c13:	39 e9                	cmp    %ebp,%ecx
  800c15:	77 61                	ja     800c78 <__udivdi3+0x88>
  800c17:	85 c9                	test   %ecx,%ecx
  800c19:	89 ce                	mov    %ecx,%esi
  800c1b:	75 0b                	jne    800c28 <__udivdi3+0x38>
  800c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c22:	31 d2                	xor    %edx,%edx
  800c24:	f7 f1                	div    %ecx
  800c26:	89 c6                	mov    %eax,%esi
  800c28:	31 d2                	xor    %edx,%edx
  800c2a:	89 e8                	mov    %ebp,%eax
  800c2c:	f7 f6                	div    %esi
  800c2e:	89 c5                	mov    %eax,%ebp
  800c30:	89 f8                	mov    %edi,%eax
  800c32:	f7 f6                	div    %esi
  800c34:	89 ea                	mov    %ebp,%edx
  800c36:	83 c4 0c             	add    $0xc,%esp
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
  800c3d:	8d 76 00             	lea    0x0(%esi),%esi
  800c40:	39 e8                	cmp    %ebp,%eax
  800c42:	77 24                	ja     800c68 <__udivdi3+0x78>
  800c44:	0f bd e8             	bsr    %eax,%ebp
  800c47:	83 f5 1f             	xor    $0x1f,%ebp
  800c4a:	75 3c                	jne    800c88 <__udivdi3+0x98>
  800c4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c50:	39 34 24             	cmp    %esi,(%esp)
  800c53:	0f 86 9f 00 00 00    	jbe    800cf8 <__udivdi3+0x108>
  800c59:	39 d0                	cmp    %edx,%eax
  800c5b:	0f 82 97 00 00 00    	jb     800cf8 <__udivdi3+0x108>
  800c61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c68:	31 d2                	xor    %edx,%edx
  800c6a:	31 c0                	xor    %eax,%eax
  800c6c:	83 c4 0c             	add    $0xc,%esp
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
  800c73:	90                   	nop
  800c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c78:	89 f8                	mov    %edi,%eax
  800c7a:	f7 f1                	div    %ecx
  800c7c:	31 d2                	xor    %edx,%edx
  800c7e:	83 c4 0c             	add    $0xc,%esp
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    
  800c85:	8d 76 00             	lea    0x0(%esi),%esi
  800c88:	89 e9                	mov    %ebp,%ecx
  800c8a:	8b 3c 24             	mov    (%esp),%edi
  800c8d:	d3 e0                	shl    %cl,%eax
  800c8f:	89 c6                	mov    %eax,%esi
  800c91:	b8 20 00 00 00       	mov    $0x20,%eax
  800c96:	29 e8                	sub    %ebp,%eax
  800c98:	89 c1                	mov    %eax,%ecx
  800c9a:	d3 ef                	shr    %cl,%edi
  800c9c:	89 e9                	mov    %ebp,%ecx
  800c9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ca2:	8b 3c 24             	mov    (%esp),%edi
  800ca5:	09 74 24 08          	or     %esi,0x8(%esp)
  800ca9:	89 d6                	mov    %edx,%esi
  800cab:	d3 e7                	shl    %cl,%edi
  800cad:	89 c1                	mov    %eax,%ecx
  800caf:	89 3c 24             	mov    %edi,(%esp)
  800cb2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cb6:	d3 ee                	shr    %cl,%esi
  800cb8:	89 e9                	mov    %ebp,%ecx
  800cba:	d3 e2                	shl    %cl,%edx
  800cbc:	89 c1                	mov    %eax,%ecx
  800cbe:	d3 ef                	shr    %cl,%edi
  800cc0:	09 d7                	or     %edx,%edi
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	89 f8                	mov    %edi,%eax
  800cc6:	f7 74 24 08          	divl   0x8(%esp)
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	89 c7                	mov    %eax,%edi
  800cce:	f7 24 24             	mull   (%esp)
  800cd1:	39 d6                	cmp    %edx,%esi
  800cd3:	89 14 24             	mov    %edx,(%esp)
  800cd6:	72 30                	jb     800d08 <__udivdi3+0x118>
  800cd8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cdc:	89 e9                	mov    %ebp,%ecx
  800cde:	d3 e2                	shl    %cl,%edx
  800ce0:	39 c2                	cmp    %eax,%edx
  800ce2:	73 05                	jae    800ce9 <__udivdi3+0xf9>
  800ce4:	3b 34 24             	cmp    (%esp),%esi
  800ce7:	74 1f                	je     800d08 <__udivdi3+0x118>
  800ce9:	89 f8                	mov    %edi,%eax
  800ceb:	31 d2                	xor    %edx,%edx
  800ced:	e9 7a ff ff ff       	jmp    800c6c <__udivdi3+0x7c>
  800cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cf8:	31 d2                	xor    %edx,%edx
  800cfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800cff:	e9 68 ff ff ff       	jmp    800c6c <__udivdi3+0x7c>
  800d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d08:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d0b:	31 d2                	xor    %edx,%edx
  800d0d:	83 c4 0c             	add    $0xc,%esp
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    
  800d14:	66 90                	xchg   %ax,%ax
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__umoddi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	83 ec 14             	sub    $0x14,%esp
  800d26:	8b 44 24 28          	mov    0x28(%esp),%eax
  800d2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800d2e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800d32:	89 c7                	mov    %eax,%edi
  800d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d38:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d40:	89 34 24             	mov    %esi,(%esp)
  800d43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	89 c2                	mov    %eax,%edx
  800d4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d4f:	75 17                	jne    800d68 <__umoddi3+0x48>
  800d51:	39 fe                	cmp    %edi,%esi
  800d53:	76 4b                	jbe    800da0 <__umoddi3+0x80>
  800d55:	89 c8                	mov    %ecx,%eax
  800d57:	89 fa                	mov    %edi,%edx
  800d59:	f7 f6                	div    %esi
  800d5b:	89 d0                	mov    %edx,%eax
  800d5d:	31 d2                	xor    %edx,%edx
  800d5f:	83 c4 14             	add    $0x14,%esp
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	39 f8                	cmp    %edi,%eax
  800d6a:	77 54                	ja     800dc0 <__umoddi3+0xa0>
  800d6c:	0f bd e8             	bsr    %eax,%ebp
  800d6f:	83 f5 1f             	xor    $0x1f,%ebp
  800d72:	75 5c                	jne    800dd0 <__umoddi3+0xb0>
  800d74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d78:	39 3c 24             	cmp    %edi,(%esp)
  800d7b:	0f 87 e7 00 00 00    	ja     800e68 <__umoddi3+0x148>
  800d81:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d85:	29 f1                	sub    %esi,%ecx
  800d87:	19 c7                	sbb    %eax,%edi
  800d89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d91:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d95:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d99:	83 c4 14             	add    $0x14,%esp
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
  800da0:	85 f6                	test   %esi,%esi
  800da2:	89 f5                	mov    %esi,%ebp
  800da4:	75 0b                	jne    800db1 <__umoddi3+0x91>
  800da6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	f7 f6                	div    %esi
  800daf:	89 c5                	mov    %eax,%ebp
  800db1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800db5:	31 d2                	xor    %edx,%edx
  800db7:	f7 f5                	div    %ebp
  800db9:	89 c8                	mov    %ecx,%eax
  800dbb:	f7 f5                	div    %ebp
  800dbd:	eb 9c                	jmp    800d5b <__umoddi3+0x3b>
  800dbf:	90                   	nop
  800dc0:	89 c8                	mov    %ecx,%eax
  800dc2:	89 fa                	mov    %edi,%edx
  800dc4:	83 c4 14             	add    $0x14,%esp
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    
  800dcb:	90                   	nop
  800dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	8b 04 24             	mov    (%esp),%eax
  800dd3:	be 20 00 00 00       	mov    $0x20,%esi
  800dd8:	89 e9                	mov    %ebp,%ecx
  800dda:	29 ee                	sub    %ebp,%esi
  800ddc:	d3 e2                	shl    %cl,%edx
  800dde:	89 f1                	mov    %esi,%ecx
  800de0:	d3 e8                	shr    %cl,%eax
  800de2:	89 e9                	mov    %ebp,%ecx
  800de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de8:	8b 04 24             	mov    (%esp),%eax
  800deb:	09 54 24 04          	or     %edx,0x4(%esp)
  800def:	89 fa                	mov    %edi,%edx
  800df1:	d3 e0                	shl    %cl,%eax
  800df3:	89 f1                	mov    %esi,%ecx
  800df5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800dfd:	d3 ea                	shr    %cl,%edx
  800dff:	89 e9                	mov    %ebp,%ecx
  800e01:	d3 e7                	shl    %cl,%edi
  800e03:	89 f1                	mov    %esi,%ecx
  800e05:	d3 e8                	shr    %cl,%eax
  800e07:	89 e9                	mov    %ebp,%ecx
  800e09:	09 f8                	or     %edi,%eax
  800e0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800e0f:	f7 74 24 04          	divl   0x4(%esp)
  800e13:	d3 e7                	shl    %cl,%edi
  800e15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	f7 64 24 08          	mull   0x8(%esp)
  800e1f:	39 d7                	cmp    %edx,%edi
  800e21:	89 c1                	mov    %eax,%ecx
  800e23:	89 14 24             	mov    %edx,(%esp)
  800e26:	72 2c                	jb     800e54 <__umoddi3+0x134>
  800e28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  800e2c:	72 22                	jb     800e50 <__umoddi3+0x130>
  800e2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e32:	29 c8                	sub    %ecx,%eax
  800e34:	19 d7                	sbb    %edx,%edi
  800e36:	89 e9                	mov    %ebp,%ecx
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	d3 e8                	shr    %cl,%eax
  800e3c:	89 f1                	mov    %esi,%ecx
  800e3e:	d3 e2                	shl    %cl,%edx
  800e40:	89 e9                	mov    %ebp,%ecx
  800e42:	d3 ef                	shr    %cl,%edi
  800e44:	09 d0                	or     %edx,%eax
  800e46:	89 fa                	mov    %edi,%edx
  800e48:	83 c4 14             	add    $0x14,%esp
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    
  800e4f:	90                   	nop
  800e50:	39 d7                	cmp    %edx,%edi
  800e52:	75 da                	jne    800e2e <__umoddi3+0x10e>
  800e54:	8b 14 24             	mov    (%esp),%edx
  800e57:	89 c1                	mov    %eax,%ecx
  800e59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  800e5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  800e61:	eb cb                	jmp    800e2e <__umoddi3+0x10e>
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e6c:	0f 82 0f ff ff ff    	jb     800d81 <__umoddi3+0x61>
  800e72:	e9 1a ff ff ff       	jmp    800d91 <__umoddi3+0x71>
