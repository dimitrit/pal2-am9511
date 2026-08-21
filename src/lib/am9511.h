#ifndef _AM9511_H_

#include "float.h"

/* AM9511 32 bit floating point operations */
#define APU_FADD 0x10	// floating point add
#define APU_FSUB 0x11	// floating point subtract
#define APU_FMUL 0x12	// floating point multiply
#define APU_FDIV 0x13	// floating point divide

/* AM9511 stack operations */
void __fastcall__ pushf(float a);
float __fastcall__ readf();
void __fastcall__ apuexec(unsigned char cmd);

/* AM9511 floating point functions */
float __fastcall__ fadd(float a, float b);
float __fastcall__ fsub(float a, float b);
float __fastcall__ fmul(float a, float b);
float __fastcall__ fdiv(float a, float b);

#endif /* AM9511_H */