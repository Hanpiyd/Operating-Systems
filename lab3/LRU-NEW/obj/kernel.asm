
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53a60613          	addi	a2,a2,1338 # ffffffffc0211574 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	39e040ef          	jal	ra,ffffffffc02043e8 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	3ca58593          	addi	a1,a1,970 # ffffffffc0204418 <etext+0x6>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	3e250513          	addi	a0,a0,994 # ffffffffc0204438 <etext+0x26>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	271010ef          	jal	ra,ffffffffc0201ad6 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	628030ef          	jal	ra,ffffffffc0203696 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	0c5020ef          	jal	ra,ffffffffc020293a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	39a000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	689030ef          	jal	ra,ffffffffc0203f36 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	653030ef          	jal	ra,ffffffffc0203f36 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	ae0d                	j	ffffffffc0200422 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	360000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200102:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	33c50513          	addi	a0,a0,828 # ffffffffc0204440 <etext+0x2e>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	34650513          	addi	a0,a0,838 # ffffffffc0204460 <etext+0x4e>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	2ec58593          	addi	a1,a1,748 # ffffffffc0204412 <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	35250513          	addi	a0,a0,850 # ffffffffc0204480 <etext+0x6e>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	35e50513          	addi	a0,a0,862 # ffffffffc02044a0 <etext+0x8e>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	42658593          	addi	a1,a1,1062 # ffffffffc0211574 <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	36a50513          	addi	a0,a0,874 # ffffffffc02044c0 <etext+0xae>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	81158593          	addi	a1,a1,-2031 # ffffffffc0211973 <end+0x3ff>
ffffffffc020016a:	00000797          	auipc	a5,0x0
ffffffffc020016e:	ec878793          	addi	a5,a5,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200176:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200180:	95be                	add	a1,a1,a5
ffffffffc0200182:	85a9                	srai	a1,a1,0xa
ffffffffc0200184:	00004517          	auipc	a0,0x4
ffffffffc0200188:	35c50513          	addi	a0,a0,860 # ffffffffc02044e0 <etext+0xce>
}
ffffffffc020018c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018e:	b735                	j	ffffffffc02000ba <cprintf>

ffffffffc0200190 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200190:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200192:	00004617          	auipc	a2,0x4
ffffffffc0200196:	37e60613          	addi	a2,a2,894 # ffffffffc0204510 <etext+0xfe>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	38a50513          	addi	a0,a0,906 # ffffffffc0204528 <etext+0x116>
void print_stackframe(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a8:	1cc000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001ac <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ac:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ae:	00004617          	auipc	a2,0x4
ffffffffc02001b2:	39260613          	addi	a2,a2,914 # ffffffffc0204540 <etext+0x12e>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	3aa58593          	addi	a1,a1,938 # ffffffffc0204560 <etext+0x14e>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	3aa50513          	addi	a0,a0,938 # ffffffffc0204568 <etext+0x156>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	3ac60613          	addi	a2,a2,940 # ffffffffc0204578 <etext+0x166>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	3cc58593          	addi	a1,a1,972 # ffffffffc02045a0 <etext+0x18e>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	38c50513          	addi	a0,a0,908 # ffffffffc0204568 <etext+0x156>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	3c860613          	addi	a2,a2,968 # ffffffffc02045b0 <etext+0x19e>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	3e058593          	addi	a1,a1,992 # ffffffffc02045d0 <etext+0x1be>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	37050513          	addi	a0,a0,880 # ffffffffc0204568 <etext+0x156>
ffffffffc0200200:	ebbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200204:	60a2                	ld	ra,8(sp)
ffffffffc0200206:	4501                	li	a0,0
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200210:	ef3ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200220:	f71ff0ef          	jal	ra,ffffffffc0200190 <print_stackframe>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022c:	7115                	addi	sp,sp,-224
ffffffffc020022e:	ed5e                	sd	s7,152(sp)
ffffffffc0200230:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200232:	00004517          	auipc	a0,0x4
ffffffffc0200236:	3ae50513          	addi	a0,a0,942 # ffffffffc02045e0 <etext+0x1ce>
kmonitor(struct trapframe *tf) {
ffffffffc020023a:	ed86                	sd	ra,216(sp)
ffffffffc020023c:	e9a2                	sd	s0,208(sp)
ffffffffc020023e:	e5a6                	sd	s1,200(sp)
ffffffffc0200240:	e1ca                	sd	s2,192(sp)
ffffffffc0200242:	fd4e                	sd	s3,184(sp)
ffffffffc0200244:	f952                	sd	s4,176(sp)
ffffffffc0200246:	f556                	sd	s5,168(sp)
ffffffffc0200248:	f15a                	sd	s6,160(sp)
ffffffffc020024a:	e962                	sd	s8,144(sp)
ffffffffc020024c:	e566                	sd	s9,136(sp)
ffffffffc020024e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200250:	e6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	3b450513          	addi	a0,a0,948 # ffffffffc0204608 <etext+0x1f6>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	406c0c13          	addi	s8,s8,1030 # ffffffffc0204670 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	80e90913          	addi	s2,s2,-2034 # ffffffffc0205a80 <default_pmm_manager+0x928>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	3b648493          	addi	s1,s1,950 # ffffffffc0204630 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	3b4b0b13          	addi	s6,s6,948 # ffffffffc0204638 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	2d4a0a13          	addi	s4,s4,724 # ffffffffc0204560 <etext+0x14e>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	020040ef          	jal	ra,ffffffffc02042b8 <readline>
ffffffffc020029c:	842a                	mv	s0,a0
ffffffffc020029e:	dd65                	beqz	a0,ffffffffc0200296 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a6:	e1bd                	bnez	a1,ffffffffc020030c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002a8:	fe0c87e3          	beqz	s9,ffffffffc0200296 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ac:	6582                	ld	a1,0(sp)
ffffffffc02002ae:	00004d17          	auipc	s10,0x4
ffffffffc02002b2:	3c2d0d13          	addi	s10,s10,962 # ffffffffc0204670 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	0f8040ef          	jal	ra,ffffffffc02043b4 <strcmp>
ffffffffc02002c0:	c919                	beqz	a0,ffffffffc02002d6 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	0b540063          	beq	s0,s5,ffffffffc0200364 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c8:	000d3503          	ld	a0,0(s10)
ffffffffc02002cc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	0e4040ef          	jal	ra,ffffffffc02043b4 <strcmp>
ffffffffc02002d4:	f57d                	bnez	a0,ffffffffc02002c2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002d6:	00141793          	slli	a5,s0,0x1
ffffffffc02002da:	97a2                	add	a5,a5,s0
ffffffffc02002dc:	078e                	slli	a5,a5,0x3
ffffffffc02002de:	97e2                	add	a5,a5,s8
ffffffffc02002e0:	6b9c                	ld	a5,16(a5)
ffffffffc02002e2:	865e                	mv	a2,s7
ffffffffc02002e4:	002c                	addi	a1,sp,8
ffffffffc02002e6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ea:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002ec:	fa0555e3          	bgez	a0,ffffffffc0200296 <kmonitor+0x6a>
}
ffffffffc02002f0:	60ee                	ld	ra,216(sp)
ffffffffc02002f2:	644e                	ld	s0,208(sp)
ffffffffc02002f4:	64ae                	ld	s1,200(sp)
ffffffffc02002f6:	690e                	ld	s2,192(sp)
ffffffffc02002f8:	79ea                	ld	s3,184(sp)
ffffffffc02002fa:	7a4a                	ld	s4,176(sp)
ffffffffc02002fc:	7aaa                	ld	s5,168(sp)
ffffffffc02002fe:	7b0a                	ld	s6,160(sp)
ffffffffc0200300:	6bea                	ld	s7,152(sp)
ffffffffc0200302:	6c4a                	ld	s8,144(sp)
ffffffffc0200304:	6caa                	ld	s9,136(sp)
ffffffffc0200306:	6d0a                	ld	s10,128(sp)
ffffffffc0200308:	612d                	addi	sp,sp,224
ffffffffc020030a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	8526                	mv	a0,s1
ffffffffc020030e:	0c4040ef          	jal	ra,ffffffffc02043d2 <strchr>
ffffffffc0200312:	c901                	beqz	a0,ffffffffc0200322 <kmonitor+0xf6>
ffffffffc0200314:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200318:	00040023          	sb	zero,0(s0)
ffffffffc020031c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	d5c9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200320:	b7f5                	j	ffffffffc020030c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200322:	00044783          	lbu	a5,0(s0)
ffffffffc0200326:	d3c9                	beqz	a5,ffffffffc02002a8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200328:	033c8963          	beq	s9,s3,ffffffffc020035a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020032c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200330:	0118                	addi	a4,sp,128
ffffffffc0200332:	97ba                	add	a5,a5,a4
ffffffffc0200334:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200338:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033e:	e591                	bnez	a1,ffffffffc020034a <kmonitor+0x11e>
ffffffffc0200340:	b7b5                	j	ffffffffc02002ac <kmonitor+0x80>
ffffffffc0200342:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200346:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200348:	d1a5                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc020034a:	8526                	mv	a0,s1
ffffffffc020034c:	086040ef          	jal	ra,ffffffffc02043d2 <strchr>
ffffffffc0200350:	d96d                	beqz	a0,ffffffffc0200342 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	00044583          	lbu	a1,0(s0)
ffffffffc0200356:	d9a9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200358:	bf55                	j	ffffffffc020030c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200362:	b7e9                	j	ffffffffc020032c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	2f250513          	addi	a0,a0,754 # ffffffffc0204658 <etext+0x246>
ffffffffc020036e:	d4dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc0200372:	b715                	j	ffffffffc0200296 <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	18430313          	addi	t1,t1,388 # ffffffffc02114f8 <is_panic>
ffffffffc020037c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	020e1a63          	bnez	t3,ffffffffc02003c4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039a:	8432                	mv	s0,a2
ffffffffc020039c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039e:	862e                	mv	a2,a1
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	31650513          	addi	a0,a0,790 # ffffffffc02046b8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	ce7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	21850513          	addi	a0,a0,536 # ffffffffc02055d0 <default_pmm_manager+0x478>
ffffffffc02003c0:	cfbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12a000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e63ff0ef          	jal	ra,ffffffffc020022c <kmonitor>
    while (1) {
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x54>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	12f73923          	sd	a5,306(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	2e250513          	addi	a0,a0,738 # ffffffffc02046d8 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	1007b123          	sd	zero,258(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b955                	j	ffffffffc02000ba <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	0fc7b783          	ld	a5,252(a5) # ffffffffc0211508 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	zext.b	a0,a0
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	0ae000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a851                	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	07c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	062000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a0:	0000a797          	auipc	a5,0xa
ffffffffc02004a4:	ba078793          	addi	a5,a5,-1120 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004a8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	95be                	add	a1,a1,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b8:	743030ef          	jal	ra,ffffffffc02043fa <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0000a517          	auipc	a0,0xa
ffffffffc02004cc:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d0:	1141                	addi	sp,sp,-16
ffffffffc02004d2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	953e                	add	a0,a0,a5
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004da:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004dc:	71f030ef          	jal	ra,ffffffffc02043fa <memcpy>
    return 0;
}
ffffffffc02004e0:	60a2                	ld	ra,8(sp)
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	0141                	addi	sp,sp,16
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	1d450513          	addi	a0,a0,468 # ffffffffc02046f8 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03853503          	ld	a0,56(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	7260306f          	j	ffffffffc0203c6e <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	1cc60613          	addi	a2,a2,460 # ffffffffc0204718 <commands+0xa8>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	1d850513          	addi	a0,a0,472 # ffffffffc0204730 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	4a878793          	addi	a5,a5,1192 # ffffffffc0200a10 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	1be50513          	addi	a0,a0,446 # ffffffffc0204748 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	1c650513          	addi	a0,a0,454 # ffffffffc0204760 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	1d050513          	addi	a0,a0,464 # ffffffffc0204778 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	1da50513          	addi	a0,a0,474 # ffffffffc0204790 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	1e450513          	addi	a0,a0,484 # ffffffffc02047a8 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	1ee50513          	addi	a0,a0,494 # ffffffffc02047c0 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	1f850513          	addi	a0,a0,504 # ffffffffc02047d8 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	20250513          	addi	a0,a0,514 # ffffffffc02047f0 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	20c50513          	addi	a0,a0,524 # ffffffffc0204808 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	21650513          	addi	a0,a0,534 # ffffffffc0204820 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	22050513          	addi	a0,a0,544 # ffffffffc0204838 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	22a50513          	addi	a0,a0,554 # ffffffffc0204850 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	23450513          	addi	a0,a0,564 # ffffffffc0204868 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	23e50513          	addi	a0,a0,574 # ffffffffc0204880 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	24850513          	addi	a0,a0,584 # ffffffffc0204898 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	25250513          	addi	a0,a0,594 # ffffffffc02048b0 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	25c50513          	addi	a0,a0,604 # ffffffffc02048c8 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	26650513          	addi	a0,a0,614 # ffffffffc02048e0 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	27050513          	addi	a0,a0,624 # ffffffffc02048f8 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	27a50513          	addi	a0,a0,634 # ffffffffc0204910 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	28450513          	addi	a0,a0,644 # ffffffffc0204928 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	28e50513          	addi	a0,a0,654 # ffffffffc0204940 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	29850513          	addi	a0,a0,664 # ffffffffc0204958 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	2a250513          	addi	a0,a0,674 # ffffffffc0204970 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	2ac50513          	addi	a0,a0,684 # ffffffffc0204988 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	2b650513          	addi	a0,a0,694 # ffffffffc02049a0 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	2c050513          	addi	a0,a0,704 # ffffffffc02049b8 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	2ca50513          	addi	a0,a0,714 # ffffffffc02049d0 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	2d450513          	addi	a0,a0,724 # ffffffffc02049e8 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	2de50513          	addi	a0,a0,734 # ffffffffc0204a00 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	2e850513          	addi	a0,a0,744 # ffffffffc0204a18 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	2ee50513          	addi	a0,a0,750 # ffffffffc0204a30 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	2f250513          	addi	a0,a0,754 # ffffffffc0204a48 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	2f250513          	addi	a0,a0,754 # ffffffffc0204a60 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	2fa50513          	addi	a0,a0,762 # ffffffffc0204a78 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	30250513          	addi	a0,a0,770 # ffffffffc0204a90 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	30650513          	addi	a0,a0,774 # ffffffffc0204aa8 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;
int num = 0;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	0af76563          	bltu	a4,a5,ffffffffc0200864 <interrupt_handler+0xb4>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	3b270713          	addi	a4,a4,946 # ffffffffc0204b70 <commands+0x500>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	35050513          	addi	a0,a0,848 # ffffffffc0204b20 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	32450513          	addi	a0,a0,804 # ffffffffc0204b00 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	2d850513          	addi	a0,a0,728 # ffffffffc0204ac0 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	2ec50513          	addi	a0,a0,748 # ffffffffc0204ae0 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e022                	sd	s0,0(sp)
ffffffffc0200804:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
            if (++ticks % TICK_NUM == 0 && num == 0) {
ffffffffc0200806:	00011417          	auipc	s0,0x11
ffffffffc020080a:	cfa40413          	addi	s0,s0,-774 # ffffffffc0211500 <ticks>
            clock_set_next_event();
ffffffffc020080e:	bfbff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && num == 0) {
ffffffffc0200812:	601c                	ld	a5,0(s0)
ffffffffc0200814:	06400713          	li	a4,100
ffffffffc0200818:	0785                	addi	a5,a5,1
ffffffffc020081a:	02e7f733          	remu	a4,a5,a4
ffffffffc020081e:	e01c                	sd	a5,0(s0)
ffffffffc0200820:	ef11                	bnez	a4,ffffffffc020083c <interrupt_handler+0x8c>
ffffffffc0200822:	00011797          	auipc	a5,0x11
ffffffffc0200826:	cee7a783          	lw	a5,-786(a5) # ffffffffc0211510 <num>
ffffffffc020082a:	eb89                	bnez	a5,ffffffffc020083c <interrupt_handler+0x8c>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020082c:	06400593          	li	a1,100
ffffffffc0200830:	00004517          	auipc	a0,0x4
ffffffffc0200834:	31050513          	addi	a0,a0,784 # ffffffffc0204b40 <commands+0x4d0>
ffffffffc0200838:	883ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
                print_ticks();
            }
            if(ticks == 1000)
ffffffffc020083c:	6018                	ld	a4,0(s0)
ffffffffc020083e:	3e800793          	li	a5,1000
ffffffffc0200842:	00f71763          	bne	a4,a5,ffffffffc0200850 <interrupt_handler+0xa0>
            {
                num = 1;
ffffffffc0200846:	4785                	li	a5,1
ffffffffc0200848:	00011717          	auipc	a4,0x11
ffffffffc020084c:	ccf72423          	sw	a5,-824(a4) # ffffffffc0211510 <num>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200850:	60a2                	ld	ra,8(sp)
ffffffffc0200852:	6402                	ld	s0,0(sp)
ffffffffc0200854:	0141                	addi	sp,sp,16
ffffffffc0200856:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200858:	00004517          	auipc	a0,0x4
ffffffffc020085c:	2f850513          	addi	a0,a0,760 # ffffffffc0204b50 <commands+0x4e0>
ffffffffc0200860:	85bff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200864:	b5ed                	j	ffffffffc020074e <print_trapframe>

ffffffffc0200866 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200866:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020086a:	1101                	addi	sp,sp,-32
ffffffffc020086c:	e822                	sd	s0,16(sp)
ffffffffc020086e:	ec06                	sd	ra,24(sp)
ffffffffc0200870:	e426                	sd	s1,8(sp)
ffffffffc0200872:	473d                	li	a4,15
ffffffffc0200874:	842a                	mv	s0,a0
ffffffffc0200876:	14f76a63          	bltu	a4,a5,ffffffffc02009ca <exception_handler+0x164>
ffffffffc020087a:	00004717          	auipc	a4,0x4
ffffffffc020087e:	4de70713          	addi	a4,a4,1246 # ffffffffc0204d58 <commands+0x6e8>
ffffffffc0200882:	078a                	slli	a5,a5,0x2
ffffffffc0200884:	97ba                	add	a5,a5,a4
ffffffffc0200886:	439c                	lw	a5,0(a5)
ffffffffc0200888:	97ba                	add	a5,a5,a4
ffffffffc020088a:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020088c:	00004517          	auipc	a0,0x4
ffffffffc0200890:	4b450513          	addi	a0,a0,1204 # ffffffffc0204d40 <commands+0x6d0>
ffffffffc0200894:	827ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200898:	8522                	mv	a0,s0
ffffffffc020089a:	c5bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020089e:	84aa                	mv	s1,a0
ffffffffc02008a0:	12051b63          	bnez	a0,ffffffffc02009d6 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a4:	60e2                	ld	ra,24(sp)
ffffffffc02008a6:	6442                	ld	s0,16(sp)
ffffffffc02008a8:	64a2                	ld	s1,8(sp)
ffffffffc02008aa:	6105                	addi	sp,sp,32
ffffffffc02008ac:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	2f250513          	addi	a0,a0,754 # ffffffffc0204ba0 <commands+0x530>
}
ffffffffc02008b6:	6442                	ld	s0,16(sp)
ffffffffc02008b8:	60e2                	ld	ra,24(sp)
ffffffffc02008ba:	64a2                	ld	s1,8(sp)
ffffffffc02008bc:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008be:	ffcff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	2fe50513          	addi	a0,a0,766 # ffffffffc0204bc0 <commands+0x550>
ffffffffc02008ca:	b7f5                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	31450513          	addi	a0,a0,788 # ffffffffc0204be0 <commands+0x570>
ffffffffc02008d4:	b7cd                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008d6:	00004517          	auipc	a0,0x4
ffffffffc02008da:	32250513          	addi	a0,a0,802 # ffffffffc0204bf8 <commands+0x588>
ffffffffc02008de:	bfe1                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008e0:	00004517          	auipc	a0,0x4
ffffffffc02008e4:	32850513          	addi	a0,a0,808 # ffffffffc0204c08 <commands+0x598>
ffffffffc02008e8:	b7f9                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008ea:	00004517          	auipc	a0,0x4
ffffffffc02008ee:	33e50513          	addi	a0,a0,830 # ffffffffc0204c28 <commands+0x5b8>
ffffffffc02008f2:	fc8ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f6:	8522                	mv	a0,s0
ffffffffc02008f8:	bfdff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008fc:	84aa                	mv	s1,a0
ffffffffc02008fe:	d15d                	beqz	a0,ffffffffc02008a4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200900:	8522                	mv	a0,s0
ffffffffc0200902:	e4dff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200906:	86a6                	mv	a3,s1
ffffffffc0200908:	00004617          	auipc	a2,0x4
ffffffffc020090c:	33860613          	addi	a2,a2,824 # ffffffffc0204c40 <commands+0x5d0>
ffffffffc0200910:	0cf00593          	li	a1,207
ffffffffc0200914:	00004517          	auipc	a0,0x4
ffffffffc0200918:	e1c50513          	addi	a0,a0,-484 # ffffffffc0204730 <commands+0xc0>
ffffffffc020091c:	a59ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200920:	00004517          	auipc	a0,0x4
ffffffffc0200924:	34050513          	addi	a0,a0,832 # ffffffffc0204c60 <commands+0x5f0>
ffffffffc0200928:	b779                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020092a:	00004517          	auipc	a0,0x4
ffffffffc020092e:	34e50513          	addi	a0,a0,846 # ffffffffc0204c78 <commands+0x608>
ffffffffc0200932:	f88ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200936:	8522                	mv	a0,s0
ffffffffc0200938:	bbdff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020093c:	84aa                	mv	s1,a0
ffffffffc020093e:	d13d                	beqz	a0,ffffffffc02008a4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200940:	8522                	mv	a0,s0
ffffffffc0200942:	e0dff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200946:	86a6                	mv	a3,s1
ffffffffc0200948:	00004617          	auipc	a2,0x4
ffffffffc020094c:	2f860613          	addi	a2,a2,760 # ffffffffc0204c40 <commands+0x5d0>
ffffffffc0200950:	0d900593          	li	a1,217
ffffffffc0200954:	00004517          	auipc	a0,0x4
ffffffffc0200958:	ddc50513          	addi	a0,a0,-548 # ffffffffc0204730 <commands+0xc0>
ffffffffc020095c:	a19ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	33050513          	addi	a0,a0,816 # ffffffffc0204c90 <commands+0x620>
ffffffffc0200968:	b7b9                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	34650513          	addi	a0,a0,838 # ffffffffc0204cb0 <commands+0x640>
ffffffffc0200972:	b791                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	35c50513          	addi	a0,a0,860 # ffffffffc0204cd0 <commands+0x660>
ffffffffc020097c:	bf2d                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020097e:	00004517          	auipc	a0,0x4
ffffffffc0200982:	37250513          	addi	a0,a0,882 # ffffffffc0204cf0 <commands+0x680>
ffffffffc0200986:	bf05                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200988:	00004517          	auipc	a0,0x4
ffffffffc020098c:	38850513          	addi	a0,a0,904 # ffffffffc0204d10 <commands+0x6a0>
ffffffffc0200990:	b71d                	j	ffffffffc02008b6 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200992:	00004517          	auipc	a0,0x4
ffffffffc0200996:	39650513          	addi	a0,a0,918 # ffffffffc0204d28 <commands+0x6b8>
ffffffffc020099a:	f20ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099e:	8522                	mv	a0,s0
ffffffffc02009a0:	b55ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02009a4:	84aa                	mv	s1,a0
ffffffffc02009a6:	ee050fe3          	beqz	a0,ffffffffc02008a4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009aa:	8522                	mv	a0,s0
ffffffffc02009ac:	da3ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009b0:	86a6                	mv	a3,s1
ffffffffc02009b2:	00004617          	auipc	a2,0x4
ffffffffc02009b6:	28e60613          	addi	a2,a2,654 # ffffffffc0204c40 <commands+0x5d0>
ffffffffc02009ba:	0ef00593          	li	a1,239
ffffffffc02009be:	00004517          	auipc	a0,0x4
ffffffffc02009c2:	d7250513          	addi	a0,a0,-654 # ffffffffc0204730 <commands+0xc0>
ffffffffc02009c6:	9afff0ef          	jal	ra,ffffffffc0200374 <__panic>
            print_trapframe(tf);
ffffffffc02009ca:	8522                	mv	a0,s0
}
ffffffffc02009cc:	6442                	ld	s0,16(sp)
ffffffffc02009ce:	60e2                	ld	ra,24(sp)
ffffffffc02009d0:	64a2                	ld	s1,8(sp)
ffffffffc02009d2:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009d4:	bbad                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009d6:	8522                	mv	a0,s0
ffffffffc02009d8:	d77ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009dc:	86a6                	mv	a3,s1
ffffffffc02009de:	00004617          	auipc	a2,0x4
ffffffffc02009e2:	26260613          	addi	a2,a2,610 # ffffffffc0204c40 <commands+0x5d0>
ffffffffc02009e6:	0f600593          	li	a1,246
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	d4650513          	addi	a0,a0,-698 # ffffffffc0204730 <commands+0xc0>
ffffffffc02009f2:	983ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02009f6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009f6:	11853783          	ld	a5,280(a0)
ffffffffc02009fa:	0007c363          	bltz	a5,ffffffffc0200a00 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009fe:	b5a5                	j	ffffffffc0200866 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a00:	bb45                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f85ff0ef          	jal	ra,ffffffffc02009f6 <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ad0:	00010797          	auipc	a5,0x10
ffffffffc0200ad4:	57078793          	addi	a5,a5,1392 # ffffffffc0211040 <free_area>
ffffffffc0200ad8:	e79c                	sd	a5,8(a5)
ffffffffc0200ada:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200adc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ae0:	8082                	ret

ffffffffc0200ae2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ae2:	00010517          	auipc	a0,0x10
ffffffffc0200ae6:	56e56503          	lwu	a0,1390(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200aea:	8082                	ret

ffffffffc0200aec <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200aec:	715d                	addi	sp,sp,-80
ffffffffc0200aee:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200af0:	00010417          	auipc	s0,0x10
ffffffffc0200af4:	55040413          	addi	s0,s0,1360 # ffffffffc0211040 <free_area>
ffffffffc0200af8:	641c                	ld	a5,8(s0)
ffffffffc0200afa:	e486                	sd	ra,72(sp)
ffffffffc0200afc:	fc26                	sd	s1,56(sp)
ffffffffc0200afe:	f84a                	sd	s2,48(sp)
ffffffffc0200b00:	f44e                	sd	s3,40(sp)
ffffffffc0200b02:	f052                	sd	s4,32(sp)
ffffffffc0200b04:	ec56                	sd	s5,24(sp)
ffffffffc0200b06:	e85a                	sd	s6,16(sp)
ffffffffc0200b08:	e45e                	sd	s7,8(sp)
ffffffffc0200b0a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b0c:	2c878763          	beq	a5,s0,ffffffffc0200dda <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200b10:	4481                	li	s1,0
ffffffffc0200b12:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b14:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b18:	8b09                	andi	a4,a4,2
ffffffffc0200b1a:	2c070463          	beqz	a4,ffffffffc0200de2 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200b1e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b22:	679c                	ld	a5,8(a5)
ffffffffc0200b24:	2905                	addiw	s2,s2,1
ffffffffc0200b26:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b28:	fe8796e3          	bne	a5,s0,ffffffffc0200b14 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b2c:	89a6                	mv	s3,s1
ffffffffc0200b2e:	385000ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
ffffffffc0200b32:	71351863          	bne	a0,s3,ffffffffc0201242 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b36:	4505                	li	a0,1
ffffffffc0200b38:	2a9000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200b3c:	8a2a                	mv	s4,a0
ffffffffc0200b3e:	44050263          	beqz	a0,ffffffffc0200f82 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b42:	4505                	li	a0,1
ffffffffc0200b44:	29d000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200b48:	89aa                	mv	s3,a0
ffffffffc0200b4a:	70050c63          	beqz	a0,ffffffffc0201262 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b4e:	4505                	li	a0,1
ffffffffc0200b50:	291000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200b54:	8aaa                	mv	s5,a0
ffffffffc0200b56:	4a050663          	beqz	a0,ffffffffc0201002 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b5a:	2b3a0463          	beq	s4,s3,ffffffffc0200e02 <default_check+0x316>
ffffffffc0200b5e:	2aaa0263          	beq	s4,a0,ffffffffc0200e02 <default_check+0x316>
ffffffffc0200b62:	2aa98063          	beq	s3,a0,ffffffffc0200e02 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b66:	000a2783          	lw	a5,0(s4)
ffffffffc0200b6a:	2a079c63          	bnez	a5,ffffffffc0200e22 <default_check+0x336>
ffffffffc0200b6e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b72:	2a079863          	bnez	a5,ffffffffc0200e22 <default_check+0x336>
ffffffffc0200b76:	411c                	lw	a5,0(a0)
ffffffffc0200b78:	2a079563          	bnez	a5,ffffffffc0200e22 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b7c:	00011797          	auipc	a5,0x11
ffffffffc0200b80:	9b47b783          	ld	a5,-1612(a5) # ffffffffc0211530 <pages>
ffffffffc0200b84:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b88:	870d                	srai	a4,a4,0x3
ffffffffc0200b8a:	00005597          	auipc	a1,0x5
ffffffffc0200b8e:	6965b583          	ld	a1,1686(a1) # ffffffffc0206220 <error_string+0x38>
ffffffffc0200b92:	02b70733          	mul	a4,a4,a1
ffffffffc0200b96:	00005617          	auipc	a2,0x5
ffffffffc0200b9a:	69263603          	ld	a2,1682(a2) # ffffffffc0206228 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b9e:	00011697          	auipc	a3,0x11
ffffffffc0200ba2:	98a6b683          	ld	a3,-1654(a3) # ffffffffc0211528 <npage>
ffffffffc0200ba6:	06b2                	slli	a3,a3,0xc
ffffffffc0200ba8:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200baa:	0732                	slli	a4,a4,0xc
ffffffffc0200bac:	28d77b63          	bgeu	a4,a3,ffffffffc0200e42 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bb0:	40f98733          	sub	a4,s3,a5
ffffffffc0200bb4:	870d                	srai	a4,a4,0x3
ffffffffc0200bb6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bba:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bbc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bbe:	4cd77263          	bgeu	a4,a3,ffffffffc0201082 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bc2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bc6:	878d                	srai	a5,a5,0x3
ffffffffc0200bc8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bcc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bce:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bd0:	30d7f963          	bgeu	a5,a3,ffffffffc0200ee2 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200bd4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bd6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bda:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bde:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200be2:	e400                	sd	s0,8(s0)
ffffffffc0200be4:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200be6:	00010797          	auipc	a5,0x10
ffffffffc0200bea:	4607a523          	sw	zero,1130(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bee:	1f3000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200bf2:	2c051863          	bnez	a0,ffffffffc0200ec2 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200bf6:	4585                	li	a1,1
ffffffffc0200bf8:	8552                	mv	a0,s4
ffffffffc0200bfa:	279000ef          	jal	ra,ffffffffc0201672 <free_pages>
    free_page(p1);
ffffffffc0200bfe:	4585                	li	a1,1
ffffffffc0200c00:	854e                	mv	a0,s3
ffffffffc0200c02:	271000ef          	jal	ra,ffffffffc0201672 <free_pages>
    free_page(p2);
ffffffffc0200c06:	4585                	li	a1,1
ffffffffc0200c08:	8556                	mv	a0,s5
ffffffffc0200c0a:	269000ef          	jal	ra,ffffffffc0201672 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c0e:	4818                	lw	a4,16(s0)
ffffffffc0200c10:	478d                	li	a5,3
ffffffffc0200c12:	28f71863          	bne	a4,a5,ffffffffc0200ea2 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c16:	4505                	li	a0,1
ffffffffc0200c18:	1c9000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200c1c:	89aa                	mv	s3,a0
ffffffffc0200c1e:	26050263          	beqz	a0,ffffffffc0200e82 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c22:	4505                	li	a0,1
ffffffffc0200c24:	1bd000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200c28:	8aaa                	mv	s5,a0
ffffffffc0200c2a:	3a050c63          	beqz	a0,ffffffffc0200fe2 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c2e:	4505                	li	a0,1
ffffffffc0200c30:	1b1000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200c34:	8a2a                	mv	s4,a0
ffffffffc0200c36:	38050663          	beqz	a0,ffffffffc0200fc2 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c3a:	4505                	li	a0,1
ffffffffc0200c3c:	1a5000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200c40:	36051163          	bnez	a0,ffffffffc0200fa2 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c44:	4585                	li	a1,1
ffffffffc0200c46:	854e                	mv	a0,s3
ffffffffc0200c48:	22b000ef          	jal	ra,ffffffffc0201672 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c4c:	641c                	ld	a5,8(s0)
ffffffffc0200c4e:	20878a63          	beq	a5,s0,ffffffffc0200e62 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c52:	4505                	li	a0,1
ffffffffc0200c54:	18d000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200c58:	30a99563          	bne	s3,a0,ffffffffc0200f62 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c5c:	4505                	li	a0,1
ffffffffc0200c5e:	183000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200c62:	2e051063          	bnez	a0,ffffffffc0200f42 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c66:	481c                	lw	a5,16(s0)
ffffffffc0200c68:	2a079d63          	bnez	a5,ffffffffc0200f22 <default_check+0x436>
    free_page(p);
ffffffffc0200c6c:	854e                	mv	a0,s3
ffffffffc0200c6e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c70:	01843023          	sd	s8,0(s0)
ffffffffc0200c74:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c78:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c7c:	1f7000ef          	jal	ra,ffffffffc0201672 <free_pages>
    free_page(p1);
ffffffffc0200c80:	4585                	li	a1,1
ffffffffc0200c82:	8556                	mv	a0,s5
ffffffffc0200c84:	1ef000ef          	jal	ra,ffffffffc0201672 <free_pages>
    free_page(p2);
ffffffffc0200c88:	4585                	li	a1,1
ffffffffc0200c8a:	8552                	mv	a0,s4
ffffffffc0200c8c:	1e7000ef          	jal	ra,ffffffffc0201672 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c90:	4515                	li	a0,5
ffffffffc0200c92:	14f000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200c96:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c98:	26050563          	beqz	a0,ffffffffc0200f02 <default_check+0x416>
ffffffffc0200c9c:	651c                	ld	a5,8(a0)
ffffffffc0200c9e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ca0:	8b85                	andi	a5,a5,1
ffffffffc0200ca2:	54079063          	bnez	a5,ffffffffc02011e2 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ca6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ca8:	00043b03          	ld	s6,0(s0)
ffffffffc0200cac:	00843a83          	ld	s5,8(s0)
ffffffffc0200cb0:	e000                	sd	s0,0(s0)
ffffffffc0200cb2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cb4:	12d000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200cb8:	50051563          	bnez	a0,ffffffffc02011c2 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cbc:	09098a13          	addi	s4,s3,144
ffffffffc0200cc0:	8552                	mv	a0,s4
ffffffffc0200cc2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200cc4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200cc8:	00010797          	auipc	a5,0x10
ffffffffc0200ccc:	3807a423          	sw	zero,904(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cd0:	1a3000ef          	jal	ra,ffffffffc0201672 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cd4:	4511                	li	a0,4
ffffffffc0200cd6:	10b000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200cda:	4c051463          	bnez	a0,ffffffffc02011a2 <default_check+0x6b6>
ffffffffc0200cde:	0989b783          	ld	a5,152(s3)
ffffffffc0200ce2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200ce4:	8b85                	andi	a5,a5,1
ffffffffc0200ce6:	48078e63          	beqz	a5,ffffffffc0201182 <default_check+0x696>
ffffffffc0200cea:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cee:	478d                	li	a5,3
ffffffffc0200cf0:	48f71963          	bne	a4,a5,ffffffffc0201182 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cf4:	450d                	li	a0,3
ffffffffc0200cf6:	0eb000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200cfa:	8c2a                	mv	s8,a0
ffffffffc0200cfc:	46050363          	beqz	a0,ffffffffc0201162 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200d00:	4505                	li	a0,1
ffffffffc0200d02:	0df000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200d06:	42051e63          	bnez	a0,ffffffffc0201142 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200d0a:	418a1c63          	bne	s4,s8,ffffffffc0201122 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d0e:	4585                	li	a1,1
ffffffffc0200d10:	854e                	mv	a0,s3
ffffffffc0200d12:	161000ef          	jal	ra,ffffffffc0201672 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d16:	458d                	li	a1,3
ffffffffc0200d18:	8552                	mv	a0,s4
ffffffffc0200d1a:	159000ef          	jal	ra,ffffffffc0201672 <free_pages>
ffffffffc0200d1e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d22:	04898c13          	addi	s8,s3,72
ffffffffc0200d26:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d28:	8b85                	andi	a5,a5,1
ffffffffc0200d2a:	3c078c63          	beqz	a5,ffffffffc0201102 <default_check+0x616>
ffffffffc0200d2e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d32:	4785                	li	a5,1
ffffffffc0200d34:	3cf71763          	bne	a4,a5,ffffffffc0201102 <default_check+0x616>
ffffffffc0200d38:	008a3783          	ld	a5,8(s4)
ffffffffc0200d3c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d3e:	8b85                	andi	a5,a5,1
ffffffffc0200d40:	3a078163          	beqz	a5,ffffffffc02010e2 <default_check+0x5f6>
ffffffffc0200d44:	018a2703          	lw	a4,24(s4)
ffffffffc0200d48:	478d                	li	a5,3
ffffffffc0200d4a:	38f71c63          	bne	a4,a5,ffffffffc02010e2 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d4e:	4505                	li	a0,1
ffffffffc0200d50:	091000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200d54:	36a99763          	bne	s3,a0,ffffffffc02010c2 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d58:	4585                	li	a1,1
ffffffffc0200d5a:	119000ef          	jal	ra,ffffffffc0201672 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d5e:	4509                	li	a0,2
ffffffffc0200d60:	081000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200d64:	32aa1f63          	bne	s4,a0,ffffffffc02010a2 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d68:	4589                	li	a1,2
ffffffffc0200d6a:	109000ef          	jal	ra,ffffffffc0201672 <free_pages>
    free_page(p2);
ffffffffc0200d6e:	4585                	li	a1,1
ffffffffc0200d70:	8562                	mv	a0,s8
ffffffffc0200d72:	101000ef          	jal	ra,ffffffffc0201672 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d76:	4515                	li	a0,5
ffffffffc0200d78:	069000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200d7c:	89aa                	mv	s3,a0
ffffffffc0200d7e:	48050263          	beqz	a0,ffffffffc0201202 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d82:	4505                	li	a0,1
ffffffffc0200d84:	05d000ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0200d88:	2c051d63          	bnez	a0,ffffffffc0201062 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d8c:	481c                	lw	a5,16(s0)
ffffffffc0200d8e:	2a079a63          	bnez	a5,ffffffffc0201042 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d92:	4595                	li	a1,5
ffffffffc0200d94:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d96:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d9a:	01643023          	sd	s6,0(s0)
ffffffffc0200d9e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200da2:	0d1000ef          	jal	ra,ffffffffc0201672 <free_pages>
    return listelm->next;
ffffffffc0200da6:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200da8:	00878963          	beq	a5,s0,ffffffffc0200dba <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dac:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200db0:	679c                	ld	a5,8(a5)
ffffffffc0200db2:	397d                	addiw	s2,s2,-1
ffffffffc0200db4:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200db6:	fe879be3          	bne	a5,s0,ffffffffc0200dac <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200dba:	26091463          	bnez	s2,ffffffffc0201022 <default_check+0x536>
    assert(total == 0);
ffffffffc0200dbe:	46049263          	bnez	s1,ffffffffc0201222 <default_check+0x736>
}
ffffffffc0200dc2:	60a6                	ld	ra,72(sp)
ffffffffc0200dc4:	6406                	ld	s0,64(sp)
ffffffffc0200dc6:	74e2                	ld	s1,56(sp)
ffffffffc0200dc8:	7942                	ld	s2,48(sp)
ffffffffc0200dca:	79a2                	ld	s3,40(sp)
ffffffffc0200dcc:	7a02                	ld	s4,32(sp)
ffffffffc0200dce:	6ae2                	ld	s5,24(sp)
ffffffffc0200dd0:	6b42                	ld	s6,16(sp)
ffffffffc0200dd2:	6ba2                	ld	s7,8(sp)
ffffffffc0200dd4:	6c02                	ld	s8,0(sp)
ffffffffc0200dd6:	6161                	addi	sp,sp,80
ffffffffc0200dd8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dda:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ddc:	4481                	li	s1,0
ffffffffc0200dde:	4901                	li	s2,0
ffffffffc0200de0:	b3b9                	j	ffffffffc0200b2e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200de2:	00004697          	auipc	a3,0x4
ffffffffc0200de6:	fb668693          	addi	a3,a3,-74 # ffffffffc0204d98 <commands+0x728>
ffffffffc0200dea:	00004617          	auipc	a2,0x4
ffffffffc0200dee:	fbe60613          	addi	a2,a2,-66 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200df2:	0f000593          	li	a1,240
ffffffffc0200df6:	00004517          	auipc	a0,0x4
ffffffffc0200dfa:	fca50513          	addi	a0,a0,-54 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200dfe:	d76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e02:	00004697          	auipc	a3,0x4
ffffffffc0200e06:	05668693          	addi	a3,a3,86 # ffffffffc0204e58 <commands+0x7e8>
ffffffffc0200e0a:	00004617          	auipc	a2,0x4
ffffffffc0200e0e:	f9e60613          	addi	a2,a2,-98 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200e12:	0bd00593          	li	a1,189
ffffffffc0200e16:	00004517          	auipc	a0,0x4
ffffffffc0200e1a:	faa50513          	addi	a0,a0,-86 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200e1e:	d56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e22:	00004697          	auipc	a3,0x4
ffffffffc0200e26:	05e68693          	addi	a3,a3,94 # ffffffffc0204e80 <commands+0x810>
ffffffffc0200e2a:	00004617          	auipc	a2,0x4
ffffffffc0200e2e:	f7e60613          	addi	a2,a2,-130 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200e32:	0be00593          	li	a1,190
ffffffffc0200e36:	00004517          	auipc	a0,0x4
ffffffffc0200e3a:	f8a50513          	addi	a0,a0,-118 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200e3e:	d36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e42:	00004697          	auipc	a3,0x4
ffffffffc0200e46:	07e68693          	addi	a3,a3,126 # ffffffffc0204ec0 <commands+0x850>
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	f5e60613          	addi	a2,a2,-162 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200e52:	0c000593          	li	a1,192
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	f6a50513          	addi	a0,a0,-150 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200e5e:	d16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e62:	00004697          	auipc	a3,0x4
ffffffffc0200e66:	0e668693          	addi	a3,a3,230 # ffffffffc0204f48 <commands+0x8d8>
ffffffffc0200e6a:	00004617          	auipc	a2,0x4
ffffffffc0200e6e:	f3e60613          	addi	a2,a2,-194 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200e72:	0d900593          	li	a1,217
ffffffffc0200e76:	00004517          	auipc	a0,0x4
ffffffffc0200e7a:	f4a50513          	addi	a0,a0,-182 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200e7e:	cf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	f7668693          	addi	a3,a3,-138 # ffffffffc0204df8 <commands+0x788>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200e92:	0d200593          	li	a1,210
ffffffffc0200e96:	00004517          	auipc	a0,0x4
ffffffffc0200e9a:	f2a50513          	addi	a0,a0,-214 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200e9e:	cd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200ea2:	00004697          	auipc	a3,0x4
ffffffffc0200ea6:	09668693          	addi	a3,a3,150 # ffffffffc0204f38 <commands+0x8c8>
ffffffffc0200eaa:	00004617          	auipc	a2,0x4
ffffffffc0200eae:	efe60613          	addi	a2,a2,-258 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200eb2:	0d000593          	li	a1,208
ffffffffc0200eb6:	00004517          	auipc	a0,0x4
ffffffffc0200eba:	f0a50513          	addi	a0,a0,-246 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200ebe:	cb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	05e68693          	addi	a3,a3,94 # ffffffffc0204f20 <commands+0x8b0>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	ede60613          	addi	a2,a2,-290 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200ed2:	0cb00593          	li	a1,203
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	eea50513          	addi	a0,a0,-278 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200ede:	c96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	01e68693          	addi	a3,a3,30 # ffffffffc0204f00 <commands+0x890>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	ebe60613          	addi	a2,a2,-322 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200ef2:	0c200593          	li	a1,194
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	eca50513          	addi	a0,a0,-310 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200efe:	c76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	08e68693          	addi	a3,a3,142 # ffffffffc0204f90 <commands+0x920>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200f12:	0f800593          	li	a1,248
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	eaa50513          	addi	a0,a0,-342 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200f1e:	c56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f22:	00004697          	auipc	a3,0x4
ffffffffc0200f26:	05e68693          	addi	a3,a3,94 # ffffffffc0204f80 <commands+0x910>
ffffffffc0200f2a:	00004617          	auipc	a2,0x4
ffffffffc0200f2e:	e7e60613          	addi	a2,a2,-386 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200f32:	0df00593          	li	a1,223
ffffffffc0200f36:	00004517          	auipc	a0,0x4
ffffffffc0200f3a:	e8a50513          	addi	a0,a0,-374 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200f3e:	c36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f42:	00004697          	auipc	a3,0x4
ffffffffc0200f46:	fde68693          	addi	a3,a3,-34 # ffffffffc0204f20 <commands+0x8b0>
ffffffffc0200f4a:	00004617          	auipc	a2,0x4
ffffffffc0200f4e:	e5e60613          	addi	a2,a2,-418 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200f52:	0dd00593          	li	a1,221
ffffffffc0200f56:	00004517          	auipc	a0,0x4
ffffffffc0200f5a:	e6a50513          	addi	a0,a0,-406 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200f5e:	c16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f62:	00004697          	auipc	a3,0x4
ffffffffc0200f66:	ffe68693          	addi	a3,a3,-2 # ffffffffc0204f60 <commands+0x8f0>
ffffffffc0200f6a:	00004617          	auipc	a2,0x4
ffffffffc0200f6e:	e3e60613          	addi	a2,a2,-450 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200f72:	0dc00593          	li	a1,220
ffffffffc0200f76:	00004517          	auipc	a0,0x4
ffffffffc0200f7a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200f7e:	bf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f82:	00004697          	auipc	a3,0x4
ffffffffc0200f86:	e7668693          	addi	a3,a3,-394 # ffffffffc0204df8 <commands+0x788>
ffffffffc0200f8a:	00004617          	auipc	a2,0x4
ffffffffc0200f8e:	e1e60613          	addi	a2,a2,-482 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200f92:	0b900593          	li	a1,185
ffffffffc0200f96:	00004517          	auipc	a0,0x4
ffffffffc0200f9a:	e2a50513          	addi	a0,a0,-470 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200f9e:	bd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa2:	00004697          	auipc	a3,0x4
ffffffffc0200fa6:	f7e68693          	addi	a3,a3,-130 # ffffffffc0204f20 <commands+0x8b0>
ffffffffc0200faa:	00004617          	auipc	a2,0x4
ffffffffc0200fae:	dfe60613          	addi	a2,a2,-514 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200fb2:	0d600593          	li	a1,214
ffffffffc0200fb6:	00004517          	auipc	a0,0x4
ffffffffc0200fba:	e0a50513          	addi	a0,a0,-502 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200fbe:	bb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	e7668693          	addi	a3,a3,-394 # ffffffffc0204e38 <commands+0x7c8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	dde60613          	addi	a2,a2,-546 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200fd2:	0d400593          	li	a1,212
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	dea50513          	addi	a0,a0,-534 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200fde:	b96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	e3668693          	addi	a3,a3,-458 # ffffffffc0204e18 <commands+0x7a8>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	dbe60613          	addi	a2,a2,-578 # ffffffffc0204da8 <commands+0x738>
ffffffffc0200ff2:	0d300593          	li	a1,211
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	dca50513          	addi	a0,a0,-566 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0200ffe:	b76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201002:	00004697          	auipc	a3,0x4
ffffffffc0201006:	e3668693          	addi	a3,a3,-458 # ffffffffc0204e38 <commands+0x7c8>
ffffffffc020100a:	00004617          	auipc	a2,0x4
ffffffffc020100e:	d9e60613          	addi	a2,a2,-610 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201012:	0bb00593          	li	a1,187
ffffffffc0201016:	00004517          	auipc	a0,0x4
ffffffffc020101a:	daa50513          	addi	a0,a0,-598 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020101e:	b56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201022:	00004697          	auipc	a3,0x4
ffffffffc0201026:	0be68693          	addi	a3,a3,190 # ffffffffc02050e0 <commands+0xa70>
ffffffffc020102a:	00004617          	auipc	a2,0x4
ffffffffc020102e:	d7e60613          	addi	a2,a2,-642 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201032:	12500593          	li	a1,293
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	d8a50513          	addi	a0,a0,-630 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020103e:	b36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201042:	00004697          	auipc	a3,0x4
ffffffffc0201046:	f3e68693          	addi	a3,a3,-194 # ffffffffc0204f80 <commands+0x910>
ffffffffc020104a:	00004617          	auipc	a2,0x4
ffffffffc020104e:	d5e60613          	addi	a2,a2,-674 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201052:	11a00593          	li	a1,282
ffffffffc0201056:	00004517          	auipc	a0,0x4
ffffffffc020105a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020105e:	b16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	ebe68693          	addi	a3,a3,-322 # ffffffffc0204f20 <commands+0x8b0>
ffffffffc020106a:	00004617          	auipc	a2,0x4
ffffffffc020106e:	d3e60613          	addi	a2,a2,-706 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201072:	11800593          	li	a1,280
ffffffffc0201076:	00004517          	auipc	a0,0x4
ffffffffc020107a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020107e:	af6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201082:	00004697          	auipc	a3,0x4
ffffffffc0201086:	e5e68693          	addi	a3,a3,-418 # ffffffffc0204ee0 <commands+0x870>
ffffffffc020108a:	00004617          	auipc	a2,0x4
ffffffffc020108e:	d1e60613          	addi	a2,a2,-738 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201092:	0c100593          	li	a1,193
ffffffffc0201096:	00004517          	auipc	a0,0x4
ffffffffc020109a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020109e:	ad6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010a2:	00004697          	auipc	a3,0x4
ffffffffc02010a6:	ffe68693          	addi	a3,a3,-2 # ffffffffc02050a0 <commands+0xa30>
ffffffffc02010aa:	00004617          	auipc	a2,0x4
ffffffffc02010ae:	cfe60613          	addi	a2,a2,-770 # ffffffffc0204da8 <commands+0x738>
ffffffffc02010b2:	11200593          	li	a1,274
ffffffffc02010b6:	00004517          	auipc	a0,0x4
ffffffffc02010ba:	d0a50513          	addi	a0,a0,-758 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02010be:	ab6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	fbe68693          	addi	a3,a3,-66 # ffffffffc0205080 <commands+0xa10>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	cde60613          	addi	a2,a2,-802 # ffffffffc0204da8 <commands+0x738>
ffffffffc02010d2:	11000593          	li	a1,272
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	cea50513          	addi	a0,a0,-790 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02010de:	a96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	f7668693          	addi	a3,a3,-138 # ffffffffc0205058 <commands+0x9e8>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	cbe60613          	addi	a2,a2,-834 # ffffffffc0204da8 <commands+0x738>
ffffffffc02010f2:	10e00593          	li	a1,270
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	cca50513          	addi	a0,a0,-822 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02010fe:	a76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205030 <commands+0x9c0>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	c9e60613          	addi	a2,a2,-866 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201112:	10d00593          	li	a1,269
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	caa50513          	addi	a0,a0,-854 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020111e:	a56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	efe68693          	addi	a3,a3,-258 # ffffffffc0205020 <commands+0x9b0>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	c7e60613          	addi	a2,a2,-898 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201132:	10800593          	li	a1,264
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	c8a50513          	addi	a0,a0,-886 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020113e:	a36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	dde68693          	addi	a3,a3,-546 # ffffffffc0204f20 <commands+0x8b0>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	c5e60613          	addi	a2,a2,-930 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201152:	10700593          	li	a1,263
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	c6a50513          	addi	a0,a0,-918 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020115e:	a16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	e9e68693          	addi	a3,a3,-354 # ffffffffc0205000 <commands+0x990>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	c3e60613          	addi	a2,a2,-962 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201172:	10600593          	li	a1,262
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	c4a50513          	addi	a0,a0,-950 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020117e:	9f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	e4e68693          	addi	a3,a3,-434 # ffffffffc0204fd0 <commands+0x960>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	c1e60613          	addi	a2,a2,-994 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201192:	10500593          	li	a1,261
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	c2a50513          	addi	a0,a0,-982 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020119e:	9d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	e1668693          	addi	a3,a3,-490 # ffffffffc0204fb8 <commands+0x948>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0204da8 <commands+0x738>
ffffffffc02011b2:	10400593          	li	a1,260
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02011be:	9b6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	d5e68693          	addi	a3,a3,-674 # ffffffffc0204f20 <commands+0x8b0>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	bde60613          	addi	a2,a2,-1058 # ffffffffc0204da8 <commands+0x738>
ffffffffc02011d2:	0fe00593          	li	a1,254
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	bea50513          	addi	a0,a0,-1046 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02011de:	996ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	dbe68693          	addi	a3,a3,-578 # ffffffffc0204fa0 <commands+0x930>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0204da8 <commands+0x738>
ffffffffc02011f2:	0f900593          	li	a1,249
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	bca50513          	addi	a0,a0,-1078 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02011fe:	976ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	ebe68693          	addi	a3,a3,-322 # ffffffffc02050c0 <commands+0xa50>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201212:	11700593          	li	a1,279
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	baa50513          	addi	a0,a0,-1110 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020121e:	956ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201222:	00004697          	auipc	a3,0x4
ffffffffc0201226:	ece68693          	addi	a3,a3,-306 # ffffffffc02050f0 <commands+0xa80>
ffffffffc020122a:	00004617          	auipc	a2,0x4
ffffffffc020122e:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201232:	12600593          	li	a1,294
ffffffffc0201236:	00004517          	auipc	a0,0x4
ffffffffc020123a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020123e:	936ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	b9668693          	addi	a3,a3,-1130 # ffffffffc0204dd8 <commands+0x768>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201252:	0f300593          	li	a1,243
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020125e:	916ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201262:	00004697          	auipc	a3,0x4
ffffffffc0201266:	bb668693          	addi	a3,a3,-1098 # ffffffffc0204e18 <commands+0x7a8>
ffffffffc020126a:	00004617          	auipc	a2,0x4
ffffffffc020126e:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201272:	0ba00593          	li	a1,186
ffffffffc0201276:	00004517          	auipc	a0,0x4
ffffffffc020127a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0204dc0 <commands+0x750>
ffffffffc020127e:	8f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201282 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201282:	1141                	addi	sp,sp,-16
ffffffffc0201284:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201286:	14058a63          	beqz	a1,ffffffffc02013da <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020128a:	00359693          	slli	a3,a1,0x3
ffffffffc020128e:	96ae                	add	a3,a3,a1
ffffffffc0201290:	068e                	slli	a3,a3,0x3
ffffffffc0201292:	96aa                	add	a3,a3,a0
ffffffffc0201294:	87aa                	mv	a5,a0
ffffffffc0201296:	02d50263          	beq	a0,a3,ffffffffc02012ba <default_free_pages+0x38>
ffffffffc020129a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020129c:	8b05                	andi	a4,a4,1
ffffffffc020129e:	10071e63          	bnez	a4,ffffffffc02013ba <default_free_pages+0x138>
ffffffffc02012a2:	6798                	ld	a4,8(a5)
ffffffffc02012a4:	8b09                	andi	a4,a4,2
ffffffffc02012a6:	10071a63          	bnez	a4,ffffffffc02013ba <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02012aa:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012ae:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012b2:	04878793          	addi	a5,a5,72
ffffffffc02012b6:	fed792e3          	bne	a5,a3,ffffffffc020129a <default_free_pages+0x18>
    base->property = n;
ffffffffc02012ba:	2581                	sext.w	a1,a1
ffffffffc02012bc:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012be:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012c2:	4789                	li	a5,2
ffffffffc02012c4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012c8:	00010697          	auipc	a3,0x10
ffffffffc02012cc:	d7868693          	addi	a3,a3,-648 # ffffffffc0211040 <free_area>
ffffffffc02012d0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012d2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012d4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012d8:	9db9                	addw	a1,a1,a4
ffffffffc02012da:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012dc:	0ad78863          	beq	a5,a3,ffffffffc020138c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012e0:	fe078713          	addi	a4,a5,-32
ffffffffc02012e4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012e8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012ea:	00e56a63          	bltu	a0,a4,ffffffffc02012fe <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02012ee:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012f0:	06d70263          	beq	a4,a3,ffffffffc0201354 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02012f4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012f6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012fa:	fee57ae3          	bgeu	a0,a4,ffffffffc02012ee <default_free_pages+0x6c>
ffffffffc02012fe:	c199                	beqz	a1,ffffffffc0201304 <default_free_pages+0x82>
ffffffffc0201300:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201304:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201306:	e390                	sd	a2,0(a5)
ffffffffc0201308:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020130a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020130c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020130e:	02d70063          	beq	a4,a3,ffffffffc020132e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201312:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201316:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc020131a:	02081613          	slli	a2,a6,0x20
ffffffffc020131e:	9201                	srli	a2,a2,0x20
ffffffffc0201320:	00361793          	slli	a5,a2,0x3
ffffffffc0201324:	97b2                	add	a5,a5,a2
ffffffffc0201326:	078e                	slli	a5,a5,0x3
ffffffffc0201328:	97ae                	add	a5,a5,a1
ffffffffc020132a:	02f50f63          	beq	a0,a5,ffffffffc0201368 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020132e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201330:	00d70f63          	beq	a4,a3,ffffffffc020134e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201334:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201336:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020133a:	02059613          	slli	a2,a1,0x20
ffffffffc020133e:	9201                	srli	a2,a2,0x20
ffffffffc0201340:	00361793          	slli	a5,a2,0x3
ffffffffc0201344:	97b2                	add	a5,a5,a2
ffffffffc0201346:	078e                	slli	a5,a5,0x3
ffffffffc0201348:	97aa                	add	a5,a5,a0
ffffffffc020134a:	04f68863          	beq	a3,a5,ffffffffc020139a <default_free_pages+0x118>
}
ffffffffc020134e:	60a2                	ld	ra,8(sp)
ffffffffc0201350:	0141                	addi	sp,sp,16
ffffffffc0201352:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201354:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201356:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201358:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020135a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020135c:	02d70563          	beq	a4,a3,ffffffffc0201386 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201360:	8832                	mv	a6,a2
ffffffffc0201362:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201364:	87ba                	mv	a5,a4
ffffffffc0201366:	bf41                	j	ffffffffc02012f6 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201368:	4d1c                	lw	a5,24(a0)
ffffffffc020136a:	0107883b          	addw	a6,a5,a6
ffffffffc020136e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201372:	57f5                	li	a5,-3
ffffffffc0201374:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201378:	7110                	ld	a2,32(a0)
ffffffffc020137a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020137c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020137e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201380:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201382:	e390                	sd	a2,0(a5)
ffffffffc0201384:	b775                	j	ffffffffc0201330 <default_free_pages+0xae>
ffffffffc0201386:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201388:	873e                	mv	a4,a5
ffffffffc020138a:	b761                	j	ffffffffc0201312 <default_free_pages+0x90>
}
ffffffffc020138c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020138e:	e390                	sd	a2,0(a5)
ffffffffc0201390:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201392:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201394:	f11c                	sd	a5,32(a0)
ffffffffc0201396:	0141                	addi	sp,sp,16
ffffffffc0201398:	8082                	ret
            base->property += p->property;
ffffffffc020139a:	ff872783          	lw	a5,-8(a4)
ffffffffc020139e:	fe870693          	addi	a3,a4,-24
ffffffffc02013a2:	9dbd                	addw	a1,a1,a5
ffffffffc02013a4:	cd0c                	sw	a1,24(a0)
ffffffffc02013a6:	57f5                	li	a5,-3
ffffffffc02013a8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013ac:	6314                	ld	a3,0(a4)
ffffffffc02013ae:	671c                	ld	a5,8(a4)
}
ffffffffc02013b0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013b2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013b4:	e394                	sd	a3,0(a5)
ffffffffc02013b6:	0141                	addi	sp,sp,16
ffffffffc02013b8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013ba:	00004697          	auipc	a3,0x4
ffffffffc02013be:	d4e68693          	addi	a3,a3,-690 # ffffffffc0205108 <commands+0xa98>
ffffffffc02013c2:	00004617          	auipc	a2,0x4
ffffffffc02013c6:	9e660613          	addi	a2,a2,-1562 # ffffffffc0204da8 <commands+0x738>
ffffffffc02013ca:	08300593          	li	a1,131
ffffffffc02013ce:	00004517          	auipc	a0,0x4
ffffffffc02013d2:	9f250513          	addi	a0,a0,-1550 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02013d6:	f9ffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02013da:	00004697          	auipc	a3,0x4
ffffffffc02013de:	d2668693          	addi	a3,a3,-730 # ffffffffc0205100 <commands+0xa90>
ffffffffc02013e2:	00004617          	auipc	a2,0x4
ffffffffc02013e6:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204da8 <commands+0x738>
ffffffffc02013ea:	08000593          	li	a1,128
ffffffffc02013ee:	00004517          	auipc	a0,0x4
ffffffffc02013f2:	9d250513          	addi	a0,a0,-1582 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02013f6:	f7ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02013fa <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013fa:	c959                	beqz	a0,ffffffffc0201490 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013fc:	00010597          	auipc	a1,0x10
ffffffffc0201400:	c4458593          	addi	a1,a1,-956 # ffffffffc0211040 <free_area>
ffffffffc0201404:	0105a803          	lw	a6,16(a1)
ffffffffc0201408:	862a                	mv	a2,a0
ffffffffc020140a:	02081793          	slli	a5,a6,0x20
ffffffffc020140e:	9381                	srli	a5,a5,0x20
ffffffffc0201410:	00a7ee63          	bltu	a5,a0,ffffffffc020142c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201414:	87ae                	mv	a5,a1
ffffffffc0201416:	a801                	j	ffffffffc0201426 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201418:	ff87a703          	lw	a4,-8(a5)
ffffffffc020141c:	02071693          	slli	a3,a4,0x20
ffffffffc0201420:	9281                	srli	a3,a3,0x20
ffffffffc0201422:	00c6f763          	bgeu	a3,a2,ffffffffc0201430 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201426:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201428:	feb798e3          	bne	a5,a1,ffffffffc0201418 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020142c:	4501                	li	a0,0
}
ffffffffc020142e:	8082                	ret
    return listelm->prev;
ffffffffc0201430:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201434:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201438:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020143c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201440:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201444:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201448:	02d67b63          	bgeu	a2,a3,ffffffffc020147e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020144c:	00361693          	slli	a3,a2,0x3
ffffffffc0201450:	96b2                	add	a3,a3,a2
ffffffffc0201452:	068e                	slli	a3,a3,0x3
ffffffffc0201454:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201456:	41c7073b          	subw	a4,a4,t3
ffffffffc020145a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020145c:	00868613          	addi	a2,a3,8
ffffffffc0201460:	4709                	li	a4,2
ffffffffc0201462:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201466:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020146a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020146e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201472:	e310                	sd	a2,0(a4)
ffffffffc0201474:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201478:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020147a:	0316b023          	sd	a7,32(a3)
ffffffffc020147e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201482:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201486:	5775                	li	a4,-3
ffffffffc0201488:	17a1                	addi	a5,a5,-24
ffffffffc020148a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020148e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201490:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201492:	00004697          	auipc	a3,0x4
ffffffffc0201496:	c6e68693          	addi	a3,a3,-914 # ffffffffc0205100 <commands+0xa90>
ffffffffc020149a:	00004617          	auipc	a2,0x4
ffffffffc020149e:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204da8 <commands+0x738>
ffffffffc02014a2:	06200593          	li	a1,98
ffffffffc02014a6:	00004517          	auipc	a0,0x4
ffffffffc02014aa:	91a50513          	addi	a0,a0,-1766 # ffffffffc0204dc0 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc02014ae:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014b0:	ec5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014b4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014b4:	1141                	addi	sp,sp,-16
ffffffffc02014b6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014b8:	c9e1                	beqz	a1,ffffffffc0201588 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02014ba:	00359693          	slli	a3,a1,0x3
ffffffffc02014be:	96ae                	add	a3,a3,a1
ffffffffc02014c0:	068e                	slli	a3,a3,0x3
ffffffffc02014c2:	96aa                	add	a3,a3,a0
ffffffffc02014c4:	87aa                	mv	a5,a0
ffffffffc02014c6:	00d50f63          	beq	a0,a3,ffffffffc02014e4 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014ca:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014cc:	8b05                	andi	a4,a4,1
ffffffffc02014ce:	cf49                	beqz	a4,ffffffffc0201568 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014d0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014d4:	0007b423          	sd	zero,8(a5)
ffffffffc02014d8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014dc:	04878793          	addi	a5,a5,72
ffffffffc02014e0:	fed795e3          	bne	a5,a3,ffffffffc02014ca <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014e4:	2581                	sext.w	a1,a1
ffffffffc02014e6:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014e8:	4789                	li	a5,2
ffffffffc02014ea:	00850713          	addi	a4,a0,8
ffffffffc02014ee:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014f2:	00010697          	auipc	a3,0x10
ffffffffc02014f6:	b4e68693          	addi	a3,a3,-1202 # ffffffffc0211040 <free_area>
ffffffffc02014fa:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014fc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02014fe:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201502:	9db9                	addw	a1,a1,a4
ffffffffc0201504:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201506:	04d78a63          	beq	a5,a3,ffffffffc020155a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020150a:	fe078713          	addi	a4,a5,-32
ffffffffc020150e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201512:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201514:	00e56a63          	bltu	a0,a4,ffffffffc0201528 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201518:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020151a:	02d70263          	beq	a4,a3,ffffffffc020153e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020151e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201520:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201524:	fee57ae3          	bgeu	a0,a4,ffffffffc0201518 <default_init_memmap+0x64>
ffffffffc0201528:	c199                	beqz	a1,ffffffffc020152e <default_init_memmap+0x7a>
ffffffffc020152a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020152e:	6398                	ld	a4,0(a5)
}
ffffffffc0201530:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201532:	e390                	sd	a2,0(a5)
ffffffffc0201534:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201536:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201538:	f118                	sd	a4,32(a0)
ffffffffc020153a:	0141                	addi	sp,sp,16
ffffffffc020153c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020153e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201540:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201542:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201544:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201546:	00d70663          	beq	a4,a3,ffffffffc0201552 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020154a:	8832                	mv	a6,a2
ffffffffc020154c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020154e:	87ba                	mv	a5,a4
ffffffffc0201550:	bfc1                	j	ffffffffc0201520 <default_init_memmap+0x6c>
}
ffffffffc0201552:	60a2                	ld	ra,8(sp)
ffffffffc0201554:	e290                	sd	a2,0(a3)
ffffffffc0201556:	0141                	addi	sp,sp,16
ffffffffc0201558:	8082                	ret
ffffffffc020155a:	60a2                	ld	ra,8(sp)
ffffffffc020155c:	e390                	sd	a2,0(a5)
ffffffffc020155e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201560:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201562:	f11c                	sd	a5,32(a0)
ffffffffc0201564:	0141                	addi	sp,sp,16
ffffffffc0201566:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201568:	00004697          	auipc	a3,0x4
ffffffffc020156c:	bc868693          	addi	a3,a3,-1080 # ffffffffc0205130 <commands+0xac0>
ffffffffc0201570:	00004617          	auipc	a2,0x4
ffffffffc0201574:	83860613          	addi	a2,a2,-1992 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201578:	04900593          	li	a1,73
ffffffffc020157c:	00004517          	auipc	a0,0x4
ffffffffc0201580:	84450513          	addi	a0,a0,-1980 # ffffffffc0204dc0 <commands+0x750>
ffffffffc0201584:	df1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201588:	00004697          	auipc	a3,0x4
ffffffffc020158c:	b7868693          	addi	a3,a3,-1160 # ffffffffc0205100 <commands+0xa90>
ffffffffc0201590:	00004617          	auipc	a2,0x4
ffffffffc0201594:	81860613          	addi	a2,a2,-2024 # ffffffffc0204da8 <commands+0x738>
ffffffffc0201598:	04600593          	li	a1,70
ffffffffc020159c:	00004517          	auipc	a0,0x4
ffffffffc02015a0:	82450513          	addi	a0,a0,-2012 # ffffffffc0204dc0 <commands+0x750>
ffffffffc02015a4:	dd1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015a8 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015a8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015aa:	00004617          	auipc	a2,0x4
ffffffffc02015ae:	be660613          	addi	a2,a2,-1050 # ffffffffc0205190 <default_pmm_manager+0x38>
ffffffffc02015b2:	06500593          	li	a1,101
ffffffffc02015b6:	00004517          	auipc	a0,0x4
ffffffffc02015ba:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02051b0 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015be:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015c0:	db5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015c4 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015c4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015c6:	00004617          	auipc	a2,0x4
ffffffffc02015ca:	bfa60613          	addi	a2,a2,-1030 # ffffffffc02051c0 <default_pmm_manager+0x68>
ffffffffc02015ce:	07000593          	li	a1,112
ffffffffc02015d2:	00004517          	auipc	a0,0x4
ffffffffc02015d6:	bde50513          	addi	a0,a0,-1058 # ffffffffc02051b0 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015da:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015dc:	d99fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015e0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015e0:	7139                	addi	sp,sp,-64
ffffffffc02015e2:	f426                	sd	s1,40(sp)
ffffffffc02015e4:	f04a                	sd	s2,32(sp)
ffffffffc02015e6:	ec4e                	sd	s3,24(sp)
ffffffffc02015e8:	e852                	sd	s4,16(sp)
ffffffffc02015ea:	e456                	sd	s5,8(sp)
ffffffffc02015ec:	e05a                	sd	s6,0(sp)
ffffffffc02015ee:	fc06                	sd	ra,56(sp)
ffffffffc02015f0:	f822                	sd	s0,48(sp)
ffffffffc02015f2:	84aa                	mv	s1,a0
ffffffffc02015f4:	00010917          	auipc	s2,0x10
ffffffffc02015f8:	f4490913          	addi	s2,s2,-188 # ffffffffc0211538 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015fc:	4a05                	li	s4,1
ffffffffc02015fe:	00010a97          	auipc	s5,0x10
ffffffffc0201602:	f5aa8a93          	addi	s5,s5,-166 # ffffffffc0211558 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201606:	0005099b          	sext.w	s3,a0
ffffffffc020160a:	00010b17          	auipc	s6,0x10
ffffffffc020160e:	f5eb0b13          	addi	s6,s6,-162 # ffffffffc0211568 <check_mm_struct>
ffffffffc0201612:	a01d                	j	ffffffffc0201638 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201614:	00093783          	ld	a5,0(s2)
ffffffffc0201618:	6f9c                	ld	a5,24(a5)
ffffffffc020161a:	9782                	jalr	a5
ffffffffc020161c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020161e:	4601                	li	a2,0
ffffffffc0201620:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201622:	ec0d                	bnez	s0,ffffffffc020165c <alloc_pages+0x7c>
ffffffffc0201624:	029a6c63          	bltu	s4,s1,ffffffffc020165c <alloc_pages+0x7c>
ffffffffc0201628:	000aa783          	lw	a5,0(s5)
ffffffffc020162c:	2781                	sext.w	a5,a5
ffffffffc020162e:	c79d                	beqz	a5,ffffffffc020165c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201630:	000b3503          	ld	a0,0(s6)
ffffffffc0201634:	189010ef          	jal	ra,ffffffffc0202fbc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201638:	100027f3          	csrr	a5,sstatus
ffffffffc020163c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020163e:	8526                	mv	a0,s1
ffffffffc0201640:	dbf1                	beqz	a5,ffffffffc0201614 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201642:	eadfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201646:	00093783          	ld	a5,0(s2)
ffffffffc020164a:	8526                	mv	a0,s1
ffffffffc020164c:	6f9c                	ld	a5,24(a5)
ffffffffc020164e:	9782                	jalr	a5
ffffffffc0201650:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201652:	e97fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201656:	4601                	li	a2,0
ffffffffc0201658:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020165a:	d469                	beqz	s0,ffffffffc0201624 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020165c:	70e2                	ld	ra,56(sp)
ffffffffc020165e:	8522                	mv	a0,s0
ffffffffc0201660:	7442                	ld	s0,48(sp)
ffffffffc0201662:	74a2                	ld	s1,40(sp)
ffffffffc0201664:	7902                	ld	s2,32(sp)
ffffffffc0201666:	69e2                	ld	s3,24(sp)
ffffffffc0201668:	6a42                	ld	s4,16(sp)
ffffffffc020166a:	6aa2                	ld	s5,8(sp)
ffffffffc020166c:	6b02                	ld	s6,0(sp)
ffffffffc020166e:	6121                	addi	sp,sp,64
ffffffffc0201670:	8082                	ret

ffffffffc0201672 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201672:	100027f3          	csrr	a5,sstatus
ffffffffc0201676:	8b89                	andi	a5,a5,2
ffffffffc0201678:	e799                	bnez	a5,ffffffffc0201686 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020167a:	00010797          	auipc	a5,0x10
ffffffffc020167e:	ebe7b783          	ld	a5,-322(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201682:	739c                	ld	a5,32(a5)
ffffffffc0201684:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201686:	1101                	addi	sp,sp,-32
ffffffffc0201688:	ec06                	sd	ra,24(sp)
ffffffffc020168a:	e822                	sd	s0,16(sp)
ffffffffc020168c:	e426                	sd	s1,8(sp)
ffffffffc020168e:	842a                	mv	s0,a0
ffffffffc0201690:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201692:	e5dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201696:	00010797          	auipc	a5,0x10
ffffffffc020169a:	ea27b783          	ld	a5,-350(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc020169e:	739c                	ld	a5,32(a5)
ffffffffc02016a0:	85a6                	mv	a1,s1
ffffffffc02016a2:	8522                	mv	a0,s0
ffffffffc02016a4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016a6:	6442                	ld	s0,16(sp)
ffffffffc02016a8:	60e2                	ld	ra,24(sp)
ffffffffc02016aa:	64a2                	ld	s1,8(sp)
ffffffffc02016ac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016ae:	e3bfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc02016b2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016b2:	100027f3          	csrr	a5,sstatus
ffffffffc02016b6:	8b89                	andi	a5,a5,2
ffffffffc02016b8:	e799                	bnez	a5,ffffffffc02016c6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016ba:	00010797          	auipc	a5,0x10
ffffffffc02016be:	e7e7b783          	ld	a5,-386(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016c2:	779c                	ld	a5,40(a5)
ffffffffc02016c4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016c6:	1141                	addi	sp,sp,-16
ffffffffc02016c8:	e406                	sd	ra,8(sp)
ffffffffc02016ca:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016cc:	e23fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016d0:	00010797          	auipc	a5,0x10
ffffffffc02016d4:	e687b783          	ld	a5,-408(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016d8:	779c                	ld	a5,40(a5)
ffffffffc02016da:	9782                	jalr	a5
ffffffffc02016dc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016de:	e0bfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016e2:	60a2                	ld	ra,8(sp)
ffffffffc02016e4:	8522                	mv	a0,s0
ffffffffc02016e6:	6402                	ld	s0,0(sp)
ffffffffc02016e8:	0141                	addi	sp,sp,16
ffffffffc02016ea:	8082                	ret

ffffffffc02016ec <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016ec:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016f0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f4:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016f6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f8:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016fa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016fe:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201700:	f84a                	sd	s2,48(sp)
ffffffffc0201702:	f44e                	sd	s3,40(sp)
ffffffffc0201704:	f052                	sd	s4,32(sp)
ffffffffc0201706:	e486                	sd	ra,72(sp)
ffffffffc0201708:	e0a2                	sd	s0,64(sp)
ffffffffc020170a:	ec56                	sd	s5,24(sp)
ffffffffc020170c:	e85a                	sd	s6,16(sp)
ffffffffc020170e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201710:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201714:	892e                	mv	s2,a1
ffffffffc0201716:	8a32                	mv	s4,a2
ffffffffc0201718:	00010997          	auipc	s3,0x10
ffffffffc020171c:	e1098993          	addi	s3,s3,-496 # ffffffffc0211528 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201720:	efb5                	bnez	a5,ffffffffc020179c <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201722:	14060c63          	beqz	a2,ffffffffc020187a <get_pte+0x18e>
ffffffffc0201726:	4505                	li	a0,1
ffffffffc0201728:	eb9ff0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc020172c:	842a                	mv	s0,a0
ffffffffc020172e:	14050663          	beqz	a0,ffffffffc020187a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201732:	00010b97          	auipc	s7,0x10
ffffffffc0201736:	dfeb8b93          	addi	s7,s7,-514 # ffffffffc0211530 <pages>
ffffffffc020173a:	000bb503          	ld	a0,0(s7)
ffffffffc020173e:	00005b17          	auipc	s6,0x5
ffffffffc0201742:	ae2b3b03          	ld	s6,-1310(s6) # ffffffffc0206220 <error_string+0x38>
ffffffffc0201746:	00080ab7          	lui	s5,0x80
ffffffffc020174a:	40a40533          	sub	a0,s0,a0
ffffffffc020174e:	850d                	srai	a0,a0,0x3
ffffffffc0201750:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201754:	00010997          	auipc	s3,0x10
ffffffffc0201758:	dd498993          	addi	s3,s3,-556 # ffffffffc0211528 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020175c:	4785                	li	a5,1
ffffffffc020175e:	0009b703          	ld	a4,0(s3)
ffffffffc0201762:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201764:	9556                	add	a0,a0,s5
ffffffffc0201766:	00c51793          	slli	a5,a0,0xc
ffffffffc020176a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020176c:	0532                	slli	a0,a0,0xc
ffffffffc020176e:	14e7fd63          	bgeu	a5,a4,ffffffffc02018c8 <get_pte+0x1dc>
ffffffffc0201772:	00010797          	auipc	a5,0x10
ffffffffc0201776:	dce7b783          	ld	a5,-562(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc020177a:	6605                	lui	a2,0x1
ffffffffc020177c:	4581                	li	a1,0
ffffffffc020177e:	953e                	add	a0,a0,a5
ffffffffc0201780:	469020ef          	jal	ra,ffffffffc02043e8 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201784:	000bb683          	ld	a3,0(s7)
ffffffffc0201788:	40d406b3          	sub	a3,s0,a3
ffffffffc020178c:	868d                	srai	a3,a3,0x3
ffffffffc020178e:	036686b3          	mul	a3,a3,s6
ffffffffc0201792:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201794:	06aa                	slli	a3,a3,0xa
ffffffffc0201796:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020179a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020179c:	77fd                	lui	a5,0xfffff
ffffffffc020179e:	068a                	slli	a3,a3,0x2
ffffffffc02017a0:	0009b703          	ld	a4,0(s3)
ffffffffc02017a4:	8efd                	and	a3,a3,a5
ffffffffc02017a6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017aa:	0ce7fa63          	bgeu	a5,a4,ffffffffc020187e <get_pte+0x192>
ffffffffc02017ae:	00010a97          	auipc	s5,0x10
ffffffffc02017b2:	d92a8a93          	addi	s5,s5,-622 # ffffffffc0211540 <va_pa_offset>
ffffffffc02017b6:	000ab403          	ld	s0,0(s5)
ffffffffc02017ba:	01595793          	srli	a5,s2,0x15
ffffffffc02017be:	1ff7f793          	andi	a5,a5,511
ffffffffc02017c2:	96a2                	add	a3,a3,s0
ffffffffc02017c4:	00379413          	slli	s0,a5,0x3
ffffffffc02017c8:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017ca:	6014                	ld	a3,0(s0)
ffffffffc02017cc:	0016f793          	andi	a5,a3,1
ffffffffc02017d0:	ebad                	bnez	a5,ffffffffc0201842 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017d2:	0a0a0463          	beqz	s4,ffffffffc020187a <get_pte+0x18e>
ffffffffc02017d6:	4505                	li	a0,1
ffffffffc02017d8:	e09ff0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc02017dc:	84aa                	mv	s1,a0
ffffffffc02017de:	cd51                	beqz	a0,ffffffffc020187a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017e0:	00010b97          	auipc	s7,0x10
ffffffffc02017e4:	d50b8b93          	addi	s7,s7,-688 # ffffffffc0211530 <pages>
ffffffffc02017e8:	000bb503          	ld	a0,0(s7)
ffffffffc02017ec:	00005b17          	auipc	s6,0x5
ffffffffc02017f0:	a34b3b03          	ld	s6,-1484(s6) # ffffffffc0206220 <error_string+0x38>
ffffffffc02017f4:	00080a37          	lui	s4,0x80
ffffffffc02017f8:	40a48533          	sub	a0,s1,a0
ffffffffc02017fc:	850d                	srai	a0,a0,0x3
ffffffffc02017fe:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201802:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201804:	0009b703          	ld	a4,0(s3)
ffffffffc0201808:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020180a:	9552                	add	a0,a0,s4
ffffffffc020180c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201810:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201812:	0532                	slli	a0,a0,0xc
ffffffffc0201814:	08e7fd63          	bgeu	a5,a4,ffffffffc02018ae <get_pte+0x1c2>
ffffffffc0201818:	000ab783          	ld	a5,0(s5)
ffffffffc020181c:	6605                	lui	a2,0x1
ffffffffc020181e:	4581                	li	a1,0
ffffffffc0201820:	953e                	add	a0,a0,a5
ffffffffc0201822:	3c7020ef          	jal	ra,ffffffffc02043e8 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201826:	000bb683          	ld	a3,0(s7)
ffffffffc020182a:	40d486b3          	sub	a3,s1,a3
ffffffffc020182e:	868d                	srai	a3,a3,0x3
ffffffffc0201830:	036686b3          	mul	a3,a3,s6
ffffffffc0201834:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201836:	06aa                	slli	a3,a3,0xa
ffffffffc0201838:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020183c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020183e:	0009b703          	ld	a4,0(s3)
ffffffffc0201842:	068a                	slli	a3,a3,0x2
ffffffffc0201844:	757d                	lui	a0,0xfffff
ffffffffc0201846:	8ee9                	and	a3,a3,a0
ffffffffc0201848:	00c6d793          	srli	a5,a3,0xc
ffffffffc020184c:	04e7f563          	bgeu	a5,a4,ffffffffc0201896 <get_pte+0x1aa>
ffffffffc0201850:	000ab503          	ld	a0,0(s5)
ffffffffc0201854:	00c95913          	srli	s2,s2,0xc
ffffffffc0201858:	1ff97913          	andi	s2,s2,511
ffffffffc020185c:	96aa                	add	a3,a3,a0
ffffffffc020185e:	00391513          	slli	a0,s2,0x3
ffffffffc0201862:	9536                	add	a0,a0,a3
}
ffffffffc0201864:	60a6                	ld	ra,72(sp)
ffffffffc0201866:	6406                	ld	s0,64(sp)
ffffffffc0201868:	74e2                	ld	s1,56(sp)
ffffffffc020186a:	7942                	ld	s2,48(sp)
ffffffffc020186c:	79a2                	ld	s3,40(sp)
ffffffffc020186e:	7a02                	ld	s4,32(sp)
ffffffffc0201870:	6ae2                	ld	s5,24(sp)
ffffffffc0201872:	6b42                	ld	s6,16(sp)
ffffffffc0201874:	6ba2                	ld	s7,8(sp)
ffffffffc0201876:	6161                	addi	sp,sp,80
ffffffffc0201878:	8082                	ret
            return NULL;
ffffffffc020187a:	4501                	li	a0,0
ffffffffc020187c:	b7e5                	j	ffffffffc0201864 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020187e:	00004617          	auipc	a2,0x4
ffffffffc0201882:	96a60613          	addi	a2,a2,-1686 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc0201886:	10200593          	li	a1,258
ffffffffc020188a:	00004517          	auipc	a0,0x4
ffffffffc020188e:	98650513          	addi	a0,a0,-1658 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0201892:	ae3fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201896:	00004617          	auipc	a2,0x4
ffffffffc020189a:	95260613          	addi	a2,a2,-1710 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc020189e:	10f00593          	li	a1,271
ffffffffc02018a2:	00004517          	auipc	a0,0x4
ffffffffc02018a6:	96e50513          	addi	a0,a0,-1682 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02018aa:	acbfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018ae:	86aa                	mv	a3,a0
ffffffffc02018b0:	00004617          	auipc	a2,0x4
ffffffffc02018b4:	93860613          	addi	a2,a2,-1736 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc02018b8:	10b00593          	li	a1,267
ffffffffc02018bc:	00004517          	auipc	a0,0x4
ffffffffc02018c0:	95450513          	addi	a0,a0,-1708 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02018c4:	ab1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018c8:	86aa                	mv	a3,a0
ffffffffc02018ca:	00004617          	auipc	a2,0x4
ffffffffc02018ce:	91e60613          	addi	a2,a2,-1762 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc02018d2:	0ff00593          	li	a1,255
ffffffffc02018d6:	00004517          	auipc	a0,0x4
ffffffffc02018da:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02018de:	a97fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02018e2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018e2:	1141                	addi	sp,sp,-16
ffffffffc02018e4:	e022                	sd	s0,0(sp)
ffffffffc02018e6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018e8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018ea:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018ec:	e01ff0ef          	jal	ra,ffffffffc02016ec <get_pte>
    if (ptep_store != NULL) {
ffffffffc02018f0:	c011                	beqz	s0,ffffffffc02018f4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02018f2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018f4:	c511                	beqz	a0,ffffffffc0201900 <get_page+0x1e>
ffffffffc02018f6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02018f8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018fa:	0017f713          	andi	a4,a5,1
ffffffffc02018fe:	e709                	bnez	a4,ffffffffc0201908 <get_page+0x26>
}
ffffffffc0201900:	60a2                	ld	ra,8(sp)
ffffffffc0201902:	6402                	ld	s0,0(sp)
ffffffffc0201904:	0141                	addi	sp,sp,16
ffffffffc0201906:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201908:	078a                	slli	a5,a5,0x2
ffffffffc020190a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020190c:	00010717          	auipc	a4,0x10
ffffffffc0201910:	c1c73703          	ld	a4,-996(a4) # ffffffffc0211528 <npage>
ffffffffc0201914:	02e7f263          	bgeu	a5,a4,ffffffffc0201938 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201918:	fff80537          	lui	a0,0xfff80
ffffffffc020191c:	97aa                	add	a5,a5,a0
ffffffffc020191e:	60a2                	ld	ra,8(sp)
ffffffffc0201920:	6402                	ld	s0,0(sp)
ffffffffc0201922:	00379513          	slli	a0,a5,0x3
ffffffffc0201926:	97aa                	add	a5,a5,a0
ffffffffc0201928:	078e                	slli	a5,a5,0x3
ffffffffc020192a:	00010517          	auipc	a0,0x10
ffffffffc020192e:	c0653503          	ld	a0,-1018(a0) # ffffffffc0211530 <pages>
ffffffffc0201932:	953e                	add	a0,a0,a5
ffffffffc0201934:	0141                	addi	sp,sp,16
ffffffffc0201936:	8082                	ret
ffffffffc0201938:	c71ff0ef          	jal	ra,ffffffffc02015a8 <pa2page.part.0>

ffffffffc020193c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020193c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020193e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201940:	ec06                	sd	ra,24(sp)
ffffffffc0201942:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201944:	da9ff0ef          	jal	ra,ffffffffc02016ec <get_pte>
    if (ptep != NULL) {
ffffffffc0201948:	c511                	beqz	a0,ffffffffc0201954 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020194a:	611c                	ld	a5,0(a0)
ffffffffc020194c:	842a                	mv	s0,a0
ffffffffc020194e:	0017f713          	andi	a4,a5,1
ffffffffc0201952:	e709                	bnez	a4,ffffffffc020195c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201954:	60e2                	ld	ra,24(sp)
ffffffffc0201956:	6442                	ld	s0,16(sp)
ffffffffc0201958:	6105                	addi	sp,sp,32
ffffffffc020195a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020195c:	078a                	slli	a5,a5,0x2
ffffffffc020195e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201960:	00010717          	auipc	a4,0x10
ffffffffc0201964:	bc873703          	ld	a4,-1080(a4) # ffffffffc0211528 <npage>
ffffffffc0201968:	06e7f563          	bgeu	a5,a4,ffffffffc02019d2 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020196c:	fff80737          	lui	a4,0xfff80
ffffffffc0201970:	97ba                	add	a5,a5,a4
ffffffffc0201972:	00379513          	slli	a0,a5,0x3
ffffffffc0201976:	97aa                	add	a5,a5,a0
ffffffffc0201978:	078e                	slli	a5,a5,0x3
ffffffffc020197a:	00010517          	auipc	a0,0x10
ffffffffc020197e:	bb653503          	ld	a0,-1098(a0) # ffffffffc0211530 <pages>
ffffffffc0201982:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201984:	411c                	lw	a5,0(a0)
ffffffffc0201986:	fff7871b          	addiw	a4,a5,-1
ffffffffc020198a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020198c:	cb09                	beqz	a4,ffffffffc020199e <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020198e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201992:	12000073          	sfence.vma
}
ffffffffc0201996:	60e2                	ld	ra,24(sp)
ffffffffc0201998:	6442                	ld	s0,16(sp)
ffffffffc020199a:	6105                	addi	sp,sp,32
ffffffffc020199c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020199e:	100027f3          	csrr	a5,sstatus
ffffffffc02019a2:	8b89                	andi	a5,a5,2
ffffffffc02019a4:	eb89                	bnez	a5,ffffffffc02019b6 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019a6:	00010797          	auipc	a5,0x10
ffffffffc02019aa:	b927b783          	ld	a5,-1134(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019ae:	739c                	ld	a5,32(a5)
ffffffffc02019b0:	4585                	li	a1,1
ffffffffc02019b2:	9782                	jalr	a5
    if (flag) {
ffffffffc02019b4:	bfe9                	j	ffffffffc020198e <page_remove+0x52>
        intr_disable();
ffffffffc02019b6:	e42a                	sd	a0,8(sp)
ffffffffc02019b8:	b37fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02019bc:	00010797          	auipc	a5,0x10
ffffffffc02019c0:	b7c7b783          	ld	a5,-1156(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019c4:	739c                	ld	a5,32(a5)
ffffffffc02019c6:	6522                	ld	a0,8(sp)
ffffffffc02019c8:	4585                	li	a1,1
ffffffffc02019ca:	9782                	jalr	a5
        intr_enable();
ffffffffc02019cc:	b1dfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02019d0:	bf7d                	j	ffffffffc020198e <page_remove+0x52>
ffffffffc02019d2:	bd7ff0ef          	jal	ra,ffffffffc02015a8 <pa2page.part.0>

ffffffffc02019d6 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019d6:	7179                	addi	sp,sp,-48
ffffffffc02019d8:	87b2                	mv	a5,a2
ffffffffc02019da:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019dc:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019de:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019e0:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019e2:	ec26                	sd	s1,24(sp)
ffffffffc02019e4:	f406                	sd	ra,40(sp)
ffffffffc02019e6:	e84a                	sd	s2,16(sp)
ffffffffc02019e8:	e44e                	sd	s3,8(sp)
ffffffffc02019ea:	e052                	sd	s4,0(sp)
ffffffffc02019ec:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019ee:	cffff0ef          	jal	ra,ffffffffc02016ec <get_pte>
    if (ptep == NULL) {
ffffffffc02019f2:	cd71                	beqz	a0,ffffffffc0201ace <page_insert+0xf8>
    page->ref += 1;
ffffffffc02019f4:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc02019f6:	611c                	ld	a5,0(a0)
ffffffffc02019f8:	89aa                	mv	s3,a0
ffffffffc02019fa:	0016871b          	addiw	a4,a3,1
ffffffffc02019fe:	c018                	sw	a4,0(s0)
ffffffffc0201a00:	0017f713          	andi	a4,a5,1
ffffffffc0201a04:	e331                	bnez	a4,ffffffffc0201a48 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a06:	00010797          	auipc	a5,0x10
ffffffffc0201a0a:	b2a7b783          	ld	a5,-1238(a5) # ffffffffc0211530 <pages>
ffffffffc0201a0e:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a12:	878d                	srai	a5,a5,0x3
ffffffffc0201a14:	00005417          	auipc	s0,0x5
ffffffffc0201a18:	80c43403          	ld	s0,-2036(s0) # ffffffffc0206220 <error_string+0x38>
ffffffffc0201a1c:	028787b3          	mul	a5,a5,s0
ffffffffc0201a20:	00080437          	lui	s0,0x80
ffffffffc0201a24:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a26:	07aa                	slli	a5,a5,0xa
ffffffffc0201a28:	8cdd                	or	s1,s1,a5
ffffffffc0201a2a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a2e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a32:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a36:	4501                	li	a0,0
}
ffffffffc0201a38:	70a2                	ld	ra,40(sp)
ffffffffc0201a3a:	7402                	ld	s0,32(sp)
ffffffffc0201a3c:	64e2                	ld	s1,24(sp)
ffffffffc0201a3e:	6942                	ld	s2,16(sp)
ffffffffc0201a40:	69a2                	ld	s3,8(sp)
ffffffffc0201a42:	6a02                	ld	s4,0(sp)
ffffffffc0201a44:	6145                	addi	sp,sp,48
ffffffffc0201a46:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a48:	00279713          	slli	a4,a5,0x2
ffffffffc0201a4c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a4e:	00010797          	auipc	a5,0x10
ffffffffc0201a52:	ada7b783          	ld	a5,-1318(a5) # ffffffffc0211528 <npage>
ffffffffc0201a56:	06f77e63          	bgeu	a4,a5,ffffffffc0201ad2 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a5a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a5e:	973e                	add	a4,a4,a5
ffffffffc0201a60:	00010a17          	auipc	s4,0x10
ffffffffc0201a64:	ad0a0a13          	addi	s4,s4,-1328 # ffffffffc0211530 <pages>
ffffffffc0201a68:	000a3783          	ld	a5,0(s4)
ffffffffc0201a6c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a70:	993a                	add	s2,s2,a4
ffffffffc0201a72:	090e                	slli	s2,s2,0x3
ffffffffc0201a74:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a76:	03240063          	beq	s0,s2,ffffffffc0201a96 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a7a:	00092783          	lw	a5,0(s2)
ffffffffc0201a7e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a82:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201a86:	cb11                	beqz	a4,ffffffffc0201a9a <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a88:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a8c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a90:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201a94:	bfad                	j	ffffffffc0201a0e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201a96:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201a98:	bf9d                	j	ffffffffc0201a0e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a9e:	8b89                	andi	a5,a5,2
ffffffffc0201aa0:	eb91                	bnez	a5,ffffffffc0201ab4 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201aa2:	00010797          	auipc	a5,0x10
ffffffffc0201aa6:	a967b783          	ld	a5,-1386(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201aaa:	739c                	ld	a5,32(a5)
ffffffffc0201aac:	4585                	li	a1,1
ffffffffc0201aae:	854a                	mv	a0,s2
ffffffffc0201ab0:	9782                	jalr	a5
    if (flag) {
ffffffffc0201ab2:	bfd9                	j	ffffffffc0201a88 <page_insert+0xb2>
        intr_disable();
ffffffffc0201ab4:	a3bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201ab8:	00010797          	auipc	a5,0x10
ffffffffc0201abc:	a807b783          	ld	a5,-1408(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201ac0:	739c                	ld	a5,32(a5)
ffffffffc0201ac2:	4585                	li	a1,1
ffffffffc0201ac4:	854a                	mv	a0,s2
ffffffffc0201ac6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201ac8:	a21fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201acc:	bf75                	j	ffffffffc0201a88 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201ace:	5571                	li	a0,-4
ffffffffc0201ad0:	b7a5                	j	ffffffffc0201a38 <page_insert+0x62>
ffffffffc0201ad2:	ad7ff0ef          	jal	ra,ffffffffc02015a8 <pa2page.part.0>

ffffffffc0201ad6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201ad6:	00003797          	auipc	a5,0x3
ffffffffc0201ada:	68278793          	addi	a5,a5,1666 # ffffffffc0205158 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ade:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ae0:	7159                	addi	sp,sp,-112
ffffffffc0201ae2:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ae4:	00003517          	auipc	a0,0x3
ffffffffc0201ae8:	73c50513          	addi	a0,a0,1852 # ffffffffc0205220 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201aec:	00010b97          	auipc	s7,0x10
ffffffffc0201af0:	a4cb8b93          	addi	s7,s7,-1460 # ffffffffc0211538 <pmm_manager>
void pmm_init(void) {
ffffffffc0201af4:	f486                	sd	ra,104(sp)
ffffffffc0201af6:	f0a2                	sd	s0,96(sp)
ffffffffc0201af8:	eca6                	sd	s1,88(sp)
ffffffffc0201afa:	e8ca                	sd	s2,80(sp)
ffffffffc0201afc:	e4ce                	sd	s3,72(sp)
ffffffffc0201afe:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b00:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201b04:	e0d2                	sd	s4,64(sp)
ffffffffc0201b06:	fc56                	sd	s5,56(sp)
ffffffffc0201b08:	f062                	sd	s8,32(sp)
ffffffffc0201b0a:	ec66                	sd	s9,24(sp)
ffffffffc0201b0c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b0e:	dacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b12:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b16:	4445                	li	s0,17
ffffffffc0201b18:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201b1c:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b1e:	00010997          	auipc	s3,0x10
ffffffffc0201b22:	a2298993          	addi	s3,s3,-1502 # ffffffffc0211540 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b26:	00010497          	auipc	s1,0x10
ffffffffc0201b2a:	a0248493          	addi	s1,s1,-1534 # ffffffffc0211528 <npage>
    pmm_manager->init();
ffffffffc0201b2e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b30:	57f5                	li	a5,-3
ffffffffc0201b32:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b34:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b38:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b3c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b40:	00003517          	auipc	a0,0x3
ffffffffc0201b44:	6f850513          	addi	a0,a0,1784 # ffffffffc0205238 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b48:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b4c:	d6efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b50:	00003517          	auipc	a0,0x3
ffffffffc0201b54:	71850513          	addi	a0,a0,1816 # ffffffffc0205268 <default_pmm_manager+0x110>
ffffffffc0201b58:	d62fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b5c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b60:	16fd                	addi	a3,a3,-1
ffffffffc0201b62:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b66:	01591613          	slli	a2,s2,0x15
ffffffffc0201b6a:	00003517          	auipc	a0,0x3
ffffffffc0201b6e:	71650513          	addi	a0,a0,1814 # ffffffffc0205280 <default_pmm_manager+0x128>
ffffffffc0201b72:	d48fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b76:	777d                	lui	a4,0xfffff
ffffffffc0201b78:	00011797          	auipc	a5,0x11
ffffffffc0201b7c:	9fb78793          	addi	a5,a5,-1541 # ffffffffc0212573 <end+0xfff>
ffffffffc0201b80:	8ff9                	and	a5,a5,a4
ffffffffc0201b82:	00010b17          	auipc	s6,0x10
ffffffffc0201b86:	9aeb0b13          	addi	s6,s6,-1618 # ffffffffc0211530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201b8a:	00088737          	lui	a4,0x88
ffffffffc0201b8e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b90:	00fb3023          	sd	a5,0(s6)
ffffffffc0201b94:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b96:	4701                	li	a4,0
ffffffffc0201b98:	4505                	li	a0,1
ffffffffc0201b9a:	fff805b7          	lui	a1,0xfff80
ffffffffc0201b9e:	a019                	j	ffffffffc0201ba4 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201ba0:	000b3783          	ld	a5,0(s6)
ffffffffc0201ba4:	97b6                	add	a5,a5,a3
ffffffffc0201ba6:	07a1                	addi	a5,a5,8
ffffffffc0201ba8:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bac:	609c                	ld	a5,0(s1)
ffffffffc0201bae:	0705                	addi	a4,a4,1
ffffffffc0201bb0:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201bb4:	00b78633          	add	a2,a5,a1
ffffffffc0201bb8:	fec764e3          	bltu	a4,a2,ffffffffc0201ba0 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bbc:	000b3503          	ld	a0,0(s6)
ffffffffc0201bc0:	00379693          	slli	a3,a5,0x3
ffffffffc0201bc4:	96be                	add	a3,a3,a5
ffffffffc0201bc6:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bca:	972a                	add	a4,a4,a0
ffffffffc0201bcc:	068e                	slli	a3,a3,0x3
ffffffffc0201bce:	96ba                	add	a3,a3,a4
ffffffffc0201bd0:	c0200737          	lui	a4,0xc0200
ffffffffc0201bd4:	64e6e463          	bltu	a3,a4,ffffffffc020221c <pmm_init+0x746>
ffffffffc0201bd8:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201bdc:	4645                	li	a2,17
ffffffffc0201bde:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201be0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201be2:	4ec6e263          	bltu	a3,a2,ffffffffc02020c6 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201be6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bea:	00010917          	auipc	s2,0x10
ffffffffc0201bee:	93690913          	addi	s2,s2,-1738 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201bf2:	7b9c                	ld	a5,48(a5)
ffffffffc0201bf4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201bf6:	00003517          	auipc	a0,0x3
ffffffffc0201bfa:	6da50513          	addi	a0,a0,1754 # ffffffffc02052d0 <default_pmm_manager+0x178>
ffffffffc0201bfe:	cbcfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c02:	00007697          	auipc	a3,0x7
ffffffffc0201c06:	3fe68693          	addi	a3,a3,1022 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c0a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c0e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c12:	62f6e163          	bltu	a3,a5,ffffffffc0202234 <pmm_init+0x75e>
ffffffffc0201c16:	0009b783          	ld	a5,0(s3)
ffffffffc0201c1a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c1c:	00010797          	auipc	a5,0x10
ffffffffc0201c20:	8ed7be23          	sd	a3,-1796(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c24:	100027f3          	csrr	a5,sstatus
ffffffffc0201c28:	8b89                	andi	a5,a5,2
ffffffffc0201c2a:	4c079763          	bnez	a5,ffffffffc02020f8 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c2e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c32:	779c                	ld	a5,40(a5)
ffffffffc0201c34:	9782                	jalr	a5
ffffffffc0201c36:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c38:	6098                	ld	a4,0(s1)
ffffffffc0201c3a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c3e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c40:	62e7e663          	bltu	a5,a4,ffffffffc020226c <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c44:	00093503          	ld	a0,0(s2)
ffffffffc0201c48:	60050263          	beqz	a0,ffffffffc020224c <pmm_init+0x776>
ffffffffc0201c4c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c50:	5e079e63          	bnez	a5,ffffffffc020224c <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c54:	4601                	li	a2,0
ffffffffc0201c56:	4581                	li	a1,0
ffffffffc0201c58:	c8bff0ef          	jal	ra,ffffffffc02018e2 <get_page>
ffffffffc0201c5c:	66051a63          	bnez	a0,ffffffffc02022d0 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c60:	4505                	li	a0,1
ffffffffc0201c62:	97fff0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0201c66:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c68:	00093503          	ld	a0,0(s2)
ffffffffc0201c6c:	4681                	li	a3,0
ffffffffc0201c6e:	4601                	li	a2,0
ffffffffc0201c70:	85d2                	mv	a1,s4
ffffffffc0201c72:	d65ff0ef          	jal	ra,ffffffffc02019d6 <page_insert>
ffffffffc0201c76:	62051d63          	bnez	a0,ffffffffc02022b0 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c7a:	00093503          	ld	a0,0(s2)
ffffffffc0201c7e:	4601                	li	a2,0
ffffffffc0201c80:	4581                	li	a1,0
ffffffffc0201c82:	a6bff0ef          	jal	ra,ffffffffc02016ec <get_pte>
ffffffffc0201c86:	60050563          	beqz	a0,ffffffffc0202290 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c8a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c8c:	0017f713          	andi	a4,a5,1
ffffffffc0201c90:	5e070e63          	beqz	a4,ffffffffc020228c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201c94:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c96:	078a                	slli	a5,a5,0x2
ffffffffc0201c98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c9a:	56c7ff63          	bgeu	a5,a2,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c9e:	fff80737          	lui	a4,0xfff80
ffffffffc0201ca2:	97ba                	add	a5,a5,a4
ffffffffc0201ca4:	000b3683          	ld	a3,0(s6)
ffffffffc0201ca8:	00379713          	slli	a4,a5,0x3
ffffffffc0201cac:	97ba                	add	a5,a5,a4
ffffffffc0201cae:	078e                	slli	a5,a5,0x3
ffffffffc0201cb0:	97b6                	add	a5,a5,a3
ffffffffc0201cb2:	14fa18e3          	bne	s4,a5,ffffffffc0202602 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201cb6:	000a2703          	lw	a4,0(s4)
ffffffffc0201cba:	4785                	li	a5,1
ffffffffc0201cbc:	16f71fe3          	bne	a4,a5,ffffffffc020263a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201cc0:	00093503          	ld	a0,0(s2)
ffffffffc0201cc4:	77fd                	lui	a5,0xfffff
ffffffffc0201cc6:	6114                	ld	a3,0(a0)
ffffffffc0201cc8:	068a                	slli	a3,a3,0x2
ffffffffc0201cca:	8efd                	and	a3,a3,a5
ffffffffc0201ccc:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201cd0:	14c779e3          	bgeu	a4,a2,ffffffffc0202622 <pmm_init+0xb4c>
ffffffffc0201cd4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cd8:	96e2                	add	a3,a3,s8
ffffffffc0201cda:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cde:	0a8a                	slli	s5,s5,0x2
ffffffffc0201ce0:	00fafab3          	and	s5,s5,a5
ffffffffc0201ce4:	00cad793          	srli	a5,s5,0xc
ffffffffc0201ce8:	66c7f463          	bgeu	a5,a2,ffffffffc0202350 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cec:	4601                	li	a2,0
ffffffffc0201cee:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cf0:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cf2:	9fbff0ef          	jal	ra,ffffffffc02016ec <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cf6:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cf8:	63551c63          	bne	a0,s5,ffffffffc0202330 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201cfc:	4505                	li	a0,1
ffffffffc0201cfe:	8e3ff0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0201d02:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d04:	00093503          	ld	a0,0(s2)
ffffffffc0201d08:	46d1                	li	a3,20
ffffffffc0201d0a:	6605                	lui	a2,0x1
ffffffffc0201d0c:	85d6                	mv	a1,s5
ffffffffc0201d0e:	cc9ff0ef          	jal	ra,ffffffffc02019d6 <page_insert>
ffffffffc0201d12:	5c051f63          	bnez	a0,ffffffffc02022f0 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d16:	00093503          	ld	a0,0(s2)
ffffffffc0201d1a:	4601                	li	a2,0
ffffffffc0201d1c:	6585                	lui	a1,0x1
ffffffffc0201d1e:	9cfff0ef          	jal	ra,ffffffffc02016ec <get_pte>
ffffffffc0201d22:	12050ce3          	beqz	a0,ffffffffc020265a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201d26:	611c                	ld	a5,0(a0)
ffffffffc0201d28:	0107f713          	andi	a4,a5,16
ffffffffc0201d2c:	72070f63          	beqz	a4,ffffffffc020246a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d30:	8b91                	andi	a5,a5,4
ffffffffc0201d32:	6e078c63          	beqz	a5,ffffffffc020242a <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d36:	00093503          	ld	a0,0(s2)
ffffffffc0201d3a:	611c                	ld	a5,0(a0)
ffffffffc0201d3c:	8bc1                	andi	a5,a5,16
ffffffffc0201d3e:	6c078663          	beqz	a5,ffffffffc020240a <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201d42:	000aa703          	lw	a4,0(s5)
ffffffffc0201d46:	4785                	li	a5,1
ffffffffc0201d48:	5cf71463          	bne	a4,a5,ffffffffc0202310 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d4c:	4681                	li	a3,0
ffffffffc0201d4e:	6605                	lui	a2,0x1
ffffffffc0201d50:	85d2                	mv	a1,s4
ffffffffc0201d52:	c85ff0ef          	jal	ra,ffffffffc02019d6 <page_insert>
ffffffffc0201d56:	66051a63          	bnez	a0,ffffffffc02023ca <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d5a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d5e:	4789                	li	a5,2
ffffffffc0201d60:	64f71563          	bne	a4,a5,ffffffffc02023aa <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201d64:	000aa783          	lw	a5,0(s5)
ffffffffc0201d68:	62079163          	bnez	a5,ffffffffc020238a <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d6c:	00093503          	ld	a0,0(s2)
ffffffffc0201d70:	4601                	li	a2,0
ffffffffc0201d72:	6585                	lui	a1,0x1
ffffffffc0201d74:	979ff0ef          	jal	ra,ffffffffc02016ec <get_pte>
ffffffffc0201d78:	5e050963          	beqz	a0,ffffffffc020236a <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d7c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d7e:	00177793          	andi	a5,a4,1
ffffffffc0201d82:	50078563          	beqz	a5,ffffffffc020228c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d86:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d88:	00271793          	slli	a5,a4,0x2
ffffffffc0201d8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d8e:	48d7f563          	bgeu	a5,a3,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d92:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d96:	97b6                	add	a5,a5,a3
ffffffffc0201d98:	000b3603          	ld	a2,0(s6)
ffffffffc0201d9c:	00379693          	slli	a3,a5,0x3
ffffffffc0201da0:	97b6                	add	a5,a5,a3
ffffffffc0201da2:	078e                	slli	a5,a5,0x3
ffffffffc0201da4:	97b2                	add	a5,a5,a2
ffffffffc0201da6:	72fa1263          	bne	s4,a5,ffffffffc02024ca <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201daa:	8b41                	andi	a4,a4,16
ffffffffc0201dac:	6e071f63          	bnez	a4,ffffffffc02024aa <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201db0:	00093503          	ld	a0,0(s2)
ffffffffc0201db4:	4581                	li	a1,0
ffffffffc0201db6:	b87ff0ef          	jal	ra,ffffffffc020193c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dba:	000a2703          	lw	a4,0(s4)
ffffffffc0201dbe:	4785                	li	a5,1
ffffffffc0201dc0:	6cf71563          	bne	a4,a5,ffffffffc020248a <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201dc4:	000aa783          	lw	a5,0(s5)
ffffffffc0201dc8:	78079d63          	bnez	a5,ffffffffc0202562 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201dcc:	00093503          	ld	a0,0(s2)
ffffffffc0201dd0:	6585                	lui	a1,0x1
ffffffffc0201dd2:	b6bff0ef          	jal	ra,ffffffffc020193c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201dd6:	000a2783          	lw	a5,0(s4)
ffffffffc0201dda:	76079463          	bnez	a5,ffffffffc0202542 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201dde:	000aa783          	lw	a5,0(s5)
ffffffffc0201de2:	74079063          	bnez	a5,ffffffffc0202522 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201de6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201dea:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dec:	000a3783          	ld	a5,0(s4)
ffffffffc0201df0:	078a                	slli	a5,a5,0x2
ffffffffc0201df2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201df4:	42c7f263          	bgeu	a5,a2,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201df8:	fff80737          	lui	a4,0xfff80
ffffffffc0201dfc:	973e                	add	a4,a4,a5
ffffffffc0201dfe:	00371793          	slli	a5,a4,0x3
ffffffffc0201e02:	000b3503          	ld	a0,0(s6)
ffffffffc0201e06:	97ba                	add	a5,a5,a4
ffffffffc0201e08:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e0a:	00f50733          	add	a4,a0,a5
ffffffffc0201e0e:	4314                	lw	a3,0(a4)
ffffffffc0201e10:	4705                	li	a4,1
ffffffffc0201e12:	6ee69863          	bne	a3,a4,ffffffffc0202502 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e16:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e1a:	00004c97          	auipc	s9,0x4
ffffffffc0201e1e:	406cbc83          	ld	s9,1030(s9) # ffffffffc0206220 <error_string+0x38>
ffffffffc0201e22:	039686b3          	mul	a3,a3,s9
ffffffffc0201e26:	000805b7          	lui	a1,0x80
ffffffffc0201e2a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e2c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e30:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e32:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e34:	6ac77b63          	bgeu	a4,a2,ffffffffc02024ea <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e38:	0009b703          	ld	a4,0(s3)
ffffffffc0201e3c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e3e:	629c                	ld	a5,0(a3)
ffffffffc0201e40:	078a                	slli	a5,a5,0x2
ffffffffc0201e42:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e44:	3cc7fa63          	bgeu	a5,a2,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e48:	8f8d                	sub	a5,a5,a1
ffffffffc0201e4a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e4e:	97ba                	add	a5,a5,a4
ffffffffc0201e50:	078e                	slli	a5,a5,0x3
ffffffffc0201e52:	953e                	add	a0,a0,a5
ffffffffc0201e54:	100027f3          	csrr	a5,sstatus
ffffffffc0201e58:	8b89                	andi	a5,a5,2
ffffffffc0201e5a:	2e079963          	bnez	a5,ffffffffc020214c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e5e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e62:	4585                	li	a1,1
ffffffffc0201e64:	739c                	ld	a5,32(a5)
ffffffffc0201e66:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e68:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e6c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e6e:	078a                	slli	a5,a5,0x2
ffffffffc0201e70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e72:	3ae7f363          	bgeu	a5,a4,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e76:	fff80737          	lui	a4,0xfff80
ffffffffc0201e7a:	97ba                	add	a5,a5,a4
ffffffffc0201e7c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e80:	00379713          	slli	a4,a5,0x3
ffffffffc0201e84:	97ba                	add	a5,a5,a4
ffffffffc0201e86:	078e                	slli	a5,a5,0x3
ffffffffc0201e88:	953e                	add	a0,a0,a5
ffffffffc0201e8a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e8e:	8b89                	andi	a5,a5,2
ffffffffc0201e90:	2a079263          	bnez	a5,ffffffffc0202134 <pmm_init+0x65e>
ffffffffc0201e94:	000bb783          	ld	a5,0(s7)
ffffffffc0201e98:	4585                	li	a1,1
ffffffffc0201e9a:	739c                	ld	a5,32(a5)
ffffffffc0201e9c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201e9e:	00093783          	ld	a5,0(s2)
ffffffffc0201ea2:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201ea6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eaa:	8b89                	andi	a5,a5,2
ffffffffc0201eac:	26079a63          	bnez	a5,ffffffffc0202120 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201eb0:	000bb783          	ld	a5,0(s7)
ffffffffc0201eb4:	779c                	ld	a5,40(a5)
ffffffffc0201eb6:	9782                	jalr	a5
ffffffffc0201eb8:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201eba:	73441463          	bne	s0,s4,ffffffffc02025e2 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ebe:	00003517          	auipc	a0,0x3
ffffffffc0201ec2:	6fa50513          	addi	a0,a0,1786 # ffffffffc02055b8 <default_pmm_manager+0x460>
ffffffffc0201ec6:	9f4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201eca:	100027f3          	csrr	a5,sstatus
ffffffffc0201ece:	8b89                	andi	a5,a5,2
ffffffffc0201ed0:	22079e63          	bnez	a5,ffffffffc020210c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ed4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ed8:	779c                	ld	a5,40(a5)
ffffffffc0201eda:	9782                	jalr	a5
ffffffffc0201edc:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ede:	6098                	ld	a4,0(s1)
ffffffffc0201ee0:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ee4:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ee6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201eea:	6a05                	lui	s4,0x1
ffffffffc0201eec:	02f47c63          	bgeu	s0,a5,ffffffffc0201f24 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ef0:	00c45793          	srli	a5,s0,0xc
ffffffffc0201ef4:	00093503          	ld	a0,0(s2)
ffffffffc0201ef8:	30e7f363          	bgeu	a5,a4,ffffffffc02021fe <pmm_init+0x728>
ffffffffc0201efc:	0009b583          	ld	a1,0(s3)
ffffffffc0201f00:	4601                	li	a2,0
ffffffffc0201f02:	95a2                	add	a1,a1,s0
ffffffffc0201f04:	fe8ff0ef          	jal	ra,ffffffffc02016ec <get_pte>
ffffffffc0201f08:	2c050b63          	beqz	a0,ffffffffc02021de <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f0c:	611c                	ld	a5,0(a0)
ffffffffc0201f0e:	078a                	slli	a5,a5,0x2
ffffffffc0201f10:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f14:	2a879563          	bne	a5,s0,ffffffffc02021be <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f18:	6098                	ld	a4,0(s1)
ffffffffc0201f1a:	9452                	add	s0,s0,s4
ffffffffc0201f1c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f20:	fcf468e3          	bltu	s0,a5,ffffffffc0201ef0 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f24:	00093783          	ld	a5,0(s2)
ffffffffc0201f28:	639c                	ld	a5,0(a5)
ffffffffc0201f2a:	68079c63          	bnez	a5,ffffffffc02025c2 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f2e:	4505                	li	a0,1
ffffffffc0201f30:	eb0ff0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0201f34:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f36:	00093503          	ld	a0,0(s2)
ffffffffc0201f3a:	4699                	li	a3,6
ffffffffc0201f3c:	10000613          	li	a2,256
ffffffffc0201f40:	85d6                	mv	a1,s5
ffffffffc0201f42:	a95ff0ef          	jal	ra,ffffffffc02019d6 <page_insert>
ffffffffc0201f46:	64051e63          	bnez	a0,ffffffffc02025a2 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f4a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201f4e:	4785                	li	a5,1
ffffffffc0201f50:	62f71963          	bne	a4,a5,ffffffffc0202582 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f54:	00093503          	ld	a0,0(s2)
ffffffffc0201f58:	6405                	lui	s0,0x1
ffffffffc0201f5a:	4699                	li	a3,6
ffffffffc0201f5c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f60:	85d6                	mv	a1,s5
ffffffffc0201f62:	a75ff0ef          	jal	ra,ffffffffc02019d6 <page_insert>
ffffffffc0201f66:	48051263          	bnez	a0,ffffffffc02023ea <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f6a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f6e:	4789                	li	a5,2
ffffffffc0201f70:	74f71563          	bne	a4,a5,ffffffffc02026ba <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f74:	00003597          	auipc	a1,0x3
ffffffffc0201f78:	77c58593          	addi	a1,a1,1916 # ffffffffc02056f0 <default_pmm_manager+0x598>
ffffffffc0201f7c:	10000513          	li	a0,256
ffffffffc0201f80:	422020ef          	jal	ra,ffffffffc02043a2 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f84:	10040593          	addi	a1,s0,256
ffffffffc0201f88:	10000513          	li	a0,256
ffffffffc0201f8c:	428020ef          	jal	ra,ffffffffc02043b4 <strcmp>
ffffffffc0201f90:	70051563          	bnez	a0,ffffffffc020269a <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f94:	000b3683          	ld	a3,0(s6)
ffffffffc0201f98:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f9c:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f9e:	40da86b3          	sub	a3,s5,a3
ffffffffc0201fa2:	868d                	srai	a3,a3,0x3
ffffffffc0201fa4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fa8:	609c                	ld	a5,0(s1)
ffffffffc0201faa:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fac:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fae:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fb2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fb4:	52f77b63          	bgeu	a4,a5,ffffffffc02024ea <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fb8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fbc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fc0:	96be                	add	a3,a3,a5
ffffffffc0201fc2:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb8c>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fc6:	3a6020ef          	jal	ra,ffffffffc020436c <strlen>
ffffffffc0201fca:	6a051863          	bnez	a0,ffffffffc020267a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fce:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fd2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fd4:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201fd8:	078a                	slli	a5,a5,0x2
ffffffffc0201fda:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fdc:	22e7fe63          	bgeu	a5,a4,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fe0:	41a787b3          	sub	a5,a5,s10
ffffffffc0201fe4:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fe8:	96be                	add	a3,a3,a5
ffffffffc0201fea:	03968cb3          	mul	s9,a3,s9
ffffffffc0201fee:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ff4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff6:	4ee47a63          	bgeu	s0,a4,ffffffffc02024ea <pmm_init+0xa14>
ffffffffc0201ffa:	0009b403          	ld	s0,0(s3)
ffffffffc0201ffe:	9436                	add	s0,s0,a3
ffffffffc0202000:	100027f3          	csrr	a5,sstatus
ffffffffc0202004:	8b89                	andi	a5,a5,2
ffffffffc0202006:	1a079163          	bnez	a5,ffffffffc02021a8 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020200a:	000bb783          	ld	a5,0(s7)
ffffffffc020200e:	4585                	li	a1,1
ffffffffc0202010:	8556                	mv	a0,s5
ffffffffc0202012:	739c                	ld	a5,32(a5)
ffffffffc0202014:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202016:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202018:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020201a:	078a                	slli	a5,a5,0x2
ffffffffc020201c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020201e:	1ee7fd63          	bgeu	a5,a4,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202022:	fff80737          	lui	a4,0xfff80
ffffffffc0202026:	97ba                	add	a5,a5,a4
ffffffffc0202028:	000b3503          	ld	a0,0(s6)
ffffffffc020202c:	00379713          	slli	a4,a5,0x3
ffffffffc0202030:	97ba                	add	a5,a5,a4
ffffffffc0202032:	078e                	slli	a5,a5,0x3
ffffffffc0202034:	953e                	add	a0,a0,a5
ffffffffc0202036:	100027f3          	csrr	a5,sstatus
ffffffffc020203a:	8b89                	andi	a5,a5,2
ffffffffc020203c:	14079a63          	bnez	a5,ffffffffc0202190 <pmm_init+0x6ba>
ffffffffc0202040:	000bb783          	ld	a5,0(s7)
ffffffffc0202044:	4585                	li	a1,1
ffffffffc0202046:	739c                	ld	a5,32(a5)
ffffffffc0202048:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020204a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020204e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202050:	078a                	slli	a5,a5,0x2
ffffffffc0202052:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202054:	1ce7f263          	bgeu	a5,a4,ffffffffc0202218 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202058:	fff80737          	lui	a4,0xfff80
ffffffffc020205c:	97ba                	add	a5,a5,a4
ffffffffc020205e:	000b3503          	ld	a0,0(s6)
ffffffffc0202062:	00379713          	slli	a4,a5,0x3
ffffffffc0202066:	97ba                	add	a5,a5,a4
ffffffffc0202068:	078e                	slli	a5,a5,0x3
ffffffffc020206a:	953e                	add	a0,a0,a5
ffffffffc020206c:	100027f3          	csrr	a5,sstatus
ffffffffc0202070:	8b89                	andi	a5,a5,2
ffffffffc0202072:	10079363          	bnez	a5,ffffffffc0202178 <pmm_init+0x6a2>
ffffffffc0202076:	000bb783          	ld	a5,0(s7)
ffffffffc020207a:	4585                	li	a1,1
ffffffffc020207c:	739c                	ld	a5,32(a5)
ffffffffc020207e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202080:	00093783          	ld	a5,0(s2)
ffffffffc0202084:	0007b023          	sd	zero,0(a5)
ffffffffc0202088:	100027f3          	csrr	a5,sstatus
ffffffffc020208c:	8b89                	andi	a5,a5,2
ffffffffc020208e:	0c079b63          	bnez	a5,ffffffffc0202164 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202092:	000bb783          	ld	a5,0(s7)
ffffffffc0202096:	779c                	ld	a5,40(a5)
ffffffffc0202098:	9782                	jalr	a5
ffffffffc020209a:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020209c:	3a8c1763          	bne	s8,s0,ffffffffc020244a <pmm_init+0x974>
}
ffffffffc02020a0:	7406                	ld	s0,96(sp)
ffffffffc02020a2:	70a6                	ld	ra,104(sp)
ffffffffc02020a4:	64e6                	ld	s1,88(sp)
ffffffffc02020a6:	6946                	ld	s2,80(sp)
ffffffffc02020a8:	69a6                	ld	s3,72(sp)
ffffffffc02020aa:	6a06                	ld	s4,64(sp)
ffffffffc02020ac:	7ae2                	ld	s5,56(sp)
ffffffffc02020ae:	7b42                	ld	s6,48(sp)
ffffffffc02020b0:	7ba2                	ld	s7,40(sp)
ffffffffc02020b2:	7c02                	ld	s8,32(sp)
ffffffffc02020b4:	6ce2                	ld	s9,24(sp)
ffffffffc02020b6:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020b8:	00003517          	auipc	a0,0x3
ffffffffc02020bc:	6b050513          	addi	a0,a0,1712 # ffffffffc0205768 <default_pmm_manager+0x610>
}
ffffffffc02020c0:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020c2:	ff9fd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020c6:	6705                	lui	a4,0x1
ffffffffc02020c8:	177d                	addi	a4,a4,-1
ffffffffc02020ca:	96ba                	add	a3,a3,a4
ffffffffc02020cc:	777d                	lui	a4,0xfffff
ffffffffc02020ce:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02020d0:	00c75693          	srli	a3,a4,0xc
ffffffffc02020d4:	14f6f263          	bgeu	a3,a5,ffffffffc0202218 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02020d8:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020dc:	95b6                	add	a1,a1,a3
ffffffffc02020de:	00359793          	slli	a5,a1,0x3
ffffffffc02020e2:	97ae                	add	a5,a5,a1
ffffffffc02020e4:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020e8:	40e60733          	sub	a4,a2,a4
ffffffffc02020ec:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020ee:	00c75593          	srli	a1,a4,0xc
ffffffffc02020f2:	953e                	add	a0,a0,a5
ffffffffc02020f4:	9682                	jalr	a3
}
ffffffffc02020f6:	bcc5                	j	ffffffffc0201be6 <pmm_init+0x110>
        intr_disable();
ffffffffc02020f8:	bf6fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020fc:	000bb783          	ld	a5,0(s7)
ffffffffc0202100:	779c                	ld	a5,40(a5)
ffffffffc0202102:	9782                	jalr	a5
ffffffffc0202104:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202106:	be2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020210a:	b63d                	j	ffffffffc0201c38 <pmm_init+0x162>
        intr_disable();
ffffffffc020210c:	be2fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202110:	000bb783          	ld	a5,0(s7)
ffffffffc0202114:	779c                	ld	a5,40(a5)
ffffffffc0202116:	9782                	jalr	a5
ffffffffc0202118:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020211a:	bcefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020211e:	b3c1                	j	ffffffffc0201ede <pmm_init+0x408>
        intr_disable();
ffffffffc0202120:	bcefe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202124:	000bb783          	ld	a5,0(s7)
ffffffffc0202128:	779c                	ld	a5,40(a5)
ffffffffc020212a:	9782                	jalr	a5
ffffffffc020212c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020212e:	bbafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202132:	b361                	j	ffffffffc0201eba <pmm_init+0x3e4>
ffffffffc0202134:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202136:	bb8fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020213a:	000bb783          	ld	a5,0(s7)
ffffffffc020213e:	6522                	ld	a0,8(sp)
ffffffffc0202140:	4585                	li	a1,1
ffffffffc0202142:	739c                	ld	a5,32(a5)
ffffffffc0202144:	9782                	jalr	a5
        intr_enable();
ffffffffc0202146:	ba2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020214a:	bb91                	j	ffffffffc0201e9e <pmm_init+0x3c8>
ffffffffc020214c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020214e:	ba0fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202152:	000bb783          	ld	a5,0(s7)
ffffffffc0202156:	6522                	ld	a0,8(sp)
ffffffffc0202158:	4585                	li	a1,1
ffffffffc020215a:	739c                	ld	a5,32(a5)
ffffffffc020215c:	9782                	jalr	a5
        intr_enable();
ffffffffc020215e:	b8afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202162:	b319                	j	ffffffffc0201e68 <pmm_init+0x392>
        intr_disable();
ffffffffc0202164:	b8afe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202168:	000bb783          	ld	a5,0(s7)
ffffffffc020216c:	779c                	ld	a5,40(a5)
ffffffffc020216e:	9782                	jalr	a5
ffffffffc0202170:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202172:	b76fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202176:	b71d                	j	ffffffffc020209c <pmm_init+0x5c6>
ffffffffc0202178:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020217a:	b74fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020217e:	000bb783          	ld	a5,0(s7)
ffffffffc0202182:	6522                	ld	a0,8(sp)
ffffffffc0202184:	4585                	li	a1,1
ffffffffc0202186:	739c                	ld	a5,32(a5)
ffffffffc0202188:	9782                	jalr	a5
        intr_enable();
ffffffffc020218a:	b5efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020218e:	bdcd                	j	ffffffffc0202080 <pmm_init+0x5aa>
ffffffffc0202190:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202192:	b5cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202196:	000bb783          	ld	a5,0(s7)
ffffffffc020219a:	6522                	ld	a0,8(sp)
ffffffffc020219c:	4585                	li	a1,1
ffffffffc020219e:	739c                	ld	a5,32(a5)
ffffffffc02021a0:	9782                	jalr	a5
        intr_enable();
ffffffffc02021a2:	b46fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021a6:	b555                	j	ffffffffc020204a <pmm_init+0x574>
        intr_disable();
ffffffffc02021a8:	b46fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021ac:	000bb783          	ld	a5,0(s7)
ffffffffc02021b0:	4585                	li	a1,1
ffffffffc02021b2:	8556                	mv	a0,s5
ffffffffc02021b4:	739c                	ld	a5,32(a5)
ffffffffc02021b6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021b8:	b30fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021bc:	bda9                	j	ffffffffc0202016 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	45a68693          	addi	a3,a3,1114 # ffffffffc0205618 <default_pmm_manager+0x4c0>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	be260613          	addi	a2,a2,-1054 # ffffffffc0204da8 <commands+0x738>
ffffffffc02021ce:	1ce00593          	li	a1,462
ffffffffc02021d2:	00003517          	auipc	a0,0x3
ffffffffc02021d6:	03e50513          	addi	a0,a0,62 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02021da:	99afe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02021de:	00003697          	auipc	a3,0x3
ffffffffc02021e2:	3fa68693          	addi	a3,a3,1018 # ffffffffc02055d8 <default_pmm_manager+0x480>
ffffffffc02021e6:	00003617          	auipc	a2,0x3
ffffffffc02021ea:	bc260613          	addi	a2,a2,-1086 # ffffffffc0204da8 <commands+0x738>
ffffffffc02021ee:	1cd00593          	li	a1,461
ffffffffc02021f2:	00003517          	auipc	a0,0x3
ffffffffc02021f6:	01e50513          	addi	a0,a0,30 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02021fa:	97afe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02021fe:	86a2                	mv	a3,s0
ffffffffc0202200:	00003617          	auipc	a2,0x3
ffffffffc0202204:	fe860613          	addi	a2,a2,-24 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc0202208:	1cd00593          	li	a1,461
ffffffffc020220c:	00003517          	auipc	a0,0x3
ffffffffc0202210:	00450513          	addi	a0,a0,4 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202214:	960fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202218:	b90ff0ef          	jal	ra,ffffffffc02015a8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020221c:	00003617          	auipc	a2,0x3
ffffffffc0202220:	08c60613          	addi	a2,a2,140 # ffffffffc02052a8 <default_pmm_manager+0x150>
ffffffffc0202224:	07700593          	li	a1,119
ffffffffc0202228:	00003517          	auipc	a0,0x3
ffffffffc020222c:	fe850513          	addi	a0,a0,-24 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202230:	944fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202234:	00003617          	auipc	a2,0x3
ffffffffc0202238:	07460613          	addi	a2,a2,116 # ffffffffc02052a8 <default_pmm_manager+0x150>
ffffffffc020223c:	0bd00593          	li	a1,189
ffffffffc0202240:	00003517          	auipc	a0,0x3
ffffffffc0202244:	fd050513          	addi	a0,a0,-48 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202248:	92cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020224c:	00003697          	auipc	a3,0x3
ffffffffc0202250:	0c468693          	addi	a3,a3,196 # ffffffffc0205310 <default_pmm_manager+0x1b8>
ffffffffc0202254:	00003617          	auipc	a2,0x3
ffffffffc0202258:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204da8 <commands+0x738>
ffffffffc020225c:	19300593          	li	a1,403
ffffffffc0202260:	00003517          	auipc	a0,0x3
ffffffffc0202264:	fb050513          	addi	a0,a0,-80 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202268:	90cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020226c:	00003697          	auipc	a3,0x3
ffffffffc0202270:	08468693          	addi	a3,a3,132 # ffffffffc02052f0 <default_pmm_manager+0x198>
ffffffffc0202274:	00003617          	auipc	a2,0x3
ffffffffc0202278:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204da8 <commands+0x738>
ffffffffc020227c:	19200593          	li	a1,402
ffffffffc0202280:	00003517          	auipc	a0,0x3
ffffffffc0202284:	f9050513          	addi	a0,a0,-112 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202288:	8ecfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020228c:	b38ff0ef          	jal	ra,ffffffffc02015c4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202290:	00003697          	auipc	a3,0x3
ffffffffc0202294:	11068693          	addi	a3,a3,272 # ffffffffc02053a0 <default_pmm_manager+0x248>
ffffffffc0202298:	00003617          	auipc	a2,0x3
ffffffffc020229c:	b1060613          	addi	a2,a2,-1264 # ffffffffc0204da8 <commands+0x738>
ffffffffc02022a0:	19a00593          	li	a1,410
ffffffffc02022a4:	00003517          	auipc	a0,0x3
ffffffffc02022a8:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02022ac:	8c8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02022b0:	00003697          	auipc	a3,0x3
ffffffffc02022b4:	0c068693          	addi	a3,a3,192 # ffffffffc0205370 <default_pmm_manager+0x218>
ffffffffc02022b8:	00003617          	auipc	a2,0x3
ffffffffc02022bc:	af060613          	addi	a2,a2,-1296 # ffffffffc0204da8 <commands+0x738>
ffffffffc02022c0:	19800593          	li	a1,408
ffffffffc02022c4:	00003517          	auipc	a0,0x3
ffffffffc02022c8:	f4c50513          	addi	a0,a0,-180 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02022cc:	8a8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02022d0:	00003697          	auipc	a3,0x3
ffffffffc02022d4:	07868693          	addi	a3,a3,120 # ffffffffc0205348 <default_pmm_manager+0x1f0>
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	ad060613          	addi	a2,a2,-1328 # ffffffffc0204da8 <commands+0x738>
ffffffffc02022e0:	19400593          	li	a1,404
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	f2c50513          	addi	a0,a0,-212 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02022ec:	888fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022f0:	00003697          	auipc	a3,0x3
ffffffffc02022f4:	13868693          	addi	a3,a3,312 # ffffffffc0205428 <default_pmm_manager+0x2d0>
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202300:	1a300593          	li	a1,419
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	f0c50513          	addi	a0,a0,-244 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020230c:	868fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202310:	00003697          	auipc	a3,0x3
ffffffffc0202314:	1b868693          	addi	a3,a3,440 # ffffffffc02054c8 <default_pmm_manager+0x370>
ffffffffc0202318:	00003617          	auipc	a2,0x3
ffffffffc020231c:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202320:	1a800593          	li	a1,424
ffffffffc0202324:	00003517          	auipc	a0,0x3
ffffffffc0202328:	eec50513          	addi	a0,a0,-276 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020232c:	848fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202330:	00003697          	auipc	a3,0x3
ffffffffc0202334:	0d068693          	addi	a3,a3,208 # ffffffffc0205400 <default_pmm_manager+0x2a8>
ffffffffc0202338:	00003617          	auipc	a2,0x3
ffffffffc020233c:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202340:	1a000593          	li	a1,416
ffffffffc0202344:	00003517          	auipc	a0,0x3
ffffffffc0202348:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020234c:	828fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202350:	86d6                	mv	a3,s5
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	e9660613          	addi	a2,a2,-362 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc020235a:	19f00593          	li	a1,415
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	eb250513          	addi	a0,a0,-334 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	0f668693          	addi	a3,a3,246 # ffffffffc0205460 <default_pmm_manager+0x308>
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	a3660613          	addi	a2,a2,-1482 # ffffffffc0204da8 <commands+0x738>
ffffffffc020237a:	1ad00593          	li	a1,429
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	e9250513          	addi	a0,a0,-366 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	19e68693          	addi	a3,a3,414 # ffffffffc0205528 <default_pmm_manager+0x3d0>
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	a1660613          	addi	a2,a2,-1514 # ffffffffc0204da8 <commands+0x738>
ffffffffc020239a:	1ac00593          	li	a1,428
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	e7250513          	addi	a0,a0,-398 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	16668693          	addi	a3,a3,358 # ffffffffc0205510 <default_pmm_manager+0x3b8>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	9f660613          	addi	a2,a2,-1546 # ffffffffc0204da8 <commands+0x738>
ffffffffc02023ba:	1ab00593          	li	a1,427
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	e5250513          	addi	a0,a0,-430 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	11668693          	addi	a3,a3,278 # ffffffffc02054e0 <default_pmm_manager+0x388>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	9d660613          	addi	a2,a2,-1578 # ffffffffc0204da8 <commands+0x738>
ffffffffc02023da:	1aa00593          	li	a1,426
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	e3250513          	addi	a0,a0,-462 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	2ae68693          	addi	a3,a3,686 # ffffffffc0205698 <default_pmm_manager+0x540>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	9b660613          	addi	a2,a2,-1610 # ffffffffc0204da8 <commands+0x738>
ffffffffc02023fa:	1d800593          	li	a1,472
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	e1250513          	addi	a0,a0,-494 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	0a668693          	addi	a3,a3,166 # ffffffffc02054b0 <default_pmm_manager+0x358>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	99660613          	addi	a2,a2,-1642 # ffffffffc0204da8 <commands+0x738>
ffffffffc020241a:	1a700593          	li	a1,423
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	df250513          	addi	a0,a0,-526 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	07668693          	addi	a3,a3,118 # ffffffffc02054a0 <default_pmm_manager+0x348>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	97660613          	addi	a2,a2,-1674 # ffffffffc0204da8 <commands+0x738>
ffffffffc020243a:	1a600593          	li	a1,422
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	dd250513          	addi	a0,a0,-558 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	14e68693          	addi	a3,a3,334 # ffffffffc0205598 <default_pmm_manager+0x440>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	95660613          	addi	a2,a2,-1706 # ffffffffc0204da8 <commands+0x738>
ffffffffc020245a:	1e800593          	li	a1,488
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	db250513          	addi	a0,a0,-590 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	02668693          	addi	a3,a3,38 # ffffffffc0205490 <default_pmm_manager+0x338>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	93660613          	addi	a2,a2,-1738 # ffffffffc0204da8 <commands+0x738>
ffffffffc020247a:	1a500593          	li	a1,421
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	d9250513          	addi	a0,a0,-622 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	f5e68693          	addi	a3,a3,-162 # ffffffffc02053e8 <default_pmm_manager+0x290>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	91660613          	addi	a2,a2,-1770 # ffffffffc0204da8 <commands+0x738>
ffffffffc020249a:	1b200593          	li	a1,434
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	d7250513          	addi	a0,a0,-654 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	09668693          	addi	a3,a3,150 # ffffffffc0205540 <default_pmm_manager+0x3e8>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204da8 <commands+0x738>
ffffffffc02024ba:	1af00593          	li	a1,431
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	d5250513          	addi	a0,a0,-686 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	f0668693          	addi	a3,a3,-250 # ffffffffc02053d0 <default_pmm_manager+0x278>
ffffffffc02024d2:	00003617          	auipc	a2,0x3
ffffffffc02024d6:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204da8 <commands+0x738>
ffffffffc02024da:	1ae00593          	li	a1,430
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	d3250513          	addi	a0,a0,-718 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02024ea:	00003617          	auipc	a2,0x3
ffffffffc02024ee:	cfe60613          	addi	a2,a2,-770 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc02024f2:	06a00593          	li	a1,106
ffffffffc02024f6:	00003517          	auipc	a0,0x3
ffffffffc02024fa:	cba50513          	addi	a0,a0,-838 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc02024fe:	e77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202502:	00003697          	auipc	a3,0x3
ffffffffc0202506:	06e68693          	addi	a3,a3,110 # ffffffffc0205570 <default_pmm_manager+0x418>
ffffffffc020250a:	00003617          	auipc	a2,0x3
ffffffffc020250e:	89e60613          	addi	a2,a2,-1890 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202512:	1b900593          	li	a1,441
ffffffffc0202516:	00003517          	auipc	a0,0x3
ffffffffc020251a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020251e:	e57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202522:	00003697          	auipc	a3,0x3
ffffffffc0202526:	00668693          	addi	a3,a3,6 # ffffffffc0205528 <default_pmm_manager+0x3d0>
ffffffffc020252a:	00003617          	auipc	a2,0x3
ffffffffc020252e:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202532:	1b700593          	li	a1,439
ffffffffc0202536:	00003517          	auipc	a0,0x3
ffffffffc020253a:	cda50513          	addi	a0,a0,-806 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020253e:	e37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202542:	00003697          	auipc	a3,0x3
ffffffffc0202546:	01668693          	addi	a3,a3,22 # ffffffffc0205558 <default_pmm_manager+0x400>
ffffffffc020254a:	00003617          	auipc	a2,0x3
ffffffffc020254e:	85e60613          	addi	a2,a2,-1954 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202552:	1b600593          	li	a1,438
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	cba50513          	addi	a0,a0,-838 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020255e:	e17fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202562:	00003697          	auipc	a3,0x3
ffffffffc0202566:	fc668693          	addi	a3,a3,-58 # ffffffffc0205528 <default_pmm_manager+0x3d0>
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	83e60613          	addi	a2,a2,-1986 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202572:	1b300593          	li	a1,435
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	c9a50513          	addi	a0,a0,-870 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020257e:	df7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	0fe68693          	addi	a3,a3,254 # ffffffffc0205680 <default_pmm_manager+0x528>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	81e60613          	addi	a2,a2,-2018 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202592:	1d700593          	li	a1,471
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	0a668693          	addi	a3,a3,166 # ffffffffc0205648 <default_pmm_manager+0x4f0>
ffffffffc02025aa:	00002617          	auipc	a2,0x2
ffffffffc02025ae:	7fe60613          	addi	a2,a2,2046 # ffffffffc0204da8 <commands+0x738>
ffffffffc02025b2:	1d600593          	li	a1,470
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	c5a50513          	addi	a0,a0,-934 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	06e68693          	addi	a3,a3,110 # ffffffffc0205630 <default_pmm_manager+0x4d8>
ffffffffc02025ca:	00002617          	auipc	a2,0x2
ffffffffc02025ce:	7de60613          	addi	a2,a2,2014 # ffffffffc0204da8 <commands+0x738>
ffffffffc02025d2:	1d200593          	li	a1,466
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	c3a50513          	addi	a0,a0,-966 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	fb668693          	addi	a3,a3,-74 # ffffffffc0205598 <default_pmm_manager+0x440>
ffffffffc02025ea:	00002617          	auipc	a2,0x2
ffffffffc02025ee:	7be60613          	addi	a2,a2,1982 # ffffffffc0204da8 <commands+0x738>
ffffffffc02025f2:	1c000593          	li	a1,448
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	c1a50513          	addi	a0,a0,-998 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	dce68693          	addi	a3,a3,-562 # ffffffffc02053d0 <default_pmm_manager+0x278>
ffffffffc020260a:	00002617          	auipc	a2,0x2
ffffffffc020260e:	79e60613          	addi	a2,a2,1950 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202612:	19b00593          	li	a1,411
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020261e:	d57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202622:	00003617          	auipc	a2,0x3
ffffffffc0202626:	bc660613          	addi	a2,a2,-1082 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc020262a:	19e00593          	li	a1,414
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	be250513          	addi	a0,a0,-1054 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202636:	d3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020263a:	00003697          	auipc	a3,0x3
ffffffffc020263e:	dae68693          	addi	a3,a3,-594 # ffffffffc02053e8 <default_pmm_manager+0x290>
ffffffffc0202642:	00002617          	auipc	a2,0x2
ffffffffc0202646:	76660613          	addi	a2,a2,1894 # ffffffffc0204da8 <commands+0x738>
ffffffffc020264a:	19c00593          	li	a1,412
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	bc250513          	addi	a0,a0,-1086 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202656:	d1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020265a:	00003697          	auipc	a3,0x3
ffffffffc020265e:	e0668693          	addi	a3,a3,-506 # ffffffffc0205460 <default_pmm_manager+0x308>
ffffffffc0202662:	00002617          	auipc	a2,0x2
ffffffffc0202666:	74660613          	addi	a2,a2,1862 # ffffffffc0204da8 <commands+0x738>
ffffffffc020266a:	1a400593          	li	a1,420
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	ba250513          	addi	a0,a0,-1118 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202676:	cfffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020267a:	00003697          	auipc	a3,0x3
ffffffffc020267e:	0c668693          	addi	a3,a3,198 # ffffffffc0205740 <default_pmm_manager+0x5e8>
ffffffffc0202682:	00002617          	auipc	a2,0x2
ffffffffc0202686:	72660613          	addi	a2,a2,1830 # ffffffffc0204da8 <commands+0x738>
ffffffffc020268a:	1e000593          	li	a1,480
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	b8250513          	addi	a0,a0,-1150 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202696:	cdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020269a:	00003697          	auipc	a3,0x3
ffffffffc020269e:	06e68693          	addi	a3,a3,110 # ffffffffc0205708 <default_pmm_manager+0x5b0>
ffffffffc02026a2:	00002617          	auipc	a2,0x2
ffffffffc02026a6:	70660613          	addi	a2,a2,1798 # ffffffffc0204da8 <commands+0x738>
ffffffffc02026aa:	1dd00593          	li	a1,477
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	b6250513          	addi	a0,a0,-1182 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02026b6:	cbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02026ba:	00003697          	auipc	a3,0x3
ffffffffc02026be:	01e68693          	addi	a3,a3,30 # ffffffffc02056d8 <default_pmm_manager+0x580>
ffffffffc02026c2:	00002617          	auipc	a2,0x2
ffffffffc02026c6:	6e660613          	addi	a2,a2,1766 # ffffffffc0204da8 <commands+0x738>
ffffffffc02026ca:	1d900593          	li	a1,473
ffffffffc02026ce:	00003517          	auipc	a0,0x3
ffffffffc02026d2:	b4250513          	addi	a0,a0,-1214 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc02026d6:	c9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02026da <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02026da:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02026de:	8082                	ret

ffffffffc02026e0 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026e0:	7179                	addi	sp,sp,-48
ffffffffc02026e2:	e84a                	sd	s2,16(sp)
ffffffffc02026e4:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02026e6:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026e8:	f022                	sd	s0,32(sp)
ffffffffc02026ea:	ec26                	sd	s1,24(sp)
ffffffffc02026ec:	e44e                	sd	s3,8(sp)
ffffffffc02026ee:	f406                	sd	ra,40(sp)
ffffffffc02026f0:	84ae                	mv	s1,a1
ffffffffc02026f2:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02026f4:	eedfe0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc02026f8:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02026fa:	cd09                	beqz	a0,ffffffffc0202714 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02026fc:	85aa                	mv	a1,a0
ffffffffc02026fe:	86ce                	mv	a3,s3
ffffffffc0202700:	8626                	mv	a2,s1
ffffffffc0202702:	854a                	mv	a0,s2
ffffffffc0202704:	ad2ff0ef          	jal	ra,ffffffffc02019d6 <page_insert>
ffffffffc0202708:	ed21                	bnez	a0,ffffffffc0202760 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020270a:	0000f797          	auipc	a5,0xf
ffffffffc020270e:	e4e7a783          	lw	a5,-434(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0202712:	eb89                	bnez	a5,ffffffffc0202724 <pgdir_alloc_page+0x44>
}
ffffffffc0202714:	70a2                	ld	ra,40(sp)
ffffffffc0202716:	8522                	mv	a0,s0
ffffffffc0202718:	7402                	ld	s0,32(sp)
ffffffffc020271a:	64e2                	ld	s1,24(sp)
ffffffffc020271c:	6942                	ld	s2,16(sp)
ffffffffc020271e:	69a2                	ld	s3,8(sp)
ffffffffc0202720:	6145                	addi	sp,sp,48
ffffffffc0202722:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202724:	4681                	li	a3,0
ffffffffc0202726:	8622                	mv	a2,s0
ffffffffc0202728:	85a6                	mv	a1,s1
ffffffffc020272a:	0000f517          	auipc	a0,0xf
ffffffffc020272e:	e3e53503          	ld	a0,-450(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0202732:	07f000ef          	jal	ra,ffffffffc0202fb0 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202736:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202738:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020273a:	4785                	li	a5,1
ffffffffc020273c:	fcf70ce3          	beq	a4,a5,ffffffffc0202714 <pgdir_alloc_page+0x34>
ffffffffc0202740:	00003697          	auipc	a3,0x3
ffffffffc0202744:	04868693          	addi	a3,a3,72 # ffffffffc0205788 <default_pmm_manager+0x630>
ffffffffc0202748:	00002617          	auipc	a2,0x2
ffffffffc020274c:	66060613          	addi	a2,a2,1632 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202750:	17a00593          	li	a1,378
ffffffffc0202754:	00003517          	auipc	a0,0x3
ffffffffc0202758:	abc50513          	addi	a0,a0,-1348 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020275c:	c19fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202760:	100027f3          	csrr	a5,sstatus
ffffffffc0202764:	8b89                	andi	a5,a5,2
ffffffffc0202766:	eb99                	bnez	a5,ffffffffc020277c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202768:	0000f797          	auipc	a5,0xf
ffffffffc020276c:	dd07b783          	ld	a5,-560(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0202770:	739c                	ld	a5,32(a5)
ffffffffc0202772:	8522                	mv	a0,s0
ffffffffc0202774:	4585                	li	a1,1
ffffffffc0202776:	9782                	jalr	a5
            return NULL;
ffffffffc0202778:	4401                	li	s0,0
ffffffffc020277a:	bf69                	j	ffffffffc0202714 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020277c:	d73fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202780:	0000f797          	auipc	a5,0xf
ffffffffc0202784:	db87b783          	ld	a5,-584(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0202788:	739c                	ld	a5,32(a5)
ffffffffc020278a:	8522                	mv	a0,s0
ffffffffc020278c:	4585                	li	a1,1
ffffffffc020278e:	9782                	jalr	a5
            return NULL;
ffffffffc0202790:	4401                	li	s0,0
        intr_enable();
ffffffffc0202792:	d57fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202796:	bfbd                	j	ffffffffc0202714 <pgdir_alloc_page+0x34>

ffffffffc0202798 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0202798:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020279a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020279c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020279e:	fff50713          	addi	a4,a0,-1
ffffffffc02027a2:	17f9                	addi	a5,a5,-2
ffffffffc02027a4:	04e7ea63          	bltu	a5,a4,ffffffffc02027f8 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027a8:	6785                	lui	a5,0x1
ffffffffc02027aa:	17fd                	addi	a5,a5,-1
ffffffffc02027ac:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027ae:	8131                	srli	a0,a0,0xc
ffffffffc02027b0:	e31fe0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
    assert(base != NULL);
ffffffffc02027b4:	cd3d                	beqz	a0,ffffffffc0202832 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027b6:	0000f797          	auipc	a5,0xf
ffffffffc02027ba:	d7a7b783          	ld	a5,-646(a5) # ffffffffc0211530 <pages>
ffffffffc02027be:	8d1d                	sub	a0,a0,a5
ffffffffc02027c0:	00004697          	auipc	a3,0x4
ffffffffc02027c4:	a606b683          	ld	a3,-1440(a3) # ffffffffc0206220 <error_string+0x38>
ffffffffc02027c8:	850d                	srai	a0,a0,0x3
ffffffffc02027ca:	02d50533          	mul	a0,a0,a3
ffffffffc02027ce:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027d2:	0000f717          	auipc	a4,0xf
ffffffffc02027d6:	d5673703          	ld	a4,-682(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027da:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027dc:	00c51793          	slli	a5,a0,0xc
ffffffffc02027e0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02027e2:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027e4:	02e7fa63          	bgeu	a5,a4,ffffffffc0202818 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02027e8:	60a2                	ld	ra,8(sp)
ffffffffc02027ea:	0000f797          	auipc	a5,0xf
ffffffffc02027ee:	d567b783          	ld	a5,-682(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc02027f2:	953e                	add	a0,a0,a5
ffffffffc02027f4:	0141                	addi	sp,sp,16
ffffffffc02027f6:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027f8:	00003697          	auipc	a3,0x3
ffffffffc02027fc:	fa868693          	addi	a3,a3,-88 # ffffffffc02057a0 <default_pmm_manager+0x648>
ffffffffc0202800:	00002617          	auipc	a2,0x2
ffffffffc0202804:	5a860613          	addi	a2,a2,1448 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202808:	1f000593          	li	a1,496
ffffffffc020280c:	00003517          	auipc	a0,0x3
ffffffffc0202810:	a0450513          	addi	a0,a0,-1532 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202814:	b61fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202818:	86aa                	mv	a3,a0
ffffffffc020281a:	00003617          	auipc	a2,0x3
ffffffffc020281e:	9ce60613          	addi	a2,a2,-1586 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc0202822:	06a00593          	li	a1,106
ffffffffc0202826:	00003517          	auipc	a0,0x3
ffffffffc020282a:	98a50513          	addi	a0,a0,-1654 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc020282e:	b47fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc0202832:	00003697          	auipc	a3,0x3
ffffffffc0202836:	f8e68693          	addi	a3,a3,-114 # ffffffffc02057c0 <default_pmm_manager+0x668>
ffffffffc020283a:	00002617          	auipc	a2,0x2
ffffffffc020283e:	56e60613          	addi	a2,a2,1390 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202842:	1f300593          	li	a1,499
ffffffffc0202846:	00003517          	auipc	a0,0x3
ffffffffc020284a:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc020284e:	b27fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202852 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202852:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202854:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202856:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202858:	fff58713          	addi	a4,a1,-1
ffffffffc020285c:	17f9                	addi	a5,a5,-2
ffffffffc020285e:	0ae7ee63          	bltu	a5,a4,ffffffffc020291a <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202862:	cd41                	beqz	a0,ffffffffc02028fa <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202864:	6785                	lui	a5,0x1
ffffffffc0202866:	17fd                	addi	a5,a5,-1
ffffffffc0202868:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020286a:	c02007b7          	lui	a5,0xc0200
ffffffffc020286e:	81b1                	srli	a1,a1,0xc
ffffffffc0202870:	06f56863          	bltu	a0,a5,ffffffffc02028e0 <kfree+0x8e>
ffffffffc0202874:	0000f697          	auipc	a3,0xf
ffffffffc0202878:	ccc6b683          	ld	a3,-820(a3) # ffffffffc0211540 <va_pa_offset>
ffffffffc020287c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020287e:	8131                	srli	a0,a0,0xc
ffffffffc0202880:	0000f797          	auipc	a5,0xf
ffffffffc0202884:	ca87b783          	ld	a5,-856(a5) # ffffffffc0211528 <npage>
ffffffffc0202888:	04f57a63          	bgeu	a0,a5,ffffffffc02028dc <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020288c:	fff806b7          	lui	a3,0xfff80
ffffffffc0202890:	9536                	add	a0,a0,a3
ffffffffc0202892:	00351793          	slli	a5,a0,0x3
ffffffffc0202896:	953e                	add	a0,a0,a5
ffffffffc0202898:	050e                	slli	a0,a0,0x3
ffffffffc020289a:	0000f797          	auipc	a5,0xf
ffffffffc020289e:	c967b783          	ld	a5,-874(a5) # ffffffffc0211530 <pages>
ffffffffc02028a2:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028a4:	100027f3          	csrr	a5,sstatus
ffffffffc02028a8:	8b89                	andi	a5,a5,2
ffffffffc02028aa:	eb89                	bnez	a5,ffffffffc02028bc <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02028ac:	0000f797          	auipc	a5,0xf
ffffffffc02028b0:	c8c7b783          	ld	a5,-884(a5) # ffffffffc0211538 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02028b4:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02028b6:	739c                	ld	a5,32(a5)
}
ffffffffc02028b8:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02028ba:	8782                	jr	a5
        intr_disable();
ffffffffc02028bc:	e42a                	sd	a0,8(sp)
ffffffffc02028be:	e02e                	sd	a1,0(sp)
ffffffffc02028c0:	c2ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02028c4:	0000f797          	auipc	a5,0xf
ffffffffc02028c8:	c747b783          	ld	a5,-908(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02028cc:	6582                	ld	a1,0(sp)
ffffffffc02028ce:	6522                	ld	a0,8(sp)
ffffffffc02028d0:	739c                	ld	a5,32(a5)
ffffffffc02028d2:	9782                	jalr	a5
}
ffffffffc02028d4:	60e2                	ld	ra,24(sp)
ffffffffc02028d6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02028d8:	c11fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02028dc:	ccdfe0ef          	jal	ra,ffffffffc02015a8 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028e0:	86aa                	mv	a3,a0
ffffffffc02028e2:	00003617          	auipc	a2,0x3
ffffffffc02028e6:	9c660613          	addi	a2,a2,-1594 # ffffffffc02052a8 <default_pmm_manager+0x150>
ffffffffc02028ea:	06c00593          	li	a1,108
ffffffffc02028ee:	00003517          	auipc	a0,0x3
ffffffffc02028f2:	8c250513          	addi	a0,a0,-1854 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc02028f6:	a7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc02028fa:	00003697          	auipc	a3,0x3
ffffffffc02028fe:	ed668693          	addi	a3,a3,-298 # ffffffffc02057d0 <default_pmm_manager+0x678>
ffffffffc0202902:	00002617          	auipc	a2,0x2
ffffffffc0202906:	4a660613          	addi	a2,a2,1190 # ffffffffc0204da8 <commands+0x738>
ffffffffc020290a:	1fa00593          	li	a1,506
ffffffffc020290e:	00003517          	auipc	a0,0x3
ffffffffc0202912:	90250513          	addi	a0,a0,-1790 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202916:	a5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020291a:	00003697          	auipc	a3,0x3
ffffffffc020291e:	e8668693          	addi	a3,a3,-378 # ffffffffc02057a0 <default_pmm_manager+0x648>
ffffffffc0202922:	00002617          	auipc	a2,0x2
ffffffffc0202926:	48660613          	addi	a2,a2,1158 # ffffffffc0204da8 <commands+0x738>
ffffffffc020292a:	1f900593          	li	a1,505
ffffffffc020292e:	00003517          	auipc	a0,0x3
ffffffffc0202932:	8e250513          	addi	a0,a0,-1822 # ffffffffc0205210 <default_pmm_manager+0xb8>
ffffffffc0202936:	a3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020293a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020293a:	7135                	addi	sp,sp,-160
ffffffffc020293c:	ed06                	sd	ra,152(sp)
ffffffffc020293e:	e922                	sd	s0,144(sp)
ffffffffc0202940:	e526                	sd	s1,136(sp)
ffffffffc0202942:	e14a                	sd	s2,128(sp)
ffffffffc0202944:	fcce                	sd	s3,120(sp)
ffffffffc0202946:	f8d2                	sd	s4,112(sp)
ffffffffc0202948:	f4d6                	sd	s5,104(sp)
ffffffffc020294a:	f0da                	sd	s6,96(sp)
ffffffffc020294c:	ecde                	sd	s7,88(sp)
ffffffffc020294e:	e8e2                	sd	s8,80(sp)
ffffffffc0202950:	e4e6                	sd	s9,72(sp)
ffffffffc0202952:	e0ea                	sd	s10,64(sp)
ffffffffc0202954:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202956:	408010ef          	jal	ra,ffffffffc0203d5e <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020295a:	0000f697          	auipc	a3,0xf
ffffffffc020295e:	bee6b683          	ld	a3,-1042(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc0202962:	010007b7          	lui	a5,0x1000
ffffffffc0202966:	ff968713          	addi	a4,a3,-7
ffffffffc020296a:	17e1                	addi	a5,a5,-8
ffffffffc020296c:	3ee7e063          	bltu	a5,a4,ffffffffc0202d4c <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202970:	00007797          	auipc	a5,0x7
ffffffffc0202974:	69078793          	addi	a5,a5,1680 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0202978:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020297a:	0000fb17          	auipc	s6,0xf
ffffffffc020297e:	bd6b0b13          	addi	s6,s6,-1066 # ffffffffc0211550 <sm>
ffffffffc0202982:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202986:	9702                	jalr	a4
ffffffffc0202988:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc020298a:	c10d                	beqz	a0,ffffffffc02029ac <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020298c:	60ea                	ld	ra,152(sp)
ffffffffc020298e:	644a                	ld	s0,144(sp)
ffffffffc0202990:	64aa                	ld	s1,136(sp)
ffffffffc0202992:	690a                	ld	s2,128(sp)
ffffffffc0202994:	7a46                	ld	s4,112(sp)
ffffffffc0202996:	7aa6                	ld	s5,104(sp)
ffffffffc0202998:	7b06                	ld	s6,96(sp)
ffffffffc020299a:	6be6                	ld	s7,88(sp)
ffffffffc020299c:	6c46                	ld	s8,80(sp)
ffffffffc020299e:	6ca6                	ld	s9,72(sp)
ffffffffc02029a0:	6d06                	ld	s10,64(sp)
ffffffffc02029a2:	7de2                	ld	s11,56(sp)
ffffffffc02029a4:	854e                	mv	a0,s3
ffffffffc02029a6:	79e6                	ld	s3,120(sp)
ffffffffc02029a8:	610d                	addi	sp,sp,160
ffffffffc02029aa:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029ac:	000b3783          	ld	a5,0(s6)
ffffffffc02029b0:	00003517          	auipc	a0,0x3
ffffffffc02029b4:	e6050513          	addi	a0,a0,-416 # ffffffffc0205810 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc02029b8:	0000e497          	auipc	s1,0xe
ffffffffc02029bc:	68848493          	addi	s1,s1,1672 # ffffffffc0211040 <free_area>
ffffffffc02029c0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02029c2:	4785                	li	a5,1
ffffffffc02029c4:	0000f717          	auipc	a4,0xf
ffffffffc02029c8:	b8f72a23          	sw	a5,-1132(a4) # ffffffffc0211558 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029cc:	eeefd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029d0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02029d2:	4401                	li	s0,0
ffffffffc02029d4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029d6:	2c978163          	beq	a5,s1,ffffffffc0202c98 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02029da:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02029de:	8b09                	andi	a4,a4,2
ffffffffc02029e0:	2a070e63          	beqz	a4,ffffffffc0202c9c <swap_init+0x362>
        count ++, total += p->property;
ffffffffc02029e4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029e8:	679c                	ld	a5,8(a5)
ffffffffc02029ea:	2d05                	addiw	s10,s10,1
ffffffffc02029ec:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029ee:	fe9796e3          	bne	a5,s1,ffffffffc02029da <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02029f2:	8922                	mv	s2,s0
ffffffffc02029f4:	cbffe0ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
ffffffffc02029f8:	47251663          	bne	a0,s2,ffffffffc0202e64 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02029fc:	8622                	mv	a2,s0
ffffffffc02029fe:	85ea                	mv	a1,s10
ffffffffc0202a00:	00003517          	auipc	a0,0x3
ffffffffc0202a04:	e2850513          	addi	a0,a0,-472 # ffffffffc0205828 <default_pmm_manager+0x6d0>
ffffffffc0202a08:	eb2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202a0c:	2cf000ef          	jal	ra,ffffffffc02034da <mm_create>
ffffffffc0202a10:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202a12:	52050963          	beqz	a0,ffffffffc0202f44 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a16:	0000f797          	auipc	a5,0xf
ffffffffc0202a1a:	b5278793          	addi	a5,a5,-1198 # ffffffffc0211568 <check_mm_struct>
ffffffffc0202a1e:	6398                	ld	a4,0(a5)
ffffffffc0202a20:	54071263          	bnez	a4,ffffffffc0202f64 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a24:	0000fb97          	auipc	s7,0xf
ffffffffc0202a28:	afcbbb83          	ld	s7,-1284(s7) # ffffffffc0211520 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a2c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a30:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a32:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a36:	3c071763          	bnez	a4,ffffffffc0202e04 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a3a:	6599                	lui	a1,0x6
ffffffffc0202a3c:	460d                	li	a2,3
ffffffffc0202a3e:	6505                	lui	a0,0x1
ffffffffc0202a40:	2e3000ef          	jal	ra,ffffffffc0203522 <vma_create>
ffffffffc0202a44:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a46:	3c050f63          	beqz	a0,ffffffffc0202e24 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a4a:	8556                	mv	a0,s5
ffffffffc0202a4c:	345000ef          	jal	ra,ffffffffc0203590 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a50:	00003517          	auipc	a0,0x3
ffffffffc0202a54:	e4850513          	addi	a0,a0,-440 # ffffffffc0205898 <default_pmm_manager+0x740>
ffffffffc0202a58:	e62fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a5c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a60:	4605                	li	a2,1
ffffffffc0202a62:	6585                	lui	a1,0x1
ffffffffc0202a64:	c89fe0ef          	jal	ra,ffffffffc02016ec <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202a68:	3c050e63          	beqz	a0,ffffffffc0202e44 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a6c:	00003517          	auipc	a0,0x3
ffffffffc0202a70:	e7c50513          	addi	a0,a0,-388 # ffffffffc02058e8 <default_pmm_manager+0x790>
ffffffffc0202a74:	0000e917          	auipc	s2,0xe
ffffffffc0202a78:	60490913          	addi	s2,s2,1540 # ffffffffc0211078 <check_rp>
ffffffffc0202a7c:	e3efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a80:	0000ea17          	auipc	s4,0xe
ffffffffc0202a84:	618a0a13          	addi	s4,s4,1560 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a88:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202a8a:	4505                	li	a0,1
ffffffffc0202a8c:	b55fe0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
ffffffffc0202a90:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202a94:	28050c63          	beqz	a0,ffffffffc0202d2c <swap_init+0x3f2>
ffffffffc0202a98:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a9a:	8b89                	andi	a5,a5,2
ffffffffc0202a9c:	26079863          	bnez	a5,ffffffffc0202d0c <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202aa0:	0c21                	addi	s8,s8,8
ffffffffc0202aa2:	ff4c14e3          	bne	s8,s4,ffffffffc0202a8a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202aa6:	609c                	ld	a5,0(s1)
ffffffffc0202aa8:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202aac:	e084                	sd	s1,0(s1)
ffffffffc0202aae:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202ab0:	489c                	lw	a5,16(s1)
ffffffffc0202ab2:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202ab4:	0000ec17          	auipc	s8,0xe
ffffffffc0202ab8:	5c4c0c13          	addi	s8,s8,1476 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202abc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202abe:	0000e797          	auipc	a5,0xe
ffffffffc0202ac2:	5807a923          	sw	zero,1426(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202ac6:	000c3503          	ld	a0,0(s8)
ffffffffc0202aca:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202acc:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202ace:	ba5fe0ef          	jal	ra,ffffffffc0201672 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ad2:	ff4c1ae3          	bne	s8,s4,ffffffffc0202ac6 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ad6:	0104ac03          	lw	s8,16(s1)
ffffffffc0202ada:	4791                	li	a5,4
ffffffffc0202adc:	4afc1463          	bne	s8,a5,ffffffffc0202f84 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202ae0:	00003517          	auipc	a0,0x3
ffffffffc0202ae4:	e9050513          	addi	a0,a0,-368 # ffffffffc0205970 <default_pmm_manager+0x818>
ffffffffc0202ae8:	dd2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202aec:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202aee:	0000f797          	auipc	a5,0xf
ffffffffc0202af2:	a807a123          	sw	zero,-1406(a5) # ffffffffc0211570 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202af6:	4529                	li	a0,10
ffffffffc0202af8:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202afc:	0000f597          	auipc	a1,0xf
ffffffffc0202b00:	a745a583          	lw	a1,-1420(a1) # ffffffffc0211570 <pgfault_num>
ffffffffc0202b04:	4805                	li	a6,1
ffffffffc0202b06:	0000f797          	auipc	a5,0xf
ffffffffc0202b0a:	a6a78793          	addi	a5,a5,-1430 # ffffffffc0211570 <pgfault_num>
ffffffffc0202b0e:	3f059b63          	bne	a1,a6,ffffffffc0202f04 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b12:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0202b16:	4390                	lw	a2,0(a5)
ffffffffc0202b18:	2601                	sext.w	a2,a2
ffffffffc0202b1a:	40b61563          	bne	a2,a1,ffffffffc0202f24 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b1e:	6589                	lui	a1,0x2
ffffffffc0202b20:	452d                	li	a0,11
ffffffffc0202b22:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202b26:	4390                	lw	a2,0(a5)
ffffffffc0202b28:	4809                	li	a6,2
ffffffffc0202b2a:	2601                	sext.w	a2,a2
ffffffffc0202b2c:	35061c63          	bne	a2,a6,ffffffffc0202e84 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b30:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0202b34:	438c                	lw	a1,0(a5)
ffffffffc0202b36:	2581                	sext.w	a1,a1
ffffffffc0202b38:	36c59663          	bne	a1,a2,ffffffffc0202ea4 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b3c:	658d                	lui	a1,0x3
ffffffffc0202b3e:	4531                	li	a0,12
ffffffffc0202b40:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202b44:	4390                	lw	a2,0(a5)
ffffffffc0202b46:	480d                	li	a6,3
ffffffffc0202b48:	2601                	sext.w	a2,a2
ffffffffc0202b4a:	37061d63          	bne	a2,a6,ffffffffc0202ec4 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b4e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0202b52:	438c                	lw	a1,0(a5)
ffffffffc0202b54:	2581                	sext.w	a1,a1
ffffffffc0202b56:	38c59763          	bne	a1,a2,ffffffffc0202ee4 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b5a:	6591                	lui	a1,0x4
ffffffffc0202b5c:	4535                	li	a0,13
ffffffffc0202b5e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202b62:	4390                	lw	a2,0(a5)
ffffffffc0202b64:	2601                	sext.w	a2,a2
ffffffffc0202b66:	21861f63          	bne	a2,s8,ffffffffc0202d84 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b6a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0202b6e:	439c                	lw	a5,0(a5)
ffffffffc0202b70:	2781                	sext.w	a5,a5
ffffffffc0202b72:	22c79963          	bne	a5,a2,ffffffffc0202da4 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202b76:	489c                	lw	a5,16(s1)
ffffffffc0202b78:	24079663          	bnez	a5,ffffffffc0202dc4 <swap_init+0x48a>
ffffffffc0202b7c:	0000e797          	auipc	a5,0xe
ffffffffc0202b80:	51c78793          	addi	a5,a5,1308 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202b84:	0000e617          	auipc	a2,0xe
ffffffffc0202b88:	53c60613          	addi	a2,a2,1340 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202b8c:	0000e517          	auipc	a0,0xe
ffffffffc0202b90:	53450513          	addi	a0,a0,1332 # ffffffffc02110c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202b94:	55fd                	li	a1,-1
ffffffffc0202b96:	c38c                	sw	a1,0(a5)
ffffffffc0202b98:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202b9a:	0791                	addi	a5,a5,4
ffffffffc0202b9c:	0611                	addi	a2,a2,4
ffffffffc0202b9e:	fef51ce3          	bne	a0,a5,ffffffffc0202b96 <swap_init+0x25c>
ffffffffc0202ba2:	0000e817          	auipc	a6,0xe
ffffffffc0202ba6:	4b680813          	addi	a6,a6,1206 # ffffffffc0211058 <check_ptep>
ffffffffc0202baa:	0000e897          	auipc	a7,0xe
ffffffffc0202bae:	4ce88893          	addi	a7,a7,1230 # ffffffffc0211078 <check_rp>
ffffffffc0202bb2:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202bb4:	0000fc97          	auipc	s9,0xf
ffffffffc0202bb8:	97cc8c93          	addi	s9,s9,-1668 # ffffffffc0211530 <pages>
ffffffffc0202bbc:	00003c17          	auipc	s8,0x3
ffffffffc0202bc0:	66cc0c13          	addi	s8,s8,1644 # ffffffffc0206228 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202bc4:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202bc8:	4601                	li	a2,0
ffffffffc0202bca:	855e                	mv	a0,s7
ffffffffc0202bcc:	ec46                	sd	a7,24(sp)
ffffffffc0202bce:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202bd0:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202bd2:	b1bfe0ef          	jal	ra,ffffffffc02016ec <get_pte>
ffffffffc0202bd6:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202bd8:	65c2                	ld	a1,16(sp)
ffffffffc0202bda:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202bdc:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202be0:	0000f317          	auipc	t1,0xf
ffffffffc0202be4:	94830313          	addi	t1,t1,-1720 # ffffffffc0211528 <npage>
ffffffffc0202be8:	16050e63          	beqz	a0,ffffffffc0202d64 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bec:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202bee:	0017f613          	andi	a2,a5,1
ffffffffc0202bf2:	0e060563          	beqz	a2,ffffffffc0202cdc <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202bf6:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bfa:	078a                	slli	a5,a5,0x2
ffffffffc0202bfc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bfe:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202cf4 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c02:	000c3603          	ld	a2,0(s8)
ffffffffc0202c06:	000cb503          	ld	a0,0(s9)
ffffffffc0202c0a:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c0e:	8f91                	sub	a5,a5,a2
ffffffffc0202c10:	00379613          	slli	a2,a5,0x3
ffffffffc0202c14:	97b2                	add	a5,a5,a2
ffffffffc0202c16:	078e                	slli	a5,a5,0x3
ffffffffc0202c18:	97aa                	add	a5,a5,a0
ffffffffc0202c1a:	0aff1163          	bne	t5,a5,ffffffffc0202cbc <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c1e:	6785                	lui	a5,0x1
ffffffffc0202c20:	95be                	add	a1,a1,a5
ffffffffc0202c22:	6795                	lui	a5,0x5
ffffffffc0202c24:	0821                	addi	a6,a6,8
ffffffffc0202c26:	08a1                	addi	a7,a7,8
ffffffffc0202c28:	f8f59ee3          	bne	a1,a5,ffffffffc0202bc4 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c2c:	00003517          	auipc	a0,0x3
ffffffffc0202c30:	dec50513          	addi	a0,a0,-532 # ffffffffc0205a18 <default_pmm_manager+0x8c0>
ffffffffc0202c34:	c86fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202c38:	000b3783          	ld	a5,0(s6)
ffffffffc0202c3c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c3e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202c40:	1a051263          	bnez	a0,ffffffffc0202de4 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202c44:	00093503          	ld	a0,0(s2)
ffffffffc0202c48:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c4a:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202c4c:	a27fe0ef          	jal	ra,ffffffffc0201672 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c50:	ff491ae3          	bne	s2,s4,ffffffffc0202c44 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202c54:	8556                	mv	a0,s5
ffffffffc0202c56:	20b000ef          	jal	ra,ffffffffc0203660 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202c5a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c5c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c60:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c62:	7782                	ld	a5,32(sp)
ffffffffc0202c64:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c66:	009d8a63          	beq	s11,s1,ffffffffc0202c7a <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202c6a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c6e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c72:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c74:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c76:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c6a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202c7a:	8622                	mv	a2,s0
ffffffffc0202c7c:	85ea                	mv	a1,s10
ffffffffc0202c7e:	00003517          	auipc	a0,0x3
ffffffffc0202c82:	dca50513          	addi	a0,a0,-566 # ffffffffc0205a48 <default_pmm_manager+0x8f0>
ffffffffc0202c86:	c34fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202c8a:	00003517          	auipc	a0,0x3
ffffffffc0202c8e:	dde50513          	addi	a0,a0,-546 # ffffffffc0205a68 <default_pmm_manager+0x910>
ffffffffc0202c92:	c28fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202c96:	b9dd                	j	ffffffffc020298c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c98:	4901                	li	s2,0
ffffffffc0202c9a:	bba9                	j	ffffffffc02029f4 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202c9c:	00002697          	auipc	a3,0x2
ffffffffc0202ca0:	0fc68693          	addi	a3,a3,252 # ffffffffc0204d98 <commands+0x728>
ffffffffc0202ca4:	00002617          	auipc	a2,0x2
ffffffffc0202ca8:	10460613          	addi	a2,a2,260 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202cac:	0ba00593          	li	a1,186
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202cb8:	ebcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202cbc:	00003697          	auipc	a3,0x3
ffffffffc0202cc0:	d3468693          	addi	a3,a3,-716 # ffffffffc02059f0 <default_pmm_manager+0x898>
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	0e460613          	addi	a2,a2,228 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202ccc:	0fa00593          	li	a1,250
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	b3050513          	addi	a0,a0,-1232 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202cd8:	e9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cdc:	00002617          	auipc	a2,0x2
ffffffffc0202ce0:	4e460613          	addi	a2,a2,1252 # ffffffffc02051c0 <default_pmm_manager+0x68>
ffffffffc0202ce4:	07000593          	li	a1,112
ffffffffc0202ce8:	00002517          	auipc	a0,0x2
ffffffffc0202cec:	4c850513          	addi	a0,a0,1224 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc0202cf0:	e84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	49c60613          	addi	a2,a2,1180 # ffffffffc0205190 <default_pmm_manager+0x38>
ffffffffc0202cfc:	06500593          	li	a1,101
ffffffffc0202d00:	00002517          	auipc	a0,0x2
ffffffffc0202d04:	4b050513          	addi	a0,a0,1200 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc0202d08:	e6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d0c:	00003697          	auipc	a3,0x3
ffffffffc0202d10:	c1c68693          	addi	a3,a3,-996 # ffffffffc0205928 <default_pmm_manager+0x7d0>
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	09460613          	addi	a2,a2,148 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202d1c:	0db00593          	li	a1,219
ffffffffc0202d20:	00003517          	auipc	a0,0x3
ffffffffc0202d24:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202d28:	e4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202d2c:	00003697          	auipc	a3,0x3
ffffffffc0202d30:	be468693          	addi	a3,a3,-1052 # ffffffffc0205910 <default_pmm_manager+0x7b8>
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	07460613          	addi	a2,a2,116 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202d3c:	0da00593          	li	a1,218
ffffffffc0202d40:	00003517          	auipc	a0,0x3
ffffffffc0202d44:	ac050513          	addi	a0,a0,-1344 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202d48:	e2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d4c:	00003617          	auipc	a2,0x3
ffffffffc0202d50:	a9460613          	addi	a2,a2,-1388 # ffffffffc02057e0 <default_pmm_manager+0x688>
ffffffffc0202d54:	02700593          	li	a1,39
ffffffffc0202d58:	00003517          	auipc	a0,0x3
ffffffffc0202d5c:	aa850513          	addi	a0,a0,-1368 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202d60:	e14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202d64:	00003697          	auipc	a3,0x3
ffffffffc0202d68:	c7468693          	addi	a3,a3,-908 # ffffffffc02059d8 <default_pmm_manager+0x880>
ffffffffc0202d6c:	00002617          	auipc	a2,0x2
ffffffffc0202d70:	03c60613          	addi	a2,a2,60 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202d74:	0f900593          	li	a1,249
ffffffffc0202d78:	00003517          	auipc	a0,0x3
ffffffffc0202d7c:	a8850513          	addi	a0,a0,-1400 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202d80:	df4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d84:	00003697          	auipc	a3,0x3
ffffffffc0202d88:	c4468693          	addi	a3,a3,-956 # ffffffffc02059c8 <default_pmm_manager+0x870>
ffffffffc0202d8c:	00002617          	auipc	a2,0x2
ffffffffc0202d90:	01c60613          	addi	a2,a2,28 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202d94:	09d00593          	li	a1,157
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	a6850513          	addi	a0,a0,-1432 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202da0:	dd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202da4:	00003697          	auipc	a3,0x3
ffffffffc0202da8:	c2468693          	addi	a3,a3,-988 # ffffffffc02059c8 <default_pmm_manager+0x870>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202db4:	09f00593          	li	a1,159
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	a4850513          	addi	a0,a0,-1464 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202dc0:	db4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202dc4:	00002697          	auipc	a3,0x2
ffffffffc0202dc8:	1bc68693          	addi	a3,a3,444 # ffffffffc0204f80 <commands+0x910>
ffffffffc0202dcc:	00002617          	auipc	a2,0x2
ffffffffc0202dd0:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202dd4:	0f100593          	li	a1,241
ffffffffc0202dd8:	00003517          	auipc	a0,0x3
ffffffffc0202ddc:	a2850513          	addi	a0,a0,-1496 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202de0:	d94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202de4:	00003697          	auipc	a3,0x3
ffffffffc0202de8:	c5c68693          	addi	a3,a3,-932 # ffffffffc0205a40 <default_pmm_manager+0x8e8>
ffffffffc0202dec:	00002617          	auipc	a2,0x2
ffffffffc0202df0:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202df4:	10000593          	li	a1,256
ffffffffc0202df8:	00003517          	auipc	a0,0x3
ffffffffc0202dfc:	a0850513          	addi	a0,a0,-1528 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202e00:	d74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e04:	00003697          	auipc	a3,0x3
ffffffffc0202e08:	a7468693          	addi	a3,a3,-1420 # ffffffffc0205878 <default_pmm_manager+0x720>
ffffffffc0202e0c:	00002617          	auipc	a2,0x2
ffffffffc0202e10:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202e14:	0ca00593          	li	a1,202
ffffffffc0202e18:	00003517          	auipc	a0,0x3
ffffffffc0202e1c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202e20:	d54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e24:	00003697          	auipc	a3,0x3
ffffffffc0202e28:	a6468693          	addi	a3,a3,-1436 # ffffffffc0205888 <default_pmm_manager+0x730>
ffffffffc0202e2c:	00002617          	auipc	a2,0x2
ffffffffc0202e30:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202e34:	0cd00593          	li	a1,205
ffffffffc0202e38:	00003517          	auipc	a0,0x3
ffffffffc0202e3c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202e40:	d34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202e44:	00003697          	auipc	a3,0x3
ffffffffc0202e48:	a8c68693          	addi	a3,a3,-1396 # ffffffffc02058d0 <default_pmm_manager+0x778>
ffffffffc0202e4c:	00002617          	auipc	a2,0x2
ffffffffc0202e50:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202e54:	0d500593          	li	a1,213
ffffffffc0202e58:	00003517          	auipc	a0,0x3
ffffffffc0202e5c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202e60:	d14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e64:	00002697          	auipc	a3,0x2
ffffffffc0202e68:	f7468693          	addi	a3,a3,-140 # ffffffffc0204dd8 <commands+0x768>
ffffffffc0202e6c:	00002617          	auipc	a2,0x2
ffffffffc0202e70:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202e74:	0bd00593          	li	a1,189
ffffffffc0202e78:	00003517          	auipc	a0,0x3
ffffffffc0202e7c:	98850513          	addi	a0,a0,-1656 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202e80:	cf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202e84:	00003697          	auipc	a3,0x3
ffffffffc0202e88:	b2468693          	addi	a3,a3,-1244 # ffffffffc02059a8 <default_pmm_manager+0x850>
ffffffffc0202e8c:	00002617          	auipc	a2,0x2
ffffffffc0202e90:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202e94:	09500593          	li	a1,149
ffffffffc0202e98:	00003517          	auipc	a0,0x3
ffffffffc0202e9c:	96850513          	addi	a0,a0,-1688 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202ea0:	cd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ea4:	00003697          	auipc	a3,0x3
ffffffffc0202ea8:	b0468693          	addi	a3,a3,-1276 # ffffffffc02059a8 <default_pmm_manager+0x850>
ffffffffc0202eac:	00002617          	auipc	a2,0x2
ffffffffc0202eb0:	efc60613          	addi	a2,a2,-260 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202eb4:	09700593          	li	a1,151
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	94850513          	addi	a0,a0,-1720 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202ec0:	cb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ec4:	00003697          	auipc	a3,0x3
ffffffffc0202ec8:	af468693          	addi	a3,a3,-1292 # ffffffffc02059b8 <default_pmm_manager+0x860>
ffffffffc0202ecc:	00002617          	auipc	a2,0x2
ffffffffc0202ed0:	edc60613          	addi	a2,a2,-292 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202ed4:	09900593          	li	a1,153
ffffffffc0202ed8:	00003517          	auipc	a0,0x3
ffffffffc0202edc:	92850513          	addi	a0,a0,-1752 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202ee0:	c94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ee4:	00003697          	auipc	a3,0x3
ffffffffc0202ee8:	ad468693          	addi	a3,a3,-1324 # ffffffffc02059b8 <default_pmm_manager+0x860>
ffffffffc0202eec:	00002617          	auipc	a2,0x2
ffffffffc0202ef0:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202ef4:	09b00593          	li	a1,155
ffffffffc0202ef8:	00003517          	auipc	a0,0x3
ffffffffc0202efc:	90850513          	addi	a0,a0,-1784 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202f00:	c74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f04:	00003697          	auipc	a3,0x3
ffffffffc0202f08:	a9468693          	addi	a3,a3,-1388 # ffffffffc0205998 <default_pmm_manager+0x840>
ffffffffc0202f0c:	00002617          	auipc	a2,0x2
ffffffffc0202f10:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202f14:	09100593          	li	a1,145
ffffffffc0202f18:	00003517          	auipc	a0,0x3
ffffffffc0202f1c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202f20:	c54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f24:	00003697          	auipc	a3,0x3
ffffffffc0202f28:	a7468693          	addi	a3,a3,-1420 # ffffffffc0205998 <default_pmm_manager+0x840>
ffffffffc0202f2c:	00002617          	auipc	a2,0x2
ffffffffc0202f30:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202f34:	09300593          	li	a1,147
ffffffffc0202f38:	00003517          	auipc	a0,0x3
ffffffffc0202f3c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202f40:	c34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202f44:	00003697          	auipc	a3,0x3
ffffffffc0202f48:	90c68693          	addi	a3,a3,-1780 # ffffffffc0205850 <default_pmm_manager+0x6f8>
ffffffffc0202f4c:	00002617          	auipc	a2,0x2
ffffffffc0202f50:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202f54:	0c200593          	li	a1,194
ffffffffc0202f58:	00003517          	auipc	a0,0x3
ffffffffc0202f5c:	8a850513          	addi	a0,a0,-1880 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202f60:	c14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f64:	00003697          	auipc	a3,0x3
ffffffffc0202f68:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0205860 <default_pmm_manager+0x708>
ffffffffc0202f6c:	00002617          	auipc	a2,0x2
ffffffffc0202f70:	e3c60613          	addi	a2,a2,-452 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202f74:	0c500593          	li	a1,197
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	88850513          	addi	a0,a0,-1912 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202f80:	bf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202f84:	00003697          	auipc	a3,0x3
ffffffffc0202f88:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205948 <default_pmm_manager+0x7f0>
ffffffffc0202f8c:	00002617          	auipc	a2,0x2
ffffffffc0202f90:	e1c60613          	addi	a2,a2,-484 # ffffffffc0204da8 <commands+0x738>
ffffffffc0202f94:	0e800593          	li	a1,232
ffffffffc0202f98:	00003517          	auipc	a0,0x3
ffffffffc0202f9c:	86850513          	addi	a0,a0,-1944 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0202fa0:	bd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202fa4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202fa4:	0000e797          	auipc	a5,0xe
ffffffffc0202fa8:	5ac7b783          	ld	a5,1452(a5) # ffffffffc0211550 <sm>
ffffffffc0202fac:	6b9c                	ld	a5,16(a5)
ffffffffc0202fae:	8782                	jr	a5

ffffffffc0202fb0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202fb0:	0000e797          	auipc	a5,0xe
ffffffffc0202fb4:	5a07b783          	ld	a5,1440(a5) # ffffffffc0211550 <sm>
ffffffffc0202fb8:	739c                	ld	a5,32(a5)
ffffffffc0202fba:	8782                	jr	a5

ffffffffc0202fbc <swap_out>:
{
ffffffffc0202fbc:	711d                	addi	sp,sp,-96
ffffffffc0202fbe:	ec86                	sd	ra,88(sp)
ffffffffc0202fc0:	e8a2                	sd	s0,80(sp)
ffffffffc0202fc2:	e4a6                	sd	s1,72(sp)
ffffffffc0202fc4:	e0ca                	sd	s2,64(sp)
ffffffffc0202fc6:	fc4e                	sd	s3,56(sp)
ffffffffc0202fc8:	f852                	sd	s4,48(sp)
ffffffffc0202fca:	f456                	sd	s5,40(sp)
ffffffffc0202fcc:	f05a                	sd	s6,32(sp)
ffffffffc0202fce:	ec5e                	sd	s7,24(sp)
ffffffffc0202fd0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202fd2:	cde9                	beqz	a1,ffffffffc02030ac <swap_out+0xf0>
ffffffffc0202fd4:	8a2e                	mv	s4,a1
ffffffffc0202fd6:	892a                	mv	s2,a0
ffffffffc0202fd8:	8ab2                	mv	s5,a2
ffffffffc0202fda:	4401                	li	s0,0
ffffffffc0202fdc:	0000e997          	auipc	s3,0xe
ffffffffc0202fe0:	57498993          	addi	s3,s3,1396 # ffffffffc0211550 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202fe4:	00003b17          	auipc	s6,0x3
ffffffffc0202fe8:	b04b0b13          	addi	s6,s6,-1276 # ffffffffc0205ae8 <default_pmm_manager+0x990>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fec:	00003b97          	auipc	s7,0x3
ffffffffc0202ff0:	ae4b8b93          	addi	s7,s7,-1308 # ffffffffc0205ad0 <default_pmm_manager+0x978>
ffffffffc0202ff4:	a825                	j	ffffffffc020302c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ff6:	67a2                	ld	a5,8(sp)
ffffffffc0202ff8:	8626                	mv	a2,s1
ffffffffc0202ffa:	85a2                	mv	a1,s0
ffffffffc0202ffc:	63b4                	ld	a3,64(a5)
ffffffffc0202ffe:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203000:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203002:	82b1                	srli	a3,a3,0xc
ffffffffc0203004:	0685                	addi	a3,a3,1
ffffffffc0203006:	8b4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020300a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020300c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020300e:	613c                	ld	a5,64(a0)
ffffffffc0203010:	83b1                	srli	a5,a5,0xc
ffffffffc0203012:	0785                	addi	a5,a5,1
ffffffffc0203014:	07a2                	slli	a5,a5,0x8
ffffffffc0203016:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020301a:	e58fe0ef          	jal	ra,ffffffffc0201672 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020301e:	01893503          	ld	a0,24(s2)
ffffffffc0203022:	85a6                	mv	a1,s1
ffffffffc0203024:	eb6ff0ef          	jal	ra,ffffffffc02026da <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203028:	048a0d63          	beq	s4,s0,ffffffffc0203082 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020302c:	0009b783          	ld	a5,0(s3)
ffffffffc0203030:	8656                	mv	a2,s5
ffffffffc0203032:	002c                	addi	a1,sp,8
ffffffffc0203034:	7b9c                	ld	a5,48(a5)
ffffffffc0203036:	854a                	mv	a0,s2
ffffffffc0203038:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020303a:	e12d                	bnez	a0,ffffffffc020309c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020303c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020303e:	01893503          	ld	a0,24(s2)
ffffffffc0203042:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203044:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203046:	85a6                	mv	a1,s1
ffffffffc0203048:	ea4fe0ef          	jal	ra,ffffffffc02016ec <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020304c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020304e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203050:	8b85                	andi	a5,a5,1
ffffffffc0203052:	cfb9                	beqz	a5,ffffffffc02030b0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203054:	65a2                	ld	a1,8(sp)
ffffffffc0203056:	61bc                	ld	a5,64(a1)
ffffffffc0203058:	83b1                	srli	a5,a5,0xc
ffffffffc020305a:	0785                	addi	a5,a5,1
ffffffffc020305c:	00879513          	slli	a0,a5,0x8
ffffffffc0203060:	5d1000ef          	jal	ra,ffffffffc0203e30 <swapfs_write>
ffffffffc0203064:	d949                	beqz	a0,ffffffffc0202ff6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203066:	855e                	mv	a0,s7
ffffffffc0203068:	852fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020306c:	0009b783          	ld	a5,0(s3)
ffffffffc0203070:	6622                	ld	a2,8(sp)
ffffffffc0203072:	4681                	li	a3,0
ffffffffc0203074:	739c                	ld	a5,32(a5)
ffffffffc0203076:	85a6                	mv	a1,s1
ffffffffc0203078:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020307a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020307c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020307e:	fa8a17e3          	bne	s4,s0,ffffffffc020302c <swap_out+0x70>
}
ffffffffc0203082:	60e6                	ld	ra,88(sp)
ffffffffc0203084:	8522                	mv	a0,s0
ffffffffc0203086:	6446                	ld	s0,80(sp)
ffffffffc0203088:	64a6                	ld	s1,72(sp)
ffffffffc020308a:	6906                	ld	s2,64(sp)
ffffffffc020308c:	79e2                	ld	s3,56(sp)
ffffffffc020308e:	7a42                	ld	s4,48(sp)
ffffffffc0203090:	7aa2                	ld	s5,40(sp)
ffffffffc0203092:	7b02                	ld	s6,32(sp)
ffffffffc0203094:	6be2                	ld	s7,24(sp)
ffffffffc0203096:	6c42                	ld	s8,16(sp)
ffffffffc0203098:	6125                	addi	sp,sp,96
ffffffffc020309a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020309c:	85a2                	mv	a1,s0
ffffffffc020309e:	00003517          	auipc	a0,0x3
ffffffffc02030a2:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0205a88 <default_pmm_manager+0x930>
ffffffffc02030a6:	814fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc02030aa:	bfe1                	j	ffffffffc0203082 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02030ac:	4401                	li	s0,0
ffffffffc02030ae:	bfd1                	j	ffffffffc0203082 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030b0:	00003697          	auipc	a3,0x3
ffffffffc02030b4:	a0868693          	addi	a3,a3,-1528 # ffffffffc0205ab8 <default_pmm_manager+0x960>
ffffffffc02030b8:	00002617          	auipc	a2,0x2
ffffffffc02030bc:	cf060613          	addi	a2,a2,-784 # ffffffffc0204da8 <commands+0x738>
ffffffffc02030c0:	06600593          	li	a1,102
ffffffffc02030c4:	00002517          	auipc	a0,0x2
ffffffffc02030c8:	73c50513          	addi	a0,a0,1852 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc02030cc:	aa8fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030d0 <swap_in>:
{
ffffffffc02030d0:	7179                	addi	sp,sp,-48
ffffffffc02030d2:	e84a                	sd	s2,16(sp)
ffffffffc02030d4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02030d6:	4505                	li	a0,1
{
ffffffffc02030d8:	ec26                	sd	s1,24(sp)
ffffffffc02030da:	e44e                	sd	s3,8(sp)
ffffffffc02030dc:	f406                	sd	ra,40(sp)
ffffffffc02030de:	f022                	sd	s0,32(sp)
ffffffffc02030e0:	84ae                	mv	s1,a1
ffffffffc02030e2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02030e4:	cfcfe0ef          	jal	ra,ffffffffc02015e0 <alloc_pages>
     assert(result!=NULL);
ffffffffc02030e8:	c129                	beqz	a0,ffffffffc020312a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02030ea:	842a                	mv	s0,a0
ffffffffc02030ec:	01893503          	ld	a0,24(s2)
ffffffffc02030f0:	4601                	li	a2,0
ffffffffc02030f2:	85a6                	mv	a1,s1
ffffffffc02030f4:	df8fe0ef          	jal	ra,ffffffffc02016ec <get_pte>
ffffffffc02030f8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02030fa:	6108                	ld	a0,0(a0)
ffffffffc02030fc:	85a2                	mv	a1,s0
ffffffffc02030fe:	499000ef          	jal	ra,ffffffffc0203d96 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203102:	00093583          	ld	a1,0(s2)
ffffffffc0203106:	8626                	mv	a2,s1
ffffffffc0203108:	00003517          	auipc	a0,0x3
ffffffffc020310c:	a3050513          	addi	a0,a0,-1488 # ffffffffc0205b38 <default_pmm_manager+0x9e0>
ffffffffc0203110:	81a1                	srli	a1,a1,0x8
ffffffffc0203112:	fa9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203116:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203118:	0089b023          	sd	s0,0(s3)
}
ffffffffc020311c:	7402                	ld	s0,32(sp)
ffffffffc020311e:	64e2                	ld	s1,24(sp)
ffffffffc0203120:	6942                	ld	s2,16(sp)
ffffffffc0203122:	69a2                	ld	s3,8(sp)
ffffffffc0203124:	4501                	li	a0,0
ffffffffc0203126:	6145                	addi	sp,sp,48
ffffffffc0203128:	8082                	ret
     assert(result!=NULL);
ffffffffc020312a:	00003697          	auipc	a3,0x3
ffffffffc020312e:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0205b28 <default_pmm_manager+0x9d0>
ffffffffc0203132:	00002617          	auipc	a2,0x2
ffffffffc0203136:	c7660613          	addi	a2,a2,-906 # ffffffffc0204da8 <commands+0x738>
ffffffffc020313a:	07c00593          	li	a1,124
ffffffffc020313e:	00002517          	auipc	a0,0x2
ffffffffc0203142:	6c250513          	addi	a0,a0,1730 # ffffffffc0205800 <default_pmm_manager+0x6a8>
ffffffffc0203146:	a2efd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020314a <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020314a:	0000e797          	auipc	a5,0xe
ffffffffc020314e:	f9e78793          	addi	a5,a5,-98 # ffffffffc02110e8 <pra_list_head>
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr = &pra_list_head;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head;
ffffffffc0203152:	f51c                	sd	a5,40(a0)
ffffffffc0203154:	e79c                	sd	a5,8(a5)
ffffffffc0203156:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc0203158:	0000e717          	auipc	a4,0xe
ffffffffc020315c:	40f73423          	sd	a5,1032(a4) # ffffffffc0211560 <curr_ptr>
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203160:	4501                	li	a0,0
ffffffffc0203162:	8082                	ret

ffffffffc0203164 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203164:	4501                	li	a0,0
ffffffffc0203166:	8082                	ret

ffffffffc0203168 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203168:	4501                	li	a0,0
ffffffffc020316a:	8082                	ret

ffffffffc020316c <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020316c:	4501                	li	a0,0
ffffffffc020316e:	8082                	ret

ffffffffc0203170 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0203170:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203172:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203174:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203176:	678d                	lui	a5,0x3
ffffffffc0203178:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc020317c:	0000e697          	auipc	a3,0xe
ffffffffc0203180:	3f46a683          	lw	a3,1012(a3) # ffffffffc0211570 <pgfault_num>
ffffffffc0203184:	4711                	li	a4,4
ffffffffc0203186:	0ae69363          	bne	a3,a4,ffffffffc020322c <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020318a:	6705                	lui	a4,0x1
ffffffffc020318c:	4629                	li	a2,10
ffffffffc020318e:	0000e797          	auipc	a5,0xe
ffffffffc0203192:	3e278793          	addi	a5,a5,994 # ffffffffc0211570 <pgfault_num>
ffffffffc0203196:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc020319a:	4398                	lw	a4,0(a5)
ffffffffc020319c:	2701                	sext.w	a4,a4
ffffffffc020319e:	20d71763          	bne	a4,a3,ffffffffc02033ac <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031a2:	6691                	lui	a3,0x4
ffffffffc02031a4:	4635                	li	a2,13
ffffffffc02031a6:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02031aa:	4394                	lw	a3,0(a5)
ffffffffc02031ac:	2681                	sext.w	a3,a3
ffffffffc02031ae:	1ce69f63          	bne	a3,a4,ffffffffc020338c <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02031b2:	6709                	lui	a4,0x2
ffffffffc02031b4:	462d                	li	a2,11
ffffffffc02031b6:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02031ba:	4398                	lw	a4,0(a5)
ffffffffc02031bc:	2701                	sext.w	a4,a4
ffffffffc02031be:	1ad71763          	bne	a4,a3,ffffffffc020336c <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02031c2:	6715                	lui	a4,0x5
ffffffffc02031c4:	46b9                	li	a3,14
ffffffffc02031c6:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02031ca:	4398                	lw	a4,0(a5)
ffffffffc02031cc:	4695                	li	a3,5
ffffffffc02031ce:	2701                	sext.w	a4,a4
ffffffffc02031d0:	16d71e63          	bne	a4,a3,ffffffffc020334c <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc02031d4:	4394                	lw	a3,0(a5)
ffffffffc02031d6:	2681                	sext.w	a3,a3
ffffffffc02031d8:	14e69a63          	bne	a3,a4,ffffffffc020332c <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc02031dc:	4398                	lw	a4,0(a5)
ffffffffc02031de:	2701                	sext.w	a4,a4
ffffffffc02031e0:	12d71663          	bne	a4,a3,ffffffffc020330c <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc02031e4:	4394                	lw	a3,0(a5)
ffffffffc02031e6:	2681                	sext.w	a3,a3
ffffffffc02031e8:	10e69263          	bne	a3,a4,ffffffffc02032ec <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc02031ec:	4398                	lw	a4,0(a5)
ffffffffc02031ee:	2701                	sext.w	a4,a4
ffffffffc02031f0:	0cd71e63          	bne	a4,a3,ffffffffc02032cc <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc02031f4:	4394                	lw	a3,0(a5)
ffffffffc02031f6:	2681                	sext.w	a3,a3
ffffffffc02031f8:	0ae69a63          	bne	a3,a4,ffffffffc02032ac <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02031fc:	6715                	lui	a4,0x5
ffffffffc02031fe:	46b9                	li	a3,14
ffffffffc0203200:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203204:	4398                	lw	a4,0(a5)
ffffffffc0203206:	4695                	li	a3,5
ffffffffc0203208:	2701                	sext.w	a4,a4
ffffffffc020320a:	08d71163          	bne	a4,a3,ffffffffc020328c <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020320e:	6705                	lui	a4,0x1
ffffffffc0203210:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203214:	4729                	li	a4,10
ffffffffc0203216:	04e69b63          	bne	a3,a4,ffffffffc020326c <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc020321a:	439c                	lw	a5,0(a5)
ffffffffc020321c:	4719                	li	a4,6
ffffffffc020321e:	2781                	sext.w	a5,a5
ffffffffc0203220:	02e79663          	bne	a5,a4,ffffffffc020324c <_clock_check_swap+0xdc>
}
ffffffffc0203224:	60a2                	ld	ra,8(sp)
ffffffffc0203226:	4501                	li	a0,0
ffffffffc0203228:	0141                	addi	sp,sp,16
ffffffffc020322a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020322c:	00002697          	auipc	a3,0x2
ffffffffc0203230:	79c68693          	addi	a3,a3,1948 # ffffffffc02059c8 <default_pmm_manager+0x870>
ffffffffc0203234:	00002617          	auipc	a2,0x2
ffffffffc0203238:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204da8 <commands+0x738>
ffffffffc020323c:	08f00593          	li	a1,143
ffffffffc0203240:	00003517          	auipc	a0,0x3
ffffffffc0203244:	93850513          	addi	a0,a0,-1736 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203248:	92cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc020324c:	00003697          	auipc	a3,0x3
ffffffffc0203250:	97c68693          	addi	a3,a3,-1668 # ffffffffc0205bc8 <default_pmm_manager+0xa70>
ffffffffc0203254:	00002617          	auipc	a2,0x2
ffffffffc0203258:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204da8 <commands+0x738>
ffffffffc020325c:	0a600593          	li	a1,166
ffffffffc0203260:	00003517          	auipc	a0,0x3
ffffffffc0203264:	91850513          	addi	a0,a0,-1768 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203268:	90cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020326c:	00003697          	auipc	a3,0x3
ffffffffc0203270:	93468693          	addi	a3,a3,-1740 # ffffffffc0205ba0 <default_pmm_manager+0xa48>
ffffffffc0203274:	00002617          	auipc	a2,0x2
ffffffffc0203278:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204da8 <commands+0x738>
ffffffffc020327c:	0a400593          	li	a1,164
ffffffffc0203280:	00003517          	auipc	a0,0x3
ffffffffc0203284:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203288:	8ecfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020328c:	00003697          	auipc	a3,0x3
ffffffffc0203290:	90468693          	addi	a3,a3,-1788 # ffffffffc0205b90 <default_pmm_manager+0xa38>
ffffffffc0203294:	00002617          	auipc	a2,0x2
ffffffffc0203298:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204da8 <commands+0x738>
ffffffffc020329c:	0a300593          	li	a1,163
ffffffffc02032a0:	00003517          	auipc	a0,0x3
ffffffffc02032a4:	8d850513          	addi	a0,a0,-1832 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc02032a8:	8ccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032ac:	00003697          	auipc	a3,0x3
ffffffffc02032b0:	8e468693          	addi	a3,a3,-1820 # ffffffffc0205b90 <default_pmm_manager+0xa38>
ffffffffc02032b4:	00002617          	auipc	a2,0x2
ffffffffc02032b8:	af460613          	addi	a2,a2,-1292 # ffffffffc0204da8 <commands+0x738>
ffffffffc02032bc:	0a100593          	li	a1,161
ffffffffc02032c0:	00003517          	auipc	a0,0x3
ffffffffc02032c4:	8b850513          	addi	a0,a0,-1864 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc02032c8:	8acfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032cc:	00003697          	auipc	a3,0x3
ffffffffc02032d0:	8c468693          	addi	a3,a3,-1852 # ffffffffc0205b90 <default_pmm_manager+0xa38>
ffffffffc02032d4:	00002617          	auipc	a2,0x2
ffffffffc02032d8:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204da8 <commands+0x738>
ffffffffc02032dc:	09f00593          	li	a1,159
ffffffffc02032e0:	00003517          	auipc	a0,0x3
ffffffffc02032e4:	89850513          	addi	a0,a0,-1896 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc02032e8:	88cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032ec:	00003697          	auipc	a3,0x3
ffffffffc02032f0:	8a468693          	addi	a3,a3,-1884 # ffffffffc0205b90 <default_pmm_manager+0xa38>
ffffffffc02032f4:	00002617          	auipc	a2,0x2
ffffffffc02032f8:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204da8 <commands+0x738>
ffffffffc02032fc:	09d00593          	li	a1,157
ffffffffc0203300:	00003517          	auipc	a0,0x3
ffffffffc0203304:	87850513          	addi	a0,a0,-1928 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203308:	86cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020330c:	00003697          	auipc	a3,0x3
ffffffffc0203310:	88468693          	addi	a3,a3,-1916 # ffffffffc0205b90 <default_pmm_manager+0xa38>
ffffffffc0203314:	00002617          	auipc	a2,0x2
ffffffffc0203318:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204da8 <commands+0x738>
ffffffffc020331c:	09b00593          	li	a1,155
ffffffffc0203320:	00003517          	auipc	a0,0x3
ffffffffc0203324:	85850513          	addi	a0,a0,-1960 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203328:	84cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020332c:	00003697          	auipc	a3,0x3
ffffffffc0203330:	86468693          	addi	a3,a3,-1948 # ffffffffc0205b90 <default_pmm_manager+0xa38>
ffffffffc0203334:	00002617          	auipc	a2,0x2
ffffffffc0203338:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204da8 <commands+0x738>
ffffffffc020333c:	09900593          	li	a1,153
ffffffffc0203340:	00003517          	auipc	a0,0x3
ffffffffc0203344:	83850513          	addi	a0,a0,-1992 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203348:	82cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020334c:	00003697          	auipc	a3,0x3
ffffffffc0203350:	84468693          	addi	a3,a3,-1980 # ffffffffc0205b90 <default_pmm_manager+0xa38>
ffffffffc0203354:	00002617          	auipc	a2,0x2
ffffffffc0203358:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204da8 <commands+0x738>
ffffffffc020335c:	09700593          	li	a1,151
ffffffffc0203360:	00003517          	auipc	a0,0x3
ffffffffc0203364:	81850513          	addi	a0,a0,-2024 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203368:	80cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc020336c:	00002697          	auipc	a3,0x2
ffffffffc0203370:	65c68693          	addi	a3,a3,1628 # ffffffffc02059c8 <default_pmm_manager+0x870>
ffffffffc0203374:	00002617          	auipc	a2,0x2
ffffffffc0203378:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204da8 <commands+0x738>
ffffffffc020337c:	09500593          	li	a1,149
ffffffffc0203380:	00002517          	auipc	a0,0x2
ffffffffc0203384:	7f850513          	addi	a0,a0,2040 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc0203388:	fedfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc020338c:	00002697          	auipc	a3,0x2
ffffffffc0203390:	63c68693          	addi	a3,a3,1596 # ffffffffc02059c8 <default_pmm_manager+0x870>
ffffffffc0203394:	00002617          	auipc	a2,0x2
ffffffffc0203398:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204da8 <commands+0x738>
ffffffffc020339c:	09300593          	li	a1,147
ffffffffc02033a0:	00002517          	auipc	a0,0x2
ffffffffc02033a4:	7d850513          	addi	a0,a0,2008 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc02033a8:	fcdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02033ac:	00002697          	auipc	a3,0x2
ffffffffc02033b0:	61c68693          	addi	a3,a3,1564 # ffffffffc02059c8 <default_pmm_manager+0x870>
ffffffffc02033b4:	00002617          	auipc	a2,0x2
ffffffffc02033b8:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204da8 <commands+0x738>
ffffffffc02033bc:	09100593          	li	a1,145
ffffffffc02033c0:	00002517          	auipc	a0,0x2
ffffffffc02033c4:	7b850513          	addi	a0,a0,1976 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc02033c8:	fadfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02033cc <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02033cc:	751c                	ld	a5,40(a0)
{
ffffffffc02033ce:	1141                	addi	sp,sp,-16
ffffffffc02033d0:	e406                	sd	ra,8(sp)
ffffffffc02033d2:	e022                	sd	s0,0(sp)
         assert(head != NULL);
ffffffffc02033d4:	cfa9                	beqz	a5,ffffffffc020342e <_clock_swap_out_victim+0x62>
     assert(in_tick==0);
ffffffffc02033d6:	ee25                	bnez	a2,ffffffffc020344e <_clock_swap_out_victim+0x82>
ffffffffc02033d8:	0000e417          	auipc	s0,0xe
ffffffffc02033dc:	18840413          	addi	s0,s0,392 # ffffffffc0211560 <curr_ptr>
ffffffffc02033e0:	852e                	mv	a0,a1
ffffffffc02033e2:	600c                	ld	a1,0(s0)
ffffffffc02033e4:	4681                	li	a3,0
        if(curr_ptr == head){
ffffffffc02033e6:	00b78b63          	beq	a5,a1,ffffffffc02033fc <_clock_swap_out_victim+0x30>
            if(temp->visited == 0){
ffffffffc02033ea:	fe05b703          	ld	a4,-32(a1) # fe0 <kern_entry-0xffffffffc01ff020>
ffffffffc02033ee:	cb11                	beqz	a4,ffffffffc0203402 <_clock_swap_out_victim+0x36>
                temp->visited = 0;
ffffffffc02033f0:	fe05b023          	sd	zero,-32(a1)
    return listelm->next;
ffffffffc02033f4:	658c                	ld	a1,8(a1)
{
ffffffffc02033f6:	4685                	li	a3,1
        if(curr_ptr == head){
ffffffffc02033f8:	feb799e3          	bne	a5,a1,ffffffffc02033ea <_clock_swap_out_victim+0x1e>
ffffffffc02033fc:	678c                	ld	a1,8(a5)
{
ffffffffc02033fe:	4685                	li	a3,1
ffffffffc0203400:	bfe5                	j	ffffffffc02033f8 <_clock_swap_out_victim+0x2c>
ffffffffc0203402:	c291                	beqz	a3,ffffffffc0203406 <_clock_swap_out_victim+0x3a>
ffffffffc0203404:	e00c                	sd	a1,0(s0)
            struct Page *temp = le2page(curr_ptr, pra_page_link);
ffffffffc0203406:	fd058793          	addi	a5,a1,-48
                *ptr_page = temp;
ffffffffc020340a:	e11c                	sd	a5,0(a0)
                cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc020340c:	00002517          	auipc	a0,0x2
ffffffffc0203410:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205bf8 <default_pmm_manager+0xaa0>
ffffffffc0203414:	ca7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
                list_del(curr_ptr);
ffffffffc0203418:	601c                	ld	a5,0(s0)
}
ffffffffc020341a:	60a2                	ld	ra,8(sp)
ffffffffc020341c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020341e:	6398                	ld	a4,0(a5)
ffffffffc0203420:	679c                	ld	a5,8(a5)
    prev->next = next;
ffffffffc0203422:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203424:	e398                	sd	a4,0(a5)
                curr_ptr = curr_ptr->next;
ffffffffc0203426:	e01c                	sd	a5,0(s0)
}
ffffffffc0203428:	6402                	ld	s0,0(sp)
ffffffffc020342a:	0141                	addi	sp,sp,16
ffffffffc020342c:	8082                	ret
         assert(head != NULL);
ffffffffc020342e:	00002697          	auipc	a3,0x2
ffffffffc0203432:	7aa68693          	addi	a3,a3,1962 # ffffffffc0205bd8 <default_pmm_manager+0xa80>
ffffffffc0203436:	00002617          	auipc	a2,0x2
ffffffffc020343a:	97260613          	addi	a2,a2,-1678 # ffffffffc0204da8 <commands+0x738>
ffffffffc020343e:	04900593          	li	a1,73
ffffffffc0203442:	00002517          	auipc	a0,0x2
ffffffffc0203446:	73650513          	addi	a0,a0,1846 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc020344a:	f2bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(in_tick==0);
ffffffffc020344e:	00002697          	auipc	a3,0x2
ffffffffc0203452:	79a68693          	addi	a3,a3,1946 # ffffffffc0205be8 <default_pmm_manager+0xa90>
ffffffffc0203456:	00002617          	auipc	a2,0x2
ffffffffc020345a:	95260613          	addi	a2,a2,-1710 # ffffffffc0204da8 <commands+0x738>
ffffffffc020345e:	04a00593          	li	a1,74
ffffffffc0203462:	00002517          	auipc	a0,0x2
ffffffffc0203466:	71650513          	addi	a0,a0,1814 # ffffffffc0205b78 <default_pmm_manager+0xa20>
ffffffffc020346a:	f0bfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020346e <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020346e:	0000e797          	auipc	a5,0xe
ffffffffc0203472:	0f27b783          	ld	a5,242(a5) # ffffffffc0211560 <curr_ptr>
ffffffffc0203476:	cf91                	beqz	a5,ffffffffc0203492 <_clock_map_swappable+0x24>
    list_add(head->prev, entry);
ffffffffc0203478:	751c                	ld	a5,40(a0)
ffffffffc020347a:	03060713          	addi	a4,a2,48
}
ffffffffc020347e:	4501                	li	a0,0
    list_add(head->prev, entry);
ffffffffc0203480:	639c                	ld	a5,0(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203482:	6794                	ld	a3,8(a5)
    prev->next = next->prev = elm;
ffffffffc0203484:	e298                	sd	a4,0(a3)
ffffffffc0203486:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0203488:	fa1c                	sd	a5,48(a2)
    page->visited = 1;
ffffffffc020348a:	4785                	li	a5,1
    elm->next = next;
ffffffffc020348c:	fe14                	sd	a3,56(a2)
ffffffffc020348e:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203490:	8082                	ret
{
ffffffffc0203492:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203494:	00002697          	auipc	a3,0x2
ffffffffc0203498:	77468693          	addi	a3,a3,1908 # ffffffffc0205c08 <default_pmm_manager+0xab0>
ffffffffc020349c:	00002617          	auipc	a2,0x2
ffffffffc02034a0:	90c60613          	addi	a2,a2,-1780 # ffffffffc0204da8 <commands+0x738>
ffffffffc02034a4:	03600593          	li	a1,54
ffffffffc02034a8:	00002517          	auipc	a0,0x2
ffffffffc02034ac:	6d050513          	addi	a0,a0,1744 # ffffffffc0205b78 <default_pmm_manager+0xa20>
{
ffffffffc02034b0:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02034b2:	ec3fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02034b6 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02034b6:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02034b8:	00002697          	auipc	a3,0x2
ffffffffc02034bc:	79068693          	addi	a3,a3,1936 # ffffffffc0205c48 <default_pmm_manager+0xaf0>
ffffffffc02034c0:	00002617          	auipc	a2,0x2
ffffffffc02034c4:	8e860613          	addi	a2,a2,-1816 # ffffffffc0204da8 <commands+0x738>
ffffffffc02034c8:	08c00593          	li	a1,140
ffffffffc02034cc:	00002517          	auipc	a0,0x2
ffffffffc02034d0:	79c50513          	addi	a0,a0,1948 # ffffffffc0205c68 <default_pmm_manager+0xb10>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02034d4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02034d6:	e9ffc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02034da <mm_create>:
{
ffffffffc02034da:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02034dc:	03000513          	li	a0,48
{
ffffffffc02034e0:	e022                	sd	s0,0(sp)
ffffffffc02034e2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02034e4:	ab4ff0ef          	jal	ra,ffffffffc0202798 <kmalloc>
ffffffffc02034e8:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc02034ea:	c105                	beqz	a0,ffffffffc020350a <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02034ec:	e408                	sd	a0,8(s0)
ffffffffc02034ee:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02034f0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02034f4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02034f8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02034fc:	0000e797          	auipc	a5,0xe
ffffffffc0203500:	05c7a783          	lw	a5,92(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203504:	eb81                	bnez	a5,ffffffffc0203514 <mm_create+0x3a>
            mm->sm_priv = NULL;
ffffffffc0203506:	02053423          	sd	zero,40(a0)
}
ffffffffc020350a:	60a2                	ld	ra,8(sp)
ffffffffc020350c:	8522                	mv	a0,s0
ffffffffc020350e:	6402                	ld	s0,0(sp)
ffffffffc0203510:	0141                	addi	sp,sp,16
ffffffffc0203512:	8082                	ret
            swap_init_mm(mm);
ffffffffc0203514:	a91ff0ef          	jal	ra,ffffffffc0202fa4 <swap_init_mm>
}
ffffffffc0203518:	60a2                	ld	ra,8(sp)
ffffffffc020351a:	8522                	mv	a0,s0
ffffffffc020351c:	6402                	ld	s0,0(sp)
ffffffffc020351e:	0141                	addi	sp,sp,16
ffffffffc0203520:	8082                	ret

ffffffffc0203522 <vma_create>:
{
ffffffffc0203522:	1101                	addi	sp,sp,-32
ffffffffc0203524:	e04a                	sd	s2,0(sp)
ffffffffc0203526:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203528:	03000513          	li	a0,48
{
ffffffffc020352c:	e822                	sd	s0,16(sp)
ffffffffc020352e:	e426                	sd	s1,8(sp)
ffffffffc0203530:	ec06                	sd	ra,24(sp)
ffffffffc0203532:	84ae                	mv	s1,a1
ffffffffc0203534:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203536:	a62ff0ef          	jal	ra,ffffffffc0202798 <kmalloc>
    if (vma != NULL)
ffffffffc020353a:	c509                	beqz	a0,ffffffffc0203544 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020353c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203540:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203542:	ed00                	sd	s0,24(a0)
}
ffffffffc0203544:	60e2                	ld	ra,24(sp)
ffffffffc0203546:	6442                	ld	s0,16(sp)
ffffffffc0203548:	64a2                	ld	s1,8(sp)
ffffffffc020354a:	6902                	ld	s2,0(sp)
ffffffffc020354c:	6105                	addi	sp,sp,32
ffffffffc020354e:	8082                	ret

ffffffffc0203550 <find_vma>:
{
ffffffffc0203550:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0203552:	c505                	beqz	a0,ffffffffc020357a <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203554:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203556:	c501                	beqz	a0,ffffffffc020355e <find_vma+0xe>
ffffffffc0203558:	651c                	ld	a5,8(a0)
ffffffffc020355a:	02f5f263          	bgeu	a1,a5,ffffffffc020357e <find_vma+0x2e>
    return listelm->next;
ffffffffc020355e:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203560:	00f68d63          	beq	a3,a5,ffffffffc020357a <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203564:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203568:	00e5e663          	bltu	a1,a4,ffffffffc0203574 <find_vma+0x24>
ffffffffc020356c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203570:	00e5ec63          	bltu	a1,a4,ffffffffc0203588 <find_vma+0x38>
ffffffffc0203574:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203576:	fef697e3          	bne	a3,a5,ffffffffc0203564 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020357a:	4501                	li	a0,0
}
ffffffffc020357c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020357e:	691c                	ld	a5,16(a0)
ffffffffc0203580:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020355e <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203584:	ea88                	sd	a0,16(a3)
ffffffffc0203586:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203588:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020358c:	ea88                	sd	a0,16(a3)
ffffffffc020358e:	8082                	ret

ffffffffc0203590 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203590:	6590                	ld	a2,8(a1)
ffffffffc0203592:	0105b803          	ld	a6,16(a1)
{
ffffffffc0203596:	1141                	addi	sp,sp,-16
ffffffffc0203598:	e406                	sd	ra,8(sp)
ffffffffc020359a:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020359c:	01066763          	bltu	a2,a6,ffffffffc02035aa <insert_vma_struct+0x1a>
ffffffffc02035a0:	a085                	j	ffffffffc0203600 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02035a2:	fe87b703          	ld	a4,-24(a5)
ffffffffc02035a6:	04e66863          	bltu	a2,a4,ffffffffc02035f6 <insert_vma_struct+0x66>
ffffffffc02035aa:	86be                	mv	a3,a5
ffffffffc02035ac:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02035ae:	fef51ae3          	bne	a0,a5,ffffffffc02035a2 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02035b2:	02a68463          	beq	a3,a0,ffffffffc02035da <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02035b6:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035ba:	fe86b883          	ld	a7,-24(a3)
ffffffffc02035be:	08e8f163          	bgeu	a7,a4,ffffffffc0203640 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035c2:	04e66f63          	bltu	a2,a4,ffffffffc0203620 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02035c6:	00f50a63          	beq	a0,a5,ffffffffc02035da <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02035ca:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035ce:	05076963          	bltu	a4,a6,ffffffffc0203620 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02035d2:	ff07b603          	ld	a2,-16(a5)
ffffffffc02035d6:	02c77363          	bgeu	a4,a2,ffffffffc02035fc <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02035da:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02035dc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02035de:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02035e2:	e390                	sd	a2,0(a5)
ffffffffc02035e4:	e690                	sd	a2,8(a3)
}
ffffffffc02035e6:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02035e8:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02035ea:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02035ec:	0017079b          	addiw	a5,a4,1
ffffffffc02035f0:	d11c                	sw	a5,32(a0)
}
ffffffffc02035f2:	0141                	addi	sp,sp,16
ffffffffc02035f4:	8082                	ret
    if (le_prev != list)
ffffffffc02035f6:	fca690e3          	bne	a3,a0,ffffffffc02035b6 <insert_vma_struct+0x26>
ffffffffc02035fa:	bfd1                	j	ffffffffc02035ce <insert_vma_struct+0x3e>
ffffffffc02035fc:	ebbff0ef          	jal	ra,ffffffffc02034b6 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203600:	00002697          	auipc	a3,0x2
ffffffffc0203604:	67868693          	addi	a3,a3,1656 # ffffffffc0205c78 <default_pmm_manager+0xb20>
ffffffffc0203608:	00001617          	auipc	a2,0x1
ffffffffc020360c:	7a060613          	addi	a2,a2,1952 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203610:	09200593          	li	a1,146
ffffffffc0203614:	00002517          	auipc	a0,0x2
ffffffffc0203618:	65450513          	addi	a0,a0,1620 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc020361c:	d59fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203620:	00002697          	auipc	a3,0x2
ffffffffc0203624:	69868693          	addi	a3,a3,1688 # ffffffffc0205cb8 <default_pmm_manager+0xb60>
ffffffffc0203628:	00001617          	auipc	a2,0x1
ffffffffc020362c:	78060613          	addi	a2,a2,1920 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203630:	08b00593          	li	a1,139
ffffffffc0203634:	00002517          	auipc	a0,0x2
ffffffffc0203638:	63450513          	addi	a0,a0,1588 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc020363c:	d39fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203640:	00002697          	auipc	a3,0x2
ffffffffc0203644:	65868693          	addi	a3,a3,1624 # ffffffffc0205c98 <default_pmm_manager+0xb40>
ffffffffc0203648:	00001617          	auipc	a2,0x1
ffffffffc020364c:	76060613          	addi	a2,a2,1888 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203650:	08a00593          	li	a1,138
ffffffffc0203654:	00002517          	auipc	a0,0x2
ffffffffc0203658:	61450513          	addi	a0,a0,1556 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc020365c:	d19fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203660 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
ffffffffc0203660:	1141                	addi	sp,sp,-16
ffffffffc0203662:	e022                	sd	s0,0(sp)
ffffffffc0203664:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203666:	6508                	ld	a0,8(a0)
ffffffffc0203668:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020366a:	00a40e63          	beq	s0,a0,ffffffffc0203686 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020366e:	6118                	ld	a4,0(a0)
ffffffffc0203670:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc0203672:	03000593          	li	a1,48
ffffffffc0203676:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203678:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020367a:	e398                	sd	a4,0(a5)
ffffffffc020367c:	9d6ff0ef          	jal	ra,ffffffffc0202852 <kfree>
    return listelm->next;
ffffffffc0203680:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203682:	fea416e3          	bne	s0,a0,ffffffffc020366e <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203686:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203688:	6402                	ld	s0,0(sp)
ffffffffc020368a:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc020368c:	03000593          	li	a1,48
}
ffffffffc0203690:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203692:	9c0ff06f          	j	ffffffffc0202852 <kfree>

ffffffffc0203696 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203696:	715d                	addi	sp,sp,-80
ffffffffc0203698:	e486                	sd	ra,72(sp)
ffffffffc020369a:	f44e                	sd	s3,40(sp)
ffffffffc020369c:	f052                	sd	s4,32(sp)
ffffffffc020369e:	e0a2                	sd	s0,64(sp)
ffffffffc02036a0:	fc26                	sd	s1,56(sp)
ffffffffc02036a2:	f84a                	sd	s2,48(sp)
ffffffffc02036a4:	ec56                	sd	s5,24(sp)
ffffffffc02036a6:	e85a                	sd	s6,16(sp)
ffffffffc02036a8:	e45e                	sd	s7,8(sp)

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02036aa:	808fe0ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
ffffffffc02036ae:	89aa                	mv	s3,a0
}

static void
check_vma_struct(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02036b0:	802fe0ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
ffffffffc02036b4:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02036b6:	03000513          	li	a0,48
ffffffffc02036ba:	8deff0ef          	jal	ra,ffffffffc0202798 <kmalloc>
    if (mm != NULL)
ffffffffc02036be:	56050863          	beqz	a0,ffffffffc0203c2e <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc02036c2:	e508                	sd	a0,8(a0)
ffffffffc02036c4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02036c6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02036ca:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02036ce:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02036d2:	0000e797          	auipc	a5,0xe
ffffffffc02036d6:	e867a783          	lw	a5,-378(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc02036da:	84aa                	mv	s1,a0
ffffffffc02036dc:	e7b9                	bnez	a5,ffffffffc020372a <vmm_init+0x94>
            mm->sm_priv = NULL;
ffffffffc02036de:	02053423          	sd	zero,40(a0)
{
ffffffffc02036e2:	03200413          	li	s0,50
ffffffffc02036e6:	a811                	j	ffffffffc02036fa <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02036e8:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02036ea:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02036ec:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc02036f0:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02036f2:	8526                	mv	a0,s1
ffffffffc02036f4:	e9dff0ef          	jal	ra,ffffffffc0203590 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc02036f8:	cc05                	beqz	s0,ffffffffc0203730 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036fa:	03000513          	li	a0,48
ffffffffc02036fe:	89aff0ef          	jal	ra,ffffffffc0202798 <kmalloc>
ffffffffc0203702:	85aa                	mv	a1,a0
ffffffffc0203704:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203708:	f165                	bnez	a0,ffffffffc02036e8 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc020370a:	00002697          	auipc	a3,0x2
ffffffffc020370e:	17e68693          	addi	a3,a3,382 # ffffffffc0205888 <default_pmm_manager+0x730>
ffffffffc0203712:	00001617          	auipc	a2,0x1
ffffffffc0203716:	69660613          	addi	a2,a2,1686 # ffffffffc0204da8 <commands+0x738>
ffffffffc020371a:	0e400593          	li	a1,228
ffffffffc020371e:	00002517          	auipc	a0,0x2
ffffffffc0203722:	54a50513          	addi	a0,a0,1354 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203726:	c4ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
            swap_init_mm(mm);
ffffffffc020372a:	87bff0ef          	jal	ra,ffffffffc0202fa4 <swap_init_mm>
ffffffffc020372e:	bf55                	j	ffffffffc02036e2 <vmm_init+0x4c>
ffffffffc0203730:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203734:	1f900913          	li	s2,505
ffffffffc0203738:	a819                	j	ffffffffc020374e <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc020373a:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020373c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020373e:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203742:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203744:	8526                	mv	a0,s1
ffffffffc0203746:	e4bff0ef          	jal	ra,ffffffffc0203590 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc020374a:	03240a63          	beq	s0,s2,ffffffffc020377e <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020374e:	03000513          	li	a0,48
ffffffffc0203752:	846ff0ef          	jal	ra,ffffffffc0202798 <kmalloc>
ffffffffc0203756:	85aa                	mv	a1,a0
ffffffffc0203758:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc020375c:	fd79                	bnez	a0,ffffffffc020373a <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc020375e:	00002697          	auipc	a3,0x2
ffffffffc0203762:	12a68693          	addi	a3,a3,298 # ffffffffc0205888 <default_pmm_manager+0x730>
ffffffffc0203766:	00001617          	auipc	a2,0x1
ffffffffc020376a:	64260613          	addi	a2,a2,1602 # ffffffffc0204da8 <commands+0x738>
ffffffffc020376e:	0eb00593          	li	a1,235
ffffffffc0203772:	00002517          	auipc	a0,0x2
ffffffffc0203776:	4f650513          	addi	a0,a0,1270 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc020377a:	bfbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc020377e:	649c                	ld	a5,8(s1)
ffffffffc0203780:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203782:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203786:	2ef48463          	beq	s1,a5,ffffffffc0203a6e <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020378a:	fe87b603          	ld	a2,-24(a5)
ffffffffc020378e:	ffe70693          	addi	a3,a4,-2
ffffffffc0203792:	26d61e63          	bne	a2,a3,ffffffffc0203a0e <vmm_init+0x378>
ffffffffc0203796:	ff07b683          	ld	a3,-16(a5)
ffffffffc020379a:	26e69a63          	bne	a3,a4,ffffffffc0203a0e <vmm_init+0x378>
    for (i = 1; i <= step2; i++)
ffffffffc020379e:	0715                	addi	a4,a4,5
ffffffffc02037a0:	679c                	ld	a5,8(a5)
ffffffffc02037a2:	feb712e3          	bne	a4,a1,ffffffffc0203786 <vmm_init+0xf0>
ffffffffc02037a6:	4b1d                	li	s6,7
ffffffffc02037a8:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02037aa:	1f900b93          	li	s7,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02037ae:	85a2                	mv	a1,s0
ffffffffc02037b0:	8526                	mv	a0,s1
ffffffffc02037b2:	d9fff0ef          	jal	ra,ffffffffc0203550 <find_vma>
ffffffffc02037b6:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02037b8:	2c050b63          	beqz	a0,ffffffffc0203a8e <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc02037bc:	00140593          	addi	a1,s0,1
ffffffffc02037c0:	8526                	mv	a0,s1
ffffffffc02037c2:	d8fff0ef          	jal	ra,ffffffffc0203550 <find_vma>
ffffffffc02037c6:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02037c8:	2e050363          	beqz	a0,ffffffffc0203aae <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc02037cc:	85da                	mv	a1,s6
ffffffffc02037ce:	8526                	mv	a0,s1
ffffffffc02037d0:	d81ff0ef          	jal	ra,ffffffffc0203550 <find_vma>
        assert(vma3 == NULL);
ffffffffc02037d4:	2e051d63          	bnez	a0,ffffffffc0203ace <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc02037d8:	00340593          	addi	a1,s0,3
ffffffffc02037dc:	8526                	mv	a0,s1
ffffffffc02037de:	d73ff0ef          	jal	ra,ffffffffc0203550 <find_vma>
        assert(vma4 == NULL);
ffffffffc02037e2:	30051663          	bnez	a0,ffffffffc0203aee <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc02037e6:	00440593          	addi	a1,s0,4
ffffffffc02037ea:	8526                	mv	a0,s1
ffffffffc02037ec:	d65ff0ef          	jal	ra,ffffffffc0203550 <find_vma>
        assert(vma5 == NULL);
ffffffffc02037f0:	30051f63          	bnez	a0,ffffffffc0203b0e <vmm_init+0x478>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02037f4:	00893783          	ld	a5,8(s2)
ffffffffc02037f8:	24879b63          	bne	a5,s0,ffffffffc0203a4e <vmm_init+0x3b8>
ffffffffc02037fc:	01093783          	ld	a5,16(s2)
ffffffffc0203800:	25679763          	bne	a5,s6,ffffffffc0203a4e <vmm_init+0x3b8>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203804:	008ab783          	ld	a5,8(s5)
ffffffffc0203808:	22879363          	bne	a5,s0,ffffffffc0203a2e <vmm_init+0x398>
ffffffffc020380c:	010ab783          	ld	a5,16(s5)
ffffffffc0203810:	21679f63          	bne	a5,s6,ffffffffc0203a2e <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203814:	0415                	addi	s0,s0,5
ffffffffc0203816:	0b15                	addi	s6,s6,5
ffffffffc0203818:	f9741be3          	bne	s0,s7,ffffffffc02037ae <vmm_init+0x118>
ffffffffc020381c:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc020381e:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203820:	85a2                	mv	a1,s0
ffffffffc0203822:	8526                	mv	a0,s1
ffffffffc0203824:	d2dff0ef          	jal	ra,ffffffffc0203550 <find_vma>
ffffffffc0203828:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc020382c:	c90d                	beqz	a0,ffffffffc020385e <vmm_init+0x1c8>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc020382e:	6914                	ld	a3,16(a0)
ffffffffc0203830:	6510                	ld	a2,8(a0)
ffffffffc0203832:	00002517          	auipc	a0,0x2
ffffffffc0203836:	5a650513          	addi	a0,a0,1446 # ffffffffc0205dd8 <default_pmm_manager+0xc80>
ffffffffc020383a:	881fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020383e:	00002697          	auipc	a3,0x2
ffffffffc0203842:	5c268693          	addi	a3,a3,1474 # ffffffffc0205e00 <default_pmm_manager+0xca8>
ffffffffc0203846:	00001617          	auipc	a2,0x1
ffffffffc020384a:	56260613          	addi	a2,a2,1378 # ffffffffc0204da8 <commands+0x738>
ffffffffc020384e:	11100593          	li	a1,273
ffffffffc0203852:	00002517          	auipc	a0,0x2
ffffffffc0203856:	41650513          	addi	a0,a0,1046 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc020385a:	b1bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc020385e:	147d                	addi	s0,s0,-1
ffffffffc0203860:	fd2410e3          	bne	s0,s2,ffffffffc0203820 <vmm_init+0x18a>
ffffffffc0203864:	a811                	j	ffffffffc0203878 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203866:	6118                	ld	a4,0(a0)
ffffffffc0203868:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc020386a:	03000593          	li	a1,48
ffffffffc020386e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203870:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203872:	e398                	sd	a4,0(a5)
ffffffffc0203874:	fdffe0ef          	jal	ra,ffffffffc0202852 <kfree>
    return listelm->next;
ffffffffc0203878:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc020387a:	fea496e3          	bne	s1,a0,ffffffffc0203866 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc020387e:	03000593          	li	a1,48
ffffffffc0203882:	8526                	mv	a0,s1
ffffffffc0203884:	fcffe0ef          	jal	ra,ffffffffc0202852 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203888:	e2bfd0ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
ffffffffc020388c:	3caa1163          	bne	s4,a0,ffffffffc0203c4e <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203890:	00002517          	auipc	a0,0x2
ffffffffc0203894:	5b050513          	addi	a0,a0,1456 # ffffffffc0205e40 <default_pmm_manager+0xce8>
ffffffffc0203898:	823fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    // char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020389c:	e17fd0ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
ffffffffc02038a0:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02038a2:	03000513          	li	a0,48
ffffffffc02038a6:	ef3fe0ef          	jal	ra,ffffffffc0202798 <kmalloc>
ffffffffc02038aa:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc02038ac:	2a050163          	beqz	a0,ffffffffc0203b4e <vmm_init+0x4b8>
        if (swap_init_ok)
ffffffffc02038b0:	0000e797          	auipc	a5,0xe
ffffffffc02038b4:	ca87a783          	lw	a5,-856(a5) # ffffffffc0211558 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc02038b8:	e508                	sd	a0,8(a0)
ffffffffc02038ba:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02038bc:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02038c0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02038c4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02038c8:	14079063          	bnez	a5,ffffffffc0203a08 <vmm_init+0x372>
            mm->sm_priv = NULL;
ffffffffc02038cc:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038d0:	0000e917          	auipc	s2,0xe
ffffffffc02038d4:	c5093903          	ld	s2,-944(s2) # ffffffffc0211520 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02038d8:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02038dc:	0000e717          	auipc	a4,0xe
ffffffffc02038e0:	c8873623          	sd	s0,-884(a4) # ffffffffc0211568 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038e4:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02038e8:	24079363          	bnez	a5,ffffffffc0203b2e <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038ec:	03000513          	li	a0,48
ffffffffc02038f0:	ea9fe0ef          	jal	ra,ffffffffc0202798 <kmalloc>
ffffffffc02038f4:	8a2a                	mv	s4,a0
    if (vma != NULL)
ffffffffc02038f6:	28050063          	beqz	a0,ffffffffc0203b76 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02038fa:	002007b7          	lui	a5,0x200
ffffffffc02038fe:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203902:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203904:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203906:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc020390a:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020390c:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203910:	c81ff0ef          	jal	ra,ffffffffc0203590 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203914:	10000593          	li	a1,256
ffffffffc0203918:	8522                	mv	a0,s0
ffffffffc020391a:	c37ff0ef          	jal	ra,ffffffffc0203550 <find_vma>
ffffffffc020391e:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i++)
ffffffffc0203922:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203926:	26aa1863          	bne	s4,a0,ffffffffc0203b96 <vmm_init+0x500>
    {
        *(char *)(addr + i) = i;
ffffffffc020392a:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i++)
ffffffffc020392e:	0785                	addi	a5,a5,1
ffffffffc0203930:	fee79de3          	bne	a5,a4,ffffffffc020392a <vmm_init+0x294>
        sum += i;
ffffffffc0203934:	6705                	lui	a4,0x1
ffffffffc0203936:	10000793          	li	a5,256
ffffffffc020393a:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i++)
ffffffffc020393e:	16400613          	li	a2,356
    {
        sum -= *(char *)(addr + i);
ffffffffc0203942:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i++)
ffffffffc0203946:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203948:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i++)
ffffffffc020394a:	fec79ce3          	bne	a5,a2,ffffffffc0203942 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc020394e:	26071463          	bnez	a4,ffffffffc0203bb6 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203952:	4581                	li	a1,0
ffffffffc0203954:	854a                	mv	a0,s2
ffffffffc0203956:	fe7fd0ef          	jal	ra,ffffffffc020193c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020395a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020395e:	0000e717          	auipc	a4,0xe
ffffffffc0203962:	bca73703          	ld	a4,-1078(a4) # ffffffffc0211528 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203966:	078a                	slli	a5,a5,0x2
ffffffffc0203968:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020396a:	26e7f663          	bgeu	a5,a4,ffffffffc0203bd6 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc020396e:	00003717          	auipc	a4,0x3
ffffffffc0203972:	8ba73703          	ld	a4,-1862(a4) # ffffffffc0206228 <nbase>
ffffffffc0203976:	8f99                	sub	a5,a5,a4
ffffffffc0203978:	00379713          	slli	a4,a5,0x3
ffffffffc020397c:	97ba                	add	a5,a5,a4
ffffffffc020397e:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203980:	0000e517          	auipc	a0,0xe
ffffffffc0203984:	bb053503          	ld	a0,-1104(a0) # ffffffffc0211530 <pages>
ffffffffc0203988:	953e                	add	a0,a0,a5
ffffffffc020398a:	4585                	li	a1,1
ffffffffc020398c:	ce7fd0ef          	jal	ra,ffffffffc0201672 <free_pages>
    return listelm->next;
ffffffffc0203990:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203992:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203996:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list)
ffffffffc020399a:	00a40e63          	beq	s0,a0,ffffffffc02039b6 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc020399e:	6118                	ld	a4,0(a0)
ffffffffc02039a0:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc02039a2:	03000593          	li	a1,48
ffffffffc02039a6:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02039a8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02039aa:	e398                	sd	a4,0(a5)
ffffffffc02039ac:	ea7fe0ef          	jal	ra,ffffffffc0202852 <kfree>
    return listelm->next;
ffffffffc02039b0:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02039b2:	fea416e3          	bne	s0,a0,ffffffffc020399e <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc02039b6:	03000593          	li	a1,48
ffffffffc02039ba:	8522                	mv	a0,s0
ffffffffc02039bc:	e97fe0ef          	jal	ra,ffffffffc0202852 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--; // szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02039c0:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc02039c2:	0000e797          	auipc	a5,0xe
ffffffffc02039c6:	ba07b323          	sd	zero,-1114(a5) # ffffffffc0211568 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039ca:	ce9fd0ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
ffffffffc02039ce:	22a49063          	bne	s1,a0,ffffffffc0203bee <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02039d2:	00002517          	auipc	a0,0x2
ffffffffc02039d6:	4be50513          	addi	a0,a0,1214 # ffffffffc0205e90 <default_pmm_manager+0xd38>
ffffffffc02039da:	ee0fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039de:	cd5fd0ef          	jal	ra,ffffffffc02016b2 <nr_free_pages>
    nr_free_pages_store--; // szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02039e2:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039e4:	22a99563          	bne	s3,a0,ffffffffc0203c0e <vmm_init+0x578>
}
ffffffffc02039e8:	6406                	ld	s0,64(sp)
ffffffffc02039ea:	60a6                	ld	ra,72(sp)
ffffffffc02039ec:	74e2                	ld	s1,56(sp)
ffffffffc02039ee:	7942                	ld	s2,48(sp)
ffffffffc02039f0:	79a2                	ld	s3,40(sp)
ffffffffc02039f2:	7a02                	ld	s4,32(sp)
ffffffffc02039f4:	6ae2                	ld	s5,24(sp)
ffffffffc02039f6:	6b42                	ld	s6,16(sp)
ffffffffc02039f8:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02039fa:	00002517          	auipc	a0,0x2
ffffffffc02039fe:	4b650513          	addi	a0,a0,1206 # ffffffffc0205eb0 <default_pmm_manager+0xd58>
}
ffffffffc0203a02:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a04:	eb6fc06f          	j	ffffffffc02000ba <cprintf>
            swap_init_mm(mm);
ffffffffc0203a08:	d9cff0ef          	jal	ra,ffffffffc0202fa4 <swap_init_mm>
ffffffffc0203a0c:	b5d1                	j	ffffffffc02038d0 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a0e:	00002697          	auipc	a3,0x2
ffffffffc0203a12:	2e268693          	addi	a3,a3,738 # ffffffffc0205cf0 <default_pmm_manager+0xb98>
ffffffffc0203a16:	00001617          	auipc	a2,0x1
ffffffffc0203a1a:	39260613          	addi	a2,a2,914 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203a1e:	0f500593          	li	a1,245
ffffffffc0203a22:	00002517          	auipc	a0,0x2
ffffffffc0203a26:	24650513          	addi	a0,a0,582 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203a2a:	94bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203a2e:	00002697          	auipc	a3,0x2
ffffffffc0203a32:	37a68693          	addi	a3,a3,890 # ffffffffc0205da8 <default_pmm_manager+0xc50>
ffffffffc0203a36:	00001617          	auipc	a2,0x1
ffffffffc0203a3a:	37260613          	addi	a2,a2,882 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203a3e:	10700593          	li	a1,263
ffffffffc0203a42:	00002517          	auipc	a0,0x2
ffffffffc0203a46:	22650513          	addi	a0,a0,550 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203a4a:	92bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203a4e:	00002697          	auipc	a3,0x2
ffffffffc0203a52:	32a68693          	addi	a3,a3,810 # ffffffffc0205d78 <default_pmm_manager+0xc20>
ffffffffc0203a56:	00001617          	auipc	a2,0x1
ffffffffc0203a5a:	35260613          	addi	a2,a2,850 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203a5e:	10600593          	li	a1,262
ffffffffc0203a62:	00002517          	auipc	a0,0x2
ffffffffc0203a66:	20650513          	addi	a0,a0,518 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203a6a:	90bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203a6e:	00002697          	auipc	a3,0x2
ffffffffc0203a72:	26a68693          	addi	a3,a3,618 # ffffffffc0205cd8 <default_pmm_manager+0xb80>
ffffffffc0203a76:	00001617          	auipc	a2,0x1
ffffffffc0203a7a:	33260613          	addi	a2,a2,818 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203a7e:	0f300593          	li	a1,243
ffffffffc0203a82:	00002517          	auipc	a0,0x2
ffffffffc0203a86:	1e650513          	addi	a0,a0,486 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203a8a:	8ebfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203a8e:	00002697          	auipc	a3,0x2
ffffffffc0203a92:	29a68693          	addi	a3,a3,666 # ffffffffc0205d28 <default_pmm_manager+0xbd0>
ffffffffc0203a96:	00001617          	auipc	a2,0x1
ffffffffc0203a9a:	31260613          	addi	a2,a2,786 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203a9e:	0fc00593          	li	a1,252
ffffffffc0203aa2:	00002517          	auipc	a0,0x2
ffffffffc0203aa6:	1c650513          	addi	a0,a0,454 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203aaa:	8cbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203aae:	00002697          	auipc	a3,0x2
ffffffffc0203ab2:	28a68693          	addi	a3,a3,650 # ffffffffc0205d38 <default_pmm_manager+0xbe0>
ffffffffc0203ab6:	00001617          	auipc	a2,0x1
ffffffffc0203aba:	2f260613          	addi	a2,a2,754 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203abe:	0fe00593          	li	a1,254
ffffffffc0203ac2:	00002517          	auipc	a0,0x2
ffffffffc0203ac6:	1a650513          	addi	a0,a0,422 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203aca:	8abfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203ace:	00002697          	auipc	a3,0x2
ffffffffc0203ad2:	27a68693          	addi	a3,a3,634 # ffffffffc0205d48 <default_pmm_manager+0xbf0>
ffffffffc0203ad6:	00001617          	auipc	a2,0x1
ffffffffc0203ada:	2d260613          	addi	a2,a2,722 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203ade:	10000593          	li	a1,256
ffffffffc0203ae2:	00002517          	auipc	a0,0x2
ffffffffc0203ae6:	18650513          	addi	a0,a0,390 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203aea:	88bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203aee:	00002697          	auipc	a3,0x2
ffffffffc0203af2:	26a68693          	addi	a3,a3,618 # ffffffffc0205d58 <default_pmm_manager+0xc00>
ffffffffc0203af6:	00001617          	auipc	a2,0x1
ffffffffc0203afa:	2b260613          	addi	a2,a2,690 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203afe:	10200593          	li	a1,258
ffffffffc0203b02:	00002517          	auipc	a0,0x2
ffffffffc0203b06:	16650513          	addi	a0,a0,358 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203b0a:	86bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203b0e:	00002697          	auipc	a3,0x2
ffffffffc0203b12:	25a68693          	addi	a3,a3,602 # ffffffffc0205d68 <default_pmm_manager+0xc10>
ffffffffc0203b16:	00001617          	auipc	a2,0x1
ffffffffc0203b1a:	29260613          	addi	a2,a2,658 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203b1e:	10400593          	li	a1,260
ffffffffc0203b22:	00002517          	auipc	a0,0x2
ffffffffc0203b26:	14650513          	addi	a0,a0,326 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203b2a:	84bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b2e:	00002697          	auipc	a3,0x2
ffffffffc0203b32:	d4a68693          	addi	a3,a3,-694 # ffffffffc0205878 <default_pmm_manager+0x720>
ffffffffc0203b36:	00001617          	auipc	a2,0x1
ffffffffc0203b3a:	27260613          	addi	a2,a2,626 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203b3e:	12900593          	li	a1,297
ffffffffc0203b42:	00002517          	auipc	a0,0x2
ffffffffc0203b46:	12650513          	addi	a0,a0,294 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203b4a:	82bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203b4e:	00002697          	auipc	a3,0x2
ffffffffc0203b52:	37a68693          	addi	a3,a3,890 # ffffffffc0205ec8 <default_pmm_manager+0xd70>
ffffffffc0203b56:	00001617          	auipc	a2,0x1
ffffffffc0203b5a:	25260613          	addi	a2,a2,594 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203b5e:	12600593          	li	a1,294
ffffffffc0203b62:	00002517          	auipc	a0,0x2
ffffffffc0203b66:	10650513          	addi	a0,a0,262 # ffffffffc0205c68 <default_pmm_manager+0xb10>
    check_mm_struct = mm_create();
ffffffffc0203b6a:	0000e797          	auipc	a5,0xe
ffffffffc0203b6e:	9e07bf23          	sd	zero,-1538(a5) # ffffffffc0211568 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203b72:	803fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203b76:	00002697          	auipc	a3,0x2
ffffffffc0203b7a:	d1268693          	addi	a3,a3,-750 # ffffffffc0205888 <default_pmm_manager+0x730>
ffffffffc0203b7e:	00001617          	auipc	a2,0x1
ffffffffc0203b82:	22a60613          	addi	a2,a2,554 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203b86:	12d00593          	li	a1,301
ffffffffc0203b8a:	00002517          	auipc	a0,0x2
ffffffffc0203b8e:	0de50513          	addi	a0,a0,222 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203b92:	fe2fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b96:	00002697          	auipc	a3,0x2
ffffffffc0203b9a:	2ca68693          	addi	a3,a3,714 # ffffffffc0205e60 <default_pmm_manager+0xd08>
ffffffffc0203b9e:	00001617          	auipc	a2,0x1
ffffffffc0203ba2:	20a60613          	addi	a2,a2,522 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203ba6:	13200593          	li	a1,306
ffffffffc0203baa:	00002517          	auipc	a0,0x2
ffffffffc0203bae:	0be50513          	addi	a0,a0,190 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203bb2:	fc2fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203bb6:	00002697          	auipc	a3,0x2
ffffffffc0203bba:	2ca68693          	addi	a3,a3,714 # ffffffffc0205e80 <default_pmm_manager+0xd28>
ffffffffc0203bbe:	00001617          	auipc	a2,0x1
ffffffffc0203bc2:	1ea60613          	addi	a2,a2,490 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203bc6:	13e00593          	li	a1,318
ffffffffc0203bca:	00002517          	auipc	a0,0x2
ffffffffc0203bce:	09e50513          	addi	a0,a0,158 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203bd2:	fa2fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203bd6:	00001617          	auipc	a2,0x1
ffffffffc0203bda:	5ba60613          	addi	a2,a2,1466 # ffffffffc0205190 <default_pmm_manager+0x38>
ffffffffc0203bde:	06500593          	li	a1,101
ffffffffc0203be2:	00001517          	auipc	a0,0x1
ffffffffc0203be6:	5ce50513          	addi	a0,a0,1486 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc0203bea:	f8afc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203bee:	00002697          	auipc	a3,0x2
ffffffffc0203bf2:	22a68693          	addi	a3,a3,554 # ffffffffc0205e18 <default_pmm_manager+0xcc0>
ffffffffc0203bf6:	00001617          	auipc	a2,0x1
ffffffffc0203bfa:	1b260613          	addi	a2,a2,434 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203bfe:	14c00593          	li	a1,332
ffffffffc0203c02:	00002517          	auipc	a0,0x2
ffffffffc0203c06:	06650513          	addi	a0,a0,102 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203c0a:	f6afc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c0e:	00002697          	auipc	a3,0x2
ffffffffc0203c12:	20a68693          	addi	a3,a3,522 # ffffffffc0205e18 <default_pmm_manager+0xcc0>
ffffffffc0203c16:	00001617          	auipc	a2,0x1
ffffffffc0203c1a:	19260613          	addi	a2,a2,402 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203c1e:	0d100593          	li	a1,209
ffffffffc0203c22:	00002517          	auipc	a0,0x2
ffffffffc0203c26:	04650513          	addi	a0,a0,70 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203c2a:	f4afc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203c2e:	00002697          	auipc	a3,0x2
ffffffffc0203c32:	c2268693          	addi	a3,a3,-990 # ffffffffc0205850 <default_pmm_manager+0x6f8>
ffffffffc0203c36:	00001617          	auipc	a2,0x1
ffffffffc0203c3a:	17260613          	addi	a2,a2,370 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203c3e:	0dc00593          	li	a1,220
ffffffffc0203c42:	00002517          	auipc	a0,0x2
ffffffffc0203c46:	02650513          	addi	a0,a0,38 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203c4a:	f2afc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c4e:	00002697          	auipc	a3,0x2
ffffffffc0203c52:	1ca68693          	addi	a3,a3,458 # ffffffffc0205e18 <default_pmm_manager+0xcc0>
ffffffffc0203c56:	00001617          	auipc	a2,0x1
ffffffffc0203c5a:	15260613          	addi	a2,a2,338 # ffffffffc0204da8 <commands+0x738>
ffffffffc0203c5e:	11600593          	li	a1,278
ffffffffc0203c62:	00002517          	auipc	a0,0x2
ffffffffc0203c66:	00650513          	addi	a0,a0,6 # ffffffffc0205c68 <default_pmm_manager+0xb10>
ffffffffc0203c6a:	f0afc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c6e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0203c6e:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203c70:	85b2                	mv	a1,a2
{
ffffffffc0203c72:	f822                	sd	s0,48(sp)
ffffffffc0203c74:	f426                	sd	s1,40(sp)
ffffffffc0203c76:	fc06                	sd	ra,56(sp)
ffffffffc0203c78:	f04a                	sd	s2,32(sp)
ffffffffc0203c7a:	ec4e                	sd	s3,24(sp)
ffffffffc0203c7c:	8432                	mv	s0,a2
ffffffffc0203c7e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203c80:	8d1ff0ef          	jal	ra,ffffffffc0203550 <find_vma>

    pgfault_num++;
ffffffffc0203c84:	0000e797          	auipc	a5,0xe
ffffffffc0203c88:	8ec7a783          	lw	a5,-1812(a5) # ffffffffc0211570 <pgfault_num>
ffffffffc0203c8c:	2785                	addiw	a5,a5,1
ffffffffc0203c8e:	0000e717          	auipc	a4,0xe
ffffffffc0203c92:	8ef72123          	sw	a5,-1822(a4) # ffffffffc0211570 <pgfault_num>
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
ffffffffc0203c96:	c15d                	beqz	a0,ffffffffc0203d3c <do_pgfault+0xce>
ffffffffc0203c98:	651c                	ld	a5,8(a0)
ffffffffc0203c9a:	0af46163          	bltu	s0,a5,ffffffffc0203d3c <do_pgfault+0xce>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203c9e:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203ca0:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203ca2:	8b89                	andi	a5,a5,2
ffffffffc0203ca4:	efa9                	bnez	a5,ffffffffc0203cfe <do_pgfault+0x90>
    {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203ca6:	75fd                	lui	a1,0xfffff
     * VARIABLES:
     *   mm->pgdir : the PDT of these vma
     *
     */

    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's
ffffffffc0203ca8:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203caa:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's
ffffffffc0203cac:	85a2                	mv	a1,s0
ffffffffc0203cae:	4605                	li	a2,1
ffffffffc0203cb0:	a3dfd0ef          	jal	ra,ffffffffc02016ec <get_pte>
                                        // PT(Page Table) isn't existed, then
                                        // create a PT.
    if (*ptep == 0)
ffffffffc0203cb4:	610c                	ld	a1,0(a0)
ffffffffc0203cb6:	c5a5                	beqz	a1,ffffffffc0203d1e <do_pgfault+0xb0>
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        if (swap_init_ok)
ffffffffc0203cb8:	0000e797          	auipc	a5,0xe
ffffffffc0203cbc:	8a07a783          	lw	a5,-1888(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203cc0:	c7d9                	beqz	a5,ffffffffc0203d4e <do_pgfault+0xe0>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            // to load the content of right disk page
            // into the memory which page managed.
            if ((ret = swap_in(mm, addr, &page)) != 0)
ffffffffc0203cc2:	0030                	addi	a2,sp,8
ffffffffc0203cc4:	85a2                	mv	a1,s0
ffffffffc0203cc6:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203cc8:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0)
ffffffffc0203cca:	c06ff0ef          	jal	ra,ffffffffc02030d0 <swap_in>
ffffffffc0203cce:	892a                	mv	s2,a0
ffffffffc0203cd0:	e90d                	bnez	a0,ffffffffc0203d02 <do_pgfault+0x94>
                goto failed;
            } //(2) According to the mm,
            // addr AND page, setup the
            // map of phy addr <--->
            // logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203cd2:	65a2                	ld	a1,8(sp)
ffffffffc0203cd4:	6c88                	ld	a0,24(s1)
ffffffffc0203cd6:	86ce                	mv	a3,s3
ffffffffc0203cd8:	8622                	mv	a2,s0
ffffffffc0203cda:	cfdfd0ef          	jal	ra,ffffffffc02019d6 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203cde:	6622                	ld	a2,8(sp)
ffffffffc0203ce0:	4685                	li	a3,1
ffffffffc0203ce2:	85a2                	mv	a1,s0
ffffffffc0203ce4:	8526                	mv	a0,s1
ffffffffc0203ce6:	acaff0ef          	jal	ra,ffffffffc0202fb0 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203cea:	67a2                	ld	a5,8(sp)
ffffffffc0203cec:	e3a0                	sd	s0,64(a5)
    }

    ret = 0;
failed:
    return ret;
ffffffffc0203cee:	70e2                	ld	ra,56(sp)
ffffffffc0203cf0:	7442                	ld	s0,48(sp)
ffffffffc0203cf2:	74a2                	ld	s1,40(sp)
ffffffffc0203cf4:	69e2                	ld	s3,24(sp)
ffffffffc0203cf6:	854a                	mv	a0,s2
ffffffffc0203cf8:	7902                	ld	s2,32(sp)
ffffffffc0203cfa:	6121                	addi	sp,sp,64
ffffffffc0203cfc:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203cfe:	49d9                	li	s3,22
ffffffffc0203d00:	b75d                	j	ffffffffc0203ca6 <do_pgfault+0x38>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0203d02:	00002517          	auipc	a0,0x2
ffffffffc0203d06:	23650513          	addi	a0,a0,566 # ffffffffc0205f38 <default_pmm_manager+0xde0>
ffffffffc0203d0a:	bb0fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d0e:	70e2                	ld	ra,56(sp)
ffffffffc0203d10:	7442                	ld	s0,48(sp)
ffffffffc0203d12:	74a2                	ld	s1,40(sp)
ffffffffc0203d14:	69e2                	ld	s3,24(sp)
ffffffffc0203d16:	854a                	mv	a0,s2
ffffffffc0203d18:	7902                	ld	s2,32(sp)
ffffffffc0203d1a:	6121                	addi	sp,sp,64
ffffffffc0203d1c:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203d1e:	6c88                	ld	a0,24(s1)
ffffffffc0203d20:	864e                	mv	a2,s3
ffffffffc0203d22:	85a2                	mv	a1,s0
ffffffffc0203d24:	9bdfe0ef          	jal	ra,ffffffffc02026e0 <pgdir_alloc_page>
    ret = 0;
ffffffffc0203d28:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203d2a:	f171                	bnez	a0,ffffffffc0203cee <do_pgfault+0x80>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203d2c:	00002517          	auipc	a0,0x2
ffffffffc0203d30:	1e450513          	addi	a0,a0,484 # ffffffffc0205f10 <default_pmm_manager+0xdb8>
ffffffffc0203d34:	b86fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203d38:	5971                	li	s2,-4
            goto failed;
ffffffffc0203d3a:	bf55                	j	ffffffffc0203cee <do_pgfault+0x80>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203d3c:	85a2                	mv	a1,s0
ffffffffc0203d3e:	00002517          	auipc	a0,0x2
ffffffffc0203d42:	1a250513          	addi	a0,a0,418 # ffffffffc0205ee0 <default_pmm_manager+0xd88>
ffffffffc0203d46:	b74fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203d4a:	5975                	li	s2,-3
        goto failed;
ffffffffc0203d4c:	b74d                	j	ffffffffc0203cee <do_pgfault+0x80>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203d4e:	00002517          	auipc	a0,0x2
ffffffffc0203d52:	20a50513          	addi	a0,a0,522 # ffffffffc0205f58 <default_pmm_manager+0xe00>
ffffffffc0203d56:	b64fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203d5a:	5971                	li	s2,-4
            goto failed;
ffffffffc0203d5c:	bf49                	j	ffffffffc0203cee <do_pgfault+0x80>

ffffffffc0203d5e <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203d5e:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d60:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203d62:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d64:	f30fc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203d68:	cd01                	beqz	a0,ffffffffc0203d80 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d6a:	4505                	li	a0,1
ffffffffc0203d6c:	f2efc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203d70:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d72:	810d                	srli	a0,a0,0x3
ffffffffc0203d74:	0000d797          	auipc	a5,0xd
ffffffffc0203d78:	7ca7ba23          	sd	a0,2004(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203d7c:	0141                	addi	sp,sp,16
ffffffffc0203d7e:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203d80:	00002617          	auipc	a2,0x2
ffffffffc0203d84:	20060613          	addi	a2,a2,512 # ffffffffc0205f80 <default_pmm_manager+0xe28>
ffffffffc0203d88:	45b5                	li	a1,13
ffffffffc0203d8a:	00002517          	auipc	a0,0x2
ffffffffc0203d8e:	21650513          	addi	a0,a0,534 # ffffffffc0205fa0 <default_pmm_manager+0xe48>
ffffffffc0203d92:	de2fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d96 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203d96:	1141                	addi	sp,sp,-16
ffffffffc0203d98:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d9a:	00855793          	srli	a5,a0,0x8
ffffffffc0203d9e:	c3a5                	beqz	a5,ffffffffc0203dfe <swapfs_read+0x68>
ffffffffc0203da0:	0000d717          	auipc	a4,0xd
ffffffffc0203da4:	7a873703          	ld	a4,1960(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203da8:	04e7fb63          	bgeu	a5,a4,ffffffffc0203dfe <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dac:	0000d617          	auipc	a2,0xd
ffffffffc0203db0:	78463603          	ld	a2,1924(a2) # ffffffffc0211530 <pages>
ffffffffc0203db4:	8d91                	sub	a1,a1,a2
ffffffffc0203db6:	4035d613          	srai	a2,a1,0x3
ffffffffc0203dba:	00002597          	auipc	a1,0x2
ffffffffc0203dbe:	4665b583          	ld	a1,1126(a1) # ffffffffc0206220 <error_string+0x38>
ffffffffc0203dc2:	02b60633          	mul	a2,a2,a1
ffffffffc0203dc6:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203dca:	00002797          	auipc	a5,0x2
ffffffffc0203dce:	45e7b783          	ld	a5,1118(a5) # ffffffffc0206228 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203dd2:	0000d717          	auipc	a4,0xd
ffffffffc0203dd6:	75673703          	ld	a4,1878(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dda:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ddc:	00c61793          	slli	a5,a2,0xc
ffffffffc0203de0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203de2:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203de4:	02e7f963          	bgeu	a5,a4,ffffffffc0203e16 <swapfs_read+0x80>
}
ffffffffc0203de8:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dea:	0000d797          	auipc	a5,0xd
ffffffffc0203dee:	7567b783          	ld	a5,1878(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203df2:	46a1                	li	a3,8
ffffffffc0203df4:	963e                	add	a2,a2,a5
ffffffffc0203df6:	4505                	li	a0,1
}
ffffffffc0203df8:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dfa:	ea6fc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203dfe:	86aa                	mv	a3,a0
ffffffffc0203e00:	00002617          	auipc	a2,0x2
ffffffffc0203e04:	1b860613          	addi	a2,a2,440 # ffffffffc0205fb8 <default_pmm_manager+0xe60>
ffffffffc0203e08:	45d1                	li	a1,20
ffffffffc0203e0a:	00002517          	auipc	a0,0x2
ffffffffc0203e0e:	19650513          	addi	a0,a0,406 # ffffffffc0205fa0 <default_pmm_manager+0xe48>
ffffffffc0203e12:	d62fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203e16:	86b2                	mv	a3,a2
ffffffffc0203e18:	06a00593          	li	a1,106
ffffffffc0203e1c:	00001617          	auipc	a2,0x1
ffffffffc0203e20:	3cc60613          	addi	a2,a2,972 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc0203e24:	00001517          	auipc	a0,0x1
ffffffffc0203e28:	38c50513          	addi	a0,a0,908 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc0203e2c:	d48fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e30 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203e30:	1141                	addi	sp,sp,-16
ffffffffc0203e32:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e34:	00855793          	srli	a5,a0,0x8
ffffffffc0203e38:	c3a5                	beqz	a5,ffffffffc0203e98 <swapfs_write+0x68>
ffffffffc0203e3a:	0000d717          	auipc	a4,0xd
ffffffffc0203e3e:	70e73703          	ld	a4,1806(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203e42:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e98 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e46:	0000d617          	auipc	a2,0xd
ffffffffc0203e4a:	6ea63603          	ld	a2,1770(a2) # ffffffffc0211530 <pages>
ffffffffc0203e4e:	8d91                	sub	a1,a1,a2
ffffffffc0203e50:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e54:	00002597          	auipc	a1,0x2
ffffffffc0203e58:	3cc5b583          	ld	a1,972(a1) # ffffffffc0206220 <error_string+0x38>
ffffffffc0203e5c:	02b60633          	mul	a2,a2,a1
ffffffffc0203e60:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e64:	00002797          	auipc	a5,0x2
ffffffffc0203e68:	3c47b783          	ld	a5,964(a5) # ffffffffc0206228 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e6c:	0000d717          	auipc	a4,0xd
ffffffffc0203e70:	6bc73703          	ld	a4,1724(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e74:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e76:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e7a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e7c:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e7e:	02e7f963          	bgeu	a5,a4,ffffffffc0203eb0 <swapfs_write+0x80>
}
ffffffffc0203e82:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e84:	0000d797          	auipc	a5,0xd
ffffffffc0203e88:	6bc7b783          	ld	a5,1724(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203e8c:	46a1                	li	a3,8
ffffffffc0203e8e:	963e                	add	a2,a2,a5
ffffffffc0203e90:	4505                	li	a0,1
}
ffffffffc0203e92:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e94:	e30fc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0203e98:	86aa                	mv	a3,a0
ffffffffc0203e9a:	00002617          	auipc	a2,0x2
ffffffffc0203e9e:	11e60613          	addi	a2,a2,286 # ffffffffc0205fb8 <default_pmm_manager+0xe60>
ffffffffc0203ea2:	45e5                	li	a1,25
ffffffffc0203ea4:	00002517          	auipc	a0,0x2
ffffffffc0203ea8:	0fc50513          	addi	a0,a0,252 # ffffffffc0205fa0 <default_pmm_manager+0xe48>
ffffffffc0203eac:	cc8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203eb0:	86b2                	mv	a3,a2
ffffffffc0203eb2:	06a00593          	li	a1,106
ffffffffc0203eb6:	00001617          	auipc	a2,0x1
ffffffffc0203eba:	33260613          	addi	a2,a2,818 # ffffffffc02051e8 <default_pmm_manager+0x90>
ffffffffc0203ebe:	00001517          	auipc	a0,0x1
ffffffffc0203ec2:	2f250513          	addi	a0,a0,754 # ffffffffc02051b0 <default_pmm_manager+0x58>
ffffffffc0203ec6:	caefc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203eca <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203eca:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ece:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203ed0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ed4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203ed6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203eda:	f022                	sd	s0,32(sp)
ffffffffc0203edc:	ec26                	sd	s1,24(sp)
ffffffffc0203ede:	e84a                	sd	s2,16(sp)
ffffffffc0203ee0:	f406                	sd	ra,40(sp)
ffffffffc0203ee2:	e44e                	sd	s3,8(sp)
ffffffffc0203ee4:	84aa                	mv	s1,a0
ffffffffc0203ee6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203ee8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203eec:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203eee:	03067e63          	bgeu	a2,a6,ffffffffc0203f2a <printnum+0x60>
ffffffffc0203ef2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203ef4:	00805763          	blez	s0,ffffffffc0203f02 <printnum+0x38>
ffffffffc0203ef8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203efa:	85ca                	mv	a1,s2
ffffffffc0203efc:	854e                	mv	a0,s3
ffffffffc0203efe:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203f00:	fc65                	bnez	s0,ffffffffc0203ef8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f02:	1a02                	slli	s4,s4,0x20
ffffffffc0203f04:	00002797          	auipc	a5,0x2
ffffffffc0203f08:	0d478793          	addi	a5,a5,212 # ffffffffc0205fd8 <default_pmm_manager+0xe80>
ffffffffc0203f0c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203f10:	9a3e                	add	s4,s4,a5
}
ffffffffc0203f12:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f14:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203f18:	70a2                	ld	ra,40(sp)
ffffffffc0203f1a:	69a2                	ld	s3,8(sp)
ffffffffc0203f1c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f1e:	85ca                	mv	a1,s2
ffffffffc0203f20:	87a6                	mv	a5,s1
}
ffffffffc0203f22:	6942                	ld	s2,16(sp)
ffffffffc0203f24:	64e2                	ld	s1,24(sp)
ffffffffc0203f26:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f28:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203f2a:	03065633          	divu	a2,a2,a6
ffffffffc0203f2e:	8722                	mv	a4,s0
ffffffffc0203f30:	f9bff0ef          	jal	ra,ffffffffc0203eca <printnum>
ffffffffc0203f34:	b7f9                	j	ffffffffc0203f02 <printnum+0x38>

ffffffffc0203f36 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203f36:	7119                	addi	sp,sp,-128
ffffffffc0203f38:	f4a6                	sd	s1,104(sp)
ffffffffc0203f3a:	f0ca                	sd	s2,96(sp)
ffffffffc0203f3c:	ecce                	sd	s3,88(sp)
ffffffffc0203f3e:	e8d2                	sd	s4,80(sp)
ffffffffc0203f40:	e4d6                	sd	s5,72(sp)
ffffffffc0203f42:	e0da                	sd	s6,64(sp)
ffffffffc0203f44:	fc5e                	sd	s7,56(sp)
ffffffffc0203f46:	f06a                	sd	s10,32(sp)
ffffffffc0203f48:	fc86                	sd	ra,120(sp)
ffffffffc0203f4a:	f8a2                	sd	s0,112(sp)
ffffffffc0203f4c:	f862                	sd	s8,48(sp)
ffffffffc0203f4e:	f466                	sd	s9,40(sp)
ffffffffc0203f50:	ec6e                	sd	s11,24(sp)
ffffffffc0203f52:	892a                	mv	s2,a0
ffffffffc0203f54:	84ae                	mv	s1,a1
ffffffffc0203f56:	8d32                	mv	s10,a2
ffffffffc0203f58:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f5a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203f5e:	5b7d                	li	s6,-1
ffffffffc0203f60:	00002a97          	auipc	s5,0x2
ffffffffc0203f64:	0aca8a93          	addi	s5,s5,172 # ffffffffc020600c <default_pmm_manager+0xeb4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f68:	00002b97          	auipc	s7,0x2
ffffffffc0203f6c:	280b8b93          	addi	s7,s7,640 # ffffffffc02061e8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f70:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203f74:	001d0413          	addi	s0,s10,1
ffffffffc0203f78:	01350a63          	beq	a0,s3,ffffffffc0203f8c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203f7c:	c121                	beqz	a0,ffffffffc0203fbc <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203f7e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f80:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203f82:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f84:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203f88:	ff351ae3          	bne	a0,s3,ffffffffc0203f7c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f8c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203f90:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203f94:	4c81                	li	s9,0
ffffffffc0203f96:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203f98:	5c7d                	li	s8,-1
ffffffffc0203f9a:	5dfd                	li	s11,-1
ffffffffc0203f9c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203fa0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fa2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203fa6:	0ff5f593          	zext.b	a1,a1
ffffffffc0203faa:	00140d13          	addi	s10,s0,1
ffffffffc0203fae:	04b56263          	bltu	a0,a1,ffffffffc0203ff2 <vprintfmt+0xbc>
ffffffffc0203fb2:	058a                	slli	a1,a1,0x2
ffffffffc0203fb4:	95d6                	add	a1,a1,s5
ffffffffc0203fb6:	4194                	lw	a3,0(a1)
ffffffffc0203fb8:	96d6                	add	a3,a3,s5
ffffffffc0203fba:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203fbc:	70e6                	ld	ra,120(sp)
ffffffffc0203fbe:	7446                	ld	s0,112(sp)
ffffffffc0203fc0:	74a6                	ld	s1,104(sp)
ffffffffc0203fc2:	7906                	ld	s2,96(sp)
ffffffffc0203fc4:	69e6                	ld	s3,88(sp)
ffffffffc0203fc6:	6a46                	ld	s4,80(sp)
ffffffffc0203fc8:	6aa6                	ld	s5,72(sp)
ffffffffc0203fca:	6b06                	ld	s6,64(sp)
ffffffffc0203fcc:	7be2                	ld	s7,56(sp)
ffffffffc0203fce:	7c42                	ld	s8,48(sp)
ffffffffc0203fd0:	7ca2                	ld	s9,40(sp)
ffffffffc0203fd2:	7d02                	ld	s10,32(sp)
ffffffffc0203fd4:	6de2                	ld	s11,24(sp)
ffffffffc0203fd6:	6109                	addi	sp,sp,128
ffffffffc0203fd8:	8082                	ret
            padc = '0';
ffffffffc0203fda:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203fdc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fe0:	846a                	mv	s0,s10
ffffffffc0203fe2:	00140d13          	addi	s10,s0,1
ffffffffc0203fe6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203fea:	0ff5f593          	zext.b	a1,a1
ffffffffc0203fee:	fcb572e3          	bgeu	a0,a1,ffffffffc0203fb2 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203ff2:	85a6                	mv	a1,s1
ffffffffc0203ff4:	02500513          	li	a0,37
ffffffffc0203ff8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203ffa:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203ffe:	8d22                	mv	s10,s0
ffffffffc0204000:	f73788e3          	beq	a5,s3,ffffffffc0203f70 <vprintfmt+0x3a>
ffffffffc0204004:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204008:	1d7d                	addi	s10,s10,-1
ffffffffc020400a:	ff379de3          	bne	a5,s3,ffffffffc0204004 <vprintfmt+0xce>
ffffffffc020400e:	b78d                	j	ffffffffc0203f70 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204010:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204014:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204018:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020401a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020401e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204022:	02d86463          	bltu	a6,a3,ffffffffc020404a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204026:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020402a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020402e:	0186873b          	addw	a4,a3,s8
ffffffffc0204032:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204036:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204038:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020403c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020403e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204042:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204046:	fed870e3          	bgeu	a6,a3,ffffffffc0204026 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020404a:	f40ddce3          	bgez	s11,ffffffffc0203fa2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020404e:	8de2                	mv	s11,s8
ffffffffc0204050:	5c7d                	li	s8,-1
ffffffffc0204052:	bf81                	j	ffffffffc0203fa2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204054:	fffdc693          	not	a3,s11
ffffffffc0204058:	96fd                	srai	a3,a3,0x3f
ffffffffc020405a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020405e:	00144603          	lbu	a2,1(s0)
ffffffffc0204062:	2d81                	sext.w	s11,s11
ffffffffc0204064:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204066:	bf35                	j	ffffffffc0203fa2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204068:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020406c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204070:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204072:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204074:	bfd9                	j	ffffffffc020404a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204076:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204078:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020407c:	01174463          	blt	a4,a7,ffffffffc0204084 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204080:	1a088e63          	beqz	a7,ffffffffc020423c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204084:	000a3603          	ld	a2,0(s4)
ffffffffc0204088:	46c1                	li	a3,16
ffffffffc020408a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020408c:	2781                	sext.w	a5,a5
ffffffffc020408e:	876e                	mv	a4,s11
ffffffffc0204090:	85a6                	mv	a1,s1
ffffffffc0204092:	854a                	mv	a0,s2
ffffffffc0204094:	e37ff0ef          	jal	ra,ffffffffc0203eca <printnum>
            break;
ffffffffc0204098:	bde1                	j	ffffffffc0203f70 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020409a:	000a2503          	lw	a0,0(s4)
ffffffffc020409e:	85a6                	mv	a1,s1
ffffffffc02040a0:	0a21                	addi	s4,s4,8
ffffffffc02040a2:	9902                	jalr	s2
            break;
ffffffffc02040a4:	b5f1                	j	ffffffffc0203f70 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02040ac:	01174463          	blt	a4,a7,ffffffffc02040b4 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02040b0:	18088163          	beqz	a7,ffffffffc0204232 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02040b4:	000a3603          	ld	a2,0(s4)
ffffffffc02040b8:	46a9                	li	a3,10
ffffffffc02040ba:	8a2e                	mv	s4,a1
ffffffffc02040bc:	bfc1                	j	ffffffffc020408c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040be:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02040c2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040c4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040c6:	bdf1                	j	ffffffffc0203fa2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02040c8:	85a6                	mv	a1,s1
ffffffffc02040ca:	02500513          	li	a0,37
ffffffffc02040ce:	9902                	jalr	s2
            break;
ffffffffc02040d0:	b545                	j	ffffffffc0203f70 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02040d6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040da:	b5e1                	j	ffffffffc0203fa2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02040dc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040de:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02040e2:	01174463          	blt	a4,a7,ffffffffc02040ea <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02040e6:	14088163          	beqz	a7,ffffffffc0204228 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02040ea:	000a3603          	ld	a2,0(s4)
ffffffffc02040ee:	46a1                	li	a3,8
ffffffffc02040f0:	8a2e                	mv	s4,a1
ffffffffc02040f2:	bf69                	j	ffffffffc020408c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02040f4:	03000513          	li	a0,48
ffffffffc02040f8:	85a6                	mv	a1,s1
ffffffffc02040fa:	e03e                	sd	a5,0(sp)
ffffffffc02040fc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02040fe:	85a6                	mv	a1,s1
ffffffffc0204100:	07800513          	li	a0,120
ffffffffc0204104:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204106:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204108:	6782                	ld	a5,0(sp)
ffffffffc020410a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020410c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204110:	bfb5                	j	ffffffffc020408c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204112:	000a3403          	ld	s0,0(s4)
ffffffffc0204116:	008a0713          	addi	a4,s4,8
ffffffffc020411a:	e03a                	sd	a4,0(sp)
ffffffffc020411c:	14040263          	beqz	s0,ffffffffc0204260 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204120:	0fb05763          	blez	s11,ffffffffc020420e <vprintfmt+0x2d8>
ffffffffc0204124:	02d00693          	li	a3,45
ffffffffc0204128:	0cd79163          	bne	a5,a3,ffffffffc02041ea <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020412c:	00044783          	lbu	a5,0(s0)
ffffffffc0204130:	0007851b          	sext.w	a0,a5
ffffffffc0204134:	cf85                	beqz	a5,ffffffffc020416c <vprintfmt+0x236>
ffffffffc0204136:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020413a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020413e:	000c4563          	bltz	s8,ffffffffc0204148 <vprintfmt+0x212>
ffffffffc0204142:	3c7d                	addiw	s8,s8,-1
ffffffffc0204144:	036c0263          	beq	s8,s6,ffffffffc0204168 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204148:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020414a:	0e0c8e63          	beqz	s9,ffffffffc0204246 <vprintfmt+0x310>
ffffffffc020414e:	3781                	addiw	a5,a5,-32
ffffffffc0204150:	0ef47b63          	bgeu	s0,a5,ffffffffc0204246 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204154:	03f00513          	li	a0,63
ffffffffc0204158:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020415a:	000a4783          	lbu	a5,0(s4)
ffffffffc020415e:	3dfd                	addiw	s11,s11,-1
ffffffffc0204160:	0a05                	addi	s4,s4,1
ffffffffc0204162:	0007851b          	sext.w	a0,a5
ffffffffc0204166:	ffe1                	bnez	a5,ffffffffc020413e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204168:	01b05963          	blez	s11,ffffffffc020417a <vprintfmt+0x244>
ffffffffc020416c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020416e:	85a6                	mv	a1,s1
ffffffffc0204170:	02000513          	li	a0,32
ffffffffc0204174:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204176:	fe0d9be3          	bnez	s11,ffffffffc020416c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020417a:	6a02                	ld	s4,0(sp)
ffffffffc020417c:	bbd5                	j	ffffffffc0203f70 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020417e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204180:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204184:	01174463          	blt	a4,a7,ffffffffc020418c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204188:	08088d63          	beqz	a7,ffffffffc0204222 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020418c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204190:	0a044d63          	bltz	s0,ffffffffc020424a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204194:	8622                	mv	a2,s0
ffffffffc0204196:	8a66                	mv	s4,s9
ffffffffc0204198:	46a9                	li	a3,10
ffffffffc020419a:	bdcd                	j	ffffffffc020408c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020419c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02041a0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02041a2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02041a4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02041a8:	8fb5                	xor	a5,a5,a3
ffffffffc02041aa:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02041ae:	02d74163          	blt	a4,a3,ffffffffc02041d0 <vprintfmt+0x29a>
ffffffffc02041b2:	00369793          	slli	a5,a3,0x3
ffffffffc02041b6:	97de                	add	a5,a5,s7
ffffffffc02041b8:	639c                	ld	a5,0(a5)
ffffffffc02041ba:	cb99                	beqz	a5,ffffffffc02041d0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02041bc:	86be                	mv	a3,a5
ffffffffc02041be:	00002617          	auipc	a2,0x2
ffffffffc02041c2:	e4a60613          	addi	a2,a2,-438 # ffffffffc0206008 <default_pmm_manager+0xeb0>
ffffffffc02041c6:	85a6                	mv	a1,s1
ffffffffc02041c8:	854a                	mv	a0,s2
ffffffffc02041ca:	0ce000ef          	jal	ra,ffffffffc0204298 <printfmt>
ffffffffc02041ce:	b34d                	j	ffffffffc0203f70 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02041d0:	00002617          	auipc	a2,0x2
ffffffffc02041d4:	e2860613          	addi	a2,a2,-472 # ffffffffc0205ff8 <default_pmm_manager+0xea0>
ffffffffc02041d8:	85a6                	mv	a1,s1
ffffffffc02041da:	854a                	mv	a0,s2
ffffffffc02041dc:	0bc000ef          	jal	ra,ffffffffc0204298 <printfmt>
ffffffffc02041e0:	bb41                	j	ffffffffc0203f70 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02041e2:	00002417          	auipc	s0,0x2
ffffffffc02041e6:	e0e40413          	addi	s0,s0,-498 # ffffffffc0205ff0 <default_pmm_manager+0xe98>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041ea:	85e2                	mv	a1,s8
ffffffffc02041ec:	8522                	mv	a0,s0
ffffffffc02041ee:	e43e                	sd	a5,8(sp)
ffffffffc02041f0:	196000ef          	jal	ra,ffffffffc0204386 <strnlen>
ffffffffc02041f4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02041f8:	01b05b63          	blez	s11,ffffffffc020420e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02041fc:	67a2                	ld	a5,8(sp)
ffffffffc02041fe:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204202:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204204:	85a6                	mv	a1,s1
ffffffffc0204206:	8552                	mv	a0,s4
ffffffffc0204208:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020420a:	fe0d9ce3          	bnez	s11,ffffffffc0204202 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020420e:	00044783          	lbu	a5,0(s0)
ffffffffc0204212:	00140a13          	addi	s4,s0,1
ffffffffc0204216:	0007851b          	sext.w	a0,a5
ffffffffc020421a:	d3a5                	beqz	a5,ffffffffc020417a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020421c:	05e00413          	li	s0,94
ffffffffc0204220:	bf39                	j	ffffffffc020413e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204222:	000a2403          	lw	s0,0(s4)
ffffffffc0204226:	b7ad                	j	ffffffffc0204190 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204228:	000a6603          	lwu	a2,0(s4)
ffffffffc020422c:	46a1                	li	a3,8
ffffffffc020422e:	8a2e                	mv	s4,a1
ffffffffc0204230:	bdb1                	j	ffffffffc020408c <vprintfmt+0x156>
ffffffffc0204232:	000a6603          	lwu	a2,0(s4)
ffffffffc0204236:	46a9                	li	a3,10
ffffffffc0204238:	8a2e                	mv	s4,a1
ffffffffc020423a:	bd89                	j	ffffffffc020408c <vprintfmt+0x156>
ffffffffc020423c:	000a6603          	lwu	a2,0(s4)
ffffffffc0204240:	46c1                	li	a3,16
ffffffffc0204242:	8a2e                	mv	s4,a1
ffffffffc0204244:	b5a1                	j	ffffffffc020408c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204246:	9902                	jalr	s2
ffffffffc0204248:	bf09                	j	ffffffffc020415a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020424a:	85a6                	mv	a1,s1
ffffffffc020424c:	02d00513          	li	a0,45
ffffffffc0204250:	e03e                	sd	a5,0(sp)
ffffffffc0204252:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204254:	6782                	ld	a5,0(sp)
ffffffffc0204256:	8a66                	mv	s4,s9
ffffffffc0204258:	40800633          	neg	a2,s0
ffffffffc020425c:	46a9                	li	a3,10
ffffffffc020425e:	b53d                	j	ffffffffc020408c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204260:	03b05163          	blez	s11,ffffffffc0204282 <vprintfmt+0x34c>
ffffffffc0204264:	02d00693          	li	a3,45
ffffffffc0204268:	f6d79de3          	bne	a5,a3,ffffffffc02041e2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020426c:	00002417          	auipc	s0,0x2
ffffffffc0204270:	d8440413          	addi	s0,s0,-636 # ffffffffc0205ff0 <default_pmm_manager+0xe98>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204274:	02800793          	li	a5,40
ffffffffc0204278:	02800513          	li	a0,40
ffffffffc020427c:	00140a13          	addi	s4,s0,1
ffffffffc0204280:	bd6d                	j	ffffffffc020413a <vprintfmt+0x204>
ffffffffc0204282:	00002a17          	auipc	s4,0x2
ffffffffc0204286:	d6fa0a13          	addi	s4,s4,-657 # ffffffffc0205ff1 <default_pmm_manager+0xe99>
ffffffffc020428a:	02800513          	li	a0,40
ffffffffc020428e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204292:	05e00413          	li	s0,94
ffffffffc0204296:	b565                	j	ffffffffc020413e <vprintfmt+0x208>

ffffffffc0204298 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204298:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020429a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020429e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02042a0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02042a2:	ec06                	sd	ra,24(sp)
ffffffffc02042a4:	f83a                	sd	a4,48(sp)
ffffffffc02042a6:	fc3e                	sd	a5,56(sp)
ffffffffc02042a8:	e0c2                	sd	a6,64(sp)
ffffffffc02042aa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02042ac:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02042ae:	c89ff0ef          	jal	ra,ffffffffc0203f36 <vprintfmt>
}
ffffffffc02042b2:	60e2                	ld	ra,24(sp)
ffffffffc02042b4:	6161                	addi	sp,sp,80
ffffffffc02042b6:	8082                	ret

ffffffffc02042b8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02042b8:	715d                	addi	sp,sp,-80
ffffffffc02042ba:	e486                	sd	ra,72(sp)
ffffffffc02042bc:	e0a6                	sd	s1,64(sp)
ffffffffc02042be:	fc4a                	sd	s2,56(sp)
ffffffffc02042c0:	f84e                	sd	s3,48(sp)
ffffffffc02042c2:	f452                	sd	s4,40(sp)
ffffffffc02042c4:	f056                	sd	s5,32(sp)
ffffffffc02042c6:	ec5a                	sd	s6,24(sp)
ffffffffc02042c8:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02042ca:	c901                	beqz	a0,ffffffffc02042da <readline+0x22>
ffffffffc02042cc:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02042ce:	00002517          	auipc	a0,0x2
ffffffffc02042d2:	d3a50513          	addi	a0,a0,-710 # ffffffffc0206008 <default_pmm_manager+0xeb0>
ffffffffc02042d6:	de5fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02042da:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042dc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02042de:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02042e0:	4aa9                	li	s5,10
ffffffffc02042e2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02042e4:	0000db97          	auipc	s7,0xd
ffffffffc02042e8:	e14b8b93          	addi	s7,s7,-492 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042ec:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02042f0:	e03fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02042f4:	00054a63          	bltz	a0,ffffffffc0204308 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042f8:	00a95a63          	bge	s2,a0,ffffffffc020430c <readline+0x54>
ffffffffc02042fc:	029a5263          	bge	s4,s1,ffffffffc0204320 <readline+0x68>
        c = getchar();
ffffffffc0204300:	df3fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204304:	fe055ae3          	bgez	a0,ffffffffc02042f8 <readline+0x40>
            return NULL;
ffffffffc0204308:	4501                	li	a0,0
ffffffffc020430a:	a091                	j	ffffffffc020434e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020430c:	03351463          	bne	a0,s3,ffffffffc0204334 <readline+0x7c>
ffffffffc0204310:	e8a9                	bnez	s1,ffffffffc0204362 <readline+0xaa>
        c = getchar();
ffffffffc0204312:	de1fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204316:	fe0549e3          	bltz	a0,ffffffffc0204308 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020431a:	fea959e3          	bge	s2,a0,ffffffffc020430c <readline+0x54>
ffffffffc020431e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204320:	e42a                	sd	a0,8(sp)
ffffffffc0204322:	dcffb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0204326:	6522                	ld	a0,8(sp)
ffffffffc0204328:	009b87b3          	add	a5,s7,s1
ffffffffc020432c:	2485                	addiw	s1,s1,1
ffffffffc020432e:	00a78023          	sb	a0,0(a5)
ffffffffc0204332:	bf7d                	j	ffffffffc02042f0 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204334:	01550463          	beq	a0,s5,ffffffffc020433c <readline+0x84>
ffffffffc0204338:	fb651ce3          	bne	a0,s6,ffffffffc02042f0 <readline+0x38>
            cputchar(c);
ffffffffc020433c:	db5fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204340:	0000d517          	auipc	a0,0xd
ffffffffc0204344:	db850513          	addi	a0,a0,-584 # ffffffffc02110f8 <buf>
ffffffffc0204348:	94aa                	add	s1,s1,a0
ffffffffc020434a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020434e:	60a6                	ld	ra,72(sp)
ffffffffc0204350:	6486                	ld	s1,64(sp)
ffffffffc0204352:	7962                	ld	s2,56(sp)
ffffffffc0204354:	79c2                	ld	s3,48(sp)
ffffffffc0204356:	7a22                	ld	s4,40(sp)
ffffffffc0204358:	7a82                	ld	s5,32(sp)
ffffffffc020435a:	6b62                	ld	s6,24(sp)
ffffffffc020435c:	6bc2                	ld	s7,16(sp)
ffffffffc020435e:	6161                	addi	sp,sp,80
ffffffffc0204360:	8082                	ret
            cputchar(c);
ffffffffc0204362:	4521                	li	a0,8
ffffffffc0204364:	d8dfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0204368:	34fd                	addiw	s1,s1,-1
ffffffffc020436a:	b759                	j	ffffffffc02042f0 <readline+0x38>

ffffffffc020436c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020436c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204370:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204372:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204374:	cb81                	beqz	a5,ffffffffc0204384 <strlen+0x18>
        cnt ++;
ffffffffc0204376:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204378:	00a707b3          	add	a5,a4,a0
ffffffffc020437c:	0007c783          	lbu	a5,0(a5)
ffffffffc0204380:	fbfd                	bnez	a5,ffffffffc0204376 <strlen+0xa>
ffffffffc0204382:	8082                	ret
    }
    return cnt;
}
ffffffffc0204384:	8082                	ret

ffffffffc0204386 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204386:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204388:	e589                	bnez	a1,ffffffffc0204392 <strnlen+0xc>
ffffffffc020438a:	a811                	j	ffffffffc020439e <strnlen+0x18>
        cnt ++;
ffffffffc020438c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020438e:	00f58863          	beq	a1,a5,ffffffffc020439e <strnlen+0x18>
ffffffffc0204392:	00f50733          	add	a4,a0,a5
ffffffffc0204396:	00074703          	lbu	a4,0(a4)
ffffffffc020439a:	fb6d                	bnez	a4,ffffffffc020438c <strnlen+0x6>
ffffffffc020439c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020439e:	852e                	mv	a0,a1
ffffffffc02043a0:	8082                	ret

ffffffffc02043a2 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02043a2:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02043a4:	0005c703          	lbu	a4,0(a1)
ffffffffc02043a8:	0785                	addi	a5,a5,1
ffffffffc02043aa:	0585                	addi	a1,a1,1
ffffffffc02043ac:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02043b0:	fb75                	bnez	a4,ffffffffc02043a4 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02043b2:	8082                	ret

ffffffffc02043b4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02043b4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02043b8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02043bc:	cb89                	beqz	a5,ffffffffc02043ce <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02043be:	0505                	addi	a0,a0,1
ffffffffc02043c0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02043c2:	fee789e3          	beq	a5,a4,ffffffffc02043b4 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02043c6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02043ca:	9d19                	subw	a0,a0,a4
ffffffffc02043cc:	8082                	ret
ffffffffc02043ce:	4501                	li	a0,0
ffffffffc02043d0:	bfed                	j	ffffffffc02043ca <strcmp+0x16>

ffffffffc02043d2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02043d2:	00054783          	lbu	a5,0(a0)
ffffffffc02043d6:	c799                	beqz	a5,ffffffffc02043e4 <strchr+0x12>
        if (*s == c) {
ffffffffc02043d8:	00f58763          	beq	a1,a5,ffffffffc02043e6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02043dc:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02043e0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02043e2:	fbfd                	bnez	a5,ffffffffc02043d8 <strchr+0x6>
    }
    return NULL;
ffffffffc02043e4:	4501                	li	a0,0
}
ffffffffc02043e6:	8082                	ret

ffffffffc02043e8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02043e8:	ca01                	beqz	a2,ffffffffc02043f8 <memset+0x10>
ffffffffc02043ea:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02043ec:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02043ee:	0785                	addi	a5,a5,1
ffffffffc02043f0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02043f4:	fec79de3          	bne	a5,a2,ffffffffc02043ee <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02043f8:	8082                	ret

ffffffffc02043fa <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02043fa:	ca19                	beqz	a2,ffffffffc0204410 <memcpy+0x16>
ffffffffc02043fc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02043fe:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204400:	0005c703          	lbu	a4,0(a1)
ffffffffc0204404:	0585                	addi	a1,a1,1
ffffffffc0204406:	0785                	addi	a5,a5,1
ffffffffc0204408:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020440c:	fec59ae3          	bne	a1,a2,ffffffffc0204400 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204410:	8082                	ret
