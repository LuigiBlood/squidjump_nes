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
	jsr helper_get_PPUADDR
	lda temp5
	sta PPUADDR
	lda temp4
	sta PPUADDR

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

	//Don't display certain platforms
	lda stgbuf+0,x
	cmp #$02
	beq +
	cmp #$03
	beq +
	jmp ++

+;	dex;dex;dex;dex;dex
	jmp _game_platform_display_direct_empty
+;
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
	lda #$FF
	sta PPUDATA
	dey
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
	lda #$FF
	sta PPUDATA
	dey
	lda #0
-;	sta PPUDATA
	dey
	bne -
	jmp _game_platform_display_direct_loop


helper_get_PPUADDR:
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
+;
	rts

game_platform_display_queue:
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
	jsr helper_get_PPUADDR
	//Set Address to Buffer
	ldy ppubuf_ptr
	lda temp5
	sta ppubuf,y; iny
	lda temp4
	sta ppubuf,y; iny

	//Set Size to Buffer
	lda temp2
	sec; sbc temp0
	asl;asl;asl;asl;asl
	sta ppubuf,y; iny
	sty ppubuf_ptr

	//Step: Draw from highest to lowest (can have empty lines)

	//Find platform at Y specific position, if not found, then draw empty line
	//-1
	ldx temp7
_game_platform_display_queue_loop:
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

	//Don't display certain platforms
	lda stgbuf+0,x
	cmp #$02
	beq +
	cmp #$03
	beq +
	jmp ++
+;	dex;dex;dex;dex;dex
	jmp _game_platform_display_queue_empty
+;

	lda stgbuf+4,x
	cmp temp3		//>= Upper Tile
	bne _game_platform_display_queue_empty
	lda stgbuf+3,x
	cmp temp2		//>= Upper Tile
	bne _game_platform_display_queue_empty
_game_platform_display_queue_platform:
	//Left of platform (if any)
	lda stgbuf+1,x
	lsr;lsr;lsr
	sta temp4
	beq +
	tay
	txa
	pha
	ldx ppubuf_ptr
	lda #$FF
	sta ppubuf,x
	inx
	dey
	lda #0
-;	sta ppubuf,x
	inx
	dey
	bne -
	stx ppubuf_ptr
	pla
	tax
+;	//Platform itself
	lda stgbuf+2,x
	tay
	clc; adc temp4
	sta temp4
	beq +
	lda #6
	clc
	adc stgbuf+0,x
	adc stgbuf+0,x
	sta temp6
	txa
	pha
	ldx ppubuf_ptr
	lda temp6
-;	sta ppubuf,x
	inx
	dey
	bne -
	stx ppubuf_ptr
	pla
	tax
+;	//After platform
	ldy temp4
	txa
	pha
	ldx ppubuf_ptr
	lda #0
-;	cpy #$20
	beq +
	sta ppubuf,x
	inx
	iny
	jmp -
+;
	stx ppubuf_ptr
	pla
	tax
	dex;dex;dex;dex;dex
	jmp _game_platform_display_queue_loop
_game_platform_display_queue_empty:
	ldy #32
	txa
	pha
	ldx ppubuf_ptr
	lda #$FF
	sta ppubuf,x
	inx
	dey
	lda #0
-;	sta ppubuf,x
	inx
	dey
	bne -
	stx ppubuf_ptr
	pla
	tax
	jmp _game_platform_display_queue_loop

game_scrolling_mgr:
	//Offset and Reverse Squid Y Position
	lda squid_y_lo
	sec; sbc #$20
	sta temp0
	lda squid_y_hi
	sbc #0
	sta temp1

	//Divide by 30 and get Quotient (A, temp1) (for PPUCTRL) and Reminder (temp0) (for PPUSCROLL Y)
	//from tokumaru @ https://forums.nesdev.org/viewtopic.php?p=23266#p23266
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
	cmp #$F0
	bne +
	//weird hacky workaround but it works
	lda temp0
	eor #1
	sta temp0
	lda #0
+;	sta buf_ppuscroll_y
	
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

	//Update Nametable
	lda squid_y_hi
	sta temp1
	lda squid_y_lo
	lsr temp1; ror
	lsr temp1; ror
	lsr temp1; ror
	lsr temp1; ror
	asl; rol temp1
	sta temp0

	lda squid_dy_lo
	beq _game_scrolling_mgr_end
	bpl +
	//Positive
	lda temp0
	clc; adc #32
	sta temp0
	lda temp1
	adc #0
	sta temp1

	lda temp0
	clc; adc #2
	sta temp2
	lda temp1
	adc #0
	sta temp3
	jmp ++
+;	//Negative

	lda temp0
	sec; sbc #4
	sta temp2	
	lda temp1
	sbc #0
	sta temp3

	lda temp2
	sec; sbc #2
	sta temp0	
	lda temp3
	sbc #0
	sta temp1
+;	jsr game_platform_display_queue
	inc need_ppu_upload
_game_scrolling_mgr_end:
	rts

game_spr0_effect:
	lda.b first_game_frame
	beq +
	lda oambuf
	cmp #8
	bcc +
	cmp #$EC-1
	bcs +
	ldy buf_ppumask
	lda #%10111111
-;	bit PPUSTATUS
	bvc -
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	nop
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
	sty $3E01
	sta $3F01
+;	rts
