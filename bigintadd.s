//-------------------------------
// bigintadd.s
// Authors: Nadja and Kat
//----------------------------------------
    .equ FALSE, 0
    .equ TRUE, 1
//----------------------------------------
    .section .rodata
printfFormatStr:
    .string "%7ld %7ld %7ld\n"
//newline:
//    .quad '\n'
//----------------------------------------

.equ LARGER_STACK_BYTECOUNT, 32
.equ ADD_STACK_BYTECOUNT, 56
.equ ZERO, 0
.equ UNSIGNED_LONG_SIZE, 8

bigintlarger:
    // Prolog
    sub sp, sp, LARGER_STACK_BYTECOUNT
    str x30, [sp]

    // Save lLength1
    str x0, [sp, 16]
    // Save lLength2
    str x1, [sp, 8]

    // load lLength1
    ldr x0, [sp, 16]
    // load lLength2
    ldr x1, [sp, 8]

    // if (lLength1 <= lLength2) goto else1;
    cmp x0, x1
    ble else1

    // lLarger = lLength1;
    // no change required
    b endif1

    else1:
    str x0, [sp, 8]
    ldr x0, [sp, 8]

    ldr x30, [sp]
    add sp, sp, 16

    endif1:
    ret

bigintadd:
    // Prolog
    sub sp, sp, ADD_STACK_BYTECOUNT
    str x30, [sp]

    // Save oAddend1
    str x0, [sp, 8]
    // Save oAddend2
    str x1, [sp, 16]
    // Save oSum
    str x2, [sp, 24]

    // Load parameters
    ldr x0, [sp, 8]
    ldr x1, [sp, 16]
    ldr x2, [sp, 24]

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    bl bigintlarger
    str x0, [sp, 32]
    
    // Load oSum
    ldr x0, [sp, 24]
    ldr x1, [sp, 32]

    cmp x0, x1
    ble endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr x0, [sp, 24]
    add x0, x0, 8
    ldr x1, ZERO
    ldr x2, MAX_DIGITS
    ldr x3, UNSIGNED_LONG_SIZE
    mul x2, x2, x3
    bl memset

    endif2:
    // ulCarry = 0;
    ldr x0, ZERO
    str x0, [sp, 40]

    // lIndex = 0
    ldr x1, ZERO
    str x2, [sp, 48]

    loop1:





