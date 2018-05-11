;
;***************************************************************************************************
;
;	Filename:		LevelLoader.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; Constants
;**************************************************************************************************
;
LN_BRK				= $FD
LN_CRG				= $FE
LN_EOD				= $FF

;
;**************************************************************************************************
; 	LoadDisplayListData
;
;		Routine to load the desired display list data to Atari's LISTL and LISTH location.
;
;		Parameters:		m_param00	-	Length of data
;						m_paramW01	-	Source of data
;						m_paramW02	-	Destination of data
;
;		Destroy's A, X, and Y registers 
;
;**************************************************************************************************
.proc LoadDisplayListData

		ldx m_param00
		ldy #$00

;*****	Loop until data length is reached	
loop
		lda (m_paramW01), y
		sta (m_paramW02), y
		iny
		dex
		bne loop
		
		rts

.endp

;
;**************************************************************************************************
; LoadLevel
;
;	Level index is passed in zero page PARAM01
;
;**************************************************************************************************
.proc LoadLevel

		ldx m_param01
				
		lda LevelsAddr_LSB,x					; get the LSB for the requested levels data
		sta m_ptrLevelAddr						; store it in our zero page pointer
		lda LevelsAddr_MSB,x					; get the MSB for the requested levels data
		sta m_ptrLevelAddr + 1					; store it in our zero page pointer
		
		lda #$00								; initialize the counters
		sta m_scrYCount		
		sta m_datYCount
		
		tay										; begin with the Y register set

;************************************************
;
GetNextRowCol		
		
		ldy m_datYCount		
		lda (m_ptrLevelAddr), y					; make sure this level is valid (while not EOD)
		cmp #LN_EOD								; check for eof of level data
		beq ExitLoadLevel						; true jump to exit

StoreRow
		
		sta	m_currRow							; save off the first byte the current row

		inc m_datYCount							; increment for COLS value
		ldy m_datYCount							; use it
		lda (m_ptrLevelAddr),y					; make sure this level is valid
		sta m_currCol							; now we have the current column
		
		ldx m_currCol
		lda TabLevelLineAddressLSB,x			; get the low part of the screen address by row
		clc
		adc m_currRow		
		sta m_ptrLevelLine						; save it off to the current line address		
		lda TabLevelLineAddressMSB,x			; get the low part of the screen address by row
		adc #$00
		sta m_ptrLevelLine + 1					; save it off to the current line address

;************************************************
;
SetCharacter
  		
  		inc m_datYCount							; increment for next COLS value
		ldy m_datYCount							; use the value

		lda (m_ptrLevelAddr),y					; check for line break
		cmp #LN_BRK								; did we hit it 
		beq GetNextDataLine						; go reset the counters and test for carriage return  

;		sta mm_currChar							; hold the maps character		
;		lda mm_currChar							; get the character back

		ldy m_scrYCount
		sta (m_ptrLevelLine),y					; store it at location
		inc m_scrYCount
		
		jmp SetCharacter						; do the process all over
		
;************************************************
;
GetNextDataLine
		
		lda #$00
		sta m_scrYCount
		
  		inc m_datYCount							; increment for next COLS value
		ldy m_datYCount							; use the value
		lda (m_ptrLevelAddr), y					; load up the next level data item
		
		cmp #LN_CRG								; check for carraige return
		beq SetNextRowCol						; true get the next row of data
		
		jmp StoreRow		

SetNextRowCol
		inc m_datYCount		
		
		clc
		lda m_ptrLevelAddr					; get the LSB for the requested levels data
		adc m_datYCount
		sta m_ptrLevelAddr
		lda m_ptrLevelAddr + 1
		adc #$00
		sta m_ptrLevelAddr + 1					; store it in our zero page pointer

		lda #$00
		sta m_datYCount

		jmp GetNextRowCol			
 
;************************************************
;
ExitLoadLevel

		rts
	
.endp			