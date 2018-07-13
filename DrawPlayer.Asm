;
;***************************************************************************************************
;
;	Filename:		DrawPlayer.Asm
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
_plrAnimationTimer				.byte $00
_plrAnimationFrame				.byte $00
_plrAnimationOffset				.byte $00

_plrAnimationTableIndex			.byte $00
_plrAnimationTableFrame			.byte $00

_plrAnimationHeight				.byte $00
_plrAnimationHeightCount		.byte $00

;
;***************************************************************************************************
;	
;	AnimateClimbing
;
;***************************************************************************************************
;	
.proc AnimateClimbing

		ldx #$04		
		stx _plrAnimationTableIndex				; load the curren index

		lda #$00
		sta m_param01
		sta _plrAnimationTableFrame

		 jsr ProcessFrame	

Stick_Check

		; Check the state of the stick
		lda m_stick0
		and #[STICK_UP | STICK_DOWN]
		cmp #[STICK_UP | STICK_DOWN]
		bne Check_One
		jmp Exit
		
Check_One

		lda _plrAnimationFrame
		and #$0C
		cmp #$0C		
		bne Check_Two
		lda #$01
		sta m_param01
		jsr ProcessFrame

		jmp Exit

Check_Two

		lda _plrAnimationFrame
		and #$08
		cmp #$08		
		bne Check_Three
		lda #$02
		sta m_param01
		jsr ProcessFrame

		jmp Exit

Check_Three

		lda _plrAnimationFrame
		and #$04		
		cmp #$04		
		bne Exit
		lda #$03
		sta m_param01
		jsr ProcessFrame
				 
Exit		
		rts

.endp

;
;***************************************************************************************************
;	
;	AnimateWalking
;
;***************************************************************************************************
;	
.proc AnimateWalking

		lda m_lastPlayerSideDirection
		cmp #PSD_RIGHT
		bne SetLeftPointer
		
		lda #$00
		sta _plrAnimationTableIndex
		
		jmp StartLogic
		
SetLeftPointer		
		lda #$02
		sta _plrAnimationTableIndex

StartLogic

		; Check the state of the stick
		lda m_stick0
		and #[STICK_RIGHT | STICK_LEFT]
		cmp #[STICK_RIGHT | STICK_LEFT]
		bne Begin_Checks
		
		ldx _plrAnimationTableIndex
		lda #$00								; reset the frame counter
		sta m_param01
		sta _plrAnimationFrame						; reset the animation frame
		sta PlrTabCurrFrames,x						; update the main arrays for this index
		sta PlrTabCurrFrames+1,x					; update the main arrays for this index		
		jsr ProcessFrame		
		jmp Exit
		
Begin_Checks
		lda #$01
		sta m_param01
		jsr ProcessFrame
				
Check_One
		lda _plrAnimationFrame
		and #$04		
		cmp #$04
		bne Check_Two
		lda #$02
		sta m_param01
		jsr ProcessFrame
		jmp Exit
		
Check_Two
		lda _plrAnimationFrame
		and #$08
		cmp #$08
		bne Check_Three		
		lda #$03
		sta m_param01
		jsr ProcessFrame
		jmp Exit

Check_Three
		lda _plrAnimationFrame
		and #$0C
		cmp #$0C
		bne Exit
		lda #$01
		sta m_param01		
		jsr ProcessFrame
		
Exit		
		
		rts
		
.endp

;
;***************************************************************************************************
;	
;	DrawPlayer
;
;***************************************************************************************************
;	
.proc DrawPlayer

		lda m_redrawPlayerCounter
		bne Draw		
		jmp Exit				
		
Draw

StartDraw

		lda #$00
		sta m_redrawPlayerCounter 		
		
		jsr UpdateAnimationTimer
		 		
		jsr SetAnimationIndex

		lda m_playerScreenLeftX					; get the cuirrent horizontal position	
		sta HPOSP0								; store it in the regiaters	
		sta HPOSP1								; store it in the regiaters

		lda #$00
		ldx #$00
		ldy m_oldPlayerScreenTopY
		
ClearPlayer		

		sta p0_area_1,y	
		sta p1_area_1,y	
		iny
		inx
		cpx _plrAnimationHeight
		bne ClearPlayer
		
		ldx _plrAnimationTableIndex
		
		lda PlrTabAnimLSB,x						; load the animation LSB
		sta m_paramW01							; store it in the LO byte
		lda PlrTabAnimMSB, x					; load the animation MSB
		sta m_paramW01+1						; store it in the HI byte
		
		lda PlrTabAnimLSB+1,x					; load the animation LSB
		sta m_paramW02							; store it in the LO byte
		lda PlrTabAnimMSB+1,x					; load the animation MSB
		sta m_paramW02+1						; store it in the HI byte

		lda PlrTabColorsLSB,x					; load the color LSB
		sta TabColor00+1						; store it in the LO color slot
		lda PlrTabColorsMSB,x					; load the color LSB
		sta TabColor00+2						; store it in the HI color slot

		lda PlrTabColorsLSB+1,x					; load the color LSB
		sta TabColor01+1						; store it in the LO color slot
		lda PlrTabColorsMSB+1,x					; load the color LSB
		sta TabColor01+2						; store it in the HI color slot

		ldx _plrAnimationTableFrame
		
TabColor00		

		lda $FFFF,x								; grab the color
		sta COLPM0								; store it in the register
		
TabColor01		

		lda $FFFF,x								; grab the color
		sta COLPM1								; store it in the register

		lda #$00
		sta _plrAnimationHeightCount

		ldx m_playerScreenTopY
		ldy _plrAnimationOffset
	
TabAnim

		lda (m_paramW01),y
		sta p0_area_1,x	
		lda (m_paramW02),y
		sta p1_area_1,x	
		
		iny
		inx
		
		inc _plrAnimationHeightCount
		lda _plrAnimationHeightCount
		cmp _plrAnimationHeight
		bne TabAnim

Exit

		rts

.endp

;
;**************************************************************************************************
; DrawPlayerExplosion
;**************************************************************************************************
;
.proc DrawPlayerExplosion

		lda m_playerState
		cmp #PS_LOSE
		beq SetPlayerColor
		jmp DPE_exit 
		
SetPlayerColor
		lda COLPF3
		sta COLPM0

;************************************************
;
DPE_erase										; erase previous player explosion frame
		ldx #0
		ldy m_playerExplosionScreenTopY_H1

;************************************************
;
DPE_erase_loop
		lda #0
		sta p0_area_1,y
		sta p1_area_1,y
		
		tya
		clc
		adc m_playerExplosionStep
		bcs DPE_update_frame
		tay

		inx
		cpx m_playerSizeY
		bne DPE_erase_loop

;************************************************
; 	update step and explosion starting line
; 	if step +1 --> line - 3.5
; 	if step +2 --> line - 7.0
;
DPE_update_frame

		lda m_playerExplosionScreenTopY_L1
		sec
		sbc #$80
		sta m_playerExplosionScreenTopY_L1

		lda m_playerExplosionScreenTopY_H1
		sbc #$03
		bcs DPE_do_update

		ldx #PS_OVER_PLATFORM
		jsr SetPlayerMethod

		lda #$00
		sta HPOSP0
		sta HPOSP1
		
		lda m_currLevelNum
		sta m_param00
		
		jsr SetSpawnPos
		
		jmp DPE_exit
	
;************************************************
;
DPE_do_update
		
		sta m_playerExplosionScreenTopY_H1
		inc m_playerExplosionStep				; step +1

;*****	draw new player explosion frame
; 
DPE_draw						

		ldx _plrAnimationTableIndex
		
		lda PlrTabAnimLSB,x						; load the animation LSB
		sta DPE_draw_p0+1						; store it in the LO byte
		lda PlrTabAnimMSB, x					; load the animation MSB
		sta DPE_draw_p0+2						; store it in the HI byte
		
		lda PlrTabAnimLSB+1,x						; load the animation LSB
		sta DPE_draw_p1+1						; store it in the LO byte
		lda PlrTabAnimMSB+1,x						; load the animation MSB
		sta DPE_draw_p1+2						; store it in the HI byte

		lda PlrTabColorsLSB,x						; load the color LSB
		sta TabColor00+1						; store it in the LO color slot
		lda PlrTabColorsMSB,x						; load the color LSB
		sta TabColor00+2						; store it in the HI color slot

		lda PlrTabColorsLSB+1,x					; load the color LSB
		sta TabColor01+1						; store it in the LO color slot
		lda PlrTabColorsMSB+1,x					; load the color LSB
		sta TabColor01+2						; store it in the HI color slot

		ldx _plrAnimationTableFrame

TabColor00		

		lda $FFFF,x								; grab the color
		sta COLPM0								; store it in the register
		
TabColor01		

		lda $FFFF,x								; grab the color
		sta COLPM1								; store it in the register

		ldx #$00
		ldy m_playerExplosionScreenTopY_H1 

;************************************************
;
DPE_draw_p0

		lda $FFFF,x
		beq DPE_draw_p1
		sta p0_area_1,y

;************************************************
;
DPE_draw_p1

		lda $FFFF,x
		beq DPE_draw_end	
		sta p1_area_1,y

;************************************************
;
DPE_draw_end

		tya
		clc
		adc m_playerExplosionStep
		bcs DPE_exit

		tay
		inx
		cpx m_playerSizeY
		bne DPE_draw_p0

;************************************************
;
DPE_exit
		
		rts

.endp		

;
;***************************************************************************************************
;	
;	InitDraw
;
;***************************************************************************************************
;	
.proc InitDraw

		lda #$00
		sta _plrAnimationFrame
		sta _plrAnimationOffset
		sta _plrAnimationTableIndex
		sta _plrAnimationTableFrame
		sta _plrAnimationHeight
		sta _plrAnimationHeightCount
				
		lda #PLR_ANIMATION_DELAY
		sta _plrAnimationTimer

		rts
		
.endp

;
;***************************************************************************************************
;	
;	ProcessFrame
;
;***************************************************************************************************
;	
.proc ProcessFrame

		sta m_hldA								; save off AXY
		stx m_hldX								; save off AXY
		sty m_hldY								; save off AXY

		ldx _plrAnimationTableIndex	

		lda m_param01
		sta _plrAnimationTableFrame
		
		sta PlrTabCurrFrames,x						; update the main arrays for this index
		sta PlrTabCurrFrames+1,x					; update the main arrays for this index
		
Exit		
		lda m_hldA								; save off AXY
		ldx m_hldX								; save off AXY
		ldy m_hldY								; save off AXY
		
		rts

.endp

;
;***************************************************************************************************
;	
;	SetAnimationIndex
;
;		const used:	PS_CLIMBING
;					PS_FALLING
;					PS_IN_WATER
;					PS_JUMPING
;					PS_LOSE
;					PS_OVER_PLATFORM
;					PS_STATIC
;
;		vars used:	m_playerState
;					m_stick0
;					m_animFrame
;					m_animHeight
;
;					_plrAnimationTableIndex
;
;***************************************************************************************************
;	
.proc SetAnimationIndex

StartState		
		lda #PLR_HEIGHT							; load the players height
		sta _plrAnimationHeight					; save if off

		lda m_playerState						; load current player state
		cmp m_oldPlayerState					; did it change
		beq ProcessState						; if not then process players state
		
ProcessState		
		lda m_playerState						; check the current state
		sta m_oldPlayerState					; update the old state with the current

		cmp #PS_OVER_PLATFORM					; over a platform
		bne CheckClimbing						; no check the climbing state
		jsr AnimateWalking
		jmp Return_Exit

CheckClimbing		
		cmp #PS_CLIMBING
		bne CheckStatic
		jsr AnimateClimbing
		jmp Return_Exit

CheckStatic		
;		cmp #PS_STATIC
;		beq StandingIndex
		jmp Return_Exit
CheckJumping
;		cmp #PS_JUMPING
;		beq JumpFallIndex
		jmp Return_Exit
CheckFalling
;		cmp #PS_FALLING
;		beq JumpFallIndex
		jmp Return_Exit
CheckInWater		
;		cmp #PS_IN_WATER
;		beq StandingIndex
		jmp Return_Exit
CheckLose		
;		cmp #PS_LOSE
		jmp Return_Exit
		 

;JumpFallIndex
;		
;		lda #$09
;		jmp Return_Exit
;		
;ClimbingIndex		
;		inc m_floatAnimClimb
;		lda m_floatAnimClimb
;		and #$10
;		beq LeftClimb 
;		
;RightClimb		
;		lda #$0C		
;		jmp Return_Exit
;		
;LeftClimb
;		lda #$0F		
;		jmp Return_Exit				
;		

Return_Exit

		lda _plrAnimationTableFrame
		ldx _plrAnimationHeight		
		MultiplyAX
		
		lda _productLo
		sta _plrAnimationOffset
	
Exit				
		rts		

.endp

;
;***************************************************************************************************
;	
;	UpdateAnimationTimer
;
;***************************************************************************************************
;	
.proc UpdateAnimationTimer
		
		dec  _plrAnimationTimer
		bne	Exit
		
		lda #PLR_ANIMATION_DELAY
		sta _plrAnimationTimer
		
		inc _plrAnimationFrame

Exit		
		rts

	.endp


