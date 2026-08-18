
#include <conio.h>

#include "float.h"

typedef union {
    float    f;
    unsigned char b[sizeof (float)];
} U;

// void __fastcall__ (*quux)(char c) = (void*)0x1ea0;

char n[] = "12345";
char m[12];

int main (void) {
	U u;
	unsigned char i;

	cputs("\n\r");

	u.f = strtof(n);

	for (i=0; i<4; i++) {
		//u.b[i] = i;
		cputhex8(u.b[i]);
	}

	cputs("\n\r");

	ftostr(m, u.f);

	cputs(m);
}