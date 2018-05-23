;
;***************************************************************************************************
;
;	Filename:		StateInPlatform.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
PlayerMethodOverPlatform

		jsr CheckCollectable
		jsr CheckCreatePlayerMissile
		jsr DoSideMovement	

;************************************************
;
PMGT_check_up
		
		lda m_stick0
		and #STICK_UP						; check up
		bne PMGT_check_fall

		lda m_oldStick0
		and #STICK_UP						; check old up (looking for "just pressed")
		beq PMGT_check_fall


		lda #0									; check bottom of a stair (left pixel)
		sta m_bottomPosOffsetX
	
		lda #0
		sta m_bottomPosOffsetY
		
		jsr CheckPlayerBottomDownPos

		lda m_middleBottomChar
		and #15
		cmp #CT_LADDER
		beq PMGT_snap_ladder_up

		lda #3									; check bottom of a stair (right pixel)
		sta m_bottomPosOffsetX
		
		lda #0
		sta m_bottomPosOffsetY
		
		jsr CheckPlayerBottomDownPos

		lda m_middleBottomChar
		and #15
		cmp #CT_LADDER
		bne PMGT_check_jump

;************************************************
; snap player to center of the ladder
;
PMGT_snap_ladder_up

		lda #0
		sta m_playerLevelLeftX_L1
		sta m_playerLevelLeftX_H2

		lda m_middleBottomCharPosX
		asl
		rol m_playerLevelLeftX_H2				; x2
		asl
		rol m_playerLevelLeftX_H2				; x4 = CHAR_PIX.else_X
		sta m_playerLevelLeftX_H1

		ldx #PS_CLIMBING						; start climbing state
		jsr SetPlayerMethod

		jmp PMGT_end

;************************************************
; start jumping state
;
PMGT_check_jump

		ldx #PS_JUMPING
		jsr SetPlayerMethod

		lda m_playerSideSpeed_L1				; reduce side speed a little
		sec
		sbc #JUMP_HSPEED_SLOWDOWN
		sta m_playerSideSpeed_L1
		
		lda m_playerSideSpeed_H1
		sbc #0
		bcs PMGT_jump_side_speed
		
		lda #0
		sta m_playerSideSpeed_L1

;************************************************
;
PMGT_jump_side_speed
		
		sta m_playerSideSpeed_H1
		jmp PMGT_end

;************************************************
;
PMGT_check_fall

		jsr CheckHoleBelowPlayer

		lda m_playerOverPlatformFlag
		bne CheckPlatformLeft
	
		ldx #PS_FALLING							; start falling state
		jsr SetPlayerMethod

		lsr m_playerSideSpeed_H1				; divide by 2 the side speed, if there was any movement previous to falling
		ror m_playerSideSpeed_L1

		jmp PMGT_end

;*****	Check Platform Left
;
CheckPlatformLeft
		
		lda m_leftBottomChar					; float Platform check
		and #%00000111
		cmp #CT_FLOATPLATFORMH
		bne CheckPlatformRight
		
		jmp ClampPlayer

;*****	Check Platform Right		
CheckPlatformRight		
		
		lda m_rightBottomChar
		and #%00000111
		cmp #CT_FLOATPLATFORMH
		bne PMGT_check_down	

		jmp ClampPlayer
		
;*****	Check down
;						
PMGT_check_down		
		lda m_stick0
		and #STICK_DOWN	
		beq SearchLadder
		
		jmp PMGT_end

SearchLadder
		lda #0									; search for a ladder one char below (left pixel)
		sta m_bottomPosOffsetX
		lda #[CHAR_PIX.else_Y+1]
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomDownPos

		lda m_middleBottomChar
		and #15
		cmp #CT_LADDER
		beq PMGT_snap_ladder_down

		lda #3									; search for a ladder one char below (right pixel)
		sta m_bottomPosOffsetX
		lda #[CHAR_PIX.else_Y+1]
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomDownPos

		lda m_middleBottomChar
		and #15
		cmp #CT_LADDER
		bne PMGT_end

;************************************************
; snap player to center of the ladder
;
PMGT_snap_ladder_down
	
		lda #0
		sta m_playerLevelLeftX_L1
		sta m_playerLevelLeftX_H2

		lda m_middleBottomCharPosX
		asl
		rol m_playerLevelLeftX_H2				; x2
		asl
		rol m_playerLevelLeftX_H2				; x4 = CHAR_PIX.else_X
		sta m_playerLevelLeftX_H1

		lda #0									; put player one line below
		sta m_playerLevelBottomY_L1
		
		lda m_playerLevelBottomY_H1
		clc
		adc #1
		sta m_playerLevelBottomY_H1
	
		lda m_playerLevelBottomY_H2
		adc #0
		sta m_playerLevelBottomY_H2

		ldx #PS_CLIMBING						; start climbing state
		jsr SetPlayerMethod
		
		jmp PMGT_end
		
;***** Clamp Player to platform
ClampPlayer

		lda m_stick0
		cmp #$0F
		bne PMGT_end
		 
		ldx m_floatPlatformIdx
		dex
		
		lda PlatformTime,x
		cmp #FLOAT_PLATFORM_TIMER
		bne PMGT_end
		
		lda PlatformDirX,x
		cmp #00
		bne ClampLeft
		
		clc		
		
		lda m_playerLevelLeftX_H1	
		adc #$04
		sta m_playerLevelLeftX_H1
		lda m_playerLevelLeftX_H2
		adc #00
		sta m_playerLevelLeftX_H2		

		jmp PMGT_end 
		
ClampLeft		
		sec
		lda m_playerLevelLeftX_H1
		sbc #$04
		sta m_playerLevelLeftX_H1
		lda m_playerLevelLeftX_H2
		sbc #00
		sta m_playerLevelLeftX_H2		
		
;************************************************
;
PMGT_end
		
		jsr SetPlayerInfo
		jmp PlayerMethodReturn
