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

.equ MAIN_STACK_BYTECOUNT, 32

bigintlarger:
    // Prolog
    sub sp, sp, MAIN_STACK_BYTECOUNT
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
