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
    adr x0, iChar
    ldr x0, [x0]
    cmp x0, 0
    blt endloop1
    
    // lCharCount++;
    ldr w0, [sp, lCharCount]
    add w0, w0, 1

    // if (!isspace(iChar)) goto else1;
    adr x0, iChar
    ldr x0, [x0]
    bl isspace
    cmp x0, FALSE
    beq else1

    //if (!iInWord) goto endif2;
    ldr x0, iInWord
    cmp x0, FALSE
    beq endif2

    //lWordCount++;
    ldr w0, [sp, lWordCount]
    add w0, w0, 1

    //iInWord = FALSE;
    ldr w0, [sp, iInWord]
    mov w0, FALSE
    endif2:
    // goto endif1
    b endif1

    else1:
    //if (iInWord) goto endif3;
    ldr x0, iInWord
    cmp x0, TRUE
    beq endif3

	//iInWord = TRUE;
    ldr w0, [sp, iInWord]
    mov w0, TRUE

	endif3:

    endif1:
    //if (iChar != '\n') goto endif4;
    adr x0, iChar
    ldr x0, [x0]
    cmp x0, newline
    bne endif4

	//lLineCount++;
	ldr w0, [sp, lLineCount]
    add w0, w0, 1
    endif4:
    b loop1
endloop1:

//if (!iInWord) goto endif5;
ldr x0, iInWord
cmp x0, FALSE
beq endif5

//lWordCount++;
ldr w0, [sp, lWordCount]
add w0, w0, 1
endif5:

//printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
adr x0, printfFormatStr
ldr x0, [x0]
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


