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
    .section .text
.equ LARGER_STACK_BYTECOUNT, 32
.equ MAX_DIGITS, 32768
.equ ADD_STACK_BYTECOUNT, 64
.equ UNSIGNED_LONG_SIZE, 8
.equ OADDEND1, 8
.equ OADDEND2, 16
.equ OSUM, 24
.equ LSUMLENGTH, 32
.equ ULCARRY, 40
.equ LINDEX, 48
.equ ULSUM, 56

.global BigInt_add

BigInt_larger:
    // Prolog
    sub sp, sp, LARGER_STACK_BYTECOUNT
    str x30, [sp]

    // Save lLength1
    str x0, [sp, OADDEND2]
    // Save lLength2
    str x1, [sp, OADDEND1]

    // load lLength1
    ldr x0, [sp, OADDEND2]
    // load lLength2
    ldr x1, [sp, OADDEND1]

    // if (lLength1 <= lLength2) goto else1;
    cmp x0, x1
    ble else1

    // lLarger = lLength1;
    // no change required
    b endif1

    else1:
    str x0, [sp, OADDEND1]
    ldr x0, [sp, OADDEND1]

    ldr x30, [sp]
    add sp, sp, 16

    endif1:
    ret
    .size BigInt_larger, (. - BigInt_larger)

BigInt_add:
    // Prolog
    sub sp, sp, 64
    str x30, [sp]

    // Save oAddend1
    str x0, [sp, OADDEND1]
    // Save oAddend2
    str x1, [sp, OADDEND2]
    // Save oSum
    str x2, [sp, OSUM]

    // Load parameters
    ldr x0, [sp, OADDEND1]
    ldr x1, [sp, OADDEND2]
    ldr x2, [sp, OSUM]

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    bl BigInt_larger
    str x0, [sp, 32]
    
    // Load oSum
    ldr x0, [sp, OSUM]
    ldr x1, [sp, 32]

    cmp x0, x1
    ble endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr x0, [sp, OSUM]
    add x0, x0, UNSIGNED_LONG_SIZE
    mov x1, 0
    mov x2, MAX_DIGITS
    mov x3, UNSIGNED_LONG_SIZE
    mul x2, x2, x3
    bl memset

    endif2:
    // ulCarry = 0;
    mov x0, 0
    str x0, [sp, 40]

    // lIndex = 0
    mov x1, 0
    str x2, [sp, 48]

    loop1:
        // if(lIndex >= lSumLength) goto endloop1;
        ldr x0, [sp, 48]
        ldr x1, [sp, 32]
        cmp x0, x1
        bge endloop1

        // ulSum = ulCarry;
        ldr x0, [sp, 40]
        str x0, [sp, 56]

        // ulCarry = 0;
        str xzr, [sp, 40]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [sp, OADDEND1]
        add x0, x0, 8
        ldr x1, [sp, 48]
        ldr x0, [x0, x1, lsl 3]
        ldr x3, [sp, 56]
        add x3, x3, x0
        str x3, [sp, 56]

        cmp x3, x0
        bge endif3

        // ulCarry = 1;
        mov x4, 1
        str x4, [sp, 40]

        endif3:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr x0, [sp, OADDEND2]
        add x0, x0, 8
        ldr x1, [sp, 48]
        mov x2, x1
        ldr x0, [x0, x2, lsl 3]
        ldr x3, [sp, 56]
        add x3, x3, x0
        str x3, [sp, 56]

        cmp x3, x0
        bge endif4

        // ulCarry = 1;
        mov x4, 1
        str x4, [sp, 40]

        endif4:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr x0, [sp, OSUM]
        add x0, x0, 8
        ldr x1, [sp, 48]
        ldr x3, [sp, 56]
        str x3, [x0, x1, lsl 3]

        // lIndex = lIndex + 1;
        ldr x0, [sp, 48]
        add x0, x0, 1
        str x0, [sp, 48]

        b loop1

    endloop1:
        // if(ulCarry != 1) goto endif5;
        ldr x0, [sp, 40]
        cmp x0, 1
        bne endif5

        //if(lSumLength != MAX_DIGITS) goto endif6;
        ldr x0, [sp, 32]
        mov x1, MAX_DIGITS
        cmp x0, x1
        bne endif6
        ldr x0, FALSE

        endif6:
        // oSum -> aulDigits[lSumLength] = 1;
        ldr x0, [sp, OSUM]
        add x0, x0, 8
        ldr x1, [sp, 32]
        mov x3, 1
        str x3, [x0, x1, lsl 3]

        // lSumLength++;
        add x1, x1, 1
        str x1, [sp, 32]

        endif5:
        //oSum->lLength = lSumLength;
        ldr x0, [sp, OSUM]
        ldr x1, [sp, 32]
        str x1, [x0]

        // pop sp??
        ldr x30, [sp]
        add sp, sp, 64

        mov x0, TRUE

        ret
    .size BigInt_add, (. - BigInt_add)



