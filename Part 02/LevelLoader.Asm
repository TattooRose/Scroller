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
; 	LoadDisplayListData
;
;		Routine to load the desired display list data to Atari's LISTL and LISTH location.
;
;		Parameters:		_param00	-	Length of data
;						_paramW01	-	Source of data
;						_paramW02	-	Destination of data
;
;		Destroy's A, X, and Y registers 
;
;**************************************************************************************************
.proc LoadDisplayListData

		ldx _param00
		ldy #$00

;*****	Loop until data length is reached	
loop
		lda (_paramW01), y
		sta (_paramW02), y
		iny
		dex
		bne loop
		
		rts

.endp

;
;**************************************************************************************************
; LoadLevel
;
;	Level index is passed in zero page PARAM00
;
;**************************************************************************************************
.proc LoadLevel

		ldx _param00
				
		lda LevelsAddr_LSB,x					; get the LSB for the requested levels data
		sta m_ptrLevelAddr						; store it in our zero page pointer
		lda LevelsAddr_MSB,x					; get the MSB for the requested levels data
		sta m_ptrLevelAddr + 1					; store it in our zero page pointer
		
		lda #$00								; initialize the counters
		sta _scrYCount		
		sta _datYCount
		
		tay										; begin with the Y register set

;************************************************
;
GetNextRowCol		
		
		ldy _datYCount		
		lda (m_ptrLevelAddr), y					; make sure this level is valid (while not EOD)
		cmp #LN_EOD								; check for eof of level data
		beq ExitLoadLevel						; true jump to exit

StoreRow
		
		sta	_currRow							; save off the first byte the current row

		inc _datYCount							; increment for COLS value
		ldy _datYCount							; use it
		lda (m_ptrLevelAddr),y					; make sure this level is valid
		sta _currCol							; now we have the current column
		
		ldx _currCol
		lda TabLevelLineAddressLSB,x			; get the low part of the screen address by row
		clc
		adc _currRow		
		sta m_ptrLevelLine						; save it off to the current line address		
		lda TabLevelLineAddressMSB,x			; get the low part of the screen address by row
		adc #$00
		sta m_ptrLevelLine + 1					; save it off to the current line address

;************************************************
;
SetCharacter
  		
  		inc _datYCount							; increment for next COLS value
		ldy _datYCount							; use the value

		lda (m_ptrLevelAddr),y					; check for line break
		cmp #LN_BRK								; did we hit it 
		beq GetNextDataLine						; go reset the counters and test for carriage return  

;		sta _currChar							; hold the maps character		
;		lda _currChar							; get the character back

		ldy _scrYCount
		sta (m_ptrLevelLine),y					; store it at location
		inc _scrYCount
		
		jmp SetCharacter						; do the process all over
		
;************************************************
;
GetNextDataLine
		
		lda #$00
		sta _scrYCount
		
  		inc _datYCount							; increment for next COLS value
		ldy _datYCount							; use the value
		lda (m_ptrLevelAddr), y					; load up the next level data item
		
		cmp #LN_CRG								; check for carraige return
		beq SetNextRowCol						; true get the next row of data
		
		jmp StoreRow		

SetNextRowCol
		inc _datYCount		
		
		clc
		lda m_ptrLevelAddr					; get the LSB for the requested levels data
		adc _datYCount
		sta m_ptrLevelAddr
		lda m_ptrLevelAddr + 1
		adc #$00
		sta m_ptrLevelAddr + 1					; store it in our zero page pointer

		lda #$00
		sta _datYCount

		jmp GetNextRowCol			
 
;************************************************
;
ExitLoadLevel

		rts
			
.endp	

		