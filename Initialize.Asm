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
		
		; set uo spawn position
		jsr SetSpawnPos
		lda #PSD_LEFT	
		sta m_lastPlayerSideDirection
		sta m_lastPlayerShootDirection
		lda #1
		sta m_redrawPlayerCounter
		jsr DrawPlayer
		
		lda #PSD_RIGHT	
		sta m_lastPlayerSideDirection
		sta m_lastPlayerShootDirection
		lda #1
		sta m_redrawPlayerCounter
		jsr DrawPlayer	

		jsr SetPlayerInfo	
		
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
; UpdateInfoLine
;**************************************************************************************************
;
.proc InitPlatforms

		ldx #$00
		stx m_floatPlatformV
		stx m_floatPlatformH
		stx m_floatPlatformIdx		
		
;*****	Beging loop
;
loop
		ldy #0									; column index
	
		lda TabLevelLineAddressLSB,x		
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

;*****	Middle loop
;
loop1

		lda (m_ptrLevelLine),y
		sta m_currChar	
		stx m_pageZeroTempValue
		tax
		lda TabCharDefinition,x
		ldx m_pageZeroTempValue

		and #15
		cmp #CT_FLOATPLATFORMH
		beq loopH
		
		cmp #CT_FLOATPLATFORMV
		beq loopV		
		jmp loop2	

loopH
		lda PlatformCharH
		cmp m_currChar
		beq StartH

		lda PlatformCharH+1
		cmp m_currChar
		beq StartH
		jmp loop2
					
StartH	
							 
		txa										; move x to a
		pha										; store a

		tya										; move y to a
		pha										; store a
		
		ldy m_floatPlatformIdx					; put the current index in y

		pha
		lda TabLevelLineAddressLSB,x
		sta PlatformBaseLSB,y
		lda TabLevelLineAddressMSB,x
		sta PlatformBaseMSB,y
		
		pla		
		clc										; clear the carry
		adc TabLevelLineAddressLSB,x			; add the lsb screen address		
		sta PlatformLSB,y						; store it by index		
		
		lda TabLevelLineAddressMSB,x			; get the msb screen address
		adc #00									; account for carry
		sta PlatformMSB,y						; store it by index
		
		lda #01									; type 01 is horizontal
		sta PlatformType,y						; store it by index
		
		lda #$00								; initialize the step
		sta PlatformStepX,y						; store it by index
				
		inc m_floatPlatformIdx					; increment the index
		inc m_floatPlatformH
		
		pla										; pull y
		tay										; restore y

		pla										; pull x
		tax										; restore x

		jmp loop2
		
loopV	
		lda TabCharDefinition,x			
		inc m_floatPlatformV
		
;*****	Loop on X 
;		
loop2	
		iny
		cpy m_levelCharSizeX
		bne loop1
		
		inx
		cpx m_levelCharSizeY
		beq Exit
		jmp loop
		
Exit		
		rts

.endp

;
;**************************************************************************************************
; UpdateInfoLine
;**************************************************************************************************
;
.proc UpdateInfoLine
	
		lda m_goldCounter						; assuming 99 or less
		ldy #4
		jsr DisplayDebugInfoBinary99

		lda m_activeEnemies
		ldy #12
		jsr DisplayDebugInfoBinary99

		lda m_healthCounter						; assuming 99 or less
		ldy #31
		jsr DisplayDebugInfoBinary99

		lda m_disableGameTimer					; update the time here also
		bne UIL_exit
	
		lda m_goldCounter
		bne UIL_update_timer
		
		lda m_activeEnemies
		bne UIL_update_timer
	
		lda #1
		sta m_disableGameTimer					; my record? 1:16.1 (NTSC, lost one life)

;*****	allow the final update..
;
UIL_update_timer
	
		inc m_gameTSFrameCounter
		lda m_gameTSFrameCounter
		cmp #TENTH_OF_SECOND_FRAMES
		bne UIL_draw_timer
	
		lda #0
		sta m_gameTSFrameCounter
		inc m_gameTimerTSeconds
		
		lda m_gameTimerTSeconds
		cmp #10
		bne UIL_draw_timer
	
		lda #0
		sta m_gameTimerTSeconds
		inc m_gameTimerSeconds
	
		lda m_gameTimerSeconds
		cmp #60
		bne UIL_draw_timer
	
		lda #0
		sta m_gameTimerSeconds
		inc m_gameTimerMinutes

		lda m_gameTimerMinutes
		cmp #100
		bne UIL_draw_timer
	
		lda #1
		sta m_disableGameTimer
		jmp UIL_exit							; final timer would be 99:99.9 in this case

;*****	Draw Timer
;
UIL_draw_timer
	
		lda m_gameTimerMinutes
		ldy #20
		jsr DisplayDebugInfoBinary99
	
		lda m_gameTimerSeconds
		ldy #23
		jsr DisplayDebugInfoBinary99
	
		lda m_gameTimerTSeconds
		ldy #26
		jsr DisplayDebugInfoBinary9

;*****	Exit
;
UIL_exit
		
;		lda m_playerScreenLeftX
;		ldy #40
;		jsr DisplayDebugInfoHexFF
;
;		lda m_playerScreenTopY
;		ldy #43
;		jsr DisplayDebugInfoHexFF
;
;		lda m_playerState
;		ldy #46
;		jsr DisplayDebugInfoHexFF
;
;		lda m_lastPlayerSideDirection
;		ldy #49
;		jsr DisplayDebugInfoHexFF
;
;		lda m_animFrame
;		ldy #52
;		jsr DisplayDebugInfoHexFF
;
;		lda m_animIndex
;		ldy #55
;		jsr DisplayDebugInfoHexFF
				
		rts
	
.endp	

;
;**************************************************************************************************
; UpdateTimers
;**************************************************************************************************
;
.proc UpdateTimers
		
		lda m_playerNoJumpTimer
		beq UT_end_no_jump
		dec m_playerNoJumpTimer
	
;************************************************
;	
UT_end_no_jump		
		
		rts

.endp	

