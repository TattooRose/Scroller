;
;***************************************************************************************************
;
;	Filename:		Initialize.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; InitVars
;**************************************************************************************************
;
.proc InitVars
	
		lda #1									; input info
		sta m_currentTrigger0
		sta m_oldTrigger0

		lda #0
		sta m_triggerState

		lda #15
		sta m_stick0
		sta m_oldStick0
		
		lda #>[CHAR_PIX.else_X]					; level info
		sta m_levelWindowX_H2
		
		lda #<[CHAR_PIX.else_X]
		sta m_levelWindowX_H1
		
		lda #0
		sta m_levelWindowY_H2
		
		lda #0
		sta m_levelWindowY_H1

		lda #LEVEL_CHAR_SIZE_X
		sta m_levelCharSizeX
		
		lda #LEVEL_CHAR_SIZE_Y
		sta m_levelCharSizeY

		lda #>[LEVEL_CHAR_SIZE_X*CHAR_PIX.else_X]
		sta m_levelSizeX_H2
		
		lda #<[LEVEL_CHAR_SIZE_X*CHAR_PIX.else_X]
		sta m_levelSizeX_H1

		lda #>[LEVEL_CHAR_SIZE_Y*CHAR_PIX.else_Y]
		sta m_levelSizeY_H2
		
		lda #<[LEVEL_CHAR_SIZE_Y*CHAR_PIX.else_Y]
		sta m_levelSizeY_H1

		lda #<GameMemoryAddress
		sta m_currentLineAddress
		
		lda #>GameMemoryAddress
		sta m_currentLineAddress+1

		jsr InitLevelTable						; set up the level table		
			
		;************************************************
		;
		; player info
		;
		; 	remember that we don't use any speed over 1 char per frame right now,
		; 	because we don't want to lose collisions (in that case case we should
		; 	use 2 or more steps per frame, or a "sweep" collision method)
		;
		;************************************************
		;

.if PAL_VERSION = 0
	
		lda #3									; air vertical movement 240 pixels per second (at 60 fps only!)
		sta m_playerJumpSpeed_H1
		
		lda #128
		sta m_playerJumpSpeed_L1

		lda #6									; near 400 pixels per second (1 character per frame at 50 fps, PAL friendly)
		sta m_playerMaxFallSpeed_H1
	
		lda #170
		sta m_playerMaxFallSpeed_L1

		lda #0									; 12.8 frames (at 60 fps only!) to reach max speed (from zero)
		sta m_playerGravityAccel_H1
	
		lda #112
		sta m_playerGravityAccel_L1
				
		lda #0									; water vertical movement
		sta m_playerWaterAccelY_H1
		
		lda #32
		sta m_playerWaterAccelY_L1

		lda #0
		sta m_playerMaxWaterSpeedY_H1
	
		lda #128
		sta m_playerMaxWaterSpeedY_L1

		lda #1
		sta m_playerMoveWaterSpeedY_H1
	
		lda #0
		sta m_playerMoveWaterSpeedY_L1

.else

		lda #4									; air vertical movement pixels per second (at 50 fps only!)
		sta m_playerJumpSpeed_H1
	
		lda #51
		sta m_playerJumpSpeed_L1

		lda #7									; near 400 pixels per second (1 character per frame at 50 fps, PAL friendly)
		sta m_playerMaxFallSpeed_H1
	
		lda #255
		sta m_playerMaxFallSpeed_L1

		lda #0									;  frames (at 50 fps only!) to reach max speed (from zero)
		sta m_playerGravityAccel_H1
		
		lda #134
		sta m_playerGravityAccel_L1

		lda #0									; water vertical movement
		sta m_playerWaterAccelY_H1
		
		lda #38
		sta m_playerWaterAccelY_L1

		lda #0
		sta m_playerMaxWaterSpeedY_H1
	
		lda #154
		sta m_playerMaxWaterSpeedY_L1

		lda #1
		sta m_playerMoveWaterSpeedY_H1
	
		lda #51
		sta m_playerMoveWaterSpeedY_L1

.endif
	
		ldx #PLR_WIDTH							; set size in pixels
		stx m_playerSizeX
		dex
		stx m_playerSizeXMinusOne
	
		ldx #PLR_HEIGHT
		stx m_playerSizeY
		dex
		stx m_playerSizeYMinusOne
	
		jsr InitPlayerInfo
		
		rts
	
.endp	

;
;**************************************************************************************************
; InitPlayerInfo
;**************************************************************************************************
;
.proc InitPlayerInfo

		lda #0
		sta m_playerNoJumpTimer
		sta m_playerHoldJumpCounter
		sta m_playerOverPlatformFlag
		sta m_playerTopCollisionFlag
		sta m_playerSideCollisionFlag

		ldx #PS_OVER_PLATFORM
		jsr SetPlayerMethod

		lda #0
		sta m_playerSideSpeed_H1
		sta m_playerSideSpeed_L1
		
;		lda #PSD_NONE
;		sta m_lastPlayerSideDirection
;		lda #PSD_RIGHT
;		sta m_lastPlayerShootDirection
		
		; set uo spawn position
		lda #PSD_RIGHT	
		sta m_lastPlayerSideDirection
		sta m_lastPlayerShootDirection
;		
		
		jsr SetPlayerInfo
		;jsr DrawPlayer	

			
		
		rts

.endp		

;
;**************************************************************************************************
; InitLevelTable
;**************************************************************************************************
;
.proc InitLevelTable
		
		ldy #0

;************************************************
;
ILTL_loop

		lda m_currentLineAddress
		sta TabLevelLineAddressLSB,y
		
		lda m_currentLineAddress+1
		sta TabLevelLineAddressMSB,y

		lda m_levelCharSizeX
		bne ILTL_below_256

		inc m_currentLineAddress+1				; if m_levelCharSizeX = 0, then add 256 chars
		jmp ILTL_check_loop

;************************************************
;
ILTL_below_256

		clc
		adc m_currentLineAddress				; from 1 to 255 chars
		sta m_currentLineAddress

		lda m_currentLineAddress+1
		adc #0
		sta m_currentLineAddress+1

;************************************************
;
ILTL_check_loop

		iny
		cpy m_levelCharSizeY					; from 1 to 255 lines, 0 = 256 lines in this case
		bne ILTL_loop
	
		lda m_currentLineAddress				; add one more line definition to fix problem of ladders in the last line, but this is not going to work if there are 256 lines!
		sta TabLevelLineAddressLSB,y
	
		lda m_currentLineAddress+1
		sta TabLevelLineAddressMSB,y
	
		rts
		
.endp		

;
;**************************************************************************************************
; InitGoldCounter
;**************************************************************************************************
;
.proc InitGoldCounter

		ldx #0									; line index

;****	1st Loop
; 
IGC_loop1
	
		ldy #0									; column index
	
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

;*****	2nd Loop
;
IGC_loop2

		lda (m_ptrLevelLine),y
		sta m_currChar	
		stx m_pageZeroTempValue
		tax
		lda TabCharDefinition,x
		ldx m_pageZeroTempValue
	
		and #15
		cmp #CT_COLLECTABLE
		bne WaterCheck
	
		inc m_goldCounter
		jmp IGC_no_gold
		
;*****	Water Check
;		
WaterCheck

		cmp #CT_WATER
		bne HealthCheck
		
		inc m_waterAvailable
		jmp IGC_no_gold
		
;*****	Health Check
;		
HealthCheck

		cmp #CT_HEALTH
		bne VertLaserCheck
		
		inc m_healthCounter
		jmp IGC_no_gold		
		
;*****	Vertical Check
;		
VertLaserCheck

		cmp #CT_VLASER
		bne HoriLaserCheck
		
		inc m_verticalLaserOn
		jmp IGC_no_gold

;*****	Horizontal Check
;		
HoriLaserCheck

		cmp #CT_HLASER
		bne IGC_no_gold

		inc m_horizontalLaserOn
			
;*****	No Gold
;	
IGC_no_gold

		iny
		cpy m_levelCharSizeX
		bne IGC_loop2

;*****	Check Loop Y
;
IGC_check_loop_Y

		inx
		cpx m_levelCharSizeY
		bne IGC_loop1
			
		rts

.endp	

;
;**************************************************************************************************
; 	InitPlatforms
;**************************************************************************************************
;
.proc InitPlatforms

		lda #$00
		sta m_floatPlatformV
		sta m_floatPlatformH
		sta m_floatPlatformIdx	

		ldx #$00
Loop		
		sta TabPlatformDir,x  
		sta TabPlatformStep,x  
		sta TabPlatformCount,x  
		sta TabPlatformLSB_H,x
		sta TabPlatformMSB_H,x
		inx
		cpx #$08
		bne Loop
		
		ldx #$00			

;****	1st Loop
; 
Loop1
	
		ldy #0									; column index
	
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

;*****	2nd Loop
;
Loop2

		lda (m_ptrLevelLine),y
		sta m_currChar	
		stx m_pageZeroTempValue
		tax
		lda TabCharDefinition,x
		ldx m_pageZeroTempValue
	
		and #15
		cmp #CT_FLOATPLATFORMH
		bne IGC_no_gold
		
		lda TabPlatformCharID_H
		cmp m_currChar
		bne IGC_no_gold
	
		txa
		pha
		
		tya
		pha
		
		ldx	m_floatPlatformIdx
		
		clc		 
		adc m_ptrLevelLine
		sta m_platformScrnAddress
		sta TabPlatformLSB_H,x
		lda m_ptrLevelLine+1
		adc #$00
		sta m_platformScrnAddress+1
		sta TabPlatformMSB_H,x		
		
		pla
		tay
		pla
		tax
		
		inc m_floatPlatformIdx
		lda #$01
		sta m_floatPlatformH
		
;*****	No Gold
;	
IGC_no_gold

		iny
		cpy m_levelCharSizeX
		bne Loop2

;*****	Check Loop Y
;
IGC_check_loop_Y

		inx
		cpx m_levelCharSizeY
		bne Loop1

Exit			

		rts		

.endp

;
;**************************************************************************************************
; InitEnemyManager
;
; parse every type of enemy, init its life, state, char index and position
; update total and active enemies
;
;**************************************************************************************************
;
.proc InitEnemyManager

		; parse enemy type 1 (only one for now)
		ldx #1							; enemy type index
		lda TabEnemyDefBaseChar,x
		sta m_searchEnemyChar
		lda TabEnemyDefLife,x
		sta m_defEnemyLife
	
		ldx m_levelCharSizeX
		dex										; we search in a shorter line because this enemy has a width of 2 chars
		stx m_numberOfValidRows
	
		ldx #0									; line index
;
;************************************************
;
IEM_loop1
	
		ldy #0									; column index	
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

;************************************************
;
IEM_loop2
	
		lda (m_ptrLevelLine),y
		cmp m_searchEnemyChar
		bne IEM_no_enemy

		stx m_tempByte
		ldx m_totalEnemies

		; init info for this enemy
		lda #1
		sta TabEnemyType,x
		
		lda m_defEnemyLife
		sta TabEnemyLife,x
		
		lda #1
		sta TabEnemyState,x
		
		lda #ENEMY_INIT_TIMER					; dont allow enemy actions for the first 4 seconds
		sta TabEnemyStateTimer,x
		
		lda m_searchEnemyChar
		sta TabEnemyBaseCharIndex,x
		tya
		sta TabEnemyBaseCharX,x
		
		lda m_tempByte
		sta TabEnemyBaseCharY,x

		; init level position
		; TabEnemyLevelTopY_H2 starts as 0, now multiply by 8 to get the line
		asl
		rol TabEnemyLevelTopY_H2,x
		asl
		rol TabEnemyLevelTopY_H2,x
		asl
		rol TabEnemyLevelTopY_H2,x
		sta TabEnemyLevelTopY_H1,x
	
		; TabEnemyLevelLeftX_H2 starts as 0, now multiply by 4 to get the horizontal pixel
		tya
		asl
		rol TabEnemyLevelLeftX_H2,x
		asl
		rol TabEnemyLevelLeftX_H2,x
		sta TabEnemyLevelLeftX_H1,x

		; init shot creation position (offset x: 3, offset y: 1)
		lda TabEnemyLevelLeftX_H1,x
		clc
		adc #3
		sta TabEnemyShotLevelLeftX_H1,x
		lda TabEnemyLevelLeftX_H2,x
		adc #0
		sta TabEnemyShotLevelLeftX_H2,x
	
		lda TabEnemyLevelTopY_H1,x
		clc
		adc #1
		sta TabEnemyShotLevelTopY_H1,x
		
		lda TabEnemyLevelTopY_H2,x
		adc #0
		sta TabEnemyShotLevelTopY_H2,x

		; update number of enemies	
		inc m_totalEnemies
		inc m_activeEnemies

		lda m_totalEnemies
		cmp #MAX_ENEMIES_PER_LEVEL
		beq IEM_exit
	
		ldx m_tempByte

;************************************************
;
IEM_no_enemy
		
		iny
		cpy m_numberOfValidRows
		beq IEM_check_loop_Y
		jmp IEM_loop2

;************************************************
;
IEM_check_loop_Y

		inx
		cpx m_levelCharSizeY
		beq IEM_exit
		jmp IEM_loop1

;************************************************
;
IEM_exit
	
		rts
		
.endp		

;
;**************************************************************************************************
; InitMissileSystem
;	
; 	Right now, the missile system is using a 1-on-1 relationship between
; 	a virtual missile and a hardware missile, so we have a max of 4 virtual
; 	missiles. If we want more virtual missiles we can only draw 4 every frame,
; 	so some of them can lose hardware collisions and they are going to flicker
;
;**************************************************************************************************
;
.proc InitMissileSystem

.if PAL_VERSION = 0
		lda #[32+4]		; red color, change for pal
.else
		lda #[16+4]
.endif
		sta m_missleBaseColor00
		
		lda #0
		sta m_currentVirtualMissiles

		ldx #0

IMS_loop
		sta TabMissileScreenLeftX,x
		sta TabMissileScreenTopY,x
		sta TabOldMissileScreenLeftX,x
		sta TabOldMissileScreenTopY,x

		sta TabMissileLevelLeftX_H2,x
		sta TabMissileLevelLeftX_H1,x
		sta TabMissileLevelLeftX_L1,x
		sta TabMissileLevelTopY_H2,x
		sta TabMissileLevelTopY_H1,x
		sta TabMissileLevelTopY_L1,x

		sta TabMissileSpeedX_H1,x
		sta TabMissileSpeedX_L1,x

		sta TabMissileDirection,x

		sta TabMissileFrameCounter_H2,x
		sta TabMissileFrameCounter_H1,x

		sta TabMissileOwner,x

		inx
		cpx #MAX_VIRTUAL_MISSILES
		bne IMS_loop

		rts

.endp	
	
