;
;***************************************************************************************************
;
;	Filename:		FW_StateJumping.Asm
;
;	Modified On:	Fri July 13, 2018 08:27 AM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
PlayerMethodJumping

	jsr CheckCollectable

	jsr CheckCreatePlayerMissile


; check input to grab a ladder while jumping
	lda m_stick0
	and #STICK_UP		; check if up is still pressed
	bne PMJ_air_control

	lda m_stick0
	and #[STICK_LEFT|STICK_RIGHT]		; check if left or right are not pressed
	cmp #[STICK_LEFT|STICK_RIGHT]
	bne PMJ_air_control


;----------------------------------------
PMJ_check_ladder
; search for a ladder (middle pixel)
	lda #2
	sta m_bottomPosOffsetX
	lda #0
	sta m_bottomPosOffsetY
	jsr CheckPlayerBottomDownPos

	lda m_middleBottomChar
	and #15
	cmp #CT_LADDER
	bne PMJ_air_control

; snap player to center of the ladder
PMJ_snap_ladder
	lda #0
	sta m_playerLevelLeftX_L1
	sta m_playerLevelLeftX_H2

	lda m_middleBottomCharPosX
	asl
	rol m_playerLevelLeftX_H2	; x2
	asl
	rol m_playerLevelLeftX_H2	; x4 = CHAR_PIXELS_X
	sta m_playerLevelLeftX_H1

; abort jumping state
	lda #0
	sta m_playerHoldJumpCounter	; forget hold jump counter

; start climbing state
	ldx #PS_CLIMBING
	jsr SetPlayerMethod

	jmp PMJ_exit


;----------------------------------------
PMJ_air_control
	jsr DoSideControl


;----------------------------------------
PMJ_update_jumping
	lda m_playerHoldJumpCounter
	beq PMJ_decay_jump_speed

	lda m_stick0
	and #STICK_UP		; check if up is still pressed
	bne PMJ_stick_not_up

	dec m_playerHoldJumpCounter	; update hold jump counter
	jmp PMJ_hold_jump_speed

PMJ_stick_not_up
	lda #0
	sta m_playerHoldJumpCounter	; forget hold jump counter

PMJ_decay_jump_speed
	jsr SubstractGravityAccelToSpeed

PMJ_hold_jump_speed
	jsr SubstractSpeedYToPosition

	jsr SetPlayerInfo

; check if the speed in Y is already 0
	lda m_playerSpeedY_H1
	bne PMJ_exit
	lda m_playerSpeedY_L1
	bne PMJ_exit

; change to the falling state
	ldx #PS_FALLING
	jsr SetPlayerMethod

PMJ_exit
	jmp PlayLevel.PlayerMethodReturn
