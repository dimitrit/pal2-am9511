/******************************************************************************
                      AM9511 FLOATING POINT LIBRARY

 A floating point library for the AM9511, providing high performance fixed and
 floating point arithmetic and a variety of floating point trigonometric and
 mathematical operations.
 ******************************************************************************/

#include "am9511.h"

float fexec(float a, float b, unsigned char cmd);

float __fastcall__ fadd(float a, float b) {
	return fexec(a, b, APU_FADD);
}

float __fastcall__ fsub(float a, float b) {
	return fexec(a, b, APU_FSUB);
}

float __fastcall__ fmul(float a, float b) {
	return fexec(a, b, APU_FMUL);
}

float __fastcall__ fdiv(float a, float b) {
	return fexec(a, b, APU_FDIV);
}

float fexec(float a, float b, unsigned char cmd) {
	pushf(a);
	pushf(b);

	apuexec(cmd);

	return readf();
}
