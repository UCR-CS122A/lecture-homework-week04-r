# Lecture Homework Week 04 - Thursday

For this lecture homework you will explore calling C subroutines from within Assembly
Language code.

## Getting the Code

As with the previous lecture homework, this assignment is hosted on GitHub. You will create your own repository using the assignment repository as a template. To do this:

1. Click on "Use this template."
2. Select "Create a new repository."
3. Give your repository a descriptive name.
4. Click "Create repository."

Once created, clone the repository, open it in a GitHub Codespace to begin working.

## The Assembly Code

The following ARM assembly language code simply calls a function written in C. This C
code is discussed below in the section called ["The C Code"](#the-c-code).

```asm
.text
        .global start, sum

start:
        ldr sp, =stack_top // need a stack to make calls
        ldr r2, =a
        ldr r0, [r2] // r0 = a
        ldr r2, =b
        ldr r1, [r2] // r1 = b
        bl sum // c = sum(a,b)
        ldr r2, =c
        str r0, [r2] // store return value in c
stop:   b stop

        .data
a:      .word 1
b:      .word 2
c:      .word 0
```

This code comes from section 2.7.3.5 of the book, and is refereed to as C2.4. 

The assembly code does three basic things. First, it sets up two global names, `start`
and `sum`. These are the two subroutines defined in this file. Second, it shows the
implementation of two subroutines, `start` and `sum`. Finally, it defines and initializes
the labels `a`, `b`, and `c`. These three labels are basically global variables defined
in this file.

As for what the subroutines do, the `start` subroutine is similar to `main` from C 
programs. Actually, it's what would normally call `main`. It establishes the stack
for subroutine calls, and then instead of calling `main`, calls a subroutine `sum`,
which is written in C. It goes on to store the return value in the global variable 
`c`, and then loops infinitely.

## The C Code

The following C code takes in two arguments, `x` and `y`, and returns their sum. It
is called from the assembly code discussed above in the section ["The Assembly Code"](#the-assembly-code).

```c
int sum(int x, int y) { 
    return x + y; 
} 
```

This code also comes from section 2.7.3.5 of the text book and is included in the code 
referred to as C2.4.

## C Function Calling Convention

In section 2.7.3.2 the book outlines the calling convention for C functions. This 
convention outlines the exact steps all C code follows when calling a function when
compiled. By following this convention you are guaranteed that the code can be called
by any other compiled code. Regardless of which language you use, following this 
convention will make your code universally usable.

This convention, according to the book, has the following steps:

|                                                                                   |
|-----------------------------------------------------------------------------------|
| <div align="center">**Caller**</div>                                              |
| 1. Load first four parameters in r0–r3; push any extra parameters on stack.       |
| 2. Transfers control to callee by BL call.                                        |
| <div align="center">**Callee**</div>                                              |
| 3. Save LR, FP(r12) on stack; establish stack frame (FP point at saved LR).       |
| 4. Shift SP downward to allocate local variables and temp spaces on stack.        |
| 5. Use parameters, locals (and globals), to perform the function task.            |
| 6. Compute and load return value in R0, pop stack to return control to caller.    |
| <div align="center">**Caller**</div>                                              |
| 7. Get return value from R0.                                                      |
| 8. Clean up stack by popping off extra parameters, if any.                        |

The steps associated with **Caller** apply the the coded that calls the function and
takes place before and after the actualy code of the function is executed. Similarly,
the steps associated with **Callee** are part of the function that is being called.

We see these steps in the code above. 

1. Load first four parameters in r0–r3; push any extra parameters on stack.
```asm
        ldr r2, =a
        ldr r0, [r2] // r0 = a
        ldr r2, =b
        ldr r1, [r2] // r1 = b
```
2. Transfers control to callee by BL call.
```asm
       bl sum // c = sum(a,b)
```

The callee in this case is a C function, not assembly. So let's look at the assembly of the C code:

```asm
        str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	ldr	r2, [fp, #-8]
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	mov	r0, r3
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
```

So now we have:

3. Save LR, FP(r12) on stack; establish stack frame (FP point at saved LR).
```asm
str	fp, [sp, #-4]! 
```

4. Shift SP downward to allocate local variables and temp spaces on stack.
```asm
	add	fp, sp, #0
	sub	sp, sp, #12
```

5. Use parameters, locals (and globals), to perform the function task.
```asm
        str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	ldr	r2, [fp, #-8]
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	mov	r0, r3
```

6. Compute and load return value in R0, pop stack to return control to caller.
```asm
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
```

Now back to the assembly above: 

7. Get return value from R0.
```asm
        ldr r2, =c
        str r0, [r2] // store return value in c
```

8. Clean up stack by popping off extra parameters, if any.

Nothing in this code.

## Exercise from the Book

Now do problem 3 on page 44 of the book. 

3. In the example program C2.4, instead of defining a, b, and c in the assembly code, define 
them as initialized globals in the t.c file (we called in `sum.c` in this a repository):

```c
int a = 1, b = 2, c = 0;
```

First, find where `a`, `b`, and `c` are defined in `start.s`, and remove it. Then in the C code
add these variables, with the same values from the assembly code.

### Compiling the code

To compile the code, either use the VS Code CMake extension to build it, or use the terminal. The 
following commands will compile the code using CMake:

```base
mkdir build
cmake -S . -B build
cmake --build build
```

### Executing the program in QEMU

Before we execute the program, we want to know what address the variables `a`, `b`, and `c, are 
stored in. The following command will reveal the address:

```bash
arm-none-eabi build/c_from_asm.elf
```
You should see output similar to the following:

```bash
00010070 T _fini
00010064 T _init
XXXXXXXX d a
XXXXXXXX d b
XXXXXXXX d c
00011088 D stack_top
00010000 T start
00010020 t stop
00010034 T sum
```

The `XXXXXXXX` is the actual address of these variables. Note these values for later.

Next you will execute the program in QEMU with the following command:

```bash
qemu-system-arm -M versatilepb -m 128M -kernel build/c_from_asm.bin -nographic -serial /dev/null
```

You should then see something like the following in the terminal:

```bash
(qemu)
```

### Exploring the results of running the program

Now let's look at the values of `a`, `b`, and `c`. The following command will give the value of the
variable `a`:

```bash
(qemu) xp /wd 0xXXXXXXXX
```

Where 0xXXXXXXXX is the address you found from using the `arm-none-eabi-nm` command above. You should
see something similar to the following:

```bash
00000000XXXXXXXX:          1
```

Do the same for the other variables `b` and `c`.


## What to Turn In

The files `src/start.s` and `src/sum.c` should have the code from problem 3. Also, fill the following
table, here in the `README.md` with the values of the variables `a`, `b`, and `c`.

|Variable name|Value|
|:-----------:|-----|
|`a`          |     |
|`b`          |     |
|`c`          |     |

1.    Submit your work by committing and pushing your changes to your GitHub repository.
2.    Upload the assignment via Gradescope.
3.    When prompted, log in to GitHub, select your homework repository, and submit.
