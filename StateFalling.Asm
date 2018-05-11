;
;***************************************************************************************************
;
;	Filename:		StateFalling.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
PlayerMethodFalling

	jsr CheckCollectable

	jsr CheckCreatePlayerMissile


; check input to grab a ladder while falling
	lda m_stick0
	and #STICK_UP		; check if up is still pressed
	bne PMF_check_restart_jump

	lda m_stick0
	and #[STICK_LEFT|STICK_RIGHT]		; check if left or right are not pressed
	cmp #[STICK_LEFT|STICK_RIGHT]
	bne PMF_check_restart_jump


;----------------------------------------
PMF_check_ladder
; search for a ladder (bottom middle pixel)
	lda #2
	sta m_bottomPosOffsetX
	lda #0
	sta m_bottomPosOffsetY
	jsr CheckPlayerBottomDownPos

	lda m_middleBottomChar
	and #15
	cmp #CT_LADDER
	bne PMF_check_restart_jump

; snap player to center of the ladder
PMF_snap_ladder
	lda #0
	sta m_playerLevelLeftX_L1
	sta m_playerLevelLeftX_H2

	lda m_middleBottomCharPosX
	asl
	rol m_playerLevelLeftX_H2	; x2
	asl
	rol m_playerLevelLeftX_H2	; x4 = CHAR_PIX.else_X
	sta m_playerLevelLeftX_H1

; start climbing state
	ldx #PS_CLIMBING
	jsr SetPlayerMethod

	jmp PMF_exit


;----------------------------------------
PMF_check_restart_jump
;
;	; uncomment this to allow infinite jumping
; 	lda m_stick0
; 	and #STICK_UP	; check up
; 	bne PMF_check_in_water
; 
; 	lda m_oldStick0
; 	and #STICK_UP	; check old up (looking for "just pressed")
; 	beq PMF_check_in_water
; 
;	; start jumping state
; 	ldx #PS_JUMPING
; 	jsr SetPlayerMethod
; 
; 	jmp PMF_exit


;----------------------------------------
PMF_check_in_water
; search for water (center pixel)
	lda #2
	sta m_bottomPosOffsetX
	lda #2
	sta m_bottomPosOffsetY
	jsr CheckPlayerBottomUpPos

	lda m_middleBottomChar
	and #15
	cmp #CT_WATER
	bne PMF_air_control

; start in water state
	ldx #PS_IN_WATER
	jsr SetPlayerMethod

	jmp PMF_exit


;----------------------------------------
PMF_air_control
	jsr DoSideControl


;----------------------------------------
PMF_update_falling
	jsr AddGravityAccelToSpeed

	jsr AddSpeedYToPosition

	jsr SetPlayerInfo

	lda m_playerOverPlatformFlag
	beq PMF_exit


; change to the over platform state
	ldx #PS_OVER_PLATFORM
	jsr SetPlayerMethod


PMF_exit
	jmp PlayerMethodReturn
