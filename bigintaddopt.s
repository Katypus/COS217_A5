//-------------------------------
// bigintaddopt.s
// Authors: Nadja and Kat
//----------------------------------------
    .equ FALSE, 0
    .equ TRUE, 1
//----------------------------------------
    .section .rodata
//----------------------------------------
    .section .text

// magic numbers
.equ LARGER_STACK_BYTECOUNT, 32
.equ MAX_DIGITS, 32768
.equ ADD_STACK_BYTECOUNT, 64
.equ UNSIGNED_LONG_SIZE, 8
.equ OFFSET, 8

// locations sp points to in BigInt_add
.equ OADDEND1, 8
.equ OADDEND2, 16
.equ OSUM, 24
.equ LSUMLENGTH, 32
.equ ULCARRY, 40
.equ LINDEX, 48
.equ ULSUM, 56
// locations sp points to in BigInt_larger
.equ LLENGTH1, 8
.equ LLENGTH2, 16
.equ LLARGER, 24

// registers for parameters
lLength1 .req x19
lLength2 .req x20
oAddend1 .req x22
oAddend2 .req x23
oSum .req x24

// registers for local variables
lLarger .req x21
lSumLength .req x25
ulCarry .req x26
ulSum .req x27
lIndex .req x28

.global BigInt_add

BigInt_larger:
    // Prolog
    sub sp, sp, LARGER_STACK_BYTECOUNT
    str x30, [sp]

    // Save x19
    str x19, [sp, LLENGTH1]
    // Save x20
    str x20, [sp, LLENGTH2]
    // Save x21
    str x21, [sp, LLARGER]

    // Save lLength1, lLength2
    mov lLength1, x0
    mov lLength2, x1

    // if (lLength1 <= lLength2) goto else1;
    cmp x0, x1
    ble else1
    // lLarger = lLength1;
    mov lLarger, lLength1
    b endif1

    else1:
    // lLarger = lLength2;
    mov lLarger, lLength2

    endif1:

    ldr x0, [sp, LLARGER]

    ldr x30, [sp]
    // Restore x19
    str x19, [sp, LLENGTH1]
    // Restore x20
    str x20, [sp, LLENGTH2]
    // Restore x21
    str x21, [sp, LLARGER]
    add sp, sp, LARGER_STACK_BYTECOUNT
    
    ret
    .size BigInt_larger, (. - BigInt_larger)

BigInt_add:
 // Prolog
    sub sp, sp, ADD_STACK_BYTECOUNT
    str x30, [sp]

    // Save oAddend1
    str x0, [sp, OADDEND1]
    // Save oAddend2
    str x1, [sp, OADDEND2]
    // Save oSum
    str x2, [sp, OSUM]

    // Load parameters
    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [sp, OADDEND1]
    ldr x1, [sp, OADDEND2]
    ldr x0, [x0, 0]
    ldr x1, [x1, 0]
    
    bl BigInt_larger
    str x0, [sp, LSUMLENGTH]
    
    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr x0, [sp, OSUM]
    ldr x1, [sp, LSUMLENGTH]
    ldr x0, [x0, 0]
    cmp x0, x1
    ble endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr x0, [sp, OSUM]
    add x0, x0, OFFSET
    mov w1, 0
    mov x2, MAX_DIGITS
    mov x3, UNSIGNED_LONG_SIZE
    mul x2, x2, x3
    bl memset

    endif2:
    // ulCarry = 0;
    str xzr, [sp, ULCARRY]
    
    // lIndex = 0
    str xzr, [sp, LINDEX]

    loop1:
        // if(lIndex >= lSumLength) goto endloop1;
        ldr x0, [sp, LINDEX]
        ldr x1, [sp, LSUMLENGTH]
        cmp x0, x1
        bge endloop1

        // ulSum = ulCarry;
        ldr x0, [sp, ULCARRY]
        str x0, [sp, ULSUM]

        // ulCarry = 0;
        str xzr, [sp, ULCARRY]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [sp, OADDEND1]
        add x0, x0, OFFSET
        ldr x1, [sp, LINDEX]
        ldr x0, [x0, x1, lsl 3]
        ldr x3, [sp, ULSUM]
        add x3, x3, x0
        str x3, [sp, ULSUM]

        //if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
        cmp x3, x0
        bhs endif3

        // ulCarry = 1;
        mov x4, 1
        str x4, [sp, ULCARRY]

        endif3:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr x0, [sp, OADDEND2]
        add x0, x0, OFFSET
        ldr x1, [sp, LINDEX]
        ldr x0, [x0, x1, lsl 3]
        ldr x3, [sp, ULSUM]
        add x3, x3, x0
        str x3, [sp, ULSUM]

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4; 
        cmp x3, x0
        bhs endif4

        // ulCarry = 1;
        mov x4, 1
        str x4, [sp, ULCARRY]

        endif4:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr x0, [sp, OSUM]
        add x0, x0, OFFSET
        ldr x1, [sp, LINDEX]
        ldr x3, [sp, ULSUM]
        str x3, [x0, x1, lsl 3]

        // lIndex = lIndex + 1;
        ldr x0, [sp, LINDEX]
        add x0, x0, 1
        str x0, [sp, LINDEX]

        b loop1

    endloop1:
        // if(ulCarry != 1) goto endif5;
        ldr x0, [sp, ULCARRY]
        cmp x0, 1
        bne endif5

        //if(lSumLength != MAX_DIGITS) goto endif6;
        ldr x0, [sp, LSUMLENGTH]
        mov x1, MAX_DIGITS
        cmp x0, x1
        bne endif6
        mov w0, FALSE

         // load x30
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret

        endif6:
        // oSum -> aulDigits[lSumLength] = 1;
        ldr x0, [sp, OSUM]
        add x0, x0, OFFSET
        ldr x1, [sp, LSUMLENGTH]
        mov x3, 1
        str x3, [x0, x1, lsl 3]

        // lSumLength++;
        add x1, x1, 1
        str x1, [sp, LSUMLENGTH]

        endif5:
        //oSum->lLength = lSumLength;
        ldr x0, [sp, OSUM]
        ldr x1, [sp, LSUMLENGTH]
        str x1, [x0]
        mov w0, TRUE

        // load x30
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT

        ret
    .size BigInt_add, (. - BigInt_add)



