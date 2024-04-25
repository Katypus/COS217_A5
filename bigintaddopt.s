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

.global BigInt_add
BigInt_add:
    // Prolog
    sub sp, sp, ADD_STACK_BYTECOUNT
    str x30, [sp]
    
    // Save all local variable + parameters we need to use
    str oAddend1, [sp, OADDEND1]
    str oAddend2, [sp, OADDEND2]
    str oSum, [sp, OSUM]
    str lSumLength, [sp, LSUMLENGTH]
    str ulCarry, [sp, ULCARRY]
    str lIndex, [sp, LINDEX]
    str ulSum, [sp, ULSUM]

    // Save parameters
    mov oAddend1, x0
    mov oAddend2, x1
    mov oSum, x2

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);

    // Get oAddend lengths
    ldr x0, [oAddend1]
    ldr x1, [oAddend2]
    
    // method call
    bl BigInt_larger

    // assign result to LSumLength
    mov lSumLength, x0
    
    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr x0, [sp, OSUM]
    ldr x1, [sp, LSUMLENGTH]
    ldr x0, [x0, 0]
    cmp x0, x1
    ble endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr x0, [oSum]
    add x0, x0, OFFSET
    mov w1, 0
    mov x2, MAX_DIGITS
    mov x3, UNSIGNED_LONG_SIZE
    mul x2, x2, x3
    bl memset

    endif2:
    // ulCarry = 0;
    mov ulCarry, 0
    
    // lIndex = 0
    mov lIndex, 0

    loop1:
        // if(lIndex >= lSumLength) goto endloop1;
        ldr x0, [lIndex]
        ldr x1, [lSumLength]
        cmp x0, x1
        bge endloop1

        // ulSum = ulCarry;
        mov ulSum, ulCarry

        // ulCarry = 0;
        mov ulCarry, 0

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, oAddend1
        add x0, x0, OFFSET
        ldr x1, lIndex
        ldr x0, [x0, x1, lsl 3]
        ldr x3, ulSum
        add x3, x3, x0
        mov ulSum, x3

        //if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
        cmp x3, x0
        bhs endif3

        // ulCarry = 1;
        mov ulCarry, 1

        endif3:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr x0, oAddend2
        add x0, x0, OFFSET
        ldr x1, lIndex
        ldr x0, [x0, x1, lsl 3]
        ldr x3, ulSum
        add x3, x3, x0
        mov ulSum, x3

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4; 
        cmp x3, x0
        bhs endif4

        // ulCarry = 1;
        mov ulCarry, 1

        endif4:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr x0, oSum
        add x0, x0, OFFSET
        ldr x1, lIndex
        ldr x2, [x0, x1, lsl 3]
        mov x2, ulSum

        // lIndex = lIndex + 1;
        add lIndex, lIndex, 1
        mov lIndex, x0

        b loop1

    endloop1:
        // if(ulCarry != 1) goto endif5;
        cmp ulCarry, 1
        bne endif5

        //if(lSumLength != MAX_DIGITS) goto endif6;
        cmp lSumLength, MAX_DIGITS
        bne endif6
        mov w0, FALSE
        b epilogue

        endif6:
        // oSum -> aulDigits[lSumLength] = 1;
        ldr x0, oSum
        add x0, x0, OFFSET
        ldr x1, [x0, lSumLength, lsl 3]
        mov x1, 1

        // lSumLength++;
        add lSumLength, lSumLength, 1

        endif5:
        //oSum->lLength = lSumLength;
        ldr x0, [oSum]
        mov oSum, lSumLength

        mov w0, TRUE

        epilogue:
        ldr oAddend1, [sp, OADDEND1]
        ldr oAddend2, [sp, OADDEND2]
        ldr oSum, [sp, OSUM]
        ldr lSumLength, [sp, LSUMLENGTH]
        ldr ulCarry, [sp, ULCARRY]
        ldr lIndex, [sp, LINDEX]
        ldr ulSum, [sp, ULSUM]
        // load x30
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT

        ret
    .size BigInt_add, (. - BigInt_add)



