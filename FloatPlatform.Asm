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
.struct PlatformStruct
	on		.byte 
	dir		.byte
	len		.byte
	xpos	.byte 
	ypos	.byte
	sxpos	.byte
	sypos	.byte
	dxpos	.byte
	dypos	.byte	
	timer	.byte
.ends`

FLOAT_PLATFORM_COUNT	= 0
FLOAT_PLATFORM_TIMER	= 6

TabPlatformMap dta PlatformStruct[2]	($00, $01, $04, $28, $21, $28, $21, $30, $21, $00) 
;
;**************************************************************************************************
; PlatformControl
;**************************************************************************************************
.proc PlatformControl

	lda #FLOAT_PLATFORM_COUNT
	beq CTL_Exit
	
	tay
	ldx #$00

;************************************************
;
CTL_Loop	
	lda TabPlatformMap[0].on,x
	cmp #$01
	beq CTL_CheckTime
	inx
	cpx #FLOAT_PLATFORM_COUNT
	beq CTL_Exit
	jmp CTL_Loop
	
;************************************************
;
CTL_CheckTime
	lda TabPlatformMap[0].timer,x
	cmp FLOAT_PLATFORM_TIMER
	beq CTL_Move
	clc
	adc $01
	sta TabPlatformMap[0].timer,x
	jmp CTL_Loop
	
;************************************************
;
CTL_Move
		
;************************************************
;
CTL_Exit
	rts

.endp	