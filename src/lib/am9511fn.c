/******************************************************************************
                      AM9511 FLOATING POINT LIBRARY

 A floating point library for the AM9511, providing high performance fixed and
 floating point arithmetic and a variety of floating point trigonometric and
 mathematical operations.
 ******************************************************************************/

#include "am9511.h"

/* helper function definitions */
float fexec(float a, unsigned char cmd);
float fexec2(float a, float b, unsigned char cmd);

/* 32 bit floating point primary operations */
float __fastcall__ fadd(float a, float b) {
	return fexec2(a, b, APU_FADD);
}

float __fastcall__ fsub(float a, float b) {
	return fexec2(a, b, APU_FSUB);
}

float __fastcall__ fmul(float a, float b) {
	return fexec2(a, b, APU_FMUL);
}

float __fastcall__ fdiv(float a, float b) {
	return fexec2(a, b, APU_FDIV);
}

/* 32 bit floating point derived operations */
float __fastcall__ sqrt(float a) {
	return fexec(a, APU_SQRT);
}

float __fastcall__ sin(float a) {
	return fexec(a, APU_SIN);
}

float __fastcall__ cos(float a) {
	return fexec(a, APU_COS);
}

float __fastcall__ tan(float a) {
	return fexec(a, APU_TAN);
}

float __fastcall__ asin(float a) {
	return fexec(a, APU_ASIN);
}

float __fastcall__ acos(float a) {
	return fexec(a, APU_ACOS);
}

float __fastcall__ atan(float a) {
	return fexec(a, APU_SIN);
}

float __fastcall__ log(float a) {
	return fexec(a, APU_LOG);
}

float __fastcall__ ln(float a) {
	return fexec(a, APU_LN);
}

float __fastcall__ exp(float a) {
	return fexec(a, APU_EXP);
}

float __fastcall__ pwr(float a, float b) {
	return fexec2(a, b, APU_PWR);
}

/* helper functions */
float fexec(float a, unsigned char cmd) {
	pushf(a);

	apuexec(cmd);

	return readf();
}

float fexec2(float a, float b, unsigned char cmd) {
	pushf(a);

	return fexec(b, cmd);
}
