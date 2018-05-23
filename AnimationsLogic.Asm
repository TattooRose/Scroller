;
;***************************************************************************************************
;
;	Filename:		AnimationsLogic.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;*****	Local to Animations Logic
;
ANIM_COIN_CHAR1 			= $0A
ANIM_COIN_FRAMES 			= $06
ANIM_COIN_MAX_NUMBER 		= $08

ANIM_MISC_FRAME_TIME		= $04
ANIM_SEA_TOP_FRAME_TIME 	= $04

TabCoinAnimFrame			.byte $00, $00, $00, $00, $00, $00, $00, $00

TabCoinAnimTimer			.byte $00, $00, $00, $00, $00, $00, $00, $00

TabCoinAnimCharTime			.byte $02, $02, $02, $02, $02, $02

TabCoinAnimAddressLSB		.byte $00, $00, $00, $00, $00, $00, $00, $00
TabCoinAnimAddressMSB		.byte $00, $00, $00, $00, $00, $00, $00, $00

; vertical line, dither (red)
TabAnimLaserFrame_01		.byte %00110000,%00001100,%00110000,%00001100,%00110000,%00001100,%00110000,%00001100
TabAnimLaserFrame_02		.byte %00001100,%00110000,%00001100,%00110000,%00001100,%00110000,%00001100,%00110000
TabAnimLaserFrame_03		.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000

; hoizontal line, dither (red)
TabAnimHLaserFrame_01		.byte %00110011, %11001100, %00110011
TabAnimHLaserFrame_02		.byte %11001100, %00110011, %11001100
TabAnimHLaserFrame_03		.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

; sea top (blue)
TabAnimSeaTopLeftFrame_01	.byte %00001111
							.byte %00111111
							.byte %11111111
							.byte %11111111

TabAnimSeaTopRightFrame_01	.byte %00000000
							.byte %11000000
							.byte %11110000
							.byte %11111111

.if PAL_VERSION = 0
	
	ANIM_LASER_FRAMES 		= $3D
	ANIM_HLASER_FRAMES 		= $3D
	
TabAnimLaserFrameAddressLSB		:30 .byte <TabAnimLaserFrame_01, <TabAnimLaserFrame_02
									.byte <TabAnimLaserFrame_03
						
TabAnimLaserFrameAddressMSB		:30 .byte >TabAnimLaserFrame_01, >TabAnimLaserFrame_02
									.byte >TabAnimLaserFrame_03

TabAnimHLaserFrameAddressLSB	:30 .byte <TabAnimHLaserFrame_01, <TabAnimHLaserFrame_02
									.byte <TabAnimHLaserFrame_03

TabAnimHLaserFrameAddressMSB	:30 .byte >TabAnimHLaserFrame_01, >TabAnimHLaserFrame_02
									.byte >TabAnimHLaserFrame_03

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimHLaserFrameTime			:30 .byte $01, $01
									.byte $5A

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimLaserFrameTime			:30 .byte $01, $01
									.byte $3C

.else

	ANIM_LASER_FRAMES 		= $33
	ANIM_HLASER_FRAMES 		= $33

TabAnimLaserFrameAddressLSB		:25 .byte <TabAnimLaserFrame_01, <TabAnimLaserFrame_02
									.byte <TabAnimLaserFrame_03
							
TabAnimLaserFrameAddressMSB		:25 .byte >TabAnimLaserFrame_01, >TabAnimLaserFrame_02
									.byte >TabAnimLaserFrame_03

TabAnimHLaserFrameAddressLSB	:25 .byte <TabAnimHLaserFrame_01, <TabAnimHLaserFrame_02
									.byte <TabAnimHLaserFrame_03

TabAnimHLaserFrameAddressMSB	:25 .byte >TabAnimHLaserFrame_01, >TabAnimHLaserFrame_02
									.byte >TabAnimHLaserFrame_03

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimHLaserFrameTime			:25 .byte $01, $01
									.byte $4B

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimLaserFrameTime			:25 .byte $01, $01
									.byte $32

.endif

;
;**************************************************************************************************
; DoFontAnimations	
;**************************************************************************************************
;
.proc DoFontAnimations
	
		jsr AnimateWater
		jsr AnimateVerticalLaser
		jsr AnimateHorizontalLaser
		jsr AnimateMisc		
		jsr PlatformControlH
		
		rts
		
.endp

;
;**************************************************************************************************
;
;	AddCoinAnimation
;
;		the word "m_pageZeroTempPointer" has the address of the char to animate
;	
;**************************************************************************************************
;
.proc AddCoinAnimation
	
		lda m_currentCoinAnimations					
		cmp #ANIM_COIN_MAX_NUMBER
		beq Exit
		
		inc m_currentCoinAnimations
		ldx m_emptyCoinAnimIndex
	
		lda m_pageZeroTempPointer
		sta TabCoinAnimAddressLSB,x
		
		lda m_pageZeroTempPointer+1
		sta TabCoinAnimAddressMSB,x

		lda #0										; use first frame
		sta TabCoinAnimFrame,x
	
		lda TabCoinAnimCharTime						; use first element of the table
		sta TabCoinAnimTimer,x

		ldy #0
		lda #ANIM_COIN_CHAR1
		sta (m_pageZeroTempPointer),y				; update screen

		inx
		txa
		and #%111
		sta m_emptyCoinAnimIndex

;*****	Add Coin Animation Exit
;
Exit
		rts

.endp
	
;
;**************************************************************************************************
; UpdateCoinAnimations	
;**************************************************************************************************
;
UpdateCoinAnimations

	lda m_currentCoinAnimations					; update coin animations every frame	
	beq UCA_exit
	ldx m_firstCoinAnimIndex

;**************************************************
;
UCA_loop
	dec TabCoinAnimTimer,x
	bne UCA_check_loop

	inc TabCoinAnimFrame,x
	lda TabCoinAnimFrame,x
	cmp #ANIM_COIN_FRAMES
	beq UCA_clear_anim

;**************************************************
;
UCA_update_anim
	tay
	lda TabCoinAnimCharTime,y					; #ANIM_COIN_TIME
	sta TabCoinAnimTimer,x

	lda TabCoinAnimAddressLSB,x
	sta UCA_char_pointer+1
	lda TabCoinAnimAddressMSB,x
	sta UCA_char_pointer+2

;**************************************************
;
UCA_char_pointer
	inc $FFFF									; update the animation frame, increment the char on screen
	jmp UCA_check_loop

;**************************************************
;
UCA_clear_anim
	lda TabCoinAnimAddressLSB,x
	sta UCA_clear_char_pointer+1
	lda TabCoinAnimAddressMSB,x
	sta UCA_clear_char_pointer+2
	lda #0

;**************************************************
;
UCA_clear_char_pointer
	sta $FFFF									; clear the char on screen
	dec m_currentCoinAnimations
	ldy m_firstCoinAnimIndex
	iny
	tya
	and #%111
	sta m_firstCoinAnimIndex

;**************************************************
;
UCA_check_loop
	inx
	txa
	and #%111
	tax
	cpx m_emptyCoinAnimIndex
	bne UCA_loop

;**************************************************
;
UCA_exit
	rts

;
;***************************************************************************************************
;	
;	AnimateWater
;	
; 		do sea top animation (chars 70, 71)
; 
;***************************************************************************************************
;	
.proc AnimateWater

	lda m_waterAvailable
	beq Exit
	
	dec m_animSeaTopTimer
	bne Exit

	lda #ANIM_SEA_TOP_FRAME_TIME
	sta m_animSeaTopTimer

	lda GameFontAddress+8*71
	lsr											; put left bit in the carry
	ror GameFontAddress+8*70
	ror GameFontAddress+8*71
	ror GameFontAddress+8*70
	ror GameFontAddress+8*71

	lda GameFontAddress+8*71+1
	lsr											; put left bit in the carry
	ror GameFontAddress+8*70+1
	ror GameFontAddress+8*71+1
	ror GameFontAddress+8*70+1
	ror GameFontAddress+8*71+1

	lda GameFontAddress+8*71+2
	lsr											; put left bit in the carry
	ror GameFontAddress+8*70+2
	ror GameFontAddress+8*71+2
	ror GameFontAddress+8*70+2
	ror GameFontAddress+8*71+2

;*****	Exit
;
Exit

		rts
.endp	

;
;***************************************************************************************************
;	
;	AnimateVerticalLaser
;	
; 		do vertical line dither, laser animation (char 20, 21, 22)
; 
;***************************************************************************************************
;	
.proc AnimateVerticalLaser

		lda m_verticalLaserOn
		beq Exit
		
		dec m_animLaserTimer						
		bne Exit

		ldx m_animLaserCurrentFrame
		inx
		cpx #ANIM_LASER_FRAMES
		bne NextFrame
		
		ldx #0

;*****	Animate Vertical Laser Next Frame
;
NextFrame

		stx m_animLaserCurrentFrame

		lda TabAnimLaserFrameTime,x
		sta m_animLaserTimer

		lda TabAnimLaserFrameAddressLSB,x
		sta CopyFrame+1

		lda TabAnimLaserFrameAddressMSB,x
		sta CopyFrame+2

		ldy #7
	
;*****	Animate Vertical Laser Copy Frame
;
CopyFrame
	
		lda $FFFF,y
		sta GameFontAddress+8*21,y
		dey
		bpl CopyFrame

;*****	Animate Vertical Laser End
;
Exit
		
		rts

.endp

;
;***************************************************************************************************
;	
;	AnimateHorizontalLaser
;	
; 		do horizontal line dither, laser animation (char 23, 24, 25)
; 
;***************************************************************************************************
;	
.proc AnimateHorizontalLaser

		lda m_horizontalLaserOn
		beq Exit

		dec m_animHLaserTimer						
		bne Exit

		ldx m_animHLaserCurrentFrame
		inx
		cpx #ANIM_HLASER_FRAMES
		bne NextFrame
		
		ldx #0

;******	Animate Horizontal Laser Next Frame
;
NextFrame
		
		stx m_animHLaserCurrentFrame
		lda TabAnimHLaserFrameTime,x
		sta m_animHLaserTimer

		lda TabAnimHLaserFrameAddressLSB,x
		sta CopyFrame+1
		
		lda TabAnimHLaserFrameAddressMSB,x
		sta CopyFrame+2

		ldy #2

;*****	Animate Horizontal Laser Copy Frame
;
CopyFrame
	
		lda $FFFF,y
		sta GameFontAddress+8*25+2,y
		dey
		bpl CopyFrame

;*****	Animate Horizontal Laser Exit
;
Exit
		rts

.endp

;
;***************************************************************************************************
;	
;	AnimateMisc
;	
; 		do misc animation
; 
;***************************************************************************************************
;	
.proc AnimateMisc

		ldx #$00

		lda TabAnimationMiscMap[0], x
		sta m_paramW01

		lda TabAnimationMiscMap[0]+1, x
		sta m_paramW01+1
		
		lda TabAnimationMiscMap[0]+3, x
		sta m_animMiscWidth

		lda TabAnimationMiscMap[0]+4, x
		sta m_animMiscHeight
	
		lda m_playerScreenTopY
		ldy m_animMiscHeight		
Sub1
		sec
		sbc #$01
		dey
		bne Sub1
		
				 
		
Loop
				

;*****	Exit Method
Exit

		rts

.endp