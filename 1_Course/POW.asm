ORG 0x0
RESULTAT: word 0xDDDD
START:
	LD #2 ; EXP
	PUSH
	LD #16 ; NUMBER
	PUSH
	LD #0xF ; заглушка
	PUSH
	LD #4 ;MID
	PUSH
	CALL POW
	ST RESULTAT
	HLT
		

ORG 0x40 ; Возведение в степень (выдает флаг, является ли число корнем [FFFF -- H->MID // 0001 -- L->MID // 0000 -- THIS NUMBER])
COUNTER1: word ? ;  счетчик
RES1: word ?
BASE1: word ?
HTOMID: word 0x000F
LTOMID: word 0xF000
EQ: word 0

POW: 
	LD (SP+4) ; 
	ST COUNTER1
	LD (SP+1)
	ST RES1
	ST BASE1
	JUMP FITPOW
	NEXT2:
		LD BASE1
	FITPOW:
		PUSH
		LD RES1
		PUSH
		CALL MULT
		POP
		POP
		ST RES1
		CMP (SP+3)
		BPL ISPL
		JUMP SHIFTPOW
		ISPL:
			BEQ ISEQ
			LD HTOMID
			RET
	
	SHIFTPOW:
		LOOP COUNTER1
		JUMP NEXT2
			
	POWEXIT:
		LD RES1
		CMP (SP+3)
		BEQ ISEQ
		BMI ISMIN
		LD #0
		RET
		ISEQ:
			LD EQ
			RET
		ISMIN:
			LD LTOMID
			RET
		

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


	

	