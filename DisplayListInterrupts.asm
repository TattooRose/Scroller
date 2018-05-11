;
;***************************************************************************************************
;
;	Filename:		DisplayListInterrupts.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;	Color			Dec			HEX    	Color			Dec				HEX
;	-------------------------------		-----------------------------------
;	Black           00,			$00		Medium blue      08,    		$08
;	Rust            01,			$01		Dark blue        09,    		$09
;	Red-orange      02,			$02		Blue-grey      	 10,    		$0A
;	Dark orange     03,			$03		Olive green    	 11,    		$0B
;	Red             04,			$04		Medium green   	 12,    		$0C
;	Dk lavender     05,			$05		Dark green     	 13,    		$0D
;	Cobalt blue     06,			$06		Orange-green   	 14,    		$0E
;	Ultramarine     07,			$07		Orange         	 15,    		$0F
;
;**************************************************************************************************
; Display list 1 interruptions code
;**************************************************************************************************
;
GameDli_01
		
		pha
		tya
		pha
		
.if PAL_VERSION = 0

		SetColor $00, $03, $04
		SetColor $01, $00, $0F
		SetColor $02, $0D, $04
		SetColor $03, $0F, $0C		
		
.else

		SetColor 1, 15, 14		; yellow (collectables)
		SetColor 2, 7, 2		; blue (water)

.endif
		lda m_playerScreenLeftX
		sta HPOSP0
		sta HPOSP1
		sta HPOSP2
		
		SetFontAddress GameFontAddress
    	sta WSYNC   			; Wait off-screen

		SetDisplayListInterrupt TextDli 

		pla
		tay
		pla
		
		rti
;
;**************************************************************************************************
; Display list 2 interruptions code
;**************************************************************************************************
;
TextDli

		pha
		tya
		pha
			
.if PAL_VERSION = 0

		SetColor 1, $03, $0A
		SetColor 2, $04, $01			
.else

		SetColor 1, 15, 14		; yellow (collectables)
		SetColor 2, 7, 2		; blue (water)

.endif
		
		SetFontAddress TextFontAddress
		STA WSYNC 				;Wait off-screen

		
		SetDisplayListInterrupt GameDli_01 

		pla
		tay
		pla
		
		rti
