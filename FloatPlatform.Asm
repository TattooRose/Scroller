;
;***************************************************************************************************
;
;	Filename:		FloatPlatform.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; Local Storage
;**************************************************************************************************
;
FLOAT_PLATFORM_CHR_X    = 6

FLOAT_PLATFORM_MAX_X	= 15

FLOAT_PLATFORM_MAX_Y	= 5

FLOAT_PLATFORM_TIMER	= 6

PlatformCharX			.byte $00, $26, $27, $28, $29, $00

PlatformLSB				.byte $00, $00, $00, $00, $00, $00, $00, $00 

PlatformMSB				.byte $00, $00, $00, $00, $00, $00, $00, $00 

PlatformTime 			.byte $00, $00, $00, $00, $00, $00, $00, $00 

PlatformType 			.byte $00, $00, $00, $00, $00, $00, $00, $00 

PlatformDirX			.byte $00, $00, $00, $00, $00, $00, $00, $00

PlatformStepX			.byte $00, $00, $00, $00, $00, $00, $00, $00

PlatformStepY			.byte $00, $00, $00, $00, $00, $00, $00, $00

PlatformCharH			.byte $26, $A6

PlatformCharY			.byte $00, $00

PlatformBaseLSB			.byte $00, $00, $00, $00, $00, $00, $00, $00 

PlatformBaseMSB			.byte $00, $00, $00, $00, $00, $00, $00, $00 

;
;**************************************************************************************************
; PlatformControlH
;**************************************************************************************************
.proc PlatformControlH

		sta m_SaveRegA
		stx m_SaveRegX
		sty m_SaveRegY
	
		lda m_floatPlatformH
		bne LoadIndex
		jmp Exit 
	
LoadIndex
 
		ldx m_floatPlatformIdx
		dex 
		stx m_param00
	
		lda PlatformTime, x
		cmp #FLOAT_PLATFORM_TIMER
		beq PerformAnimation
	
		clc
		adc #01
		sta PlatformTime, x

		jmp Exit
	
PerformAnimation
	
		lda PlatformLSB,x
		sta m_platformLevelPointer
		
		lda PlatformMSB,x
		sta m_platformLevelPointer+1

		lda PlatformDirX, x
		cmp #$00
		beq MoveForward
	
		cmp $01
		beq MoveBack 		
	
		jmp Exit
		
MoveForward
	
		ldy #$00	
		ldx #$00	

moveF
	
		lda PlatformCharX, x
		sta (m_platformLevelPointer), y
		iny
		inx
		cpx #FLOAT_PLATFORM_CHR_X
		bne moveF

		ldx m_param00		

		clc
		lda PlatformStepX, x
		adc #$01		
		sta PlatformStepX, x
		cmp #FLOAT_PLATFORM_MAX_X	
		beq SetBackDir	
	
		clc
		lda PlatformLSB,x
		adc #$01
		sta PlatformLSB,x
		lda PlatformMSB,x
		adc #$00
		sta PlatformMSB,x
	
		jmp ResetTime
				 	
MoveBack
	
		ldy #FLOAT_PLATFORM_CHR_X - 1	
		ldx #FLOAT_PLATFORM_CHR_X - 1
	
moveB
	
		lda PlatformCharX, x
		sta (m_platformLevelPointer), y
		dey
		dex
		cpx #$00
		bne moveB
	
		ldx m_param00	
	
		sec
		lda PlatformStepX, x
		sbc #$01
		sta PlatformStepX, x
		cmp #$00
		beq SetForwardDir	
		
		sec
		lda PlatformLSB,x
		sbc #$01
		sta PlatformLSB,x
		lda PlatformMSB,x	
		sbc #0
		sta PlatformMSB,x
		
		jmp ResetTime

SetBackDir
	
		lda #$01
		sta PlatformDirX, x
		jmp ResetTime

SetForwardDir
	
		lda #$00
		sta PlatformDirX, x
	
ResetTime

		lda #00
		sta PlatformTime, x
	

;*****	Exit
;
Exit

		lda m_SaveRegA
		ldx m_SaveRegX
		ldy m_SaveRegY
	
		rts

.endp	