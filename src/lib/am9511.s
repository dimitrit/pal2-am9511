;******************************************************************************
;                      AM9511 FLOATING POINT LIBRARY
;
; A floating point library for the AM9511, providing high performance fixed and
; floating point arithmetic and a variety of floating point trigonometric and
; mathematical operations.
;******************************************************************************

.export _apuexec
.export _pushf, _readf
.importzp sreg, msb, bexp
.import popax

.include "am9511.inc"

prtbyt		= $1e3b			; print two hex characters on tty


; ; -----------------------------------------------------------------
; ; Save 4-byte float in working area
; ; -----------------------------------------------------------------
; .proc _savef
; 		sta	msb+4		; save exponent
; 		stx	msb		; save msb
; 		lda	sreg
; 		sta	msb+1		; save nmsb
; 		lda	sreg+1
; 		sta	msb+2		; save nlsb
; 		lda	#0
; 		sta	msb+3		; clear lsb
; .endproc


; -----------------------------------------------------------------
; Execute AM9511 APU command
; -----------------------------------------------------------------
.proc _apuexec
		pha			; save command
		jsr	_pollapu	; ensure AM9511 is ready
		pla
		pha
		jsr	prtbyt		; restore command
		pla
		sta	apu_cmd		; execute command
		rts			; and done!
.endproc

; -----------------------------------------------------------------
; Push 4-byte float onto APU stack, lsb first
; -----------------------------------------------------------------
.proc _pushf
		pha			; save exponent
		jsr	_pollapu	; ensure AM9511 is ready
		ldy	sreg+1		; write lsb
		sty	apu_data
		ldy	sreg		; write nmsb
		sty	apu_data
		stx	apu_data	; write msb
		pla			; restore exponent
		sta	apu_data	; write exp
		rts
.endproc

; -----------------------------------------------------------------
; Read 4-byte result from APU stack and return as float
; -----------------------------------------------------------------
.proc _readf
		jsr	_pollapu	; ensure AM9511 is ready
		lda	apu_data	; read exponent
		sta	bexp
		lda	apu_data	; read msb
		sta	msb
		lda	apu_data	; read nmsb
		sta	msb+1
		lda	apu_data
		sta	msb+2		; read nlsb

		ldx	#$fd
		lda	bexp
		jsr	prtbyt

@0:		lda	msb+3,x
		jsr	prtbyt
		inx
		bne	@0

		ldx	msb		; get msb
		lda	msb+1		; get nmsb
		sta	sreg
		lda	msb+2		; get nlsb
		sta	sreg+1
		lda	bexp		; get exponent
		rts			; and return
.endproc

; -----------------------------------------------------------------
; Wait for APU to complete operation by polling the busy/status
; bit until operation has finsihed
; -----------------------------------------------------------------
.proc _pollapu
@0:		lda	apu_stat
		bmi	@0		; while bit 7 set, apu is busy
		rts
.endproc