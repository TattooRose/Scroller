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
CodeAddr					= $0700				; Address for the main code

GameDispListAddr			= $0600				; Address for the custom display list
HUDAddress					= $06B0				; Address for the heads up display (HUD)

PmgAddr						= $9000				; 40K (2K size - 768 bytes)
GameFontAddr				= $9800				; 42K (1K size)
TextFontAddr				= $9C00				; 39K (1K size)
 
GameScreenAddr				= $A000				; Address for the game screen data 

;*****	Zero Page Variables
;
		org ZeroPageAddr

;*****	Byte variables		
_saveRegA					org *+$01
_saveRegX					org *+$01
_saveRegY					org *+$01

_dliSaveA					org *+$01
_dliSaveX					org *+$01
_dliSaveY					org *+$01

_param01					org *+$01
_param02					org *+$01
_param03					org *+$01
_param04					org *+$01
_param05					org *+$01
_param06					org *+$01
_param07					org *+$01

_missleBaseColor0			org *+$01
_playerBaseColor			org *+$01
_playerBaseColor1A			org *+$01
_playerBaseColor1B			org *+$01

_playerLevelLeftX_H2		org *+$01			; left side coordinate
_playerLevelLeftX_H1		org *+$01
_playerLevelLeftX_L1		org *+$01

_playerLevelRightX_H2		org *+$01			; right side coordinate
_playerLevelRightX_H1		org *+$01
_playerLevelRightX_L1		org *+$01

_playerLevelTopY_H2			org *+$01			; top line coordinate
_playerLevelTopY_H1			org *+$01
_playerLevelTopY_L1			org *+$01

_playerLevelBottomY_H2		org *+$01			; bottom line coordinate
_playerLevelBottomY_H1		org *+$01
_playerLevelBottomY_L1		org *+$01

_redrawPlayerCounter		org *+$01

_playerScreenLeftX			org *+$01
_playerScreenTopY			org *+$01

_oldPlayerScreenLeftX		org *+$01
_oldPlayerScreenTopY		org *+$01

_playerSizeX				org *+$01
_playerSizeY				org *+$01

_playerSizeXMinusOne		org *+$01
_playerSizeYMinusOne		org *+$01

_playerSideSpeed_H1			org *+$01
_playerSideSpeed_L1			org *+$01

_playerMaxSideSpeed_H1		org *+$01
_playerMaxSideSpeed_L1		org *+$01

_playerSideAccel_H1			org *+$01
_playerSideAccel_L1			org *+$01

_playerSideDeaccel_H1		org *+$01
_playerSideDeaccel_L1		org *+$01

_playerSpeedY_H1			org *+$01
_playerSpeedY_L1			org *+$01

_playerJumpSpeed_H1			org *+$01
_playerJumpSpeed_L1			org *+$01

_playerMaxFallSpeed_H1		org *+$01
_playerMaxFallSpeed_L1		org *+$01

_playerGravityAccel_H1		org *+$01
_playerGravityAccel_L1		org *+$01

_playerWaterAccelY_H1		org *+$01
_playerWaterAccelY_L1		org *+$01

_playerMaxWaterSpeedY_H1	org *+$01
_playerMaxWaterSpeedY_L1	org *+$01

_playerMoveWaterSpeedY_H1	org *+$01
_playerMoveWaterSpeedY_L1	org *+$01

_playerNoJumpTimer			org *+$01			; for now this is used to disable the jump for some frames, after entering the water
_playerHoldJumpCounter		org *+$01

_lastPlayerSideDirection	org *+$01			; 0 - none, 1 - right, 2 - left
_lastPlayerShootDirection	org *+$01

_playerOverPlatformFlag		org *+$01			; is player over platform
_playerTopCollisionFlag		org *+$01			; did player hit top
_playerSideCollisionFlag	org *+$01			; did player hit side

_playerState				org *+$01			; 0-static, 1-over platform, 2-jumping up, 3-falling, 4-climbing, 5-in water, 6-gravity test

_pageZeroTempValue			org *+$01

_levelCharSizeX				org *+$01			; char size X goes from 1 to 255 characters, 0 = 256 characters
_levelCharSizeY				org *+$01			; char size Y goes from 1 to 255 characters, 0 = 256 characters

_levelSizeX_H2				org *+$01
_levelSizeX_H1				org *+$01

_levelSizeY_H2				org *+$01
_levelSizeY_H1				org *+$01

_levelWindowX_H2			org *+$01
_levelWindowX_H1			org *+$01

_levelWindowY_H2			org *+$01
_levelWindowY_H1			org *+$01

_stick0						org *+$01
_oldStick0					org *+$01
_oldTrigger0				org *+$01
_triggerState				org *+$01			; 0 - not pressed, 1 - just released, 2 - just pressed, 3 - pressed
_currentTrigger0			org *+$01

;***** 	Word variables
_ptrLevelAddr				org *+$02
_ptrLevelLine				org *+$02
_currentLineAddress			org *+$02
_pageZeroTempPointer		org *+$02
_playerMethodPointer		org *+$02

.PRINT "Zero Page Start : ", ZeroPageAddr, " Zero Page Length : ", * - ZeroPageAddr
		
;*****	Constants
;
;PAL_VERSION				= 1

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
				
LEVEL_CHAR_SIZE_X			= 82				; Tiles X - 82 of them horizontal
LEVEL_CHAR_SIZE_Y			= 48				; Lines Y - 48 of them vertical

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

.ifndef PAL_VERSION

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
		
		SetDisplayListAddress GameDispListAddr	; Set the games display list	

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
		sta m_activeEnemies

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
		sta _oldTrigger0
		sta _currentTrigger0

		lda #0
		sta _triggerState

		lda #15
		sta _stick0
		sta _oldStick0
		
		lda #>[CHAR_PIXELS_X]					; level info
		sta _levelWindowX_H2
		
		lda #<[CHAR_PIXELS_X]
		sta _levelWindowX_H1
		
		lda #0
		sta _levelWindowY_H2
		
		lda #0
		sta _levelWindowY_H1

		lda #LEVEL_CHAR_SIZE_X
		sta _levelCharSizeX
		
		lda #LEVEL_CHAR_SIZE_Y
		sta _levelCharSizeY

		lda #>[LEVEL_CHAR_SIZE_X*CHAR_PIXELS_X]
		sta _levelSizeX_H2
		
		lda #<[LEVEL_CHAR_SIZE_X*CHAR_PIXELS_X]
		sta _levelSizeX_H1

		lda #>[LEVEL_CHAR_SIZE_Y*CHAR_PIXELS_Y]
		sta _levelSizeY_H2
		
		lda #<[LEVEL_CHAR_SIZE_Y*CHAR_PIXELS_Y]
		sta _levelSizeY_H1

		lda #<GameScreenAddr
		sta _currentLineAddress
		
		lda #>GameScreenAddr
		sta _currentLineAddress+1
		
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

.ifndef PAL_VERSION
	
		lda #3									; air vertical movement 240 pixels per second (at 60 fps only!)
		sta _playerJumpSpeed_H1
		
		lda #128
		sta _playerJumpSpeed_L1

		lda #6									; near 400 pixels per second (1 character per frame at 50 fps, PAL friendly)
		sta _playerMaxFallSpeed_H1
	
		lda #170
		sta _playerMaxFallSpeed_L1

		lda #0									; 12.8 frames (at 60 fps only!) to reach max speed (from zero)
		sta _playerGravityAccel_H1
	
		lda #112
		sta _playerGravityAccel_L1

		
		lda #0									; water vertical movement
		sta _playerWaterAccelY_H1
		
		lda #32
		sta _playerWaterAccelY_L1

		lda #0
		sta _playerMaxWaterSpeedY_H1
	
		lda #128
		sta _playerMaxWaterSpeedY_L1

		lda #1
		sta _playerMoveWaterSpeedY_H1
	
		lda #0
		sta _playerMoveWaterSpeedY_L1

.else

		lda #4									; air vertical movement pixels per second (at 50 fps only!)
		sta _playerJumpSpeed_H1
	
		lda #51
		sta _playerJumpSpeed_L1

		lda #7									; near 400 pixels per second (1 character per frame at 50 fps, PAL friendly)
		sta _playerMaxFallSpeed_H1
	
		lda #255
		sta _playerMaxFallSpeed_L1

		lda #0									;  frames (at 50 fps only!) to reach max speed (from zero)
		sta _playerGravityAccel_H1
		
		lda #134
		sta _playerGravityAccel_L1

		lda #0									; water vertical movement
		sta _playerWaterAccelY_H1
		
		lda #38
		sta _playerWaterAccelY_L1

		lda #0
		sta _playerMaxWaterSpeedY_H1
	
		lda #154
		sta _playerMaxWaterSpeedY_L1

		lda #1
		sta _playerMoveWaterSpeedY_H1
	
		lda #51
		sta _playerMoveWaterSpeedY_L1

.endif
	
		ldx #PLR_WIDTH							; set width of player
		stx _playerSizeX
		dex
		stx _playerSizeXMinusOne				; used in detection methods
	
		ldx #PLR_HEIGHT							; set height of player
		stx _playerSizeY
		dex
		stx _playerSizeYMinusOne				; used in detection methods
	
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
		sta _playerOverPlatformFlag
		sta _playerTopCollisionFlag
		sta _playerSideCollisionFlag
		sta _playerHoldJumpCounter
		sta _playerNoJumpTimer

;		ldx #PS_OVER_PLATFORM					; (TBO) turn this back on when player base is implemented
;		jsr SetPlayerMethod						; (TBO) turn this back on when player base is implemented

		lda #0
		sta _redrawPlayerCounter

		lda #0
		sta _playerSideSpeed_H1
		sta _playerSideSpeed_L1

		lda #PSD_RIGHT	
		sta _lastPlayerSideDirection
		sta _lastPlayerShootDirection

		; set spawn position
		lda #0
		sta _playerLevelLeftX_H2
		
		lda #16
		sta _playerLevelLeftX_H1
		
		lda #0
		sta _playerLevelLeftX_L1				; fractional part

		lda #0
		sta _playerLevelBottomY_H2
		
		lda #$4F
		sta _playerLevelBottomY_H1
		
		lda #0
		sta _playerLevelBottomY_L1				; fractional part

		lda #0
		sta _playerLevelTopY_L1					; fractional part (not used)
		sta _playerLevelRightX_L1				; fractional part (not used)

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

		lda _currentLineAddress							
		sta TabLevelLineAddressLSB,y
		
		lda _currentLineAddress+1
		sta TabLevelLineAddressMSB,y

		lda _levelCharSizeX
		bne Char_Below_256

		inc _currentLineAddress+1				; if m_levelCharSizeX = 0, then add 256 chars
		jmp Addr_Check_Loop

;************************************************
;
Char_Below_256

		clc
		adc _currentLineAddress					; from 1 to 255 chars
		sta _currentLineAddress

		lda _currentLineAddress+1
		adc #0
		sta _currentLineAddress+1

;************************************************
;
Addr_Check_Loop

		iny
		cpy _levelCharSizeY						; from 1 to 255 lines, 0 = 256 lines in this case
		bne Addr_Loop
	
		lda _currentLineAddress					; add one more line definition to fix problem of ladders in the last line
		sta TabLevelLineAddressLSB,y			; but this is not going to work if there are 256 lines!
	
		lda _currentLineAddress+1				
		sta TabLevelLineAddressMSB,y
	
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

		lda m_goldCounter
		bne UIL_update_timer
		
		lda m_activeEnemies
		bne UIL_update_timer
	
		lda m_disableGameTimer					; update the time here also
		bne UIL_exit
	
		lda #1
		sta m_disableGameTimer					; my record? 1:16.1 (NTSC, lost one life)

;************************************************
; allow the final update..
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

;************************************************
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

;************************************************
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
		icl "ScrollerData.Asm"
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
; Display List for the game
;**************************************************************************************************
;
		org GameDispListAddr

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
	
		.byte DL_JUMP_VB, <GameDispListAddr, >GameDispListAddr

;	
;**************************************************************************************************
; HUD Address	
;**************************************************************************************************
;
		org HudAddress							

		; two rows of 40 characters for text mode
.ifndef PAL_VERSION
		.sb "  G 00    E 00    T 00:00.0       NTSC  "
.else
		.sb "  G 00    E 00    T 00:00.0        PAL  "
.endif
		.sb "                                        "

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
