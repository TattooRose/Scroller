;
;***************************************************************************************************
;
;	Filename:		DataPlayer.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;***************************************************************************************************
;	Local Storage
;***************************************************************************************************
;
PLR_WIDTH			= $08
PLR_HEIGHT			= $18

PLR_ANIMATION_DELAY	= $02

PlrTabCurrFrames	.byte $00, $00, $00, $00
					.byte $00, $00

PlrTabTotalFrames	.byte $04, $04, $04, $04
					.byte $04, $04

PlrTabAnimLSB		.byte <PLR0_WALKDATA_R,  	<PLR1_WALKDATA_R
					.byte <PLR0_WALKDATA_L,  	<PLR1_WALKDATA_L
					.byte <PLR0_CLIMBDATA, 	 	<PLR1_CLIMBDATA
				
PlrTabAnimMSB		.byte >PLR0_WALKDATA_R,  	>PLR1_WALKDATA_R
					.byte >PLR0_WALKDATA_L,  	>PLR1_WALKDATA_L
					.byte >PLR0_CLIMBDATA, 	 	>PLR1_CLIMBDATA
				
PlrTabColorsLSB		.byte <PLR0_WALKCOLORS_R,  	<PLR1_WALKCOLORS_R
					.byte <PLR0_WALKCOLORS_L,  	<PLR1_WALKCOLORS_L
					.byte <PLR0_CLIMBCOLORS, 	<PLR1_CLIMBCOLORS

PlrTabColorsMSB		.byte >PLR0_WALKCOLORS_R,  	>PLR1_WALKCOLORS_R
					.byte >PLR0_WALKCOLORS_L,  	>PLR1_WALKCOLORS_L
					.byte >PLR0_CLIMBCOLORS, 	>PLR1_CLIMBCOLORS
				
PLR0_WALKCOLORS_R	.byte $86,$86,$86,$86
PLR1_WALKCOLORS_R	.byte $2c,$2c,$2c,$2c
PLR0_WALKCOLORS_L	.byte $86,$86,$86,$86
PLR1_WALKCOLORS_L	.byte $2c,$2c,$2c,$2c

PLR0_CLIMBCOLORS	.byte $86,$86,$86,$86
PLR1_CLIMBCOLORS	.byte $2c,$2c,$2c,$2c

PLR0_WALKDATA_R		

; FRAME 1
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$10,$10,$10
 .byte $7e,$3c,$3c,$18,$10,$10,$10,$18
; FRAME 2
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$10,$18,$08
 .byte $7e,$3c,$3c,$18,$18,$18,$18,$0c
; FRAME 3
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$10,$18,$0c
 .byte $7e,$3c,$3c,$3c,$24,$24,$24,$36
; FRAME 4
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$10,$18,$08
 .byte $7e,$3c,$3c,$18,$18,$18,$18,$0c

PLR1_WALKDATA_R

 .byte $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .byte $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .byte $10,$18,$00,$00,$10,$10,$10,$18
; FRAME 2
 .byte $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .byte $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .byte $0c,$00,$00,$00,$18,$18,$18,$0c
; FRAME 3
 .byte $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .byte $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .byte $06,$00,$00,$00,$24,$24,$24,$36
; FRAME 4
 .byte $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .byte $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .byte $0c,$00,$00,$00,$18,$18,$18,$0c

PLR0_WALKDATA_L

; FRAME 1
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$08,$08,$08
 .byte $7e,$3c,$3c,$18,$08,$08,$08,$18
; FRAME 2
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$08,$18,$10
 .byte $7e,$3c,$3c,$18,$18,$18,$18,$30
; FRAME 3
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$08,$18,$30
 .byte $7e,$3c,$3c,$3c,$24,$24,$24,$6c
; FRAME 4
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$18,$3c,$7e,$7e,$08,$18,$10
 .byte $7e,$3c,$3c,$18,$18,$18,$18,$30

PLR1_WALKDATA_L

; FRAME 1
 .byte $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .byte $38,$00,$00,$08,$08,$7e,$7e,$7e
 .byte $08,$18,$00,$00,$08,$08,$08,$18
; FRAME 2
 .byte $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .byte $38,$00,$00,$08,$08,$7e,$7e,$7e
 .byte $30,$00,$00,$00,$18,$18,$18,$30
; FRAME 3
 .byte $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .byte $38,$00,$00,$08,$08,$7e,$7e,$7e
 .byte $60,$00,$00,$00,$24,$24,$24,$6c
; FRAME 4
 .byte $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .byte $38,$00,$00,$08,$08,$7e,$7e,$7e
 .byte $30,$00,$00,$00,$18,$18,$18,$30
 
PLR0_CLIMBDATA

; FRAME 1
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $00,$db,$bd,$ff,$ff,$00,$00,$00
 .byte $7e,$7e,$7e,$3c,$24,$24,$24,$24
; FRAME 2
 .byte $18,$3c,$ff,$00,$00,$00,$c0,$80
 .byte $83,$99,$bd,$ff,$ff,$00,$00,$00
 .byte $7e,$7e,$7e,$3c,$24,$24,$04,$04
; FRAME 3
 .byte $18,$3c,$ff,$00,$00,$00,$00,$00
 .byte $c3,$99,$bd,$ff,$ff,$00,$00,$00
 .byte $7e,$7e,$7e,$3c,$24,$24,$24,$24
; FRAME 4
 .byte $18,$3c,$ff,$00,$00,$00,$03,$01
 .byte $c1,$99,$bd,$ff,$ff,$00,$00,$00
 .byte $7e,$7e,$7e,$3c,$24,$24,$20,$20
 
PLR1_CLIMBDATA

; FRAME 1
 .byte $18,$3c,$ff,$3c,$3c,$3c,$3c,$3c
 .byte $18,$c3,$81,$81,$c3,$7e,$7e,$7e
 .byte $00,$00,$00,$00,$24,$24,$24,$24
; FRAME 2
 .byte $18,$3c,$ff,$3c,$3c,$3c,$fc,$bc
 .byte $9b,$81,$81,$81,$c3,$7e,$7e,$7e
 .byte $00,$00,$00,$00,$24,$24,$04,$04
; FRAME 3
 .byte $18,$3c,$ff,$3c,$3c,$3c,$3c,$3c
 .byte $db,$81,$81,$81,$c3,$7e,$7e,$7e
 .byte $00,$00,$00,$00,$24,$24,$24,$24
; FRAME 4
 .byte $18,$3c,$ff,$3c,$3c,$3c,$3f,$3d
 .byte $d9,$81,$81,$81,$c3,$7e,$7e,$7e
 .byte $00,$00,$00,$00,$24,$24,$20,$20
