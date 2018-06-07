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
; 	CheckMenuInput
;**************************************************************************************************
;
.proc CheckMenuInput

		lda #$03
		sta SKCTL
		
;***** Load Trigger
LoadTrigger

		jsr SfxUpdate

		lda m_currentTrigger0
		sta m_oldTrigger0

		lda CONSOL								; 0 - not pressed, 1 - just released, 2 - just pressed, 3 - pressed
		sta m_param01
		
		VcountWait 120 

		lda m_param01	
		and #CONSOLE_START		

		
		bne LoadTrigger
	
		rts
		
.endp

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
	
		lda P0PF
		sta TabHardwareCollision
		lda P1PF
		sta TabHardwareCollision+1
		lda P2PF
		sta TabHardwareCollision+2
		lda P3PF
		sta TabHardwareCollision+3
		lda M0PL
		sta TabHardwareCollision+4
		lda M1PL
		sta TabHardwareCollision+5
		lda M2PL
		sta TabHardwareCollision+6
		lda M3PL
		sta TabHardwareCollision+7
		lda M0PF
		sta TabHardwareCollision+8
		lda M1PF
		sta TabHardwareCollision+9
		lda M2PF
		sta TabHardwareCollision+10
		lda M3PF
		sta TabHardwareCollision+11
		
		
		
;*****	Check Missile 0 to Player 0
;
;		lda M0PL
;		and #%1011
;		beq check_m1_pl
;				
;		ldx #PS_LOSE
;		jsr SetPlayerMethod
;		jmp CPMC_check_m0_pf0_3
		
		
;*****	Check Missile 1 to Player 0
;
;check_m1_pl
;
;		lda M1PL
;		and #%1011
;		beq check_m2_pl
;				
;		ldx #PS_LOSE
;		jsr SetPlayerMethod
;		jmp CPMC_check_m0_pf0_3
		
;*****	Check Missile 2 to Player 0
;		
check_m2_pl
		
		lda M2PL
		and #%1011
		beq check_p0_pf3
				
		ldx #PS_LOSE
		jsr SetPlayerMethod
		jmp CPMC_check_m0_pf0_3

;*****	Check Missile 3 to Player 0
;		
;check_m3_pl
;		
;		lda M3PL
;		and #%1011
;		beq check_p0_pf3
;				
;		ldx #PS_LOSE
;		jsr SetPlayerMethod
;		jmp CPMC_check_m0_pf0_3

;*****	Check Player 0 Playfield 3
;
check_p0_pf3
		
		lda P0PF
		and #%1000
		beq CPMC_check_m3_pl0
		
		ldx #PS_LOSE
		jsr SetPlayerMethod
		jmp CPMC_check_m0_pf0_3

;Check_P1
;		lda P1PF
;		and #%0100
;		beq Check_P2
;
;		ldx #PS_LOSE
;		jsr SetPlayerMethod
;		jmp CPMC_check_m0_pf0_3
;
;Check_P2
;		lda P2PF
;		and #%0100
;		beq CPMC_check_m2_pl0
;
;		ldx #PS_LOSE
;		jsr SetPlayerMethod
;		jmp CPMC_check_m0_pf0_3
;
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

