;
;***************************************************************************************************
;
;	Filename:		PlayerStates.Asm
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
TabPlayerMethodColor
.if PAL_VERSION = 0
	.byte 10, 11*16+10, 9*16+10, 9*16+10, 1*16+12, 7*16+8, 4, 2*16+6
.else
	.byte 10, 10*16+10, 8*16+10, 8*16+10, 15*16+12, 7*16+8, 4, 1*16+6
.endif

TabPlayerMethodLSB
	.byte <PlayerMethodStatic, <PlayerMethodOverPlatform
	.byte <PlayerMethodJumping, <PlayerMethodFalling
	.byte <PlayerMethodClimbing, <PlayerMethodInWater
	.byte <PlayerMethodGravityTest, <PlayerMethodLose

TabPlayerMethodMSB
	.byte >PlayerMethodStatic, >PlayerMethodOverPlatform
	.byte >PlayerMethodJumping, >PlayerMethodFalling
	.byte >PlayerMethodClimbing, >PlayerMethodInWater
	.byte >PlayerMethodGravityTest, >PlayerMethodLose

TabPlayerMethodInitLSB
	.byte <PlayerMethodInitStatic, <PlayerMethodInitOverPlatform
	.byte <PlayerMethodInitJumping, <PlayerMethodInitFalling
	.byte <PlayerMethodInitClimbing, <PlayerMethodInitInWater
	.byte <PlayerMethodInitGravityTest, <PlayerMethodInitLose

TabPlayerMethodInitMSB
	.byte >PlayerMethodInitStatic, >PlayerMethodInitOverPlatform
	.byte >PlayerMethodInitJumping, >PlayerMethodInitFalling
	.byte >PlayerMethodInitClimbing, >PlayerMethodInitInWater
	.byte >PlayerMethodInitGravityTest, >PlayerMethodInitLose
;
;**************************************************************************************************
; SetPlayerMethod
;**************************************************************************************************
;
SetPlayerMethod
	stx m_playerState
	
	lda TabPlayerMethodLSB,x
	sta m_playerMethodPointer
	
	lda TabPlayerMethodMSB,x
	sta m_playerMethodPointer+1

	lda #$8A
	sta m_playerBaseColor00	
	
	lda #$3A
	sta m_playerBaseColor1A
		
	lda #$0F
	sta m_playerBaseColor1B
		
	lda TabPlayerMethodInitLSB,x
	sta m_pageZeroTempPointer
	
	lda TabPlayerMethodInitMSB,x
	sta m_pageZeroTempPointer+1
	
	jmp (m_pageZeroTempPointer)
;
;**************************************************************************************************
; PlayerMethodInitStatic
;**************************************************************************************************
;
PlayerMethodInitStatic
	rts
;
;**************************************************************************************************
; PlayerMethodInitOverPlatform
;**************************************************************************************************
;
PlayerMethodInitOverPlatform
	lda #0										; clear player speed in Y
	sta m_playerSpeedY_H1
	sta m_playerSpeedY_L1
	
	lda #SIDE_SPEED_LAND_H1						; init max side speed
	sta m_playerMaxSideSpeed_H1
	lda #SIDE_SPEED_LAND_L1
	sta m_playerMaxSideSpeed_L1
	
	lda #SIDE_ACCEL_LAND_H1						; init side accelerations
	sta m_playerSideAccel_H1
	lda #SIDE_ACCEL_LAND_L1
	sta m_playerSideAccel_L1

	lda #SIDE_DEACCEL_LAND_H1
	sta m_playerSideDeaccel_H1
	lda #SIDE_DEACCEL_LAND_L1
	sta m_playerSideDeaccel_L1
	rts
;
;**************************************************************************************************
; PlayerMethodInitJumping
;**************************************************************************************************
;
PlayerMethodInitJumping

	lda #JUMP_HOLD_FRAMES						; hold jump for this number of frames, if the button is still pressed
	sta m_playerHoldJumpCounter

	lda m_playerJumpSpeed_H1
	sta m_playerSpeedY_H1
	lda m_playerJumpSpeed_L1
	sta m_playerSpeedY_L1

	lda #SIDE_SPEED_AIR_H1						; init max side speed
	sta m_playerMaxSideSpeed_H1
	lda #SIDE_SPEED_AIR_L1
	sta m_playerMaxSideSpeed_L1

	lda #SIDE_ACCEL_AIR_H1						; init side accelerations
	sta m_playerSideAccel_H1
	lda #SIDE_ACCEL_AIR_L1
	sta m_playerSideAccel_L1

	lda #SIDE_DEACCEL_AIR_H1
	sta m_playerSideDeaccel_H1
	lda #SIDE_DEACCEL_AIR_L1
	sta m_playerSideDeaccel_L1
	rts
;
;**************************************************************************************************
; PlayerMethodInitFalling
;**************************************************************************************************
;
PlayerMethodInitFalling

	lda #SIDE_SPEED_AIR_H1						; init max side speed
	sta m_playerMaxSideSpeed_H1
	lda #SIDE_SPEED_AIR_L1
	sta m_playerMaxSideSpeed_L1

	lda #SIDE_ACCEL_AIR_H1						; init side accelerations
	sta m_playerSideAccel_H1
	lda #SIDE_ACCEL_AIR_L1
	sta m_playerSideAccel_L1

	lda #SIDE_DEACCEL_AIR_H1
	sta m_playerSideDeaccel_H1
	lda #SIDE_DEACCEL_AIR_L1
	sta m_playerSideDeaccel_L1

	rts
;
;**************************************************************************************************
; PlayerMethodInitClimbing
;**************************************************************************************************
;
PlayerMethodInitClimbing

	lda #0										; clear player speed in X and Y
	sta m_playerSideSpeed_H1
	sta m_playerSideSpeed_L1
	sta m_playerSpeedY_H1
	sta m_playerSpeedY_L1

	rts
;
;**************************************************************************************************
; PlayerMethodInitInWater
;**************************************************************************************************
;
PlayerMethodInitInWater

	lda #1										; set starting direction going down (0 = going up, 1 = going down)
	sta m_waterPlayerDirectionFlag

	lda #0
	sta m_playerOnWaterSurfaceFlag

	lsr m_playerSpeedY_H1						; reduce in half current falling speed
	ror m_playerSpeedY_L1

	lsr m_playerSideSpeed_H1					; reduce in half current side speed
	ror m_playerSideSpeed_L1

	lda #SIDE_SPEED_WATER_H1					; init max side speed
	sta m_playerMaxSideSpeed_H1
	lda #SIDE_SPEED_WATER_L1
	sta m_playerMaxSideSpeed_L1

	lda #SIDE_ACCEL_WATER_H1					; init side accelerations
	sta m_playerSideAccel_H1
	lda #SIDE_ACCEL_WATER_L1
	sta m_playerSideAccel_L1

	lda #SIDE_DEACCEL_WATER_H1
	sta m_playerSideDeaccel_H1
	lda #SIDE_DEACCEL_WATER_L1
	sta m_playerSideDeaccel_L1

	lda #WATER_NO_JUMP_FRAMES					; disable jump for some frames
	sta m_playerNoJumpTimer
	
	rts
;
;**************************************************************************************************
; PlayerMethodInitGravityTest
;**************************************************************************************************
;
PlayerMethodInitGravityTest
	rts
;
;**************************************************************************************************
; PlayerMethodInitLose
;**************************************************************************************************
;
PlayerMethodInitLose
	lda m_playerScreenTopY
	sta m_playerExplosionScreenTopY_H1
	lda #0
	sta m_playerExplosionScreenTopY_L1

	lda #1
	sta m_playerExplosionStep

	rts
;
;**************************************************************************************************
; PlayerMethodInitLose
;**************************************************************************************************
;
PlayerMethodStatic
	jmp PlayerMethodReturn

;
;**************************************************************************************************
;
; 	CheckCollectable
;
;**************************************************************************************************
;
.proc CheckCollectable

	lda #[PLR_WIDTH / 2]						; check middle left center pixel, to see if there is a collectable
	sta m_bottomPosOffsetX
	
	lda #[PLR_HEIGHT / 2]
	sta m_bottomPosOffsetY
	
	jsr CheckPlayerBottomUpPos

	and #15
	cmp #CT_COLLECTABLE
	beq DecrementCoins
	
	cmp	#CT_HEALTH
	beq DecrementHealth
	
;	lda m_playerLevelLeftX_H1					; check if right side pixel is in other char
;	and #%11									; "m_playerSizeXMinusOne"
;	beq CC_exit
;
;	iny											; check the right side char then
;	lda (m_ptrLevelLine),y
;	tax
;	lda TabCharDefinition,x
;	
;	and #15	
;	cmp #CT_COLLECTABLE
;	beq DecrementCoins
;	
;	cmp	#CT_HEALTH
;	beq DecrementHealth
	
;	inc m_middleBottomCharPosX

	jmp CC_exit
	
;***** Decrement Coins
;	
DecrementCoins
	
	dec m_goldCounter
	lda #06
	sta m_sfxEffect
	jmp CC_start_animation
	
;***** Decrement Health
;	
DecrementHealth	
	
	dec m_healthCounter
	lda #06
	sta m_sfxEffect
		
;*****	Start Animation
;
CC_start_animation								; erase the collectable with the correct animation
	lda m_ptrLevelLine
	clc
	adc m_middleBottomCharPosX
	sta m_pageZeroTempPointer
	lda m_ptrLevelLine+1
	adc #0
	sta m_pageZeroTempPointer+1

	jsr AddCoinAnimation
	
;*****	Exit Proc
;
CC_exit
		
		rts
		
.endp
		
;
;**************************************************************************************************
; DoSideMovement
;**************************************************************************************************
;
DoSideMovement

	lda m_stick0
	and #[STICK_RIGHT | STICK_LEFT]
	cmp #[STICK_RIGHT | STICK_LEFT]
	bne DSM_check_right							; if one or both are pressed, just continue

;**************************************************
;
DSM_check_deaccel_right
	lda m_lastPlayerSideDirection
	cmp #PSD_RIGHT
	bne DSM_check_deaccel_left

	jsr SubstractSideDeaccelToSpeed
	jsr AddSideSpeedToPosition
	jmp DSM_exit

;**************************************************
;
DSM_check_deaccel_left
	cmp #PSD_LEFT
	beq DSM_cdl1
	jmp DSM_exit

;**************************************************
;
DSM_cdl1
	jsr SubstractSideDeaccelToSpeed
	jsr SubstractSideSpeedToPosition
	jmp DSM_exit

;**************************************************
;
DSM_check_right
	and #STICK_RIGHT	; check right
	bne DSM_check_left

	lda m_lastPlayerSideDirection
	cmp #PSD_LEFT
	bne DSM_move_to_right

	lda #0
	sta m_playerSideSpeed_H1
	sta m_playerSideSpeed_L1

;**************************************************
;
DSM_move_to_right
	lda #PSD_RIGHT
	sta m_lastPlayerSideDirection
	jsr AddSideAccelToSpeed
	jsr AddSideSpeedToPosition
	jmp DSM_exit

;**************************************************
;
DSM_check_left
	lda m_stick0
	and #STICK_LEFT						; check left
	bne DSM_exit

	lda m_lastPlayerSideDirection
	cmp #PSD_RIGHT
	bne DSM_move_to_left

	lda #0
	sta m_playerSideSpeed_H1
	sta m_playerSideSpeed_L1

;**************************************************
;
DSM_move_to_left
	lda #PSD_LEFT
	sta m_lastPlayerSideDirection
	jsr AddSideAccelToSpeed
	jsr SubstractSideSpeedToPosition

;**************************************************
;
DSM_exit
	rts
;
;**************************************************************************************************
; DoSideControl
;**************************************************************************************************
;
DoSideControl

	lda m_stick0
	and #[STICK_RIGHT | STICK_LEFT]
	cmp #[STICK_RIGHT | STICK_LEFT]
	beq DSC_check_right							; if neither is pressed, just continue

;**************************************************
;
DSC_side_control_right
	and #STICK_RIGHT
	bne DSC_side_control_left
	lda m_lastPlayerSideDirection
	cmp #PSD_RIGHT
	bne DSC_scr1
	jsr AddSideAccelToSpeed
	jmp DSC_check_right

;**************************************************
;
DSC_scr1
	cmp #PSD_LEFT
	bne DSC_scr2
	jsr SubstractSideDeaccelToSpeed
	jmp DSC_check_right

;**************************************************
;
DSC_scr2
	lda #PSD_RIGHT
	sta m_lastPlayerSideDirection
	jsr AddSideAccelToSpeed
	jmp DSC_check_right

;**************************************************
;
DSC_side_control_left
	lda m_lastPlayerSideDirection
	cmp #PSD_LEFT
	bne DSC_scl1
	jsr AddSideAccelToSpeed
	jmp DSC_check_right

;**************************************************
;
DSC_scl1
	cmp #PSD_RIGHT
	bne DSC_scl2
	jsr SubstractSideDeaccelToSpeed
	jmp DSC_check_right

;**************************************************
;
DSC_scl2
	lda #PSD_LEFT
	sta m_lastPlayerSideDirection
	jsr AddSideAccelToSpeed

;**************************************************
;
DSC_check_right
	lda m_lastPlayerSideDirection
	cmp #PSD_RIGHT
	bne DSC_check_left
	jsr AddSideSpeedToPosition
	jmp DSC_exit

;**************************************************
;
DSC_check_left
	cmp #PSD_LEFT
	bne DSC_exit
	jsr SubstractSideSpeedToPosition

;**************************************************
;
DSC_exit
	rts
;
;**************************************************************************************************
; Include Files
;**************************************************************************************************
;
	icl "StateInPlatform.Asm"
	icl "StateJumping.Asm"
	icl "StateFalling.Asm"
	icl "StateClimbing.Asm"
	icl "StateInWater.Asm"
;	
;**************************************************************************************************
;
;**************************************************************************************************
; PlayerMethodGravityTest
;**************************************************************************************************
;
PlayerMethodGravityTest
	jmp PlayerMethodReturn
;
;**************************************************************************************************
; PlayerMethodLose
;**************************************************************************************************
;
PlayerMethodLose
	jmp PlayerMethodReturn
