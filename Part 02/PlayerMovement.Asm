;
;**************************************************************************************************
; 	Filename:		PlayerMovement.Asm
;
; 	Modified On:	Mar 23, 2018 03:16:00 PM
;	
;**************************************************************************************************
;
;*****	Local Storage
;
m_hldA							.byte $00
m_hldY							.byte $00
m_hldX							.byte $00
m_revX							.byte $00
m_revIndex						.byte $00
m_revHeight						.byte $00
m_revOffset						.byte $00
m_animCount						.byte $00
m_animFrame						.byte $00
m_animIndex        				.byte $00
m_animHeight					.byte $00
m_animOffset					.byte $00	

m_leftTopChar					.byte $00
m_rightTopChar					.byte $00
m_charBuffer_H2					.byte $00
m_leftBottomChar				.byte $00
m_rightBottomChar				.byte $00
m_middleBottomChar				.byte $00
m_bottomPosOffsetX				.byte $00
m_bottomPosOffsetY				.byte $00
m_playerExplosionStep			.byte $00
m_middleBottomCharPosX			.byte $00
m_WaterPlayerDirectionFlag		.byte $00
m_playerOnWaterSurfaceFlag		.byte $00
m_playerExplosionScreenTopY_H1	.byte $00
m_playerExplosionScreenTopY_L1	.byte $00

;
;**************************************************************************************************
; SetAnimationIndex
;**************************************************************************************************
;
.proc SetAnimationIndex

CheckState
		lda m_playerState
		cmp #PS_OVER_PLATFORM
		beq CheckWalking	
		cmp #PS_STATIC
		beq StandingIndex
		cmp #PS_JUMPING
		beq StandingIndex
		cmp #PS_FALLING
		beq StandingIndex		
		cmp #PS_CLIMBING
		beq StandingIndex		
		cmp #PS_IN_WATER
		beq StandingIndex		
		cmp #PS_LOSE
		jmp StandingIndex		
		 
CheckWalking
		lda m_stick0
		and #[STICK_RIGHT | STICK_LEFT]
		cmp #[STICK_RIGHT | STICK_LEFT]
		bne ProcessFrame
		jmp StandingIndex
			
ProcessFrame		
		; Process frame 
		lda m_animFrame
		adc #$01
		sta m_animFrame
		
IsWalking
		and #12
		cmp #12
		bne check_one
		jmp WalkingIndex1
		
check_one
		lda m_animFrame
		and #8		
		cmp #8
		bne check_two
		jmp StandingIndex
		
check_two
		lda m_animFrame
		and #4
		cmp #4
		bne check_three		
		jmp WalkingIndex

check_three
		jmp StandingIndex		

WalkingIndex
		lda #$03
		jmp Return_Exit		

WalkingIndex1
		lda #$06
		jmp Return_Exit		

StandingIndex
		lda #0	
				
Return_Exit
		sta m_animIndex
		tax	
		lda TabAnimationMap,x
		sta m_animOffset
		lda TabAnimationMap+1,x
		sta m_animHeight
				
		rts		
.endp

;
;**************************************************************************************************
; FlipPlayer
;**************************************************************************************************
;
.proc FlipPlayer
	
		pha
		txa
		pha
		tya
		pha	
			
		lda TabAnimationMap[0]+2,x	
		cmp m_lastplayerSideDirection
		beq FlipExit

		lda TabAnimationMap[0],x
		sta m_revOffset
				
		lda TabAnimationMap[0]+1,x
		sta m_revHeight
		
		lda m_lastPlayerSideDirection
		sta TabAnimationMap[0]+2,x		
		
		ldy #0
		ldx m_revOffset				
Flip	lda TabPlayerShape_01,x
		jsr ReverseSprite 
		sta TabPlayerShape_01,x
		
		lda TabPlayerShape_01A,x
		jsr ReverseSprite 
		sta TabPlayerShape_01A,x
		
		lda TabPlayerShape_01B,x
		jsr ReverseSprite 
		sta TabPlayerShape_01B,x
		inx
		iny
		cpy m_revHeight
		bne Flip
		
FlipExit
		pla
		tay
		pla
		tax
		pla
		rts
.endp
;
;**************************************************************************************************
; ReverseSprite
;**************************************************************************************************
;
.proc ReverseSprite
		sta m_hldA
		sty m_hldY
	 	ldy #$07 
loop1   asl m_hldA
        ror 
        dey 
        bpl loop1        
        ldy m_hldY
        rts
.endp         	
;
;**************************************************************************************************
; SetPlayerInfo
;**************************************************************************************************
;
.proc SetPlayerInfo

		lda m_playerLevelLeftX_H1				; update right coordinate
		clc
		adc m_playerSizeXMinusOne
		sta m_playerLevelRightX_H1
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelRightX_H2

		lda m_playerLevelBottomY_H1				; update top coordinate
		sec
		sbc m_playerSizeYMinusOne
		sta m_playerLevelTopY_H1
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelTopY_H2

		rts
		
.endp		
;
;**************************************************************************************************
; SetPlayerScreenPos
;**************************************************************************************************
;
.proc SetPlayerScreenPos

		lda m_playerScreenLeftX					; save old screen pos
		sta m_oldPlayerScreenLeftX

		lda m_playerScreenTopY
		sta m_oldPlayerScreenTopY
		;
		; get new screen pos
		;
		; 	(this should use the "_H2" positions if the delta between the player
		; 	and the camera is too big, 64 chars in X, or 32 chars in Y)
		;
		lda m_playerLevelLeftX_H1
		sec
		sbc m_levelWindowX_H1
		clc
		adc #PM_BASE_SCREEN_X
		sta m_playerScreenLeftX

		lda m_playerLevelTopY_H1
		sec
		sbc m_levelWindowY_H1
		clc
		adc #PM_BASE_SCREEN_Y
		sta m_playerScreenTopY

		inc m_redrawPlayerCounter				; signal for the DLI to redraw the player

		rts

.endp		
;
;**************************************************************************************************
; DrawPlayer
;**************************************************************************************************
;
.proc DrawPlayer

		lda m_playerBaseColor00
		sta COLPM0
		lda m_playerBaseColor01
		sta COLPM1
		lda m_playerBaseColor02
		sta COLPM2

		lda m_redrawPlayerCounter
		bne zdraw		
		jmp DP_exit				

zdraw
		lda #0
		sta HPOSP0
		sta HPOSP1
		sta HPOSP2
		sta m_redrawPlayerCounter
				
		jsr SetAnimationIndex

		lda #0
		ldx #0
		ldy m_oldPlayerScreenTopY	
zfill	
		sta p0_area_1,y
		sta p1_area_1,y
		sta p2_area_1,y
		iny
		inx
		cpx m_revHeight
		bne zfill

		ldx m_animIndex
		jsr FlipPlayer		

		lda m_playerScreenLeftX
		sta HPOSP0
		sta HPOSP1
		sta HPOSP2

		lda #$00
		sta m_animCount
		ldx m_animOffset
		ldy m_playerScreenTopY	
fill01
		lda TabPlayerShape_01,x
		sta p0_area_1,y		
		lda TabPlayerShape_01A,x
		sta p1_area_1,y
		lda TabPlayerShape_01B,x
		sta p2_area_1,y
		iny
		inx
		inc m_animCount
		lda m_animCount
		cmp m_animHeight
		bcc fill01

DP_exit
		rts
.endp		
;
;**************************************************************************************************
; DrawPlayerExplosion
;**************************************************************************************************
;
.proc DrawPlayerExplosion
		lda m_missleBaseColor00
		sta COLPM3

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
		sta p2_area_1,y
		
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

		jsr InitPlayerInfo						; reached top of the screen, end explosion, respawn player
		jmp DPE_exit
	
;************************************************
;
DPE_do_update
		sta m_playerExplosionScreenTopY_H1
		inc m_playerExplosionStep				; step +1

;************************************************
; draw new player explosion frame
DPE_draw										
		ldx #0
		ldy m_playerExplosionScreenTopY_H1

;************************************************
;
DPE_draw_loop
		lda TabPlayerShape_01,x
		beq DPE_draw_p1
		sta p0_area_1,y

;************************************************
;
DPE_draw_p1
		lda TabPlayerShape_01A,x
		beq DPE_draw_p2	
		sta p1_area_1,y

;************************************************
;
DPE_draw_p2	
		lda TabPlayerShape_01B,x
		beq DPE_draw_end
		sta p2_area_1,y

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
		bne DPE_draw_loop

;************************************************
;
DPE_exit
		
		rts

.endp		
;
;**************************************************************************************************
; CheckPlayerInLevelRightLimit
;**************************************************************************************************
;
.proc CheckPlayerInLevelRightLimit

		lda m_playerLevelLeftX_H1				; update right coordinate
		clc
		adc m_playerSizeXMinusOne
		sta m_playerLevelRightX_H1
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelRightX_H2

		cmp m_levelSizeX_H2
		bcc CPILRL_exit
		bne CPILRL_reset_pos

		lda m_playerLevelRightX_H1
		cmp m_levelSizeX_H1
		bcc CPILRL_exit

;************************************************
;
CPILRL_reset_pos
		lda #0
		sta m_playerLevelLeftX_L1

		lda m_levelSizeX_H1
		sec
		sbc m_playerSizeX
		sta m_playerLevelLeftX_H1
		lda m_levelSizeX_H2
		sbc #0
		sta m_playerLevelLeftX_H2

		lda #1
		sta m_playerSideCollisionFlag

;************************************************
;
CPILRL_exit
	
	rts
	
.endp
	
;
;**************************************************************************************************
; CheckPlayerInLevelBottomLimit
;**************************************************************************************************
;
.proc CheckPlayerInLevelBottomLimit

		lda m_playerLevelBottomY_H2
		cmp m_levelSizeY_H2
		bcc Exit
		bne Reset_Pos

		lda m_playerLevelBottomY_H1
		cmp m_levelSizeY_H1
		bcc Exit

;************************************************
;
Reset_Pos
		lda #0
		sta m_playerLevelBottomY_L1

		lda m_levelSizeY_H1
		sec
		sbc #1
		sta m_playerLevelBottomY_H1
		lda m_levelSizeY_H2
		sbc #0
		sta m_playerLevelBottomY_H2

		lda #1
		sta m_playerOverPlatformFlag

;************************************************
;
Exit
		rts

.endp		
;
;**************************************************************************************************
; CheckHoleBelowPlayer
;**************************************************************************************************
;
.proc CheckHoleBelowPlayer

		; get bottom char line
		lda m_playerLevelBottomY_H2
		sta m_charBuffer_H2
		lda m_playerLevelBottomY_H1
		clc
		adc #1									; check one pixel below the bottom line of the player
		bcc CHBP_get_char_line
		inc m_charBuffer_H2

;************************************************
;
CHBP_get_char_line
		
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		; check bottom level limit
		cmp m_levelCharSizeY
		bcs CHBP_no_hole

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		; update right coordinate
		lda m_playerLevelLeftX_H1
		clc
		adc m_playerSizeXMinusOne
		sta m_playerLevelRightX_H1
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelRightX_H2

		; get left point char column
		lda m_playerLevelLeftX_H2
		sta m_charBuffer_H2
		lda m_playerLevelLeftX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_leftBottomChar

		; get right point char column
		lda m_playerLevelRightX_H2
		sta m_charBuffer_H2
		lda m_playerLevelRightX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_rightBottomChar
	
		; fast collision check
		lda m_leftBottomChar
		and #15
		cmp #CT_BLOCK
		bne CHBP_check_next_char

		lda m_leftBottomChar
		and #%00010000
		bne CHBP_no_hole

;************************************************
;
CHBP_check_next_char
		
		lda m_rightBottomChar
		and #15
		cmp #CT_BLOCK
		bne CHBP_hole

		lda m_rightBottomChar
		and #%00010000
		bne CHBP_no_hole

;************************************************
;
CHBP_hole

		; need to change the player to the falling state
		lda #0
		sta m_playerOverPlatformFlag
		rts

;************************************************
;
CHBP_no_hole

		lda #1
		sta m_playerOverPlatformFlag
		rts
.endp
;
;**************************************************************************************************
; CheckPlayerBottomCollision
;**************************************************************************************************
;
.proc CheckPlayerBottomCollision

		; get bottom char line
		lda m_playerLevelBottomY_H2
		sta m_charBuffer_H2
		lda m_playerLevelBottomY_H1

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		; update right coordinate
		lda m_playerLevelLeftX_H1
		clc
		adc m_playerSizeXMinusOne
		sta m_playerLevelRightX_H1
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelRightX_H2

		; get left point char column
		lda m_playerLevelLeftX_H2
		sta m_charBuffer_H2
		lda m_playerLevelLeftX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_leftBottomChar

		; get right point char column
		lda m_playerLevelRightX_H2
		sta m_charBuffer_H2
		lda m_playerLevelRightX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_rightBottomChar

		; fast collision check
		lda m_leftBottomChar
		and #15
		cmp #CT_BLOCK
		bne CPBC_check_next_char

		lda m_leftBottomChar
		and #%00010000
		bne CPBC_found_collision

;************************************************
;
CPBC_check_next_char

		lda m_rightBottomChar
		and #15
		cmp #CT_BLOCK
		bne CPBC_exit

		lda m_rightBottomChar
		and #%00010000
		beq CPBC_exit

;************************************************
;
CPBC_found_collision

		; need to move the player up and change to the platform state
		lda #1
		sta m_playerOverPlatformFlag

		lda #0
		sta m_playerLevelBottomY_L1

		lda m_playerLevelBottomY_H1
		and #%11111000		; mask for CHAR_PIXELS_Y
		sec
		sbc #1
		sta m_playerLevelBottomY_H1
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelBottomY_H2

;************************************************
;
CPBC_exit
		rts

.endp		
;
;**************************************************************************************************
; CheckPlayerTopCollision
;**************************************************************************************************
;
.proc CheckPlayerTopCollision

		lda m_playerLevelBottomY_H1				; update top coordinate
		sec
		sbc m_playerSizeYMinusOne
		sta m_playerLevelTopY_H1
		
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelTopY_H2

		lda m_playerLevelTopY_H2				; get top char line
		sta m_charBuffer_H2
		lda m_playerLevelTopY_H1

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda m_playerLevelLeftX_H1				; update right coordinate
		clc
		adc m_playerSizeXMinusOne
		sta m_playerLevelRightX_H1
		
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelRightX_H2

		lda m_playerLevelLeftX_H2				; get left point char column
		sta m_charBuffer_H2
		
		lda m_playerLevelLeftX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		
		tax		
		lda TabCharDefinition,x
		sta m_leftTopChar

		lda m_playerLevelRightX_H2				; get right point char column	
		sta m_charBuffer_H2
		
		lda m_playerLevelRightX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_rightTopChar

		lda m_leftTopChar						; fast collision check	
		and #15
		cmp #CT_BLOCK
		bne CPTC_check_next_char

		lda m_leftTopChar
		and #%00100000
		bne CPTC_found_collision

;**************************************************
;
CPTC_check_next_char
		
		lda m_rightTopChar
		and #15
		cmp #CT_BLOCK
		bne CPTC_exit

		lda m_rightTopChar
		and #%00100000
		beq CPTC_exit

;**************************************************
;
CPTC_found_collision

		lda #1									; need to move the player down
		sta m_playerTopCollisionFlag

		lda #0
		sta m_playerLevelBottomY_L1

		lda m_playerLevelTopY_H1
		and #%11111000							; mask for CHAR_PIXELS_Y
		clc
		adc #CHAR_PIXELS_Y 						; +m_playerSizeY
		sta m_playerLevelBottomY_H1
		
		lda m_playerLevelTopY_H2
		adc #0
		sta m_playerLevelBottomY_H2

		lda m_playerLevelBottomY_H1
		clc
		adc m_playerSizeYMinusOne
		sta m_playerLevelBottomY_H1
		
		lda m_playerLevelBottomY_H2
		adc #0
		sta m_playerLevelBottomY_H2

;**************************************************
;
CPTC_exit
		rts

.endp		
;
;**************************************************************************************************
; CheckPlayerLeftCollision
;**************************************************************************************************
;
.proc CheckPlayerLeftCollision

		lda m_playerLevelBottomY_H1				; update top coordinate
		sec
		sbc m_playerSizeYMinusOne
		sta m_playerLevelTopY_H1
		
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelTopY_H2

		lda m_playerLevelLeftX_H2				; get left point char column
		sta m_charBuffer_H2
		lda m_playerLevelLeftX_H1

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda m_playerLevelTopY_H2				; get top char line	
		sta m_charBuffer_H2
		lda m_playerLevelTopY_H1

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_leftTopChar

		lda m_playerLevelBottomY_H2				; get bottom char line
		sta m_charBuffer_H2
		lda m_playerLevelBottomY_H1

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax
		
		lda TabCharDefinition,x
		sta m_leftBottomChar

		lda m_leftTopChar						; fast collision check
		and #15
		cmp #CT_BLOCK
		bne CPLC_check_next_char

		lda m_leftTopChar
		and #%10000000
		bne CPLC_found_collision

;**************************************************
;
CPLC_check_next_char

		lda m_leftBottomChar
		and #15
		cmp #CT_BLOCK
		bne CPLC_exit

		lda m_leftBottomChar
		and #%10000000
		beq CPLC_exit

;**************************************************
;
CPLC_found_collision

		lda #1
		sta m_playerSideCollisionFlag

		lda #0									; need to move the player to the right
		sta m_playerLevelLeftX_L1

		lda m_playerLevelLeftX_H1
		and #%11111100							; mask for CHAR_PIXELS_X
		clc
		adc #CHAR_PIXELS_X
		sta m_playerLevelLeftX_H1
		
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelLeftX_H2

;**************************************************
;
CPLC_exit	
		rts

.endp	
;
;**************************************************************************************************
; CheckPlayerRightCollision
;**************************************************************************************************
;
.proc CheckPlayerRightCollision

		lda m_playerLevelBottomY_H1				; update top coordinate
		sec
		sbc m_playerSizeYMinusOne
		sta m_playerLevelTopY_H1
	
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelTopY_H2

		lda m_playerLevelLeftX_H1				; update right coordinate
		clc
		adc m_playerSizeXMinusOne
		sta m_playerLevelRightX_H1
	
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelRightX_H2

		lda m_playerLevelRightX_H2				; get right point char column
		sta m_charBuffer_H2
		
		lda m_playerLevelRightX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror
		tay

		lda m_playerLevelTopY_H2				; get top char line
		sta m_charBuffer_H2
	
		lda m_playerLevelTopY_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror	

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
	
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax
	
		lda TabCharDefinition,x
		sta m_rightTopChar

		lda m_playerLevelBottomY_H2				; get bottom char line
		sta m_charBuffer_H2
		lda m_playerLevelBottomY_H1

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
	
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax	
		lda TabCharDefinition,x
		sta m_rightBottomChar

		lda m_rightTopChar						; fast collision check
		and #15
		cmp #CT_BLOCK
		bne CPRC_check_next_char

		lda m_rightTopChar
		and #%01000000
		bne CPRC_found_collision

;**************************************************
;
CPRC_check_next_char
		
		lda m_rightBottomChar
		and #15
		cmp #CT_BLOCK
		bne CPRC_exit

		lda m_rightBottomChar
		and #%01000000
		beq CPRC_exit

;**************************************************
;
CPRC_found_collision
		lda #1
		sta m_playerSideCollisionFlag

		lda #0									; need to move the player to the left
		sta m_playerLevelLeftX_L1
	
		lda m_playerLevelRightX_H1
		and #%11111100							; mask for CHAR_PIXELS_X
		sec
		sbc m_playerSizeX
		sta m_playerLevelLeftX_H1
	
		lda m_playerLevelRightX_H2
		sbc #0
		sta m_playerLevelLeftX_H2

;**************************************************
;
CPRC_exit
		rts
		
.endp		
;
;**************************************************************************************************
; AddSideAccelToSpeed
;**************************************************************************************************
;
.proc AddSideAccelToSpeed

		lda m_playerSideSpeed_L1				; update frame speed with frame accel	
		clc
		adc m_playerSideAccel_L1
		sta m_playerSideSpeed_L1
		
		lda m_playerSideSpeed_H1
		adc m_playerSideAccel_H1

;**************************************************
;
ASATS_entry_point
		
		sta m_playerSideSpeed_H1
		cmp m_playerMaxSideSpeed_H1				; check max frame speed
		bcc ASATS_exit							; lower than max speed
		bne ASATS_max_speed						; greater than max speed

		lda m_playerMaxSideSpeed_L1				; need to check the low byte
		cmp m_playerSideSpeed_L1
		bcs ASATS_exit							; lower or equal to max speed

;**************************************************
;
ASATS_max_speed									
		
		lda m_playerMaxSideSpeed_H1				; is higher than the max speed
		sta m_playerSideSpeed_H1
		
		lda m_playerMaxSideSpeed_L1
		sta m_playerSideSpeed_L1

;**************************************************
;
ASATS_exit		
		rts

.endp
;
;**************************************************************************************************
; SubstractSideDeaccelToSpeed
;**************************************************************************************************
;
SubstractSideDeaccelToSpeed

		lda m_playerSideSpeed_L1					; update frame speed with frame accel
		sec
		sbc m_playerSideDeaccel_L1
		sta m_playerSideSpeed_L1

		lda m_playerSideSpeed_H1
		sbc m_playerSideDeaccel_H1
		bcs SSDTS_dont_reset_speed

;************************************************
;
SSDTS_reset_speed
		lda #0
		sta m_playerSideSpeed_L1

;************************************************
;
SSDTS_dont_reset_speed
		sta m_playerSideSpeed_H1

		rts	
;
;**************************************************************************************************
; AddSideSpeedToPosition
;**************************************************************************************************
;
.proc AddSideSpeedToPosition

		lda m_playerLevelLeftX_L1				; update player side position
		clc
		adc m_playerSideSpeed_L1
		sta m_playerLevelLeftX_L1
		
		lda m_playerLevelLeftX_H1		
		adc m_playerSideSpeed_H1
		sta m_playerLevelLeftX_H1
		
		lda m_playerLevelLeftX_H2
		adc #0
		sta m_playerLevelLeftX_H2

		lda #0									; check collisions for a player moving to the right	
		sta m_playerSideCollisionFlag

		jsr CheckPlayerInLevelRightLimit		; check level right side limit
	
		lda m_playerSideCollisionFlag
		bne ASSTP_found_collision

		jsr CheckPlayerRightCollision

		lda m_playerSideCollisionFlag
		beq ASSTP_exit

;************************************************
;
ASSTP_found_collision
		
		lda #0
		sta m_playerSideSpeed_H1
		sta m_playerSideSpeed_L1

;************************************************
;
ASSTP_exit
		
		rts

.endp
;
;**************************************************************************************************
; SubstractSideSpeedToPosition
;**************************************************************************************************
;
.proc SubstractSideSpeedToPosition

		lda m_playerLevelLeftX_L1	; update player side position
		sec
		sbc m_playerSideSpeed_L1
		sta m_playerLevelLeftX_L1
		
		lda m_playerLevelLeftX_H1
		sbc m_playerSideSpeed_H1
		sta m_playerLevelLeftX_H1
		
		lda m_playerLevelLeftX_H2
		sbc #0
		sta m_playerLevelLeftX_H2

		; check collisions for a player moving to the left
		bcs SSSTP_check_left_collision			; check level left side limit
		lda #0
		sta m_playerLevelLeftX_H2
		sta m_playerLevelLeftX_H1
		sta m_playerLevelLeftX_L1
		jmp SSSTP_found_collision

;************************************************
;
SSSTP_check_left_collision
		
		lda #0
		sta m_playerSideCollisionFlag

		jsr CheckPlayerLeftCollision

		lda m_playerSideCollisionFlag
		beq SSSTP_exit

;************************************************
;
SSSTP_found_collision
		
		lda #0
		sta m_playerSideSpeed_H1
		sta m_playerSideSpeed_L1

SSSTP_exit
		rts
		
.endp		
;
;**************************************************************************************************
; AddGravityAccelToSpeed
;**************************************************************************************************
;
.proc AddGravityAccelToSpeed

		lda m_playerSpeedY_L1					; update frame speed with frame accel
		clc
		adc m_playerGravityAccel_L1
		sta m_playerSpeedY_L1
		
		lda m_playerSpeedY_H1
		adc m_playerGravityAccel_H1
		sta m_playerSpeedY_H1

		cmp m_playerMaxFallSpeed_H1				; check max frame speed
		bcc AGATS_exit							; lower than max speed
		bne AGATS_max_speed						; greater than max speed

		lda m_playerMaxFallSpeed_L1				; need to check the low byte
		cmp m_playerSpeedY_L1
		bcs AGATS_exit							; lower or equal to max speed

;************************************************
;
AGATS_max_speed			

		lda m_playerMaxFallSpeed_H1				; is higher than the max speed
		sta m_playerSpeedY_H1
		
		lda m_playerMaxFallSpeed_L1
		sta m_playerSpeedY_L1

;************************************************
;
AGATS_exit
		rts
		
.endp		
;
;**************************************************************************************************
; SubstractGravityAccelToSpeed
;**************************************************************************************************
;
.proc SubstractGravityAccelToSpeed
		
		lda m_playerSpeedY_L1					; update frame speed with frame accel
		sec
		sbc m_playerGravityAccel_L1
		sta m_playerSpeedY_L1
		
		lda m_playerSpeedY_H1
		sbc m_playerGravityAccel_H1
		bcs SGATS_dont_reset_speed

;************************************************
;
SGATS_reset_speed
		lda #0
		sta m_playerSpeedY_L1

;************************************************
;
SGATS_dont_reset_speed
		sta m_playerSpeedY_H1
		rts

.endp
;
;**************************************************************************************************
; AddSpeedYToPosition
;**************************************************************************************************
;
.proc AddSpeedYToPosition

		lda m_playerLevelBottomY_L1				; update player position in Y
		clc
		adc m_playerSpeedY_L1
		sta m_playerLevelBottomY_L1
		
		lda m_playerLevelBottomY_H1
		adc m_playerSpeedY_H1
		sta m_playerLevelBottomY_H1
		
		lda m_playerLevelBottomY_H2
		adc #0
		sta m_playerLevelBottomY_H2

		lda #0									; check collisions for a player moving down
		sta m_playerOverPlatformFlag

		jsr CheckPlayerInLevelBottomLimit		; check level bottom limit collision

		lda m_playerOverPlatformFlag
		bne ASYTP_exit

		jsr CheckPlayerBottomCollision			; check collision with the top of a platform

;************************************************
;
ASYTP_exit
		rts
		
.endp		
;
;**************************************************************************************************
; SubstractSpeedYToPosition
;**************************************************************************************************
;
.proc SubstractSpeedYToPosition

		lda m_playerLevelBottomY_L1				; update player position in Y
		sec
		sbc m_playerSpeedY_L1
		sta m_playerLevelBottomY_L1
		lda m_playerLevelBottomY_H1
		sbc m_playerSpeedY_H1
		sta m_playerLevelBottomY_H1
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelBottomY_H2

		lda m_playerLevelBottomY_H1				; update top coordinate
		sec
		sbc m_playerSizeYMinusOne
		sta m_playerLevelTopY_H1
		lda m_playerLevelBottomY_H2
		sbc #0
		sta m_playerLevelTopY_H2

		bcs SSYTP_check_platform_bottom			; check collisions for a player moving up check level top limit collision

		lda #0
		sta m_playerLevelBottomY_L1
		sta m_playerLevelBottomY_H2

		lda m_playerSizeYMinusOne
		sta m_playerLevelBottomY_H1

		jmp SSYTP_found_collision

SSYTP_check_platform_bottom
	
		lda #0									; check collision with the bottom of a platform
		sta m_playerTopCollisionFlag

		jsr CheckPlayerTopCollision

		lda m_playerTopCollisionFlag
		beq SSYTP_exit

SSYTP_found_collision
		lda #0
		sta m_playerSpeedY_H1
		sta m_playerSpeedY_L1

SSYTP_exit
		rts

.endp		
;
;**************************************************************************************************
; AddWaterAccelToSpeed
;**************************************************************************************************
;
.proc AddWaterAccelToSpeed

		lda m_playerSpeedY_L1					; update frame speed with frame accel
		clc
		adc m_playerWaterAccelY_L1
		sta m_playerSpeedY_L1
		lda m_playerSpeedY_H1
		adc m_playerWaterAccelY_H1
		sta m_playerSpeedY_H1


		cmp m_playerMaxWaterSpeedY_H1			; check max frame speed
		bcc AWATS_exit							; lower than max speed
		bne AWATS_max_speed						; greater than max speed

	
		lda m_playerMaxWaterSpeedY_L1			; need to check the low byte
		cmp m_playerSpeedY_L1
		bcs AWATS_exit							; lower or equal to max speed

;************************************************
;
AWATS_max_speed			

		lda m_playerMaxWaterSpeedY_H1			; is higher than the max speed
		sta m_playerSpeedY_H1
		lda m_playerMaxWaterSpeedY_L1
		sta m_playerSpeedY_L1

;************************************************
;
AWATS_exit
		rts
	
.endp	
;
;**************************************************************************************************
; SubstractWaterAccelToSpeed
;**************************************************************************************************
;
.proc SubstractWaterAccelToSpeed

		lda m_playerSpeedY_L1					; update frame speed with frame accel
		sec
		sbc m_playerWaterAccelY_L1
		sta m_playerSpeedY_L1
		lda m_playerSpeedY_H1
		sbc m_playerWaterAccelY_H1
		bcs SWATS_dont_reset_speed

;************************************************
;
SWATS_reset_speed
		lda #0
		sta m_playerSpeedY_L1

;************************************************
;
SWATS_dont_reset_speed
		sta m_playerSpeedY_H1

		rts
		
.endp		
;
;**************************************************************************************************
; AddWaterMoveUpAccelToSpeed
;**************************************************************************************************
;
.proc AddWaterMoveUpAccelToSpeed

		lda m_playerSpeedY_L1					; update frame speed with frame accel
		clc
		adc m_playerWaterAccelY_L1
		sta m_playerSpeedY_L1
		lda m_playerSpeedY_H1
		adc m_playerWaterAccelY_H1
		sta m_playerSpeedY_H1

		cmp m_playerMoveWaterSpeedY_H1			; check max frame speed
		bcc AWMUATS_exit						; lower than max speed
		bne AWMUATS_max_speed					; greater than max speed

		lda m_playerMoveWaterSpeedY_L1			; need to check the low byte
		cmp m_playerSpeedY_L1
		bcs AWMUATS_exit						; lower or equal to max speed

;************************************************
;
AWMUATS_max_speed								; is higher than the max speed
		
		lda m_playerMoveWaterSpeedY_H1
		sta m_playerSpeedY_H1
		lda m_playerMoveWaterSpeedY_L1
		sta m_playerSpeedY_L1

;************************************************
;
AWMUATS_exit
		rts

.endp	
;
;**************************************************************************************************
; AddWaterMoveDownAccelToSpeed
;**************************************************************************************************
;
.proc AddWaterMoveDownAccelToSpeed

		lda m_playerMaxWaterSpeedY_H1			; check max frame speed
		cmp m_playerSpeedY_H1
		bcc AWMAATS_exit						; greater than max speed, exit
		bne AWMAATS_add							; lower than the max, continue with the add

		lda m_playerSpeedY_L1					; need to check the low byte
		cmp m_playerMaxWaterSpeedY_L1
		bcs AWMAATS_exit						; greater or equal to max speed, exit

;************************************************
;
AWMAATS_add

		lda m_playerSpeedY_L1					; update frame speed with frame accel
		clc
		adc m_playerWaterAccelY_L1
		sta m_playerSpeedY_L1
		lda m_playerSpeedY_H1
		adc m_playerWaterAccelY_H1
		sta m_playerSpeedY_H1

		cmp m_playerMaxWaterSpeedY_H1			; check max frame speed
		bcc AWMAATS_exit						; lower than max speed
		bne AWMAATS_max_speed					; greater than max speed

		lda m_playerMaxWaterSpeedY_L1			; need to check the low byte
		cmp m_playerSpeedY_L1
		bcs AWMAATS_exit						; lower or equal to max speed

;************************************************
;
AWMAATS_max_speed			
		lda m_playerMaxWaterSpeedY_H1			; is higher than the max speed
		sta m_playerSpeedY_H1
		lda m_playerMaxWaterSpeedY_L1
		sta m_playerSpeedY_L1

;************************************************
;
AWMAATS_exit
		
		rts
	
.endp	
;
;**************************************************************************************************
; CheckPlayerBottomDownPos
;**************************************************************************************************
;
.proc CheckPlayerBottomDownPos

		lda m_playerLevelBottomY_H2				; get bottom char line
		sta m_charBuffer_H2

		lda m_playerLevelBottomY_H1
		clc
		adc m_bottomPosOffsetY
		bcc CPBDP_offset_no_carry
		inc m_charBuffer_H2

;************************************************
;
CPBDP_offset_no_carry
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1
	
		lda m_playerLevelLeftX_H2				; get left to right point char column
		sta m_charBuffer_H2

		lda m_playerLevelLeftX_H1
		clc
		adc m_bottomPosOffsetX
		bcc CPBDP_no_carry
		inc m_charBuffer_H2
	
;************************************************
;
CPBDP_no_carry

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		sty m_middleBottomCharPosX
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_middleBottomChar

		rts
	
.endp	
;
;**************************************************************************************************
; CheckPlayerBottomUpPos
;**************************************************************************************************
;
.proc CheckPlayerBottomUpPos

		lda m_playerLevelBottomY_H2				; get bottom char line
		sta m_charBuffer_H2

		lda m_playerLevelBottomY_H1
		sec
		sbc m_bottomPosOffsetY
		bcs CPBUP_offset_no_carry
		dec m_charBuffer_H2

;************************************************
;
CPBUP_offset_no_carry

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
	
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda m_playerLevelLeftX_H2				; get left to right point char column
		sta m_charBuffer_H2

		lda m_playerLevelLeftX_H1
		clc
		adc m_bottomPosOffsetX
		bcc CPBUP_no_carry
		inc m_charBuffer_H2

;************************************************
;
CPBUP_no_carry

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		sty m_middleBottomCharPosX
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_middleBottomChar

		rts

.endp	