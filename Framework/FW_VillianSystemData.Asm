;
;***************************************************************************************************
;
;	Filename:		FW_VillianSystemData.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
MAX_VILLIANS_CHARS			= 8

VilChars					.byte $70, $71, $72, $73 
							.byte $74, $75, $76, $77
							
VilLines					.byte $00, $06, $06, $0D
							.byte $0D, $13, $13, $19 							
							
VilTypeId					:MAX_VILLIANS	.byte $00
							
VilPositionX				:MAX_VILLIANS	.byte $00
VilPositionY				:MAX_VILLIANS	.byte $00

VilDirX						:MAX_VILLIANS	.byte $00
VilDirY						:MAX_VILLIANS	.byte $00
VilDirectionX				:MAX_VILLIANS 	.byte $00
VilDirectionY				:MAX_VILLIANS 	.byte $00
VilCollisionX				:MAX_VILLIANS 	.byte $00
VilCollisionY				:MAX_VILLIANS 	.byte $00
VilOldCollisionX			:MAX_VILLIANS 	.byte $00
VilOldCollisionY			:MAX_VILLIANS 	.byte $00

VilDelay					:MAX_VILLIANS	.byte $00
VilState					:MAX_VILLIANS	.byte $00
VilBonus					:MAX_VILLIANS	.byte $00
VilActive					:MAX_VILLIANS	.byte $00
VilTimers					:MAX_VILLIANS	.byte $00

VilWidth					:MAX_VILLIANS	.byte $00
VilHeight					:MAX_VILLIANS	.byte $00

VilPosLSB					:MAX_VILLIANS	.byte $00
VilPosMSB					:MAX_VILLIANS	.byte $00

VilMoveLSB					:MAX_VILLIANS	.byte $00
VilMoveMSB					:MAX_VILLIANS	.byte $00

VilAnimLSB					:MAX_VILLIANS	.byte $00
VilAnimMSB					:MAX_VILLIANS	.byte $00

VilColorLSB					:MAX_VILLIANS	.byte $00
VilColorMSB					:MAX_VILLIANS	.byte $00

VilCurrFrame				:MAX_VILLIANS	.byte $00
VilTotalFrame				:MAX_VILLIANS	.byte $00

VilSpeedX_L1				:MAX_VILLIANS 	.byte $00
VilSpeedX_H1				:MAX_VILLIANS 	.byte $00

VilSideSpeedX_L1			:MAX_VILLIANS	.byte $00
VilSideSpeedX_H1			:MAX_VILLIANS	.byte $00

VilSideSpeedAccelX_L1		:MAX_VILLIANS	.byte $00
VilSideSpeedAccelX_H1		:MAX_VILLIANS	.byte $00

VilSideSpeedDeaccelX_L1		:MAX_VILLIANS	.byte $00
VilSideSpeedDeaccelX_H1		:MAX_VILLIANS	.byte $00

VilSpeedY_L1				:MAX_VILLIANS 	.byte $00
VilSpeedY_H1				:MAX_VILLIANS 	.byte $00

VilUpDownSpeedY_L1			:MAX_VILLIANS 	.byte $00
VilUpDownSpeedY_H1			:MAX_VILLIANS 	.byte $00

VilUpDownSpeedAccelY_L1		:MAX_VILLIANS	.byte $00
VilUpDownSpeedAccelY_H1		:MAX_VILLIANS	.byte $00

VilUpDownSpeedDeaccelY_L1	:MAX_VILLIANS	.byte $00
VilUpDownSpeedDeaccelY_H1	:MAX_VILLIANS	.byte $00

VilScreenTopY				:MAX_VILLIANS	.byte $00
VilOldScreenTopY			:MAX_VILLIANS	.byte $00

VilScreenLeftX				:MAX_VILLIANS	.byte $00
VilOldScreenLeftX			:MAX_VILLIANS	.byte $00

VilLevelLeftX_H1			:MAX_VILLIANS 	.byte $00
VilLevelLeftX_H2			:MAX_VILLIANS 	.byte $00
VilLevelLeftX_L1			:MAX_VILLIANS 	.byte $00

VilLevelRightX_H1			:MAX_VILLIANS 	.byte $00
VilLevelRightX_H2			:MAX_VILLIANS 	.byte $00
VilLevelRightX_L1			:MAX_VILLIANS 	.byte $00

VilLevelTopY_H1				:MAX_VILLIANS 	.byte $00
VilLevelTopY_H2				:MAX_VILLIANS 	.byte $00
VilLevelTopY_L1				:MAX_VILLIANS 	.byte $00

VilLevelBottomY_H1			:MAX_VILLIANS 	.byte $00
VilLevelBottomY_H2			:MAX_VILLIANS 	.byte $00
VilLevelBottomY_L1			:MAX_VILLIANS 	.byte $00

m_villianTopY				.byte $00
m_villianLeftX				.byte $00
m_villianRightX				.byte $00
m_villianBottomY			.byte $00

m_villianTypeId				.byte $00
m_villianDliIndex			.byte $00
m_villianCurrIndex			.byte $FF



