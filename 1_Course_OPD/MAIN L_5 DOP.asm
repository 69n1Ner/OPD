; !!! Описание программы читай ниже !!!
ORG 0x20 ; Поиск произвольного корня числа
LOW: word 1
HIGH: word ?

ROOT:
	LD (SP+1) 
	JUMP FITROOT
	NEXTROOT:
		LD HIGH
	FITROOT:
		ADD LOW
		ASR 
		PUSH ; MID
		CALL POW
		BEQ EQROOT
		BPL PLROOT
		BMI MINROOT
		LD #0
		RET
		EQROOT:
			POP
			RET
		PLROOT:
			POP
			ST HIGH
			JUMP NEXTROOT
		MINROOT:
			POP
			ST LOW
			JUMP NEXTROOT
	

; Возведение в степень (выдает флаг, является ли число корнем [FFFF -- H->MID // 0001 -- L->MID // 0000 -- THIS NUMBER])
COUNTER1: word ? ;  счетчик
RES1: word ?
BASE1: word ?
HTOMID: word 0x000F
LTOMID: word 0xF000
EQ: word 0

POW: 
	LD (SP+4) ; 
	DEC
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
			BEQ ISEND
			LD HTOMID
			RET
		ISEND:
			LD COUNTER1
			BEQ ISEQ
			JUMP SHIFTPOW
	
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
;============================================
;||		  ОПИСАНИЕ		   ||
;============================================
; Программа ищет произвольный корень из числа, вводятся через ВУ-3, символ прекращения чтения - 0x0D
; выодит же ответ программа на ВУ-6
ORG 0x110
exp:		word ?
number:		word ?
ans:		word ?
num_ex:		word ?
mask:		word 0x00FF
res:	WORD 0x647	
finish: WORD 0x0D   
temp:	WORD ?      
START:	CLA		    
s1:		IN 7		
		AND #0x40	
		BEQ s1	    
		IN 6		
		ST (res)	
		ST temp	    
		CMP finish	
		BEQ exit	
		CLA		    
s2:		IN 7		
		AND #0x40	
		BEQ s2	    
		IN 6		
		SWAB		
		OR temp	    
		ST (res)	
		SUB temp	
		SWAB		
		CMP finish	
		BEQ exit	
		LD (res)+	
		CLA		    
		JUMP s1	    
exit:	LD (res)+   
		LD -(res)
		LD -(res)
		ST num_ex
		AND mask
		ST exp
		LD num_ex
		SWAB
		AND mask
		ST number
; вторая часть
		LD exp
		PUSH
		LD number
		PUSH
		CALL $ROOT
		ST ans
		PUSH
		CALL $print_ans
		LD ans
		CALL $print_number
		HLT
	
ten: word 0x0
tens: word 0x0
units: word 0x0
current_n: word ?
tmp_n: word ?
print_number:
	LD #0
	ST ten
	ST tens
	ST units
	LD (SP + 1)
	ST current_n
	ST tmp_n
	new_cycle:	CMP #9
					BPL cycle
					LD current_n
					SUB ten
					ST units
					LD tens
					CMP #0
					BEQ print_units
					LD tens
	print_tens:	CALL print_digit
					NOP
	print_units:	LD units
					CALL print_digit
					NOP
					RET
					
					cycle:	LD ten
							ADD #10
							ST ten
							LD (tens)+
							LD tmp_n
							SUB #9
							ST tmp_n
							JUMP new_cycle
							
; сюда приходит уже готовое число в стеке или AC, оно добавляется к началу массива,
;вызывается скрипт печати и RET
curr_d: 	word ?
arr_start:	word $arr
index:		word ?
arr:		word $zero,$one,$two,$three,$four,$five,$six,$seven,$eight,$nine
print_digit:	ST curr_d
				ADD arr_start
				ST index
				LD (index)
				ST index
				CALL (index)
				LD #0
				OUT 0x10
				RET

print_ans:	LD #0xFF
				OUT 0x10
				LD #0x18
				OUT 0x10
				LD #0x18
				OUT 0x10
				LD #0x18
				OUT 0x10
				LD #0x18
				OUT 0x10
				LD #0x5A
				OUT 0x10
				LD #0x3C
				OUT 0x10
				LD #0x18
				OUT 0x10
				LD #0x0
				OUT 0x10
				RET

zero:	LD #0x3E
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD  #0x51
		OUT 0x10
		LD #0x3E
		OUT 0x10
		RET

one: 	LD #0x21
		OUT 0x10
		LD #0x7F
		OUT 0x10
		LD #0x01
		OUT 0x10
		RET

two:	LD #0x21
		OUT 0x10
		LD #0x43
		OUT 0x10
		LD #0x45
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD #0x31
		OUT 0x10
		RET

three:	LD #0x42
		OUT 0x10
		LD #0x41
		OUT 0x10
		LD #0x51
		OUT 0x10
		LD #0x69
		OUT 0x10
		LD #0x46
		OUT 0x10
		RET

four:	LD #0x0C
		OUT 0x10
		LD #0x14
		OUT 0x10
		LD #0x24
		OUT 0x10
		LD #0x7F
		OUT 0x10
		LD #0x04
		OUT 0x10
		RET

five:	LD #0x72
		OUT 0x10
		LD #0x51
		OUT 0x10
		LD #0x51
		OUT 0x10
		LD #0x51
		OUT 0x10
		LD #0x4E
		OUT 0x10
		RET

six:	LD #0x1E
		OUT 0x10
		LD #0x29
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD #0x06
		OUT 0x10
		RET

seven:	LD #0x40
		OUT 0x10
		LD #0x47
		OUT 0x10
		LD #0x48
		OUT 0x10
		LD #0x50
		OUT 0x10
		LD #0x60
		OUT 0x10
		RET

eight:	LD #0x36
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD #0x36
		OUT 0x10
		RET

nine:	LD #0x30
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD #0x49
		OUT 0x10
		LD #0x4A
		OUT 0x10
		LD #0x3C
		OUT 0x10
		RET