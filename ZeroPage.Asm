;
;***************************************************************************************************
;
;	Filename:		ZeroPage.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;	
;**************************************************************************************************
; Zero Page Variables definitions
;**************************************************************************************************
;
		org ZeroPageAddress

;*****	RMT zero page variables
;
p_tis						
p_instrstable				org *+2
p_trackslbstable			org *+2
p_trackshbstable			org *+2
p_song						org *+2
ns							org *+2
nr							org *+2
nt							org *+2
reg1						org *+1
reg2						org *+1
reg3						org *+1
tmp							org *+1

;*****	Platform Engine zero page variables
;
m_param00					org *+$01
m_param01					org *+$01
m_param02					org *+$01
m_param03					org *+$01

m_saveRegA					org *+$01
m_saveRegX					org *+$01
m_saveRegY					org *+$01

m_sfxEffect					org *+$01

m_animMiscWidth				org *+$01
m_animMiscHeight			org *+$01

m_redrawPlayerCounter		org *+$01

m_missleBaseColor00			org *+$01
m_playerBaseColor00			org *+$01
m_playerBaseColor1A			org *+$01
m_playerBaseColor1B			org *+$01

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

m_paramW01					org *+$02
m_paramW02					org *+$02

m_ptrLevelAddr				org *+$02
m_ptrLevelLine				org *+$02
m_pageZeroTempPointer		org *+$02
m_playerMethodPointer		org *+$02
m_platformLevelPointer		org *+$02

m_currChar					org *+$01
m_currLevelNum				org *+$01

.PRINT "Zero Page Start : ", ZeroPageAddress, " Zero Page Length : ", * - ZeroPageAddress, " Total : ", *  

.if * - ZeroPageAddress > $79
	.error "Zero Page length address greater than $00FA!"
.endif

