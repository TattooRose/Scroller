;	
;**************************************************************************************************
;
;	Filename:		Scroller.Asm
;
;	Created By:		Victor V Ferenzi
;
;	Created On:		Wed Apr 18, 2018 12:30 PM
;
;	Comments:		This code contains parts of the OPEN_PLAT project developed by NVR. It also
;					contains parts of the port from the C64 to Atari project ported by
;					Ken Jennings. Many thanks to both of them. 
;	
;**************************************************************************************************
;
;*****	Memory Map
;
;	Atari XL 64K
;
;	Computer's Hardware Stack												($0100 to $01FF)
;	IOCB's (input/output control blocks) and miscellaneous OS variables		($0200 to $03BF)
;	Printer buffer															($03C0 to $03E7)   
;	Reserved for OS															($03E8 to $03FC)
;	Cassette buffer															($03FD to $047F)	 83 bytes available  
;	Reserved for use by BASIC cartridge										($0480 to $057D) 	254 bytes available 
;	OS floating point package.												($057E to $05FF)	 82 bytes available 
;	Page 6																	($0600 to $06FF)
;	DOS Dedicated RAM														($0700 to MEMLO)
;	Free Ram																(MEMLO to MEMTOP)
;	Screen Memory															(Above MEMTOP) 	 
;   Cartrige A & B Slots													($8000 to $BFFF)	16K available
;   Os Rom in newer models													($C000 to $CFFF)	 
;	Hardware Registers														($D000 to $D7FF)
;	Floating Point Rom														($D800 to $DFFF)	 2K available
;	Operating system														($E000 to $FFFF)

;*****	Include Files
;
		icl "Lib/Atari_Equates.Asm"
		icl "Lib/sys_macros.asm"	

;***** Memory Allocation
; 				
ZeroPageAddr				= $80				; Address for the zero page variables
CodeAddr					= $2000				; Address for the main code

GameDispList			= $0600				; Address for the custom display list
HUDAddress					= $06B0				; Address for the heads up display (HUD)

DataAddr					= $8800				; 2K data area
PmgAddr						= $9000				; 40K (2K size - 768 bytes)
GameFontAddr				= $9800				; 42K (1K size)
TextFontAddr				= $9C00				; 39K (1K size)
 
GameScreenAddr				= $A000				; Address for the game screen data 

;*****	Zero Page Variables
;
		org ZeroPageAddr

;*****	Byte variables		
m_saveRegA					org *+$01
m_saveRegX					org *+$01
m_saveRegY					org *+$01

m_dliSaveA					org *+$01
m_dliSaveX					org *+$01
m_dliSaveY					org *+$01

_param01					org *+$01
_param02					org *+$01
_param03					org *+$01
_param04					org *+$01
_param05					org *+$01
_param06					org *+$01
_param07					org *+$01

_missleBaseColor0			org *+$01
mm_playerBaseColor			org *+$01
mm_playerBaseColor1A			org *+$01
mm_playerBaseColor1B			org *+$01

m_playerLevelLeftX_H2		org *+$01			; left side coordinate
m_playerLevelLeftX_H1		org *+$01
m_playerLevelLeftX_L1		org *+$01

m_playerLevelRightX_H2		org *+$01			; right side coordinate
m_playerLevelRightX_H1		org *+$01
m_playerLevelRightX_L1		org *+$01

m_playerLevelTopY_H2			org *+$01			; top line coordinate
m_playerLevelTopY_H1			org *+$01
m_playerLevelTopY_L1			org *+$01

m_playerLevelBottomY_H2		org *+$01			; bottom line coordinate
m_playerLevelBottomY_H1		org *+$01
m_playerLevelBottomY_L1		org *+$01

m_redrawPlayerCounter		org *+$01

m_playerScreenLeftX			org *+$01
m_playerScreenTopY			org *+$01

m_oldPlayerScreenLeftX		org *+$01
m_oldPlayerScreenTopY		org *+$01

m_playerSizeX				org *+$01
m_playerSizeY				org *+$01

m_playerSizeXMinusOne		org *+$01
m_playerSizeYMinusOne		org *+$01

m_playerSideSpeed_H1			org *+$01
m_playerSideSpeed_L1			org *+$01

m_playerMaxSideSpeed_H1		org *+$01
m_playerMaxSideSpeed_L1		org *+$01

m_playerSideAccel_H1			org *+$01
m_playerSideAccel_L1			org *+$01

m_playerSideDeaccel_H1		org *+$01
m_playerSideDeaccel_L1		org *+$01

m_playerSpeedY_H1			org *+$01
m_playerSpeedY_L1			org *+$01

m_playerJumpSpeed_H1			org *+$01
m_playerJumpSpeed_L1			org *+$01

m_playerMaxFallSpeed_H1		org *+$01
m_playerMaxFallSpeed_L1		org *+$01

m_playerGravityAccel_H1		org *+$01
m_playerGravityAccel_L1		org *+$01

m_playerWaterAccelY_H1		org *+$01
m_playerWaterAccelY_L1		org *+$01

m_playerMaxWaterSpeedY_H1	org *+$01
m_playerMaxWaterSpeedY_L1	org *+$01

m_playerMoveWaterSpeedY_H1	org *+$01
m_playerMoveWaterSpeedY_L1	org *+$01

m_playerNoJumpTimer			org *+$01			; for now this is used to disable the jump for some frames, after entering the water
m_playerHoldJumpCounter		org *+$01

m_lastPlayerSideDirection	org *+$01			; 0 - none, 1 - right, 2 - left
m_lastPlayerShootDirection	org *+$01

m_playerOverPlatformFlag		org *+$01			; is player over platform
m_playerTopCollisionFlag		org *+$01			; did player hit top
m_playerSideCollisionFlag	org *+$01			; did player hit side

m_playerState				org *+$01			; 0-static, 1-over platform, 2-jumping up, 3-falling, 4-climbing, 5-in water, 6-gravity test

m_pageZeroTempValue			org *+$01

m_levelCharSizeX				org *+$01			; char size X goes from 1 to 255 characters, 0 = 256 characters
m_levelCharSizeY				org *+$01			; char size Y goes from 1 to 255 characters, 0 = 256 characters

m_levelSizeX_H2				org *+$01
m_levelSizeX_H1				org *+$01

m_levelSizeY_H2				org *+$01
m_levelSizeY_H1				org *+$01

m_levelWindowX_H2			org *+$01
m_levelWindowX_H1			org *+$01

m_levelWindowY_H2			org *+$01
m_levelWindowY_H1			org *+$01

m_stick0						org *+$01
m_oldStick0					org *+$01
m_oldTrigger0				org *+$01
m_triggerState				org *+$01			; 0 - not pressed, 1 - just released, 2 - just pressed, 3 - pressed
m_currentTrigger0			org *+$01

;***** 	Word variables
m_ptrLevelAddr				org *+$02
m_ptrLevelLine				org *+$02
m_currentLineAddress			org *+$02
m_pageZeroTempPointer		org *+$02
m_playerMethodPointer		org *+$02

.PRINT "Zero Page Start : ", ZeroPageAddr, " Zero Page Length : ", * - ZeroPageAddr
		
;***** 	Set the constant values for the registers below
;
GRACTL_OPTIONS				= ENABLE_MISSILES | ENABLE_PLAYERS
PRIOR_OPTIONS				= PM_PRIORITY_1   | FIFTH_PLAYER        | MULTICOLOR_PM	
DMACTL_OPTIONS				= ENABLE_DL_DMA   | PM_1LINE_RESOLUTION | PLAYFIELD_WIDTH_NORMAL_MASK 

;*****	Scrolling and Screen sizes
;
MAX_ROWS					= 40

PLR_WIDTH					= 8
PLR_HEIGHT					= 21

CHAR_PIXELS_X				= 4
CHAR_PIXELS_Y				= 8
				
LEVEL_CHAR_SIZE_X			= 42				; Tiles X - 82 of them horizontal
LEVEL_CHAR_SIZE_Y			= 24				; Lines Y - 48 of them vertical

WINDOW_CHAR_SIZE_X			= 40				; Chars X - 40 of them horizontal
WINDOW_CHAR_SIZE_Y			= 24				; Chars Y - 24 of them vertical

PM_BASE_SCREEN_X			= 48				; starting pixel for the left
PM_BASE_SCREEN_Y			= 32				; starting pixel for the top

PSD_NONE					= 0					; player side direction
PSD_RIGHT					= 1
PSD_LEFT					= 2

PS_STATIC					= 0					; player states
PS_OVER_PLATFORM			= 1
PS_JUMPING					= 2
PS_FALLING					= 3
PS_CLIMBING					= 4
PS_IN_WATER					= 5
PS_GRAVITY_TEST				= 6
PS_LOSE						= 7

CT_BLANK					= 0					; character types
CT_BLOCK					= 1
CT_COLLECTABLE				= 2
CT_DANGER					= 3
CT_LADDER					= 4
CT_WATER					= 5
CT_FLOATPLATFORM			= 1

TS_NOT_PRESSED				= 0					; trigger states
TS_JUST_RELEASED			= 0
TS_PRESSED					= 0
TS_JUST_PRESSED				= 0

ENEMY_SHOOT_DELTA_Y			= 32

.if PAL_VERSION = 0

	TENTH_OF_SECOND_FRAMES	= 6
	MINIMUM_CAMERA_STEP		= 1
	JUMP_HOLD_FRAMES		= 8
	JUMP_HSPEED_SLOWDOWN	= 64
	WATER_NO_JUMP_FRAMES	= 30

	SIDE_SPEED_LAND_H1		= 1					; 001.160 --> 97.5 pixels per second (at 60 fps only!)
	SIDE_SPEED_LAND_L1		= 2	;64
	
	SIDE_ACCEL_LAND_H1		= 0					; 6 frames (at 60 fps only!) or 0.x seconds, to reach max speed
	SIDE_ACCEL_LAND_L1		= 32
	
	SIDE_DEACCEL_LAND_H1	= 0					; 3 frames (at 60 fps only!) or 0.x seconds, to reach zero speed
	SIDE_DEACCEL_LAND_L1	= 128

	SIDE_SPEED_WATER_H1		= 0
	SIDE_SPEED_WATER_L1		= 128

	SIDE_ACCEL_WATER_H1		= 0					; _ frames (at 60 fps only!) or _ seconds, to reach max speed
	SIDE_ACCEL_WATER_L1		= 4

	SIDE_DEACCEL_WATER_H1	= 0					; _ frames (at 60 fps only!) or _ seconds, to reach zero speed
	SIDE_DEACCEL_WATER_L1	= 4

	SIDE_SPEED_AIR_H1		= 1					; 001.120 --> 88.125 pixels per second (at 60 fps only!)
	SIDE_SPEED_AIR_L1		= 32

	SIDE_ACCEL_AIR_H1		= 0					; 17.3 frames (at 60 fps only!) or 0.288 seconds, to reach max speed
	SIDE_ACCEL_AIR_L1		= 16

	SIDE_DEACCEL_AIR_H1		= 0					; 17.3 frames (at 60 fps only!) or 0.288 seconds, to reach zero speed
	SIDE_DEACCEL_AIR_L1		= 16

	CLIMB_UP_SPEED_Y_H1		= 0
	CLIMB_UP_SPEED_Y_L1		= 224

	CLIMB_DOWN_SPEED_Y_H1	= 1
	CLIMB_DOWN_SPEED_Y_L1	= 128

	PLAYER_MISSILE_SPEED_X	= 2*256+128
	ENEMY_MISSILE_SPEED_X	= 2*256
	ENEMY_INIT_TIMER		= 120
	VLASER_DISABLED_INDEX	= 60

.else

	TENTH_OF_SECOND_FRAMES	= 5
	MINIMUM_CAMERA_STEP		= 1
	JUMP_HOLD_FRAMES		= 6					; 6.67 for pal
	JUMP_HSPEED_SLOWDOWN	= 77
	WATER_NO_JUMP_FRAMES	= 25

	SIDE_SPEED_LAND_H1		= 1					;  pixels per second (at 50 fps only!)
	SIDE_SPEED_LAND_L1		= 128

	SIDE_ACCEL_LAND_H1		= 0					;  frames (at 50 fps only!) or 0.x seconds, to reach max speed
	SIDE_ACCEL_LAND_L1		= 38

	SIDE_DEACCEL_LAND_H1	= 0					;  frames (at 50 fps only!) or 0.x seconds, to reach zero speed
	SIDE_DEACCEL_LAND_L1	= 154

	SIDE_SPEED_WATER_H1		= 0
	SIDE_SPEED_WATER_L1		= 154

	SIDE_ACCEL_WATER_H1		= 0					; _ frames (at 50 fps only!) or _ seconds, to reach max speed
	SIDE_ACCEL_WATER_L1		= 5

	SIDE_DEACCEL_WATER_H1	= 0					; _ frames (at 50 fps only!) or _ seconds, to reach zero speed
	SIDE_DEACCEL_WATER_L1	= 5

	SIDE_SPEED_AIR_H1		= 1					;  pixels per second (at 50 fps only!)
	SIDE_SPEED_AIR_L1		= 90
	
	SIDE_ACCEL_AIR_H1		= 0					;  frames (at 50 fps only!) or  seconds, to reach max speed
	SIDE_ACCEL_AIR_L1		= 19

	SIDE_DEACCEL_AIR_H1		= 0					;  frames (at 50 fps only!) or  seconds, to reach zero speed
	SIDE_DEACCEL_AIR_L1		= 19

	CLIMB_UP_SPEED_Y_H1		= 1
	CLIMB_UP_SPEED_Y_L1		= 13

	CLIMB_DOWN_SPEED_Y_H1	= 1
	CLIMB_DOWN_SPEED_Y_L1	= 205

	PLAYER_MISSILE_SPEED_X	= 3*256
	ENEMY_MISSILE_SPEED_X	= 2*256+104
	ENEMY_INIT_TIMER		= 100
	VLASER_DISABLED_INDEX	= 50

.endif

;****	Player missle address definitions
;
ms_area_1 					= PmgAddr 	+ $0300
p0_area_1 					= ms_area_1 + $0100
p1_area_1 					= p0_area_1 + $0100
p2_area_1 					= p1_area_1 + $0100
p3_area_1 					= p2_area_1 + $0100

;	
;**************************************************************************************************
; System Entry Point
;**************************************************************************************************
;
		org CodeAddr
		
StartSystem
		
		ClearSystem								; initialize all registers
		DisableBasic							; disable basic
		DisableOperatingSystem					; disable the operating system 

		SetRamTop 16							; drop ramtop by 16 pages
	
		SetDisplayListInterrupt GameDli_01		; set the DLI's
		VcountWait 120							; Wait on a frame

		lda #0									; set the player info
		sta SIZEP0

		lda #MISSILES_BITS						; double width for all missiles
		sta SIZEM

		lda #12									; 0 to 16 color clocks
		sta HSCROL
	
		lda #0									; 0 to 16 color clocks
		sta VSCROL

		SetPMBaseAddress PmgAddr				; Set the player missile address
		SetFontAddress GameFontAddr				; Set the initial font
		
		SetDisplayListAddress GameDispList	; Set the games display list	

		lda #$80								; enable DLI's (but no VBI's)
		sta NMIEN
		    
		lda #GRACTL_OPTIONS						; Enable/Disable Player/Missile DMA to GRAFxx registers. And latch triggers.
		sta GRACTL

		lda #PRIOR_OPTIONS						; Control Priority, Fifth Player and GTIA modes
		sta PRIOR

		lda #DMACTL_OPTIONS						; DMA control for display and Player/Missile graphics
		sta DMACTL

		VcountWait 120							; wait on a frame again

		jsr InitVars							; initialize the game variables
		jsr InitLevelTable						; initialize the screen address tables

		lda #$10
		sta _activeEnemies

;***** GameLoop 
;
GameLoop
	
		jsr UpdateInfoLine						; Update the HUD area

		lda #0									; Value to clear any hits 
		sta HITCLR								; Clear them

		VcountWait 120							; wait for the RTCLOCK to change

		jmp GameLoop							; Do it all over again

;
;**************************************************************************************************
; InitVars
;**************************************************************************************************
;
.proc InitVars
	
		lda #1									; input info
		sta m_oldTrigger0
		sta m_currentTrigger0

		lda #0
		sta m_triggerState

		lda #15
		sta m_stick0
		sta m_oldStick0
		
		lda #>[CHAR_PIXELS_X]					; level info
		sta m_levelWindowX_H2
		
		lda #<[CHAR_PIXELS_X]
		sta m_levelWindowX_H1
		
		lda #0
		sta m_levelWindowY_H2
		
		lda #0
		sta m_levelWindowY_H1

		lda #LEVEL_CHAR_SIZE_X
		sta m_levelCharSizeX
		
		lda #LEVEL_CHAR_SIZE_Y
		sta m_levelCharSizeY

		lda #>[LEVEL_CHAR_SIZE_X*CHAR_PIXELS_X]
		sta m_levelSizeX_H2
		
		lda #<[LEVEL_CHAR_SIZE_X*CHAR_PIXELS_X]
		sta m_levelSizeX_H1

		lda #>[LEVEL_CHAR_SIZE_Y*CHAR_PIXELS_Y]
		sta m_levelSizeY_H2
		
		lda #<[LEVEL_CHAR_SIZE_Y*CHAR_PIXELS_Y]
		sta m_levelSizeY_H1

		lda #<GameScreenAddr
		sta m_currentLineAddress
		
		lda #>GameScreenAddr
		sta m_currentLineAddress+1
		
		;	
		;************************************************
		;
		; player info
		;
		; 	remember that we don't use any speed over 1 char per frame right now,
		; 	because we don't want to lose collisions (in that case we should
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
	
		ldx #PLR_WIDTH							; set width of player
		stx m_playerSizeX
		dex
		stx m_playerSizeXMinusOne				; used in detection methods
	
		ldx #PLR_HEIGHT							; set height of player
		stx m_playerSizeY
		dex
		stx m_playerSizeYMinusOne				; used in detection methods
	
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
		sta m_playerOverPlatformFlag
		sta m_playerTopCollisionFlag
		sta m_playerSideCollisionFlag
		sta m_playerHoldJumpCounter
		sta m_playerNoJumpTimer

;		ldx #PS_OVER_PLATFORM					; (TBO) turn this back on when player base is implemented
;		jsr SetPlayerMethod						; (TBO) turn this back on when player base is implemented

		lda #0
		sta m_redrawPlayerCounter

		lda #0
		sta m_playerSideSpeed_H1
		sta m_playerSideSpeed_L1

		lda #PSD_RIGHT	
		sta m_lastPlayerSideDirection
		sta m_lastPlayerShootDirection

		; set spawn position
		lda #0
		sta m_playerLevelLeftX_H2
		
		lda #16
		sta m_playerLevelLeftX_H1
		
		lda #0
		sta m_playerLevelLeftX_L1				; fractional part

		lda #0
		sta m_playerLevelBottomY_H2
		
		lda #$4F
		sta m_playerLevelBottomY_H1
		
		lda #0
		sta m_playerLevelBottomY_L1				; fractional part

		lda #0
		sta m_playerLevelTopY_L1					; fractional part (not used)
		sta m_playerLevelRightX_L1				; fractional part (not used)

;		jsr SetPlayerInfo						; (TBO) turn this back on when player base is implemented	
		
		rts

.endp		

;
;**************************************************************************************************
; InitLevelTable
;**************************************************************************************************
;
.proc InitLevelTable
		
		ldy #0									; set  the indexer to zero

;************************************************
;
Addr_Loop

		lda m_currentLineAddress							
		sta TabLevelLineAddressLSB,y
		
		lda m_currentLineAddress+1
		sta TabLevelLineAddressMSB,y

		lda m_levelCharSizeX
		bne Char_Below_256

		inc m_currentLineAddress+1				; if m_levelCharSizeX = 0, then add 256 chars
		jmp Addr_Check_Loop

;************************************************
;
Char_Below_256

		clc
		adc m_currentLineAddress					; from 1 to 255 chars
		sta m_currentLineAddress

		lda m_currentLineAddress+1
		adc #0
		sta m_currentLineAddress+1

;************************************************
;
Addr_Check_Loop

		iny
		cpy m_levelCharSizeY						; from 1 to 255 lines, 0 = 256 lines in this case
		bne Addr_Loop
	
		lda m_currentLineAddress					; add one more line definition to fix problem of ladders in the last line
		sta TabLevelLineAddressLSB,y			; but this is not going to work if there are 256 lines!
	
		lda m_currentLineAddress+1				
		sta TabLevelLineAddressMSB,y
	
		rts
		
.endp	

;
;**************************************************************************************************
; UpdateInfoLine
;**************************************************************************************************
;
.proc UpdateInfoLine
	
		lda _goldCounter						; assuming 99 or less
		ldy #4
		jsr DisplayDebugInfoBinary99

		lda _activeEnemies
		ldy #12
		jsr DisplayDebugInfoBinary99

		lda _goldCounter
		bne UIL_update_timer
		
		lda _activeEnemies
		bne UIL_update_timer
	
		lda _disableGameTimer					; update the time here also
		bne UIL_exit
	
		lda #1
		sta _disableGameTimer					; my record? 1:16.1 (NTSC, lost one life)

;************************************************
; allow the final update..
;
UIL_update_timer
	
		inc _gameTSFrameCounter
		lda _gameTSFrameCounter
		cmp #TENTH_OF_SECOND_FRAMES
		bne UIL_draw_timer
	
		lda #0
		sta _gameTSFrameCounter
		inc _gameTimerTSeconds
		
		lda _gameTimerTSeconds
		cmp #10
		bne UIL_draw_timer
	
		lda #0
		sta _gameTimerTSeconds
		inc _gameTimerSeconds
	
		lda _gameTimerSeconds
		cmp #60
		bne UIL_draw_timer
	
		lda #0
		sta _gameTimerSeconds
		inc _gameTimerMinutes

		lda _gameTimerMinutes
		cmp #100
		bne UIL_draw_timer
	
		lda #1
		sta _disableGameTimer
		jmp UIL_exit							; final timer would be 99:99.9 in this case

;************************************************
;
UIL_draw_timer
	
		lda _gameTimerMinutes
		ldy #20
		jsr DisplayDebugInfoBinary99
	
		lda _gameTimerSeconds
		ldy #23
		jsr DisplayDebugInfoBinary99
	
		lda _gameTimerTSeconds
		ldy #26
		jsr DisplayDebugInfoBinary9

;************************************************
;
UIL_exit
		
		rts
	
.endp				

;	
;**************************************************************************************************
; Include Files  
;**************************************************************************************************
;
		icl "Lib/sys_procs.asm"
		icl "DispListInterrupts.Asm"

;
;**************************************************************************************************
; Data definition
;**************************************************************************************************
;
		org DataAddr
		icl "ScrollerData.Asm"

;	
;**************************************************************************************************
; Display List for the game
;**************************************************************************************************
;
		org GameDispList

		.byte DL_BLANK_8
		.byte DL_BLANK_8
		.byte DL_BLANK_8 + DL_DLI

DL1_LMS1
		
		?dldata = GameScreenAddr
		.rept 24
			.byte DL_TEXT_4 + DL_LMS + DL_HSCROLL + DL_VSCROLL
			.byte <?dldata, >?dldata
			?dldata += LEVEL_CHAR_SIZE_X
		.endr
	
		.byte DL_TEXT_4 + DL_LMS + DL_HSCROLL
		.byte <?dldata, >?dldata
	
		.byte DL_BLANK_3 + DL_DLI

		?dldata = HudAddress
		.rept 2
			.byte DL_TEXT_2 + DL_LMS
			.byte <?dldata, >?dldata
			?dldata += WINDOW_CHAR_SIZE_X
		.endr	
	
		.byte DL_JUMP_VB, <GameDispList, >GameDispList

;	
;**************************************************************************************************
; HUD Address	
;**************************************************************************************************
;
		org HudAddress							

		; two rows of 40 characters for text mode
.if PAL_VERSION = 0
		.sb "  G 00    E 00    T 00:00.0       NTSC  "
.else
		.sb "  G 00    E 00    T 00:00.0        PAL  "
.endif
		.sb "                                        "

;	
;**************************************************************************************************
; Player Missle Address  
;**************************************************************************************************
;
		org PmgAddr
		
		; clear the 2K area for player/missiles
		.rept $0800
			.byte $00
		.endr		

;	
;**************************************************************************************************
; Font Include 
;**************************************************************************************************
;
		org GameFontAddr
		ins "Data/scroller.fnt"
		
		org TextFontAddr
		ins "Data/atari.fnt"		

;	
;**************************************************************************************************
; Game screen address - initializes the screen memory and clears it 
;**************************************************************************************************
;
		org GameScreenAddr
		
		; allocate 4K for the game screen
		.rept $1000
			.byte $00
		.endr			
		
		; extra line to help with hazards and ladders and etc....
		:LEVEL_CHAR_SIZE_X 		.byte $61

;		
;**************************************************************************************************
; Run Address
;**************************************************************************************************
;
		run StartSystem
