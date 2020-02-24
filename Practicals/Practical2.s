	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register turn off - store 000x0000 value into r1 turns off in reverse
; r2 points to the CLEAR register turn on - store 000x0000 value into r2 turns on in reverse

;number starts at ram start

	LDR R3, =-5309 ; =1049
	LDR R4, =0x80000000

;check if number is negative

	AND R4, R3, R4 ; r3 && r4 = r4
	CMP R4, #0x80000000
	BNE cont
	BL TWOC
cont
	LDR R0, =0
	LDR R4, =0x40000000
	LDR R5, =1000000000
BIL CMP R3, R5
	BLO HMIL0
	SUB R3, R3, R5
	ADD R0, #1
	B BIL
HMIL0
	LDR R5, =100000000
	STRB R0, [R4],#1
	LDR R0, =0
HMIL 	
	CMP R3, R5
	BLO TMIL0
	SUB R3, R3, R5
	ADD R0, #1
	B HMIL
TMIL0
	LDR R5, =10000000
	STRB R0, [R4],#1
	LDR R0, =0
TMIL 	
	CMP R3, R5
	BLO MIL0
	SUB R3, R3, R5
	ADD R0, #1
	B TMIL
MIL0	
	LDR R5, =1000000
	STRB R0, [R4],#1
	LDR R0, =0
MIL 	
	CMP R3, R5
	BLO HT0
	SUB R3, R3, R5
	ADD R0, #1
	B MIL
HT0	
	LDR R5, =100000
	STRB R0, [R4],#1
	LDR R0, =0
HT 	
	CMP R3, R5
	BLO TT0
	SUB R3, R3, R5
	ADD R0, #1
	B HT
TT0	
	LDR R5, =10000
	STRB R0, [R4],#1
	LDR R0, =0
TT 	
	CMP R3, R5
	BLO T0
	SUB R3, R3, R5
	ADD R0, #1
	B TT
T0	
	LDR R5, =1000
	STRB R0, [R4],#1
	LDR R0, =0
T 	
	CMP R3, R5
	BLO H0
	SUB R3, R3, R5
	ADD R0, #1
	B T
H0	
	LDR R5, =100
	STRB R0, [R4],#1
	LDR R0, =0
H 	
	CMP R3, R5
	BLO TEN0
	SUB R3, R3, R5
	ADD R0, #1
	B H
TEN0	
	LDR R5, =10
	STRB R0, [R4],#1
	LDR R0, =0
TEN 	
	CMP R3, R5
	BLO ONE0
	SUB R3, R3, R5
	ADD R0, #1
	B TEN
ONE0	
	LDR R5, =1
	STRB R0, [R4],#1
	LDR R0, =0
ONE 	
	CMP R3, R5
	BLO BINHEX
	SUB R3, R3, R5
	ADD R0, #1
	B ONE
	
BINHEX ;binary value should be in memory	
	STRB R0, [R4]
	LDR R0, =0
	LDR R4, =0x40000000 ; set r4 to beginning of RAM
	
checkstart
	LDRB R0, [R4],#1
	CMP R0, #0
	BEQ checkstart
	SUB R4,#1 ;r4 is now beginning of value
	RSB R6, R4, #0x40000009 ; R6 = max index
	;R3 = BCD
	;R5 = index
	;R4 = start mem address
	; r1 turn off - store 000x0000 value into r1 turns off in reverse
	; r2 turn on - store 000x0000 value into r2 turns on in reverse

	
startLED0	

	LDR R0, =8000000
waitSTART0 
	SUB R0, #1
	CMP R0, #0
	BNE waitSTART0
	
	LDR R5, =0
	CMP R9, #1
	BNE startLED
	BL PRINTNEG
startLED
	CMP R5, R6
	BGT startLED0
	LDRB R3, [R4, R5]
	BL flip
	
	;main LED output algorithm
	
	PUSH{R6}
	;turn on LED
	MOV R3, R3, LSL  #16
	LDR	R6, [R2]
	MOV R6, R3
	STR R6, [R2]
	
	LDR R0, =8000000
waitMAIN 
	SUB R0, #1
	CMP R0, #0
	BNE waitMAIN
	
	;turn off
	LDR	R6, [R1]
	MOV R6, R3
	STR R6, [R1]
	
	LDR R0, =3000000
waitMAIN0 
	SUB R0, #1
	CMP R0, #0
	BNE waitMAIN0
	
	ADD R5, #1
	POP{R6}
	B startLED
	
	
	
	
	
stop	B	stop

TWOC
	MVN R3, R3
	ADD R3, R3, #1
	LDR R9, =1 ;set negative flag
	BX LR
	
PRINTNEG
	PUSH{R6}
	
	LDR R0, =13 
	MOV R0, R0, LSL  #16
	LDR	R6, [R2]
	MOV R6, R0
	STR R6, [R2]

	LDR R0, =8000000
wait
	SUB R0, #1
	CMP R0, #0
	BNE wait
	
	LDR R0, =13
	MOV R0, R0, LSL  #16
	LDR	R6, [R1]
	MOV R6, R0
	STR R6, [R1]
	POP{R6}
	
	BX LR
	
	
;flip routine to either invert all bits if 0 in R3 or reverse bits
flip
	PUSH{R4, R5}
	CMP R3, #0
	BEQ flip0
	LDR R5, =0
	
	LDR R4, =1
	AND R4, R4, R3
	MOV R4, R4, LSL #3
	ORR R5, R5, R4
	
	LDR R4, =2
	AND R4, R4, R3
	MOV R4, R4, LSL #1
	ORR R5, R5, R4
	
	LDR R4, =4
	AND R4, R4, R3
	MOV R4, R4, LSR #1
	ORR R5, R5, R4
	
	LDR R4, =8
	AND R4, R4, R3
	MOV R4, R4, LSR #3
	ORR R5, R5, R4
	
	MOV R3, R5
	POP{R4,R5}
	BX LR
flip0
	MVN R3, R3
	POP{R4, R5}
	BX LR
	
	
	END