ORG 0x2
V1:	WORD $s1, 0x180

ORG     0x0A3	    
res:	WORD 0x647	
finish: WORD 0x0D   
temp:	WORD ?      
counter: WORD ?
START:	DI
		CLA		
		LD #0x9
		OUT 7		
		EI
		CLA
INCLP:	
		INC
		BR INCLP
		
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
		IRET