;
;***************************************************************************************************
;
;	Filename:		FloatPlatform.Asm
;
;	Modified On:	Fri June 1, 2018 08:24 AM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;***************************************************************************************************
; Local Storage
;***************************************************************************************************
;
PLATFORMH_MAX_SIZE		= $06

_PlayerClamped			.byte $00				
_PlatformMaxStep		.byte $28
_PlatformMaxTimer		.byte $02
_PlatformCurrTimer		.byte $00

TabPlatformCharID_H		.byte $26
TabPlatformCharH		.byte $00,$26,$27,$28,$29,$00

TabPlatformDir			:8  .byte $00  
TabPlatformStep			:8  .byte $00  
TabPlatformCount		:8  .byte $00  
TabPlatformLSB_H		:8	.byte $00
TabPlatformMSB_H		:8  .byte $00

HFP001
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
    					.byte $3F,$3F,$00,$15,$00,$00,$00,$00
    					.byte $0F,$0F,$00,$05,$00,$00,$00,$00
    					.byte $03,$03,$00,$01,$00,$00,$00,$00
HFP002
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
HFP003
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
HFP004
    					.byte $C0,$C0,$00,$40,$00,$00,$00,$00
    					.byte $F0,$F0,$00,$50,$00,$00,$00,$00
    					.byte $FC,$FC,$00,$54,$00,$00,$00,$00
    					.byte $FF,$FF,$00,$55,$00,$00,$00,$00
;
;**************************************************************************************************
; 	AnimatePlatformH
;**************************************************************************************************
;
.proc AnimatePlatformH

		lda m_floatPlatformH
		cmp #$01
		beq CheckTimer
		jmp Exit
		
CheckTimer		
		inc _PlatformCurrTimer					; increment the timer
		lda _PlatformCurrTimer					; load it for the test
		cmp _PlatformMaxTimer					; test it to max timer
	
		beq ResetTimer							; not equal
		jmp Exit								; jump out

ResetTimer

		lda #$00								; reset the timer	
		sta _PlatformCurrTimer					; store it

		ldx m_floatPlatformIdx					; grab the index
		dex  									; decrement it
		stx m_currPlatformIdx					; store it for later
		
		lda #<TabPlatformCharH					; load the LSB platform sequence 
		sta m_currentCharAddress				; store it in zero page
		lda #>TabPlatformCharH					; load the MSB platform sequemce
		sta m_currentCharAddress+1				; store it in zero page
	
		lda m_platformGameCharAddr_H			; get the LSB for the game font address	
		sta m_paramW01							; store it in zero page
		lda m_platformGameCharAddr_H+1			; get the MSB for the game font address
		sta m_paramW01+1						; store it in zero page

		lda TabPlatformLSB_h,x					; get the LSB for the game screen address
		sta m_platformScrnAddress				; store it in zero page
		lda TabPlatformMSB_h,x					; get the MSB for the game screen address
		sta m_platformScrnAddress+1				; store it in zero page
		jsr CopyChar							; copy the animation chars

		ldy #$00								; reset the Y

DrawChar
	
		lda (m_currentCharAddress),y			; Load this character
		sta (m_platformScrnAddress),y			; store it to the screen
		iny										; increment the index 
		cpy #PLATFORMH_MAX_SIZE					; number of characters to draw
		bne DrawChar							; get next character
		
		ldx #$00
		lda TabPlatformDir,x					; grab it's direction
		and #$01								; and it 
		bne Backward							; branch to backwards if 1
	
Forward

		lda _PlayerClamped						; is player clamped to platform
		cmp #$01								; test it
		bne ForwardCount						; no jump the player increment
		
		clc										; set the carry for addition
		lda m_playerLevelLeftX_H1				; load the low left X
		adc #$01								; add one 
		sta m_playerLevelLeftX_H1				; store it
		lda m_playerLevelLeftX_H2				; load the high left X
		adc #$00								; add with carry
		sta m_playerLevelLeftX_H2				; store it
		jsr SetPlayerInfo						; update the players info
		
ForwardCount
		inc TabPlatformCount,x					; increment the count
		lda TabPlatformCount,x					; load it for compare
		cmp #$04								; check against value
		beq ResetForward
		jmp Exit								; not there yet exit

ResetForward	
		lda #$00								; reset the counter
		sta TabPlatformCount,x					; store it
	
		inc TabPlatformStep,x					; increment the step
		lda TabPlatformStep,x					; load it for compare
		cmp _PlatformMaxStep					; check against value
		bne MoveForward							; not there yet 

		lda #$03								; load for backwards
		sta TabPlatformCount,x					; store it in the counter
	
		lda #$00								; load for step reset
		sta TabPlatformStep,x					; store it off
	
		inc TabPlatformDir,x					; update the direction
	
		jmp Exit								; jump out
		
Backward
	
		lda _PlayerClamped						; is player clamped to platform
		cmp #$01								; test it
		bne BackwardCount						; no jump the player decremt

		sec										; set the carry for subtraction
		lda m_playerLevelLeftX_H1				; load the low left X
		sbc #$01								; subtract one
		sta m_playerLevelLeftX_H1				; store it	
		lda m_playerLevelLeftX_H2				; load the high left X
		sbc #$00								; subtract with carry
		sta m_playerLevelLeftX_H2				; store it
		jsr SetPlayerInfo						; update the players info
		
BackwardCount
		dec TabPlatformCount,x					; decrement the counter
		lda TabPlatformCount,x					; load it for compare	
		cmp #$FF								; check against value
		bne Exit								; not there yet
	
		lda #$03								; load the reset value
		sta TabPlatformCount,x					; store it

		inc TabPlatformStep,x					; increment the step
		lda TabPlatformStep,x					; load it for compare
		cmp _PlatformMaxStep					; check against value 
		bne MoveBackward						; not there yet

		lda #$00								; load for forward
		sta TabPlatformCount,x					; store it

		lda #$00								; load for step reset
		sta TabPlatformStep,x					; store it off
	
		inc TabPlatformDir,x					; update the direction

		jmp Exit								; jump out
	
MoveForward
	
		ldx m_currPlatformIdx
		clc										; prepare for addition
		lda TabPlatformLSB_H,x					; load the LSB screen address
		adc #$01								; add one
		sta TabPlatformLSB_H,x					; store it
		lda TabPlatformMSB_H,x					; load the MSB screen address 
		adc #$00								; add with carry
		sta TabPlatformMSB_H,x					; store it
		
		jmp Exit								; jump out
	
MoveBackward

		ldx m_currPlatformIdx
		sec										; prepare for subtraction
		lda TabPlatformLSB_H,x					; load the LSB screen address
		sbc #$01								; substract one
		sta TabPlatformLSB_H,x					; store it
		lda TabPlatformMSB_H,x					; load the mSB screen address
		sbc #$00								; subtract with carry	
		sta TabPlatformMSB_H,x					; store it
	
Exit

		rts										; return from routine
	
.endp	

;
;**************************************************************************************************
; 	ClearPlatformMemory
;**************************************************************************************************
;
.proc ClearPlatformMemory
	
		lda #$00
		sta _PlayerClamped			
		sta _PlatformCurrTimer
		
		ldx #$00
		
Loop
		sta TabPlatformDir,x  
		sta TabPlatformStep,x  
		sta TabPlatformCount,x  
		sta TabPlatformLSB_H,x
		sta TabPlatformMSB_H,x
		
		inx
		cpx #$08
		bne Loop

		rts
.endp
;
;**************************************************************************************************
; 	CopyChar
;**************************************************************************************************
;
.proc CopyChar

		clc										; set the carry for addition
		lda m_paramW01							; load the first LSB for the animation character
		adc #$08								; add eight
		sta m_paramW02							; store the LSB in address 2
		lda m_paramW01+1						; load the first MSB for the animation character	
		adc #$00								; add with carry
		sta m_paramW02+1						; store the MSB in address 2

		clc										; set the carry for addition
		lda m_paramW02							; load the second LSB for the animation character   
		adc #$08      							; add eight                                        
		sta m_paramW03							; store the LSB in address 3                       
		lda m_paramW02+1						; load the second MSB for the animation character	 	
		adc #$00      							; add with carry                                   
		sta m_paramW03+1						; store the MSB in address 3

		clc										; set the carry for addition                        
		lda m_paramW03							; load the third LSB for the animation character    
		adc #$08								; add eight                                         
		sta m_paramW04							; store the LSB in address 4                        
		lda m_paramW03+1						; load the third MSB for the animation character	
		adc #$00								; add with carry                                    
		sta m_paramW04+1						; store the MSB in address 4                        

		ldy #$00	 							; get the offset to the animation font
		lda #$08								; multiply by eight
		ldx TabPlatformCount,y					; get the multiplicant
		jsr MultiplyAX							; multiply
	
		ldy #$00								; rest the offset
		ldx _productLo							; load the low product

CopyCharLoop

		lda HFP001,x							; get the 1st char
		sta (m_paramW01),y						; store it 
		lda HFP002,x							; get the 2nd char
		sta (m_paramW02),y						; store it        
		lda HFP003,x							; get the 3rd char
		sta (m_paramW03),y						; store it        
		lda HFP004,x							; get the 4th char
		sta (m_paramW04),y						; store it        
		inx										; increment the char offset	
		iny										; increment the address offset
		cpy #$08								; have we completed 8	
		bne CopyCharLoop						; no branch back
	
		rts										; return from sub
	
.endp
