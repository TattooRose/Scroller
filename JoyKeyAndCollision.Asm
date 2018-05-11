;
;***************************************************************************************************
;
;	Filename:		JoyKeyAndCollision.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; CheckInput
;**************************************************************************************************
;
.proc CheckInput

;*****	Check Stick
;
CI_check_stick
		
		lda m_stick0
		sta m_oldStick0

		lda PORTA
		and #15
		sta m_stick0

;*****	Check Shoot Right
;
CI_check_shoot_right
		
		cmp #%1000								; right
		bcs CI_check_shoot_left
		
		lda #PSD_RIGHT
		sta m_lastPlayerShootDirection
		jmp CI_check_trigger

;*****	Check Shoot Left
;
CI_check_shoot_left
		
		and #%0100								; left
		bne CI_check_trigger
	
		lda #PSD_LEFT
		sta m_lastPlayerShootDirection

;*****	Check Trigger
;
CI_check_trigger
	
		lda m_currentTrigger0
		sta m_oldTrigger0

		lda TRIG0								; 0 - not pressed, 1 - just released, 2 - just pressed, 3 - pressed
		sta m_currentTrigger0	
		asl
		ora m_oldTrigger0
		eor #%11
		sta m_triggerState
			
		lda #0+GRACTL_OPTIONS					; reset trigger latches	
		sta GRACTL								; reset triggers latch mode
	
		lda #4+GRACTL_OPTIONS
		sta GRACTL								; set triggers latch mode

		rts
		
.endp	
	
;
;**************************************************************************************************
; CheckPMCollisions
;**************************************************************************************************
;
.proc CheckPMCollisions
	
;*****	Check Player 0 Playfield 3
;
		lda M2PL
		and #%1011
		beq check_p0_pf3
				
		ldx #PS_LOSE
		jsr SetPlayerMethod
		jmp CPMC_check_m0_pf0_3

;*****	Check Player 0 Playfield 3
;
check_p0_pf3
		
		lda P0PF
		and #%1000
		beq CPMC_check_m2_pl0

		ldx #PS_LOSE
		jsr SetPlayerMethod
		jmp CPMC_check_m0_pf0_3
		
;*****	Check Missile 2 Player 0
;
CPMC_check_m2_pl0
	
		lda M2PL
		and #%0001
		beq CPMC_check_m3_pl0

		ldx #PS_LOSE
		jsr SetPlayerMethod
		jmp CPMC_check_m0_pf0_3

;*****	Check Missile 3 Player 0
;
CPMC_check_m3_pl0

		lda M3PL
		and #%0001
		beq CPMC_check_m0_pf0_3

		ldx #PS_LOSE
		jsr SetPlayerMethod

;*****	Check Missile 0 Player 0-3
;
CPMC_check_m0_pf0_3
	
		lda M0PF
		and #%1001
		beq CPMC_check_m1_pf0_3

;*****	Check Missile 1 Player 0-3
;
CPMC_check_m1_pf0_3
	
		lda M1PF
		and #%1001
		beq ClearPMCollisions

;*****	Check PM Collisions
;
ClearPMCollisions

		lda #0
		sta HITCLR		
		
		rts

.endp		

