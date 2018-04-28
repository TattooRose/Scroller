;	
;**************************************************************************************************
;
;	Filename:		Scroller.Asm
;
;	Created By:		Victor V Ferenzi
;
;	Created On:		Wed Apr 18, 2018 12:30 PM
;
;	Comments:		Portions of this code are take from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
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


;***** Memory Allocation
; 				
ZeroPageAddr				= $80				; 128  bytes for the zero page variables
CodeAddr					= $2000				;  28K for the main code

GameDispList				= $0600				; 176  bytes for the game custom display list
HUDAddress					= $06B0				;  80  bytes for the heads up display (HUD)

DataAddr					= $9000				;   4K data area
PmAddress					= $A000				;  40K 2K size - 768 bytes
GameFontAddr				= $A800				;  42K 1K size
TextFontAddr				= $AC00				;  39K 1K size
 
GameScreenAddr				= $B000				;   4K Address for the game screen data 

;*****	Include Files
;
		icl "Lib/Atari_Equates.Asm"
		icl "Lib/sys_macros.asm"	
		icl "ZeroPageConstants.Asm"

;	
;**************************************************************************************************
; System Entry Point
;**************************************************************************************************
;
		org CodeAddr
		
Start
		
		ClearSystem								; initialize all registers
		DisableBasic							; disable basic
		DisableOperatingSystem					; disable the operating system 

		SetRamTop 32							; drop ramtop by 32 pages
	
		SetDisplayListInterrupt GameDli_01		; set the DLI's
		VcountWait 120							; Wait on a frame
		
		lda #GameDLEnd							; length of games display list data
		sta _param00 							; store it for the load routine									
		SetVector _paramW01, GameDL				; source of display list data
		SetVector _paramW02, GameDispList		; destination of display list data
		SetVector _cameraLabel, GameDL_LMS1		; set the cameras LMS address for this display list
		
		jsr LoadDisplayListData					; perform the DL data move

		SetPMBaseAddress PmAddress				; Set the player missile address		
		SetFontAddress GameFontAddr				; Set the initial font		
		SetDisplayListAddress GameDispList		; Set the games display list	

		lda #0									; set the player info
		sta SIZEP0

		lda #MISSILES_BITS						; double width for all missiles
		sta SIZEM

		lda #12									; 0 to 16 color clocks
		sta HSCROL
	
		lda #0									; 0 to 16 color clocks
		sta VSCROL

		lda #GRACTL_OPTIONS						; Enable/Disable Player/Missile DMA to GRAFxx registers. And latch triggers.
		sta GRACTL

		lda #PRIOR_OPTIONS						; Control Priority, Fifth Player and GTIA modes
		sta PRIOR

		lda #DMACTL_OPTIONS						; DMA control for display and Player/Missile graphics
		sta DMACTL

		VcountWait 120							; wait on a frame again

		jsr InitVars							; initialize the game variables
		
		lda #$80								; enable DLI's (but no VBI's)
		sta NMIEN
		    
		VcountWait 120
		
		lda #$00								; set up for level 1 (zero based)
		sta _param00							; store it off
		jsr LoadLevel							; call the method to draw the screen
		
		jsr InitGoldCounter 
		jsr InitEnemyManager

;***** GameLoop 
;
GameLoop
	
		jsr UpdateInfoLine						; Update the HUD area
		jsr DoFontAnimations

		lda #0									; Value to clear any hits 
		sta HITCLR								; Clear them

		VcountWait 120							; wait for the RTCLOCK to change

		jmp GameLoop							; Do it all over again

InitGoldCounter

		ldx #0									; line index

;****	1st Loop
; 
IGC_loop1
	
		ldy #0									; column index
	
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

;*****	2nd Loop
;
IGC_loop2

		lda (m_ptrLevelLine),y	
		stx m_pageZeroTempValue
		tax
		lda TabCharDefinition,x
		ldx m_pageZeroTempValue
	
		and #15
		cmp #CT_COLLECTABLE
		bne IGC_no_gold
	
		inc m_goldCounter

;*****	No Gold
;	
IGC_no_gold

		iny
		cpy m_levelCharSizeX
		bne IGC_loop2

;*****	Check Loop Y
;
IGC_check_loop_Y

		inx
		cpx m_levelCharSizeY
		bne IGC_loop1	
		rts

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
		
		rts
	
.endp				

;	
;**************************************************************************************************
; Include Files  
;**************************************************************************************************
;
		icl "Lib/sys_procs.asm"
		icl "Initialize.Asm"	
		icl "DispListInterrupts.Asm"
		icl "LevelLoader.Asm"
		icl "AnimationsLogic.Asm"
		icl "CameraLogic.Asm"
		icl "EnemyManager.Asm"
		icl "MissileSystem.Asm"		
		icl "PlayerMovement.Asm"

;
;**************************************************************************************************
; Data definition
;**************************************************************************************************
;
		org DataAddr
		icl "ScrollerData.Asm"
		icl "PlayerData.Asm"
		icl "Data/Levels.Asm"	

;	
;**************************************************************************************************
; HUD Address	
;**************************************************************************************************
;
		org HudAddress							

		; two rows of 40 characters for text mode
.if PAL_VERSION = 0
		.sb "  G 00    E 00    T 00:00.0       NTSC  "
.else
		.sb "  G 00    E 00    T 00:00.0        PAL  "
.endif
		.sb "                                        "

;	
;**************************************************************************************************
; Player Missle Address  
;**************************************************************************************************
;
		org PmAddress
		
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
; Game screen address - initializes the screen memory and clears it 
;**************************************************************************************************
;
		org GameScreenAddr
		
		; allocate 4K for the game screen
		.rept $1000-LEVEL_CHAR_SIZE_X
			.byte $00
		.endr			
		
		; extra line to help with hazards and ladders and etc....
		:LEVEL_CHAR_SIZE_X 		.byte $61

;		
;**************************************************************************************************
; Run System
;**************************************************************************************************
;
		run Start
