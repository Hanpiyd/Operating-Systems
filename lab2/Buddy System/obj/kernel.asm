
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	393010ef          	jal	ra,ffffffffc0201bdc <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0201bf0 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	4a0010ef          	jal	ra,ffffffffc0201506 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	660010ef          	jal	ra,ffffffffc0201706 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	62a010ef          	jal	ra,ffffffffc0201706 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	ad450513          	addi	a0,a0,-1324 # ffffffffc0201c10 <etext+0x22>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	ade50513          	addi	a0,a0,-1314 # ffffffffc0201c30 <etext+0x42>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	a9058593          	addi	a1,a1,-1392 # ffffffffc0201bee <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	aea50513          	addi	a0,a0,-1302 # ffffffffc0201c50 <etext+0x62>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	af650513          	addi	a0,a0,-1290 # ffffffffc0201c70 <etext+0x82>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	b0250513          	addi	a0,a0,-1278 # ffffffffc0201c90 <etext+0xa2>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	af450513          	addi	a0,a0,-1292 # ffffffffc0201cb0 <etext+0xc2>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	b1660613          	addi	a2,a2,-1258 # ffffffffc0201ce0 <etext+0xf2>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	b2250513          	addi	a0,a0,-1246 # ffffffffc0201cf8 <etext+0x10a>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0201d10 <etext+0x122>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	b4258593          	addi	a1,a1,-1214 # ffffffffc0201d30 <etext+0x142>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	b4250513          	addi	a0,a0,-1214 # ffffffffc0201d38 <etext+0x14a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	b4460613          	addi	a2,a2,-1212 # ffffffffc0201d48 <etext+0x15a>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	b6458593          	addi	a1,a1,-1180 # ffffffffc0201d70 <etext+0x182>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	b2450513          	addi	a0,a0,-1244 # ffffffffc0201d38 <etext+0x14a>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	b6060613          	addi	a2,a2,-1184 # ffffffffc0201d80 <etext+0x192>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	b7858593          	addi	a1,a1,-1160 # ffffffffc0201da0 <etext+0x1b2>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	b0850513          	addi	a0,a0,-1272 # ffffffffc0201d38 <etext+0x14a>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	b4650513          	addi	a0,a0,-1210 # ffffffffc0201db0 <etext+0x1c2>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0201dd8 <etext+0x1ea>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	ba6c0c13          	addi	s8,s8,-1114 # ffffffffc0201e48 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	b5690913          	addi	s2,s2,-1194 # ffffffffc0201e00 <etext+0x212>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	b5648493          	addi	s1,s1,-1194 # ffffffffc0201e08 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	b54b0b13          	addi	s6,s6,-1196 # ffffffffc0201e10 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	a6ca0a13          	addi	s4,s4,-1428 # ffffffffc0201d30 <etext+0x142>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	7b8010ef          	jal	ra,ffffffffc0201a88 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	b62d0d13          	addi	s10,s10,-1182 # ffffffffc0201e48 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	0b5010ef          	jal	ra,ffffffffc0201ba8 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	0a1010ef          	jal	ra,ffffffffc0201ba8 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	081010ef          	jal	ra,ffffffffc0201bc6 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	043010ef          	jal	ra,ffffffffc0201bc6 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	a9250513          	addi	a0,a0,-1390 # ffffffffc0201e30 <etext+0x242>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	ab650513          	addi	a0,a0,-1354 # ffffffffc0201e90 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	8e850513          	addi	a0,a0,-1816 # ffffffffc0201cd8 <etext+0xea>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	736010ef          	jal	ra,ffffffffc0201b56 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201eb0 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	7100106f          	j	ffffffffc0201b56 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	6ec0106f          	j	ffffffffc0201b3c <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	71c0106f          	j	ffffffffc0201b70 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	a5250513          	addi	a0,a0,-1454 # ffffffffc0201ed0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0201ee8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201f00 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201f18 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201f30 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201f48 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201f60 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	a9650513          	addi	a0,a0,-1386 # ffffffffc0201f78 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	aa050513          	addi	a0,a0,-1376 # ffffffffc0201f90 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0201fa8 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	ab450513          	addi	a0,a0,-1356 # ffffffffc0201fc0 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0201fd8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0201ff0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0202008 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	adc50513          	addi	a0,a0,-1316 # ffffffffc0202020 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	ae650513          	addi	a0,a0,-1306 # ffffffffc0202038 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	af050513          	addi	a0,a0,-1296 # ffffffffc0202050 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	afa50513          	addi	a0,a0,-1286 # ffffffffc0202068 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	b0450513          	addi	a0,a0,-1276 # ffffffffc0202080 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0202098 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	b1850513          	addi	a0,a0,-1256 # ffffffffc02020b0 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	b2250513          	addi	a0,a0,-1246 # ffffffffc02020c8 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02020e0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	b3650513          	addi	a0,a0,-1226 # ffffffffc02020f8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	b4050513          	addi	a0,a0,-1216 # ffffffffc0202110 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0202128 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	b5450513          	addi	a0,a0,-1196 # ffffffffc0202140 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0202158 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	b6850513          	addi	a0,a0,-1176 # ffffffffc0202170 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	b7250513          	addi	a0,a0,-1166 # ffffffffc0202188 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02021a0 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	b8250513          	addi	a0,a0,-1150 # ffffffffc02021b8 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	b8650513          	addi	a0,a0,-1146 # ffffffffc02021d0 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	b8650513          	addi	a0,a0,-1146 # ffffffffc02021e8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0202200 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	b9650513          	addi	a0,a0,-1130 # ffffffffc0202218 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0202230 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	c6070713          	addi	a4,a4,-928 # ffffffffc0202310 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	be650513          	addi	a0,a0,-1050 # ffffffffc02022a8 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0202288 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	b7250513          	addi	a0,a0,-1166 # ffffffffc0202248 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	be850513          	addi	a0,a0,-1048 # ffffffffc02022c8 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	be050513          	addi	a0,a0,-1056 # ffffffffc02022f0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0202268 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	bb450513          	addi	a0,a0,-1100 # ffffffffc02022e0 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)

//finished
static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:
} 

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_check>:
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void)
{
ffffffffc020081e:	715d                	addi	sp,sp,-80
ffffffffc0200820:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200822:	00005917          	auipc	s2,0x5
ffffffffc0200826:	7ee90913          	addi	s2,s2,2030 # ffffffffc0206010 <free_area>
ffffffffc020082a:	00893783          	ld	a5,8(s2)
ffffffffc020082e:	e486                	sd	ra,72(sp)
ffffffffc0200830:	e0a2                	sd	s0,64(sp)
ffffffffc0200832:	fc26                	sd	s1,56(sp)
ffffffffc0200834:	f44e                	sd	s3,40(sp)
ffffffffc0200836:	f052                	sd	s4,32(sp)
ffffffffc0200838:	ec56                	sd	s5,24(sp)
ffffffffc020083a:	e85a                	sd	s6,16(sp)
ffffffffc020083c:	e45e                	sd	s7,8(sp)
ffffffffc020083e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200840:	33278b63          	beq	a5,s2,ffffffffc0200b76 <best_fit_check+0x358>
    int count = 0, total = 0;
ffffffffc0200844:	4401                	li	s0,0
ffffffffc0200846:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200848:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020084c:	8b09                	andi	a4,a4,2
ffffffffc020084e:	34070863          	beqz	a4,ffffffffc0200b9e <best_fit_check+0x380>
        count++, total += p->property;
ffffffffc0200852:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200856:	679c                	ld	a5,8(a5)
ffffffffc0200858:	2485                	addiw	s1,s1,1
ffffffffc020085a:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020085c:	ff2796e3          	bne	a5,s2,ffffffffc0200848 <best_fit_check+0x2a>
    }
    assert(total == nr_free_pages());
ffffffffc0200860:	89a2                	mv	s3,s0
ffffffffc0200862:	46b000ef          	jal	ra,ffffffffc02014cc <nr_free_pages>
ffffffffc0200866:	5b351c63          	bne	a0,s3,ffffffffc0200e1e <best_fit_check+0x600>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020086a:	4505                	li	a0,1
ffffffffc020086c:	3e3000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200870:	8aaa                	mv	s5,a0
ffffffffc0200872:	76050663          	beqz	a0,ffffffffc0200fde <best_fit_check+0x7c0>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200876:	4505                	li	a0,1
ffffffffc0200878:	3d7000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc020087c:	8a2a                	mv	s4,a0
ffffffffc020087e:	74050063          	beqz	a0,ffffffffc0200fbe <best_fit_check+0x7a0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200882:	4505                	li	a0,1
ffffffffc0200884:	3cb000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200888:	89aa                	mv	s3,a0
ffffffffc020088a:	4c050a63          	beqz	a0,ffffffffc0200d5e <best_fit_check+0x540>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020088e:	7b4a8863          	beq	s5,s4,ffffffffc020103e <best_fit_check+0x820>
ffffffffc0200892:	7aaa8663          	beq	s5,a0,ffffffffc020103e <best_fit_check+0x820>
ffffffffc0200896:	7aaa0463          	beq	s4,a0,ffffffffc020103e <best_fit_check+0x820>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020089a:	000aa783          	lw	a5,0(s5)
ffffffffc020089e:	78079063          	bnez	a5,ffffffffc020101e <best_fit_check+0x800>
ffffffffc02008a2:	000a2783          	lw	a5,0(s4)
ffffffffc02008a6:	76079c63          	bnez	a5,ffffffffc020101e <best_fit_check+0x800>
ffffffffc02008aa:	411c                	lw	a5,0(a0)
ffffffffc02008ac:	76079963          	bnez	a5,ffffffffc020101e <best_fit_check+0x800>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008b0:	00006797          	auipc	a5,0x6
ffffffffc02008b4:	b907b783          	ld	a5,-1136(a5) # ffffffffc0206440 <pages>
ffffffffc02008b8:	40fa8733          	sub	a4,s5,a5
ffffffffc02008bc:	870d                	srai	a4,a4,0x3
ffffffffc02008be:	00002597          	auipc	a1,0x2
ffffffffc02008c2:	1d25b583          	ld	a1,466(a1) # ffffffffc0202a90 <error_string+0x38>
ffffffffc02008c6:	02b70733          	mul	a4,a4,a1
ffffffffc02008ca:	00002617          	auipc	a2,0x2
ffffffffc02008ce:	1ce63603          	ld	a2,462(a2) # ffffffffc0202a98 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008d2:	00006697          	auipc	a3,0x6
ffffffffc02008d6:	b666b683          	ld	a3,-1178(a3) # ffffffffc0206438 <npage>
ffffffffc02008da:	06b2                	slli	a3,a3,0xc
ffffffffc02008dc:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008de:	0732                	slli	a4,a4,0xc
ffffffffc02008e0:	70d77f63          	bgeu	a4,a3,ffffffffc0200ffe <best_fit_check+0x7e0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e4:	40fa0733          	sub	a4,s4,a5
ffffffffc02008e8:	870d                	srai	a4,a4,0x3
ffffffffc02008ea:	02b70733          	mul	a4,a4,a1
ffffffffc02008ee:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02008f0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008f2:	56d77663          	bgeu	a4,a3,ffffffffc0200e5e <best_fit_check+0x640>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f6:	40f507b3          	sub	a5,a0,a5
ffffffffc02008fa:	878d                	srai	a5,a5,0x3
ffffffffc02008fc:	02b787b3          	mul	a5,a5,a1
ffffffffc0200900:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200902:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200904:	32d7fd63          	bgeu	a5,a3,ffffffffc0200c3e <best_fit_check+0x420>
    assert(alloc_page() == NULL);
ffffffffc0200908:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020090a:	00093c03          	ld	s8,0(s2)
ffffffffc020090e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200912:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200916:	01293423          	sd	s2,8(s2)
ffffffffc020091a:	01293023          	sd	s2,0(s2)
    nr_free = 0;
ffffffffc020091e:	00005797          	auipc	a5,0x5
ffffffffc0200922:	7007a123          	sw	zero,1794(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200926:	329000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc020092a:	2e051a63          	bnez	a0,ffffffffc0200c1e <best_fit_check+0x400>
    free_page(p0);
ffffffffc020092e:	4585                	li	a1,1
ffffffffc0200930:	8556                	mv	a0,s5
ffffffffc0200932:	35b000ef          	jal	ra,ffffffffc020148c <free_pages>
    free_page(p1);
ffffffffc0200936:	4585                	li	a1,1
ffffffffc0200938:	8552                	mv	a0,s4
ffffffffc020093a:	353000ef          	jal	ra,ffffffffc020148c <free_pages>
    free_page(p2);
ffffffffc020093e:	4585                	li	a1,1
ffffffffc0200940:	854e                	mv	a0,s3
ffffffffc0200942:	34b000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(nr_free == 3);
ffffffffc0200946:	01092703          	lw	a4,16(s2)
ffffffffc020094a:	478d                	li	a5,3
ffffffffc020094c:	2af71963          	bne	a4,a5,ffffffffc0200bfe <best_fit_check+0x3e0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200950:	4505                	li	a0,1
ffffffffc0200952:	2fd000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200956:	89aa                	mv	s3,a0
ffffffffc0200958:	28050363          	beqz	a0,ffffffffc0200bde <best_fit_check+0x3c0>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020095c:	4505                	li	a0,1
ffffffffc020095e:	2f1000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200962:	8aaa                	mv	s5,a0
ffffffffc0200964:	30050d63          	beqz	a0,ffffffffc0200c7e <best_fit_check+0x460>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200968:	4505                	li	a0,1
ffffffffc020096a:	2e5000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc020096e:	8a2a                	mv	s4,a0
ffffffffc0200970:	2e050763          	beqz	a0,ffffffffc0200c5e <best_fit_check+0x440>
    assert(alloc_page() == NULL);
ffffffffc0200974:	4505                	li	a0,1
ffffffffc0200976:	2d9000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc020097a:	40051263          	bnez	a0,ffffffffc0200d7e <best_fit_check+0x560>
    free_page(p0);
ffffffffc020097e:	4585                	li	a1,1
ffffffffc0200980:	854e                	mv	a0,s3
ffffffffc0200982:	30b000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200986:	00893783          	ld	a5,8(s2)
ffffffffc020098a:	23278a63          	beq	a5,s2,ffffffffc0200bbe <best_fit_check+0x3a0>
    assert((p = alloc_page()) == p0);
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	2bf000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200994:	36a99563          	bne	s3,a0,ffffffffc0200cfe <best_fit_check+0x4e0>
    assert(alloc_page() == NULL);
ffffffffc0200998:	4505                	li	a0,1
ffffffffc020099a:	2b5000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc020099e:	34051063          	bnez	a0,ffffffffc0200cde <best_fit_check+0x4c0>
    assert(nr_free == 0);
ffffffffc02009a2:	01092783          	lw	a5,16(s2)
ffffffffc02009a6:	30079c63          	bnez	a5,ffffffffc0200cbe <best_fit_check+0x4a0>
    free_page(p);
ffffffffc02009aa:	854e                	mv	a0,s3
ffffffffc02009ac:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009ae:	01893023          	sd	s8,0(s2)
ffffffffc02009b2:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc02009b6:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc02009ba:	2d3000ef          	jal	ra,ffffffffc020148c <free_pages>
    free_page(p1);
ffffffffc02009be:	4585                	li	a1,1
ffffffffc02009c0:	8556                	mv	a0,s5
ffffffffc02009c2:	2cb000ef          	jal	ra,ffffffffc020148c <free_pages>
    free_page(p2);
ffffffffc02009c6:	4585                	li	a1,1
ffffffffc02009c8:	8552                	mv	a0,s4
ffffffffc02009ca:	2c3000ef          	jal	ra,ffffffffc020148c <free_pages>
    basic_check();
    struct Page *p0 = alloc_pages(26), *p1;
ffffffffc02009ce:	4569                	li	a0,26
ffffffffc02009d0:	27f000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc02009d4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009d6:	2c050463          	beqz	a0,ffffffffc0200c9e <best_fit_check+0x480>
ffffffffc02009da:	651c                	ld	a5,8(a0)
ffffffffc02009dc:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02009de:	8b85                	andi	a5,a5,1
ffffffffc02009e0:	34079f63          	bnez	a5,ffffffffc0200d3e <best_fit_check+0x520>
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02009e4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009e6:	00093a83          	ld	s5,0(s2)
ffffffffc02009ea:	00893a03          	ld	s4,8(s2)
ffffffffc02009ee:	01293023          	sd	s2,0(s2)
ffffffffc02009f2:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc02009f6:	259000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc02009fa:	32051263          	bnez	a0,ffffffffc0200d1e <best_fit_check+0x500>
    unsigned int nr_free_store = nr_free;
    nr_free = 0;
    free_pages(p0, 26);
ffffffffc02009fe:	45e9                	li	a1,26
ffffffffc0200a00:	854e                	mv	a0,s3
    unsigned int nr_free_store = nr_free;
ffffffffc0200a02:	01092b03          	lw	s6,16(s2)
    nr_free = 0;
ffffffffc0200a06:	00005797          	auipc	a5,0x5
ffffffffc0200a0a:	6007ad23          	sw	zero,1562(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0, 26);
ffffffffc0200a0e:	27f000ef          	jal	ra,ffffffffc020148c <free_pages>
    p0 = alloc_pages(6);
ffffffffc0200a12:	4519                	li	a0,6
ffffffffc0200a14:	23b000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200a18:	89aa                	mv	s3,a0
    p1 = alloc_pages(10);
ffffffffc0200a1a:	4529                	li	a0,10
ffffffffc0200a1c:	233000ef          	jal	ra,ffffffffc020144e <alloc_pages>
    assert((p0 + 8)->property == 8);
ffffffffc0200a20:	1509ac03          	lw	s8,336(s3)
ffffffffc0200a24:	47a1                	li	a5,8
    p1 = alloc_pages(10);
ffffffffc0200a26:	8baa                	mv	s7,a0
    assert((p0 + 8)->property == 8);
ffffffffc0200a28:	54fc1b63          	bne	s8,a5,ffffffffc0200f7e <best_fit_check+0x760>
    free_pages(p1, 10); 
ffffffffc0200a2c:	45a9                	li	a1,10
ffffffffc0200a2e:	25f000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert((p0 + 8)->property == 8);
ffffffffc0200a32:	1509a783          	lw	a5,336(s3)
ffffffffc0200a36:	53879463          	bne	a5,s8,ffffffffc0200f5e <best_fit_check+0x740>
    assert(p1->property == 16);
ffffffffc0200a3a:	010bac03          	lw	s8,16(s7)
ffffffffc0200a3e:	47c1                	li	a5,16
ffffffffc0200a40:	4efc1f63          	bne	s8,a5,ffffffffc0200f3e <best_fit_check+0x720>
    p1 = alloc_pages(16); 
ffffffffc0200a44:	4541                	li	a0,16
ffffffffc0200a46:	209000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200a4a:	8baa                	mv	s7,a0
    free_pages(p0, 6); 
ffffffffc0200a4c:	4599                	li	a1,6
ffffffffc0200a4e:	854e                	mv	a0,s3
ffffffffc0200a50:	23d000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(p0->property == 16);
ffffffffc0200a54:	0109a783          	lw	a5,16(s3)
ffffffffc0200a58:	4d879363          	bne	a5,s8,ffffffffc0200f1e <best_fit_check+0x700>
    free_pages(p1, 16); 
ffffffffc0200a5c:	45c1                	li	a1,16
ffffffffc0200a5e:	855e                	mv	a0,s7
ffffffffc0200a60:	22d000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(p0->property == 32);
ffffffffc0200a64:	0109ac03          	lw	s8,16(s3)
ffffffffc0200a68:	02000793          	li	a5,32
ffffffffc0200a6c:	48fc1963          	bne	s8,a5,ffffffffc0200efe <best_fit_check+0x6e0>
    p0 = alloc_pages(8); 
ffffffffc0200a70:	4521                	li	a0,8
ffffffffc0200a72:	1dd000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200a76:	89aa                	mv	s3,a0
    p1 = alloc_pages(9); 
ffffffffc0200a78:	4525                	li	a0,9
ffffffffc0200a7a:	1d5000ef          	jal	ra,ffffffffc020144e <alloc_pages>
    free_pages(p1, 9);   
ffffffffc0200a7e:	45a5                	li	a1,9
    p1 = alloc_pages(9); 
ffffffffc0200a80:	8baa                	mv	s7,a0
    free_pages(p1, 9);   
ffffffffc0200a82:	20b000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(p1->property == 16);
ffffffffc0200a86:	010ba703          	lw	a4,16(s7)
ffffffffc0200a8a:	47c1                	li	a5,16
ffffffffc0200a8c:	44f71963          	bne	a4,a5,ffffffffc0200ede <best_fit_check+0x6c0>
    assert((p0 + 8)->property == 8);
ffffffffc0200a90:	1509a703          	lw	a4,336(s3)
ffffffffc0200a94:	47a1                	li	a5,8
ffffffffc0200a96:	42f71463          	bne	a4,a5,ffffffffc0200ebe <best_fit_check+0x6a0>
    free_pages(p0, 8); 
ffffffffc0200a9a:	45a1                	li	a1,8
ffffffffc0200a9c:	854e                	mv	a0,s3
ffffffffc0200a9e:	1ef000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(p0->property == 32);
ffffffffc0200aa2:	0109a783          	lw	a5,16(s3)
ffffffffc0200aa6:	3f879c63          	bne	a5,s8,ffffffffc0200e9e <best_fit_check+0x680>
    p0 = alloc_pages(5);
ffffffffc0200aaa:	4515                	li	a0,5
ffffffffc0200aac:	1a3000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200ab0:	89aa                	mv	s3,a0
    p1 = alloc_pages(16);
ffffffffc0200ab2:	4541                	li	a0,16
ffffffffc0200ab4:	19b000ef          	jal	ra,ffffffffc020144e <alloc_pages>
    free_pages(p1, 16);
ffffffffc0200ab8:	45c1                	li	a1,16
    p1 = alloc_pages(16);
ffffffffc0200aba:	8baa                	mv	s7,a0
    free_pages(p1, 16);
ffffffffc0200abc:	1d1000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc0200ac0:	00893783          	ld	a5,8(s2)
ffffffffc0200ac4:	ed8b8b93          	addi	s7,s7,-296
ffffffffc0200ac8:	3b779b63          	bne	a5,s7,ffffffffc0200e7e <best_fit_check+0x660>
    free_pages(p0, 5);
ffffffffc0200acc:	854e                	mv	a0,s3
ffffffffc0200ace:	4595                	li	a1,5
ffffffffc0200ad0:	1bd000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200ad4:	00893783          	ld	a5,8(s2)
ffffffffc0200ad8:	09e1                	addi	s3,s3,24
ffffffffc0200ada:	31379263          	bne	a5,s3,ffffffffc0200dde <best_fit_check+0x5c0>
    p0 = alloc_pages(5);
ffffffffc0200ade:	4515                	li	a0,5
ffffffffc0200ae0:	16f000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200ae4:	89aa                	mv	s3,a0
    p1 = alloc_pages(16);
ffffffffc0200ae6:	4541                	li	a0,16
ffffffffc0200ae8:	167000ef          	jal	ra,ffffffffc020144e <alloc_pages>
ffffffffc0200aec:	8baa                	mv	s7,a0
    free_pages(p0, 5);
ffffffffc0200aee:	4595                	li	a1,5
ffffffffc0200af0:	854e                	mv	a0,s3
ffffffffc0200af2:	19b000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200af6:	00893783          	ld	a5,8(s2)
ffffffffc0200afa:	09e1                	addi	s3,s3,24
ffffffffc0200afc:	2cf99163          	bne	s3,a5,ffffffffc0200dbe <best_fit_check+0x5a0>
    free_pages(p1, 16);
ffffffffc0200b00:	45c1                	li	a1,16
ffffffffc0200b02:	855e                	mv	a0,s7
ffffffffc0200b04:	189000ef          	jal	ra,ffffffffc020148c <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200b08:	00893783          	ld	a5,8(s2)
ffffffffc0200b0c:	28f99963          	bne	s3,a5,ffffffffc0200d9e <best_fit_check+0x580>
    p0 = alloc_pages(26);
ffffffffc0200b10:	4569                	li	a0,26
ffffffffc0200b12:	13d000ef          	jal	ra,ffffffffc020144e <alloc_pages>
    assert(nr_free == 0);
ffffffffc0200b16:	01092783          	lw	a5,16(s2)
ffffffffc0200b1a:	32079263          	bnez	a5,ffffffffc0200e3e <best_fit_check+0x620>
    nr_free = nr_free_store;
    free_list = free_list_store;
    free_pages(p0, 26);
ffffffffc0200b1e:	45e9                	li	a1,26
    nr_free = nr_free_store;
ffffffffc0200b20:	01692823          	sw	s6,16(s2)
    free_list = free_list_store;
ffffffffc0200b24:	01593023          	sd	s5,0(s2)
ffffffffc0200b28:	01493423          	sd	s4,8(s2)
    free_pages(p0, 26);
ffffffffc0200b2c:	161000ef          	jal	ra,ffffffffc020148c <free_pages>
    return listelm->next;
ffffffffc0200b30:	00893783          	ld	a5,8(s2)
    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b34:	03278163          	beq	a5,s2,ffffffffc0200b56 <best_fit_check+0x338>
    {
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc0200b38:	86be                	mv	a3,a5
ffffffffc0200b3a:	679c                	ld	a5,8(a5)
ffffffffc0200b3c:	6398                	ld	a4,0(a5)
ffffffffc0200b3e:	04d71063          	bne	a4,a3,ffffffffc0200b7e <best_fit_check+0x360>
ffffffffc0200b42:	6314                	ld	a3,0(a4)
ffffffffc0200b44:	6694                	ld	a3,8(a3)
ffffffffc0200b46:	02e69c63          	bne	a3,a4,ffffffffc0200b7e <best_fit_check+0x360>
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0200b4a:	ff86a703          	lw	a4,-8(a3)
ffffffffc0200b4e:	34fd                	addiw	s1,s1,-1
ffffffffc0200b50:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b52:	ff2793e3          	bne	a5,s2,ffffffffc0200b38 <best_fit_check+0x31a>
    }
    assert(count == 0);
ffffffffc0200b56:	44049463          	bnez	s1,ffffffffc0200f9e <best_fit_check+0x780>
    assert(total == 0);
ffffffffc0200b5a:	2a041263          	bnez	s0,ffffffffc0200dfe <best_fit_check+0x5e0>
}
ffffffffc0200b5e:	60a6                	ld	ra,72(sp)
ffffffffc0200b60:	6406                	ld	s0,64(sp)
ffffffffc0200b62:	74e2                	ld	s1,56(sp)
ffffffffc0200b64:	7942                	ld	s2,48(sp)
ffffffffc0200b66:	79a2                	ld	s3,40(sp)
ffffffffc0200b68:	7a02                	ld	s4,32(sp)
ffffffffc0200b6a:	6ae2                	ld	s5,24(sp)
ffffffffc0200b6c:	6b42                	ld	s6,16(sp)
ffffffffc0200b6e:	6ba2                	ld	s7,8(sp)
ffffffffc0200b70:	6c02                	ld	s8,0(sp)
ffffffffc0200b72:	6161                	addi	sp,sp,80
ffffffffc0200b74:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b76:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b78:	4401                	li	s0,0
ffffffffc0200b7a:	4481                	li	s1,0
ffffffffc0200b7c:	b1dd                	j	ffffffffc0200862 <best_fit_check+0x44>
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc0200b7e:	00002697          	auipc	a3,0x2
ffffffffc0200b82:	aaa68693          	addi	a3,a3,-1366 # ffffffffc0202628 <commands+0x7e0>
ffffffffc0200b86:	00001617          	auipc	a2,0x1
ffffffffc0200b8a:	7ca60613          	addi	a2,a2,1994 # ffffffffc0202350 <commands+0x508>
ffffffffc0200b8e:	15300593          	li	a1,339
ffffffffc0200b92:	00001517          	auipc	a0,0x1
ffffffffc0200b96:	7d650513          	addi	a0,a0,2006 # ffffffffc0202368 <commands+0x520>
ffffffffc0200b9a:	813ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        assert(PageProperty(p));
ffffffffc0200b9e:	00001697          	auipc	a3,0x1
ffffffffc0200ba2:	7a268693          	addi	a3,a3,1954 # ffffffffc0202340 <commands+0x4f8>
ffffffffc0200ba6:	00001617          	auipc	a2,0x1
ffffffffc0200baa:	7aa60613          	addi	a2,a2,1962 # ffffffffc0202350 <commands+0x508>
ffffffffc0200bae:	11e00593          	li	a1,286
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	7b650513          	addi	a0,a0,1974 # ffffffffc0202368 <commands+0x520>
ffffffffc0200bba:	ff2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200bbe:	00002697          	auipc	a3,0x2
ffffffffc0200bc2:	93268693          	addi	a3,a3,-1742 # ffffffffc02024f0 <commands+0x6a8>
ffffffffc0200bc6:	00001617          	auipc	a2,0x1
ffffffffc0200bca:	78a60613          	addi	a2,a2,1930 # ffffffffc0202350 <commands+0x508>
ffffffffc0200bce:	10300593          	li	a1,259
ffffffffc0200bd2:	00001517          	auipc	a0,0x1
ffffffffc0200bd6:	79650513          	addi	a0,a0,1942 # ffffffffc0202368 <commands+0x520>
ffffffffc0200bda:	fd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bde:	00001697          	auipc	a3,0x1
ffffffffc0200be2:	7c268693          	addi	a3,a3,1986 # ffffffffc02023a0 <commands+0x558>
ffffffffc0200be6:	00001617          	auipc	a2,0x1
ffffffffc0200bea:	76a60613          	addi	a2,a2,1898 # ffffffffc0202350 <commands+0x508>
ffffffffc0200bee:	0fc00593          	li	a1,252
ffffffffc0200bf2:	00001517          	auipc	a0,0x1
ffffffffc0200bf6:	77650513          	addi	a0,a0,1910 # ffffffffc0202368 <commands+0x520>
ffffffffc0200bfa:	fb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200bfe:	00002697          	auipc	a3,0x2
ffffffffc0200c02:	8e268693          	addi	a3,a3,-1822 # ffffffffc02024e0 <commands+0x698>
ffffffffc0200c06:	00001617          	auipc	a2,0x1
ffffffffc0200c0a:	74a60613          	addi	a2,a2,1866 # ffffffffc0202350 <commands+0x508>
ffffffffc0200c0e:	0fa00593          	li	a1,250
ffffffffc0200c12:	00001517          	auipc	a0,0x1
ffffffffc0200c16:	75650513          	addi	a0,a0,1878 # ffffffffc0202368 <commands+0x520>
ffffffffc0200c1a:	f92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c1e:	00002697          	auipc	a3,0x2
ffffffffc0200c22:	8aa68693          	addi	a3,a3,-1878 # ffffffffc02024c8 <commands+0x680>
ffffffffc0200c26:	00001617          	auipc	a2,0x1
ffffffffc0200c2a:	72a60613          	addi	a2,a2,1834 # ffffffffc0202350 <commands+0x508>
ffffffffc0200c2e:	0f500593          	li	a1,245
ffffffffc0200c32:	00001517          	auipc	a0,0x1
ffffffffc0200c36:	73650513          	addi	a0,a0,1846 # ffffffffc0202368 <commands+0x520>
ffffffffc0200c3a:	f72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c3e:	00002697          	auipc	a3,0x2
ffffffffc0200c42:	86a68693          	addi	a3,a3,-1942 # ffffffffc02024a8 <commands+0x660>
ffffffffc0200c46:	00001617          	auipc	a2,0x1
ffffffffc0200c4a:	70a60613          	addi	a2,a2,1802 # ffffffffc0202350 <commands+0x508>
ffffffffc0200c4e:	0ec00593          	li	a1,236
ffffffffc0200c52:	00001517          	auipc	a0,0x1
ffffffffc0200c56:	71650513          	addi	a0,a0,1814 # ffffffffc0202368 <commands+0x520>
ffffffffc0200c5a:	f52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c5e:	00001697          	auipc	a3,0x1
ffffffffc0200c62:	78268693          	addi	a3,a3,1922 # ffffffffc02023e0 <commands+0x598>
ffffffffc0200c66:	00001617          	auipc	a2,0x1
ffffffffc0200c6a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0202350 <commands+0x508>
ffffffffc0200c6e:	0fe00593          	li	a1,254
ffffffffc0200c72:	00001517          	auipc	a0,0x1
ffffffffc0200c76:	6f650513          	addi	a0,a0,1782 # ffffffffc0202368 <commands+0x520>
ffffffffc0200c7a:	f32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c7e:	00001697          	auipc	a3,0x1
ffffffffc0200c82:	74268693          	addi	a3,a3,1858 # ffffffffc02023c0 <commands+0x578>
ffffffffc0200c86:	00001617          	auipc	a2,0x1
ffffffffc0200c8a:	6ca60613          	addi	a2,a2,1738 # ffffffffc0202350 <commands+0x508>
ffffffffc0200c8e:	0fd00593          	li	a1,253
ffffffffc0200c92:	00001517          	auipc	a0,0x1
ffffffffc0200c96:	6d650513          	addi	a0,a0,1750 # ffffffffc0202368 <commands+0x520>
ffffffffc0200c9a:	f12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200c9e:	00002697          	auipc	a3,0x2
ffffffffc0200ca2:	89a68693          	addi	a3,a3,-1894 # ffffffffc0202538 <commands+0x6f0>
ffffffffc0200ca6:	00001617          	auipc	a2,0x1
ffffffffc0200caa:	6aa60613          	addi	a2,a2,1706 # ffffffffc0202350 <commands+0x508>
ffffffffc0200cae:	12400593          	li	a1,292
ffffffffc0200cb2:	00001517          	auipc	a0,0x1
ffffffffc0200cb6:	6b650513          	addi	a0,a0,1718 # ffffffffc0202368 <commands+0x520>
ffffffffc0200cba:	ef2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200cbe:	00002697          	auipc	a3,0x2
ffffffffc0200cc2:	86a68693          	addi	a3,a3,-1942 # ffffffffc0202528 <commands+0x6e0>
ffffffffc0200cc6:	00001617          	auipc	a2,0x1
ffffffffc0200cca:	68a60613          	addi	a2,a2,1674 # ffffffffc0202350 <commands+0x508>
ffffffffc0200cce:	10900593          	li	a1,265
ffffffffc0200cd2:	00001517          	auipc	a0,0x1
ffffffffc0200cd6:	69650513          	addi	a0,a0,1686 # ffffffffc0202368 <commands+0x520>
ffffffffc0200cda:	ed2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cde:	00001697          	auipc	a3,0x1
ffffffffc0200ce2:	7ea68693          	addi	a3,a3,2026 # ffffffffc02024c8 <commands+0x680>
ffffffffc0200ce6:	00001617          	auipc	a2,0x1
ffffffffc0200cea:	66a60613          	addi	a2,a2,1642 # ffffffffc0202350 <commands+0x508>
ffffffffc0200cee:	10700593          	li	a1,263
ffffffffc0200cf2:	00001517          	auipc	a0,0x1
ffffffffc0200cf6:	67650513          	addi	a0,a0,1654 # ffffffffc0202368 <commands+0x520>
ffffffffc0200cfa:	eb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200cfe:	00002697          	auipc	a3,0x2
ffffffffc0200d02:	80a68693          	addi	a3,a3,-2038 # ffffffffc0202508 <commands+0x6c0>
ffffffffc0200d06:	00001617          	auipc	a2,0x1
ffffffffc0200d0a:	64a60613          	addi	a2,a2,1610 # ffffffffc0202350 <commands+0x508>
ffffffffc0200d0e:	10600593          	li	a1,262
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	65650513          	addi	a0,a0,1622 # ffffffffc0202368 <commands+0x520>
ffffffffc0200d1a:	e92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d1e:	00001697          	auipc	a3,0x1
ffffffffc0200d22:	7aa68693          	addi	a3,a3,1962 # ffffffffc02024c8 <commands+0x680>
ffffffffc0200d26:	00001617          	auipc	a2,0x1
ffffffffc0200d2a:	62a60613          	addi	a2,a2,1578 # ffffffffc0202350 <commands+0x508>
ffffffffc0200d2e:	12900593          	li	a1,297
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	63650513          	addi	a0,a0,1590 # ffffffffc0202368 <commands+0x520>
ffffffffc0200d3a:	e72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200d3e:	00002697          	auipc	a3,0x2
ffffffffc0200d42:	80a68693          	addi	a3,a3,-2038 # ffffffffc0202548 <commands+0x700>
ffffffffc0200d46:	00001617          	auipc	a2,0x1
ffffffffc0200d4a:	60a60613          	addi	a2,a2,1546 # ffffffffc0202350 <commands+0x508>
ffffffffc0200d4e:	12500593          	li	a1,293
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	61650513          	addi	a0,a0,1558 # ffffffffc0202368 <commands+0x520>
ffffffffc0200d5a:	e52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	68268693          	addi	a3,a3,1666 # ffffffffc02023e0 <commands+0x598>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	5ea60613          	addi	a2,a2,1514 # ffffffffc0202350 <commands+0x508>
ffffffffc0200d6e:	0e500593          	li	a1,229
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	5f650513          	addi	a0,a0,1526 # ffffffffc0202368 <commands+0x520>
ffffffffc0200d7a:	e32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	74a68693          	addi	a3,a3,1866 # ffffffffc02024c8 <commands+0x680>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0202350 <commands+0x508>
ffffffffc0200d8e:	10000593          	li	a1,256
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	5d650513          	addi	a0,a0,1494 # ffffffffc0202368 <commands+0x520>
ffffffffc0200d9a:	e12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200d9e:	00002697          	auipc	a3,0x2
ffffffffc0200da2:	85a68693          	addi	a3,a3,-1958 # ffffffffc02025f8 <commands+0x7b0>
ffffffffc0200da6:	00001617          	auipc	a2,0x1
ffffffffc0200daa:	5aa60613          	addi	a2,a2,1450 # ffffffffc0202350 <commands+0x508>
ffffffffc0200dae:	14a00593          	li	a1,330
ffffffffc0200db2:	00001517          	auipc	a0,0x1
ffffffffc0200db6:	5b650513          	addi	a0,a0,1462 # ffffffffc0202368 <commands+0x520>
ffffffffc0200dba:	df2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200dbe:	00002697          	auipc	a3,0x2
ffffffffc0200dc2:	83a68693          	addi	a3,a3,-1990 # ffffffffc02025f8 <commands+0x7b0>
ffffffffc0200dc6:	00001617          	auipc	a2,0x1
ffffffffc0200dca:	58a60613          	addi	a2,a2,1418 # ffffffffc0202350 <commands+0x508>
ffffffffc0200dce:	14800593          	li	a1,328
ffffffffc0200dd2:	00001517          	auipc	a0,0x1
ffffffffc0200dd6:	59650513          	addi	a0,a0,1430 # ffffffffc0202368 <commands+0x520>
ffffffffc0200dda:	dd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200dde:	00002697          	auipc	a3,0x2
ffffffffc0200de2:	81a68693          	addi	a3,a3,-2022 # ffffffffc02025f8 <commands+0x7b0>
ffffffffc0200de6:	00001617          	auipc	a2,0x1
ffffffffc0200dea:	56a60613          	addi	a2,a2,1386 # ffffffffc0202350 <commands+0x508>
ffffffffc0200dee:	14400593          	li	a1,324
ffffffffc0200df2:	00001517          	auipc	a0,0x1
ffffffffc0200df6:	57650513          	addi	a0,a0,1398 # ffffffffc0202368 <commands+0x520>
ffffffffc0200dfa:	db2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200dfe:	00002697          	auipc	a3,0x2
ffffffffc0200e02:	86a68693          	addi	a3,a3,-1942 # ffffffffc0202668 <commands+0x820>
ffffffffc0200e06:	00001617          	auipc	a2,0x1
ffffffffc0200e0a:	54a60613          	addi	a2,a2,1354 # ffffffffc0202350 <commands+0x508>
ffffffffc0200e0e:	15800593          	li	a1,344
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	55650513          	addi	a0,a0,1366 # ffffffffc0202368 <commands+0x520>
ffffffffc0200e1a:	d92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	56268693          	addi	a3,a3,1378 # ffffffffc0202380 <commands+0x538>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	52a60613          	addi	a2,a2,1322 # ffffffffc0202350 <commands+0x508>
ffffffffc0200e2e:	12100593          	li	a1,289
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	53650513          	addi	a0,a0,1334 # ffffffffc0202368 <commands+0x520>
ffffffffc0200e3a:	d72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e3e:	00001697          	auipc	a3,0x1
ffffffffc0200e42:	6ea68693          	addi	a3,a3,1770 # ffffffffc0202528 <commands+0x6e0>
ffffffffc0200e46:	00001617          	auipc	a2,0x1
ffffffffc0200e4a:	50a60613          	addi	a2,a2,1290 # ffffffffc0202350 <commands+0x508>
ffffffffc0200e4e:	14c00593          	li	a1,332
ffffffffc0200e52:	00001517          	auipc	a0,0x1
ffffffffc0200e56:	51650513          	addi	a0,a0,1302 # ffffffffc0202368 <commands+0x520>
ffffffffc0200e5a:	d52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e5e:	00001697          	auipc	a3,0x1
ffffffffc0200e62:	62a68693          	addi	a3,a3,1578 # ffffffffc0202488 <commands+0x640>
ffffffffc0200e66:	00001617          	auipc	a2,0x1
ffffffffc0200e6a:	4ea60613          	addi	a2,a2,1258 # ffffffffc0202350 <commands+0x508>
ffffffffc0200e6e:	0eb00593          	li	a1,235
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	4f650513          	addi	a0,a0,1270 # ffffffffc0202368 <commands+0x520>
ffffffffc0200e7a:	d32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc0200e7e:	00001697          	auipc	a3,0x1
ffffffffc0200e82:	74268693          	addi	a3,a3,1858 # ffffffffc02025c0 <commands+0x778>
ffffffffc0200e86:	00001617          	auipc	a2,0x1
ffffffffc0200e8a:	4ca60613          	addi	a2,a2,1226 # ffffffffc0202350 <commands+0x508>
ffffffffc0200e8e:	14200593          	li	a1,322
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	4d650513          	addi	a0,a0,1238 # ffffffffc0202368 <commands+0x520>
ffffffffc0200e9a:	d12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0->property == 32);
ffffffffc0200e9e:	00001697          	auipc	a3,0x1
ffffffffc0200ea2:	70a68693          	addi	a3,a3,1802 # ffffffffc02025a8 <commands+0x760>
ffffffffc0200ea6:	00001617          	auipc	a2,0x1
ffffffffc0200eaa:	4aa60613          	addi	a2,a2,1194 # ffffffffc0202350 <commands+0x508>
ffffffffc0200eae:	13e00593          	li	a1,318
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	4b650513          	addi	a0,a0,1206 # ffffffffc0202368 <commands+0x520>
ffffffffc0200eba:	cf2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200ebe:	00001697          	auipc	a3,0x1
ffffffffc0200ec2:	6a268693          	addi	a3,a3,1698 # ffffffffc0202560 <commands+0x718>
ffffffffc0200ec6:	00001617          	auipc	a2,0x1
ffffffffc0200eca:	48a60613          	addi	a2,a2,1162 # ffffffffc0202350 <commands+0x508>
ffffffffc0200ece:	13c00593          	li	a1,316
ffffffffc0200ed2:	00001517          	auipc	a0,0x1
ffffffffc0200ed6:	49650513          	addi	a0,a0,1174 # ffffffffc0202368 <commands+0x520>
ffffffffc0200eda:	cd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->property == 16);
ffffffffc0200ede:	00001697          	auipc	a3,0x1
ffffffffc0200ee2:	69a68693          	addi	a3,a3,1690 # ffffffffc0202578 <commands+0x730>
ffffffffc0200ee6:	00001617          	auipc	a2,0x1
ffffffffc0200eea:	46a60613          	addi	a2,a2,1130 # ffffffffc0202350 <commands+0x508>
ffffffffc0200eee:	13b00593          	li	a1,315
ffffffffc0200ef2:	00001517          	auipc	a0,0x1
ffffffffc0200ef6:	47650513          	addi	a0,a0,1142 # ffffffffc0202368 <commands+0x520>
ffffffffc0200efa:	cb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0->property == 32);
ffffffffc0200efe:	00001697          	auipc	a3,0x1
ffffffffc0200f02:	6aa68693          	addi	a3,a3,1706 # ffffffffc02025a8 <commands+0x760>
ffffffffc0200f06:	00001617          	auipc	a2,0x1
ffffffffc0200f0a:	44a60613          	addi	a2,a2,1098 # ffffffffc0202350 <commands+0x508>
ffffffffc0200f0e:	13700593          	li	a1,311
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	45650513          	addi	a0,a0,1110 # ffffffffc0202368 <commands+0x520>
ffffffffc0200f1a:	c92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0->property == 16);
ffffffffc0200f1e:	00001697          	auipc	a3,0x1
ffffffffc0200f22:	67268693          	addi	a3,a3,1650 # ffffffffc0202590 <commands+0x748>
ffffffffc0200f26:	00001617          	auipc	a2,0x1
ffffffffc0200f2a:	42a60613          	addi	a2,a2,1066 # ffffffffc0202350 <commands+0x508>
ffffffffc0200f2e:	13500593          	li	a1,309
ffffffffc0200f32:	00001517          	auipc	a0,0x1
ffffffffc0200f36:	43650513          	addi	a0,a0,1078 # ffffffffc0202368 <commands+0x520>
ffffffffc0200f3a:	c72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->property == 16);
ffffffffc0200f3e:	00001697          	auipc	a3,0x1
ffffffffc0200f42:	63a68693          	addi	a3,a3,1594 # ffffffffc0202578 <commands+0x730>
ffffffffc0200f46:	00001617          	auipc	a2,0x1
ffffffffc0200f4a:	40a60613          	addi	a2,a2,1034 # ffffffffc0202350 <commands+0x508>
ffffffffc0200f4e:	13200593          	li	a1,306
ffffffffc0200f52:	00001517          	auipc	a0,0x1
ffffffffc0200f56:	41650513          	addi	a0,a0,1046 # ffffffffc0202368 <commands+0x520>
ffffffffc0200f5a:	c52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200f5e:	00001697          	auipc	a3,0x1
ffffffffc0200f62:	60268693          	addi	a3,a3,1538 # ffffffffc0202560 <commands+0x718>
ffffffffc0200f66:	00001617          	auipc	a2,0x1
ffffffffc0200f6a:	3ea60613          	addi	a2,a2,1002 # ffffffffc0202350 <commands+0x508>
ffffffffc0200f6e:	13100593          	li	a1,305
ffffffffc0200f72:	00001517          	auipc	a0,0x1
ffffffffc0200f76:	3f650513          	addi	a0,a0,1014 # ffffffffc0202368 <commands+0x520>
ffffffffc0200f7a:	c32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200f7e:	00001697          	auipc	a3,0x1
ffffffffc0200f82:	5e268693          	addi	a3,a3,1506 # ffffffffc0202560 <commands+0x718>
ffffffffc0200f86:	00001617          	auipc	a2,0x1
ffffffffc0200f8a:	3ca60613          	addi	a2,a2,970 # ffffffffc0202350 <commands+0x508>
ffffffffc0200f8e:	12f00593          	li	a1,303
ffffffffc0200f92:	00001517          	auipc	a0,0x1
ffffffffc0200f96:	3d650513          	addi	a0,a0,982 # ffffffffc0202368 <commands+0x520>
ffffffffc0200f9a:	c12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200f9e:	00001697          	auipc	a3,0x1
ffffffffc0200fa2:	6ba68693          	addi	a3,a3,1722 # ffffffffc0202658 <commands+0x810>
ffffffffc0200fa6:	00001617          	auipc	a2,0x1
ffffffffc0200faa:	3aa60613          	addi	a2,a2,938 # ffffffffc0202350 <commands+0x508>
ffffffffc0200fae:	15700593          	li	a1,343
ffffffffc0200fb2:	00001517          	auipc	a0,0x1
ffffffffc0200fb6:	3b650513          	addi	a0,a0,950 # ffffffffc0202368 <commands+0x520>
ffffffffc0200fba:	bf2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fbe:	00001697          	auipc	a3,0x1
ffffffffc0200fc2:	40268693          	addi	a3,a3,1026 # ffffffffc02023c0 <commands+0x578>
ffffffffc0200fc6:	00001617          	auipc	a2,0x1
ffffffffc0200fca:	38a60613          	addi	a2,a2,906 # ffffffffc0202350 <commands+0x508>
ffffffffc0200fce:	0e400593          	li	a1,228
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	39650513          	addi	a0,a0,918 # ffffffffc0202368 <commands+0x520>
ffffffffc0200fda:	bd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fde:	00001697          	auipc	a3,0x1
ffffffffc0200fe2:	3c268693          	addi	a3,a3,962 # ffffffffc02023a0 <commands+0x558>
ffffffffc0200fe6:	00001617          	auipc	a2,0x1
ffffffffc0200fea:	36a60613          	addi	a2,a2,874 # ffffffffc0202350 <commands+0x508>
ffffffffc0200fee:	0e300593          	li	a1,227
ffffffffc0200ff2:	00001517          	auipc	a0,0x1
ffffffffc0200ff6:	37650513          	addi	a0,a0,886 # ffffffffc0202368 <commands+0x520>
ffffffffc0200ffa:	bb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ffe:	00001697          	auipc	a3,0x1
ffffffffc0201002:	46a68693          	addi	a3,a3,1130 # ffffffffc0202468 <commands+0x620>
ffffffffc0201006:	00001617          	auipc	a2,0x1
ffffffffc020100a:	34a60613          	addi	a2,a2,842 # ffffffffc0202350 <commands+0x508>
ffffffffc020100e:	0ea00593          	li	a1,234
ffffffffc0201012:	00001517          	auipc	a0,0x1
ffffffffc0201016:	35650513          	addi	a0,a0,854 # ffffffffc0202368 <commands+0x520>
ffffffffc020101a:	b92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020101e:	00001697          	auipc	a3,0x1
ffffffffc0201022:	40a68693          	addi	a3,a3,1034 # ffffffffc0202428 <commands+0x5e0>
ffffffffc0201026:	00001617          	auipc	a2,0x1
ffffffffc020102a:	32a60613          	addi	a2,a2,810 # ffffffffc0202350 <commands+0x508>
ffffffffc020102e:	0e800593          	li	a1,232
ffffffffc0201032:	00001517          	auipc	a0,0x1
ffffffffc0201036:	33650513          	addi	a0,a0,822 # ffffffffc0202368 <commands+0x520>
ffffffffc020103a:	b72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020103e:	00001697          	auipc	a3,0x1
ffffffffc0201042:	3c268693          	addi	a3,a3,962 # ffffffffc0202400 <commands+0x5b8>
ffffffffc0201046:	00001617          	auipc	a2,0x1
ffffffffc020104a:	30a60613          	addi	a2,a2,778 # ffffffffc0202350 <commands+0x508>
ffffffffc020104e:	0e700593          	li	a1,231
ffffffffc0201052:	00001517          	auipc	a0,0x1
ffffffffc0201056:	31650513          	addi	a0,a0,790 # ffffffffc0202368 <commands+0x520>
ffffffffc020105a:	b52ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020105e <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020105e:	1141                	addi	sp,sp,-16
ffffffffc0201060:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201062:	c1e9                	beqz	a1,ffffffffc0201124 <best_fit_init_memmap+0xc6>
    for (; p != base + n; p ++) {
ffffffffc0201064:	00259693          	slli	a3,a1,0x2
ffffffffc0201068:	96ae                	add	a3,a3,a1
ffffffffc020106a:	068e                	slli	a3,a3,0x3
ffffffffc020106c:	96aa                	add	a3,a3,a0
ffffffffc020106e:	87aa                	mv	a5,a0
ffffffffc0201070:	00d50f63          	beq	a0,a3,ffffffffc020108e <best_fit_init_memmap+0x30>
ffffffffc0201074:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201076:	8b05                	andi	a4,a4,1
ffffffffc0201078:	c751                	beqz	a4,ffffffffc0201104 <best_fit_init_memmap+0xa6>
        p->flags = p->property = 0;
ffffffffc020107a:	0007a823          	sw	zero,16(a5)
ffffffffc020107e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201082:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201086:	02878793          	addi	a5,a5,40
ffffffffc020108a:	fed795e3          	bne	a5,a3,ffffffffc0201074 <best_fit_init_memmap+0x16>
    nr_free += n;
ffffffffc020108e:	00005617          	auipc	a2,0x5
ffffffffc0201092:	f8260613          	addi	a2,a2,-126 # ffffffffc0206010 <free_area>
ffffffffc0201096:	4a1c                	lw	a5,16(a2)
    size_t block_size = 1;
ffffffffc0201098:	4805                	li	a6,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020109a:	4309                	li	t1,2
    nr_free += n;
ffffffffc020109c:	9fad                	addw	a5,a5,a1
ffffffffc020109e:	ca1c                	sw	a5,16(a2)
    while(n > 0){
ffffffffc02010a0:	a019                	j	ffffffffc02010a6 <best_fit_init_memmap+0x48>
        block_size <<= 1;
ffffffffc02010a2:	0806                	slli	a6,a6,0x1
    while(n > 0){
ffffffffc02010a4:	cda9                	beqz	a1,ffffffffc02010fe <best_fit_init_memmap+0xa0>
        size_t temp = n & 1;
ffffffffc02010a6:	0015f793          	andi	a5,a1,1
        n >>= 1;
ffffffffc02010aa:	8185                	srli	a1,a1,0x1
        if(temp != 0){
ffffffffc02010ac:	dbfd                	beqz	a5,ffffffffc02010a2 <best_fit_init_memmap+0x44>
            base->property = block_size;
ffffffffc02010ae:	01052823          	sw	a6,16(a0)
ffffffffc02010b2:	00850793          	addi	a5,a0,8
ffffffffc02010b6:	4067b02f          	amoor.d	zero,t1,(a5)
ffffffffc02010ba:	661c                	ld	a5,8(a2)
            while((le = list_next(le)) != &free_list){
ffffffffc02010bc:	02c78163          	beq	a5,a2,ffffffffc02010de <best_fit_init_memmap+0x80>
                if(p->property > base->property ||( p->property == base->property && base < p)){
ffffffffc02010c0:	4914                	lw	a3,16(a0)
ffffffffc02010c2:	a021                	j	ffffffffc02010ca <best_fit_init_memmap+0x6c>
ffffffffc02010c4:	679c                	ld	a5,8(a5)
            while((le = list_next(le)) != &free_list){
ffffffffc02010c6:	00c78c63          	beq	a5,a2,ffffffffc02010de <best_fit_init_memmap+0x80>
                if(p->property > base->property ||( p->property == base->property && base < p)){
ffffffffc02010ca:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ce:	00e6e863          	bltu	a3,a4,ffffffffc02010de <best_fit_init_memmap+0x80>
ffffffffc02010d2:	fed719e3          	bne	a4,a3,ffffffffc02010c4 <best_fit_init_memmap+0x66>
                struct Page *p = le2page(le, page_link);
ffffffffc02010d6:	fe878713          	addi	a4,a5,-24
                if(p->property > base->property ||( p->property == base->property && base < p)){
ffffffffc02010da:	fee575e3          	bgeu	a0,a4,ffffffffc02010c4 <best_fit_init_memmap+0x66>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010de:	6394                	ld	a3,0(a5)
            list_add_before(le, &(base->page_link));
ffffffffc02010e0:	01850893          	addi	a7,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02010e4:	0117b023          	sd	a7,0(a5)
            base += block_size;
ffffffffc02010e8:	00281713          	slli	a4,a6,0x2
ffffffffc02010ec:	9742                	add	a4,a4,a6
ffffffffc02010ee:	0116b423          	sd	a7,8(a3)
ffffffffc02010f2:	070e                	slli	a4,a4,0x3
    elm->next = next;
ffffffffc02010f4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010f6:	ed14                	sd	a3,24(a0)
        block_size <<= 1;
ffffffffc02010f8:	0806                	slli	a6,a6,0x1
            base += block_size;
ffffffffc02010fa:	953a                	add	a0,a0,a4
    while(n > 0){
ffffffffc02010fc:	f5cd                	bnez	a1,ffffffffc02010a6 <best_fit_init_memmap+0x48>
}
ffffffffc02010fe:	60a2                	ld	ra,8(sp)
ffffffffc0201100:	0141                	addi	sp,sp,16
ffffffffc0201102:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201104:	00001697          	auipc	a3,0x1
ffffffffc0201108:	57c68693          	addi	a3,a3,1404 # ffffffffc0202680 <commands+0x838>
ffffffffc020110c:	00001617          	auipc	a2,0x1
ffffffffc0201110:	24460613          	addi	a2,a2,580 # ffffffffc0202350 <commands+0x508>
ffffffffc0201114:	05700593          	li	a1,87
ffffffffc0201118:	00001517          	auipc	a0,0x1
ffffffffc020111c:	25050513          	addi	a0,a0,592 # ffffffffc0202368 <commands+0x520>
ffffffffc0201120:	a8cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201124:	00001697          	auipc	a3,0x1
ffffffffc0201128:	55468693          	addi	a3,a3,1364 # ffffffffc0202678 <commands+0x830>
ffffffffc020112c:	00001617          	auipc	a2,0x1
ffffffffc0201130:	22460613          	addi	a2,a2,548 # ffffffffc0202350 <commands+0x508>
ffffffffc0201134:	05400593          	li	a1,84
ffffffffc0201138:	00001517          	auipc	a0,0x1
ffffffffc020113c:	23050513          	addi	a0,a0,560 # ffffffffc0202368 <commands+0x520>
ffffffffc0201140:	a6cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201144 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201144:	1141                	addi	sp,sp,-16
ffffffffc0201146:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201148:	1a058c63          	beqz	a1,ffffffffc0201300 <best_fit_free_pages+0x1bc>
    size_t count = 1;
ffffffffc020114c:	4605                	li	a2,1
ffffffffc020114e:	02850693          	addi	a3,a0,40
    while(count < n){
ffffffffc0201152:	00c58c63          	beq	a1,a2,ffffffffc020116a <best_fit_free_pages+0x26>
        count <<= 1;
ffffffffc0201156:	0606                	slli	a2,a2,0x1
    while(count < n){
ffffffffc0201158:	feb66fe3          	bltu	a2,a1,ffffffffc0201156 <best_fit_free_pages+0x12>
    for (; p != base + n; p ++) {
ffffffffc020115c:	00261693          	slli	a3,a2,0x2
ffffffffc0201160:	96b2                	add	a3,a3,a2
ffffffffc0201162:	068e                	slli	a3,a3,0x3
ffffffffc0201164:	96aa                	add	a3,a3,a0
ffffffffc0201166:	02d50363          	beq	a0,a3,ffffffffc020118c <best_fit_free_pages+0x48>
ffffffffc020116a:	87aa                	mv	a5,a0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020116c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020116e:	8b05                	andi	a4,a4,1
ffffffffc0201170:	16071863          	bnez	a4,ffffffffc02012e0 <best_fit_free_pages+0x19c>
ffffffffc0201174:	6798                	ld	a4,8(a5)
ffffffffc0201176:	8b09                	andi	a4,a4,2
ffffffffc0201178:	16071463          	bnez	a4,ffffffffc02012e0 <best_fit_free_pages+0x19c>
        p->flags = 0;
ffffffffc020117c:	0007b423          	sd	zero,8(a5)
ffffffffc0201180:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201184:	02878793          	addi	a5,a5,40
ffffffffc0201188:	fed792e3          	bne	a5,a3,ffffffffc020116c <best_fit_free_pages+0x28>
    base->property = n;
ffffffffc020118c:	2601                	sext.w	a2,a2
ffffffffc020118e:	c910                	sw	a2,16(a0)
    SetPageProperty(base);
ffffffffc0201190:	00850313          	addi	t1,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201194:	4789                	li	a5,2
ffffffffc0201196:	40f3302f          	amoor.d	zero,a5,(t1)
    nr_free += n;
ffffffffc020119a:	00005817          	auipc	a6,0x5
ffffffffc020119e:	e7680813          	addi	a6,a6,-394 # ffffffffc0206010 <free_area>
ffffffffc02011a2:	01082703          	lw	a4,16(a6)
    return listelm->next;
ffffffffc02011a6:	00883783          	ld	a5,8(a6)
ffffffffc02011aa:	9e39                	addw	a2,a2,a4
ffffffffc02011ac:	00c82823          	sw	a2,16(a6)
    while((le = list_next(le)) != &free_list){
ffffffffc02011b0:	13078663          	beq	a5,a6,ffffffffc02012dc <best_fit_free_pages+0x198>
        if(p->property > base->property ||( p->property == base->property && p > base)){
ffffffffc02011b4:	4910                	lw	a2,16(a0)
ffffffffc02011b6:	a021                	j	ffffffffc02011be <best_fit_free_pages+0x7a>
ffffffffc02011b8:	679c                	ld	a5,8(a5)
    while((le = list_next(le)) != &free_list){
ffffffffc02011ba:	01078c63          	beq	a5,a6,ffffffffc02011d2 <best_fit_free_pages+0x8e>
        if(p->property > base->property ||( p->property == base->property && p > base)){
ffffffffc02011be:	ff87a703          	lw	a4,-8(a5)
        p = le2page(le, page_link); 
ffffffffc02011c2:	fe878693          	addi	a3,a5,-24
        if(p->property > base->property ||( p->property == base->property && p > base)){
ffffffffc02011c6:	00e66663          	bltu	a2,a4,ffffffffc02011d2 <best_fit_free_pages+0x8e>
ffffffffc02011ca:	fec717e3          	bne	a4,a2,ffffffffc02011b8 <best_fit_free_pages+0x74>
ffffffffc02011ce:	fed575e3          	bgeu	a0,a3,ffffffffc02011b8 <best_fit_free_pages+0x74>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011d2:	6398                	ld	a4,0(a5)
    list_add_before(le, &(base->page_link));
ffffffffc02011d4:	01850593          	addi	a1,a0,24
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc02011d8:	0106a883          	lw	a7,16(a3)
    prev->next = next->prev = elm;
ffffffffc02011dc:	e38c                	sd	a1,0(a5)
ffffffffc02011de:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02011e0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011e2:	ed18                	sd	a4,24(a0)
ffffffffc02011e4:	0ac88763          	beq	a7,a2,ffffffffc0201292 <best_fit_free_pages+0x14e>
    while ((le = list_next(le)) != &free_list)
ffffffffc02011e8:	07078163          	beq	a5,a6,ffffffffc020124a <best_fit_free_pages+0x106>
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc02011ec:	4914                	lw	a3,16(a0)
ffffffffc02011ee:	ff87a703          	lw	a4,-8(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02011f2:	58f5                	li	a7,-3
ffffffffc02011f4:	00d70c63          	beq	a4,a3,ffffffffc020120c <best_fit_free_pages+0xc8>
        else if (base->property < p->property || (base->property == p->property && base + base->property < p))
ffffffffc02011f8:	02e6ec63          	bltu	a3,a4,ffffffffc0201230 <best_fit_free_pages+0xec>
    return listelm->next;
ffffffffc02011fc:	6798                	ld	a4,8(a5)
        else if(list_next(le) == &free_list){
ffffffffc02011fe:	0d070163          	beq	a4,a6,ffffffffc02012c0 <best_fit_free_pages+0x17c>
ffffffffc0201202:	87ba                	mv	a5,a4
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc0201204:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201208:	fed718e3          	bne	a4,a3,ffffffffc02011f8 <best_fit_free_pages+0xb4>
ffffffffc020120c:	02069613          	slli	a2,a3,0x20
ffffffffc0201210:	9201                	srli	a2,a2,0x20
ffffffffc0201212:	00261713          	slli	a4,a2,0x2
ffffffffc0201216:	9732                	add	a4,a4,a2
ffffffffc0201218:	070e                	slli	a4,a4,0x3
        p = le2page(le, page_link);
ffffffffc020121a:	fe878613          	addi	a2,a5,-24
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc020121e:	00e505b3          	add	a1,a0,a4
ffffffffc0201222:	02b60763          	beq	a2,a1,ffffffffc0201250 <best_fit_free_pages+0x10c>
        else if((p->property == base->property) && (p + p->property == base)){
ffffffffc0201226:	9732                	add	a4,a4,a2
ffffffffc0201228:	04e50763          	beq	a0,a4,ffffffffc0201276 <best_fit_free_pages+0x132>
        else if (base->property < p->property || (base->property == p->property && base + base->property < p))
ffffffffc020122c:	fcc5f8e3          	bgeu	a1,a2,ffffffffc02011fc <best_fit_free_pages+0xb8>
ffffffffc0201230:	7118                	ld	a4,32(a0)
            if (targetLe != list_next(&base->page_link))
ffffffffc0201232:	00f70c63          	beq	a4,a5,ffffffffc020124a <best_fit_free_pages+0x106>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201236:	6d10                	ld	a2,24(a0)
                list_add_before(targetLe, &(base->page_link));
ffffffffc0201238:	01850693          	addi	a3,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020123c:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020123e:	e310                	sd	a2,0(a4)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201240:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201242:	e394                	sd	a3,0(a5)
ffffffffc0201244:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0201246:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201248:	ed18                	sd	a4,24(a0)
} 
ffffffffc020124a:	60a2                	ld	ra,8(sp)
ffffffffc020124c:	0141                	addi	sp,sp,16
ffffffffc020124e:	8082                	ret
            base->property += p->property;
ffffffffc0201250:	0016969b          	slliw	a3,a3,0x1
ffffffffc0201254:	c914                	sw	a3,16(a0)
ffffffffc0201256:	ff078713          	addi	a4,a5,-16
ffffffffc020125a:	6117302f          	amoand.d	zero,a7,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc020125e:	6394                	ld	a3,0(a5)
ffffffffc0201260:	6798                	ld	a4,8(a5)
            le = &(base->page_link);
ffffffffc0201262:	01850793          	addi	a5,a0,24
    prev->next = next;
ffffffffc0201266:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201268:	e314                	sd	a3,0(a4)
    return listelm->next;
ffffffffc020126a:	6798                	ld	a4,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020126c:	fd070fe3          	beq	a4,a6,ffffffffc020124a <best_fit_free_pages+0x106>
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc0201270:	4914                	lw	a3,16(a0)
ffffffffc0201272:	87ba                	mv	a5,a4
ffffffffc0201274:	bf41                	j	ffffffffc0201204 <best_fit_free_pages+0xc0>
            p->property += base->property;
ffffffffc0201276:	0016969b          	slliw	a3,a3,0x1
ffffffffc020127a:	fed7ac23          	sw	a3,-8(a5)
ffffffffc020127e:	00850713          	addi	a4,a0,8
ffffffffc0201282:	6117302f          	amoand.d	zero,a7,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201286:	6d14                	ld	a3,24(a0)
ffffffffc0201288:	7118                	ld	a4,32(a0)
            le = &(base->page_link);
ffffffffc020128a:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020128c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020128e:	e314                	sd	a3,0(a4)
ffffffffc0201290:	bfe9                	j	ffffffffc020126a <best_fit_free_pages+0x126>
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc0201292:	02061593          	slli	a1,a2,0x20
ffffffffc0201296:	9181                	srli	a1,a1,0x20
ffffffffc0201298:	00259713          	slli	a4,a1,0x2
ffffffffc020129c:	972e                	add	a4,a4,a1
ffffffffc020129e:	070e                	slli	a4,a4,0x3
ffffffffc02012a0:	9736                	add	a4,a4,a3
ffffffffc02012a2:	f4e513e3          	bne	a0,a4,ffffffffc02011e8 <best_fit_free_pages+0xa4>
        p->property += base->property;
ffffffffc02012a6:	0016161b          	slliw	a2,a2,0x1
ffffffffc02012aa:	ca90                	sw	a2,16(a3)
ffffffffc02012ac:	57f5                	li	a5,-3
ffffffffc02012ae:	60f3302f          	amoand.d	zero,a5,(t1)
    __list_del(listelm->prev, listelm->next);
ffffffffc02012b2:	6d10                	ld	a2,24(a0)
ffffffffc02012b4:	7118                	ld	a4,32(a0)
    return listelm->next;
ffffffffc02012b6:	8536                	mv	a0,a3
    prev->next = next;
ffffffffc02012b8:	e618                	sd	a4,8(a2)
    return listelm->next;
ffffffffc02012ba:	729c                	ld	a5,32(a3)
    next->prev = prev;
ffffffffc02012bc:	e310                	sd	a2,0(a4)
        base = p;
ffffffffc02012be:	b72d                	j	ffffffffc02011e8 <best_fit_free_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc02012c0:	6d0c                	ld	a1,24(a0)
ffffffffc02012c2:	7110                	ld	a2,32(a0)
            list_add(le, &(base->page_link));
ffffffffc02012c4:	01850693          	addi	a3,a0,24
} 
ffffffffc02012c8:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02012ca:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02012cc:	6798                	ld	a4,8(a5)
    next->prev = prev;
ffffffffc02012ce:	e20c                	sd	a1,0(a2)
    prev->next = next->prev = elm;
ffffffffc02012d0:	e314                	sd	a3,0(a4)
ffffffffc02012d2:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc02012d4:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc02012d6:	ed1c                	sd	a5,24(a0)
ffffffffc02012d8:	0141                	addi	sp,sp,16
ffffffffc02012da:	8082                	ret
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc02012dc:	4910                	lw	a2,16(a0)
ffffffffc02012de:	bdd5                	j	ffffffffc02011d2 <best_fit_free_pages+0x8e>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012e0:	00001697          	auipc	a3,0x1
ffffffffc02012e4:	3b068693          	addi	a3,a3,944 # ffffffffc0202690 <commands+0x848>
ffffffffc02012e8:	00001617          	auipc	a2,0x1
ffffffffc02012ec:	06860613          	addi	a2,a2,104 # ffffffffc0202350 <commands+0x508>
ffffffffc02012f0:	0a000593          	li	a1,160
ffffffffc02012f4:	00001517          	auipc	a0,0x1
ffffffffc02012f8:	07450513          	addi	a0,a0,116 # ffffffffc0202368 <commands+0x520>
ffffffffc02012fc:	8b0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201300:	00001697          	auipc	a3,0x1
ffffffffc0201304:	37868693          	addi	a3,a3,888 # ffffffffc0202678 <commands+0x830>
ffffffffc0201308:	00001617          	auipc	a2,0x1
ffffffffc020130c:	04860613          	addi	a2,a2,72 # ffffffffc0202350 <commands+0x508>
ffffffffc0201310:	09c00593          	li	a1,156
ffffffffc0201314:	00001517          	auipc	a0,0x1
ffffffffc0201318:	05450513          	addi	a0,a0,84 # ffffffffc0202368 <commands+0x520>
ffffffffc020131c:	890ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201320 <best_fit_alloc_pages>:
best_fit_alloc_pages(size_t n) {
ffffffffc0201320:	1141                	addi	sp,sp,-16
ffffffffc0201322:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201324:	10050563          	beqz	a0,ffffffffc020142e <best_fit_alloc_pages+0x10e>
    if (n > nr_free) {
ffffffffc0201328:	00005597          	auipc	a1,0x5
ffffffffc020132c:	ce858593          	addi	a1,a1,-792 # ffffffffc0206010 <free_area>
ffffffffc0201330:	4994                	lw	a3,16(a1)
ffffffffc0201332:	02069793          	slli	a5,a3,0x20
ffffffffc0201336:	9381                	srli	a5,a5,0x20
ffffffffc0201338:	02a7e963          	bltu	a5,a0,ffffffffc020136a <best_fit_alloc_pages+0x4a>
    while(count < n){
ffffffffc020133c:	4785                	li	a5,1
    size_t count = 1;
ffffffffc020133e:	4885                	li	a7,1
    while(count < n){
ffffffffc0201340:	00f50563          	beq	a0,a5,ffffffffc020134a <best_fit_alloc_pages+0x2a>
        count <<= 1;
ffffffffc0201344:	0886                	slli	a7,a7,0x1
    while(count < n){
ffffffffc0201346:	fea8efe3          	bltu	a7,a0,ffffffffc0201344 <best_fit_alloc_pages+0x24>
    list_entry_t *le = &free_list;
ffffffffc020134a:	00005817          	auipc	a6,0x5
ffffffffc020134e:	cc680813          	addi	a6,a6,-826 # ffffffffc0206010 <free_area>
ffffffffc0201352:	a801                	j	ffffffffc0201362 <best_fit_alloc_pages+0x42>
        if(p->property >= size){
ffffffffc0201354:	ff882703          	lw	a4,-8(a6)
ffffffffc0201358:	02071793          	slli	a5,a4,0x20
ffffffffc020135c:	9381                	srli	a5,a5,0x20
ffffffffc020135e:	0117fa63          	bgeu	a5,a7,ffffffffc0201372 <best_fit_alloc_pages+0x52>
    return listelm->next;
ffffffffc0201362:	00883803          	ld	a6,8(a6)
    while((le = list_next(le)) != &free_list){
ffffffffc0201366:	feb817e3          	bne	a6,a1,ffffffffc0201354 <best_fit_alloc_pages+0x34>
}
ffffffffc020136a:	60a2                	ld	ra,8(sp)
        return NULL;
ffffffffc020136c:	4501                	li	a0,0
}
ffffffffc020136e:	0141                	addi	sp,sp,16
ffffffffc0201370:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201372:	fe880513          	addi	a0,a6,-24
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201376:	4e09                	li	t3,2
        while(page->property > size){
ffffffffc0201378:	06f8f663          	bgeu	a7,a5,ffffffffc02013e4 <best_fit_alloc_pages+0xc4>
            page->property >>= 1;
ffffffffc020137c:	0017571b          	srliw	a4,a4,0x1
            struct Page *child = page + page->property;
ffffffffc0201380:	02071793          	slli	a5,a4,0x20
ffffffffc0201384:	9381                	srli	a5,a5,0x20
ffffffffc0201386:	00279613          	slli	a2,a5,0x2
ffffffffc020138a:	963e                	add	a2,a2,a5
ffffffffc020138c:	060e                	slli	a2,a2,0x3
ffffffffc020138e:	962a                	add	a2,a2,a0
            page->property >>= 1;
ffffffffc0201390:	fee82c23          	sw	a4,-8(a6)
            child->property = page->property;
ffffffffc0201394:	ca18                	sw	a4,16(a2)
ffffffffc0201396:	00860793          	addi	a5,a2,8
ffffffffc020139a:	41c7b02f          	amoor.d	zero,t3,(a5)
ffffffffc020139e:	659c                	ld	a5,8(a1)
            while((temp_addr = list_next(temp_addr)) != &free_list){
ffffffffc02013a0:	02b78163          	beq	a5,a1,ffffffffc02013c2 <best_fit_alloc_pages+0xa2>
                if(p->property > child->property ||( p->property == child->property && p > child)){
ffffffffc02013a4:	4a14                	lw	a3,16(a2)
ffffffffc02013a6:	a021                	j	ffffffffc02013ae <best_fit_alloc_pages+0x8e>
ffffffffc02013a8:	679c                	ld	a5,8(a5)
            while((temp_addr = list_next(temp_addr)) != &free_list){
ffffffffc02013aa:	00b78c63          	beq	a5,a1,ffffffffc02013c2 <best_fit_alloc_pages+0xa2>
                if(p->property > child->property ||( p->property == child->property && p > child)){
ffffffffc02013ae:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013b2:	00e6e863          	bltu	a3,a4,ffffffffc02013c2 <best_fit_alloc_pages+0xa2>
ffffffffc02013b6:	fed719e3          	bne	a4,a3,ffffffffc02013a8 <best_fit_alloc_pages+0x88>
                struct Page *p = le2page(temp_addr, page_link);
ffffffffc02013ba:	fe878713          	addi	a4,a5,-24
                if(p->property > child->property ||( p->property == child->property && p > child)){
ffffffffc02013be:	fee675e3          	bgeu	a2,a4,ffffffffc02013a8 <best_fit_alloc_pages+0x88>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013c2:	6394                	ld	a3,0(a5)
        while(page->property > size){
ffffffffc02013c4:	ff882703          	lw	a4,-8(a6)
            list_add_before(temp_addr, &(child->page_link));
ffffffffc02013c8:	01860313          	addi	t1,a2,24
    prev->next = next->prev = elm;
ffffffffc02013cc:	0067b023          	sd	t1,0(a5)
ffffffffc02013d0:	0066b423          	sd	t1,8(a3)
    elm->next = next;
ffffffffc02013d4:	f21c                	sd	a5,32(a2)
        while(page->property > size){
ffffffffc02013d6:	02071793          	slli	a5,a4,0x20
    elm->prev = prev;
ffffffffc02013da:	ee14                	sd	a3,24(a2)
ffffffffc02013dc:	9381                	srli	a5,a5,0x20
ffffffffc02013de:	f8f8efe3          	bltu	a7,a5,ffffffffc020137c <best_fit_alloc_pages+0x5c>
        nr_free -= size;
ffffffffc02013e2:	4994                	lw	a3,16(a1)
ffffffffc02013e4:	411686bb          	subw	a3,a3,a7
ffffffffc02013e8:	c994                	sw	a3,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013ea:	57f5                	li	a5,-3
ffffffffc02013ec:	ff080713          	addi	a4,a6,-16
ffffffffc02013f0:	60f7302f          	amoand.d	zero,a5,(a4)
        assert(page->property == size);
ffffffffc02013f4:	ff886783          	lwu	a5,-8(a6)
ffffffffc02013f8:	00f89b63          	bne	a7,a5,ffffffffc020140e <best_fit_alloc_pages+0xee>
    __list_del(listelm->prev, listelm->next);
ffffffffc02013fc:	00083703          	ld	a4,0(a6)
ffffffffc0201400:	00883783          	ld	a5,8(a6)
}
ffffffffc0201404:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201406:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201408:	e398                	sd	a4,0(a5)
ffffffffc020140a:	0141                	addi	sp,sp,16
ffffffffc020140c:	8082                	ret
        assert(page->property == size);
ffffffffc020140e:	00001697          	auipc	a3,0x1
ffffffffc0201412:	2aa68693          	addi	a3,a3,682 # ffffffffc02026b8 <commands+0x870>
ffffffffc0201416:	00001617          	auipc	a2,0x1
ffffffffc020141a:	f3a60613          	addi	a2,a2,-198 # ffffffffc0202350 <commands+0x508>
ffffffffc020141e:	09300593          	li	a1,147
ffffffffc0201422:	00001517          	auipc	a0,0x1
ffffffffc0201426:	f4650513          	addi	a0,a0,-186 # ffffffffc0202368 <commands+0x520>
ffffffffc020142a:	f83fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020142e:	00001697          	auipc	a3,0x1
ffffffffc0201432:	24a68693          	addi	a3,a3,586 # ffffffffc0202678 <commands+0x830>
ffffffffc0201436:	00001617          	auipc	a2,0x1
ffffffffc020143a:	f1a60613          	addi	a2,a2,-230 # ffffffffc0202350 <commands+0x508>
ffffffffc020143e:	07400593          	li	a1,116
ffffffffc0201442:	00001517          	auipc	a0,0x1
ffffffffc0201446:	f2650513          	addi	a0,a0,-218 # ffffffffc0202368 <commands+0x520>
ffffffffc020144a:	f63fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020144e <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020144e:	100027f3          	csrr	a5,sstatus
ffffffffc0201452:	8b89                	andi	a5,a5,2
ffffffffc0201454:	e799                	bnez	a5,ffffffffc0201462 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201456:	00005797          	auipc	a5,0x5
ffffffffc020145a:	ff27b783          	ld	a5,-14(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020145e:	6f9c                	ld	a5,24(a5)
ffffffffc0201460:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201462:	1141                	addi	sp,sp,-16
ffffffffc0201464:	e406                	sd	ra,8(sp)
ffffffffc0201466:	e022                	sd	s0,0(sp)
ffffffffc0201468:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020146a:	ff5fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020146e:	00005797          	auipc	a5,0x5
ffffffffc0201472:	fda7b783          	ld	a5,-38(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201476:	6f9c                	ld	a5,24(a5)
ffffffffc0201478:	8522                	mv	a0,s0
ffffffffc020147a:	9782                	jalr	a5
ffffffffc020147c:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020147e:	fdbfe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201482:	60a2                	ld	ra,8(sp)
ffffffffc0201484:	8522                	mv	a0,s0
ffffffffc0201486:	6402                	ld	s0,0(sp)
ffffffffc0201488:	0141                	addi	sp,sp,16
ffffffffc020148a:	8082                	ret

ffffffffc020148c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020148c:	100027f3          	csrr	a5,sstatus
ffffffffc0201490:	8b89                	andi	a5,a5,2
ffffffffc0201492:	e799                	bnez	a5,ffffffffc02014a0 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201494:	00005797          	auipc	a5,0x5
ffffffffc0201498:	fb47b783          	ld	a5,-76(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020149c:	739c                	ld	a5,32(a5)
ffffffffc020149e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02014a0:	1101                	addi	sp,sp,-32
ffffffffc02014a2:	ec06                	sd	ra,24(sp)
ffffffffc02014a4:	e822                	sd	s0,16(sp)
ffffffffc02014a6:	e426                	sd	s1,8(sp)
ffffffffc02014a8:	842a                	mv	s0,a0
ffffffffc02014aa:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02014ac:	fb3fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02014b0:	00005797          	auipc	a5,0x5
ffffffffc02014b4:	f987b783          	ld	a5,-104(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02014b8:	739c                	ld	a5,32(a5)
ffffffffc02014ba:	85a6                	mv	a1,s1
ffffffffc02014bc:	8522                	mv	a0,s0
ffffffffc02014be:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02014c0:	6442                	ld	s0,16(sp)
ffffffffc02014c2:	60e2                	ld	ra,24(sp)
ffffffffc02014c4:	64a2                	ld	s1,8(sp)
ffffffffc02014c6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02014c8:	f91fe06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02014cc <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014cc:	100027f3          	csrr	a5,sstatus
ffffffffc02014d0:	8b89                	andi	a5,a5,2
ffffffffc02014d2:	e799                	bnez	a5,ffffffffc02014e0 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02014d4:	00005797          	auipc	a5,0x5
ffffffffc02014d8:	f747b783          	ld	a5,-140(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02014dc:	779c                	ld	a5,40(a5)
ffffffffc02014de:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02014e0:	1141                	addi	sp,sp,-16
ffffffffc02014e2:	e406                	sd	ra,8(sp)
ffffffffc02014e4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02014e6:	f79fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02014ea:	00005797          	auipc	a5,0x5
ffffffffc02014ee:	f5e7b783          	ld	a5,-162(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02014f2:	779c                	ld	a5,40(a5)
ffffffffc02014f4:	9782                	jalr	a5
ffffffffc02014f6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02014f8:	f61fe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02014fc:	60a2                	ld	ra,8(sp)
ffffffffc02014fe:	8522                	mv	a0,s0
ffffffffc0201500:	6402                	ld	s0,0(sp)
ffffffffc0201502:	0141                	addi	sp,sp,16
ffffffffc0201504:	8082                	ret

ffffffffc0201506 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201506:	00001797          	auipc	a5,0x1
ffffffffc020150a:	1e278793          	addi	a5,a5,482 # ffffffffc02026e8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020150e:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201510:	1101                	addi	sp,sp,-32
ffffffffc0201512:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201514:	00001517          	auipc	a0,0x1
ffffffffc0201518:	20c50513          	addi	a0,a0,524 # ffffffffc0202720 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020151c:	00005497          	auipc	s1,0x5
ffffffffc0201520:	f2c48493          	addi	s1,s1,-212 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc0201524:	ec06                	sd	ra,24(sp)
ffffffffc0201526:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201528:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020152a:	b89fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020152e:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201530:	00005417          	auipc	s0,0x5
ffffffffc0201534:	f3040413          	addi	s0,s0,-208 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201538:	679c                	ld	a5,8(a5)
ffffffffc020153a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020153c:	57f5                	li	a5,-3
ffffffffc020153e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201540:	00001517          	auipc	a0,0x1
ffffffffc0201544:	1f850513          	addi	a0,a0,504 # ffffffffc0202738 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201548:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc020154a:	b69fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020154e:	46c5                	li	a3,17
ffffffffc0201550:	06ee                	slli	a3,a3,0x1b
ffffffffc0201552:	40100613          	li	a2,1025
ffffffffc0201556:	16fd                	addi	a3,a3,-1
ffffffffc0201558:	07e005b7          	lui	a1,0x7e00
ffffffffc020155c:	0656                	slli	a2,a2,0x15
ffffffffc020155e:	00001517          	auipc	a0,0x1
ffffffffc0201562:	1f250513          	addi	a0,a0,498 # ffffffffc0202750 <best_fit_pmm_manager+0x68>
ffffffffc0201566:	b4dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020156a:	777d                	lui	a4,0xfffff
ffffffffc020156c:	00006797          	auipc	a5,0x6
ffffffffc0201570:	f0378793          	addi	a5,a5,-253 # ffffffffc020746f <end+0xfff>
ffffffffc0201574:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201576:	00005517          	auipc	a0,0x5
ffffffffc020157a:	ec250513          	addi	a0,a0,-318 # ffffffffc0206438 <npage>
ffffffffc020157e:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201582:	00005597          	auipc	a1,0x5
ffffffffc0201586:	ebe58593          	addi	a1,a1,-322 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020158a:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020158c:	e19c                	sd	a5,0(a1)
ffffffffc020158e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201590:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201592:	4885                	li	a7,1
ffffffffc0201594:	fff80837          	lui	a6,0xfff80
ffffffffc0201598:	a011                	j	ffffffffc020159c <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020159a:	619c                	ld	a5,0(a1)
ffffffffc020159c:	97b6                	add	a5,a5,a3
ffffffffc020159e:	07a1                	addi	a5,a5,8
ffffffffc02015a0:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02015a4:	611c                	ld	a5,0(a0)
ffffffffc02015a6:	0705                	addi	a4,a4,1
ffffffffc02015a8:	02868693          	addi	a3,a3,40
ffffffffc02015ac:	01078633          	add	a2,a5,a6
ffffffffc02015b0:	fec765e3          	bltu	a4,a2,ffffffffc020159a <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015b4:	6190                	ld	a2,0(a1)
ffffffffc02015b6:	00279713          	slli	a4,a5,0x2
ffffffffc02015ba:	973e                	add	a4,a4,a5
ffffffffc02015bc:	fec006b7          	lui	a3,0xfec00
ffffffffc02015c0:	070e                	slli	a4,a4,0x3
ffffffffc02015c2:	96b2                	add	a3,a3,a2
ffffffffc02015c4:	96ba                	add	a3,a3,a4
ffffffffc02015c6:	c0200737          	lui	a4,0xc0200
ffffffffc02015ca:	08e6ef63          	bltu	a3,a4,ffffffffc0201668 <pmm_init+0x162>
ffffffffc02015ce:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02015d0:	45c5                	li	a1,17
ffffffffc02015d2:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015d4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02015d6:	04b6e863          	bltu	a3,a1,ffffffffc0201626 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02015da:	609c                	ld	a5,0(s1)
ffffffffc02015dc:	7b9c                	ld	a5,48(a5)
ffffffffc02015de:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02015e0:	00001517          	auipc	a0,0x1
ffffffffc02015e4:	20850513          	addi	a0,a0,520 # ffffffffc02027e8 <best_fit_pmm_manager+0x100>
ffffffffc02015e8:	acbfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02015ec:	00004597          	auipc	a1,0x4
ffffffffc02015f0:	a1458593          	addi	a1,a1,-1516 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02015f4:	00005797          	auipc	a5,0x5
ffffffffc02015f8:	e6b7b223          	sd	a1,-412(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02015fc:	c02007b7          	lui	a5,0xc0200
ffffffffc0201600:	08f5e063          	bltu	a1,a5,ffffffffc0201680 <pmm_init+0x17a>
ffffffffc0201604:	6010                	ld	a2,0(s0)
}
ffffffffc0201606:	6442                	ld	s0,16(sp)
ffffffffc0201608:	60e2                	ld	ra,24(sp)
ffffffffc020160a:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020160c:	40c58633          	sub	a2,a1,a2
ffffffffc0201610:	00005797          	auipc	a5,0x5
ffffffffc0201614:	e4c7b023          	sd	a2,-448(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201618:	00001517          	auipc	a0,0x1
ffffffffc020161c:	1f050513          	addi	a0,a0,496 # ffffffffc0202808 <best_fit_pmm_manager+0x120>
}
ffffffffc0201620:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201622:	a91fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201626:	6705                	lui	a4,0x1
ffffffffc0201628:	177d                	addi	a4,a4,-1
ffffffffc020162a:	96ba                	add	a3,a3,a4
ffffffffc020162c:	777d                	lui	a4,0xfffff
ffffffffc020162e:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201630:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201634:	00f57e63          	bgeu	a0,a5,ffffffffc0201650 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201638:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020163a:	982a                	add	a6,a6,a0
ffffffffc020163c:	00281513          	slli	a0,a6,0x2
ffffffffc0201640:	9542                	add	a0,a0,a6
ffffffffc0201642:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201644:	8d95                	sub	a1,a1,a3
ffffffffc0201646:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201648:	81b1                	srli	a1,a1,0xc
ffffffffc020164a:	9532                	add	a0,a0,a2
ffffffffc020164c:	9782                	jalr	a5
}
ffffffffc020164e:	b771                	j	ffffffffc02015da <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201650:	00001617          	auipc	a2,0x1
ffffffffc0201654:	16860613          	addi	a2,a2,360 # ffffffffc02027b8 <best_fit_pmm_manager+0xd0>
ffffffffc0201658:	06b00593          	li	a1,107
ffffffffc020165c:	00001517          	auipc	a0,0x1
ffffffffc0201660:	17c50513          	addi	a0,a0,380 # ffffffffc02027d8 <best_fit_pmm_manager+0xf0>
ffffffffc0201664:	d49fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201668:	00001617          	auipc	a2,0x1
ffffffffc020166c:	11860613          	addi	a2,a2,280 # ffffffffc0202780 <best_fit_pmm_manager+0x98>
ffffffffc0201670:	06e00593          	li	a1,110
ffffffffc0201674:	00001517          	auipc	a0,0x1
ffffffffc0201678:	13450513          	addi	a0,a0,308 # ffffffffc02027a8 <best_fit_pmm_manager+0xc0>
ffffffffc020167c:	d31fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201680:	86ae                	mv	a3,a1
ffffffffc0201682:	00001617          	auipc	a2,0x1
ffffffffc0201686:	0fe60613          	addi	a2,a2,254 # ffffffffc0202780 <best_fit_pmm_manager+0x98>
ffffffffc020168a:	08900593          	li	a1,137
ffffffffc020168e:	00001517          	auipc	a0,0x1
ffffffffc0201692:	11a50513          	addi	a0,a0,282 # ffffffffc02027a8 <best_fit_pmm_manager+0xc0>
ffffffffc0201696:	d17fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020169a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020169a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020169e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02016a0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016a4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02016a6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016aa:	f022                	sd	s0,32(sp)
ffffffffc02016ac:	ec26                	sd	s1,24(sp)
ffffffffc02016ae:	e84a                	sd	s2,16(sp)
ffffffffc02016b0:	f406                	sd	ra,40(sp)
ffffffffc02016b2:	e44e                	sd	s3,8(sp)
ffffffffc02016b4:	84aa                	mv	s1,a0
ffffffffc02016b6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02016b8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02016bc:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02016be:	03067e63          	bgeu	a2,a6,ffffffffc02016fa <printnum+0x60>
ffffffffc02016c2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02016c4:	00805763          	blez	s0,ffffffffc02016d2 <printnum+0x38>
ffffffffc02016c8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02016ca:	85ca                	mv	a1,s2
ffffffffc02016cc:	854e                	mv	a0,s3
ffffffffc02016ce:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02016d0:	fc65                	bnez	s0,ffffffffc02016c8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016d2:	1a02                	slli	s4,s4,0x20
ffffffffc02016d4:	00001797          	auipc	a5,0x1
ffffffffc02016d8:	17478793          	addi	a5,a5,372 # ffffffffc0202848 <best_fit_pmm_manager+0x160>
ffffffffc02016dc:	020a5a13          	srli	s4,s4,0x20
ffffffffc02016e0:	9a3e                	add	s4,s4,a5
}
ffffffffc02016e2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016e4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02016e8:	70a2                	ld	ra,40(sp)
ffffffffc02016ea:	69a2                	ld	s3,8(sp)
ffffffffc02016ec:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016ee:	85ca                	mv	a1,s2
ffffffffc02016f0:	87a6                	mv	a5,s1
}
ffffffffc02016f2:	6942                	ld	s2,16(sp)
ffffffffc02016f4:	64e2                	ld	s1,24(sp)
ffffffffc02016f6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016f8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02016fa:	03065633          	divu	a2,a2,a6
ffffffffc02016fe:	8722                	mv	a4,s0
ffffffffc0201700:	f9bff0ef          	jal	ra,ffffffffc020169a <printnum>
ffffffffc0201704:	b7f9                	j	ffffffffc02016d2 <printnum+0x38>

ffffffffc0201706 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201706:	7119                	addi	sp,sp,-128
ffffffffc0201708:	f4a6                	sd	s1,104(sp)
ffffffffc020170a:	f0ca                	sd	s2,96(sp)
ffffffffc020170c:	ecce                	sd	s3,88(sp)
ffffffffc020170e:	e8d2                	sd	s4,80(sp)
ffffffffc0201710:	e4d6                	sd	s5,72(sp)
ffffffffc0201712:	e0da                	sd	s6,64(sp)
ffffffffc0201714:	fc5e                	sd	s7,56(sp)
ffffffffc0201716:	f06a                	sd	s10,32(sp)
ffffffffc0201718:	fc86                	sd	ra,120(sp)
ffffffffc020171a:	f8a2                	sd	s0,112(sp)
ffffffffc020171c:	f862                	sd	s8,48(sp)
ffffffffc020171e:	f466                	sd	s9,40(sp)
ffffffffc0201720:	ec6e                	sd	s11,24(sp)
ffffffffc0201722:	892a                	mv	s2,a0
ffffffffc0201724:	84ae                	mv	s1,a1
ffffffffc0201726:	8d32                	mv	s10,a2
ffffffffc0201728:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020172a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020172e:	5b7d                	li	s6,-1
ffffffffc0201730:	00001a97          	auipc	s5,0x1
ffffffffc0201734:	14ca8a93          	addi	s5,s5,332 # ffffffffc020287c <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201738:	00001b97          	auipc	s7,0x1
ffffffffc020173c:	320b8b93          	addi	s7,s7,800 # ffffffffc0202a58 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201740:	000d4503          	lbu	a0,0(s10)
ffffffffc0201744:	001d0413          	addi	s0,s10,1
ffffffffc0201748:	01350a63          	beq	a0,s3,ffffffffc020175c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020174c:	c121                	beqz	a0,ffffffffc020178c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020174e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201750:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201752:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201754:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201758:	ff351ae3          	bne	a0,s3,ffffffffc020174c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020175c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201760:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201764:	4c81                	li	s9,0
ffffffffc0201766:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201768:	5c7d                	li	s8,-1
ffffffffc020176a:	5dfd                	li	s11,-1
ffffffffc020176c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201770:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201772:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201776:	0ff5f593          	zext.b	a1,a1
ffffffffc020177a:	00140d13          	addi	s10,s0,1
ffffffffc020177e:	04b56263          	bltu	a0,a1,ffffffffc02017c2 <vprintfmt+0xbc>
ffffffffc0201782:	058a                	slli	a1,a1,0x2
ffffffffc0201784:	95d6                	add	a1,a1,s5
ffffffffc0201786:	4194                	lw	a3,0(a1)
ffffffffc0201788:	96d6                	add	a3,a3,s5
ffffffffc020178a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020178c:	70e6                	ld	ra,120(sp)
ffffffffc020178e:	7446                	ld	s0,112(sp)
ffffffffc0201790:	74a6                	ld	s1,104(sp)
ffffffffc0201792:	7906                	ld	s2,96(sp)
ffffffffc0201794:	69e6                	ld	s3,88(sp)
ffffffffc0201796:	6a46                	ld	s4,80(sp)
ffffffffc0201798:	6aa6                	ld	s5,72(sp)
ffffffffc020179a:	6b06                	ld	s6,64(sp)
ffffffffc020179c:	7be2                	ld	s7,56(sp)
ffffffffc020179e:	7c42                	ld	s8,48(sp)
ffffffffc02017a0:	7ca2                	ld	s9,40(sp)
ffffffffc02017a2:	7d02                	ld	s10,32(sp)
ffffffffc02017a4:	6de2                	ld	s11,24(sp)
ffffffffc02017a6:	6109                	addi	sp,sp,128
ffffffffc02017a8:	8082                	ret
            padc = '0';
ffffffffc02017aa:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02017ac:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017b0:	846a                	mv	s0,s10
ffffffffc02017b2:	00140d13          	addi	s10,s0,1
ffffffffc02017b6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02017ba:	0ff5f593          	zext.b	a1,a1
ffffffffc02017be:	fcb572e3          	bgeu	a0,a1,ffffffffc0201782 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02017c2:	85a6                	mv	a1,s1
ffffffffc02017c4:	02500513          	li	a0,37
ffffffffc02017c8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02017ca:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017ce:	8d22                	mv	s10,s0
ffffffffc02017d0:	f73788e3          	beq	a5,s3,ffffffffc0201740 <vprintfmt+0x3a>
ffffffffc02017d4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02017d8:	1d7d                	addi	s10,s10,-1
ffffffffc02017da:	ff379de3          	bne	a5,s3,ffffffffc02017d4 <vprintfmt+0xce>
ffffffffc02017de:	b78d                	j	ffffffffc0201740 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02017e0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02017e4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017e8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02017ea:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02017ee:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017f2:	02d86463          	bltu	a6,a3,ffffffffc020181a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02017f6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02017fa:	002c169b          	slliw	a3,s8,0x2
ffffffffc02017fe:	0186873b          	addw	a4,a3,s8
ffffffffc0201802:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201806:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201808:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020180c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020180e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201812:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201816:	fed870e3          	bgeu	a6,a3,ffffffffc02017f6 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020181a:	f40ddce3          	bgez	s11,ffffffffc0201772 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020181e:	8de2                	mv	s11,s8
ffffffffc0201820:	5c7d                	li	s8,-1
ffffffffc0201822:	bf81                	j	ffffffffc0201772 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201824:	fffdc693          	not	a3,s11
ffffffffc0201828:	96fd                	srai	a3,a3,0x3f
ffffffffc020182a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020182e:	00144603          	lbu	a2,1(s0)
ffffffffc0201832:	2d81                	sext.w	s11,s11
ffffffffc0201834:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201836:	bf35                	j	ffffffffc0201772 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201838:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020183c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201840:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201842:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201844:	bfd9                	j	ffffffffc020181a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201846:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201848:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020184c:	01174463          	blt	a4,a7,ffffffffc0201854 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201850:	1a088e63          	beqz	a7,ffffffffc0201a0c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201854:	000a3603          	ld	a2,0(s4)
ffffffffc0201858:	46c1                	li	a3,16
ffffffffc020185a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020185c:	2781                	sext.w	a5,a5
ffffffffc020185e:	876e                	mv	a4,s11
ffffffffc0201860:	85a6                	mv	a1,s1
ffffffffc0201862:	854a                	mv	a0,s2
ffffffffc0201864:	e37ff0ef          	jal	ra,ffffffffc020169a <printnum>
            break;
ffffffffc0201868:	bde1                	j	ffffffffc0201740 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020186a:	000a2503          	lw	a0,0(s4)
ffffffffc020186e:	85a6                	mv	a1,s1
ffffffffc0201870:	0a21                	addi	s4,s4,8
ffffffffc0201872:	9902                	jalr	s2
            break;
ffffffffc0201874:	b5f1                	j	ffffffffc0201740 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201876:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201878:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020187c:	01174463          	blt	a4,a7,ffffffffc0201884 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201880:	18088163          	beqz	a7,ffffffffc0201a02 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201884:	000a3603          	ld	a2,0(s4)
ffffffffc0201888:	46a9                	li	a3,10
ffffffffc020188a:	8a2e                	mv	s4,a1
ffffffffc020188c:	bfc1                	j	ffffffffc020185c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020188e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201892:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201894:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201896:	bdf1                	j	ffffffffc0201772 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201898:	85a6                	mv	a1,s1
ffffffffc020189a:	02500513          	li	a0,37
ffffffffc020189e:	9902                	jalr	s2
            break;
ffffffffc02018a0:	b545                	j	ffffffffc0201740 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018a2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02018a6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018a8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018aa:	b5e1                	j	ffffffffc0201772 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02018ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02018ae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02018b2:	01174463          	blt	a4,a7,ffffffffc02018ba <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02018b6:	14088163          	beqz	a7,ffffffffc02019f8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02018ba:	000a3603          	ld	a2,0(s4)
ffffffffc02018be:	46a1                	li	a3,8
ffffffffc02018c0:	8a2e                	mv	s4,a1
ffffffffc02018c2:	bf69                	j	ffffffffc020185c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02018c4:	03000513          	li	a0,48
ffffffffc02018c8:	85a6                	mv	a1,s1
ffffffffc02018ca:	e03e                	sd	a5,0(sp)
ffffffffc02018cc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02018ce:	85a6                	mv	a1,s1
ffffffffc02018d0:	07800513          	li	a0,120
ffffffffc02018d4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02018d6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02018d8:	6782                	ld	a5,0(sp)
ffffffffc02018da:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02018dc:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02018e0:	bfb5                	j	ffffffffc020185c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02018e2:	000a3403          	ld	s0,0(s4)
ffffffffc02018e6:	008a0713          	addi	a4,s4,8
ffffffffc02018ea:	e03a                	sd	a4,0(sp)
ffffffffc02018ec:	14040263          	beqz	s0,ffffffffc0201a30 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02018f0:	0fb05763          	blez	s11,ffffffffc02019de <vprintfmt+0x2d8>
ffffffffc02018f4:	02d00693          	li	a3,45
ffffffffc02018f8:	0cd79163          	bne	a5,a3,ffffffffc02019ba <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018fc:	00044783          	lbu	a5,0(s0)
ffffffffc0201900:	0007851b          	sext.w	a0,a5
ffffffffc0201904:	cf85                	beqz	a5,ffffffffc020193c <vprintfmt+0x236>
ffffffffc0201906:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020190a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020190e:	000c4563          	bltz	s8,ffffffffc0201918 <vprintfmt+0x212>
ffffffffc0201912:	3c7d                	addiw	s8,s8,-1
ffffffffc0201914:	036c0263          	beq	s8,s6,ffffffffc0201938 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201918:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020191a:	0e0c8e63          	beqz	s9,ffffffffc0201a16 <vprintfmt+0x310>
ffffffffc020191e:	3781                	addiw	a5,a5,-32
ffffffffc0201920:	0ef47b63          	bgeu	s0,a5,ffffffffc0201a16 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201924:	03f00513          	li	a0,63
ffffffffc0201928:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020192a:	000a4783          	lbu	a5,0(s4)
ffffffffc020192e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201930:	0a05                	addi	s4,s4,1
ffffffffc0201932:	0007851b          	sext.w	a0,a5
ffffffffc0201936:	ffe1                	bnez	a5,ffffffffc020190e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201938:	01b05963          	blez	s11,ffffffffc020194a <vprintfmt+0x244>
ffffffffc020193c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020193e:	85a6                	mv	a1,s1
ffffffffc0201940:	02000513          	li	a0,32
ffffffffc0201944:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201946:	fe0d9be3          	bnez	s11,ffffffffc020193c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020194a:	6a02                	ld	s4,0(sp)
ffffffffc020194c:	bbd5                	j	ffffffffc0201740 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020194e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201950:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201954:	01174463          	blt	a4,a7,ffffffffc020195c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201958:	08088d63          	beqz	a7,ffffffffc02019f2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020195c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201960:	0a044d63          	bltz	s0,ffffffffc0201a1a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201964:	8622                	mv	a2,s0
ffffffffc0201966:	8a66                	mv	s4,s9
ffffffffc0201968:	46a9                	li	a3,10
ffffffffc020196a:	bdcd                	j	ffffffffc020185c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020196c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201970:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201972:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201974:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201978:	8fb5                	xor	a5,a5,a3
ffffffffc020197a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020197e:	02d74163          	blt	a4,a3,ffffffffc02019a0 <vprintfmt+0x29a>
ffffffffc0201982:	00369793          	slli	a5,a3,0x3
ffffffffc0201986:	97de                	add	a5,a5,s7
ffffffffc0201988:	639c                	ld	a5,0(a5)
ffffffffc020198a:	cb99                	beqz	a5,ffffffffc02019a0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020198c:	86be                	mv	a3,a5
ffffffffc020198e:	00001617          	auipc	a2,0x1
ffffffffc0201992:	eea60613          	addi	a2,a2,-278 # ffffffffc0202878 <best_fit_pmm_manager+0x190>
ffffffffc0201996:	85a6                	mv	a1,s1
ffffffffc0201998:	854a                	mv	a0,s2
ffffffffc020199a:	0ce000ef          	jal	ra,ffffffffc0201a68 <printfmt>
ffffffffc020199e:	b34d                	j	ffffffffc0201740 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02019a0:	00001617          	auipc	a2,0x1
ffffffffc02019a4:	ec860613          	addi	a2,a2,-312 # ffffffffc0202868 <best_fit_pmm_manager+0x180>
ffffffffc02019a8:	85a6                	mv	a1,s1
ffffffffc02019aa:	854a                	mv	a0,s2
ffffffffc02019ac:	0bc000ef          	jal	ra,ffffffffc0201a68 <printfmt>
ffffffffc02019b0:	bb41                	j	ffffffffc0201740 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02019b2:	00001417          	auipc	s0,0x1
ffffffffc02019b6:	eae40413          	addi	s0,s0,-338 # ffffffffc0202860 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019ba:	85e2                	mv	a1,s8
ffffffffc02019bc:	8522                	mv	a0,s0
ffffffffc02019be:	e43e                	sd	a5,8(sp)
ffffffffc02019c0:	1cc000ef          	jal	ra,ffffffffc0201b8c <strnlen>
ffffffffc02019c4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02019c8:	01b05b63          	blez	s11,ffffffffc02019de <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02019cc:	67a2                	ld	a5,8(sp)
ffffffffc02019ce:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019d2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02019d4:	85a6                	mv	a1,s1
ffffffffc02019d6:	8552                	mv	a0,s4
ffffffffc02019d8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019da:	fe0d9ce3          	bnez	s11,ffffffffc02019d2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019de:	00044783          	lbu	a5,0(s0)
ffffffffc02019e2:	00140a13          	addi	s4,s0,1
ffffffffc02019e6:	0007851b          	sext.w	a0,a5
ffffffffc02019ea:	d3a5                	beqz	a5,ffffffffc020194a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019ec:	05e00413          	li	s0,94
ffffffffc02019f0:	bf39                	j	ffffffffc020190e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02019f2:	000a2403          	lw	s0,0(s4)
ffffffffc02019f6:	b7ad                	j	ffffffffc0201960 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02019f8:	000a6603          	lwu	a2,0(s4)
ffffffffc02019fc:	46a1                	li	a3,8
ffffffffc02019fe:	8a2e                	mv	s4,a1
ffffffffc0201a00:	bdb1                	j	ffffffffc020185c <vprintfmt+0x156>
ffffffffc0201a02:	000a6603          	lwu	a2,0(s4)
ffffffffc0201a06:	46a9                	li	a3,10
ffffffffc0201a08:	8a2e                	mv	s4,a1
ffffffffc0201a0a:	bd89                	j	ffffffffc020185c <vprintfmt+0x156>
ffffffffc0201a0c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201a10:	46c1                	li	a3,16
ffffffffc0201a12:	8a2e                	mv	s4,a1
ffffffffc0201a14:	b5a1                	j	ffffffffc020185c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201a16:	9902                	jalr	s2
ffffffffc0201a18:	bf09                	j	ffffffffc020192a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201a1a:	85a6                	mv	a1,s1
ffffffffc0201a1c:	02d00513          	li	a0,45
ffffffffc0201a20:	e03e                	sd	a5,0(sp)
ffffffffc0201a22:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201a24:	6782                	ld	a5,0(sp)
ffffffffc0201a26:	8a66                	mv	s4,s9
ffffffffc0201a28:	40800633          	neg	a2,s0
ffffffffc0201a2c:	46a9                	li	a3,10
ffffffffc0201a2e:	b53d                	j	ffffffffc020185c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201a30:	03b05163          	blez	s11,ffffffffc0201a52 <vprintfmt+0x34c>
ffffffffc0201a34:	02d00693          	li	a3,45
ffffffffc0201a38:	f6d79de3          	bne	a5,a3,ffffffffc02019b2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201a3c:	00001417          	auipc	s0,0x1
ffffffffc0201a40:	e2440413          	addi	s0,s0,-476 # ffffffffc0202860 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a44:	02800793          	li	a5,40
ffffffffc0201a48:	02800513          	li	a0,40
ffffffffc0201a4c:	00140a13          	addi	s4,s0,1
ffffffffc0201a50:	bd6d                	j	ffffffffc020190a <vprintfmt+0x204>
ffffffffc0201a52:	00001a17          	auipc	s4,0x1
ffffffffc0201a56:	e0fa0a13          	addi	s4,s4,-497 # ffffffffc0202861 <best_fit_pmm_manager+0x179>
ffffffffc0201a5a:	02800513          	li	a0,40
ffffffffc0201a5e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a62:	05e00413          	li	s0,94
ffffffffc0201a66:	b565                	j	ffffffffc020190e <vprintfmt+0x208>

ffffffffc0201a68 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a68:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a6a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a6e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a70:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a72:	ec06                	sd	ra,24(sp)
ffffffffc0201a74:	f83a                	sd	a4,48(sp)
ffffffffc0201a76:	fc3e                	sd	a5,56(sp)
ffffffffc0201a78:	e0c2                	sd	a6,64(sp)
ffffffffc0201a7a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a7c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a7e:	c89ff0ef          	jal	ra,ffffffffc0201706 <vprintfmt>
}
ffffffffc0201a82:	60e2                	ld	ra,24(sp)
ffffffffc0201a84:	6161                	addi	sp,sp,80
ffffffffc0201a86:	8082                	ret

ffffffffc0201a88 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a88:	715d                	addi	sp,sp,-80
ffffffffc0201a8a:	e486                	sd	ra,72(sp)
ffffffffc0201a8c:	e0a6                	sd	s1,64(sp)
ffffffffc0201a8e:	fc4a                	sd	s2,56(sp)
ffffffffc0201a90:	f84e                	sd	s3,48(sp)
ffffffffc0201a92:	f452                	sd	s4,40(sp)
ffffffffc0201a94:	f056                	sd	s5,32(sp)
ffffffffc0201a96:	ec5a                	sd	s6,24(sp)
ffffffffc0201a98:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201a9a:	c901                	beqz	a0,ffffffffc0201aaa <readline+0x22>
ffffffffc0201a9c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201a9e:	00001517          	auipc	a0,0x1
ffffffffc0201aa2:	dda50513          	addi	a0,a0,-550 # ffffffffc0202878 <best_fit_pmm_manager+0x190>
ffffffffc0201aa6:	e0cfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201aaa:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201aac:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201aae:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201ab0:	4aa9                	li	s5,10
ffffffffc0201ab2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201ab4:	00004b97          	auipc	s7,0x4
ffffffffc0201ab8:	574b8b93          	addi	s7,s7,1396 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201abc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201ac0:	e6afe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201ac4:	00054a63          	bltz	a0,ffffffffc0201ad8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ac8:	00a95a63          	bge	s2,a0,ffffffffc0201adc <readline+0x54>
ffffffffc0201acc:	029a5263          	bge	s4,s1,ffffffffc0201af0 <readline+0x68>
        c = getchar();
ffffffffc0201ad0:	e5afe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201ad4:	fe055ae3          	bgez	a0,ffffffffc0201ac8 <readline+0x40>
            return NULL;
ffffffffc0201ad8:	4501                	li	a0,0
ffffffffc0201ada:	a091                	j	ffffffffc0201b1e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201adc:	03351463          	bne	a0,s3,ffffffffc0201b04 <readline+0x7c>
ffffffffc0201ae0:	e8a9                	bnez	s1,ffffffffc0201b32 <readline+0xaa>
        c = getchar();
ffffffffc0201ae2:	e48fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201ae6:	fe0549e3          	bltz	a0,ffffffffc0201ad8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201aea:	fea959e3          	bge	s2,a0,ffffffffc0201adc <readline+0x54>
ffffffffc0201aee:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201af0:	e42a                	sd	a0,8(sp)
ffffffffc0201af2:	df6fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201af6:	6522                	ld	a0,8(sp)
ffffffffc0201af8:	009b87b3          	add	a5,s7,s1
ffffffffc0201afc:	2485                	addiw	s1,s1,1
ffffffffc0201afe:	00a78023          	sb	a0,0(a5)
ffffffffc0201b02:	bf7d                	j	ffffffffc0201ac0 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201b04:	01550463          	beq	a0,s5,ffffffffc0201b0c <readline+0x84>
ffffffffc0201b08:	fb651ce3          	bne	a0,s6,ffffffffc0201ac0 <readline+0x38>
            cputchar(c);
ffffffffc0201b0c:	ddcfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201b10:	00004517          	auipc	a0,0x4
ffffffffc0201b14:	51850513          	addi	a0,a0,1304 # ffffffffc0206028 <buf>
ffffffffc0201b18:	94aa                	add	s1,s1,a0
ffffffffc0201b1a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201b1e:	60a6                	ld	ra,72(sp)
ffffffffc0201b20:	6486                	ld	s1,64(sp)
ffffffffc0201b22:	7962                	ld	s2,56(sp)
ffffffffc0201b24:	79c2                	ld	s3,48(sp)
ffffffffc0201b26:	7a22                	ld	s4,40(sp)
ffffffffc0201b28:	7a82                	ld	s5,32(sp)
ffffffffc0201b2a:	6b62                	ld	s6,24(sp)
ffffffffc0201b2c:	6bc2                	ld	s7,16(sp)
ffffffffc0201b2e:	6161                	addi	sp,sp,80
ffffffffc0201b30:	8082                	ret
            cputchar(c);
ffffffffc0201b32:	4521                	li	a0,8
ffffffffc0201b34:	db4fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201b38:	34fd                	addiw	s1,s1,-1
ffffffffc0201b3a:	b759                	j	ffffffffc0201ac0 <readline+0x38>

ffffffffc0201b3c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201b3c:	4781                	li	a5,0
ffffffffc0201b3e:	00004717          	auipc	a4,0x4
ffffffffc0201b42:	4ca73703          	ld	a4,1226(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201b46:	88ba                	mv	a7,a4
ffffffffc0201b48:	852a                	mv	a0,a0
ffffffffc0201b4a:	85be                	mv	a1,a5
ffffffffc0201b4c:	863e                	mv	a2,a5
ffffffffc0201b4e:	00000073          	ecall
ffffffffc0201b52:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201b54:	8082                	ret

ffffffffc0201b56 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201b56:	4781                	li	a5,0
ffffffffc0201b58:	00005717          	auipc	a4,0x5
ffffffffc0201b5c:	91073703          	ld	a4,-1776(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201b60:	88ba                	mv	a7,a4
ffffffffc0201b62:	852a                	mv	a0,a0
ffffffffc0201b64:	85be                	mv	a1,a5
ffffffffc0201b66:	863e                	mv	a2,a5
ffffffffc0201b68:	00000073          	ecall
ffffffffc0201b6c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201b6e:	8082                	ret

ffffffffc0201b70 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201b70:	4501                	li	a0,0
ffffffffc0201b72:	00004797          	auipc	a5,0x4
ffffffffc0201b76:	48e7b783          	ld	a5,1166(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201b7a:	88be                	mv	a7,a5
ffffffffc0201b7c:	852a                	mv	a0,a0
ffffffffc0201b7e:	85aa                	mv	a1,a0
ffffffffc0201b80:	862a                	mv	a2,a0
ffffffffc0201b82:	00000073          	ecall
ffffffffc0201b86:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b88:	2501                	sext.w	a0,a0
ffffffffc0201b8a:	8082                	ret

ffffffffc0201b8c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201b8c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b8e:	e589                	bnez	a1,ffffffffc0201b98 <strnlen+0xc>
ffffffffc0201b90:	a811                	j	ffffffffc0201ba4 <strnlen+0x18>
        cnt ++;
ffffffffc0201b92:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b94:	00f58863          	beq	a1,a5,ffffffffc0201ba4 <strnlen+0x18>
ffffffffc0201b98:	00f50733          	add	a4,a0,a5
ffffffffc0201b9c:	00074703          	lbu	a4,0(a4)
ffffffffc0201ba0:	fb6d                	bnez	a4,ffffffffc0201b92 <strnlen+0x6>
ffffffffc0201ba2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201ba4:	852e                	mv	a0,a1
ffffffffc0201ba6:	8082                	ret

ffffffffc0201ba8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ba8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201bac:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bb0:	cb89                	beqz	a5,ffffffffc0201bc2 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201bb2:	0505                	addi	a0,a0,1
ffffffffc0201bb4:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bb6:	fee789e3          	beq	a5,a4,ffffffffc0201ba8 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201bba:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201bbe:	9d19                	subw	a0,a0,a4
ffffffffc0201bc0:	8082                	ret
ffffffffc0201bc2:	4501                	li	a0,0
ffffffffc0201bc4:	bfed                	j	ffffffffc0201bbe <strcmp+0x16>

ffffffffc0201bc6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201bc6:	00054783          	lbu	a5,0(a0)
ffffffffc0201bca:	c799                	beqz	a5,ffffffffc0201bd8 <strchr+0x12>
        if (*s == c) {
ffffffffc0201bcc:	00f58763          	beq	a1,a5,ffffffffc0201bda <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201bd0:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201bd4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201bd6:	fbfd                	bnez	a5,ffffffffc0201bcc <strchr+0x6>
    }
    return NULL;
ffffffffc0201bd8:	4501                	li	a0,0
}
ffffffffc0201bda:	8082                	ret

ffffffffc0201bdc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201bdc:	ca01                	beqz	a2,ffffffffc0201bec <memset+0x10>
ffffffffc0201bde:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201be0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201be2:	0785                	addi	a5,a5,1
ffffffffc0201be4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201be8:	fec79de3          	bne	a5,a2,ffffffffc0201be2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201bec:	8082                	ret
