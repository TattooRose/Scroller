;
;***************************************************************************************************
;
;	Filename:		Scroller.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;	1 page 				= 256 bytes
;	1 K	   				= 004 pages - 1024 bytes	 
;	2 K	   				= 008 pages - 2048 bytes	 
;	3 K	   				= 012 pages - 3072 bytes	 
;	4 K	   				= 016 pages - 4096 bytes	 
;
;***** Memory Map - Atari 64K
;
;	$0000-$007F			zeropage for OS
;	$0080-$00FF 		zeropage for you
;	$0100-$01FF 		CPU stack
;	$0200-$02FF 		OS vector, registers
;	$0300-$03FF 		OS vector, registers
;	$0400-$05FF 		OS buffers
;	$0600-$06FF 		Page 6, object code in BASIC
;	$0700-$1FFF 		Disk Operating System
;	$2000-$7FFF 		User Code Area 
;	$8000-$BFFF 		Cartrige A and B slots
;	$C000-$CBFF 		OS part 1
;	$CC00-$CFFF 		OS character set, international
;	$D000-$D7FF			Hardware registers
;	$D800-$DFFF			FP Routines
;	$E000-$E3FF 		OS character set, standard
;	$E000-$FFFF 		OS part 2
;
;***** Include Library Files
;
		icl "/Lib/AtariEquates.Asm"				; Atari hardware DOS,OS,ANTIC,GITA,POKEY,PIA equates
		icl "/Lib/SysMacros.Asm"				; General purpose macros used by system
	
;***** Include Variable Files
;
		icl "ZeroPage.Asm"
		icl "Constants.Asm"

;*****	Memory map
;
ZeroPageAddress				= $80				; 122 bytes zero page ($80 to $F9) 
GameDspLstAddr				= $0E00				; 176 bytes for display list

HudMemoryAddr				= $0680				; Heads up display are (80 bytes)

SoundPlayerAddress			= $2400
DataAddress					= $3000				;  4K (size for data)
CodeAddress					= $4800				; 20K (22K zone)

SoundAddress				= $4000

PmgAddress					= $A000				; 40K (2K size - 768 bytes)
GameFontAddress				= $A800				; 42K (1K size)
TextFontAddress				= $AC00				; 39K (1K size)

GameMemoryAddress			= $B000				; 44K (4K size)

;
;**************************************************************************************************
; InitSystem - Start of code
;**************************************************************************************************
;
		org CodeAddress

InitSystem

		lda PAL									; only run in the correct system
		and #14

.if PAL_VERSION = 1

NO_PAL_loop
		bne NO_PAL_loop

.else

NO_NTSC_loop
		beq NO_NTSC_loop

.endif

		ClearSystem								; begin machine setup
		DisableBasic							; disable to use memory
		DisableOperatingSystem					; disable to use memory	
	
		SetRamTop #32							; pull memtop down 32 pages
				
		SetDisplayListInterrupt GameDli_01		; set the display list interrupts

		VcountWait 120							; make sure to wait so the setting take effect

		lda #GameDLEnd							; length of games display list data
		sta m_param00 							; store it for the load routine									
		SetVector m_paramW01, GameDL			; source of display list data
		SetVector m_paramW02, GameDspLstAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

;*****	InitHardware
;
InitHardware

		SetPMBaseAddress PmgAddress				; set the player missile address

		SetFontAddress GameFontAddress			; set the starting font address
		SetDisplayListAddress GameDspLstAddr	; set the display list address	

		VcountWait 120

		jsr SfxOff
		jsr InitVars							; begin initialization
		jsr InitLevelTable						; set up the level table		
				
;*****	Set the Registers
;				
		lda #0									; set the player info
		sta SIZEP0

		lda #%01010101							; double width for all missiles
		sta SIZEM

		lda #12									; set the HSCROL value
		sta HSCROL
	
		lda #0									; set the VSCROL value
		sta VSCROL
		
		lda #[NMI_DLI]							; enable DLI's (but no VBI's)
		sta NMIEN
		
		lda #GRACTL_OPTIONS						; apply GRACTL options
		sta GRACTL

		lda #PRIOR_OPTIONS						; apply PRIOR options
		sta PRIOR

		lda #DMACTL_OPTIONS						; apply DMACTL options
		sta DMACTL

		lda #0									; clear the hit register
		sta HITCLR

;*****	Load the starting level
;
		lda #$00								; set the starting level
		sta m_currLevelNum						; store it off

		sta m_param01							; store it to the parameter
		jsr LoadLevel							; load the level

		VcountWait 120

;*****	Initialize Level
;
		jsr InitPlatforms						; initialize floating platforms if any
		jsr InitGoldCounter						; gold initialization
		jsr InitEnemyManager					; enemy manager initialization
		jsr InitMissileSystem					; missile system initialization

		VcountWait 120
		
;*****	Set player position and draw
;		
		lda m_currLevelNum						; grab the current level
		sta m_param00							; store it in the parameter
		jsr SetSpawnPos							; set the spawn position for this level
		
		jsr SetPlayerScreenPos 					; fill in the players position
		jsr DrawPlayer							; draw the player

		VcountWait 120	
		
;*****	GameLoop
;
GameLoop
		
		lda m_stick0
		and #$0F
		cmp #$0F
		bne CheckState
		jmp CheckUserInput

CheckState
		
		lda m_playerState
		cmp #$02		
		beq JumpSound

		cmp #$03
		beq JumpSound
		
		jmp CheckUserInput
		
JumpSound
		
		lda #SFX_JUMP
		sta m_sfxEffect

;*****	Check User Input
;		
CheckUserInput

.if DEBUG_ON = 1

		ldx m_floatPlatformIdx
		dex
		
		lda m_playerState
		ldy #40
		jsr DisplayDebugInfoHexFF
		
		lda m_leftBottomChar
		ldy #43
		jsr DisplayDebugInfoHexFF
		
		lda m_rightBottomChar
		ldy #46
		jsr DisplayDebugInfoHexFF
		
		lda m_playerLevelLeftX_H1
		ldy #49
		jsr DisplayDebugInfoHexFF	
		
		lda m_playerLevelLeftX_H2
		ldy #52
		jsr DisplayDebugInfoHexFF	
		
		lda PlatformLSB,x
		ldy #55
		jsr DisplayDebugInfoHexFF	
		 		
		lda PlatformMSB,x
		ldy #58
		jsr DisplayDebugInfoHexFF	
		 		
		lda PlatformBaseLSB,x
		ldy #61
		jsr DisplayDebugInfoHexFF	

		lda PlatformBaseMSB,x
		ldy #64
		jsr DisplayDebugInfoHexFF	

.endif
		
		jsr CheckInput
		jsr UpdateTimers
		jmp (m_playerMethodPointer)
	
;*****	PlayerMethodReturn
;
PlayerMethodReturn
		lda m_playerState
		cmp #PS_LOSE
		beq PlayerEndStates
	
;*****	PlayerNormalStates	
;
PlayerNormalStates
		jsr UpdateCameraWindow
		jsr SetPlayerScreenPos
		jsr DrawPlayer
			
;*****	EnemyUpdate
;
EnemyUpdate
		jsr UpdateEnemyManager
	
;*****	MissilesStep
;
MissilesStep
		jsr UpdateMissileSystem
		jsr DrawEnemyExplosion
	
;*****	GameAnimations
;
GameAnimations
	
		jsr DoFontAnimations
		jsr UpdateCoinAnimations
		jsr UpdateInfoLine
		jsr SfxUpdate
				
		VcountWait 120
		
		jsr CheckPMCollisions
		jmp GameLoop
	
;*****	PlayerEndStates
;
PlayerEndStates
	
		jsr DrawPlayerExplosion
		jsr DoFontAnimations
		jsr UpdateCoinAnimations
		jsr UpdateMissileSystem
		jsr DrawEnemyExplosion
		jsr UpdateInfoLine
		jsr SetSpawnPos
		jsr SfxUpdate
								
		VcountWait 120
		
		lda #0
		sta HITCLR	
		
		jmp GameLoop

;*****	Includes base files
;
		icl "/Lib/SysProcs.Asm"

		icl "Initialize.Asm"				
		icl "DisplayListInterrupts.asm"
		icl "PlayerStates.Asm"
		icl "PlayerMovement.Asm"
		icl "MissileSystem.Asm"	
		icl "AnimationsLogic.Asm"	
		icl "CameraLogic.Asm"
		icl "EnemyManager.Asm"
		icl "FloatPlatform.Asm"
		icl "LevelLoader.Asm"
		icl "JoyKeyAndCollision.Asm"
		icl "AudioManager.Asm"
		icl "rmtplayr.asm"
		
;*****	End of code test
;
END_CODE_WARNING
	.if END_CODE_WARNING > PmgAddress 
		.error "Code overrides code area!"
	.endif

;*****	Player missle graphics address
;
		org PmgAddress
:768	.byte %00000000	
	
;*****	Missle starting address
;
		org ms_area_1
:1280 .byte %00000000

;*****	Level Data definition
;
		org DataAddress
		
		icl "Data/Levels.Asm"
		icl "ScrollerData.Asm"
		icl "PlayerData.Asm"
		
.PRINT "Data Size : ", * - DataAddress		

;*****	Game font address
;
		org GameFontAddress
		ins "data/scroller.fnt"
	
;*****	Text font address
;
		org TextFontAddress
		ins "data/atari.fnt"
	
;*****	Sound Data Address
;
		org SoundAddress
		opt h-									;RMT module is standard Atari binary file already
		ins "Data/sfx.rmt"						;include music RMT module
		opt h+
	
;*****	HUD Memory Address	
;
		org HudMemoryAddr							
		 
.if PAL_VERSION = 0
		.sb "  G 00    E 00    T 00:00.0  H 00 NTSC  "
.else
		.sb "  G 00    E 00    T 00:00.0  H 00  PAL  "
.endif
		.sb "                                        "
	
;*****	Game Memory Address 
;
		org GameMemoryAddress	
		.rept $1000-LEVEL_CHAR_SIZE_X
			.byte $00
		.endr
	
		; add extra line info to avoid problem with ladder in the last line	
		:LEVEL_CHAR_SIZE_X 		.byte $61

;*****	Run Address
;
		run InitSystem
