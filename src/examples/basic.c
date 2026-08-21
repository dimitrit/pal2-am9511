#include <conio.h>

#include <am9511.h>

char n[] = "123";
char m[] = "456";
char p[20];

int main (void) {
	float a, b, r;

	cputs("\n\r");

	a = strtof(n);
	b = strtof(m);

	r = fdiv(a, b);

	ftostr(p, r);

	cputs(p);
}