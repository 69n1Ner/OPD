ORG 0x0
RESU: word 0xDEAD
START:
	LD #3
	PUSH
	PUSH
	CALL MULT
	POP
	POP
	ST RESU
	HLT

ORG 0x80
COUNTER: word ?
MULT: ; сюда должны попадать только подходящие (оба < 1байта)
	LD #8
	ST COUNTER
	LD  #0
	PUSH ;PREV_END
	LD (SP+2)
	SWAB
	ST (SP+2) ; N1/BASE множимое
	LD (SP+3) ; S4P/ RES1 множитель
	AND #1	
	PUSH ;CURR_END
	JUMP FIRSTITER
	NEXT:
		LD (SP+4) ;S4P/RES1
		AND #1
		ST (SP+0)
	FIRSTITER:
		CALL XOR 
		BEQ SHIFT ; если есть изменение с 0 на 1 или с 1 на 0, то надо определить что именно
		CALL IMPLICATION
		ONETO0:
			BEQ ZEROTO1
			LD (SP+4) ;S4P/RES1
			ADD (SP+3)
			JUMP SHIFT1
		ZEROTO1:
			LD (SP+3)
			NEG
			ADD (SP+4)
			JUMP SHIFT1
		SHIFT:
			LD (SP+4)
			SHIFT1:
				ASR
				ST (SP+4)
				LD (SP+0)
				ST (SP+1)
				LOOP COUNTER
				JUMP NEXT
		MULTEXIT:
			LD (SP+4)
			POP
			POP
			RET

BUFFER: word ?
XOR: 
	LD (SP+2) ;X2/PREV
	NOT 
	AND (SP+1) ;X1/CURR
	ST BUFFER
	LD (SP+1)
	NOT
	AND (SP+2)
	OR BUFFER
	RET

IMPLICATION: ; X1-->X2
	LD (SP+2)
	NOT
	OR (SP+1)
	NOT
	RET

	