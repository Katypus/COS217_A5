#include <stdio.h>
#include <ctype.h>

enum {FALSE, TRUE};


static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */


int main (void){
loop1:
	if ((iChar = getchar()) == EOF)) goto endloop1;
	lCharCount++;
	if (!isspace(iChar)) goto else1;
		if (!iInWord) goto endif2;
			lWordCount++;
			iInWord = FALSE;
		endif2:
		goto endif1;
	else1:
		if (iInWord) goto endif3;
			iInWord = TRUE;
		endif3:
	endif1:
	if (iChar != '\n') goto endif4;
		lLineCount++;
		endif4:
goto loop1;
endloop1:
	
	if (!iInWord) goto endif5;
		lWordCount++;
	endif5:
	printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   	return 0;
}
