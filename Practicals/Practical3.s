	
	;github: github.com/futurecertificate
	;Author: Seva Syrtsov 18323202
	
	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU 0xE0028010
	
	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
	ldr r9,=IO1PIN
; r1 points to the SET register turn off - store 000x0000 value into r1 turns off in reverse
; r2 points to the CLEAR register turn on - store 000x0000 value into r2 turns on in reverse

;number starts at ram start
	LDR R4, =0x00F00000	;pin mask
	LDR R10, =0	;flag if stack is full
	LDR R5, =0
INPUTWAIT
	
	LDR R0, [R9] ;get pins
	AND R0, R0, R4
	MOV R0, R0, LSR #20
	CMP R0, #15
	BEQ INPUTWAIT
	BL READPIN		;Read the pin and return which operation calculator will do
	
	
	
	
c20	CMP R0, #20		;subtraction operation
	BNE c21
	CMP R10, #0		;check if theres stuff on the stack
	BNE c201		;if theres stuff on stack
	LDR R8, =0x0000000F
	AND R5, R5, R8
	PUSH{R5}		;Push number onto stack
	PUSH{R0}		;push operator onto stack
	LDR R5, =0
	LDR R10, =1
	BL LIGHTSOFF
	BL COOLDOWN
	B INPUTWAIT
c201				;if theres stuff on the stack already
	POP{R7}
	POP{R6}			;number to perform operation with
	LDR R10, =0
	CMP R7, #21		;if addition
	BNE	c2010		;subtraction
	ADD R5, R6, R5	; R5 = R6 + R5
	LDR R8, =0x0000000F
	AND R5, R5, R8
	
	BL LIGHTS
	
	PUSH{R5}		;push number onto stack
	PUSH{R0}		;push operator onto stack
	LDR R5, =0
	LDR R10, =1
	BL COOLDOWN
	B INPUTWAIT
	
c2010
	SUB R5, R6, R5	; R5 = R6 - R5
	LDR R8, =0x0000000F
	AND R5, R5, R8
	
	BL LIGHTS
	
	PUSH{R5}		;push number onto stack
	PUSH{R0}		;push operator onto stack
	LDR R5, =0
	LDR R10, =1
	
	BL COOLDOWN
	B INPUTWAIT
	
	
	
	
c21	CMP R0, #21		;addition operator
	BNE c22
	CMP R10, #0		;check if theres stuff on the stack
	BNE c211		;if theres stuff on stack
	LDR R8, =0x0000000F
	AND R5, R5, R8
	
	BL LIGHTSOFF
	
	PUSH{R5}		;Push number onto stack
	PUSH{R0}		;push operator onto stack
	LDR R5, =0
	LDR R10, =1
	BL COOLDOWN
	B INPUTWAIT
c211				;if theres stuff on the stack already
	POP{R7}
	POP{R6}			;number to perform operation with
	LDR R10, =0
	CMP R7, #21		;if addition
	BNE	c2110		;subtraction
	ADD R5, R6, R5	; R5 = R6 + R5
	LDR R8, =0x0000000F
	AND R5, R5, R8
	
	BL LIGHTS
	PUSH{R5}		;push number onto stack
	PUSH{R0}		;push operator onto stack
	LDR R5,=0
	LDR R10, =1
	
	BL COOLDOWN
	B INPUTWAIT
	
c2110	;subtraction once popped off stack
	SUB R5, R6, R5	; R5 = R6 - R5
	LDR R8, =0x0000000F
	AND R5, R5, R8
	BL LIGHTS
	
	PUSH{R5}		;push number onto stack
	PUSH{R0}		;push operator onto stack
	LDR R10, =1
	
	BL COOLDOWN
	B INPUTWAIT
	
	
	
	
	
	
	
c22	CMP R0, #23	;N+ operation
	BNE c23
	ADD R5, #1
	LDR R8, =0x0000000F
	AND R5, R5, R8
	BL LIGHTS
	BL COOLDOWN
	B INPUTWAIT	
	
c23 CMP R0, #22	;N- operation
	BNE cn20
	SUB R5, #1
	LDR R8, =0x0000000F
	AND R5, R5, R8
	BL LIGHTS
	BL COOLDOWN
	B INPUTWAIT	
	
cn20 		;ALL CLEAR operation
	CMP R0, #-20
	BNE cn21
	CMP R10, #0
	BNE cn200
	LDR R5, =0
	BL LIGHTSOFF
	BL COOLDOWN
	B INPUTWAIT

cn200
	POP{R6}
	POP{R6}
	LDR R10, =0
	LDR R5, =0
	BL LIGHTSOFF
	BL COOLDOWN
	B INPUTWAIT
	
cn21			;clear number entered and last operator
	CMP R10, #0
	BNE cn210
	LDR R5, =0
	BL LIGHTS
	BL COOLDOWN
	B INPUTWAIT
	
	
cn210	
	POP{R5}
	POP{R5}
	LDR R10, =0
	BL LIGHTS
	BL COOLDOWN
	B INPUTWAIT
	
stop	B	stop
	
	
	
	
	;takes pin input in r0
READPIN
	PUSH{R5, R6}
	CMP R0, #14
	BEQ checklong
	CMP R0, #13
	BNE shortpress
	
checklong	
	LDR R6, =6000000	; set timer
checklong0
	LDR R5, [R9]		; read in pin 
	AND R5, R5, R4
	MOV R5, R5, LSR #20
	CMP R5, R0			; check if still the same
	BNE shortpress
	SUB R6, R6, #1
	CMP R6,#0
	BNE	checklong0
	
longpress
	CMP R0, #14
	BNE LONGp21
	MOV R0, #-20		;put -20 in r0 for long press of P1.20
	POP{R5, R6}
	BX LR				;return with -20 in r0

LONGp21
	MOV R0, #-21
	POP{R5, R6}
	BX LR				;return with -21 in r0
	
	
shortpress
	CMP R0, #14
	BNE p21
	MOV R0, #20
	POP{R5,R6}			;return with 20 in r0
	BX LR
	
p21	CMP R0, #13
	BNE p22
	MOV R0, #21			;return with 21 in r0
	POP{R5,R6}
	BX LR
	
p22	CMP R0, #11
	BNE p23
	MOV R0, #22			;return with 22 in r0
	POP{R5,R6}
	BX LR

p23	MOV R0, #23			;return with 23 in r0
	POP{R5,R6}
	BX LR




COOLDOWN
	PUSH{R7}
	LDR R7, =5000000
tr	SUB R7, #1
	CMP R7, #0
	BNE tr
	POP{R7}
	BX LR


;
;	LIGHTS OFF ROUTINE
;	current number in R5

LIGHTS
	PUSH{R3,LR}
	LDR R8, =0x0000000F
	MOV R8, R8, LSL #16
	STR R8, [R1]	;turns off LEDS
	MOV R3, R5
	BL flip
	MOV R3, R3, LSL #16
	STR R3, [R2]
	POP{R3,LR}
	BX LR
	
LIGHTSOFF
	LDR R8, =0x0000000F
	MOV R8, R8, LSL #16
	STR R8, [R1]	;turns off LEDS
	BX LR
	
;flip routine to either invert all bits if 0 in R3 or reverse bits
flip
	PUSH{R4, R5}
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
	
	
	END