;	
;**************************************************************************************************
; Filename:		camera_logic.asm [NRV 2010 - 2017]
; Project:		Plunker
;
; Created On:	Mon Aug 28, 2017 02:05 AM	
; Modified On:	Wed Mar 21, 2018 10:12 PM
;
;**************************************************************************************************
;
;**************************************************************************************************
; Local Storage
;**************************************************************************************************
;
MAX_ENEMY_MISSILES 				= 2
MAX_EXPLOSION_STEPS 			= 22
MAX_ENEMIES_PER_LEVEL 			= 32

m_enemyExplosionLevelLeftX_H2	.byte $00
m_enemyExplosionLevelLeftX_H1	.byte $00

m_enemyExplosionLevelTopY_H2	.byte $00
m_enemyExplosionLevelTopY_H1	.byte $00
m_enemyExplosionLevelTopY_L1	.byte $00

m_enemyExplosionScreenLeftX_H1	.byte $00
m_enemyExplosionScreenTopY_H1	.byte $00

m_enemyExplosionStep			.byte $00

m_enemyExplosionStepIndex		.byte $00
m_enemyCharPosX					.byte $00
m_enemyCharPosY					.byte $00

m_numEnemyExplosions			.byte $00
m_hitEnemySaveX 				.byte $00

m_totalEnemies 					.byte $00
m_activeEnemies 				.byte $00

m_searchEnemyChar 				.byte $00
m_defEnemyLife 					.byte $00
m_numberOfValidRows 			.byte $00

m_tempByte 						.byte $00

m_lastEnemyIndexUpdated 		.byte $00

m_enemyMissilesActive 			.byte $00

m_enemyShootDirection 			.byte $00

m_enemyShotLevelLeftX_H1 		.byte $00
m_enemyShotLevelLeftX_H2 		.byte $00
m_enemyShotLevelTopY_H1 		.byte $00
m_enemyShotLevelTopY_H2 		.byte $00

TabEnemyShapeSizeY				.byte $08

TabEnemyShape_01				.byte %00111100
								.byte %11100111
								.byte %00011000
								.byte %11100111
								.byte %00111100
								.byte %00000000
								.byte %00111100
								.byte %01111110

TabEnemyExplosionColor
.if PAL_VERSION = 0
	.byte +32, 14, 14, 14, 12, 12, 12, 10, 10, 10, 8, 8, 8, 6, 6, 6, 4, 4, 4, 2, 2, 2, 0
.else
	.byte +16, 14, 14, 14, 12, 12, 12, 10, 10, 10, 8, 8, 8, 6, 6, 6, 4, 4, 4, 2, 2, 2, 0
.endif

.if PAL_VERSION = 0
ENEMY_EXPLOSION_COLOR 			= 32+10
.else
ENEMY_EXPLOSION_COLOR 			= 16+10
.endif


TabEnemyType
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyLife									; this table could be per level, if we can go back to the same screen
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyState
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyStateTimer
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyBaseCharIndex
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyBaseCharX
	:MAX_ENEMIES_PER_LEVEL 		.byte $00
TabEnemyBaseCharY
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyLevelLeftX_H1
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyLevelLeftX_H2
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyLevelTopY_H1
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyLevelTopY_H2
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyShotLevelLeftX_H1
	:MAX_ENEMIES_PER_LEVEL 		.byte $00
TabEnemyShotLevelLeftX_H2
	:MAX_ENEMIES_PER_LEVEL 		.byte $00
TabEnemyShotLevelTopY_H1
	:MAX_ENEMIES_PER_LEVEL 		.byte $00
TabEnemyShotLevelTopY_H2
	:MAX_ENEMIES_PER_LEVEL 		.byte $00

TabEnemyDefLife					.byte $00, $01	; enemy definition tables (index or type 0 is not used)		

TabEnemyDefBaseChar				.byte $00, $C0

TabEnemyDefShootCooldown
.if PAL_VERSION = 0
	.byte $00, 120
.else
	.byte $00, 100
.endif
;
;**************************************************************************************************
; UpdateEnemyManager
;**************************************************************************************************
;
.proc UpdateEnemyManager

		; update one enemy per frame, rotate through all active enemies
		lda m_activeEnemies
		bne UEM_active_enemies
		jmp UEM_exit

;************************************************
;
UEM_active_enemies
	
		; update state timer for all enemies (if we don't want to do this, we should use a general time stamp system)
		ldx #0

;************************************************
;
UEM_loop1
	
		lda TabEnemyStateTimer,x
		beq UEM_next_timer
		dec TabEnemyStateTimer,x

;*************************************************
;
UEM_next_timer
	
		inx
		cpx m_totalEnemies
		bne UEM_loop1

		; iterate until we find the next active enemy
		ldx m_lastEnemyIndexUpdated

;************************************************
;
UEM_loop2
	
		inx
		cpx m_totalEnemies
		bne UEM_no_loop_back
		ldx #0

;************************************************
;
UEM_no_loop_back
	
		lda TabEnemyState,x						; state 0 implies a disabled enemy
		beq UEM_loop2
		stx m_lastEnemyIndexUpdated

		;
		; should use the enemy type to jump to the correct update for that type
		; check state timer, update state if is 0
		;
		lda TabEnemyStateTimer,x
		bne UEM_exit

;************************************************
; timer is 0, check if the player is near enough 
; to shoot, in what direction, and if there are 
; missiles available 
;	(maybe check against the maximum number of enemy missiles possible)
;
UEM_check_shoot
	
		lda m_enemyMissilesActive
		cmp #MAX_ENEMY_MISSILES
		beq UEM_exit
	
		; check delta Y between the player and the enemy
		lda m_playerLevelTopY_H1
		sec
		sbc TabEnemyLevelTopY_H1,x
		sta m_pageZeroTempPointer
		lda m_playerLevelTopY_H2
		sbc TabEnemyLevelTopY_H2,x
		sta m_pageZeroTempPointer+1

		lda m_pageZeroTempPointer
		clc
		adc #ENEMY_SHOOT_DELTA_Y
		sta m_pageZeroTempPointer
		lda m_pageZeroTempPointer+1
		adc #0
		sta m_pageZeroTempPointer+1
		bne UEM_exit							; abort if the high byte is already greater than 0

		; this works for a delta Y lower than 128 (lines)
		lda m_pageZeroTempPointer
		cmp #[ENEMY_SHOOT_DELTA_Y*2]
		bcs UEM_exit

;************************************************
;	
UEM_shot
	
		ldy TabEnemyType,x
		lda TabEnemyDefShootCooldown,y
		sta TabEnemyStateTimer,x				; set shoot cooldown		
		;
		; update m_enemyShootDirection (1 - right, 2 - left)
		; player width = 4 pixels, enemy1 width = 8 pixels
		; compare to see if: px + (pw/2) == ex + (ew/2) (the center of the player and the enemy)
		; if player info is equal or greater, then player is to the right of the enemy
		;
		lda m_playerLevelLeftX_H1
		sec
		sbc #4
		sta m_pageZeroTempValue
		
		lda m_playerLevelLeftX_H2
		sbc #0
		cmp TabEnemyLevelLeftX_H2,x
		bcc UEM_shoot_left
		bne UEM_shoot_right
	
		lda m_pageZeroTempValue
		cmp TabEnemyLevelLeftX_H1,x
		bcc UEM_shoot_left

;************************************************
;	
UEM_shoot_right
	
		lda #1
		jmp UEM_just_shoot

;************************************************
;	
UEM_shoot_left
	
		lda #2

;************************************************
;	
UEM_just_shoot
	
		sta m_enemyShootDirection

		; update shot creation pos (assuming left and right pos are the same in this case)
		lda TabEnemyShotLevelLeftX_H1,x
		sta m_enemyShotLevelLeftX_H1
		
		lda TabEnemyShotLevelLeftX_H2,x
		sta m_enemyShotLevelLeftX_H2
	
		lda TabEnemyShotLevelTopY_H1,x
		sta m_enemyShotLevelTopY_H1
		
		lda TabEnemyShotLevelTopY_H2,x
		sta m_enemyShotLevelTopY_H2

		jsr CheckCreateEnemyMissile
	
		inc m_enemyMissilesActive

;************************************************
;	
UEM_exit

		rts
		
.endp		
;
;**************************************************************************************************
; HitEnemy
;**************************************************************************************************
;	
.proc HitEnemy

		; should not use x register
		stx m_hitEnemySaveX
	
		;
		; pass parameters in m_enemyCharPosX and m_enemyCharPosY
		; get address of that char (clear it and the next one) --> comes in m_lineAddressLSB, m_lineAddressMSB
		; get pixel xpos for pm hpos, get pixel ypos for explosion start line
		;
		; search for enemy index at the left char position
		;
		ldx #0

;************************************************
;	
HE_loop	
	
		lda TabEnemyBaseCharX,x
		cmp m_enemyCharPosX
		bne HE_next_enemy
	
		lda TabEnemyBaseCharY,x
		cmp m_enemyCharPosY
		bne HE_next_enemy
;
;************************************************
;	
HE_found_pos
	
		lda TabEnemyState,x
		beq HE_exit								; already disabled
	
		lda TabEnemyLife,x
		beq HE_exit								; already destroyed

		dec TabEnemyLife,x
		beq HE_destroy_enemy					; life reached 0
	
		jmp HE_exit								; still alive (no feedback for now?)

;************************************************
;	
HE_next_enemy
	
		inx
		cpx m_totalEnemies
		bne HE_loop
		jmp HE_exit

;**************************************************************************************************
;	
HE_destroy_enemy

		lda #0
		sta TabEnemyState,x
		dec m_activeEnemies
		
		lda m_lineAddressLSB
		sta m_ptrLevelLine
		
		lda m_lineAddressMSB
		sta m_ptrLevelLine+1
		ldy m_enemyCharPosX
		
		lda #0
		sta (m_ptrLevelLine),y
		iny
		sta (m_ptrLevelLine),y

		; init explosion info (clear previous explosion if there was one active)
		lda m_numEnemyExplosions
		beq HE_no_explosions
		jsr EraseExplosionFrame

;************************************************
;	
HE_no_explosions
	
		lda TabEnemyLevelLeftX_H2,x
		sta m_enemyExplosionLevelLeftX_H2
		
		lda TabEnemyLevelLeftX_H1,x
		sta m_enemyExplosionLevelLeftX_H1
	
		lda TabEnemyLevelTopY_H2,x
		sta m_enemyExplosionLevelTopY_H2
	
		lda TabEnemyLevelTopY_H1,x
		sta m_enemyExplosionLevelTopY_H1
		
		lda #0
		sta m_enemyExplosionLevelTopY_L1
		sta m_enemyExplosionStepIndex

		lda #1
		sta m_enemyExplosionStep
		sta m_numEnemyExplosions				; 1 max for now

;************************************************
;	
HE_exit

		ldx m_hitEnemySaveX	
		rts
	
.endp	
;
;**************************************************************************************************
; EraseExplosionFrame
;	
; 	also clear enemy explosion if the player respawns
; 	also clear enemy missiles and m_enemyMissilesActive
;
;**************************************************************************************************
;
.proc EraseExplosionFrame

		ldx #0
		ldy m_enemyExplosionScreenTopY_H1

;************************************************
;
EEF_loop
		lda #0
		sta ms_area_1,y

		tya
		clc
		adc m_enemyExplosionStep
		tay

		inx
		cpx TabEnemyShapeSizeY					; should use and index here, if there is more than one enemy explosion
		bne EEF_loop

;************************************************
;
EEF_exit		
		rts
	
.endp	
;
;**************************************************************************************************
; DrawExplosionFrame
;**************************************************************************************************
;
.proc DrawExplosionFrame

		ldx #0
		ldy m_enemyExplosionScreenTopY_H1

;************************************************
;
DEF_loop
		
		lda TabEnemyShape_01,x
		sta ms_area_1,y

		tya
		clc
		adc m_enemyExplosionStep
		tay
		inx
		cpx TabEnemyShapeSizeY					; should use and index here, if there is more than one enemy explosion
		bne DEF_loop
;
;************************************************
;
DEF_exit
		
		rts

.endp		
;
;**************************************************************************************************
; DrawEnemyExplosion
;**************************************************************************************************
;
.proc DrawEnemyExplosion

		lda m_numEnemyExplosions
		bne DEE_erase
		jmp DEE_exit
	
;************************************************
; erase previous enemy explosion frame
;
DEE_erase
		jsr EraseExplosionFrame

;************************************************
;
DEE_update_frame
	
		inc m_enemyExplosionStepIndex
		ldx m_enemyExplosionStepIndex
		cpx #MAX_EXPLOSION_STEPS
		bcc DEE_do_update
	
		; reached end of the explosion
		lda #0
		sta m_numEnemyExplosions

		jmp DEE_exit

;************************************************
;
DEE_do_update
	
		lda TabEnemyExplosionColor,x
		sta COLPM3

		; update step and explosion starting line
		; if step +1 --> line - 3.5
		; if step +2 --> line - 7.0
		lda m_enemyExplosionLevelTopY_L1
		sec
		sbc #128
		sta m_enemyExplosionLevelTopY_L1

		lda m_enemyExplosionLevelTopY_H1
		sbc #3
		sta m_enemyExplosionLevelTopY_H1

		lda m_enemyExplosionLevelTopY_H2
		sbc #0
		sta m_enemyExplosionLevelTopY_H2

		inc m_enemyExplosionStep				; step +1 (delta between every explosion line, in this frame)
	
		;
		; get new screen pos for the explosion
		; this must use the "_H2" positions for 
		; when the delta between the explosion 
		; and the camera is too big (64 chars 
		; in X, or 32 chars in Y)
		;
		lda m_enemyExplosionLevelLeftX_H1
		sec
		sbc m_levelWindowX_H1
		sta m_screenDelta_H1

		lda m_enemyExplosionLevelLeftX_H2
		sbc m_levelWindowX_H2
		bcc DEE_set_outside						; this is not totally correct, because it doesn't use the width of the missile
		sta m_screenDelta_H2					; (but if we do it correctly we should clip the missile graphics)

		bne DEE_set_outside						; could remove the bcc and only use this..
		lda m_screenDelta_H1
		cmp #[160]								; 40 chars x 4 pixels
		bcs DEE_set_outside
	
		adc #PM_BASE_SCREEN_X
		sta m_enemyExplosionScreenLeftX_H1
	
		lda m_enemyExplosionLevelTopY_H1
		sec
		sbc m_levelWindowY_H1
		adc #PM_BASE_SCREEN_Y
		sta m_enemyExplosionScreenTopY_H1

		jmp DEE_update_hpos

;************************************************
; if outside the visible range in X or Y, just set 
; it out of the screen (for a p/m the screen coordinate 0 is outside the visible range)
;
DEE_set_outside

		lda #0
		sta m_enemyExplosionScreenLeftX_H1
		sta m_enemyExplosionScreenTopY_H1

;************************************************
;
DEE_update_hpos
	
		lda m_enemyExplosionScreenLeftX_H1
		sta HPOSM0

;************************************************
;
DEE_draw
		
		; draw new enemy explosion frame
		jsr DrawExplosionFrame

;************************************************
;
DEE_exit
		rts

.endp
