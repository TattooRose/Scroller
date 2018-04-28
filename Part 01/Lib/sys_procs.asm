;
;***************************************************************************************************
; 	Filename:		sys_procs.asm
;
; 	Modified On:	Mon Apr 02, 2018 12:31:00 PM
;
;	Comments:		This code contains parts of the OPEN_PLAT project developed by NVR. It also
;					contains parts of the port from the C64 to Atari project ported by
;					Ken Jennings. Many thanks to both of them. 
;
;***************************************************************************************************
;

;****	Storage
;
_productLo		.byte $00 
_productHi		.byte $00 
_multiplier		.byte $00 
_multiplicand	.byte $00 

_divisor		.byte $00						; DIVISOR
_quitient		.byte $00 						; QUOTIENT
_remainder		.byte $00						; REMAINDER 
_dividenLo		.byte $00						; LOW PART OF DIVIDEND
_dividendHi		.byte $00						; HIGH PART OF DIVIDEND 

TabHexNibbleToScreenDigit
	.sb "0123456789ABCDEF"

TabBinaryToBCD
	.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
	.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
	.byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29
	.byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39
	.byte $40, $41, $42, $43, $44, $45, $46, $47, $48, $49
	.byte $50, $51, $52, $53, $54, $55, $56, $57, $58, $59
	.byte $60, $61, $62, $63, $64, $65, $66, $67, $68, $69
	.byte $70, $71, $72, $73, $74, $75, $76, $77, $78, $79
	.byte $80, $81, $82, $83, $84, $85, $86, $87, $88, $89
	.byte $90, $91, $92, $93, $94, $95, $96, $97, $98, $99

;
;***************************************************************************************************
; WaitFrame
;***************************************************************************************************
;
.proc WaitFrame
		
		lda RTCLOK60							; get frame/jiffy counter

;*****	Wait Tick 60
;
WaitTick60

		cmp RTCLOK60							; Loop until the clock changes
		beq WaitTick60		
		rts
.endp			

;
;***************************************************************************************************
; MultiplyAX
;***************************************************************************************************
;
.proc MultiplyAX  
		sta _multiplier
		stx _multiplicand 
		lda #0 
		sta _productLo 
		ldx #8 

;*****	Loop
;		
Loop
	 	lsr _multiplier 
		bcc NoAdd 
		clc 
		adc _multiplicand 

;*****	No Add
;
NoAdd
	 	ror 
		ror _productLo 
		dex 
		bne Loop 
		sta _productHi 

		rts 
.endp

;
;***************************************************************************************************
; DivideAXY
;***************************************************************************************************
;
.proc DivideAXY
		
		stx _divisor							; THE DIVISOR
		sty _dividenLo								
		sta _dividendHi							; ACCUMULATOR WILL HOLD DVDH
 
		ldx	#$08 								; FOR AN 8-BIT DIVISOR 
		sec 
		sbc _divisor 

;*****	Loop
;
LOOP 	php										; THE LOOP THAT DIVIDES 
		rol _quitient 
		asl _dividenLo 
		rol  
		plp 
		bcc ADDIT 
		sbc _divisor 
		jmp NEXT 

;***** 	Add It
;
ADDIT 	adc _divisor 

;***** 	Next
;
NEXT 	dex 
		bne	LOOP 
		bcs Finish 
		ADC _divisor 
		clc 

;*****	Finish
;		
Finish
	rol _quitient 
		sta _remainder 
		rts 									; ENDIT

.endp		

;
;**************************************************************************************************
; DisplayDebugInfoHexFF
;
; 	display 2 digits with values from 00 to FF
; 	passs the value in A and the line row in Y
;
;**************************************************************************************************
;
.proc DisplayDebugInfoHexFF

		stx m_saveRegX
		sta Save_Value+1						; place the value in A 1 location pasted the lda.   
	
		lsr										; display 2 digits (from 0 to F)
		lsr
		lsr
		lsr
		tax
		lda TabHexNibbleToScreenDigit,x
		sta HudAddress,y

;*****	Save Value
;
Save_Value

		lda #$FF								; will hold the value in A on entry
		and #15
		tax
		lda TabHexNibbleToScreenDigit,x
		sta HudAddress+1,y
		ldx m_saveRegX
		rts
.endp	

;
;**************************************************************************************************
; DisplayDebugInfoBinary99
;
;	display 2 digits with values from 00 to 99
; 	passs the value in A and the line row in Y
;
;**************************************************************************************************
;
.proc DisplayDebugInfoBinary99

		stx m_saveRegX
		tax
		cpx #100
		bcc NoOverflow
		ldx #99

;*****	No Overflow
;
NoOverflow
		lda TabBinaryToBCD,x
		tax

		lsr										; display 2 digits (from 0 to 9)
		lsr
		lsr
		lsr
		ora #16									; add the "0" character value
		sta HudAddress,y

		txa
		and #15
		ora #16									; add the "0" character value
		sta HudAddress+1,y

		ldx m_saveRegX
		rts
.endp		

;
;**************************************************************************************************
; DisplayDebugInfoBinary9
;**************************************************************************************************
;
.proc DisplayDebugInfoBinary9

		cmp #10
		bcc NoOverflow
		lda #9

;*****	No Overflow 
;
NoOverflow
	
		ora #16									; display 1 digit (from 0 to 9) add the "0" character value
		sta HudAddress,y

	rts

.endp	

;
;**************************************************************************************************
; ClearDebugLineInfo
;**************************************************************************************************
;
.proc ClearDebugLineInfo

		stx m_saveRegX
		lda #0
		tax

;*****	Clear Loop
;
Loop

		sta HudAddress,x
		inx
		cpx #$30
		bne Loop
		ldx m_saveRegX
		
		rts

.endp