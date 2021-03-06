;
;***************************************************************************************************
;
;	Filename:		DataScroller.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
MAX_VILLIANS					= 8

;
;**************************************************************************************************
; 	Villian Draw Methods
;**************************************************************************************************
;
VillianAnimLSB				.byte <CreepyDraw, $FF, $FF, $FF, $FF, $FF, $FF, $FF
VillianAnimMSB				.byte >CreepyDraw, $FF, $FF, $FF, $FF, $FF, $FF, $FF 						

;
;**************************************************************************************************
; 	Villian Initialize Methods
;**************************************************************************************************
;
VillianInitLSB				.byte <CreepyInit, $FF, $FF, $FF, $FF, $FF, $FF, $FF
VillianInitMSB				.byte >CreepyInit, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;
;**************************************************************************************************
; 	Villian Move Methods
;**************************************************************************************************
;
VillianMoveLSB				.byte <CreepyMove, $FF, $FF, $FF, $FF, $FF, $FF, $FF
VillianMoveMSB				.byte >CreepyMove, $FF, $FF, $FF, $FF, $FF, $FF, $FF 						

;
;**************************************************************************************************
; 	Villian State Methods
;**************************************************************************************************
;
VillianStateLSB				.byte <CreepyState, $FF, $FF, $FF, $FF, $FF, $FF, $FF
VillianStateMSB				.byte >CreepyState, $FF, $FF, $FF, $FF, $FF, $FF, $FF 						

;
;**************************************************************************************************
; Character tile type definition
;
; 	Type definition: low 4 bits (0-15 value)
;		- 0: empty normal space (with gravity info?)			CT_BLANK			= 0					

;		- 1: block (with collision info, RLDU)					CT_BLOCK			= 1
;		- 6: floating platform									CT_FLOATPLATFORM	= 1	

;		- 2: collectable (with value info?)						CT_COLLECTABLE		= 2
;		- 3: danger (with energy info?)							CT_DANGER			= 3
;		- 4: ladder, climbable (with directions info?)			CT_LADDER			= 4
;		- 5: water (with density info? currents?)				CT_WATER			= 5
;		- 7: health 											CT_HEALTH			= 6
;		- 8: Vertical Lasers									CT_VLASER			= 7
;		- 9: Horizontal Lasers									CT_HLASER			= 8
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
	.byte %00000000+CT_HEALTH								; collectable 1						[03]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[04]
	.byte %00000000+CT_DANGER								; blue spikes						[05]
	.byte %00000000+CT_DANGER								; blue spikes						[06]
	.byte %00000000+CT_WATER								; water								[07]
	.byte %00000000+CT_HEALTH								; hEALTH wATER						[08]
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
	.byte %00000000+CT_LADDER								; ladder							[13]
	.byte %11110000+CT_VLASER								; vertical dither 1					[14]
	.byte %11110000+CT_HLASER								; horizontal dither 1				[15]
	.byte %00000000+CT_DANGER								; blue spikes						[16]
	.byte %00000000+CT_BLANK								; blank								[17]
	.byte %00000000+CT_BLANK								; blank								[18]
	.byte %00000000+CT_BLANK								; blank								[19]
	.byte %00000000+CT_DANGER								; spikes							[1A]
	.byte %00000000+CT_DANGER								; spikes							[1B]
	.byte %00000000+CT_DANGER								; spikes							[1C]
	.byte %00000000+CT_DANGER								; spikes							[1D]
	.byte %00000000+CT_DANGER								; spikes							[1E]
	.byte %00000000+CT_DANGER								; spikes							[1F]
	.byte %11110000+CT_BLOCK								; solid platform					[20]
	.byte %11110000+CT_BLOCK								; solid platform					[21]
	.byte %11110000+CT_BLOCK								; solid platform					[22]
	.byte %11110000+CT_BLOCK								; solid platform					[23]
	.byte %11110000+CT_BLOCK								; solid platform					[24]
	.byte %11110000+CT_BLOCK								; solid platform					[25]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[26]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[27]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[28]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[29]
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
	.byte %00000000+CT_DANGER								; creater							[43]
	.byte %00000000+CT_BLANK								; blank								[44]
	.byte %00000000+CT_BLANK								; blank								[45]
	.byte %00000000+CT_WATER								; blank								[46]
	.byte %00000000+CT_WATER								; blank								[47]
	.byte %00000000+CT_WATER								; blank								[48]
	.byte %00000000+CT_WATER								; blank								[49]
	.byte %00000000+CT_BLANK								; blank								[4A]
	.byte %00000000+CT_BLANK								; blank								[4B]
	.byte %11110000+CT_BLOCK								; solid platform					[4C]
	.byte %11110000+CT_BLOCK								; solid platform					[4D]
	.byte %11110000+CT_BLOCK								; solid platform					[4E]
	.byte %11110000+CT_BLOCK								; solid platform					[4F]
	.byte %11110000+CT_BLOCK								; solid platform					[50]
	.byte %11110000+CT_BLANK								; blank								[51]
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
	.byte %00000000+CT_HEALTH								; collectable 1						[83]
	.byte %00000000+CT_COLLECTABLE							; collectable 1						[84]
	.byte %00000000+CT_DANGER								; blue spikes						[85]
	.byte %00000000+CT_DANGER								; blue spikes						[86]
	.byte %00000000+CT_WATER								; water								[87]
	.byte %00000000+CT_HEALTH								; hEALTH wATER						[88]
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
	.byte %00000000+CT_LADDER								; ladder							[93]
	.byte %11110000+CT_VLASER								; vertical dither 1					[94]
	.byte %11110000+CT_HLASER								; horizontal dither 1				[95]
	.byte %00000000+CT_DANGER								; blue spikes						[96]
	.byte %00000000+CT_BLANK								; blank								[97]
	.byte %00000000+CT_BLANK								; blank								[98]
	.byte %00000000+CT_BLANK								; blank								[99]
	.byte %00000000+CT_DANGER								; spikes							[9A]
	.byte %00000000+CT_DANGER								; spikes							[9B]
	.byte %00000000+CT_DANGER								; spikes							[9C]
	.byte %00000000+CT_DANGER								; spikes							[9D]
	.byte %00000000+CT_DANGER								; spikes							[9E]
	.byte %00000000+CT_DANGER								; spikes							[9F]
	.byte %11110000+CT_BLOCK								; solid platform					[A0]
	.byte %11110000+CT_BLOCK								; solid platform					[A1]
	.byte %11110000+CT_BLOCK								; solid platform					[A2]
	.byte %11110000+CT_BLOCK								; solid platform					[A3]
	.byte %11110000+CT_BLOCK								; solid platform					[A4]
	.byte %11110000+CT_BLOCK								; solid platform					[A5]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[A6]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[A7]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[A8]
	.byte %00010000+CT_FLOATPLATFORMH						; Floating Platform					[A9]
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
	.byte %00000000+CT_DANGER								; creater							[C3]
	.byte %00000000+CT_BLANK								; blank								[C4]
	.byte %00000000+CT_BLANK								; blank								[C5]
	.byte %00000000+CT_WATER								; blank								[C6]
	.byte %00000000+CT_WATER								; blank								[C7]
	.byte %00000000+CT_WATER								; blank								[C8]
	.byte %00000000+CT_WATER								; blank								[C9]
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

GameDL 
		.byte DL_BLANK_8
		.byte DL_BLANK_8
		.byte DL_BLANK_8 + DL_DLI

GameDL_LMS1
		
		?dldata = GameMemoryAddress
		.rept 24
			.byte DL_TEXT_4 + DL_LMS + DL_HSCROLL + DL_VSCROLL
			.byte <?dldata, >?dldata
			?dldata += LEVEL_CHAR_SIZE_X
		.endr
	
		.byte DL_TEXT_4 + DL_LMS + DL_HSCROLL
		.byte <?dldata, >?dldata
	
		.byte DL_BLANK_3 + DL_DLI

		?dldata = HudMemoryAddress
		.rept 2
			.byte DL_TEXT_2 + DL_LMS
			.byte <?dldata, >?dldata
			?dldata += WINDOW_CHAR_SIZE_X
		.endr	
	
		.byte DL_JUMP_VB, <CommDspListAddr, >CommDspListAddr

GameDLEnd = * - GameDL

;
; Title Display List
;
TitleDL 
		
		.rept 2
			.byte DL_BLANK_8
		.endr		
		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE01, >TITLE01		
		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE02, >TITLE02
		.rept 5
			.byte DL_BLANK_8
		.endr
		
		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE03, >TITLE03
		.rept 2
			.byte DL_BLANK_8
		.endr

		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE04, >TITLE04
		.rept 3
			.byte DL_BLANK_8
		.endr

		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE05, >TITLE05
		.rept 2
			.byte DL_BLANK_8
		.endr
		
		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE06, >TITLE06
		.byte DL_BLANK_8

		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE07, >TITLE07
		.rept 4
			.byte DL_BLANK_8
		.endr
		
		.byte DL_LMS + DL_TEXT_6
		.byte <TITLE08, >TITLE08		
		.byte DL_JUMP_VB, <CommDspListAddr, >CommDspListAddr
		
TitleDLEnd = * - TitleDL		

;
; Next Level Display List
;
NextLevelDL 
		
		.rept 12
			.byte DL_BLANK_8
		.endr		
		.byte DL_LMS + DL_TEXT_6
		.byte <NEXT01, >NEXT01
		.byte DL_BLANK_8		
		.byte DL_BLANK_8		
		.byte DL_LMS + DL_TEXT_6
		.byte <NEXT02, >NEXT02
		.byte DL_BLANK_8		
		.byte DL_BLANK_8		
		.byte DL_LMS + DL_TEXT_6
		.byte <NEXT03, >NEXT03
		.rept 5
			.byte DL_BLANK_8
		.endr		
		.byte DL_JUMP_VB, <CommDspListAddr, >CommDspListAddr
		
NextLevelDLEnd = * - NextLevelDL		

;
; Completee Display List
;
CompleteDL 
		
		.rept 12
			.byte DL_BLANK_8
		.endr		
		.byte DL_LMS + DL_TEXT_6
		.byte <COMP01, >COMP01
		.byte DL_BLANK_8		
		.byte DL_BLANK_8		
		.byte DL_LMS + DL_TEXT_6
		.byte <COMP02, >COMP02
		.byte DL_BLANK_8		
		.byte DL_BLANK_8		
		.byte DL_LMS + DL_TEXT_6
		.byte <COMP03, >COMP03
		.rept 6
			.byte DL_BLANK_8
		.endr		
		.byte DL_JUMP_VB, <CommDspListAddr, >CommDspListAddr
		
CompleteDLEnd = * - CompleteDL		

;*****	TITLE Data
;			          1         2 
;  	         12345678901234567890
TITLE01	.sb "PLATFORM GAME ENGINE"
TITLE02	.sb "  FOR atari (8BIT)  "
TITLE03	.sb "    authorer by     "
TITLE04	.sb "        NRV         "
TITLE05	.sb "    contributers    "
TITLE06	.sb "    TATTOO ROSE     "	
TITLE07	.sb "    KEN JENNINGS    "	
TITLE08	.sb "    PRESS start     "	
	
;*****	Next Level Data
;			          1         2 
;  	         12345678901234567890
NEXT01	.sb "  LEVEL  COMPLETE   "  	
NEXT02  .sb " total time 00:00:0 "
NEXT03	.sb "    PRESS start     "	

;*****	Completed Data
;			          1         2 
;  	         12345678901234567890
COMP01	.sb "ALL LEVELS COMPLETED"  	
COMP02  .sb " total time 00:00:0 "
COMP03	.sb " thanks for playing "	
			
			