;	
;**************************************************************************************************
;
; 	Filename:		LevelLoader.Asm
;
; 	Modified On:	Sun Apr 15, 2018 02:32 PM
;
;**************************************************************************************************
; Constants
;**************************************************************************************************
;
PLAYER				= $FC
LN_BRK				= $FD
LN_CRG				= $FE
LN_EOD				= $FF
;
;**************************************************************************************************
; Local Data Storage
;**************************************************************************************************
;
_currRow			.byte $00
_currCol			.byte $00
_scrYCount			.byte $00
_datYCount			.byte $00
;
;**************************************************************************************************
; LoadLevel
;
;	Level index is passed in zero page PARAM01
;
;**************************************************************************************************
.proc LoadLevel

		ldx _param01
				
		lda LevelsAddr_LSB,x					; get the LSB for the requested levels data
		sta _ptrLevelAddr						; store it in our zero page pointer
		lda LevelsAddr_MSB,x					; get the MSB for the requested levels data
		sta _ptrLevelAddr + 1					; store it in our zero page pointer
		
		lda #$00								; initialize the counters
		sta _scrYCount		
		sta _datYCount
		
		tay										; begin with the Y register set

;************************************************
;
GetNextRowCol		
		
		ldy _datYCount		
		lda (_ptrLevelAddr), y					; make sure this level is valid (while not EOD)
		cmp #LN_EOD								; check for eof of level data
		beq ExitLoadLevel						; true jump to exit

StoreRow
		
		sta	_currRow							; save off the first byte the current row

		inc _datYCount							; increment for COLS value
		ldy _datYCount							; use it
		lda (_ptrLevelAddr),y					; make sure this level is valid
		sta _currCol							; now we have the current column
		
		ldx _currCol
		lda TabLevelLineAddressLSB,x			; get the low part of the screen address by row
		clc
		adc _currRow		
		sta _ptrLevelLine						; save it off to the current line address		
		lda TabLevelLineAddressMSB,x			; get the low part of the screen address by row
		adc #$00
		sta _ptrLevelLine + 1					; save it off to the current line address

;************************************************
;
SetCharacter
  		
  		inc _datYCount							; increment for next COLS value
		ldy _datYCount							; use the value

		lda (_ptrLevelAddr),y					; check for line break
		cmp #LN_BRK								; did we hit it 
		beq GetNextDataLine						; go reset the counters and test for carriage return  

		ldy _scrYCount
		sta (_ptrLevelLine),y					; store it at location
		inc _scrYCount
		
		jmp SetCharacter						; do the process all over
		
;************************************************
;
GetNextDataLine
		
		lda #$00
		sta _scrYCount
		
  		inc _datYCount							; increment for next COLS value
		ldy _datYCount							; use the value
		lda (_ptrLevelAddr), y					; load up the next level data item
		
		cmp #LN_CRG								; check for carraige return
		beq SetNextRowCol						; true get the next row of data
		
		jmp StoreRow		

SetNextRowCol
		inc _datYCount		
		
		clc
		lda _ptrLevelAddr						; get the LSB for the requested levels data
		adc _datYCount
		sta _ptrLevelAddr
		lda _ptrLevelAddr + 1
		adc #$00
		sta _ptrLevelAddr + 1					; store it in our zero page pointer

		lda #$00
		sta _datYCount

		jmp GetNextRowCol			
 
;************************************************
;
ExitLoadLevel

		rts
	
.endp			