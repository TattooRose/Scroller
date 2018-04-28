;
;***************************************************************************************************
;
; 	FileName:		DisplayListInterrupts.Asm
;
;	Created By:		Victor V Ferenzi
;
; 	Modified On:	Sat Apr 07, 2018 09:36:00 PM
;
;	Comments:		This code contains parts of the OPEN_PLAT project developed by NVR. It also
;					contains parts of the port from the C64 to Atari project developed by
;					Ken Jennings. Many thanks to both of them. 
;
;***************************************************************************************************
;
;	Color			Dec			HEX    	Color			Dec				HEX
;	-------------------------------		-----------------------------------
;	Black           00,			$00		Medium blue      08,    		$80
;	Rust            01,			$10		Dark blue        09,    		$90
;	Red-orange      02,			$20		Blue-grey      	 10,    		$A0
;	Dark orange     03,			$30		Olive green    	 11,    		$B0
;	Red             04,			$40		Medium green   	 12,    		$C0
;	Dk lavender     05,			$50		Dark green     	 13,    		$D0
;	Cobalt blue     06,			$60		Orange-green   	 14,    		$E0
;	Ultramarine     07,			$70		Orange         	 15,    		$F0
;
;**************************************************************************************************
; Display list 1 interruptions code
;**************************************************************************************************
;
GameDli_01
		
		pha
		tya
		pha
				
    	sta WSYNC   							; Wait off-screen

.if PAL_VERSION = 0
		SetColor $00, $04, $04
		SetColor $01, $03, $0B
		SetColor $02, $09, $06
		SetColor $03, $07, $0D		
.else
		SetColor 1, 15, 14						; yellow (collectables)
		SetColor 2, 7, 2						; blue (water)
.endif

		SetFontAddress GameFontAddr
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
			
		STA WSYNC 								;Wait off-screen

.if PAL_VERSION = 0
		SetColor 1, $03, $0A
		SetColor 2, $04, $01			
.else
		SetColor 1, 15, 14						; yellow (collectables)
		SetColor 2, 7, 2						; blue (water)
.endif
		SetFontAddress TextFontAddr

		SetDisplayListInterrupt GameDli_01 

		pla
		tay
		pla
		
		rti
