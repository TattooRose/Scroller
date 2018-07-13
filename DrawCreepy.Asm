;
;***************************************************************************************************
;
;	Filename:		DrawCreepy.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;

;
;***************************************************************************************************
;	CreepyInit
;
;		Initialize an instance of the creepy villian
;
;		params:			m_param00	-	column for character to start in
;						m_param01	-	row for character to start in
;						m_paramW03	-	level line of character 
;
;***************************************************************************************************
;
.proc CreepyInit

		jsr VillianGetIndex						; Find an open index

		cpx #$FF								; See if it's valid		
		bne Continue			
		jmp Exit								; No cannot init this instance		

Continue

		stx m_villianCurrIndex					; hold this index for later

		lda #$01								; set the state value
		sta VilActive,x
		
		lda #PS_OVER_PLATFORM					; set initial state
		sta VilState,x							; store it off

		lda #PSD_RIGHT							; set initial direction
		sta VilDirX,x							; store it off
		sta VilDirectionX,x						; store it off
			
		lda #PSD_DOWN
		sta VilDirY,x							; store it off
		sta VilDirectionY,x						; store it off
		
		lda #CPY_ANIMATION_DELAY				; set the delay value
		sta VilDelay,x							; store it off

		lda #CPY_BONUS_AMOUNT					; set the value to 100
		sta VilBonus,x							; store it off

		lda #CPY_TOTAL_FRAMES					; get the total frames
		sta VilTotalFrame,x						; store it off
		
		lda #<CPY_WALKDATA						; load the animation
		sta VilAnimLSB,x						; store it off

		lda #>CPY_WALKDATA						; load the animation
		sta VilAnimMSB,x						; store it off

		lda #<CPY_WALKDATA						; load the animation
		sta VilAnimLSB,x						; store it off

		lda #>CPY_WALKDATA						; load the animation
		sta VilAnimMSB,x						; store it off

		lda #<CPY_WALKCOLORS					; load the colors
		sta VilColorLSB,x						; store it off

		lda #>CPY_WALKCOLORS					; load the colors
		sta VilColorMSB,x						; store it off

		lda #CPY_WIDTH							; set the character width
		sta VilWidth,x							; store it off

		lda #CPY_HEIGHT							; set the character height		
		sta VilHeight,x							; store it off
		
		lda CPY_SPEEDX_L1
		sta VilSpeedX_L1,x						; store it off
		
		lda CPY_SPEEDX_H1
		sta VilSpeedX_H1,x						; store it off

		lda m_param00							; get the column value
		sta VilPositionX,x
		sta VilScreenLeftX,x					; store it off
		
		lda m_param01							; get the row value
		sta VilPositionY,x
		sta VilScreenTopY,x						; store it off
		
		lda m_paramW03							; load level line LSB
		sta VilPosLSB							; store it off
		lda m_paramW03+1						; load level line MSB
		sta VilPosMSB							; store it off

		lda #$00								; set the others to zero
		sta VilTimers,x							; store it off	
		sta VilCurrFrame,x						; store it off

		sta VilCollisionX,x						; store it off
		sta VilOldCollisionX,x					; store it off
		
		sta VilCollisionY,x						; store it off
		sta VilOldCollisionY,x					; store it off
		
		sta VilSideSpeedX_L1,x					; store it off
		sta VilSideSpeedX_H1,x					; store it off
		
		sta VilSideSpeedAccelX_L1,x				; store it off
		sta VilSideSpeedAccelX_H1,x				; store it off
		
		sta VilSideSpeedDeaccelX_L1,x			; store it off
		sta VilSideSpeedDeaccelX_H1,x			; store it off

		sta VilSpeedY_L1,x						; store it off
		sta VilSpeedY_H1,x						; store it off

		sta VilUpDownSpeedY_L1,x				; store it off
		sta VilUpDownSpeedY_H1,x				; store it off
		
		sta VilUpDownSpeedAccelY_L1,x			; store it off
		sta VilUpDownSpeedAccelY_H1,x			; store it off
		
		sta VilUpDownSpeedDeaccelY_L1,x			; store it off
		sta VilUpDownSpeedDeaccelY_H1,x			; store it off

		sta VilOldScreenTopY,x					; store it off
		sta VilOldScreenLeftX,x					; store it off

		sta VilLevelLeftX_H2,x					; store it off
		sta VilLevelLeftX_H1,x					; store it off
		sta VilLevelLeftX_L1,x					; store it off

		sta VilLevelRightX_H2,x					; store it off
		sta VilLevelRightX_H1,x					; store it off
		sta VilLevelRightX_L1,x					; store it off

		sta VilLevelTopY_H2,x					; store it off
		sta VilLevelTopY_H1,x					; store it off
		sta VilLevelTopY_L1,x					; store it off

		sta VilLevelBottomY_H2,x				; store it off
		sta VilLevelBottomY_H1,x				; store it off					
		sta VilLevelBottomY_L1,x				; store it off
		
Exit

		rts
		
.endp

;
;***************************************************************************************************
;	CreepyDraw
;
;		Draws the creepy villian
;
;		uses:			m_villianCurrIndex	-	Index value to work against
;
;***************************************************************************************************
;
.proc CreepyDraw

		ldx m_villianCurrIndex
		cpx #$FF
		bne GetTimer
		jmp Exit
		
GetTimer
		
		lda VilTimers,x
		cmp VilDelay,x
		beq ResetTimer
		
		inc VilTimers,x
		jmp Exit
				
ResetTimer
				
		lda #$00
		sta VilTimers,x

GetParams			

		lda VilScreenTopY,x
		sta m_vars00
		
		lda VilHeight,x
		sta m_vars01
		
		lda VilCurrFrame,x
		sta m_vars03

		lda #$00
		ldy VilOldScreenTopY,x		
					
		ldx #$00		
		lda #$00
		
		ldx m_villianCurrIndex

		lda VilColorLSB,x
		sta Color00+1
		lda VilColorMSB,x
		sta Color00+2

		lda VilAnimLSB,x
		sta m_paramW01
		lda VilAnimMSB,x
		sta m_paramW01+1
		
		ldx m_vars03
		
Color00

		lda $FFFF,x		
		sta COLPM2

		ldx m_vars01
		lda m_vars03
		jsr MultiplyAX
				
		ldy _productLo
		ldx m_vars00

		lda #$00
		sta m_vars02

Anim00	

		lda (m_paramW01),y
		sta p2_area_1,x
		
		inx
		iny
		
		inc m_vars02
		lda m_vars02
		cmp m_vars01
		
		bne Anim00

Exit

		rts	
.endp

;
;***************************************************************************************************
;	CreepyMove
;
;		Moves with collision checking the creepy villian
;
;		uses:			m_villianCurrIndex	-	Index value to work against
;
;***************************************************************************************************
;
.proc CreepyMove

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit
					
		jsr VillianSideMoveContained			; do the side movement within the platform 
		
SetScreemPos

		jsr VillianSetScreenPos					; update the screen position with the values
				
Exit

		rts
		
.endp

;
;***************************************************************************************************
;	CreepyState
;
;		Determine the current state of the creepy villian
;
;		uses:			m_villianCurrIndex	-	Index value to work against
;
;***************************************************************************************************
;
.proc CreepyState

		lda TabHardwareCollision+12
		cmp #$06
		beq CheckState
		jmp Exit

CheckState
		lda m_playerState
		cmp #PS_LOSE
		bne GetBounds
		jmp Exit
		
GetBounds
		
		clc
		lda m_playerScreenTopY
		adc #PLR_HEIGHT
		sec
		sbc #$01
		sta m_playerBottomY

		clc
		lda VilScreenTopY,x
		adc VilHeight,x
		sta m_villianBottomY	
		
		lda m_playerBottomY
		cmp m_villianBottomY
		bcs Exit
		
		lda VilScreenTopY,x
		cmp m_playerBottomY
		bcc ProcessState
		beq ProcessState
		jmp Exit
		
ProcessState		
		
		lda m_playerState
		cmp #PS_OVER_PLATFORM
		bne FallingVillian
		
		ldx #PS_LOSE
		jsr SetPlayerMethod
		
		lda #$00
		sta TabHardwareCollision+12
				
		jmp Exit

FallingVillian
	
		lda m_playerState
		cmp #PS_FALLING
		bne Exit
		
		lda #$00
		sta VilActive,x

		lda VilHeight,x
		sta m_vars01

		ldy VilScreenTopY,x	

		ldx #$00		
		lda #$00
		
ClearVillian

		sta p2_area_1,y	
		iny
		inx
		cpx m_vars01
		bne ClearVillian

Exit

		rts

.endp`