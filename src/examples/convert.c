
#include <conio.h>

#include <float.h>

typedef union {
    float    f;
    unsigned char b[sizeof (float)];
} U;

// void __fastcall__ (*quux)(char c) = (void*)0x1ea0;

char n[] = "1.3579";
char m[20];

int main (void) {
	U u;
	unsigned char i;

	cputs("\n\r");

	cputs(n);

	cputs(" -> ");

	u.f = strtof(n);

	for (i=0; i<4; i++) {
		cputhex8(u.b[i]);
	}

	cputs(" -> ");

	ftostr(m, u.f);

	cputs(m);

	cputs("\n\r");
}