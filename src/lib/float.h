#ifndef _FLOAT_H_
#define _FLOAT_H_

#ifdef __CC65__

/*
 * AM9511 floating point format
*
 * The AM9511 floating point format uses a 32-bit word, with fields as following
 *
 *   me
 *   sseeeeee mmmmmmmm mmmmmmmm mmmmmmmm
 *
 *     bit  description
 *     ---  -----------
 *      31  mantissa sign
 *      30  exponent sign
 *   29-24  unbiased 2s complement exponent
 *    23-0  mantissa
 *
 * The exponent of base 2 is an unbiased two's complement number with a range of
 * -64 to +63. The mantissa is a sign-magnitude number with an assumed binary
 * point just to the left of the most significant mantisa bit (bit 32).
 * All floating point values must be normalised, which makes bit 23 always equal
 * to 1, except when representing a value of zero. A zero value is represented
 * with binary zeros in all 32 bit positions.
 *
 */
typedef struct {
	unsigned char exponent; /* bit 7 is mantissa sign, bit 6 is exponent sign */
	unsigned char mantissa[3];
} FLOAT;

#define float unsigned long

/* string convertion routines */
char* __fastcall__ ftostr(char *str, float f);
float __fastcall__ strtof(char *str);

/* */
float __fastcall__ fneg(float f);

#endif /* __CC65__ */
#endif /* _FLOAT_H_ */
