;
;***************************************************************************************************
;
;	Filename:		FW_FrameworkData.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
m_hldA							.byte $00
m_hldY							.byte $00
m_hldX							.byte $00

m_debugSaveX					.byte $00
m_debugSaveA					.byte $00
m_debugSaveY					.byte $00

m_livesLeft						.byte $00		; holder for number of lives left	
m_currLevelNum					.byte $00		; holder for the current game level

m_currChar						.byte $00		; temp holder for the current char being processed
m_sfxEffect						.byte $00		; temp holder for the current sound effect being processed

m_totalScore					:4 .byte $00	; 32 byte score data area (Hi to Lo)

m_currRow						.byte $00
m_currCol						.byte $00
m_scrYCount						.byte $00
m_datYCount						.byte $00
m_currentLineAddress			.word $0000

m_verticalLaserOn				.byte $00		; is vertical laser available
m_horizontalLaserOn				.byte $00		; is horizontal laser available

m_totalEnemies 					.byte $00
m_activeEnemies 				.byte $00

m_goldCounter 					.byte $00		; current gold counter
m_healthCounter					.byte $00		; current health counter
m_waterAvailable				.byte $00		; is water available

m_disableGameTimer				.byte $00		; disable game flag

m_gameTimerSeconds				.byte $00		; seconds timer
m_gameTimerMinutes				.byte $00		; minutes timer
m_gameTimerTSeconds				.byte $00		; seconds timer total
m_gameTSFrameCounter			.byte $00		; frame counter total

m_stick0						.byte $00
m_oldStick0						.byte $00
m_oldTrigger0					.byte $00
m_triggerState					.byte $00		; 0 - not pressed, 1 - just released, 2 - just pressed, 3 - pressed
m_currentTrigger0				.byte $00

m_playerSizeX					.byte $00
m_playerSizeY					.byte $00
m_playerSizeXMinusOne			.byte $00
m_playerSizeYMinusOne			.byte $00

m_playerScreenTopY				.byte $00
m_playerScreenLeftX				.byte $00

m_oldPlayerScreenTopY			.byte $00
m_oldPlayerScreenLeftX			.byte $00

m_playerTopY					.byte $00
m_playerLeftX					.byte $00
m_playerRightX					.byte $00
m_playerBottomY					.byte $00

m_sfxData						.byte $00
m_sfxValue						.byte $00
m_sfxLength						.byte $00

m_floatAnimModV					.byte $00		; used for modulus operation on vertical animation
m_floatAnimModH					.byte $00		; used for modulus operation on horizontal animation
m_floatAnimClimb				.byte $00

m_floatPlatformV				.byte $00		; is there vertical floating platforms
m_floatPlatformH				.byte $00		; is there horizontal floating platforms

m_floatPlatform_X				.byte $00
m_floatPlatform_Y				.byte $00

m_currPlatformIdx				.byte $00		; current index to platform screen array
m_floatPlatformIdx				.byte $00		; index to platform screen array

m_screenBaseAddress1			.word $00
m_screenBaseAddress2			.word $00

m_windowTargetPosX_H1			.byte $00
m_windowTargetPosX_H2			.byte $00
m_windowTargetPosY_H1			.byte $00
m_windowTargetPosY_H2			.byte $00

m_windowTargetDeltaX_H1			.byte $00
m_windowTargetDeltaX_H2			.byte $00
m_windowTargetDeltaY_H1			.byte $00
m_windowTargetDeltaY_H2			.byte $00

m_enemyExplosionLevelLeftX_H1	.byte $00
m_enemyExplosionLevelLeftX_H2	.byte $00

m_enemyExplosionLevelTopY_H1	.byte $00
m_enemyExplosionLevelTopY_H2	.byte $00
m_enemyExplosionLevelTopY_L1	.byte $00

m_enemyExplosionScreenTopY_H1	.byte $00
m_enemyExplosionScreenLeftX_H1	.byte $00

m_enemyExplosionStep			.byte $00

m_enemyCharPosX					.byte $00
m_enemyCharPosY					.byte $00
m_enemyExplosionStepIndex		.byte $00

m_hitEnemySaveX 				.byte $00
m_numEnemyExplosions			.byte $00

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

m_pixelPositionX_H2				.byte 0
m_pixelPositionX_H1				.byte 0
m_pixelPositionY_H2				.byte 0
m_pixelPositionY_H1				.byte 0

m_charPositionX					.byte 0
m_charPositionY					.byte 0

m_lineAddressLSB				.byte 0
m_lineAddressMSB				.byte 0

m_charRaw						.byte 0
m_charDef						.byte 0

m_levelCharSizeX				.byte $00			; char size X goes from 1 to 255 characters, 0 = 256 characters
m_levelCharSizeY				.byte $00			; char size Y goes from 1 to 255 characters, 0 = 256 characters

m_levelSizeX_H2					.byte $00
m_levelSizeX_H1					.byte $00

m_levelSizeY_H2					.byte $00
m_levelSizeY_H1					.byte $00				

m_levelWindowX_H2				.byte $00
m_levelWindowX_H1				.byte $00

m_levelWindowY_H2				.byte $00
m_levelWindowY_H1				.byte $00

m_screenDelta_H2				.byte $00
m_screenDelta_H1				.byte $00

m_leftTopChar					.byte $00
m_rightTopChar					.byte $00

m_charBuffer_H2					.byte $00

m_leftBottomChar				.byte $00
m_rightBottomChar				.byte $00
m_middleBottomChar				.byte $00

m_bottomPosOffsetX				.byte $00
m_bottomPosOffsetY				.byte $00

m_playerExplosionStep			.byte $00
m_middleBottomCharPosX			.byte $00

m_waterPlayerDirectionFlag		.byte $00
m_playerOnWaterSurfaceFlag		.byte $00

m_playerExplosionScreenTopY_H1	.byte $00
m_playerExplosionScreenTopY_L1	.byte $00

;***** System Data members
;
m_animSeaTopTimer				.byte ANIM_SEA_TOP_FRAME_TIME

m_firstCoinAnimIndex			.byte $00
m_emptyCoinAnimIndex			.byte $00
m_currentCoinAnimations			.byte $00

m_animHLaserTimer				.byte $01
m_animHLaserCurrentFrame		.byte $00

m_animVLaserTimer				.byte $01
m_animVLaserCurrentFrame		.byte $00

m_revX							.byte $00
m_revIndex						.byte $00
m_revHeight						.byte $00
m_revOffset						.byte $00
m_animCount						.byte $00
m_animFrame						.byte $00
m_animIndex        				.byte $00
m_animHeight					.byte $00
m_animOffset					.byte $00	

m_missleBaseColor00				.byte $00
m_playerBaseColor00				.byte $00
m_playerBaseColor1A				.byte $00
m_playerBaseColor1B				.byte $00

TabHardwareCollision			:$10	.byte $00

TabLevelLineAddressLSB			:$0100 	.byte $00
TabLevelLineAddressMSB			:$0100 	.byte $00

