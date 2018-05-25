;
;***************************************************************************************************
;
;	Filename:		StateInWater.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;***************************************************************************************************
;	PlayerMethodInWater
;***************************************************************************************************
;
PlayerMethodInWater

		jsr CheckCollectable					; add collectables in water for this	
		jsr CheckCreatePlayerMissile

		; search for water (top center pixel)		 
		lda #2
		sta m_bottomPosOffsetX
		lda #7
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomUpPos

		lda m_middleBottomChar
		and #15
		cmp #CT_WATER
		beq PMIW_check_water_moves

		; check jump input to go out of the water
		lda m_stick0
		and #STICK_UP							; check up
		bne PMIW_check_water_moves

		lda m_playerNoJumpTimer
		bne PMIW_check_water_moves
	
		; start jumping state
		ldx #PS_JUMPING
		jsr SetPlayerMethod

		jmp PMIW_exit

PMIW_check_water_moves

		lda m_playerOnWaterSurfaceFlag
		beq PMIW_check_move_up
		jmp PMIW_on_surface

;*****	check vertical movement
; 
PMIW_check_move_up
	
		lda m_stick0
		and #STICK_UP							; check up
		bne PMIW_check_move_down

		lda m_waterPlayerDirectionFlag
		bne PMIW_move_up_down

PMIW_move_up_up
	
		jsr AddWaterMoveUpAccelToSpeed
		jmp PMIW_going_up_speed

PMIW_move_up_down
	
		jmp PMIW_going_down

PMIW_check_move_down

		lda m_stick0
		and #STICK_DOWN							; check down
		bne PMIW_under_surface

		lda m_waterPlayerDirectionFlag
		bne PMIW_move_down_down

PMIW_move_down_up
	
		jsr SubstractWaterAccelToSpeed
		jsr SubstractSpeedYToPosition

		lda m_playerSpeedY_H1
		ora m_playerSpeedY_L1
		bne PMIW_check_move_exit

		lda #1
		sta m_waterPlayerDirectionFlag

		jmp PMIW_check_side_moves

PMIW_move_down_down
		
		jsr AddWaterMoveDownAccelToSpeed
		jsr AddSpeedYToPosition

		lda m_playerOverPlatformFlag
		beq PMIW_check_move_exit

		; reset speed in Y after a bottom collision
		lda #0
		sta m_playerSpeedY_H1
		sta m_playerSpeedY_L1

PMIW_check_move_exit
	
		jmp PMIW_check_side_moves

PMIW_under_surface

		lda m_waterPlayerDirectionFlag
		bne PMIW_going_down

PMIW_going_up
		
		jsr AddWaterAccelToSpeed

PMIW_going_up_speed
		
		jsr SubstractSpeedYToPosition

;*****	check if we are emerging from water (middle height, center pixel)
;
PMIW_emerging
	
		lda #2
		sta m_bottomPosOffsetX
		lda #3
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomUpPos

		lda m_middleBottomChar
		and #15
		bne PMIW_check_side_moves

		lda #1
		sta m_playerOnWaterSurfaceFlag

		jmp PMIW_check_side_moves

PMIW_going_down

		jsr SubstractWaterAccelToSpeed

PMIW_going_down_speed
	
		jsr AddSpeedYToPosition

PMIW_check_down_speed
	
		lda m_playerSpeedY_H1
		ora m_playerSpeedY_L1
		bne PMIW_check_side_moves

PMIW_change_dir_to_up
		
		lda #0
		sta m_waterPlayerDirectionFlag

		jmp PMIW_check_side_moves

PMIW_on_surface

		; check water "buoyancy"
		lda m_waterPlayerDirectionFlag
		bne PMIW_going_down_surface

PMIW_going_up_surface

		jsr SubstractWaterAccelToSpeed
		jsr SubstractSpeedYToPosition

		lda m_playerSpeedY_H1
		ora m_playerSpeedY_L1
		bne PMIW_check_side_moves

		lda #1
		sta m_waterPlayerDirectionFlag

		jmp PMIW_check_side_moves

PMIW_going_down_surface

		jsr AddWaterAccelToSpeed
		jsr AddSpeedYToPosition

		; search for water (top center pixel)
		lda #2
		sta m_bottomPosOffsetX
		lda #7
		sta m_bottomPosOffsetY
		jsr CheckPlayerBottomUpPos

		lda m_middleBottomChar
		and #15
		cmp #CT_WATER
		bne PMIW_check_side_moves

		lda #0
		sta m_playerOnWaterSurfaceFlag

PMIW_check_side_moves

		jsr DoSideMovement

PMIW_update_pos
		
		jsr SetPlayerInfo

PMIW_exit
		
		jmp PlayLevel.PlayerMethodReturn
