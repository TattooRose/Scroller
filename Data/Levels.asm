;
;****************************************************************************************************
;
;	Player Data
;
;		Each row of X and Y is associated with a level number (zero based).
;
;****************************************************************************************************
;
LevelsPlayer_X
			.byte $02

LevelsPlayer_Y
			.byte $0B
;
;****************************************************************************************************
;
;	Level Data
;
;		Low (LSB) and High (MSB) addresses of the level data map
;
;****************************************************************************************************
;
LevelsAddr_LSB
	.byte <LEV.else_01

LevelsAddr_MSB
	.byte >LEV.else_01
;
;****************************************************************************************************
;
LEV.else_01
			.byte $01,$0A,$01,$FD,$04,$0A,$01,$FD,$07,$0A,$01,$FD,$FE
			.byte $0A,$0B,$01,$FD,$14,$0B,$01,$FD,$16,$0B,$01,$FD,$1D,$0B,$03,$FD,$1F,$0B,$03,$FD,$FE
			.byte $00,$0C,$60,$60,$60,$60,$60,$60,$60,$60,$FD,$0C,$0C,$01,$FD,$0E,$0C,$01,$FD,$26,$0C,$01,$FD,$28,$0C,$01,$FD,$2A,$0C,$01,$FD,$FE
			.byte $08,$0D,$60,$60,$60,$FD,$14,$0D,$71,$71,$71,$FD,$1D,$0D,$61,$61,$61,$FD,$2D,$0D,$01,$FD,$FE
			.byte $0B,$0E,$60,$60,$60,$60,$FD,$1C,$0E,$60,$70,$70,$70,$60,$FD,$26,$0E,$60,$60,$60,$60,$60,$FD,$FE
			.byte $26,$0F,$5E,$5D,$5D,$5D,$5D,$60,$60,$60,$FD,$FE
			.byte $26,$10,$65,$23,$24,$25,$65,$66,$67,$5D,$FD,$36,$10,$01,$FD,$38,$10,$01,$FD,$3A,$10,$01,$FD,$FE
			.byte $00,$11,$60,$60,$60,$60,$60,$60,$FD,$13,$11,$01,$FD,$15,$11,$01,$FD,$17,$11,$01,$FD,$28,$11,$95,$FD,$2D,$11,$5D,$FD,$FE
			.byte $28,$12,$95,$FD,$2D,$12,$5D,$FD,$35,$12,$60,$60,$60,$60,$60,$60,$60,$60,$FD,$FE
			.byte $1A,$13,$60,$60,$99,$99,$99,$99,$99,$60,$60,$FD,$28,$13,$95,$FD,$2B,$13,$01,$FD,$2D,$13,$5D,$FD,$35,$13,$10,$11,$12,$FD,$FE
			.byte $1A,$14,$5D,$5D,$FD,$21,$14,$5D,$5D,$FD,$28,$14,$95,$FD,$2A,$14,$01,$FD,$2D,$14,$5D,$FD,$35,$14,$10,$11,$12,$FD,$FE
			.byte $17,$15,$60,$60,$60,$5D,$5D,$FD,$21,$15,$5D,$5D,$FD,$28,$15,$95,$FD,$2B,$15,$01,$FD,$2D,$15,$5D,$FD,$35,$15,$10,$11,$12,$FD,$3B,$15,$01,$FD,$3D,$15,$01,$FD,$3F,$15,$01,$FD,$41,$15,$01,$FD,$43,$15,$01,$FD,$45,$15,$01,$FD,$47,$15,$01,$FD,$49,$15,$01,$FD,$4B,$15,$01,$FD,$4D,$15,$01,$FD,$4F,$15,$01,$FD,$FE
			.byte $15,$16,$60,$60,$60,$60,$60,$5D,$5D,$FD,$21,$16,$5D,$6B,$FD,$28,$16,$95,$FD,$2D,$16,$5D,$FD,$35,$16,$10,$11,$12,$FD,$FE
			.byte $00,$17,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$5C,$6A,$60,$60,$60,$60,$60,$5D,$5D,$60,$60,$60,$60,$20,$21,$22,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$FD,$FE
			.byte $FF

