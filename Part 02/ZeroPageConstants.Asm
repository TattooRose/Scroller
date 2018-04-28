;*****	Zero Page Variables
;
		org ZeroPageAddr

;*****	Byte variables		
_param00					org *+$01
_param01					org *+$01
_param02					org *+$01
_param03					org *+$01
_param04					org *+$01
_param05					org *+$01
_param06					org *+$01
_param07					org *+$01

_paramW01					org *+$02
_paramW02					org *+$02
_paramW03					org *+$02
_paramW04					org *+$02
_cameraLabel				org *+$02

m_saveRegA					org *+$01
m_saveRegX					org *+$01
m_saveRegY					org *+$01

m_dliSaveA					org *+$01
m_dliSaveX					org *+$01
m_dliSaveY					org *+$01

m_missleBaseColor00			org *+$01
m_playerBaseColor00			org *+$01
m_playerBaseColor01			org *+$01
m_playerBaseColor02			org *+$01
m_playerBaseColor03			org *+$01

m_playerLevelLeftX_H2		org *+$01			; left side coordinate
m_playerLevelLeftX_H1		org *+$01
m_playerLevelLeftX_L1		org *+$01

m_playerLevelRightX_H2		org *+$01			; right side coordinate
m_playerLevelRightX_H1		org *+$01
m_playerLevelRightX_L1		org *+$01

m_playerLevelTopY_H2		org *+$01			; top line coordinate
m_playerLevelTopY_H1		org *+$01
m_playerLevelTopY_L1		org *+$01

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

m_playerSideSpeed_H1		org *+$01
m_playerSideSpeed_L1		org *+$01

m_playerMaxSideSpeed_H1		org *+$01
m_playerMaxSideSpeed_L1		org *+$01

m_playerSideAccel_H1		org *+$01
m_playerSideAccel_L1		org *+$01

m_playerSideDeaccel_H1		org *+$01
m_playerSideDeaccel_L1		org *+$01

m_playerSpeedY_H1			org *+$01
m_playerSpeedY_L1			org *+$01

m_playerJumpSpeed_H1		org *+$01
m_playerJumpSpeed_L1		org *+$01

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

m_playerOverPlatformFlag	org *+$01			; is player over platform
m_playerTopCollisionFlag	org *+$01			; did player hit top
m_playerSideCollisionFlag	org *+$01			; did player hit side

m_playerState				org *+$01			; 0-static, 1-over platform, 2-jumping up, 3-falling, 4-climbing, 5-in water, 6-gravity test

m_pageZeroTempValue			org *+$01

m_levelCharSizeX			org *+$01			; char size X goes from 1 to 255 characters, 0 = 256 characters
m_levelCharSizeY			org *+$01			; char size Y goes from 1 to 255 characters, 0 = 256 characters

m_levelSizeX_H2				org *+$01
m_levelSizeX_H1				org *+$01

m_levelSizeY_H2				org *+$01
m_levelSizeY_H1				org *+$01

m_levelWindowX_H2			org *+$01
m_levelWindowX_H1			org *+$01

m_levelWindowY_H2			org *+$01
m_levelWindowY_H1			org *+$01

m_stick0					org *+$01
m_oldStick0					org *+$01
m_oldTrigger0				org *+$01
m_triggerState				org *+$01			; 0 - not pressed, 1 - just released, 2 - just pressed, 3 - pressed
m_currentTrigger0			org *+$01

;***** 	Word variables
m_ptrLevelAddr				org *+$02
m_ptrLevelLine				org *+$02
m_currentLineAddress		org *+$02
m_pageZeroTempPointer		org *+$02
m_playerMethodPointer		org *+$02

.PRINT "Zero Page Start : ", ZeroPageAddr, " Zero Page Length : ", * - ZeroPageAddr
		
;*****	Constants
;
DEBUG_ON					= 0
PAL_VERSION					= 0

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

;***** 	Set the constant values for the registers below
;
GRACTL_OPTIONS				= ENABLE_MISSILES | ENABLE_PLAYERS
PRIOR_OPTIONS				= PM_PRIORITY_1   | FIFTH_PLAYER        | MULTICOLOR_PM	
DMACTL_OPTIONS				= ENABLE_DL_DMA   | PM_1LINE_RESOLUTION | PLAYFIELD_WIDTH_NORMAL_MASK 

;*****	Player missle address definitions
;
ms_area_1 					= PmAddress + $0300
p0_area_1 					= PmAddress + $0400
p1_area_1 					= PmAddress + $0500
p2_area_1 					= PmAddress + $0600
p3_area_1 					= PmAddress + $0700

