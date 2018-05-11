;
;***************************************************************************************************
;
;	Filename:		CameraLogic.Asm
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
TabOffsetForHSCROL			.byte 12,11,10,9
TabOffsetForVSCROL			.byte 0,1,2,3,4,5,6,7

TabMultiply82_LSB			
	:26 .byte <[#*LEVEL_CHAR_SIZE_X]

TabMultiply82_MSB
	:26 .byte >[#*LEVEL_CHAR_SIZE_X]
;
;**************************************************************************************************
; UpdateCameraWindow
;
; 	update target window pos (m_windowTargetPos*_*), using the player level position,
; 	correct (clamp) target window pos with level limits if necessary
;
;**************************************************************************************************
;
.proc UpdateCameraWindow

;************************************************
;
UCW_check_left_limit
	
		; check left limit (clamp to the left)
		lda m_playerLevelLeftX_H2				
		cmp #>[[[WINDOW_CHAR_SIZE_X*CHAR_PIX.else_X]/2+CHAR_PIX.else_X]-2]						; [[[40 * 4] / 2 + 4] - 2]
		bcc UCW_force_left_limit
		bne UCW_check_right_limit
		
		lda m_playerLevelLeftX_H1
		cmp #<[[[WINDOW_CHAR_SIZE_X*CHAR_PIX.else_X]/2+CHAR_PIX.else_X]-2]						; [[[40 * 4] / 2 + 4] - 2]
		bcs UCW_check_right_limit

;************************************************
;
UCW_force_left_limit
		
		lda #>[CHAR_PIX.else_X]
		sta m_windowTargetPosX_H2
		
		lda #<[CHAR_PIX.else_X]
		sta m_windowTargetPosX_H1
		
		jmp UCW_check_top_limit

;************************************************
;
UCW_check_right_limit
	
		; check right limit (clamp to the right)
		lda #>[[[LEVEL_CHAR_SIZE_X-WINDOW_CHAR_SIZE_X/2]*CHAR_PIX.else_X-CHAR_PIX.else_X]+1]	; [[[82-40 / 2] * 4 - 4] + 1]
																							; [[[ 62 ] * 4 - 4] + 1]
																							; [ 244 + 1] = 245	
		cmp m_playerLevelRightX_H2	
		bcc UCW_force_right_limit
		bne UCW_set_target_x
		
		lda #<[[[LEVEL_CHAR_SIZE_X-WINDOW_CHAR_SIZE_X/2]*CHAR_PIX.else_X-CHAR_PIX.else_X]+1]	; [[[82-40 / 2] * 4 - 4] + 1]
																							; [[[ 62 ] * 4 - 4] + 1]
																							; [ 244 + 1] = 245	
		cmp m_playerLevelRightX_H1
		bcs UCW_set_target_x

;************************************************
;
UCW_force_right_limit
	
		lda #>[[LEVEL_CHAR_SIZE_X-WINDOW_CHAR_SIZE_X]*CHAR_PIX.else_X-CHAR_PIX.else_X]
		sta m_windowTargetPosX_H2
	
		lda #<[[LEVEL_CHAR_SIZE_X-WINDOW_CHAR_SIZE_X]*CHAR_PIX.else_X-CHAR_PIX.else_X]
		sta m_windowTargetPosX_H1
	
		jmp UCW_check_top_limit

;************************************************
; no clamp, use current player X position 
; and substract half the window size
;
UCW_set_target_x
	
		lda m_playerLevelLeftX_H1
		sec
		sbc #<[[[WINDOW_CHAR_SIZE_X*CHAR_PIX.else_X]/2]-2]
		sta m_windowTargetPosX_H1
	
		lda m_playerLevelLeftX_H2
		sbc #>[[[WINDOW_CHAR_SIZE_X*CHAR_PIX.else_X]/2]-2]
		sta m_windowTargetPosX_H2

;************************************************
; check top limit (clamp to the top)
; 
UCW_check_top_limit
		
		lda m_playerLevelTopY_H2
		cmp #>[[WINDOW_CHAR_SIZE_Y*CHAR_PIX.else_Y/2]-4]
		bcc UCW_force_top_limit
		bne UCW_check_bottom_limit
		
		lda m_playerLevelTopY_H1
		cmp #<[[WINDOW_CHAR_SIZE_Y*CHAR_PIX.else_Y/2]-4]
		bcs UCW_check_bottom_limit

;************************************************
;
UCW_force_top_limit
		
		lda #>[0]
		sta m_windowTargetPosY_H2
	
		lda #<[0]
		sta m_windowTargetPosY_H1
	
		jmp UCW_get_deltas

;************************************************
; check bottom limit (clamp to the bottom)
;
UCW_check_bottom_limit
		
		lda #>[[[LEVEL_CHAR_SIZE_Y-WINDOW_CHAR_SIZE_Y/2]*CHAR_PIX.else_Y]+3]
		cmp m_playerLevelBottomY_H2
		bcc UCW_force_bottom_limit
		bne UCW_set_target_y
		
		lda #<[[[LEVEL_CHAR_SIZE_Y-WINDOW_CHAR_SIZE_Y/2]*CHAR_PIX.else_Y]+3]
		cmp m_playerLevelBottomY_H1
		bcs UCW_set_target_y

;************************************************
;
UCW_force_bottom_limit
	
		lda #>[[LEVEL_CHAR_SIZE_Y-WINDOW_CHAR_SIZE_Y]*CHAR_PIX.else_Y]
		sta m_windowTargetPosY_H2
	
		lda #<[[LEVEL_CHAR_SIZE_Y-WINDOW_CHAR_SIZE_Y]*CHAR_PIX.else_Y]
		sta m_windowTargetPosY_H1
		
		jmp UCW_get_deltas

;************************************************
; no clamp, use current player Y position and substract half the window size
;
UCW_set_target_y
	
		lda m_playerLevelTopY_H1
		sec		
		sbc #<[[WINDOW_CHAR_SIZE_Y*CHAR_PIX.else_Y/2]-4]
		sta m_windowTargetPosY_H1
	
		lda m_playerLevelTopY_H2
		sbc #>[[WINDOW_CHAR_SIZE_Y*CHAR_PIX.else_Y/2]-4]
		sta m_windowTargetPosY_H2

;************************************************
; calculate deltas in X and Y for the current and
; the target window pos, update the current window
; pos according to the distance to the target
; (compare the level window with the target pos, 
; get the delta and divide it by 8, so the movement 
; speed is proportional to the distance, with a minimum step of 1)
;
UCW_get_deltas

;************************************************
;
UCW_check_deltaX								
		
		lda m_levelWindowX_H2					; compare target X and current X
		cmp m_windowTargetPosX_H2
		bcc UCW_deltaX_positive
		bne UCW_deltaX_negative
	
		lda m_levelWindowX_H1
		cmp m_windowTargetPosX_H1
								
		bcc UCW_deltaX_positive					; target X equal to current X
		bne UCW_deltaX_negative
		jmp UCW_deltaX_exit						; target X equal to current X

;************************************************
;
UCW_deltaX_negative								
		lda m_levelWindowX_H1 					; target X lower than current X
		sec
		sbc m_windowTargetPosX_H1
		sta m_windowTargetDeltaX_H1
	
		lda m_levelWindowX_H2
		sbc m_windowTargetPosX_H2
		sta m_windowTargetDeltaX_H2

;************************************************
;
UCW_dxn_divide

		lda m_windowTargetDeltaX_H2
		lsr
		ror m_windowTargetDeltaX_H1				; /2
		lsr
		ror m_windowTargetDeltaX_H1				; /4
		lsr
		ror m_windowTargetDeltaX_H1				; /8
		sta m_windowTargetDeltaX_H2

		ora m_windowTargetDeltaX_H1				; check that delta X is greater than zero
		bne UCW_apply_negative_deltaX
		
		lda #MINIMUM_CAMERA_STEP
		sta m_windowTargetDeltaX_H1
	
;************************************************
;
UCW_apply_negative_deltaX
	
		lda m_levelWindowX_H1
		sec
		sbc m_windowTargetDeltaX_H1
		sta m_levelWindowX_H1
		lda m_levelWindowX_H2
		sbc m_windowTargetDeltaX_H2
		sta m_levelWindowX_H2

;************************************************
;
UCW_deltaX_exit_jmp
	
		jmp UCW_deltaX_exit

;************************************************
;
UCW_deltaX_positive								
		
		lda m_windowTargetPosX_H1				; target X greater than current X
		sec
		sbc m_levelWindowX_H1
		sta m_windowTargetDeltaX_H1
	
		lda m_windowTargetPosX_H2
		sbc m_levelWindowX_H2
		sta m_windowTargetDeltaX_H2

;************************************************
;
UCW_dxp_divide
		
		lda m_windowTargetDeltaX_H2
		lsr
		ror m_windowTargetDeltaX_H1				; /2
		lsr
		ror m_windowTargetDeltaX_H1				; /4
		lsr
		ror m_windowTargetDeltaX_H1				; /8
		sta m_windowTargetDeltaX_H2

		ora m_windowTargetDeltaX_H1				; check that delta X is greater than zero
		bne UCW_apply_positive_deltaX
		
		lda #MINIMUM_CAMERA_STEP
		sta m_windowTargetDeltaX_H1

;************************************************
;
UCW_apply_positive_deltaX
		
		lda m_levelWindowX_H1
		clc
		adc m_windowTargetDeltaX_H1
		sta m_levelWindowX_H1
		
		lda m_levelWindowX_H2
		adc m_windowTargetDeltaX_H2
		sta m_levelWindowX_H2

;************************************************
;
UCW_deltaX_exit

;************************************************
;
UCW_check_deltaY								
		
		lda m_levelWindowY_H2					; compare target Y and current Y	
		cmp m_windowTargetPosY_H2
		bcc UCW_deltaY_positive
		bne UCW_deltaY_negative
	
		lda m_levelWindowY_H1
		cmp m_windowTargetPosY_H1
		beq UCW_deltaY_exit						; target Y equal to current Y
		bcc UCW_deltaY_positive

;************************************************
;
UCW_deltaY_negative								
		
		lda m_levelWindowY_H1					; target Y lower than current Y
		sec
		sbc m_windowTargetPosY_H1
		sta m_windowTargetDeltaY_H1
		
		lda m_levelWindowY_H2
		sbc m_windowTargetPosY_H2

		lsr
		ror m_windowTargetDeltaY_H1				; /2
		lsr
		ror m_windowTargetDeltaY_H1				; /4
		lsr
		ror m_windowTargetDeltaY_H1				; /8
		sta m_windowTargetDeltaY_H2

		ora m_windowTargetDeltaY_H1				; check that delta Y is greater than zero
		bne UCW_apply_negative_deltaY
		
		lda #MINIMUM_CAMERA_STEP
		sta m_windowTargetDeltaY_H1
;
;**************************************************************************************************
;
UCW_apply_negative_deltaY
		
		lda m_levelWindowY_H1
		sec
		sbc m_windowTargetDeltaY_H1
		sta m_levelWindowY_H1
		
		lda m_levelWindowY_H2
		sbc m_windowTargetDeltaY_H2
		sta m_levelWindowY_H2

		jmp UCW_deltaY_exit
;
;**************************************************************************************************
;
UCW_deltaY_positive								
		
		lda m_windowTargetPosY_H1				; target Y greater than current Y
		sec
		sbc m_levelWindowY_H1
		sta m_windowTargetDeltaY_H1
		
		lda m_windowTargetPosY_H2
		sbc m_levelWindowY_H2

		lsr
		ror m_windowTargetDeltaY_H1				; /2
		lsr
		ror m_windowTargetDeltaY_H1				; /4
		lsr
		ror m_windowTargetDeltaY_H1				; /8
		sta m_windowTargetDeltaY_H2

		ora m_windowTargetDeltaY_H1				; check that delta Y is greater than zero
		bne UCW_apply_positive_deltaY
		
		lda #MINIMUM_CAMERA_STEP
		sta m_windowTargetDeltaY_H1

;************************************************
;
UCW_apply_positive_deltaY
		
		lda m_levelWindowY_H1
		clc
		adc m_windowTargetDeltaY_H1
		sta m_levelWindowY_H1
		
		lda m_levelWindowY_H2
		adc m_windowTargetDeltaY_H2
		sta m_levelWindowY_H2

;************************************************
;
UCW_deltaY_exit

;************************************************
; update all LMS in the display list
;
UCW_update_LMS
		
		lda m_levelWindowX_H2
		sta m_screenBaseAddress1+1
		
		lda m_levelWindowX_H1
		lsr m_screenBaseAddress1+1
		ror										; /2
		lsr m_screenBaseAddress1+1
		ror										; /4 == CHAR_PIX.else_X

		clc
		adc #<[GAME_MEM-1]
		sta m_screenBaseAddress2
		
		lda m_screenBaseAddress1+1
		adc #>[GAME_MEM-1]
		sta m_screenBaseAddress2+1


		lda m_levelWindowY_H2
		sta m_screenBaseAddress1+1
		lda m_levelWindowY_H1

		lsr m_screenBaseAddress1+1
		ror										; /2
		lsr m_screenBaseAddress1+1
		ror										; /4
		lsr m_screenBaseAddress1+1
		ror										; /8 == CHAR_PIX.else_Y

		tax
		lda TabMultiply82_LSB,x
		clc
		adc m_screenBaseAddress2
		sta m_screenBaseAddress2
	
		lda TabMultiply82_MSB,x
		adc m_screenBaseAddress2+1
		sta m_screenBaseAddress2+1

		ldx #0

;************************************************
;
UCW_update_LMS_loop

		lda m_screenBaseAddress2
		sta GAME_LMS1+1,x						; should update this outside the screen zone!
		
		lda m_screenBaseAddress2+1
		sta GAME_LMS1+2,x						; should update this outside the screen zone!

		lda m_screenBaseAddress2
		clc
		adc #LEVEL_CHAR_SIZE_X
		sta m_screenBaseAddress2
		
		lda m_screenBaseAddress2+1
		adc #0
		sta m_screenBaseAddress2+1

		inx
		inx
		inx
		cpx #[[WINDOW_CHAR_SIZE_Y+1]*3]
		bne UCW_update_LMS_loop

;************************************************
; update HSCROL and VSCROL with the offsets of the window pos
;
		lda m_levelWindowX_H1
		and #[CHAR_PIX.else_X-1]
		tax
		
		lda TabOffsetForHSCROL,x
		sta HSCROL								; should update this outside the screen zone!

		lda m_levelWindowY_H1
		and #[CHAR_PIX.else_Y-1]
		tax
	
		lda TabOffsetForVSCROL,x
		sta VSCROL								; should update this outside the screen zone!
		
		rts
	
.endp	