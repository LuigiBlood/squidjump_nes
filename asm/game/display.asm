game_platform_display_direct:
	//Arguments:
	//temp0 & 1 = Stage Y Lower Tile Position (16-bit LE)
	//temp2 & 3 = Stage Y Upper Tile Position (16-bit LE), not included
	//Extras:
	//temp4 & 5 = PPU Address & Other
	//temp6     = Pointer to lowest platform within range
	//temp7     = Pointer to highest platform within range

	ldx #-5
	//Step: Find the highest platform before the upper tile position
-;	inx;inx;inx;inx;inx;
	lda stgbuf+0,x
	cmp #$FF
	bne +
	jmp ++

+;	lda stgbuf+4,x
	cmp temp3		//>= Upper Tile
	bcc -
	lda stgbuf+3,x
	cmp temp2		//>= Upper Tile
	bcc -
+;	dex;dex;dex;dex;dex
	stx temp7

	//Step: Set PPUADDR
+;
	jsr helper_direct_set_PPUADDR

	//Step: Draw from highest to lowest (can have empty lines)

	//Find platform at Y specific position, if not found, then draw empty line
	//-1
	ldx temp7
_game_platform_display_direct_loop:
	lda temp3
	cmp temp1
	bne +
	lda temp2
	cmp temp0
	bne +
	rts
+;
	lda temp2
	sec; sbc #1
	sta temp2
	lda temp3
	sbc #0
	sta temp3

	lda stgbuf+4,x
	cmp temp3		//>= Upper Tile
	bne _game_platform_display_direct_empty
	lda stgbuf+3,x
	cmp temp2		//>= Upper Tile
	bne _game_platform_display_direct_empty
_game_platform_display_direct_platform:
	//Left of platform (if any)
	lda stgbuf+1,x
	lsr;lsr;lsr
	sta temp4
	beq +
	tay
	lda #0
-;	sta PPUDATA
	dey
	bne -
+;	//Platform itself
	lda stgbuf+2,x
	pha
	clc; adc temp4
	sta temp4
	pla
	beq +
	tay
	lda #6
	clc
	adc stgbuf+0,x
	adc stgbuf+0,x
-;	sta PPUDATA
	dey
	bne -
+;	//After platform
	ldy temp4
	lda #0
-;	cpy #$20
	beq +
	sta PPUDATA
	iny
	jmp -
+;
	dex;dex;dex;dex;dex
	jmp _game_platform_display_direct_loop
_game_platform_display_direct_empty:
	ldy #32
	lda #0
-;	sta PPUDATA
	dey
	bne -
	jmp _game_platform_display_direct_loop


helper_direct_set_PPUADDR:
	//Divide the Upper range - 1 by 30 to calculate the address
	lda temp2
	sec
	sbc #1
	sta div_val_lo
	lda temp3
	sbc temp1
	sta div_val_hi

	txa
	pha
	jsr division16bit_by_30
	pla
	tax

	//Set PPUAddr
	lda #0
	sta temp5
	lda mod_result
	asl; rol temp5
	asl; rol temp5
	asl; rol temp5
	asl; rol temp5
	asl; rol temp5
	sta temp4
	lda #$A0
	sec; sbc temp4
	sta temp4
	lda #$23
	sbc temp5
	sta temp5
	
	lda div_result
	lsr
	bcc +
	//Handle other nametable
	lda temp5
	ora #8
	sta	temp5
+;	//Input Address
	lda temp5
	sta PPUADDR
	lda temp4
	sta PPUADDR
	rts

helper_direct_draw_empty_lines:
	lda temp2
	sec; sbc #1
	sta temp2
	lda temp3
	sbc #0
	sta temp3

	ldy #32
	lda #0
-;	sta PPUDATA
	dey
	bne -

	lda temp3
	cmp temp1
	bne helper_direct_draw_empty_lines
	lda temp2
	cmp temp0
	bne helper_direct_draw_empty_lines

	rts

game_scrolling_mgr:
	lda squid_y_lo
	sec; sbc #$20
	sta temp0
	lda squid_y_hi
	sbc #0
	sta temp1

	ldx #$08
-;
	cmp #$78
	bcc +
	sbc #$78		//positive
+;
	rol temp0
	rol
	dex
	bne -

	sta temp1
	lda #$F0
	sec; sbc temp1	
	sta buf_ppuscroll_y


	lda temp0
	and #1
	bne +
	lda buf_ppuctrl
	and #$FC
	ora #2
	sta buf_ppuctrl
	jmp ++
+;	lda buf_ppuctrl
	and #$FC
	sta buf_ppuctrl
+;	inc need_ppu_update
	rts
