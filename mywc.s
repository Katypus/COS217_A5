//-------------------------------
// mywc.s
// Authors: Nadja and Kat
//----------------------------------------
    .equ FALSE, 0
    .equ TRUE, 1
//----------------------------------------
    .section .rodata
printfFormatStr:
    .string "%7ld %7ld %7ld\n"
newline:
    .byte '\n'
//----------------------------------------
    .section .data
lLineCount:
    .quad 0
lWordCount:
    .quad 0
lCharCount:
    .quad 0
iInWord:
    .quad FALSE
//------------------------------------------
    .section .bss
iChar:
    .skip 4
//-------------------------------------------
    .section .text

    .equ MAIN_STACK_BYTECOUNT, 16
    .equ EOF, -1
    .global main

main:
    // Prolog
    sub sp, sp, MAIN_STACK_BYTECOUNT
    str x30, [sp]

    loop1:
        // if ((iChar = getchar()) == EOF) go to endloop1;
        bl getchar
        adr x1, iChar
        ldr w0, [x1]
        cmp w0, EOF
        blt endloop1
        
        // lCharCount++;
        adr x0, lCharCount
        ldr x2, [x0]
        add x2, x2, 1
        str x2, [x0]

        // if (!isspace(iChar)) goto else1;
        adr x0, iChar
        ldr x0, [x0]
        bl isspace
        cmp x0, FALSE
        beq else1

        //if (!iInWord) goto endif2;
        adr x3, iInWord
        ldr w3, [x3]
        cmp w3, FALSE
        beq endif2

        //lWordCount++;
        adr x4, lWordCount
        ldr x2, [x4]
        add x2, x2, 1
        str x2, [x4]

        //iInWord = FALSE;
        adr x2, iInWord
        mov w3, FALSE
        str w3, [x2]

        endif2:

        // goto endif1
        b endif1

        else1:
        //if (iInWord) goto endif3;
        adr x1, iInWord
        ldr w2, [x1]
        cmp w2, TRUE
        beq endif3
        
        //iInWord = TRUE;
        mov w2, TRUE
        str w2, [x1]

        endif3:

        endif1:
        //if (iChar != '\n') goto endif4;
        adr x0, iChar
        ldr w1, [x0]
        cmp w1, newline
        bne endif4

        //lLineCount++;
        adr x1, lLineCount
        ldr x0, [x1]
        add x0, x0, 1
        str x0, [x1]

        endif4:

        b loop1

    endloop1:

    //if (!iInWord) goto endif5;
    adr x1, iInWord
    ldr w0, [x1]
    cmp w0, FALSE
    beq endif5

    //lWordCount++;
    adr x0, lWordCount
    ldr x1, [x0]
    add x1, x1, 1
    str x1, [x0]
    endif5:

    //printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
    adr x0, printfFormatStr
    adr x1, lLineCount
    ldr x1, [x1]
    adr x2, lWordCount
    ldr x2, [x2]
    adr x3, lCharCount
    ldr x3, [x3]
    bl printf

    // Epilog and return 0
    mov w0, 0
    ldr x30, [sp]
    add sp, sp, MAIN_STACK_BYTECOUNT
    ret

    .size   main, (. - main)


