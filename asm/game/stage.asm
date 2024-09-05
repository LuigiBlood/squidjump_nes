game_stage_copy:
	ldx #0
 -;	lda game_stage_data,x
	sta stgbuf,x
	inx
	bne -
	rts

macro make_stage_platform(type, xpos, len, ypos) {
	db {type}, {xpos}*8, {len}
	dw {ypos}
}

game_stage_data:
	//Type, X-Pos (Pixel), Length (Tiles), Y-Pos (16-bit Tile Position)
	//Has to be in Y Position Order!
	//Types:
	//	FF = End
	//	00 = Regular Platform
	//	01 = Ice Platform
	//	02 = Moving Platform (Sprite), Moves Right
	//	03 = Moving Platform (Sprite), Moves Left
	make_stage_platform($00, $00, $20, $0004)
	make_stage_platform($01, $13, $0A, $000A)
	make_stage_platform($00, $03, $09, $000E)
	make_stage_platform($02, $03, $08, $0014)
	make_stage_platform($00, $03, $09, $0020)
	make_stage_platform($00, $13, $09, $0030)
	db $FF	//End
game_stage_data_end:
