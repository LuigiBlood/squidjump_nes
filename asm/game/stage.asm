game_stage_copy:
	ldx #0
 -;	lda game_stage_data,x
	sta stgbuf,x
	inx
	bne -
	rts

game_stage_data:
	//Type, X-Pos (Pixel), Length (Tiles), Y-Pos (16-bit Tile Position)
	//Types: FF = End, 00 = Regular Platform, 01 = Ice Platform, 02 = Moving Platform (Sprite), 80 = Goal Fish
	db $00, $00*8, $20; dw $0004
	db $01, $13*8, $0A; dw $000C
	db $00, $03*8, $09; dw $000D
	db $02, $03*8, $08; dw $0014
	db $FF	//End
game_stage_data_end:
