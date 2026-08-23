#ifndef _AM9511_H_

#include "float.h"

/* 32 bit floating point derived operations */
#define APU_SQRT 0x1	// floating point square root
#define APU_SIN  0x2	// floating point sine
#define APU_COS  0x3	// floating point cosine
#define APU_TAN  0x4	// floating point tangent
#define APU_ASIN 0x5	// floating point inverse sign
#define APU_ACOS 0x6	// floating point inverse cosine
#define APU_ATAN 0x7	// floating point inverse tangent
#define APU_LOG  0x8	// floating point common logarithm
#define APU_LN   0x9	// floating point natural logarithm
#define APU_EXP  0xa	// floating point
#define APU_PWR  0xb	// floating point power, NOS^TOS

/* 32 bit floating point primary operations */
#define APU_FADD 0x10	// floating point add
#define APU_FSUB 0x11	// floating point subtract
#define APU_FMUL 0x12	// floating point multiply
#define APU_FDIV 0x13	// floating point divide

/* data and stack manipulation operations */
#define	APU_NOP  0x0	// no operation
#define APU_CHSF 0x15	// change sign of float on TOS
#define APU_PTOF 0x17	// duplicate TOS, stack is moved down
#define APU_POPF 0x18	// rotate stack, NOS becomes TOS
#define APU_XCHF 0x19	// exchange TOS and NOS
#define APU_PUPI 0x1a	// push π onto TOS, rest of stack is moved down

/* AM9511 stack operations */
void __fastcall__ pushf(float a);
/* push float to TOS */
float __fastcall__ readf();
/* read float from TOS */
void __fastcall__ apuexec(unsigned char cmd);
/* execute command*/


/* AM9511 floating point functions */
float __fastcall__ fadd(float a, float b);
float __fastcall__ fsub(float a, float b);
float __fastcall__ fmul(float a, float b);
float __fastcall__ fdiv(float a, float b);

#endif /* AM9511_H */