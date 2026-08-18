#include "float.h"

typedef union {
    float    f;
    unsigned char b[sizeof (float)];
} U;

float __fastcall__ _strtof(char *s) {
	U u;
	unsigned long l = 0;
	unsigned char neg = 0;

	u.f = 0;

	if (*s == '+') {
		++s;
	} else if (*s == '-') {
		neg = 1;
		++s;
	}

	while (*s>'/' && *s<':') {
		l = l*10 + (*s-'0');
		++s;
	}



	return u.f;
}

float __fastcall__ _fneg(float f) {
	U u;
	u.f = f;
	u.b[0] = u.b[0] ^ %01000000;
	return u.f;
}