;
;***************************************************************************************************
;
;	Filename:		StateClimbing.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; PlayerMethodClimbing
;**************************************************************************************************
;
PlayerMethodClimbing

		jsr CheckCreatePlayerMissile

;************************************************
;
PMC_check_up
		
		lda m_stick0
		and #STICK_UP						; check up
		bne PMC_check_down

		lda #CLIMB_UP_SPEED_Y_L1
		sta m_playerSpeedY_L1
		lda #CLIMB_UP_SPEED_Y_H1
		sta m_playerSpeedY_H1

		; update player position in Y
		lda m_playerLevelBottomY_L1
		sec
		sbc m_playerSpeedY_L1
		sta m_playerLevelBottomY_L1
		lda m_playerLevelBottomY_H1
		sbc m_playerSpeedY_H1
		sta m_playerLevelBottomY_H1
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelBottomY_H2

		; search for an empty space at the middle bottom point of the player
		lda #[PLR_WIDTH/2 + 2]
		sta m_bottomPosOffsetX
		lda #0
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomDownPos

		lda m_middleBottomChar
		and #15
		bne PMC_end_move_up

		; snap to the bottom and go to the platform state
		lda m_playerLevelBottomY_H1
		ora #[CHAR_PIX.else_Y-1]
		sta m_playerLevelBottomY_H1

		lda #0
		sta m_playerLevelBottomY_L1

		ldx #PS_OVER_PLATFORM
		jsr SetPlayerMethod

;************************************************
;
PMC_end_move_up
		jmp PMC_exit


;************************************************
;
PMC_check_down

		lda m_stick0
		and #STICK_DOWN					; check down
		bne PMC_exit

		lda #CLIMB_DOWN_SPEED_Y_L1
		sta m_playerSpeedY_L1
		lda #CLIMB_DOWN_SPEED_Y_H1
		sta m_playerSpeedY_H1

		; update player position in Y
		lda m_playerLevelBottomY_L1
		clc
		adc m_playerSpeedY_L1
		sta m_playerLevelBottomY_L1
		lda m_playerLevelBottomY_H1
		adc m_playerSpeedY_H1
		sta m_playerLevelBottomY_H1
		lda m_playerLevelBottomY_H2
		adc #0
		sta m_playerLevelBottomY_H2

		; special check for the top char of a ladder (that is a platform)
		lda #[PLR_WIDTH/2 + 2]
		sta m_bottomPosOffsetX
		lda #CHAR_PIX.else_Y
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomDownPos

		lda m_middleBottomChar
		and #15
		cmp #CT_LADDER
		beq PMC_exit

		; search for a platform at the middle bottom point of the player
		lda #[PLR_WIDTH/2 + 2]
		sta m_bottomPosOffsetX
		lda #0
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomDownPos

		lda m_middleBottomChar
		and #01
		cmp #CT_BLOCK
		bne PMC_exit

		lda m_middleBottomChar
		and #%00010000
		beq PMC_exit

		; snap to the bottom and go to the platform state
		lda m_playerLevelBottomY_H1
		and #%11111000
		sec
		sbc #1
		sta m_playerLevelBottomY_H1
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelBottomY_H2

		lda #0
		sta m_playerLevelBottomY_L1
	
		ldx #PS_OVER_PLATFORM
		jsr SetPlayerMethod

;************************************************
;
PMC_exit

		jsr SetPlayerInfo
		jmp PlayerMethodReturn
