;
;***************************************************************************************************
;
;	Filename:		SysProcs.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
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

;*************************************************
;		
Loop
	 	lsr _multiplier 
		bcc NoAdd 
		clc 
		adc _multiplicand 

;*************************************************
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

;************************************************
;
DLOOP 	php										; THE LOOP THAT DIVIDES 
		rol _quitient 
		asl _dividenLo 
		rol  
		plp 
		bcc ADDIT 
		sbc _divisor 
		jmp NEXT 

;************************************************
;
ADDIT 	adc _divisor 

;************************************************
;
NEXT 	dex 
		bne	DLOOP 
		bcs FINI 
		ADC _divisor 
		clc 

;************************************************
;		
FINI 	rol _quitient 
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
		sta (m_hudMemoryAddress),y

Save_Value

		lda #$FF								; will hold the value in A on entry
		and #15
		tax
		lda TabHexNibbleToScreenDigit,x
		iny
		sta (m_hudMemoryAddress),y
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

NoOverflow
		lda TabBinaryToBCD,x
		tax

		lsr										; display 2 digits (from 0 to 9)
		lsr
		lsr
		lsr
		ora #16									; add the "0" character value
		sta (m_hudMemoryAddress),y

		txa
		and #15
		ora #16			
		iny						
		sta (m_hudMemoryAddress),y						; add the "0" character value

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
		bcc NoOverflow2
		lda #9

;*************************************************
;
NoOverflow2
	
		ora #16									; display 1 digit (from 0 to 9) add the "0" character value
		sta (m_hudMemoryAddress),y

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

CDI_loop

		sta HudMemoryAddress,x
		inx
		cpx #40
		bne CDI_loop
		ldx m_saveRegX
		
		rts

.endp