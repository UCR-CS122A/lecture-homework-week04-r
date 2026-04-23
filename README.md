# Lecture Homework Week 04 - Thursday

For this lecture homework, you will explore calling C subroutines from within Assembly Language code.

## Getting the Code

As with the previous lecture homework, this assignment is hosted on GitHub. You will create your own repository using the assignment repository as a template. To do this:

1.  Click on **"Use this template."**
2.  Select **"Create a new repository."**
3.  Give your repository a descriptive name.
4.  Click **"Create repository."**

Once created, clone the repository and open it in a GitHub Codespace to begin working.

## The Assembly Code

The following ARM assembly language code calls a function written in C. This C code is discussed below in the section [The C Code](https://www.google.com/search?q=%23the-c-code).

```asm
.text
        .global start, sum

start:
        ldr sp, =stack_top // need a stack to make calls
        ldr r2, =a
        ldr r0, [r2]       // r0 = a
        ldr r2, =b
        ldr r1, [r2]       // r1 = b
        bl sum             // c = sum(a,b)
        ldr r2, =c
        str r0, [r2]       // store return value in c
stop:   b stop

        .data
a:      .word 1
b:      .word 2
c:      .word 0
```

This code comes from section 2.7.3.5 of the textbook and is referred to as **C2.4**.

The assembly code performs three basic tasks:

1.  It sets up two global names, `start` and `sum`.
2.  It implements the `start` subroutine.
3.  It defines and initializes the labels `a`, `b`, and `c`. These labels act as global variables.

The `start` subroutine is similar to `main` in C programs; technically, it is the entry point that would normally call `main`. It establishes the stack for subroutine calls, calls the C subroutine `sum`, stores the return value in the global variable `c`, and then enters an infinite loop.

## The C Code

The following C code takes two arguments, `x` and `y`, and returns their sum. It is called from the assembly code discussed in [The Assembly Code](https://www.google.com/search?q=%23the-assembly-code).

```c
int sum(int x, int y) { 
    return x + y; 
} 
```

This code also comes from section 2.7.3.5 of the textbook and is included in the code referred to as **C2.4**.

## C Function Calling Convention

In section 2.7.3.2, the book outlines the calling convention for C functions. This convention defines the exact steps all C code follows when calling a function. By following this convention, you ensure your code is universally usable by any other compiled code.

According to the book, this convention follows these steps:

| Role | Step |
| :--- | :--- |
| **Caller** | 1. Load first four parameters in `r0–r3`; push any extra parameters on stack. |
| **Caller** | 2. Transfer control to callee via `BL` call. |
| **Callee** | 3. Save `LR`, `FP` (r11/r12) on stack; establish stack frame (FP points at saved LR). |
| **Callee** | 4. Shift `SP` downward to allocate local variables and temp spaces on stack. |
| **Callee** | 5. Use parameters, locals, and globals to perform the function task. |
| **Callee** | 6. Compute and load return value in `r0`, pop stack to return control to caller. |
| **Caller** | 7. Get return value from `r0`. |
| **Caller** | 8. Clean up stack by popping off extra parameters, if any. |

The **Caller** steps apply to the code initiating the call, while the **Callee** steps are part of the function being called.

### Example Trace

**1. Load parameters into r0–r1:**

```asm
        ldr r2, =a
        ldr r0, [r2] // r0 = a
        ldr r2, =b
        ldr r1, [r2] // r1 = b
```

**2. Transfer control:**

```asm
       bl sum // c = sum(a,b)
```

The callee is a C function. Below is the generated assembly for that C code:

```asm
        str     fp, [sp, #-4]!
        add     fp, sp, #0
        sub     sp, sp, #12
        str     r0, [fp, #-8]
        str     r1, [fp, #-12]
        ldr     r2, [fp, #-8]
        ldr     r3, [fp, #-12]
        add     r3, r2, r3
        mov     r0, r3
        add     sp, fp, #0
        @ sp needed
        ldr     fp, [sp], #4
        bx      lr
```

**3. Save FP and establish stack frame:**

```asm
str     fp, [sp, #-4]! 
```

**4. Allocate stack space:**

```asm
        add     fp, sp, #0
        sub     sp, sp, #12
```

**5. Perform task:**

```asm
        str     r0, [fp, #-8]
        str     r1, [fp, #-12]
        ldr     r2, [fp, #-8]
        ldr     r3, [fp, #-12]
        add     r3, r2, r3
        mov     r0, r3
```

**6. Restore stack and return:**

```asm
        add     sp, fp, #0
        ldr     fp, [sp], #4
        bx      lr
```

**7. Get return value (back in start.s):**

```asm
        ldr r2, =c
        str r0, [r2] // store return value in c
```

-----

## Exercise from the Book

Complete **Problem 3** on page 44 of the book.

> **Problem 3:** In example program C2.4, instead of defining `a`, `b`, and `c` in the assembly code, define them as initialized globals in the `sum.c` file:

```c
int a = 1, b = 2, c = 0;
```

**Instructions:**

1.  Find where `a`, `b`, and `c` are defined in `src/start.s` and remove them.
2.  In `src/sum.c`, add these variables as initialized globals.

### Compiling the Code

Use the VS Code CMake extension or the terminal:

```bash
mkdir build
cmake -S . -B build
cmake --build build
```

### Executing the Program in QEMU

First, identify the memory addresses for `a`, `b`, and `c` using the `nm` tool:

```bash
arm-none-eabi-nm build/c_from_asm.elf
```

You should see output similar to:

```text
XXXXXXXX d a
XXXXXXXX d b
XXXXXXXX d c
```

*Note the hexadecimal addresses for the next step.*

Next, execute the program in QEMU:

```bash
qemu-system-arm -M versatilepb -m 128M -kernel build/c_from_asm.bin -nographic -serial /dev/null
```

### Exploring Results

Once you see the `(qemu)` prompt, use the `xp` command to inspect memory:

```bash
(qemu) xp /wd 0xXXXXXXXX
```

Replace `0xXXXXXXXX` with the address of `a` you found earlier. Repeat this for `b` and `c`.

-----

## What to Turn In

The files `src/start.s` and `src/sum.c` should contain your modified code. Fill out the table below with the values you observed in QEMU:

| Variable name | Value |
| :-----------: | :---: |
| `a`           |       |
| `b`           |       |
| `c`           |       |

1.  Commit and push your changes to your GitHub repository.
2.  Submit the assignment via **Gradescope**.
3.  Select your repository when prompted.
