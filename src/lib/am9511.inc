;**************************************
; AM9511 APU hardware registers
;**************************************
apu_data	= $1620
apu_cmd		= $1621
apu_stat	= $1621

;**************************************
; AM9511 command opcodes
;**************************************
cmd_fadd	= $10	; floating point add
cmd_fsub	= $11	; floating point subtract
cmd_fmul	= $12	; floating point multiply
cmd_fdiv	= $13	; floating point divide