;******************************************************************************
;                      AM9511 FLOATING POINT LIBRARY
;
; A floating point library for the AM9511, providing high performance fixed and
; floating point arithmetic and a variety of floating point trigonometric and
; mathematical operations.

; The float to string and string to float routines included are based on code
; published by Marvin L DeJong in the February and April 1981 editions of
; COMPUTE! magazine.
;******************************************************************************

.export _ftostr, _strtof
.exportzp msb
.importzp sreg, ptr1, tmp1, tmp2
.import popax

;**************************************
; AM9511 IO addresses
;**************************************
prtbyt		= $1e3b			; print two hex characters on tty
outch		= $1ea0			; print ascii character on tty

;**************************************
; Zero Page variables
;**************************************
		.segment "ZEROPAGE"

ovflo:		.res 1			; overflow byte for accumulator
msb:		.res 1			; most significant byte of accumulator
nmsb:		.res 1			; next most significant byte of accumulator
nlsb:		.res 1			; next least significant byte of accumulator
lsb:		.res 1			; least significant byte of accumulator
bexp:		.res 1			; binary exponent, bit 7 is sign bit
mflag:		.res 1			; set when minus sign is parsed
dpflag:		.res 1			; decimal point flag
esign:		.res 1			; set if minus sign in exponent
eval:		.res 1			; value of decimal exponent after 'E'
dexp:		.res 1			; value of decimal exponent
accb:		.res 6			; temp binary accumulator
bcda:		.res 5			; bcd accumumator

acca		= ovflo			; point accumulator to overflow addres
bcdn		= bcda+5

;**************************************
; Library functions
;**************************************

		.segment "CODE"

;**************************************
; Converts float f to ascii string
;
; char* __fastcall__ ftostr(char *str, float f);
;**************************************
.proc _ftostr
		sta	bexp		; A contains exponent
		bpl 	@0		; process AM9511 exponent
		lda	#$80		; if bit 7 is set, then
		sta	mflag		; set negative mantissa flag
@0:		and	#$40		; now move exponent sign flag to
		asl			; bit 7 and save
		sta	tmp1
		lda	bexp		; clear 2 most significant bits
		and     #$3f
		ora	tmp1		; add exponent flag
		sta	bexp		; and save
		stx	msb		; move rest of float from X/sreg/sreg+1
		lda	sreg		; to working area
		sta	nmsb
		lda	sreg+1
		sta	nlsb
		lda	#0
		sta	lsb		; clear least significant byte
		sta	ovflo		; clear overflow byte
		sta	dexp		; clear digital exponent
		sta	tmp1		; reset result string index
		jsr	popax		; get pointer to result string
		sta	ptr1		; and save
		stx	ptr1+1
begin:		lda	msb		; test msb to see if mantissa is zero
		bne	bry
		lda	#'0'		; yes, set result string to zero
		jsr	_stchr
		jmp	arnd		; and return to caller
bry:		lda	bexp		; is binary exponent negative?
		bpl	brz		; no
		jsr	_tenx		; yes, so multiply by ten until
		jsr	_norm		; the exponent is not negative
		dec	dexp		; decrement digital exponent
		clv			; force jump
		bvc	bry
brz:		lda	bexp		; compare binary exponent to 32
		cmp	#$20
		beq	bcd		; yes, convert binary to bcd
		bcc	brf		; no, it's less than
		jsr	_divten		; no, it's greater
		inc	dexp
		clv
		bvc	brz
brf:		lda	#0		; clear overflow
		sta	ovflo
brw:		jsr	_tenx		; multiply by 10
		jsr	_norm		; then normalise
		dec	dexp		; decrement decimal exponent
		lda	bexp		; test binary exponent
		cmp	#$20		; is it 32?
		beq	bcd		; yes, it is
		bcc	brw		; less than 32, so multiply by 10
		jsr	_divten		; it's greater than 32, so divide
		inc	dexp		; increment digital exponent
bru:		lda	bexp		; test binary exponent
		cmp	#$20		; compare with 32
		beq	brv		; shift mantissa right until exponent
		lsr	msb		; is 32
		ror	nmsb
		ror	nlsb
		ror	lsb
		ror	tmp2		; least significant bit into temp
		inc	bexp		; increment exponent for each shift
		clv
		bvc	bru
brv:		lda	tmp2		; test to see if we need to round up
		bpl	bcd		; no
		sec			; yes, so add one to mantissa
		ldx	#4
brs:		lda	acca,x
		adc	#0
		sta	acca,x
		dex
		bne	brs
bcd:		jsr	_convd		; go convert 32 bit binary to bcd
brm:		ldy	#4		; rotate bcd accumulator right until
brp:		ldx	#4		; non-significant zeros are shifted
		clc			; out, or dexp is zero, whichever
brq:		ror	bcda,x		; comes first
		dex
		bpl	brq
		dey
		bne	brp
		inc	dexp		; increment exponent for each shift
		beq	bro		; right, stop when dexp equals zero
		lda	bcda		; has a non-zero digit been shifted
		and	#$0f		; into the least significant phase
		beq	brm		; no, shift another digit
bro:		lda	mflag		; if minus flag is set then first
		beq	brn		; add - symbol to return string
		lda	#'-'
		jsr	_stchr
brn:		lda	#$0b		; set digit counter to 11
		sta	tmp2
bri:		ldy	#4		; rotate bcd accumulator left to
brh:		clc			; save most significant digits
		ldx	#$fb		; but first bypass zeros
brg:		rol	bcdn,x
		inx
		bne	brg
		rol	ovflo		; rotate digit into overflow
		dey
		bne	brh
		dec	tmp2		; decrement digit counter
		lda	ovflo		; is the rotated digit zero?
		beq	bri		; yes, rotate again
brx:		clc			; convert digit to ascii and
		adc	#'0'		; add it to the result string
		jsr	_stchr
		lda	#0		; clear overflow for next digit
		sta	ovflo
		ldy	#4		; save remaining digits
brl:		clc
		ldx	#$fb
brj:		rol	bcdn,x		; rotate one digit at a time into
		inx			; overflow, then save it
		bne	brj		; one digit is 4 bits or 1 nibble
		rol	ovflo
		dey
		bne	brl
		lda	ovflo		; get digit
		dec	tmp2		; decrement digit counter
		bne	brx
		lda	dexp		; is the digital exponent zero?
		beq	arnd		; yes, no need to add exponent
		lda	#'.'		; get ascii decimal point
		jsr	_stchr		; and add it to result string
		lda	#'E'		; get ascii E
		jsr	_stchr		; and add that too
		lda	dexp		; is the digital exponent plus?
		bpl	there		; yes
		lda	#'-'		; no, add ascii -
		jsr 	_stchr
		lda	dexp		; it's minus, so complement it and
		eor	#$ff		; add 1 to form the 2s complement
		sta	dexp
		inc	dexp
there:		lda	#0		; clear overflow
		sta	ovflo
		sed			; convert exponent to BCD
		ldy	#8
br1:		rol	dexp
		lda	ovflo
		adc	ovflo
		sta	ovflo
		dey
		bne	br1
		cld			; clear decimal flag
		clc
		lda	ovflo		; get bcd exponent
		and	#$f0		; mask low order nibble (digit)
		ror	a		; rotate nibble to right
		ror	a
		ror	a
		ror	a
		adc	#'0'		; convert digit to ascii
		jsr	_stchr		; store most significant digit
		lda	ovflo		; get least significant digit
		and	#$0f		; and mask high order nibble
		clc
		adc	#'0'		; convert to ascii
		jsr	_stchr		; store least significant digit
arnd:		lda	#0		; null terminate result string
		jsr	_stchr
		lda	ptr1		; point to start of result string
		ldx	ptr1+1
		rts			; and return
.endproc

;**************************************
; Converts ascii string to float
;
; float __fastcall__ strtof(char *str);
;**************************************
.proc _strtof
		sta     ptr1            ; save input string pointer
        	stx     ptr1+1
		lda	#0		;
		sta	tmp1		; clear input string index
		ldx	#16		; clear all memory locations used by
clear:		sta	ovflo,x		;   this routine
		dex
		bpl	clear		; next location if not done
		ldy	tmp1
		lda	(ptr1),y	; get first char from input string
		cmp	#'+'		; is it a plus sign?
		beq	plus		; yes, parse next character
		cmp	#'-'		; is it a minus sign?
		bne	ntmns		; no, try decimal point
		lda	#$80		; yes, set minus flag
		sta	mflag
plus:		inc	tmp1		; increase input string index
		ldy	tmp1
		lda	(ptr1),y	; get next character from string
ntmns:		cmp	#'.'		; is it a decimal point?
		bne	digit		; no, perhaps it's a digit
		lda	dpflag		; was decimal point flag set?
		bne	normiz		; no, time to normalise mantissa
		inc	dpflag		; set decimal point flag
		bne	plus		; and process next character
digit:		cmp	#'0'		; is the character a digit?
		bcc	normiz		; no, then normalise mantissa
		cmp	#':'		; digits are between 0 and 9
		bcs	normiz
		jsr	_tenx		; it was a digit, so multiply
		ldy	tmp1		; the accumulator by 10 and
		lda	(ptr1),y	; add the new digit
		sec			; strip the ascii prefix by
		sbc	#'0'		; subtracting ascii zero
		clc			; add the new digit to the
		adc	lsb		; least significant byte of the
					; accumulator
		sta	lsb		; next, any 'carry' will be added
		ldx	#3		; to the other bytes of the
addig:		lda	#$0		; accumulator
		adc	acca,x		; add carry bit
		sta	acca,x		; and store the result
		dex
		bpl	addig		; loop round other bytes
		lda	dpflag		; check decimal point flag
		beq	plus		; if clear, get next character
		dec	dexp		; if set, decrease exponent
		bmi	plus		; then get next character
normiz:		jsr	_norm		; normalise the mantissa
		sty	bexp		; bexp is number of left shifts
		lda	msb		; if the msb of the accumulator
		bne	procexp		; is zero then the number is zero
		jmp	finish
procexp:	ldy	tmp1		; otherwise check if last character
		lda	(ptr1),y	; was 'E'
		cmp	#'E'
		bne	tenpwr		; no, continue with tenpwr
		inc	tmp1		; get next character
		ldy	tmp1
		lda	(ptr1),y
		cmp	#'+'		; is it a plus?
		beq	past		; yes, get next character
		cmp	#'-'		; perhaps it was a minus
		bne	numb		; no, maybe it was a number
		dec	esign		; set exponent sign flag
past:		inc	tmp1		; get another character
numb:		ldy	tmp1
		lda	(ptr1),y
		cmp	#'0'		; is it a digit?
		bcc	tenpwr		; no, finalise exponent
		cmp	#'9'
		bcs	tenpwr
		sec			; it was a digit, so strip ascii
		sbc	#'0'		; zero
		sta	tmp2		; keep the first digit
		inc	tmp1		; get another character
		ldy	tmp1
		lda	(ptr1),y
		cmp	#'0'		; is it a digit?
		bcc	here		; no, so finish handling the
		cmp	#'9'		; exponent
		bcs	here
		sec			; yes, it is a digit
		sbc	#'0'		; exponent is digit + 10x prev digit
		sta	eval
		lda	tmp2		; get previous digit and multiply by ten
		asl	a		; first times 2
		asl	a		; times 2 again (ie now times 4)
		clc
		adc	tmp2		; added to itself makes times 5
		asl	a		; times 2 again makes times 10
		sta	tmp2		; and save exponent
here:		clc			; add the new digit
		lda	tmp2		; to the exponent
		adc	eval
		sta	eval		; new exponent, except for its sign
		lda	esign		; was it a negative?
		beq	postv		; no, positive
		lda	eval		; yes, then calculate its twos
		eor	#$ff		; complement by complementing and
		sec			; adding one
		adc	#$00
		sta	eval		; result in exponent value loc
postv:		clc			; prepare to add exponents
		lda	eval		; get 'E' exponent
		adc	dexp		; add exponent from input and norm
		sta	dexp		; done processing exponent
tenpwr:		lda	dexp		; get decimal exponent
		beq	finish		; if it's zero, were done
		bpl	mltply		; if positive, go multiply by 10
oncmor:		jsr	_divten		; otherwise, divide by 10
arnd:		lda	#0		; clear overflow byte
		sta	ovflo
		inc	dexp		; for each divide by 10, increment
		bne	oncmor		; the decimal exponent until it is
		beq	finish		; zero. then it's all over.
mltply:		lda	#0		; clear overflow byte
		sta	ovflo
stlpls:		jsr	_tenx		; multiply by ten
		jsr	_norm		; then normalise the mantissa
		dec	dexp		; for each times 10, decrement
		bne	stlpls		; decimal exponent until it is zero
finish:		lda	nmsb		; populate return value
		sta	sreg		; for AM9511 we only want 24 bits
		lda	nlsb		; in the mantissa
		sta	sreg+1
		ldx	msb
		lda	bexp		; exponent also needs to be mangled:
		and	#$3F		; move exponent sign from bit 7
		sta	tmp2		; to bit 6, then move mantissa
		lda 	bexp		; sign into bit 7
		and	#$80		; keep only exponent sign
		lsr			; and shift to bit 6
		ora	mflag		; now add mantissa flag
		ora	tmp2		; and remainder of exponent
		rts
.endproc

;**************************************
; 'Private' functions
;**************************************

;
; Append character in A to string
;
.proc _stchr
		ldy	tmp1		; get string index
		sta	(ptr1),y	; save character in result string
		inc	tmp1		; and increase index
		rts
.endproc

;
; Normalise the mantissa
;
.proc _norm
		clc
@0:		lda	ovflo		; any bits set in overflow byte?
		beq	@1		; yes, so rotate right
		lsr	ovflo		; no, then rotate left
		ror	msb
		ror	nmsb
		ror	nlsb
		ror	lsb		; for each shift right, increase the
		inc	bexp		; the binary exponent
		clv			; force a jump back
		bvc	@0
@1:		bcc	@3		; did the last rotate result in a carry?
		ldx	#4		; yes, then round up the mantissa
@2:		lda	acca,x
		adc	#0		; carry is set, so one is added
		sta	acca,x
		dex
		bpl	@2
		bmi	@0		; check overflo byte once more
@3:		ldy	#$20		; y will limit the number of left
@4:		lda	msb		; shifts to 32
		bmi	@6		; if the mantissa has a one in bit 7
		clc			; then leave
		ldx	#4
@5:		rol	acca,x		; shift accumulator left one bit
		dex
		bne	@5
		dec	bexp		; decrement binary exponent for each
		dey			; left shift
		bne	@4		; no more than 32 bits shifted!
@6:		rts			; all done
.endproc

;
; Multiply accumulator by ten
;
.proc _tenx
		clc			; shift accumulator left
		ldx	#4		; accumulators contain 4 bytes so
@0:		lda	acca,x		; X is set to four
		rol	a		; shift byte left
		sta	accb,x		; stor it in accumulator B
		dex
		bpl	@0		; loop to get next byte
		ldx	#4		; now shift accumulator B left
		clc			; once more to get 'times four'
@1:		rol	accb,x		; shift 1 byte left
		dex
		bpl	@1		; loop to get next byte
		ldx	#4		; add accumulator a to accumulator b
		clc			; to get a+4*a = 5*a
@2:		lda	acca,x
		adc	accb,x
		sta	acca,x		; result in accumulator a
		dex
		bpl	@2
		ldx	#4		; finally shift accumulator left
		clc
@3:		rol	acca,x		; to get 2*5*a = 10*a
		dex
		bpl	@3		; loop to next byte
		rts			; all done
.endproc

;
; Divide accumulator by ten
;
.proc _divten
		lda	#0		; clear accumulator for use as reg
		ldy	#40		; do 40 bit divide
@0:		asl	ovflo		; ovflo will be used as 'guard' byte
		rol	lsb		; roll one bit at a time into the
		rol	nlsb		; accumulator which serves to hold
		rol	nmsb		; the partial dividend
		rol	msb
		rol	a		; check to see if a is larger than
		cmp	#10		; the divisor
		bcc	@1		; no, decrease bit counter
		sec			; yes, subtract divisor from a
		sbc	#10
		inc	ovflo		; set bit in the quotient
@1:		dey			; decrease bit counter
		bne	@0
@2:		dec	bexp		; division is finished, now normalise
		asl	ovflo		; for each shift left, decrease the
		rol	lsb		; binary exponent
		rol	nlsb		; rotate the mantissa left until a
		rol	nmsb		; one is in the most significant bit
		rol	msb
		bpl	@2
		lda	ovflo		; if the most significant bit in the
		bpl	@4		; guard byte is one, round up
		sec			; add one
		ldx	#4		; x is byte counter
@3:		lda	acca,x		; get the lsb
		adc	#0		; add the carry
		sta	acca,x		; result into mantissa
		dex
		bpl	@3		; continue with addition
		bcc	@4		; no carry from msb, so finish
		ror	msb		; put carry in bit 7
		inc	bexp		; and increase binary exponent
@4:		lda	#0		; clear ovflo position, then return
		sta	ovflo
		rts
.endproc

;
; Convert a 32 bit binary value to BCD
;
.proc _convd
		ldx	#5		; clear bcd accumulator
		lda	#0
@0:		sta	bcda,x		; zeros into bcd accumulator
		dex
		bpl	@0
		sed			; set decimal mode for add
		ldy	#$20		; y has number of bits to be converted
@1:		asl	lsb		; rotate binary number into carry
		rol	nlsb
		rol	nmsb
		rol	msb
		ldx	#$fb		; x will controll a 5 byte addition
@2:		lda	bcdn,x		; get least significant byte of bsd
		adc	bcdn,x		; accumulator, add it to itself,
		sta	bcdn,x		; then store
		inx			; repeat until all 5 bytes have
		bne	@2		; been added
		dey			; get next bit from the binary number
		bne	@1
		cld			; back to binary mode
		rts			; all done
.endproc
