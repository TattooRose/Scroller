;	
;**************************************************************************************************
; Filename:		animation_logic.asm
; Project:		Plunker
;
; Created On:	Mon Aug 28, 2017 02:05 AM	
; Modified On:	Wed Mar 27, 2018 04:36 PM
;
;**************************************************************************************************
;
;**************************************************************************************************
; Local Storage
;**************************************************************************************************
ANIM_COIN_CHAR1 			= $0A
ANIM_COIN_FRAMES 			= $06
ANIM_COIN_MAX_NUMBER 		= $08
ANIM_SEA_TOP_FRAME_TIME 	= $04

m_animSeaTopTimer			.byte ANIM_SEA_TOP_FRAME_TIME

m_firstCoinAnimIndex		.byte $00
m_emptyCoinAnimIndex		.byte $00
m_currentCoinAnimations		.byte $00

m_animHLaserTimer			.byte $01
m_animHLaserCurrentFrame	.byte $00

m_animLaserTimer			.byte $01
m_animLaserCurrentFrame		.byte $00

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
	
TabAnimLaserFrameAddressLSB
	:30 .byte <TabAnimLaserFrame_01, <TabAnimLaserFrame_02
	.byte <TabAnimLaserFrame_03
						
TabAnimLaserFrameAddressMSB
	:30 .byte >TabAnimLaserFrame_01, >TabAnimLaserFrame_02
	.byte >TabAnimLaserFrame_03

TabAnimHLaserFrameAddressLSB
	:30 .byte <TabAnimHLaserFrame_01, <TabAnimHLaserFrame_02
	.byte <TabAnimHLaserFrame_03

TabAnimHLaserFrameAddressMSB
	:30 .byte >TabAnimHLaserFrame_01, >TabAnimHLaserFrame_02
	.byte >TabAnimHLaserFrame_03

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimHLaserFrameTime
	:30 .byte $01, $01
		.byte $5A

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimLaserFrameTime
	:30 .byte $01, $01
	.byte $3C

.else

	ANIM_LASER_FRAMES 		= $33
	ANIM_HLASER_FRAMES 		= $33

TabAnimLaserFrameAddressLSB
	:25 .byte <TabAnimLaserFrame_01, <TabAnimLaserFrame_02
		.byte <TabAnimLaserFrame_03
							
TabAnimLaserFrameAddressMSB
	:25 .byte >TabAnimLaserFrame_01, >TabAnimLaserFrame_02
		.byte >TabAnimLaserFrame_03

TabAnimHLaserFrameAddressLSB
	:25 .byte <TabAnimHLaserFrame_01, <TabAnimHLaserFrame_02
		.byte <TabAnimHLaserFrame_03

TabAnimHLaserFrameAddressMSB
	:25 .byte >TabAnimHLaserFrame_01, >TabAnimHLaserFrame_02
		.byte >TabAnimHLaserFrame_03

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimHLaserFrameTime
	:25 .byte $01, $01
		.byte $4B

; right now, if the index to these tables is 60, then we are in the "disabled" state
TabAnimLaserFrameTime
	:25 .byte $01, $01
	.byte $32

.endif

;
;**************************************************************************************************
; DoFontAnimations	
;**************************************************************************************************
;
DoFontAnimations
	
DFA_anim_sea_top
	; do sea top animation (chars 12, 13)
	dec m_animSeaTopTimer
	bne DFA_end_anim_sea_top

	lda #ANIM_SEA_TOP_FRAME_TIME
	sta m_animSeaTopTimer

	lda GameFontAddr+8*71
	lsr											; put left bit in the carry
	ror GameFontAddr+8*70
	ror GameFontAddr+8*71
	ror GameFontAddr+8*70
	ror GameFontAddr+8*71

	lda GameFontAddr+8*71+1
	lsr											; put left bit in the carry
	ror GameFontAddr+8*70+1
	ror GameFontAddr+8*71+1
	ror GameFontAddr+8*70+1
	ror GameFontAddr+8*71+1

	lda GameFontAddr+8*71+2
	lsr											; put left bit in the carry
	ror GameFontAddr+8*70+2
	ror GameFontAddr+8*71+2
	ror GameFontAddr+8*70+2
	ror GameFontAddr+8*71+2

;**************************************************
;
DFA_end_anim_sea_top

;**************************************************
;
DFA_anim_laser
	; do vertical line dither, laser animation (char 16)
	dec m_animLaserTimer
	bne DFA_end_anim_laser

	ldx m_animLaserCurrentFrame
	inx
	cpx #ANIM_LASER_FRAMES
	bne DFA_anim_laser_next_frame
	ldx #0

;**************************************************
;
DFA_anim_laser_next_frame
	stx m_animLaserCurrentFrame
	lda TabAnimLaserFrameTime,x
	sta m_animLaserTimer

	lda TabAnimLaserFrameAddressLSB,x
	sta DFA_anim_laser_copy_frame+1
	lda TabAnimLaserFrameAddressMSB,x
	sta DFA_anim_laser_copy_frame+2

	ldy #7
	
;**************************************************
;
DFA_anim_laser_copy_frame
	lda $FFFF,y
	sta GameFontAddr+8*21,y
	dey
	bpl DFA_anim_laser_copy_frame

;**************************************************
;
DFA_end_anim_laser

;**************************************************
;
DFA_anim_laserH
	dec m_animHLaserTimer						; do horizontal line dither, laser animation (char 25)
	bne DFA_end_anim_laserH

	ldx m_animHLaserCurrentFrame
	inx
	cpx #ANIM_HLASER_FRAMES
	bne DFA_anim_laserH_next_frame
	ldx #0

;**************************************************
;
DFA_anim_laserH_next_frame
	stx m_animHLaserCurrentFrame
	lda TabAnimHLaserFrameTime,x
	sta m_animHLaserTimer

	lda TabAnimHLaserFrameAddressLSB,x
	sta DFA_anim_laserH_copy_frame+1
	lda TabAnimHLaserFrameAddressMSB,x
	sta DFA_anim_laserH_copy_frame+2

	ldy #2

;**************************************************
;
DFA_anim_laserH_copy_frame
	lda $FFFF,y
	sta GameFontAddr+8*25+2,y
	dey
	bpl DFA_anim_laserH_copy_frame

DFA_end_anim_laserH
	rts
;
;**************************************************************************************************
; AddCoinAnimation	
;**************************************************************************************************
;
AddCoinAnimation
	lda m_currentCoinAnimations					; the word "m_pageZeroTempPointer" has the address of the char to animate
	cmp #ANIM_COIN_MAX_NUMBER
	beq ACA_exit
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

;**************************************************
;
ACA_exit
	rts
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
