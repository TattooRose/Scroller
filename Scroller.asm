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
		icl "AtariEquates.Asm"					; Atari hardware DOS,OS,ANTIC,GITA,POKEY,PIA equates
		icl "SysMacros.Asm"						; General purpose macros used by system
	
;***** Include Variable Files
;
		icl "ZeroPage.Asm"
		icl "Constants.Asm"

;*****	Memory map
;
ZeroPageAddress				= $80				; 122 bytes zero page ($80 to $F9) 
CommDspListAddr				= $0E00				; 176 bytes for display list

HudMemoryAddress			= $06B0				; Heads up display are

SoundPlayerAddress			= $2400
DataAddress					= $3000				;  4K (size for data)
SoundAddress				= $4000

CodeAddress					= $4300				; 23K zone for code with new rmt file this should be adjusted

PmgAddress					= $A000				; 40K (2K size - 768 bytes)
GameFontAddress				= $A800				; 42K (1K size)
TextFontAddress				= $AC00				; 39K (1K size)

GameMemoryAddress			= $B000				; 44K (4K size)

;*****	moved here for better access
;
DEBUG_ON					= 1					 

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

;*****	Set initial level
;		
		lda #$00								; set the starting level
		sta m_currLevelNum						; store it off
		
;*****	Show the title screen
;
ShowTitle

		jsr TitleScreen							; Show the tile screen

;*****	Set player spawn
;		
		jsr SetSpawnPos							; set the spawn position for this level		

;*****	Play Level Loop
;	
PlayLevelLoop
	
		jsr PlayLevel	
		
		inc m_currLevelNum
		lda m_currLevelNum		
		cmp #MAX_GAME_LEVELS		
		bcs LevelDone
		
		jsr NextLevelScreen
		
		jmp PlayLevelLoop	
		
;*****	Level Done
;
LevelDone		
		
		jsr GameOver				

;*****	Scroller Loop
;
ScrollerLoop

		jmp ScrollerLoop						; infinite loop
;
;**************************************************************************************************
; End Start of code
;**************************************************************************************************
;

;
;**************************************************************************************************
;	InitAndLoadLevel
;**************************************************************************************************
;
.proc InitAndLoadLevel

		ClearPlatformMemory
		ClearLevelLineMemory

		lda #<HudMemoryAddress					; set the text display address
		sta m_hudMemoryAddress					; store the LSB
		lda #>HudMemoryAddress					; set the text display address
		sta m_hudMemoryAddress+1				; store the MSB

		SetDisplayListInterrupt GameDli_01		; set the display list interrupts
		VcountWait 120							; make sure to wait so the setting takes effect
		
		lda #GameDLEnd							; length of games display list data
		sta m_param00 							; store it for the load routine		
							
		SetVector m_paramW01, GameDL			; source of display list data
		SetVector m_paramW02, CommDspListAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

;*****	Housekeeping
;
		jsr SfxOff
		jsr InitVars							; begin initialization
		
		VcountWait 120							; make sure to wait so the setting takes effect

;*****	Set the addresses
;
SetAddresses

		SetPMBaseAddress PmgAddress				; set the player missile address
		SetFontAddress GameFontAddress			; set the starting font address
		SetDisplayListAddress CommDspListAddr	; set the display list address	

		VcountWait 120							; make sure to wait so the setting takes effect
				
;*****	InitHardware
;
InitHardware

		lda #%01010101							; double width for all missiles
		sta SIZEM								; store it

		lda #12									; set the HSCROL value
		sta HSCROL								; store it	
	
		lda #0									; set the VSCROL value
		sta VSCROL								; store it
		
		lda #[NMI_DLI]							; enable DLI's (but no VBI's)
		sta NMIEN								; store it
		
		lda #GRACTL_OPTIONS						; apply GRACTL options
		sta GRACTL								; store it

		lda #PRIOR_OPTIONS						; apply PRIOR options
		sta PRIOR								; store it

		lda #DMACTL_OPTIONS						; apply DMACTL options
		sta DMACTL								; store it

		lda #0									; clear the hit register
		sta HITCLR								; store it

;*****	Set character data address for horizontal platforms
;
		lda #$08
		ldx #$26
		jsr MultiplyAX
		
		clc
		lda #<GameFontAddress
		adc _productLo
		sta m_platformGameCharAddr_H
		lda #>GameFontAddress
		adc _productHi
		sta m_platformGameCharAddr_H+1
		
;*****	Load the starting level
;	
		lda m_currLevelNum						; grab the current level number
		sta m_param00							; store it to the parameter

		jsr LoadLevel							; load the level

;*****	Initialize Level
;
		jsr InitPlatforms						; initialize floating platforms if any
		jsr InitGoldCounter						; gold initialization
		jsr InitEnemyManager					; enemy manager initialization
		jsr InitMissileSystem					; missile system initialization

		VcountWait 120							; make sure to wait so the setting takes effect

		rts

.endp

;
;**************************************************************************************************
;	TitleScreen
;**************************************************************************************************
;
.proc TitleScreen

		jsr SfxOff

		lda #<TITLE06
		sta m_hudMemoryAddress
		lda #>TITLE06
		sta m_hudMemoryAddress+1

		lda #TitleDLEnd							; length of Menu display list data
		sta m_param00 							; store it for the load routine		
							
		SetVector m_paramW01, TitleDL			; source of display list data
		SetVector m_paramW02, CommDspListAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

		SetFontAddress TextFontAddress			; set the starting font address
		SetDisplayListAddress CommDspListAddr	; set the display list address	

		VcountWait 120							; make sure to wait so the setting takes effect

		SetColor $00, $03, $08
		SetColor $01, $0C, $0A
		
		lda #GRACTL_OPTIONS | TRIGGER_LATCH		; apply GRACTL options
		sta GRACTL								; store it

		lda #DMACTL_OPTIONS						; apply DMACTL options
		sta DMACTL								; store it

		jsr CheckMenuInput
			
;*****	Common exit section to return
Exit
		jsr SfxOff
		rts
		
.endp

;
;**************************************************************************************************
;	TitleScreen
;**************************************************************************************************
;
.proc NextLevelScreen
		
		jsr SfxOff
		jsr ClearPlatformMemory
		jsr ClearLevelLineMemory
		
		lda #<NEXT02
		sta m_hudMemoryAddress
		lda #>NEXT02
		sta m_hudMemoryAddress+1

		lda m_gameTimerMinutes
		ldy #12
		jsr DisplayDebugInfoBinary99
	
		lda m_gameTimerSeconds
		ldy #15
		jsr DisplayDebugInfoBinary99
	
		lda m_gameTimerTSeconds
		ldy #18
		jsr DisplayDebugInfoBinary9

		lda #NextLevelDLEnd						; length of Menu display list data
		sta m_param00 							; store it for the load routine		
							
		SetVector m_paramW01, NextLevelDL		; source of display list data
		SetVector m_paramW02, CommDspListAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

		SetFontAddress TextFontAddress			; set the starting font address
		SetDisplayListAddress CommDspListAddr	; set the display list address	

		VcountWait 120							; make sure to wait so the setting takes effect

		SetColor $00, $03, $08
		SetColor $01, $0C, $0A
		
		lda #GRACTL_OPTIONS | TRIGGER_LATCH		; apply GRACTL options
		sta GRACTL								; store it

		lda #DMACTL_OPTIONS						; apply DMACTL options
		sta DMACTL								; store it

		jsr CheckMenuInput
			
;*****	Common exit section to return
Exit
		jsr SfxOff
		rts
		
.endp
						
;
;**************************************************************************************************
;	GameOver
;**************************************************************************************************
;
.proc GameOver

		jsr SfxOff
		jsr ClearPlatformMemory
		jsr ClearLevelLineMemory

		lda #<COMP02
		sta m_hudMemoryAddress
		lda #>COMP02
		sta m_hudMemoryAddress+1
		
		lda m_gameTimerMinutes
		ldy #12
		jsr DisplayDebugInfoBinary99
	
		lda m_gameTimerSeconds
		ldy #15
		jsr DisplayDebugInfoBinary99
	
		lda m_gameTimerTSeconds
		ldy #18
		jsr DisplayDebugInfoBinary9

		lda #CompleteDLEnd						; length of Menu display list data
		sta m_param00 							; store it for the load routine		
							
		SetVector m_paramW01, CompleteDL		; source of display list data
		SetVector m_paramW02, CommDspListAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

		SetFontAddress TextFontAddress			; set the starting font address
		SetDisplayListAddress CommDspListAddr	; set the display list address	

		VcountWait 120							; make sure to wait so the setting takes effect

		SetColor $00, $03, $08
		SetColor $01, $0C, $0A
		
		lda #GRACTL_OPTIONS | TRIGGER_LATCH		; apply GRACTL options
		sta GRACTL								; store it

		lda #DMACTL_OPTIONS						; apply DMACTL options
		sta DMACTL								; store it

		jsr CheckMenuInput
			
;*****	Common exit section to return
Exit
		jsr SfxOff
		rts
		
.endp
						
;
;**************************************************************************************************
;	PlayLevel
;**************************************************************************************************
;
.proc PlayLevel

;*****	Start Level
;
StartLevel

		lda #$00								; reset the game timer
		sta m_disableGameTimer					; to a zero value
		
		jsr InitAndLoadLevel
		jsr SetSpawnPos							; set the spawn position for this level		
		
		VcountWait 120

;*****	Main target label for looping
;
Loop		
		lda m_stick0
		and #$0F
		cmp #$0F
		bne CheckState
		jmp CheckUserInput

;*****	Check th players state
;
CheckState
		
		lda m_playerState
		cmp #$02		
		beq JumpSound
*
		cmp #$03
		beq JumpSound
		
		jmp CheckUserInput
		
;*****	Set the jump sound
;
JumpSound
		
		lda #SFX_JUMP
		and #$0f
		sta m_sfxEffect
		
;*****	Check User Input
;		
CheckUserInput

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
	
		jsr AnimatePlatformH		
		jsr DoFontAnimations
		jsr UpdateCoinAnimations
		jsr UpdateInfoLine
		jsr SfxUpdate
				
		VcountWait 120
		
		jsr CheckPMCollisions		
		jsr DebugInfo
		
		lda m_disableGameTimer	
		bne Exit		
		
		jmp Loop
	
;*****	PlayerEndStates
;
PlayerEndStates		

		lda SFX_DEATH
		and #$0F
		sta m_sfxEffect

		jsr AnimatePlatformH		
		jsr DrawPlayerExplosion
		jsr DoFontAnimations
		jsr UpdateCoinAnimations
		jsr UpdateMissileSystem
		jsr DrawEnemyExplosion
		jsr UpdateInfoLine
		jsr SfxUpdate
		jsr DebugInfo				

		VcountWait 120

		lda #0
		sta HITCLR	

		jmp Loop		
		
;*****	Exit Play Level - Cleanup
;
Exit
		jsr SfxOff
		rts
		
.endp

;
;**************************************************************************************************
;	DebugInfo
;**************************************************************************************************
;
.proc DebugInfo

.if DEBUG_ON = 1

		lda TabHardwareCollision
		ldy #40
		jsr DisplayDebugInfoHexFF
		
		lda TabHardwareCollision+1
		ldy #43
		jsr DisplayDebugInfoHexFF
		
		lda TabHardwareCollision+2
		ldy #46
		jsr DisplayDebugInfoHexFF
					
		lda TabHardwareCollision+3
		ldy #49
		jsr DisplayDebugInfoHexFF

		lda TabHardwareCollision+4
		ldy #52
		jsr DisplayDebugInfoHexFF
		
		lda TabHardwareCollision+5
		ldy #55
		jsr DisplayDebugInfoHexFF
		
		lda TabHardwareCollision+6
		ldy #58
		jsr DisplayDebugInfoHexFF
					
		lda TabHardwareCollision+7
		ldy #61
		jsr DisplayDebugInfoHexFF
					
		lda TabHardwareCollision+8
		ldy #64
		jsr DisplayDebugInfoHexFF
					
		lda TabHardwareCollision+9
		ldy #67
		jsr DisplayDebugInfoHexFF
					
		lda TabHardwareCollision+10
		ldy #70
		jsr DisplayDebugInfoHexFF
					
		lda TabHardwareCollision+11
		ldy #73
		jsr DisplayDebugInfoHexFF
					
.endif
		
		rts
.endp

;*****	Includes base files
;
		icl "SysProcs.Asm"
		icl "Initialize.Asm"
		icl "Utilities.Asm"				
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
		.error "Code overrides PMG area!"
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
		org HudMemoryAddress							
		 
.if PAL_VERSION = 0
		.sb "  G 00    E 00    T 00:00.0  H 00 NTSC  "
.else
		.sb "  G 00    E 00    T 00:00.0  H 00  PAL  "
.endif
		.sb "                                        "
		
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
