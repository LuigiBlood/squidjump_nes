game_stage_copy:
	ldx #0
 -;	lda game_stage_data,x
	sta stgbuf,x
	inx
	bne -
	rts

game_stage_data:
	//Type, X-Pos, Length, Y-Pos (16-bit)
	db $00, $00, $20; dw $0004
	db $01, $16, $07; dw $000C
	db $00, $03, $09; dw $0014
	db $FF	//End
game_stage_data_end:
