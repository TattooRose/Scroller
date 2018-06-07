;
;***************************************************************************************************
;
;	Filename:		AtariEquates.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************
; OS memory and vectors
;
RTCLOK 						= $12 				; and $13, and $14.  
RTCLOK60 					= $14 				; incremented every jiffy/frame.

ATRACT 						= $4D
VDSLST 						= $0200 			; Display List interrupt.

;
;**************************************************
; DOS - Misc values related to DOS and file loading
;
LOMEM_DOS 					= $2000 			; First usable memory after DOS
LOMEM_DOS_DUP 				= $3308 			; First usable memory after DOS and DUP 

;**************************************************	
; Atari RUN ADDRESS.  
;
; 	The binary load file has a segmented structure 
; 	specifying starting address, and ending address, 
; 	followed by the bytes to load in that memory range.  
;
; 	DOS observes two special addresses when loading data.
; 	If the contents of the INIT address changes ater loading
; 	a segment DOS calls that address immediately. If the routine
; 	returns to DOS cleanly then file loading continues.
;
; 	If the contents of the RUN address changes DOS waits until
; 	all segments from the file are loaded and then calls the RUN
; 	address target.
;
DOS_RUN_ADDR 				= $02e0				; Execute here when file loading completes.
DOS_INIT_ADDR 				= $02e2				; Execute here immediately then resume loading.

;**************************************************	
; ANTIC - Register List
;
DMACTL 						= $D400				; DMA control for display and Player/Missile graphics
CHACTL 						= $D401				; Character display control
DLISTL 						= $D402				; Display List Pointer (low)
DLISTH 						= $D403				; Display List Pointer (high)
HSCROL 						= $D404				; Horizontal Fine Scroll 0 to 16 color clocks.
VSCROL 						= $D405				; Vertical Fine Scroll 0 to 16 scanlines.
PMBASE 						= $D407				; Player/Missile Base Address (high) 
CHBASE 						= $D409				; Character Set Base Address (high)
WSYNC 						= $D40A				; Wait for Horizontal Sync
VCOUNT 						= $D40B				; (Read) Vertical Scan Line Counter
PENH 						= $D40C				; (Read) Light Pen Horizontal Position
PENV 						= $D40D				; (Read) Light Pen Vertical Position
NMIEN 						= $D40E				; Non-Maskable Interupt (NMI) Enable
NMIRES 						= $D40F				; (Write) Non-Maskable Interrupt (NMI) Reset
NMIST 						= $D40F				; (Read)  Non-Maskable Interrupt Status                   	
                   	;
;**************************************************
; Handler vectors:
;
NMIH_VECTOR					= $FFFA
RESH_VECTOR					= $FFFC
IRQH_VECTOR					= $FFFE

;**************************************************	
; Shadow Registers for Hardware Registers
;
SDMCTL 						= $022F 			; DMACTL
SDLSTL 						= $0230 			; DLISTL
SDLSTH 						= $0231 			; DLISTH
CHBAS 						= $02F4 			; CHBASE
CHART 						= $02F3 			; CHACTL
LPENH 						= $0234 			; (Read) PENH
LPENV 						= $0235 			; (Read) PENV

;**************************************************	
; Important Bit Positions
;
;**************************************************
; DMACTL and SDMCTL - DMA control for display and Player/Missile graphics
;
MASK_DL_DMA 				= %11011111			; Enable/Disable DMA to read the Display List
MASK_PM_RESOLUTION 			= %11101111			; Set P/M graphics DMA to 1 or 2 scan line per update  
MASK_PM_DMA 				= %11110011			; Enable/Disable DMA for Players/Missiles
MASK_PLAYFIELD_WIDTH 		= %11111100			; Enable playfield display/set playfield width

;**************************************************	
; DMACTL and SDMCTL - Enable/Disable DMA to read the Display List
;
ENABLE_DL_DMA 				= %00100000
DISABLE_DL_DMA 				= %00000000			; defining this is overkill

;**************************************************	
; DMACTL and SDMCTL - Set P/M graphics DMA to 1 or 2 scan line per update  
;
PM_1LINE_RESOLUTION 		= %00010000
PM_2LINE_RESOLUTION 		= %00000000

;**************************************************	
; DMACTL and SDMCTL - Enable DMA for Players/Missiles
;
ENABLE_PLAYER_DMA 			= %00001000
ENABLE_MISSILE_DMA 			= %00000100
ENABLE_PM_DMA 				= %00001100

;**************************************************	
; DMACTL and SDMCTL - Enable playfield display/set playfield width
;
PLAYFIELD_DISABLE 			= %00000000			; No width is the same as no display
PLAYFIELD_WIDTH_NARROW_MASK	= %00000001			; 32 characters/128 color clocks
PLAYFIELD_WIDTH_NORMAL_MASK	= %00000010			; 40 characters/160 color clocks
PLAYFIELD_WIDTH_WIDE_MASK	= %00000011			; 48 characters/192 color clocks (176 visible)

;**************************************************	
; CHACTL - Character display control
;
MASK_CHACTL_REFLECT 		= %11111011			; Enable/Disable vertical reflect
MASK_CHACTL_INVERSE 		= %11111101			; Enable/Disable characters with high bit set displayed as inverse 
MASK_CHACTL_BLANK 			= %11111110			; Enable/Disable characters with high bit set displayed as blank space

;**************************************************	
; CHACTL - Enable character display options
; 
CHACTL_REFLECT 				= %00000100 		; Enable vertical reflect
CHACTL_INVERSE 				= %00000010 		; Enable inverse display for characters with high bit set
CHACTL_BLANK 				= %00000001 		; Enable blank display for characters with high bit set

;**************************************************	
; NMIEN (NMIRES and NMIST) - Non-Maskable Interupt (NMI) Reset and Status
;
MASK_NMI_DLI 				= %01111111 		; Enable/Disable Display List Interrupts
MASK_NMI_VBI 				= %10111111 		; Enable/Disable Vertical Blank Interrupt
MASK_NMI_RESET 				= %11011111 		; Enable/Disable Reset Key Interrupt

;**************************************************	
; NMIEN (NMIRES and NMIST) - Enable Non-Maskable Interupts
;
NMI_DLI 					= %10000000 		; Enable Display List Interrupts
NMI_VBI 					= %01000000 		; Enable Vertical Blank Interrupt
NMI_RESET 					= %00100000 		; Enable Reset Key Interrupt

;**************************************************	
; Display List Instructions/Options Mask
;
MASK_DL_DLI 				= %01111111 		; Display List Interrupt on last scan line of graphics line
MASK_DL_LMS 				= %10111111 		; Reload Memory Scan address for this graphics line
MASK_DL_VSCROLL 			= %11011111 		; Vertical scrolling for this graphics line
MASK_DL_HSCROLL 			= %11101111 		; Horizontal scrolling for this graphics line
MASK_DL_MODE 				= %11110000 		; Text/Graphics Modes

;**************************************************	
; Display List Instruction Options
;
DL_DLI 						= %10000000 		; Enable Display List Interrupt on last scan line of graphics line
DL_LMS 						= %01000000 		; Enable Reload Memory Scan address for this graphics line
DL_VSCROLL 					= %00100000 		; Enable Vertical scrolling for this graphics line
DL_HSCROLL 					= %00010000 		; Enable Horizontal scrolling for this graphics line
DL_MODE 					= %00001111 		; Collection of Text/Graphics Modes

;**************************************************	
; Display List Instructions, Jump 
;
DL_JUMP 					= $01				; Display List jump to new address
DL_JUMP_VB 					= $41				; Display List jump to address and start Vertical Blank
                        	
;**************************************************	
; Display List Instructions, blank scan lines
;
; 	Note: Bit $80 is not part of this, so the
; 	DL_DLI Instruction Option is available for 
; 	the blank line instructions.
;
DL_BLANK_1 					= $00 				; 1 Blank Scan line
DL_BLANK_2 					= $10 				; 2 Blank Scan lines
DL_BLANK_3 					= $20 				; 3 Blank Scan lines
DL_BLANK_4 					= $30 				; 4 Blank Scan lines
DL_BLANK_5 					= $40 				; 5 Blank Scan lines
DL_BLANK_6 					= $50 				; 6 Blank Scan lines
DL_BLANK_7 					= $60 				; 7 Blank Scan lines
DL_BLANK_8 					= $70 				; 8 Blank Scan lines

;**************************************************	
; Display List Instructions, Text Modes
;
DL_TEXT_2 					= $02 				; 1.5 Color, 40 Columns X  8 Scan lines
DL_TEXT_3 					= $03 				; 1.5 Color, 40 Columns X 10 Scan lines
DL_TEXT_4 					= $04 				; 4/5 Color, 40 Columns X  8 Scan lines
DL_TEXT_5 					= $05 				; 4/5 Color, 40 Columns X 16 Scan lines
DL_TEXT_6 					= $06 				;   5 Color, 20 Columns X  8 Scan lines
DL_TEXT_7 					= $07 				;   5 Color, 20 Columns X 16 Scan lines

;**************************************************	
; Display List Instructions, Map Modes
;
DL_MAP_8 					= $08 				;   4 Color,  40 Pixels X   8 Scan Lines
DL_MAP_9 					= $09 				;   2 Color,  80 Pixels X   4 Scan Lines
DL_MAP_A 					= $0A 				;   4 Color,  80 Pixels X   4 Scan Lines
DL_MAP_B 					= $0B 				;   2 Color, 160 Pixels X   2 Scan Lines
DL_MAP_C 					= $0C 				;   2 Color, 160 Pixels X   1 Scan Lines
DL_MAP_D 					= $0D 				;   4 Color, 160 Pixels X   2 Scan Lines
DL_MAP_E 					= $0E 				;   4 Color, 160 Pixels X   1 Scan Lines
DL_MAP_F 					= $0F 				; 1.5 Color, 320 Pixels X   1 Scan Lines (and GTIA modes)

;**************************************************	
; GTIA - Register List
;
;**************************************************	
; Hardware Registers
;
HPOSP0 						= $D000 			; Player 0 Horizontal Position
HPOSP1 						= $D001 			; Player 1 Horizontal Position
HPOSP2 						= $D002 			; Player 2 Horizontal Position
HPOSP3 						= $D003 			; Player 3 Horizontal Position
                        	
HPOSM0 						= $D004 			; Missile 0 Horizontal Position
HPOSM1 						= $D005 			; Missile 1 Horizontal Position
HPOSM2 						= $D006 			; Missile 2 Horizontal Position
HPOSM3 						= $D007 			; Missile 3 Horizontal Position
;;     						        			
SIZEP0 						= $D008 			; Player 0 Size
SIZEP1 						= $D009 			; Player 1 Size
SIZEP2 						= $D00A 			; Player 2 Size
SIZEP3 						= $D00B 			; Player 3 Size
SIZEM 						= $D00C 			; Missiles Sizes (2 bits per missile)
                        	
GRAFP0 						= $D00D 			; Player 0 Graphics Pattern
GRAFP1 						= $D00E 			; Player 1 Graphics Pattern
GRAFP2 						= $D00F 			; Player 2 Graphics Pattern
GRAFP3 						= $D010 			; Player 3 Graphics Pattern
GRAFM 						= $D011 			; Missile Graphics Pattern (2 bits per missile)
                        	
M0PF 						= $D000 			; (Read) Missile 0 to Playfield collisions
M1PF 						= $D001 			; (Read) Missile 1 to Playfield collisions
M2PF 						= $D002 			; (Read) Missile 2 to Playfield collisions
M3PF 						= $D003 			; (Read) Missile 3 to Playfield collisions
   					    	    			
P0PF 						= $D004 			; (Read) Player 0 to Playfield collisions
P1PF 						= $D005 			; (Read) Player 1 to Playfield collisions
P2PF 						= $D006 			; (Read) Player 2 to Playfield collisions
P3PF 						= $D007 			; (Read) Player 3 to Playfield collisions
   					    	    			
M0PL 						= $D008 			; (Read) Missile 0 to Player collisions
M1PL 						= $D009 			; (Read) Missile 1 to Player collisions
M2PL 						= $D00A 			; (Read) Missile 2 to Player collisions
M3PL 						= $D00B 			; (Read) Missile 3 to Player collisions
   					    	    			
P0PL 						= $D00C 			; (Read) Player 0 to Player collisions
P1PL 						= $D00D 			; (Read) Player 1 to Player collisions
P2PL 						= $D00E 			; (Read) Player 2 to Player collisions
P3PL 						= $D00F 			; (Read) Player 3 to Player collisions
                        	
COLPM0 						= $D012 			; Player/Missile 0 color, GTIA 9-color playfield color 0 for Background
COLPM1 						= $D013 			; Player/Missile 1 color, GTIA 9-color playfield color 1
COLPM2 						= $D014 			; Player/Missile 2 color, GTIA 9-color playfield color 2
COLPM3 						= $D015 			; Player/Missile 3 color, GTIA 9-color playfield color 3
       						        			
COLPF0 						= $D016 			; Playfield 0 color
COLPF1 						= $D017 			; Playfield 1 color
COLPF2 						= $D018 			; Playfield 2 color
COLPF3 						= $D019 			; Playfield 3 color (and fifth Player color)
COLBK 						= $D01A 			; Playfield Background color
                        	
TRIG0 						= $D010 			; (Read) Joystick 0 trigger
TRIG1 						= $D011 			; (Read) Joystick 1 trigger
TRIG2 						= $D012 			; (Read) Joystick 2 trigger
TRIG3 						= $D013 			; (Read) Joystick 3 trigger
    						        				
PAL    						= $D014 			; (Read) PAL Flag
PRIOR  						= $D01B 			; Control Priority, Fifth Player and GTIA modes
VDELAY 						= $D01C 			; Player Missile Vertical Delay
GRACTL 						= $D01D 			; Graphics Control, P/M DMA and joystick trigger latches
HITCLR 						= $D01E 			; Clear Player/Missile Collisions
     						        			
CONSOL 						= $D01F 			; (Read) Start, Select, Option console keys.
CONSPK 						= $D01F 			; Console speaker.

;**************************************************	
; Shadow Registers for Hardware Registers
;
STRIG0 						= $0284				; (Read) TRIG0 - Joystick 0 trigger
STRIG1 						= $0285				; (Read) TRIG1 - Joystick 1 trigger
STRIG2 						= $0286				; (Read) TRIG2 - Joystick 2 trigger
STRIG3 						= $0287				; (Read) TRIG3 - Joystick 3 trigger
                        	
PCOLOR0 					= $02C0				; COLPM0 - Player/Missile 0 color, GTIA 9-color playfield color 0 for Background
PCOLOR1 					= $02C1				; COLPM1 - Player/Missile 1 color, GTIA 9-color playfield color 1
PCOLOR2 					= $02C2				; COLPM2 - Player/Missile 2 color, GTIA 9-color playfield color 2
PCOLOR3 					= $02C3				; COLPM3 - Player/Missile 3 color, GTIA 9-color playfield color 3
                      	
COLOR0 						= $02C4				; COLPF0 - Playfield 0 color
COLOR1 						= $02C5				; COLPF1 - Playfield 1 color
COLOR2 						= $02C6				; COLPF2 - Playfield 2 color
COLOR3 						= $02C7				; COLPF3 - Playfield 3 color (and fifth Player color)
COLOR4 						= $02C8				; COLBK  - Playfield Background color
     						        				
GPRIOR 						= $026F				; PRIOR - Control Priority, Fifth Player and GTIA modes

;**************************************************	
; Important Bit Positions
;		
;	SIZEP0 - SIZEP3
;
PLAYER_SIZE_BITS 			= %00000011
PM_SIZE_NORMAL 				= %00000000 		; One color clock per Player/Missile pixel
PM_SIZE_DOUBLE 				= %00000001 		; Two color clocks per Player/Missile pixel
PM_SIZE_QUAD 				= %00000011 		; Fopur color clocks per Player/Missile pixel

;**************************************************	
; SIZEM and GRAFM (and missile memory)
;
MASK_MISSILE0_BITS 			= %11111100
MASK_MISSILE1_BITS 			= %11110011
MASK_MISSILE2_BITS 			= %11001111
MASK_MISSILE3_BITS 			= %00111111
                        	
MISSILE0_BITS 				= %00000011
MISSILE1_BITS 				= %00001100
MISSILE2_BITS 				= %00110000
MISSILE3_BITS 				= %11000000
MISSILES_BITS				= %01010101
 
;**************************************************	
; Collisions MxPF, MxPL, PxPF, PxPL
;
; 	COLPMx or COLPFx where X is bits 0 through 3
;
MASK_COLPMF0_BIT 			= %11111110 		; Player or Missile v Player or Playfield color 0
MASK_COLPMF1_BIT 			= %11111101 		; Player or Missile v Player or Playfield color 1
MASK_COLPMF2_BIT 			= %11111011 		; Player or Missile v Player or Playfield color 2
MASK_COLPMF3_BIT 			= %11110111 		; Player or Missile v Player or Playfield color 3
                      	
COLPMF0_BIT 				= %00000001 		; Player or Missile v Player or Playfield color 0
COLPMF1_BIT 				= %00000010 		; Player or Missile v Player or Playfield color 1
COLPMF2_BIT 				= %00000100 		; Player or Missile v Player or Playfield color 2
COLPMF3_BIT 				= %00001000 		; Player or Missile v Player or Playfield color 3

;**************************************************	
; Colors Registers
;
COLOR_BITS 					= %11110000
LUMA_BITS 					= %00001111

;**************************************************	
; PRIOR and GPRIOR - Control Priority, Fifth Player and GTIA modes
;
MASK_PRIORITY 				= %11110000 		; Player/Missile, Playfield priority
MASK_F.ifH_PLAYER 			= %11101111 		; Enable/Disable Fifth Player
MASK_MULTICOLOR_PM 			= %11011111 		; Enable/Disable Player color mixing
MASK_GTIA_MODE 				= %00111111 		; Enable/Disable GTIA playfield modes
                        	           
PM_PRIORITY_1				= %00000001
PM_PRIORITY_2				= %00000010
PM_PRIORITY_3				= %00000100
PM_PRIORITY_4				= %00001000       
                 	            		
PRIORITY_BITS 				= %00001111 		; Player/Missile, Playfield priority
FIFTH_PLAYER 				= %00010000 		; Enable Fifth Player
MULTICOLOR_PM 				= %00100000 		; Enable Player color mixing
                        	            		
GTIA_MODE_DEFAULT 			= %00000000 		; Normal CTIA color interpretation
GTIA_MODE_16_SHADE 			= %01000000 		; 16 shades of background color (COLBK)
GTIA_MODE_9_COLOR 			= %10000000 		; 9 colors from registers, COLPM0 is background
GTIA_MODE_16_COLOR 			= %11000000 		; 16 hues of brigntess of background color (COLBK)

;**************************************************	
; VDELAY - Delay PM DMA to render 2 scan line Player data one scan line lower 
;
MASK_VD_MISSILE0 			= %11111110
MASK_VD_MISSILE1 			= %11111101
MASK_VD_MISSILE2 			= %11111011
MASK_VD_MISSILE3 			= %11110111
MASK_VD_PLAYER0 			= %11101111
MASK_VD_PLAYER1 			= %11011111
MASK_VD_PLAYER2 			= %10111111
MASK_VD_PLAYER3 			= %01111111
                        	
VD_MISSILE0 				= %00000001
VD_MISSILE1 				= %00000010
VD_MISSILE2 				= %00000100
VD_MISSILE3 				= %00001000
VD_PLAYER0 					= %00010000
VD_PLAYER1 					= %00100000
VD_PLAYER2 					= %01000000
VD_PLAYER3 					= %10000000

;**************************************************	
; GRACTL - Enable/Disable Player/Missile DMA to GRAFxx registers. And latch triggers.
;
MASK_ENABLE_MISSILES 		= %11111110 		; Enable/Disable Missile DMA to GRAFM register
MASK_ENABLE_PLAYERS 		= %11111101 		; Enable/Disable Player DMA to GRAFPx registers
MASK_TRIGGER_LATCH 			= %11111011 		; Enable/Disable jostick trigger latching
                        	          		
ENABLE_MISSILES 			= %00000001 		; Enable Missile DMA to GRAFM register
ENABLE_PLAYERS 				= %00000010 		; Enable Player DMA to GRAFPx registers
TRIGGER_LATCH 				= %00000100 		; Enable joystick trigger latching

;**************************************************	                                  			
; CONSOL and CONSPK - 0 is key pressed
;
MASK_CONSOLE_KEYS 			= %11111000
MASK_CONSOLE_START 			= %11111110 		; Start button
MASK_CONSOLE_SELECT 		= %11111101 		; Select button
MASK_CONSOLE_OPTION 		= %11111011 		; Option button
MASK_CONSOLE_SPEAKER 		= %11110111 		; (Write) Keyboard speaker
                        	
CONSOLE_START 				= %00000001 		; Start button
CONSOLE_SELECT 				= %00000010 		; Select button
CONSOLE_OPTION 				= %00000100 		; Option button
CONSOLE_SPEAKER 			= %00001000 		; (Wrie) Keyboard speaker

;**************************************************
; Other Value Lists 
;
; 	Sizes in horizontal color clocks and vertical scan lines
;
PLAYFIELD_WIDTH_NARROW 		= %10000000			; Color Clocks Normal Width = 128
PLAYFIELD_WIDTH_NORMAL 		= %10100000			; Color Clocks Normal Width = 160
PLAYFIELD_WIDTH_WIDE 		= %10110000			; Color Clocks Normal Width = 176

PLAYFIELD_LEFT_EDGE_NARROW 	= %01000000 		; First/left-most color clock horizontal position
PLAYFIELD_LEFT_EDGE_NORMAL 	= %00110000
PLAYFIELD_LEFT_EDGE_WIDE 	= %00101000

PLAYFIELD_RIGHT_EDGE_NARROW = %10111111 		; Last/right-most color clock horizontal position
PLAYFIELD_RIGHT_EDGE_NORMAL = %11001111
PLAYFIELD_RIGHT_EDGE_WIDE 	= %11010111

;**************************************************	
; PMBASE offsets to Player or Missile addresses
;
PMADR_2LINE_MISSILES 		= $180 
PMADR_2LINE_PLAYER0 		= $200
PMADR_2LINE_PLAYER1 		= $280
PMADR_2LINE_PLAYER2 		= $300
PMADR_2LINE_PLAYER3 		= $380

PMADR_1LINE_MISSILES 		= $300
PMADR_1LINE_PLAYER0 		= $400
PMADR_1LINE_PLAYER1 		= $500
PMADR_1LINE_PLAYER2 		= $600
PMADR_1LINE_PLAYER3 		= $700

;**************************************************	
; Vertical Alignments - screen scanlines are offsets into PMADR memory locations
;
PM_2LINE_OVERSCAN_TOP 		= $04
PM_2LINE_NORMAL_TOP 		= $10 				; For default OS 192 scan line display
PM_2LINE_NORMAL_BOTTOM 		= $6F 				; For default OS 192 scan line display
PM_2LINE_OVERSCAN_BOTTOM 	= $7B

PM_1LINE_OVERSCAN_TOP 		= $08
PM_1LINE_NORMAL_TOP 		= $20 				; For default OS 192 scan line display
PM_1LINE_NORMAL_BOTTOM 		= $DF 				; For default OS 192 scan line display
PM_1LINE_OVERSCAN_BOTTOM 	= $F7

;**************************************************	
; Helpful Colors.  (Many match C64)
;
COLOR_GREY 					= $00
COLOR_ORANGE1 				= $10
COLOR_ORANGE2 				= $20
COLOR_RED_ORANGE 			= $30
COLOR_PINK 					= $40
COLOR_PURPLE 				= $50
COLOR_PURPLE_BLUE 			= $60
COLOR_BLUE1 				= $70
COLOR_BLUE2 				= $80
COLOR_LITE_BLUE 			= $90
COLOR_AQUA 					= $A0
COLOR_BLUE_GREEN 			= $B0
COLOR_GREEN 				= $C0
COLOR_YELLOW_GREEN 			= $D0
COLOR_ORANGE_GREEN 			= $E0
COLOR_LITE_ORANGE 			= $F0
COLOR_BLACK 				= $00				; Some like to think of first color value as black.

;**************************************************
; PIA  - Register List
;
;**************************************************
; Hardware Registers                                                                                                                                                   
;                                                                                                                                                                      
PORTA 						= $D300				; Joystick ports 1 and 2, STICK0 and STICK1                                                                                                               
PORTB 						= $D301				; Joystick ports 3 and 4, STICK2 and STICK3                                                                                                               
PACTL 						= $D302				; Port A Control                                                                                                                                          
PBCTL 						= $D303				; Port B Control                                                                                                                                          

;**************************************************
; Shadow Registers for Hardware Registers                                                                                                                              
;                                                                                                                                                                      
STICK0 						= $0278                                                                                                                                                          
STICK1 						= $0279                                                                                                                                                          
STICK2 						= $027A                                                                                                                                                          
STICK3 						= $027B                                                                                                                                                          
       						                                                                                                                                                               
PTRIG0 						= $027C                                                                                                                                                          
PTRIG1 						= $027D                                                                                                                                                          
PTRIG2 						= $027E                                                                                                                                                          
PTRIG3 						= $027F                                                                                                                                                          
PTRIG4 						= $0280                                                                                                                                                          
PTRIG5 						= $0281                                                                                                                                                          
PTRIG6 						= $0282                                                                                                                                                          
PTRIG7 						= $0283                                                                                                                                                          

;**************************************************
; Important Bit Positions                                                                                                                                              
;                                                                                                                                                                      
MASK_JACK_1_3 				= %00001111 		; Actually the anti-mask.  Keeps bits from first controller in pair.                                                                          
MASK_JACK_2_4 				= %11110000 		; The inverse of mask.  Keeps bits from second controller in pair.                                                                            

;**************************************************
; 	Stick's bits in the high nybble should be right shifted into a low nybble for testing.                                                                               
;  	Or just use the STICKx shadow register as that is its purpose.                                                                                                      
; 	Bits for STICKx shadow regs below:                                                                                                                                   
;
MASK_STICK_RIGHT 			= %11110111                                                                                                                                            
MASK_STICK_LEFT 			= %11111011                                                                                                                                            
MASK_STICK_DOWN 			= %11111101                                                                                                                                            
MASK_STICK_UP 				= %11111110                                                                                                                                            
                                                                                                                                                                      
STICK_RIGHT 				= %00001000                                                                                                                                                 
STICK_LEFT 					= %00000100                                                                                                                                                 
STICK_DOWN 					= %00000010                                                                                                                                                 
STICK_UP 					= %00000001                                                                                                                                                 

;**************************************************                                                                                                                                                                      
; PACTL and PBCTL                                                                                                                                                      
;
MASK_PORT_SERIAL_IRQ 		= %01111111 		; (Read)                                                                                                                             
MASK_MOTOR_CONTROL 			= %11110111 		; PACTL Peripheral motor control (cassette)                                                                                          
MASK_COMMAND_IDENT 			= %11110111 		; PBCTL Peripheral command identification                                                                                            
MASK_PORT_ADDRESSING 		= %11111011 		; PACTL 0 = Port direction control. 1 = Read port.                                                                                   
MASK_SERIAL_IRQ_ENABLE 		= %11111110                                                                                                                                      
                                                                                                                                                                      
PORT_SERIAL_IRQ 			= %10000000 		; (Read)                                                                                                                                  
MOTOR_CONTROL 				= %00001000 		; PACTL                                                                                                                                   
COMMAND_IDENT 				= %00001000 		; PBCTL                                                                                                                                   
PORT_ADDRESSING 			= %00000100                                                                                                                                           
SERIAL_IRQ_ENABLE 			= %00000001                                                                                                                                           
                                                                                                                                                                      

;**************************************************                                                                                                                                                                      
; PBCTL for the XL                                                                                                                                                     
;
MASK_SELECT_OS_ROM 			= %11111110 		; Turn OS ROM on and off                                                                                                            
MASK_SELECT_BASIC_ROM 		= %11111101 		; Turn BASIC ROM on and off                                                                                                         
MASK_LED_1_KEYBOARD 		= %11111011 		; 1200XL LED 1, enable/disable keyboard                                                                                             
MASK_LED_2_INTL_CHARSET 	= %11110111 		; 1200XL LED 2, enable international character set                                                                                  
MASK_SELF_TEST_ROM 			= %01111111 		; Expose Self Test at $5000                                                                                                         
                                                                                                                                                                      
SELECT_OS_ROM 				= %00000001                                                                                                                                          
SELECT_BASIC_ROM 			= %00000010                                                                                                                                          
LED_1_KEYBOARD 				= %00000100                                                                                                                                          
LED_2_INTL_CHARSET 			= %00001000                                                                                                                                          
SELF_TEST_ROM 				= %10000000                                                                                                                                          
                                                
;**************************************************
; POKEY  - Register List                             
;      
;**************************************************
; Hardware Registers
;
AUDF1 						= $D200 			; Audio channel 1 Frequency
AUDF2 						= $D202 			; Audio channel 2 Frequency
AUDF3 						= $D204 			; Audio channel 3 Frequency
AUDF4 						= $D206 			; Audio channel 4 Frequency
    						        			
AUDC1 						= $D201 			; Audio channel 1 Control
AUDC2 						= $D203 			; Audio channel 2 Control
AUDC3 						= $D205 			; Audio channel 3 Control
AUDC4 						= $D207 			; Audio channel 4 Control

AUDCTL 						= $D208 			; Audio Control

POT0 						= $D200 			; (Read) Potentiometer (paddle) 0 
POT1 						= $D201 			; (Read) Potentiometer (paddle) 1 
POT2 						= $D202 			; (Read) Potentiometer (paddle) 2 
POT3 						= $D203 			; (Read) Potentiometer (paddle) 3 
POT4 						= $D204 			; (Read) Potentiometer (paddle) 4 
POT5 						= $D205 			; (Read) Potentiometer (paddle) 5 
POT6 						= $D206 			; (Read) Potentiometer (paddle) 6 
POT7 						= $D207 			; (Read) Potentiometer (paddle) 7 

ALLPOT 						= $D208 			; (Read) Read 8 line POT port state
POTGO  						= $D20B 			; Start the POT scan sequence
       						        			
STIMER 						= $D209 			; Start timers
KBCODE 						= $D209 			; (Read) Keyboard code
RANDOM 						= $D208 			; (Read) Random number
       						        			
SKREST 						= $D20A 			; Reset Serial Status (SKSTAT)
SEROUT 						= $D20D 			; Serial port data output
SERIN  						= $D20D 			; (Read) Serial port data input
SKCTL  						= $D20F 			; Serial Port Control
SKSTAT 						= $D20F 			; (Read) Serial port status
       						        			
IRQEN  						= $D20E 			; Interrupt Request Enable
IRQST  						= $D20E 			; (Read) IRQ Status

;**************************************************
; Shadow Registers for Hardware Registers
;
PADDL0 						= $0270 			; POT0
PADDL1 						= $0270 			; POT1
PADDL2 						= $0270 			; POT2
PADDL3 						= $0270 			; POT3
PADDL4 						= $0270 			; POT4
PADDL5 						= $0270 			; POT5
PADDL6 						= $0270 			; POT6
PADDL7 						= $0270 			; POT7
       						        			
CH 	   						= $02FC 			; KBCODE       						
POKMSK 						= $10 				; IRQEN       						
SSKCTL 						= $0232 			; SKCTL

;**************************************************
; AUDC
;
; 	Important Bit Positions 
;
MASK_AUD_NOISE  			= %00011111
MASK_AUD_FORCE  			= %11101111
MASK_AUD_VOLUME 			= %11110000

AUD_NOISE  					= %11100000
AUD_FORCE  					= %00010000
AUD_VOLUME 					= %00001111

NOISE_5_BIT_17_BIT_POLY 	= %00000000
NOISE_5_BIT_POLY 			= %00100000
NOISE_5_BIT_4_BIT_POLY 		= %01000000
NOISE_5_BIT_POLY_2 			= %01100000 		; Duplicate of "5 bit poly"
NOISE_17_BIT_POLY 			= %10000000
NOISE_NO_POLY_PURE 			= %10100000
NOISE_4_BIT_POLY 			= %11000000
NOISE_NO_POLY_PURE_2 		= %11100000 		; Duplicate of "No poly pure"

;**************************************************
; AUDCTL
;
MASK_AUDCTL_POLY        	= %01111111 		; 17 or 9 bit poly
MASK_AUDCTL_CH1_SYS     	= %10111111 		; Channel 1, 64KHz or system CPU clock (1.79Mhz NTSC)
MASK_AUDCTL_CH3_SYS     	= %11011111 		; Channel 3, 64KHz or system CPU clock (1.79Mhz NTSC)
MASK_AUDCTL_16_BIT_2_1  	= %11101111 		; Tie channels 2 and 1 for 16-bit resolution
MASK_AUDCTL_16_BIT_4_3  	= %11110111 		; Tie channels 4 and 3 for 16-bit resolution
MASK_AUDCTL_HIPASS_1_3  	= %11111011 		; High pass filter channel 1 by channel 3
MASK_AUDCTL_HIPASS_2_4  	= %11111101 		; High pass filter channel 2 by channel 4
MASK_AUDCTL_64_OR_15KHZ 	= %11111110 		; Use Clock 64Khz or 15Khz

AUDCTL_POLY_17 				= %00000000
AUDCTL_POLY_9  				= %10000000
AUDCTL_CH1_64  				= %00000000
AUDCTL_CH1_SYS 				= %01000000
AUDCTL_CH3_64  				= %00000000
AUDCTL_CH3_SYS 				= %00100000
AUDCTL_16_BIT_2_1_OFF 		= %00000000
AUDCTL_16_BIT_2_1_ON 		= %00010000
AUDCTL_16_BIT_4_3_OFF 		= %00000000
AUDCTL_16_BIT_4_3_ON 		= %00001000
AUDCTL_HIPASS_1_3_OFF 		= %00000000
AUDCTL_HIPASS_1_3_ON 		= %00000100
AUDCTL_HIPASS_2_4_OFF 		= %00000000
AUDCTL_HIPASS_2_4_ON 		= %00000010
AUDCTL_CLOCK_64KHZ 			= %00000000
AUDCTL_CLOCK_15KHZ 			= %00000001

;**************************************************
; ALLPOT
;
MASK_ALLPOT_PADDLE7 		= %01111111
MASK_ALLPOT_PADDLE6 		= %10111111
MASK_ALLPOT_PADDLE5 		= %11011111
MASK_ALLPOT_PADDLE4 		= %11101111
MASK_ALLPOT_PADDLE3 		= %11110111
MASK_ALLPOT_PADDLE2 		= %11111011
MASK_ALLPOT_PADDLE1 		= %11111101
MASK_ALLPOT_PADDLE0 		= %11111110

ALLPOT_PADDLE7 				= %10000000
ALLPOT_PADDLE6 				= %01000000
ALLPOT_PADDLE5 				= %00100000
ALLPOT_PADDLE4 				= %00010000
ALLPOT_PADDLE3 				= %00001000
ALLPOT_PADDLE2 				= %00000100
ALLPOT_PADDLE1 				= %00000010
ALLPOT_PADDLE0 				= %00000001

;**************************************************
; SKCTL
;
MASK_SERIAL_BREAK 			= %01111111
MASK_SERIAL_MODE 			= %10001111
MASK_SERIAL_2TONE 			= %11110111
MASK_FAST_POT_SCAN 			= %11111011
MASK_ENABLE_KB_SCAN 		= %11111101
MASK_KB_DEBOUNCE 			= %11111110

SERIAL_BREAK 				= %10000000 		
SERIAL_MODE0 				= %00000000 		; Input Clock External.            Output Clock External.          Bidirectional Clock Input.
SERIAL_MODE1 				= %00010000 		; Input Clock Channel 3+4 (async). Output Clock External.          Bidirectional Clock Input.
SERIAL_MODE2 				= %00100000 		; Input Clock Channel 4.           Output Clock Channel 4.         Bidirectional Clock Output Channel 4.
SERIAL_MODE3 				= %00110000 		; Input Clock Channel 3+4 (async). Output Clock Channel 4 (async). Bidirectional Clock Input.
SERIAL_MODE4 				= %01000000 		; Input Clock External.            Output Clock Channel 4.         Bidirectional Clock Input.
SERIAL_MODE5 				= %01010000 		; Input Clock Channel 3+4 (async). Output Clock Channel 4 (async). Bidirectional Clock Input.
SERIAL_MODE6 				= %01100000 		; Input Clock Channel 4.           Output Clock Channel 2.         Bidirectional Clock Output Channel 4.
SERIAL_MODE7 				= %01110000 		; Input Clock Channel 3+4 (async). Output Clock Channel 2.         Bidirectional Clock Input.

SERIAL_2TONE 				= %00001000 		; 1 and 0 bits are audio set by timers 1 and 2

FAST_POT_SCAN_OFF 			= %00000000
FAST_POT_SCAN_ON  			= %00000100
DISABLE_KB_SCAN   			= %00000000
ENABLE_KB_SCAN    			= %00000010
KB_DEBOUNCE_OFF   			= %00000000
KB_DEBOUNCE_ON    			= %00000001

;**************************************************
; SKSTAT
;
MASK_SERIAL_FRAME_ERROR 	= %01111111
MASK_SERIAL_INPUT_OVERRUN 	= %10111111
MASK_KEYBOARD_OVERRUN 		= %11011111
MASK_SERIAL_DATA_READY 		= %11101111
MASK_SH.if_KEY_PRESSED 		= %11110111
MASK_LAST_KEY_HELD 			= %11111011
MASK_SERIAL_INPUT_BUSY 		= %11111101

SERIAL_FRAME_NO_ERROR 		= %00000000
SERIAL_FRAME_ERROR 			= %10000000
SERIAL_NO_INPUT_OVERRUN 	= %00000000
SERIAL_INPUT_OVERRUN 		= %01000000
KEYBOARD_NO_OVERRUN 		= %00000000
KEYBOARD_OVERRUN 			= %00100000
SERIAL_DATA_NOT_READY 		= %00000000
SERIAL_DATA_READY 			= %00010000
SH.if_KEY_NOT_PRESSED 		= %00000000
SH.if_KEY_PRESSED 			= %00001000
LAST_KEY_NOT_HELD 			= %00000000
LAST_KEY_HELD 				= %00000100
SERIAL_INPUT_NOT_BUSY 		= %00000000
SERIAL_INPUT_BUSY 			= %00000010

;**************************************************
; IRQEN and IRQST
;
MASK_IRQ_TIMER1 			= %11111110
MASK_IRQ_TIMER2 			= %11111101
MASK_IRQ_TIMER4 			= %11111011
MASK_IRQ_SERIAL_OUT_DONE 	= %11110111
MASK_IRQ_SERIAL_OUT_READY 	= %11101111
MASK_IRQ_SERIAL_IN_READY 	= %11011111
MASK_IRQ_NORMAL_KEY_PRESS 	= %10111111
MASK_IRQ_BREAK_PRESSED 		= %01111111

IRQ_TIMER1_OFF 				= %00000000
IRQ_TIMER1_ON 				= %00000001
IRQ_TIMER2_OFF 				= %00000000
IRQ_TIMER2_ON 				= %00000010
IRQ_TIMER4_OFF 				= %00000000
IRQ_TIMER4_ON 				= %00000100
IRQ_SERIAL_OUT_NOT_DONE 	= %00000000
IRQ_SERIAL_OUT_DONE 		= %00001000
IRQ_SERIAL_OUT_NOT_READY 	= %00000000
IRQ_SERIAL_OUT_READY 		= %00010000
IRQ_SERIAL_IN_NOT_READY 	= %00000000
IRQ_SERIAL_IN_READY 		= %00100000
IRQ_NO_KEY_PRESS 			= %00000000
IRQ_NORMAL_KEY_PRESS 		= %01000000
IRQ_BREAK_NOT_PRESSED 		= %00000000
IRQ_BREAK_PRESSED 			= %10000000

;**************************************************
; Additional Registers
;
RAMTOP						= $6A
SYSVBV 						= $E45F  			; interrupt enabled vector
SETVBI 						= $E45C  			; set vertical blank interrupt vector
XITVBL 						= $E462  			; exit VBI vector

XITVB_I						= $e45f
VBI_I						= $06
VBI_D						= $07
NORMAL_VBI_I				= $c0e2
NORMAL_VBI_D				= $c28a
SETVBV						= $e45c
VVBLKI						= $0222
VVBLKD						= $0224
XITVB						= XITVBL
