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
m_goldCounter 					.byte $00		; current gold counter
m_disableGameTimer				.byte $00		; disable game flag

m_gameTimerSeconds				.byte $00		; seconds timer
m_gameTimerMinutes				.byte $00		; minutes timer

m_gameTimerTSeconds				.byte $00		; seconds timer total
m_gameTSFrameCounter				.byte $00		; frame counter total

TabLevelLineAddressLSB			:256 .byte $00
TabLevelLineAddressMSB			:256 .byte $00
;
;**************************************************************************************************
; Character tile type definition
;
; 	Type definition: low 4 bits (0-15 value)
;		- 0: empty normal space (with gravity info?)			CT_BLANK			= 0					
;		- 1: block (with collision info, RLDU)					CT_BLOCK			= 1
;		- 2: collectable (with value info?)						CT_COLLECTABLE		= 2
;		- 3: danger (with energy info?)							CT_DANGER			= 3
;		- 4: ladder, climbable (with directions info?)			CT_LADDER			= 4
;		- 5: water (with density info? currents?)				CT_WATER			= 5
;		- 6: floating platform									CT_FLOATPLATFORM	= 1	
;
; 	External level definitions:
; 		- blocks ON/OFF
; 		- moving blocks
; 		- switches, triggers and traps
; 		- enemies and generators
; 		- dangers ON/OFF
; 		- moving dangers
; 		- interactions zones
; 		- text messages
;
;**************************************************************************************************
;
TabCharDefinition
	.byte %00000000+CT_BLANK								; blank								[00]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[01]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[02]				
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[03]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[04]
	.byte %00000000+CT_DANGER								; blue spikes						[05]
	.byte %00000000+CT_DANGER								; blue spikes						[06]
	.byte %00000000+CT_BLANK								; blank								[07]
	.byte %00000000+CT_BLANK								; blank								[08]
	.byte %00000000+CT_BLANK								; blank								[09]
	.byte %00000000+CT_BLANK								; blank								[0A]
	.byte %00000000+CT_BLANK								; blank								[0B]
	.byte %00000000+CT_BLANK								; blank								[0C]
	.byte %00000000+CT_BLANK								; blank								[0D]
	.byte %00000000+CT_BLANK								; blank								[0E]
	.byte %00000000+CT_BLANK								; blank								[0F]
	.byte %00000000+CT_LADDER								; ladder							[10]
	.byte %00000000+CT_LADDER								; ladder							[11]
	.byte %00000000+CT_LADDER								; ladder							[12]
	.byte %00000000+CT_DANGER								; blue spikes						[13]
	.byte %11110000+CT_DANGER								; vertical dither 1					[14]				
	.byte %11110000+CT_DANGER								; vertical dither 2					[15]
	.byte %11110000+CT_DANGER								; vertical dither 3					[16]
	.byte %11110000+CT_DANGER								; horizontal dither 1				[17]
	.byte %11110000+CT_DANGER								; horizontal dither 2				[18]
	.byte %11110000+CT_DANGER								; horizontal dither 3				[19]
	.byte %00000000+CT_DANGER								; spikes							[1A]
	.byte %00000000+CT_DANGER								; spikes							[1B]
	.byte %00000000+CT_DANGER								; spikes							[1C]
	.byte %00000000+CT_DANGER								; spikes							[1D]
	.byte %00000000+CT_DANGER								; spikes							[1E]
	.byte %00000000+CT_DANGER								; spikes							[1F]
	.byte %11110000+CT_BLOCK								; vertical dither 1 LB  base		[20]
	.byte %11110000+CT_BLOCK								; vertical dither 2 MB  base		[21]
	.byte %11110000+CT_BLOCK								; vertical dither 3 RB  base		[22]
	.byte %11110000+CT_BLOCK								; vertical dither 1 LT  base		[23]
	.byte %11110000+CT_BLOCK								; vertical dither 2 MT  base		[24]
	.byte %11110000+CT_BLOCK								; vertical dither 3 RT  base		[25]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[26]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[27]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[28]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[29]
	.byte %00000000+CT_BLANK								; blank								[2A]
	.byte %00000000+CT_BLANK								; blank								[2B]
	.byte %00000000+CT_BLANK								; blank								[2C]
	.byte %00000000+CT_BLANK								; blank								[2D]
	.byte %00000000+CT_BLANK								; blank								[2E]
	.byte %00000000+CT_BLANK								; blank								[2F]
	.byte %00000000+CT_BLANK								; blank								[30]
	.byte %00000000+CT_BLANK								; blank								[31]
	.byte %00000000+CT_BLANK								; blank								[32]
	.byte %00000000+CT_BLANK								; blank								[33]
	.byte %00000000+CT_BLANK								; blank								[34]
	.byte %00000000+CT_BLANK								; blank								[35]
	.byte %00000000+CT_BLANK								; blank								[36]
	.byte %00000000+CT_BLANK								; blank								[37]
	.byte %00000000+CT_BLANK								; blank								[38]
	.byte %00000000+CT_BLANK								; blank								[39]
	.byte %00000000+CT_DANGER								; spikes							[3A]
	.byte %00000000+CT_DANGER								; spikes							[3B]
	.byte %00000000+CT_BLANK								; blank								[3C]
	.byte %00000000+CT_BLANK								; blank								[3D]
	.byte %00000000+CT_BLANK								; blank								[3E]
	.byte %00000000+CT_BLANK								; blank								[3F]
	.byte %00010000+CT_DANGER								; enemy 1 left side (red)           [40]
	.byte %00010000+CT_DANGER								; enemy 1 left side (red)           [41]
	.byte %00000000+CT_BLANK								; blank								[42]
	.byte %00000000+CT_BLANK								; blank								[43]
	.byte %00000000+CT_BLANK								; blank								[44]
	.byte %00000000+CT_BLANK								; blank								[45]
	.byte %00000000+CT_BLANK								; blank								[46]
	.byte %00000000+CT_BLANK								; blank								[47]
	.byte %00000000+CT_BLANK								; blank								[48]
	.byte %00000000+CT_BLANK								; blank								[49]
	.byte %00000000+CT_BLANK								; blank								[4A]
	.byte %00000000+CT_BLANK								; blank								[4B]
	.byte %11110000+CT_BLOCK								; solid platform					[4C]
	.byte %11110000+CT_BLOCK								; solid platform					[4D]
	.byte %11110000+CT_BLOCK								; solid platform					[4E]
	.byte %11110000+CT_BLOCK								; solid platform					[4F]
	.byte %11110000+CT_BLOCK								; solid platform					[50]
	.byte %11110000+CT_BLOCK								; solid platform					[51]
	.byte %00000000+CT_BLANK								; blank								[52]   
	.byte %00000000+CT_BLANK								; blank								[53]   
	.byte %00000000+CT_BLANK								; blank								[54]   
	.byte %00000000+CT_BLANK								; blank								[55]   
	.byte %00000000+CT_BLANK								; blank								[56]   
	.byte %00000000+CT_BLANK								; blank								[57]   
	.byte %00000000+CT_BLANK								; blank								[58]   
	.byte %00000000+CT_BLANK								; blank								[59]   
	.byte %00000000+CT_DANGER								; spikes							[5A]   
	.byte %00000000+CT_DANGER								; spikes							[5B]   
	.byte %11110000+CT_BLOCK								; solid platform					[5C]   
	.byte %11110000+CT_BLOCK								; solid platform					[5D]   
	.byte %11110000+CT_BLOCK								; solid platform					[5E]   
	.byte %00000000+CT_BLANK								; blank								[5F]   
	.byte %11110000+CT_BLOCK								; solid platform					[60]   
	.byte %11110000+CT_BLOCK								; solid platform					[61]   
	.byte %11110000+CT_BLOCK								; solid platform					[62]   
	.byte %11110000+CT_BLOCK								; solid platform					[63]   
	.byte %11110000+CT_BLOCK								; solid platform					[64]   
	.byte %11110000+CT_BLOCK								; solid platform					[65]   
	.byte %11110000+CT_BLOCK								; solid platform					[66]   
	.byte %11110000+CT_BLOCK								; solid platform					[67]   
	.byte %11110000+CT_BLOCK								; solid platform					[68]   
	.byte %11110000+CT_BLOCK								; solid platform					[69]   
	.byte %11110000+CT_BLOCK								; solid platform					[6A]   
	.byte %11110000+CT_BLOCK								; solid platform					[6B]   
	.byte %11110000+CT_BLOCK								; solid platform					[6C]   
	.byte %11110000+CT_BLOCK								; solid platform					[6D]   
	.byte %11110000+CT_BLOCK								; solid platform					[6E]   
	.byte %11110000+CT_BLOCK								; solid platform					[6F]   
	.byte %11110000+CT_BLOCK								; solid platform					[70]   
	.byte %11110000+CT_BLOCK								; solid platform					[71]   
	.byte %11110000+CT_BLOCK								; solid platform					[72]   
	.byte %11110000+CT_BLOCK								; solid platform					[73]   
	.byte %11110000+CT_BLOCK								; solid platform					[74]   
	.byte %00000000+CT_BLANK								; blank								[75]   
	.byte %00000000+CT_BLANK								; blank								[76]   
	.byte %00000000+CT_BLANK								; blank								[77]   
	.byte %00000000+CT_BLANK								; blank								[78]   
	.byte %00000000+CT_BLANK								; blank								[79]   
	.byte %00000000+CT_BLANK								; blank								[7A]   
	.byte %00000000+CT_BLANK								; blank								[7B]   
	.byte %00000000+CT_BLANK								; blank								[7C]   
	.byte %00000000+CT_BLANK								; blank								[7D]   
	.byte %00000000+CT_BLANK								; blank								[7E]   
	.byte %00000000+CT_BLANK								; blank								[7F]   
;
;**************************************************************************************************
; second half, inverse characters, fifth color (red, danger)
;**************************************************************************************************
;
	org TabCharDefinition+$80

	.byte %00000000+CT_BLANK								; blank								[80]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[81]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[82]				
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[83]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[84]
	.byte %00000000+CT_DANGER								; blue spikes						[85]
	.byte %00000000+CT_DANGER								; blue spikes						[86]
	.byte %00000000+CT_BLANK								; blank								[87]
	.byte %00000000+CT_BLANK								; blank								[88]
	.byte %00000000+CT_BLANK								; blank								[89]
	.byte %00000000+CT_BLANK								; blank								[8A]
	.byte %00000000+CT_BLANK								; blank								[8B]
	.byte %00000000+CT_BLANK								; blank								[8C]
	.byte %00000000+CT_BLANK								; blank								[8D]
	.byte %00000000+CT_BLANK								; blank								[8E]
	.byte %00000000+CT_BLANK								; blank								[8F]
	.byte %00000000+CT_LADDER								; ladder							[90]
	.byte %00000000+CT_LADDER								; ladder							[91]
	.byte %00000000+CT_LADDER								; ladder							[92]
	.byte %00000000+CT_DANGER								; blue spikes						[93]
	.byte %11110000+CT_DANGER								; vertical dither 1					[94]				
	.byte %11110000+CT_DANGER								; vertical dither 2					[95]
	.byte %11110000+CT_DANGER								; vertical dither 3					[96]
	.byte %11110000+CT_DANGER								; horizontal dither 1				[97]
	.byte %11110000+CT_DANGER								; horizontal dither 2				[98]
	.byte %11110000+CT_DANGER								; horizontal dither 3				[99]
	.byte %00000000+CT_DANGER								; spikes							[9A]
	.byte %00000000+CT_DANGER								; spikes							[9B]
	.byte %00000000+CT_DANGER								; spikes							[9C]
	.byte %00000000+CT_DANGER								; spikes							[9D]
	.byte %00000000+CT_DANGER								; spikes							[9E]
	.byte %00000000+CT_DANGER								; spikes							[9F]
	.byte %11110000+CT_BLOCK								; vertical dither 1 LB  base		[A0]
	.byte %11110000+CT_BLOCK								; vertical dither 2 MB  base		[A1]
	.byte %11110000+CT_BLOCK								; vertical dither 3 RB  base		[A2]
	.byte %11110000+CT_BLOCK								; vertical dither 1 LT  base		[A3]
	.byte %11110000+CT_BLOCK								; vertical dither 2 MT  base		[A4]
	.byte %11110000+CT_BLOCK								; vertical dither 3 RT  base		[A5]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[A6]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[A7]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[A8]
	.byte %00010000+CT_FLOATPLATFORM						; Floating Platform					[A9]
	.byte %00000000+CT_BLANK								; blank								[AA]
	.byte %00000000+CT_BLANK								; blank								[AB]
	.byte %00000000+CT_BLANK								; blank								[AC]
	.byte %00000000+CT_BLANK								; blank								[AD]
	.byte %00000000+CT_BLANK								; blank								[AE]
	.byte %00000000+CT_BLANK								; blank								[AF]
	.byte %00000000+CT_BLANK								; blank								[B0]
	.byte %00000000+CT_BLANK								; blank								[B1]
	.byte %00000000+CT_BLANK								; blank								[B2]
	.byte %00000000+CT_BLANK								; blank								[B3]
	.byte %00000000+CT_BLANK								; blank								[B4]
	.byte %00000000+CT_BLANK								; blank								[B5]
	.byte %00000000+CT_BLANK								; blank								[B6]
	.byte %00000000+CT_BLANK								; blank								[B7]
	.byte %00000000+CT_BLANK								; blank								[B8]
	.byte %00000000+CT_BLANK								; blank								[B9]
	.byte %00000000+CT_DANGER								; spikes							[BA]
	.byte %00000000+CT_DANGER								; spikes							[BB]
	.byte %00000000+CT_BLANK								; blank								[BC]
	.byte %00000000+CT_BLANK								; blank								[BD]
	.byte %00000000+CT_BLANK								; blank								[BE]
	.byte %00000000+CT_BLANK								; blank								[BF]
	.byte %00010000+CT_DANGER								; enemy 1 left side (red)           [C0]
	.byte %00010000+CT_DANGER								; enemy 1 left side (red)           [C1]
	.byte %00000000+CT_BLANK								; blank								[C2]
	.byte %00000000+CT_BLANK								; blank								[C3]
	.byte %00000000+CT_BLANK								; blank								[C4]
	.byte %00000000+CT_BLANK								; blank								[C5]
	.byte %00000000+CT_BLANK								; blank								[C6]
	.byte %00000000+CT_BLANK								; blank								[C7]
	.byte %00000000+CT_BLANK								; blank								[C8]
	.byte %00000000+CT_BLANK								; blank								[C9]
	.byte %00000000+CT_BLANK								; blank								[CA]
	.byte %00000000+CT_BLANK								; blank								[CB]
	.byte %11110000+CT_BLOCK								; solid platform					[CC]
	.byte %11110000+CT_BLOCK								; solid platform					[CD]
	.byte %11110000+CT_BLOCK								; solid platform					[CE]
	.byte %11110000+CT_BLOCK								; solid platform					[CF]
	.byte %11110000+CT_BLOCK								; solid platform					[D0]
	.byte %11110000+CT_BLOCK								; solid platform					[D1]
	.byte %00000000+CT_BLANK								; blank								[D2]   
	.byte %00000000+CT_BLANK								; blank								[D3]   
	.byte %00000000+CT_BLANK								; blank								[D4]   
	.byte %00000000+CT_BLANK								; blank								[D5]   
	.byte %00000000+CT_BLANK								; blank								[D6]   
	.byte %00000000+CT_BLANK								; blank								[D7]   
	.byte %00000000+CT_BLANK								; blank								[D8]   
	.byte %00000000+CT_BLANK								; blank								[D9]   
	.byte %00000000+CT_DANGER								; spikes							[DA]   
	.byte %00000000+CT_DANGER								; spikes							[DB]   
	.byte %11110000+CT_BLOCK								; solid platform					[DC]   
	.byte %11110000+CT_BLOCK								; solid platform					[DD]   
	.byte %11110000+CT_BLOCK								; solid platform					[DE]   
	.byte %00000000+CT_BLANK								; blank								[DF]   
	.byte %11110000+CT_BLOCK								; solid platform					[E0]   
	.byte %11110000+CT_BLOCK								; solid platform					[E1]   
	.byte %11110000+CT_BLOCK								; solid platform					[E2]   
	.byte %11110000+CT_BLOCK								; solid platform					[E3]   
	.byte %11110000+CT_BLOCK								; solid platform					[E4]   
	.byte %11110000+CT_BLOCK								; solid platform					[E5]   
	.byte %11110000+CT_BLOCK								; solid platform					[E6]   
	.byte %11110000+CT_BLOCK								; solid platform					[E7]   
	.byte %11110000+CT_BLOCK								; solid platform					[E8]   
	.byte %11110000+CT_BLOCK								; solid platform					[E9]   
	.byte %11110000+CT_BLOCK								; solid platform					[EA]   
	.byte %11110000+CT_BLOCK								; solid platform					[EB]   
	.byte %11110000+CT_BLOCK								; solid platform					[EC]   
	.byte %11110000+CT_BLOCK								; solid platform					[ED]   
	.byte %11110000+CT_BLOCK								; solid platform					[EE]   
	.byte %11110000+CT_BLOCK								; solid platform					[EF]   
	.byte %11110000+CT_BLOCK								; solid platform					[F0]   
	.byte %11110000+CT_BLOCK								; solid platform					[F1]   
	.byte %11110000+CT_BLOCK								; solid platform					[F2]   
	.byte %11110000+CT_BLOCK								; solid platform					[F3]   
	.byte %11110000+CT_BLOCK								; solid platform					[F4]   
	.byte %00000000+CT_BLANK								; blank								[F5]   
	.byte %00000000+CT_BLANK								; blank								[F6]   
	.byte %00000000+CT_BLANK								; blank								[F7]   
	.byte %00000000+CT_BLANK								; blank								[F8]   
	.byte %00000000+CT_BLANK								; blank								[F9]   
	.byte %00000000+CT_BLANK								; blank								[FA]   
	.byte %00000000+CT_BLANK								; blank								[FB]   
	.byte %00000000+CT_BLANK								; blank								[FC]   
	.byte %00000000+CT_BLANK								; blank								[FD]   
	.byte %00000000+CT_BLANK								; blank								[FE]   
	.byte %00000000+CT_BLANK								; blank								[FF]	

;*****	Dislplay List Definitions
;
GameDL 
		.byte DL_BLANK_8
		.byte DL_BLANK_8
		.byte DL_BLANK_8 + DL_DLI

GameDL_LMS1
		
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

GameDLEnd = * - GameDL
		
