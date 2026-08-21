;******************************************************************************
;                      AM9511 FLOATING POINT LIBRARY
;
; A floating point library for the AM9511, providing high performance fixed and
; floating point arithmetic and a variety of floating point trigonometric and
; mathematical operations.
;******************************************************************************

.export _apuexec
.export _pushf, _readf
.importzp sreg, msb
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
		pla			; restore command
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
		ldx	apu_data	; read msb
		ldy	apu_data	; read nmsb
		sty	sreg
		ldy	apu_data	; read lsb
		sty	sreg+1
		rts			; and return
.endproc

; -----------------------------------------------------------------
; Wait for APU to complete operation by polling the busy/status
; bit until operation has finsihed
; -----------------------------------------------------------------
.proc _pollapu
@0:		lda	apu_stat
		bmi	@0		; while bit 7 set, apu is busy
;		sta	status		; TODO: save apu status
		rts
.endproc