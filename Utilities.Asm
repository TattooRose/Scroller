;
;***************************************************************************************************
;
;	Filename:		Utilities.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; 	Clear Zero Page 
;**************************************************************************************************
;
.proc ClearZeroPage

		lda #$00
		tay
		ldx #$79

Loop
		sta (ZeroPageAddress), y
		iny
		dex
		bne loop
		
		rts		
.endp

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

		lda m_healthCounter						; assuming 99 or less
		ldy #31
		jsr DisplayDebugInfoBinary99

		lda m_disableGameTimer					; update the time here also
		bne UIL_exit
	
		lda m_goldCounter
		bne UIL_update_timer
		
		lda m_activeEnemies
		bne UIL_update_timer
	
		lda #1
		sta m_disableGameTimer					; my record? 1:16.1 (NTSC, lost one life)

;*****	allow the final update..
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

;*****	Draw Timer
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

;*****	Exit
;
UIL_exit
		
		rts
	
.endp	

;
;**************************************************************************************************
; UpdateTimers
;**************************************************************************************************
;
.proc UpdateTimers
		
		lda m_playerNoJumpTimer
		beq UT_end_no_jump
		dec m_playerNoJumpTimer
	
;************************************************
;	
UT_end_no_jump		
		
		rts

.endp	

