;
;***************************************************************************************************
;
;	Filename:		AudioManager.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;

.proc	SfxOff

	lda #$f0					;initial value
	sta RMTSFXVOLUME			;sfx note volume * 16 (0,16,32,...,240)
;
	lda #$ff					;initial value
	sta m_sfxEffect
;
	ldx #<SoundAddress					;low byte of RMT module to X reg
	ldy #>SoundAddress					;hi byte of RMT module to Y reg
	lda #$02						;starting song line 0-255 to A reg
	jsr RASTERMUSICTRACKER		;Init

; 		 lda #0             ; silence sound output
;	     sta m_sfxBusy
;         sta m_sfxLEFT
;         sta m_sfxRIGHT
;         
;         sta AUDCTL								; clear sound
;		 
;		 sta AUDC1
;	     sta AUDC2
;	     sta AUDC3
;	     sta AUDF4
;		 
;		 sta AUDF1
;	     sta AUDF2
;	     sta AUDF3
;	     sta AUDF4
	     
         rts
.endp

.proc SfxTrigger
		 
;		 lda m_sfxBusy
;		 cmp #$01
;	 	 bne seteffect
;		 
;		 rts
;		 
seteffect
;         ldx m_sfxLEFT       ; test left channel
;         lda SFX_CV,x        ; CV value will be 0 if channel is idle 
;         bne leftnotfree   ; if not 0 then skip ahead
;         sty m_sfxLEFT       ; channel is idle, use it
;		 lda #$01
;		 sta m_sfxBusy
;         rts                ; all done
;
leftnotfree 
;         ldx m_sfxRIGHT      ; test right channel
;         lda SFX_CV,x        ; CV value will be 0 if channel is idle
;         bne rightnotfree  ; if not 0 then skip ahead
;         sty m_sfxRIGHT      ; channel is idle, use it
;		 lda #$01
;		 sta m_sfxBusy
         rts                ; all done

rightnotfree
;         cpy m_sfxLEFT       ; test sfx priority with left channel
;         bcc leftnotlower  ; skip ahead if new sfx has lower priority than active sfx
;         sty m_sfxLEFT       ; new sfx has higher priority so use left channel
;		 lda #$01
;		 sta m_sfxBusy
         rts                ; all done

leftnotlower 
;         cpy m_sfxRIGHT      ; test sfx with right channel
;         bcc rightnotlower ; skip ahead if new sfx has lower priority than active sfx
;         sty m_sfxRIGHT      ; new sfx has higher priority so use right channel
; 		 lda #$01
;		 sta m_sfxBusy
		 
rightnotlower
		
		
        rts

.endp


.proc SfxUpdate
	lda m_sfxEffect
	bmi lab2
	asl 						; * 2
	tay							;Y = 2,4,..,16	instrument number * 2 (0,2,4,..,126)
	ldx #3						;X = 3			channel (0..3 or 0..7 for stereo module)
	lda #12						;A = 12			note (0..60)
	jsr RASTERMUSICTRACKER+15	;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)
;
	lda #$ff
	sta m_sfxEffect				;reinit value
;
lab2
	jsr RASTERMUSICTRACKER+3	;1 play
	rts
	
;	lda #%11101010
;	sta AUDCTL
;	ldx m_sfxLEFT       ; get the pointer for the left channel
;    lda SFX_F,x         ; get the Frequency value
;    sta AUDF1          ; update the Frequency register
;    lda SFX_CV,x        ; get the combined Control and Volume value
;    sta AUDC1          ; update the Volume register
;    lsr                ; prep the Control value,
;    lsr                ;   it's stored in the upper nybble
;	lsr                ;   but must be in the lower nybble
;	lsr                ;   when Control is updated
;	sta AUDC1          ; update the Control register
;	beq skipleftdec   ; skip ahead if Control = 0
;	dec m_sfxLEFT       ; update pointer for left channel
;skipleftdec 
;	ldx m_sfxRIGHT      ; get the pointer for the right channel
;	lda SFX_F,x         ; get the Frequency value
;	sta AUDF2          ; update the Frequency register
;	lda SFX_CV,x        ; get the combined Control and Volume value
;    sta AUDC2          ; update the Volume register
;    lsr                ; prep the Control value,
;    lsr                ;   it's stored in the upper nybble
;    lsr                ;   but must be in the lower nybble
;    lsr                ;   when Control is updated
;    sta AUDC2         ; update the Control register
;	beq skiprightdec  ; skip ahead if Control = 0
;    dec m_sfxRIGHT      ; update pointer for right channel
;skiprightdec
;	lda m_sfxLeft
;	cmp #$00
;	bne noreset
;	sta m_sfxBusy
;noreset	
;    rts                ; all done
.endp

