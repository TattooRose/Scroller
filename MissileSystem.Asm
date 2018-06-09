;
;***************************************************************************************************
;
;	Filename:		MissileSystem.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; Missle Storage
;**************************************************************************************************
;
CLEAR_MASK_M0 				= %11111100
CLEAR_MASK_M1 				= %11110011
CLEAR_MASK_M2 				= %11001111
CLEAR_MASK_M3 				= %00111111

SET_MASK_M0 				= %00000011
SET_MASK_M1 				= %00001100
SET_MASK_M2 				= %00110000
SET_MASK_M3 				= %11000000

SET_MASK_M0_R_L1 			= %00000010
SET_MASK_M0_R_L2 			= %00000001
SET_MASK_M0_R_L3 			= %00000010

SET_MASK_M0_L_L1 			= %00000001
SET_MASK_M0_L_L2 			= %00000010
SET_MASK_M0_L_L3 			= %00000001

SET_MASK_M1_R_L1 			= %00001000
SET_MASK_M1_R_L2 			= %00000100
SET_MASK_M1_R_L3 			= %00001000

SET_MASK_M1_L_L1 			= %00000100
SET_MASK_M1_L_L2 			= %00001000
SET_MASK_M1_L_L3 			= %00000100

SET_MASK_M2_R_L1 			= %00100000
SET_MASK_M2_R_L2 			= %00010000
SET_MASK_M2_R_L3 			= %00100000

SET_MASK_M2_L_L1 			= %00010000
SET_MASK_M2_L_L2 			= %00100000
SET_MASK_M2_L_L3 			= %00010000

SET_MASK_M3_R_L1 			= %10000000
SET_MASK_M3_R_L2 			= %01000000
SET_MASK_M3_R_L3 			= %10000000

SET_MASK_M3_L_L1 			= %01000000
SET_MASK_M3_L_L2 			= %10000000
SET_MASK_M3_L_L3 			= %01000000

; virtual missiles tables
MAX_VIRTUAL_MISSILES = 4

TabClearMissileMask			.byte CLEAR_MASK_M0, CLEAR_MASK_M1, CLEAR_MASK_M2, CLEAR_MASK_M3

TabSetMissileToRightMaskL1	.byte SET_MASK_M0_R_L1, SET_MASK_M1_R_L1, SET_MASK_M2_R_L1, SET_MASK_M3_R_L1

TabSetMissileToRightMaskL2	.byte SET_MASK_M0_R_L2, SET_MASK_M1_R_L2, SET_MASK_M2_R_L2, SET_MASK_M3_R_L2

TabSetMissileToRightMaskL3	.byte SET_MASK_M0_R_L3, SET_MASK_M1_R_L3, SET_MASK_M2_R_L3, SET_MASK_M3_R_L3

TabSetMissileToLeftMaskL1	.byte SET_MASK_M0_L_L1, SET_MASK_M1_L_L1, SET_MASK_M2_L_L1, SET_MASK_M3_L_L1

TabSetMissileToLeftMaskL2	.byte SET_MASK_M0_L_L2, SET_MASK_M1_L_L2, SET_MASK_M2_L_L2, SET_MASK_M3_L_L2

TabSetMissileToLeftMaskL3	.byte SET_MASK_M0_L_L3, SET_MASK_M1_L_L3, SET_MASK_M2_L_L3, SET_MASK_M3_L_L3

TabDrawMissileMethodLSB		.byte <DrawMissileM0, <DrawMissileM1, <DrawMissileM2, <DrawMissileM3

TabDrawMissileMethodMSB		.byte >DrawMissileM0, >DrawMissileM1, >DrawMissileM2, >DrawMissileM3

m_currentVirtualMissiles 	.byte 0

TabMissileScreenLeftX		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileScreenTopY		:MAX_VIRTUAL_MISSILES .byte 0

TabOldMissileScreenLeftX	:MAX_VIRTUAL_MISSILES .byte 0

TabOldMissileScreenTopY		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileLevelLeftX_H2		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileLevelLeftX_H1		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileLevelLeftX_L1		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileLevelTopY_H2		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileLevelTopY_H1		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileLevelTopY_L1		:MAX_VIRTUAL_MISSILES .byte 0

TabMissileSpeedX_H1			:MAX_VIRTUAL_MISSILES .byte 0

TabMissileSpeedX_L1			:MAX_VIRTUAL_MISSILES .byte 0

TabMissileDirection			:MAX_VIRTUAL_MISSILES .byte 0

TabMissileFrameCounter_H2	:MAX_VIRTUAL_MISSILES .byte 0

TabMissileFrameCounter_H1	:MAX_VIRTUAL_MISSILES .byte 0

TabMissileOwner				:MAX_VIRTUAL_MISSILES .byte 0

;
;**************************************************************************************************
;	CheckCreatePlayerMissile	
;**************************************************************************************************
;
.proc CheckCreatePlayerMissile

		lda m_triggerState
		cmp #2									; check just pressed
		bne CCPM_exit

		jsr GetFreeMissileIndex
		cpx #2									; only use index 0 and 1 for the player missiles
		bcs CCPM_exit
	
		lda #>[PLAYER_MISSILE_SPEED_X]
		sta TabMissileSpeedX_H1,x
		lda #<[PLAYER_MISSILE_SPEED_X]
		sta TabMissileSpeedX_L1,x

		lda m_lastPlayerShootDirection
		cmp #PSD_RIGHT
		beq CCPM_shoot_right

CCPM_shoot_left

		lda #2
		sta TabMissileDirection,x

		jmp CCPM_init_position

CCPM_shoot_right
	
		lda #1
		sta TabMissileDirection,x

CCPM_init_position
	
		lda m_playerLevelLeftX_H1
		sta TabMissileLevelLeftX_H1,x
	
		lda m_playerLevelLeftX_H2
		sta TabMissileLevelLeftX_H2,x

		lda m_playerLevelTopY_H1
		clc
		adc #[PLR_HEIGHT/2]
		sta TabMissileLevelTopY_H1,x
	
		lda m_playerLevelTopY_H2
		adc #0
		sta TabMissileLevelTopY_H2,x

		lda #0
		sta TabMissileLevelLeftX_L1,x
		sta TabMissileLevelTopY_L1,x

		lda #1									; player owner
		sta TabMissileOwner,x

		; before this, call GetFreeMissileIndex and then init..
		jsr CreateMissile
		
		lda #SFX_FIRE
		and #$0f
		sta m_sfxEffect 

CCPM_exit
		
		rts

.endp

;
;**************************************************************************************************
;	CheckCreateEnemyMissile	
;**************************************************************************************************
;
.proc CheckCreateEnemyMissile

		; check for a free missile index
		ldx #2
		lda TabMissileOwner,x
		beq CCEM_found_one_free
	
		ldx #3
		lda TabMissileOwner,x
		bne CCEM_exit
	
CCEM_found_one_free
		
		lda #>[ENEMY_MISSILE_SPEED_X]
		sta TabMissileSpeedX_H1,x
		
		lda #<[ENEMY_MISSILE_SPEED_X]
		sta TabMissileSpeedX_L1,x
	
		lda m_enemyShootDirection
		sta TabMissileDirection,x

		; init position
		lda m_enemyShotLevelLeftX_H1
		sta TabMissileLevelLeftX_H1,x
		
		lda m_enemyShotLevelLeftX_H2
		sta TabMissileLevelLeftX_H2,x

		lda m_enemyShotLevelTopY_H1
		sta TabMissileLevelTopY_H1,x
	
		lda m_enemyShotLevelTopY_H2
		sta TabMissileLevelTopY_H2,x

		lda #0
		sta TabMissileLevelLeftX_L1,x
		sta TabMissileLevelTopY_L1,x

		lda #2									; enemy owner
		sta TabMissileOwner,x

		jsr CreateMissile

CCEM_exit

		rts
	
.endp

;
;**************************************************************************************************
;	GetFreeMissileIndex	
;**************************************************************************************************
;
.proc GetFreeMissileIndex

		; return in X the index of the free virtual missile
		ldx #0

GFMI_loop
		lda TabMissileOwner,x	; if the owner is 0, the slot is free
		beq GFMI_exit

		inx
		cpx #MAX_VIRTUAL_MISSILES
		bne GFMI_loop

		ldx #255		; value for: "there is no free index"

GFMI_exit
		
		rts

.endp

;
;**************************************************************************************************
;	CreateMissile	
;
; 		before this, call GetFreeMissileIndex and then init:
; 		TabMissileLevelLeftX_H2/H1/L1, TabMissileLevelTopY_H2/H1/L1,
; 		TabMissileSpeedX_H1/L1 (negative if going to the left)
; 		and TabMissileOwner (different than 0)
;
;**************************************************************************************************
;
.proc CreateMissile

		; use X as a parameter (the index of the virtual missile)
		lda #0
		sta TabMissileFrameCounter_H2,x
		sta TabMissileFrameCounter_H1,x

		jsr SetMissileScreenPos

		; maybe should check screen position before creating the missile
		jsr DrawMissileMX
		inc m_currentVirtualMissiles

		rts
		
.endp

;
;**************************************************************************************************
;	UpdateMissileSystem
;
; 		should call this every frame, before calling CreateMissile in that frame (?)
;
;**************************************************************************************************
;	
.proc UpdateMissileSystem

		ldx #0

UMS_loop
		lda TabMissileOwner,x	; if the owner is 0, the slot is free
		bne UMS_update
		jmp UMS_next

;*****	update frame counter (life time)
;
UMS_update
		
		inc TabMissileFrameCounter_H1,x
		bne UMS_check_collision
		inc TabMissileFrameCounter_H2,x

;*****	check if we need to destroy the missile by a hardware collision
;
UMS_check_collision

		jsr GetPlayerMissileFrontChar

		lda TabMissileOwner,x
		cmp #1
		beq UMS_player_owner

;******	the collision check is a lot simpler for enemies
;
UMS_enemy_owner			

		lda m_charDef
		and #15
		cmp #CT_BLOCK
		bne UMS_update_position
		jmp UMS_destroy
	
UMS_player_owner
	
		lda m_charDef
		and #15

UMS_check_block
		
		cmp #CT_BLOCK
		bne UMS_check_danger
		
		lda #4									; gray color
		jmp TEST_B1

UMS_check_danger
		
		cmp #CT_DANGER
		bne UMS_update_position

;*****	check for a disabed vertical laser
;
UMS_check_vlaser
		
		lda m_charRaw
		cmp #[128+16]							; danger plus vertical laser char index
		bne UMS_check_enemy1_left
	
		lda m_animVLaserCurrentFrame
		cmp #VLASER_DISABLED_INDEX				; disabled state index
		beq UMS_update_position
		jmp UMS_danger

UMS_check_enemy1_left

		cmp #[128+64]							; danger plus enemy 1 left char index
		bne UMS_check_enemy1_right
	
		lda m_charPositionX
		sta m_enemyCharPosX
		lda m_charPositionY
		sta m_enemyCharPosY
	
		jsr HitEnemy	
		jmp UMS_danger
	
UMS_check_enemy1_right
	
		cmp #[128+65]							; danger plus enemy 1 right char index
		bne UMS_danger
	
		lda m_charPositionX
		sta m_enemyCharPosX
		dec m_enemyCharPosX
		lda m_charPositionY
		sta m_enemyCharPosY
	
		jsr HitEnemy
				
UMS_danger
TEST_B1	
		jmp UMS_destroy

;*****	update position using the missile speed
UMS_update_position
	
		lda TabMissileDirection,x
		cmp #1
		bne UMS_move_left

UMS_move_right
		
		lda TabMissileLevelLeftX_L1,x
		clc
		adc TabMissileSpeedX_L1,x
		sta TabMissileLevelLeftX_L1,x

		lda TabMissileLevelLeftX_H1,x
		adc TabMissileSpeedX_H1,x
		sta TabMissileLevelLeftX_H1,x

		lda TabMissileLevelLeftX_H2,x
		adc #0
		sta TabMissileLevelLeftX_H2,x

		jsr SetMissileScreenPos
		jmp UMS_check_screen_limits

UMS_move_left

		lda TabMissileLevelLeftX_L1,x
		sec
		sbc TabMissileSpeedX_L1,x
		sta TabMissileLevelLeftX_L1,x

		lda TabMissileLevelLeftX_H1,x
		sbc TabMissileSpeedX_H1,x
		sta TabMissileLevelLeftX_H1,x

		lda TabMissileLevelLeftX_H2,x
		sbc #0
		sta TabMissileLevelLeftX_H2,x

		jsr SetMissileScreenPos

;*****	check outside screen position, to destroy the missile
;
UMS_check_screen_limits

		lda TabMissileScreenLeftX,x
		cmp #[PM_BASE_SCREEN_X]					; screen left limit
		bcc UMS_destroy
		cmp #[PM_BASE_SCREEN_X+160-3]			; screen right limit (minus width of the missile)
		bcs UMS_destroy

		lda TabMissileScreenTopY,x
		cmp #[PM_BASE_SCREEN_Y]					; screen top limit
		bcc UMS_destroy
		cmp #[PM_BASE_SCREEN_Y+192-2]			; screen bottom limit (minus height of the missile)
	
		bcc UMS_draw

UMS_destroy

		lda TabMissileOwner,x
		cmp #2
		bne UMS_not_from_enemy
		dec m_enemyMissilesActive
	
UMS_not_from_enemy
	
		lda #0
		sta TabMissileOwner,x

		ldy TabOldMissileScreenTopY,x
		jsr ClearMissileLines

		ldy TabMissileScreenTopY,x
		jsr ClearMissileLines

		dec m_currentVirtualMissiles

		jmp UMS_next

;*****	draw the missile
;
UMS_draw
	
		jsr DrawMissileMX

UMS_next

		inx
		cpx #MAX_VIRTUAL_MISSILES
		beq UMS_exit
		jmp UMS_loop

UMS_exit
		
		rts

.endp

;
;**************************************************************************************************
;	SetMissileScreenPos
;
; 		use X as a parameter (the index of the virtual missile)
;
;**************************************************************************************************
;	
.proc SetMissileScreenPos

		; save old screen pos
		lda TabMissileScreenLeftX,x
		sta TabOldMissileScreenLeftX,x
		
		lda TabMissileScreenTopY,x
		sta TabOldMissileScreenTopY,x

		; get new screen pos
		; this must use the "_H2" positions for 
		; when the delta between the missile and 
		; the camera is too big (64 chars in X, or 32 chars in Y)
		;
		lda TabMissileLevelLeftX_H1,x
		sec
		sbc m_levelWindowX_H1
		sta m_screenDelta_H1
		lda TabMissileLevelLeftX_H2,x
		sbc m_levelWindowX_H2
		bcc SMSP_set_outside					; this is not totally correct, because it doesn't use the width of the missile
		sta m_screenDelta_H2					; (but if we do it correctly we should clip the missile graphics)

		bne SMSP_set_outside					; could remove the bcc and only use this..
		lda m_screenDelta_H1
		cmp #[160-1]							; 40 chars x 4 pixels, minus (missile width - 1)
		bcs SMSP_set_outside
	
		adc #PM_BASE_SCREEN_X
		sta TabMissileScreenLeftX,x
	
		lda TabMissileLevelTopY_H1,x
		sec
		sbc m_levelWindowY_H1
		sta m_screenDelta_H1
		lda TabMissileLevelTopY_H2,x
		sbc m_levelWindowY_H2
		bcc SMSP_set_outside					; this is not totally correct, because it doesn't use the height of the missile
		sta m_screenDelta_H2					; (but if we do it correctly we should clip the missile graphics)

		bne SMSP_set_outside					; could remove the bcc and only use this..
		lda m_screenDelta_H1
		cmp #[193-2]							; 24 chars x 8 scan lines, plus one extra scan line, minus (missile height - 1)
		bcs SMSP_set_outside
	
		adc #PM_BASE_SCREEN_Y
		sta TabMissileScreenTopY,x

		rts
	
; if outside the visible range in X or Y, just set it out of the screen (for a p/m the screen coordinate 0 is outside the visible range)
SMSP_set_outside
		
		lda #0
		sta TabMissileScreenLeftX,x
		sta TabMissileScreenTopY,x
	
		rts
	
.endp
	
;
;**************************************************************************************************
;	DrawMissileMX
;
; 		draw missiles, use X as a parameter (the index of the virtual missile)
;
;**************************************************************************************************
;	
.proc DrawMissileMX
	
		lda TabDrawMissileMethodLSB,x
		sta m_pageZeroTempPointer
		
		lda TabDrawMissileMethodMSB,x
		sta m_pageZeroTempPointer+1

		lda #>(Exit -1)
		pha
		lda #<(Exit -1)
		pha

		jmp (m_pageZeroTempPointer)

Exit

		rts

.endp

;
;**************************************************************************************************
;	DrawMissileM0
;**************************************************************************************************
;	
.proc DrawMissileM0
		
		lda TabMissileScreenLeftX,x
		sta HPOSM0

		; clear old position first
		ldy TabOldMissileScreenTopY,x

		jsr ClearMissileLines

		; draw shape in new position
		ldy TabMissileScreenTopY,x

		lda TabMissileDirection,x
		cmp #1
		
		bne DMM0_left
		
		lda #>(Exit -1)
		pha
		lda #<(Exit -1)
		pha

		jmp SetMissileToRightLines

DMM0_left
		
		lda #>(Exit -1)
		pha
		lda #<(Exit -1)
		pha

		jmp SetMissileToLeftLines

Exit

		rts

.endp

;
;**************************************************************************************************
;	DrawMissileM1
;**************************************************************************************************
;	
.proc DrawMissileM1
	
		lda TabMissileScreenLeftX,x
		sta HPOSM1

		; clear old position first
		ldy TabOldMissileScreenTopY,x

		jsr ClearMissileLines

		; draw shape in new position
		ldy TabMissileScreenTopY,x

		lda TabMissileDirection,x
		cmp #1
		bne DMM1_left

		lda #>(Exit -1)
		pha
		lda #<(Exit -1)
		pha
		jmp SetMissileToRightLines

DMM1_left

		lda #>(Exit -1)
		pha
		lda #<(Exit -1)
		pha
		jmp SetMissileToLeftLines

Exit

		rts

.endp

;
;**************************************************************************************************
;	DrawMissileM2
;**************************************************************************************************
;	
.proc DrawMissileM2
		
		lda TabMissileScreenLeftX,x
		sta HPOSM2

		; clear old position first
		ldy TabOldMissileScreenTopY,x

		lda ms_area_1,y
		and #CLEAR_MASK_M2
		sta ms_area_1,y
		
		lda ms_area_1+1,y
		and #CLEAR_MASK_M2
		sta ms_area_1+1,y
		
		lda ms_area_1+2,y
		and #CLEAR_MASK_M2
		sta ms_area_1+2,y

		; draw shape in new position
		ldy TabMissileScreenTopY,x

		lda ms_area_1,y
		ora #SET_MASK_M2
		sta ms_area_1,y
		
		lda ms_area_1+1,y
		ora #SET_MASK_M2
		sta ms_area_1+1,y
		
		lda ms_area_1+2,y
		ora #SET_MASK_M2
		sta ms_area_1+2,y

		rts

.endp

;
;**************************************************************************************************
;	DrawMissileM3
;**************************************************************************************************
;	
.proc DrawMissileM3
	
		lda TabMissileScreenLeftX,x
		sta HPOSM3

		; clear old position first
		ldy TabOldMissileScreenTopY,x

		lda ms_area_1,y
		and #CLEAR_MASK_M3
		sta ms_area_1,y
		
		lda ms_area_1+1,y
		and #CLEAR_MASK_M3
		sta ms_area_1+1,y
	
		lda ms_area_1+2,y
		and #CLEAR_MASK_M3
		sta ms_area_1+2,y

		; draw shape in new position
		ldy TabMissileScreenTopY,x

		lda ms_area_1,y
		ora #SET_MASK_M3
		sta ms_area_1,y
	
		lda ms_area_1+1,y
		ora #SET_MASK_M3
		sta ms_area_1+1,y
	
		lda ms_area_1+2,y
		ora #SET_MASK_M3
		sta ms_area_1+2,y

		rts

.endp

;
;**************************************************************************************************
;	SetMissileToRightLines
;**************************************************************************************************
;	
.proc SetMissileToRightLines

		lda ms_area_1,y
		ora TabSetMissileToRightMaskL1,x	; this "x" should be a hardware missile index
		sta ms_area_1,y
		
		lda ms_area_1+1,y
		ora TabSetMissileToRightMaskL2,x	; this "x" should be a hardware missile index
		sta ms_area_1+1,y
		
		lda ms_area_1+2,y
		ora TabSetMissileToRightMaskL3,x	; this "x" should be a hardware missile index
		sta ms_area_1+2,y

		rts

.endp
		
;
;**************************************************************************************************
;	SetMissileToLeftLines
;**************************************************************************************************
;	
.proc SetMissileToLeftLines

		lda ms_area_1,y
		ora TabSetMissileToLeftMaskL1,x	; this "x" should be a hardware missile index
		sta ms_area_1,y
		
		lda ms_area_1+1,y
		ora TabSetMissileToLeftMaskL2,x	; this "x" should be a hardware missile index
		sta ms_area_1+1,y
		
		lda ms_area_1+2,y
		ora TabSetMissileToLeftMaskL3,x	; this "x" should be a hardware missile index
		sta ms_area_1+2,y

		rts

.endp

;
;**************************************************************************************************
;	ClearMissileLines
;**************************************************************************************************
;	
.proc ClearMissileLines

		lda ms_area_1,y
		and TabClearMissileMask,x				; this "x" should be a hardware missile index
		sta ms_area_1,y
		
		lda ms_area_1+1,y
		and TabClearMissileMask,x				; this "x" should be a hardware missile index
		sta ms_area_1+1,y
		
		lda ms_area_1+2,y
		and TabClearMissileMask,x				; this "x" should be a hardware missile index
		sta ms_area_1+2,y

		rts
		
.endp

;
;**************************************************************************************************
;	ClearAllMissiles
;**************************************************************************************************
;	
.proc ClearAllMissiles
		
		ldx #0
		lda #0

CAM_loop
		
		ldy TabMissileScreenTopY,x
		sta ms_area_1,y
		sta ms_area_1+1,y
		sta ms_area_1+2,y

		inx
		cpx #MAX_VIRTUAL_MISSILES
		bne CAM_loop

		rts
		
.endp
		
;
;**************************************************************************************************
;
;	GetPlayerMissileFrontChar
;
; 		use X as a parameter (the index of the virtual missile)
; 		return in A the character definition value
;
;**************************************************************************************************
;
.proc GetPlayerMissileFrontChar

		; get front point char column
		lda TabMissileDirection,x
		cmp #1
		bne GMFC_left

;*****	moving to the right, use right side pixel
;
GMFC_right
	
		lda TabMissileLevelLeftX_H1,x
		clc
		adc #3									; missile X size minus one
		sta m_pixelPositionX_H1
		lda TabMissileLevelLeftX_H2,x
		adc #0
		sta m_pixelPositionX_H2

		jmp GMFC_middle_line

;*****	moving to the left, use left side pixel
;
GMFC_left
		
		lda TabMissileLevelLeftX_H1,x
		sta m_pixelPositionX_H1
		lda TabMissileLevelLeftX_H2,x
		sta m_pixelPositionX_H2

;*****	get middle char line
;
GMFC_middle_line
	
		lda TabMissileLevelTopY_H1,x
		clc
		adc #1									; because the height is 3 lines
		sta m_pixelPositionY_H1
		lda TabMissileLevelTopY_H2,x
		adc #0
		sta m_pixelPositionY_H2

		lda #>(Exit -1)
		pha
		lda #<(Exit -1)
		pha

		jmp GetCharDefinitionFromPixelPos

Exit
		rts

.endp		

;
;**************************************************************************************************
;
;	GetCharDefinitionFromPixelPos
;
; 		put coord "x" in m_pixelPositionX_H2/_H1 and coord "y" in m_pixelPositionY_H2/_H1
; 		return in A the character definition value (and also use the Y register)
; 		(this assume that there no more than 256 chars in x or in y, in a room)
;
;**************************************************************************************************
;
.proc GetCharDefinitionFromPixelPos


		; get char line, divide by 8 (put in Y)
		lda m_pixelPositionY_H2
		sta m_charBuffer_H2
		lda m_pixelPositionY_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		sta m_charPositionY
		tay

		; init pointer to char
		lda TabLevelLineAddressLSB,y
		sta GCDFPP_pointer+1
		sta m_lineAddressLSB
	
		lda TabLevelLineAddressMSB,y
		sta GCDFPP_pointer+2
		sta m_lineAddressMSB

		; get char column, divide by 4 (put in Y)
		lda m_pixelPositionX_H2
		sta m_charBuffer_H2
		lda m_pixelPositionX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		sta m_charPositionX
		tay

GCDFPP_pointer
		
		lda $FFFF,y
		sta m_charRaw

		tay
		lda TabCharDefinition,y
		sta m_charDef

		rts

.endp
