;
;***************************************************************************************************
;
;	Filename:		FW_AudioManager.Asm
;
;	Modified On:	Fri July 13, 2018 08:27 AM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;
;**************************************************************************************************
;	SfxInit
;**************************************************************************************************
;
.proc SfxInit

		lda #$f0								; initial value
		sta RMTSFXVOLUME						; sfx note volume * 16 (0,16,32,...,240)

		lda #$ff								; initial value
		sta m_sfxEffect

		ldx #<SoundDataAddress					; low byte of RMT module to X reg
		ldy #>SoundDataAddress					; hi byte of RMT module to Y reg
		lda #$02								; starting song line 0-255 to A reg
		jsr RASTERMUSICTRACKER					; Init
	     
         rts
.endp

;
;**************************************************************************************************
;	SfxUpdate
;**************************************************************************************************
;
.proc SfxUpdate
		
		lda m_sfxEffect
		bmi lab2
		asl 									; * 2
		tay										; Y = 2,4,..,16	instrument number * 2 (0,2,4,..,126)
		ldx #3									; X = 3			channel (0..3 or 0..7 for stereo module)
		lda #15									; A = 12		note (0..60)
		jsr RASTERMUSICTRACKER+15				; RMT_SFX 		start tone (It works only if FEAT_SFX is enabled !!!)

		lda #$ff
		sta m_sfxEffect							; reinit value

lab2
		jsr RASTERMUSICTRACKER+3				; 1 play
		rts
	
.endp

