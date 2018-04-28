;	
;**************************************************************************************************
;
;	Filename:		ScrollerData.Asm
;
;	Created By:		Victor V Ferenzi
;
;	Created On:		Wed Apr 21, 2018 05:32 AM
;
;	Comments:		This code contains parts of the OPEN_PLAT project developed by NVR. It also
;					contains parts of the port from the C64 to Atari project ported by
;					Ken Jennings. Many thanks to both of them. 
;	
;**************************************************************************************************
;

;***** System Data members
;
_goldCounter 					.byte $00		; current gold counter
_activeEnemies					.byte $00		; active enemies counter
_disableGameTimer				.byte $00		; disable game flag

_gameTimerSeconds				.byte $00		; seconds timer
_gameTimerMinutes				.byte $00		; minutes timer

_gameTimerTSeconds				.byte $00		; seconds timer total
_gameTSFrameCounter			.byte $00		; frame counter total


TabLevelLineAddressLSB			:256 .byte $00
TabLevelLineAddressMSB			:256 .byte $00
