// Originally ts.s from Program 2.4
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
        