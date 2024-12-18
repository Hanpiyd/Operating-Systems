## Lab5实验报告

### 一.实验内容

**练习0：填写已有实验**
本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

**练习1: 加载应用程序并执行（需要编码）**
do_execv函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充load_icode的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

* 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

**练习2: 父进程复制自己的内存空间给子进程（需要编码）**
创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。

* 请在实验报告中简要说明你的设计实现过程。


如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。
Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

**练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）**
请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

* 请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？

* 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）

执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

**扩展练习 Challenge**
1. 实现 Copy on Write （COW）机制

    给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

    这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。

    由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。

    这是一个big challenge.

2. 说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？


### 二.练习1实验过程
load_icode函数实现解析并加载 ELF 格式的程序到进程空间中，并设置进程的栈、代码段、数据段、上下文等内容，以便进程实现从内核模式切换到用户模式，开始执行新加载的程序。
``` cpp
    /* LAB5:EXERCISE1 YOUR CODE
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */
    // 设置 tf->gpr.sp 为用户栈栈顶
    tf->gpr.sp = USTACKTOP;
    // 设置 tf->epc 为用户程序的入口地址
    tf->epc = elf->e_entry;
    // 设置 tf->status 为用户态
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;

```
#### 问题二：请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。


- 1.user_main通过调用KERNEL_EXECVE执行用户进程。__KERNEL_EXECVE通过kernel_execve函数的ebreak指令触发一个异常，进入内核态，执行系统调用，触发内核的中断处理，通过trap函数转发这些系统调用。然后调用sys_exec，停止原先正在运行的程序，开始执行一个新程序。PID不变，但是内存空间要重新分配，执行的机器代码发生了改变。

- 2.sys_exec调用do_execve函数释放旧的内存空间。
·
- 3.sys_exec调用load_icode函数解析并加载 ELF 格式的程序到进程空间中。load_icode函数执行过程如下：
 - 通过mm_create函数创建并初始化新的内存管理结构体 mm_struct。
 - 通过setup_pgdir函数建立页目录表。
 - 加载 ELF 文件内容，解析 ELF 文件的头部，这些头部描述了程序的各个段，如 .text、.data 和 .bss 等。然后检查 ELF 格式是否有效。遍历 ELF 文件的所有程序头，只处理类型为 ELF_PT_LOAD （即需要加载到内存的段。）的段。然后通过mm_map函数为每个段在进程的虚拟内存空间中映射相应的区域。将 ELF 文件的内容复制到进程内存。对于 BSS 段（未初始化的全局变量），将其内存区域清零。
 - 通过mm_map函数为用户栈分配256个页大小的虚拟内存，更新用户进程的虚拟内存空间。
 - 然后重新设置进程的中断帧，sepc寄存器是产生异常的指令的位置，在异常处理结束后，会回到sepc的位置继续执行，也就是 ELF 的入口地址。
### 三.练习2实验过程
#### 问题一：补充copy_range的实现
copy_range函数用于按页从父进程到子进程复制一段地址范围的内容，它的调用过程为do_fork()->copy_mm()->dup_mmap()->copy_range()。
copy_range()实现过程如下：首先检查地址是否按页对其并在用户可访问的内存范围。它通过 get_pte 函数获
取PTE并检查其有效性，然后为新建的页分配PTE，然后进行赋值操作。页复制过程如下：
- 首先通过page2kva函数获得 page 的虚拟地址 src_kvaddr。
- 通过page2kva函数获得 npage 的虚拟地址dst_kvaddr。
- 然后通过memcpy函数将虚拟地址src_kvaddr按页大小复制到dst_kvaddr。
- 最好通过page_insert函数在子进程的页表中里建立映射关系。

```cpp
/* LAB5:EXERCISE2 YOUR CODE
* replicate content of page to npage, build the map of phy addr of
* nage with the linear addr start
*
* Some Useful MACROs and DEFINEs, you can use them in below
* implementation.
* MACROs or Functions:
*    page2kva(struct Page *page): return the kernel vritual addr of
* memory which page managed (SEE pmm.h)
*    page_insert: build the map of phy addr of an Page with the
* linear addr la
*    memcpy: typical memory copy function
*
* (1) find src_kvaddr: the kernel virtual address of page
* (2) find dst_kvaddr: the kernel virtual address of npage
* (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
* (4) build the map of phy addr of  nage with the linear addr start
*/
void *src_kvaddr = page2kva(page);
void *dst_kvaddr = page2kva(npage);
memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ret = page_insert(to, npage, start, perm);
```
#### 问题二：Copy on Write机制的概要设计
Copy on Write (COW) 是提高内存使用效率并减少不必要的内存复制操作。COW在多个进程共享同一内存页面时，直到其中某个进程需要修改该内存页面时，才为其分配一个新的副本。这样，在不需要修改的情况下，多个进程可以共享相同的内存，从而节省内存资源。在本次实验父进程创建子进程的过程中，是将内存空间进行直接复制。这固然很简单，但也开销较大。

- 在fork时，首先将父进程的内存权限设为只读。
- 然后在子进程想要“复制”父进程的内存空间时，并不直接进行创建物理页并复制，而是先考虑将子进程的虚拟页映射到父进程的物理页。
- 当进程修改共享页时，会触发page_fault中断，此时需要判断异常是否为写只读页面。如果是，则按照原先的做法，新分配一个物理页并进行复制，修改该共享页的引用次数，判断引用数是否为1。如果是，则恢复原来的写权限。最后修改子进程的页表，建立新的映射关系。

### 四.练习3实验过程
fork、exec、wait和exit函数都是在user/libs/ulib.c下定义的函数，它们在ucore作为系统调用接口使用，经过分析我们可以很明显发现事实上这几个函数执行的功能最后都是调用位于内核态的sys_fork、sys_exec、sys_wait和sys_exit函数，因此我们先分析这四个函数。进入kern/syscall/syscall.c，就可以看到四个函数的具体实现：

```C
static int
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}
```

首先是sys_fork函数，根据课上所学的知识和实验指导书的内容我们可以知道它的功能就是根据父进程创建子进程，因此该函数的功能就是将当前进程的中断帧和中断帧的SP寄存器的值作为参数传给do_fork函数，由fork函数完成剩下的工作。由于do_fork是练习2完成的内容，我们这里就不再赘述了。

```C
static int
sys_exec(uint64_t arg[]) {
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}
```
接着就是sys_exec函数，它读取了当前进程的名字、名字长度、程序的首地址以及程序大小，并将其作为参数调用do_execve函数完成剩下的工作。

```C
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
    struct mm_struct *mm = current->mm;
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
        return -E_INVAL;
    }
    if (len > PROC_NAME_LEN) {
        len = PROC_NAME_LEN;
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);

    if (mm != NULL) {
        cputs("mm != NULL");
        lcr3(boot_cr3);
        if (mm_count_dec(mm) == 0) {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
```
do_execve函数会先判断当前进程是否为用户进程（我们根据前面的内容可以知道mm如果不为NULL那它就应该是用户进程），如果为用户进程我们先切换页目录表，接着如果这片内存没有进程再使用就将其回收，将旧程序清空，再调用load_icode函数将新程序引进来，完成在同一个进程下不同程序的切换。当然，load_icode也是我们本次练习一完成的工作，因此这里也不再赘述了。

```C
static int
sys_wait(uint64_t arg[]) {
    int pid = (int)arg[0];
    int *store = (int *)arg[1];
    return do_wait(pid, store);
}
```
接下来是sys_wait函数，它通过传递的参数获取到pid和store两个变量，其中pid是等待子进程的进程标识符，而store则是子进程的退出状态，接着将这两个变量作为参数调用do_wait完成剩下的工作。

```C
int
do_wait(int pid, int *code_store) {
    struct mm_struct *mm = current->mm;
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        if (current->flags & PF_EXITING) {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
```
do_wait函数首先会判断参数是否合法，接着根据参数pid来寻找相应子进程：如果pid为0那么父进程会等待任意的子进程退出，而如果pid不为0父进程则等待指定等待子进程。当子进程的状态变为ZOMBIE（退出态）时，父进程就完成资源的回收，否则父进程进入SLEEPING（等待态）等待子进程退出，同时调用schedule函数调度其他进程执行工作。当子进程退出时，父进程通过exit_code获得子进程的退出状态，接着完成子进程的资源-主要是PCB（proc_struct）和内核栈的回收，之后结束工作。

```C
static int
sys_exit(uint64_t arg[]) {
    int error_code = (int)arg[0];
    return do_exit(error_code);
}
```
最后是用于进程主动退出的sys_exit函数，退出函数也只是完成了获取error_code变量，接着将其作为参数调用do_exit函数完成剩下的工作。

```C
int
do_exit(int error_code) {
    if (current == idleproc) {
        panic("idleproc exit.\n");
    }
    if (current == initproc) {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
    if (mm != NULL) {
        lcr3(boot_cr3);
        if (mm_count_dec(mm) == 0) {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code;
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
            proc = current->cptr;
            current->cptr = proc->optr;
    
            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL) {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE) {
                if (initproc->wait_state == WT_CHILD) {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
    panic("do_exit will not return!! %d.\n", current->pid);
}
```
do_exit函数会先判断进程的类型，如果是用户进程会先切换页目录表，接着检查当前内存是否还有引用来确定是否需要进行释放，接着将自己的状态设为ZOMBIE，并将error_code作为exit_code(好像似曾相识，没错，我们在do_wait函数用到了)接着准备完成进程的唤醒工作，当然为了保证万无一失我们要先通过开关中断来构造一个中断屏蔽区，我们先唤醒父进程，接着将所有的子进程挂靠在InitProc下，如果所有的子进程也进入ZOMBIE状态，那么也唤醒InitProc即可，最后完成进程调度就可以结束了。

那么介绍完最重要的部分，我们可以从头捋一下整个系统调用的过程了。当然，因为它们太过大同小异，因此这里只以fork函数为例。
```C
int
fork(void) {
    return sys_fork();
}
```
首先，用户态的用户进程调用fork函数（接口）希望进行系统调用，fork函数的工作就是将工作转交给sys_fork函数。

```C
static inline int
syscall(int64_t num, ...) {
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
    }
    va_end(ap);

    asm volatile (
        "ld a0, %1\n"
        "ld a1, %2\n"
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
    	"ld a5, %6\n"
        "ecall\n"
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}

int
sys_fork(void) {
    return syscall(SYS_fork);
}
```
sys_fork函数通过事先准备好的系统调用编号（位于libs/unistd.h）作为参数，调用了syscall函数，该函数依次读取传入的参数后，通过ecall指令陷入内核态，此时正式完成状态的切换。

```C
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
        ......
        case CAUSE_USER_ECALL:
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        ......
    }
}
```
当内核态的异常处理函数通过读取cause寄存器检测到用户态的系统调用时，就会将工作再次转交给专业的syscall函数处理。

```C
static int
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}

static int (*syscalls[])(uint64_t arg[]) = {
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
        if (syscalls[num] != NULL) {
            arg[0] = tf->gpr.a1;
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
            return ;
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
```
syscall函数会读取中断帧和参数（主要是num），来确定系统调用的类型，从而调用相应的函数指针，这一分配过程则是通过函数指针数组syscalls来实现，这里用到了指定初始化器的语法，例如当传入的num是SYS_kill，那么syscalls[num]就是sys_kill的函数指针，从而实现了对于系统调用的分配。后面的过程我们前面已经详细介绍过了。

因此总结一下fork/exec/wait/exit的执行流程：

1.用户进程通过user/libs/ulib.c的系统调用接口（fork/exec/wait/exit函数）进行系统调用

2.fork/exec/wait/exit函数会调用user/libs/syscall.c中的sys_fork/sys_exec/sys_exit/sys_wait函数

3.sys_fork/sys_exec/sys_exit/sys_wait函数会携带上各自的调用编号调用user/libs/syscall.c中的syscall函数，通过其中的ecall指令完成理论上的状态切换。

4.陷入到内核态的trap，通过exception_handler处理转到内核态的syscall函数

5.通过用户态传递的参数num分配到具体的函数进行处理（kern/syscall/syscall.c中的sys_fork/sys_exec/sys_exit/sys_wait函数）

6.sys_fork/sys_exec/sys_exit/sys_wait函数最后会调用proc.c的do_fork/do_exec/do_exit/do_wait函数完成最后的工作。

下面是一个用户态进程的执行状态生命周期图：

```
(alloc_proc)            (proc_init/wakeup_proc)
---------------> PROC_UNINIT -----------------> PROC_RUNNABLE
                                                    |
                                                    |
                                                    | (proc_run)
                                                    |
                 (do_wait/do_sleep/ try_free_pages) V    (do_exit)
  PROC_SLEEPING <--------------------------------RUNNING------------->PROC_ZOMBIE
        |                                           A
        |                                           | 
        |                                           |
        |                                           |
        +-------------------------------------------+
                        (wakeup_proc)  
```


### 五.Challenge实验过程
#### 1.Challenge1
首先，我们先了解一下什么是COW：Copy on Write（COW，写时复制）是一种优化技术，通常用于提高程序效率，特别是在内存管理方面。其基本思想是在进行复制操作时，只有在实际需要修改数据时才会进行复制，从而避免不必要的复制，节省内存和提高性能。

那么什么时候会涉及到页面的复制呢，当然是fork，因此我们先改变一下fork函数，在fork时将父进程的空间设为只读，再将子进程的虚拟地址空间映射到父进程的物理页，二者共享内存空间。根据share的值来判断是否需要共享内存空间。如果需要，则通过page_insert将子进程的虚拟地址空间映射到父进程的物理页，否则，将父进程的内存空间复制给子进程。

```C
 if(share){
        page_insert(from, page, start, perm & (~PTE_W));
        ret = page_insert(to, page, start, perm & (~PTE_W));
    }
    else{
        struct Page *npage = alloc_page();
        assert(npage != NULL);
        void* src_kvaddr = page2kva(page);
        void* dst_kvaddr = page2kva(npage);
        memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
        ret = page_insert(to, npage, start, perm);
    }
```

当然，不会只改这一处，接着就是修改do_pgfault函数，当发生缺页中断时，判断是否是写一个只读页面。如果是，则需要将页面复制一份，然后修改子进程的页表，建立新的映射关系，使得子进程的内存空间与父进程的内存空间分离。另外还需查看原来共享的物理页是否只有一个进程在使用，如果是，需恢复原来的读写权限。

```C
    else if((*ptep & PTE_V) && (error_code == 0xf)) {
        struct Page *page = pte2page(*ptep);
        if(page_ref(page) == 1) {
            page_insert(mm->pgdir, page, addr, perm);
        }
        else {
            struct Page *npage = alloc_page();
            assert(npage != NULL);
            memcpy(page2kva(npage), page2kva(page), PGSIZE);
            if(page_insert(mm->pgdir, npage, addr, perm) != 0) {
                cprintf("page_insert in do_pgfault failed\n");
                goto failed;
            }
        }
    }
```


#### 2.Challenge2
事实上，实验指导书上已经指明了本问题的答案：准备好的用户程序们在编译时就被放到了生成的内核镜像中。

事实上，这部分工作在现代OS中有着文件系统的大量参与，但是由于目前Ucore还没有实现，因此我们只能选择最原始的方法：想执行一个编译好的用户程序，我们就需要将其与内核一同编译，并将其链接到内核。通俗点讲，就是我们在内存准备一片区域，来专门存放我们的二进制文件。

常用操作系统是通过以下步骤来加载用户程序的：
1. 用户请求执行程序
2. 操作系统会创建一个新的进程来执行用户程序。操作系统通过 fork() 或类似机制来创建一个新的进程（在某些系统中是通过进程控制块 PCB 来管理进程），并为新进程分配一个唯一的进程ID（PID）以及初步的资源（如内存空间、文件描述符等）。
3. 操作系统会读取程序的可执行文件（通常是 ELF 格式或 PE 格式）并将其加载到内存中。可执行文件通常包括程序代码、数据、符号表、调试信息等。
4. 完成程序的动态链接和库加载
5. 操作系统会为程序的代码段、数据段等分配合适的内存页，并将这些内存页映射到进程的虚拟地址空间。
6. 操作系统会为程序初始化必要的环境。比如，操作系统会设置一些环境变量、命令行参数等，并将它们传递给程序。
7. 程序执行

因此我们可以发现两者区别的原因就一点：Ucore还没有实现文件系统。


### 六.本实验重要的知识点
#### 权限转换
操作系统通常使用内核态和用户态来保证系统的安全性、稳定性以及进程之间的隔离。用户进程与内核的权限隔离有效防止了用户程序对系统资源的非法访问，同时又能高效地通过系统调用和中断机制与操作系统进行交互。如系统调用：用户进程需要执行操作系统服务时，它会通过系统调用进入内核态，如：read()、fork()、exec()等等。
