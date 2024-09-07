constant temp_y_lower_lo = temp0
constant temp_y_lower_hi = temp1

constant temp_y_upper_lo = temp2
constant temp_y_upper_hi = temp3

constant temp_ppuaddr_lo = temp4
constant temp_ppuaddr_hi = temp5

constant temp_tile_max = temp4

constant temp_write = temp6
constant temp_stg_idx = temp7

game_platform_display_direct:
	//Arguments:
	//temp0 & 1 = Stage Y Lower Tile Position (16-bit LE)
	//temp2 & 3 = Stage Y Upper Tile Position (16-bit LE), not included
-;
	lda temp_y_lower_hi
	pha
	lda temp_y_lower_lo
	pha
	lda temp_y_upper_lo
	sec; sbc #2
	sta temp_y_lower_lo
	lda temp_y_upper_hi
	sbc #0
	sta temp_y_lower_hi
	jsr game_platform_display_queue
	jsr game_platform_attr_display_queue
	jsr _ppu_upload
	pla
	sta temp_y_lower_lo
	pla
	sta temp_y_lower_hi

	lda temp_y_lower_lo
	cmp temp_y_upper_lo
	bne -
	lda temp_y_lower_hi
	cmp temp_y_upper_hi
	bne -

+;	rts


helper_get_PPUADDR:
	//Divide the Upper range - 1 by 30 to calculate the address
	lda temp_y_upper_lo
	sec; sbc #1
	sta div_val_lo
	lda temp_y_upper_hi
	sbc temp_y_lower_hi
	sta div_val_hi

	txa
	pha
	jsr division16bit_by_30
	pla
	tax

	//Set Addr to Attr
	lda mod_result	//$23F8 - (mod / 4)
	clc;adc #2
	asl;
	and #%00111000
	sta temp_attr_lo
	lda #$F8
	sec; sbc temp_attr_lo
	sta temp_attr_lo

	//Set PPUAddr
	lda #0
	sta temp_ppuaddr_hi
	lda mod_result	//$23A0 - (mod * 32)
	asl; rol temp_ppuaddr_hi
	asl; rol temp_ppuaddr_hi
	asl; rol temp_ppuaddr_hi
	asl; rol temp_ppuaddr_hi
	asl; rol temp_ppuaddr_hi
	sta temp_ppuaddr_lo
	lda #$A0
	sec; sbc temp_ppuaddr_lo
	sta temp_ppuaddr_lo
	lda #$23
	sta temp_attr_hi
	sbc temp_ppuaddr_hi
	sta temp_ppuaddr_hi
	
	lda div_result
	lsr
	bcc +
	//Handle other nametable
	lda temp_ppuaddr_hi
	ora #8
	sta	temp_ppuaddr_hi
	lda temp_attr_hi
	ora #8
	sta temp_attr_hi
+;
	rts

game_platform_display_queue:
	//Arguments:
	//temp0 & 1 = Stage Y Lower Tile Position (16-bit LE)
	//temp2 & 3 = Stage Y Upper Tile Position (16-bit LE), not included

	ldx #-5
	//Step: Find the highest platform before the upper tile position
-;	inx;inx;inx;inx;inx;
	lda stgbuf+0,x
	cmp #$FF
	bne +
	jmp ++

+;	lda stgbuf+4,x
	cmp temp_y_upper_hi		//>= Upper Tile
	bcc -
	lda stgbuf+3,x
	cmp temp_y_upper_lo		//>= Upper Tile
	bcc -
+;	dex;dex;dex;dex;dex
	stx temp_stg_idx

	//Step: Set PPUADDR
+;
	jsr helper_get_PPUADDR
	//Set Address to Buffer
	ldy ppubuf_ptr
	lda temp_ppuaddr_hi
	sta ppubuf,y; iny
	lda temp_ppuaddr_lo
	sta ppubuf,y; iny

	//Set Size to Buffer
	lda temp_y_upper_lo
	sec; sbc temp_y_lower_lo
	asl;asl;asl;asl;asl
	sta ppubuf,y; iny
	sty ppubuf_ptr

	//Step: Draw from highest to lowest (can have empty lines)

	//Find platform at Y specific position, if not found, then draw empty line
	//-1
	ldx temp_stg_idx
_game_platform_display_queue_loop:
	lda temp_y_upper_hi
	cmp temp_y_lower_hi
	bne +
	lda temp_y_upper_lo
	cmp temp_y_lower_lo
	bne +
	rts
+;
	lda temp_y_upper_lo
	sec; sbc #1
	sta temp_y_upper_lo
	lda temp_y_upper_hi
	sbc #0
	sta temp_y_upper_hi

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
	cmp temp_y_upper_hi		//>= Upper Tile
	bne _game_platform_display_queue_empty
	lda stgbuf+3,x
	cmp temp_y_upper_lo		//>= Upper Tile
	bne _game_platform_display_queue_empty
	jmp _game_platform_display_queue_platform
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
_game_platform_display_queue_platform:
	lda stgbuf+0,x
	sta last_display_p
	//Left of platform (if any)
	lda stgbuf+1,x
	lsr;lsr;lsr
	sta temp_tile_max
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
	clc; adc temp_tile_max
	sta temp_tile_max
	beq +
	lda #6
	clc
	adc stgbuf+0,x
	adc stgbuf+0,x
	sta temp_write
	txa
	pha
	ldx ppubuf_ptr
	lda temp_write
-;	sta ppubuf,x
	inx
	dey
	bne -
	stx ppubuf_ptr
	pla
	tax
+;	//After platform
	ldy temp_tile_max
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

game_platform_attr_display_queue:
	lda last_display_p
	cmp #$FF
	bne +
	lda #0
+;	asl;asl;asl
	tay

	ldx ppubuf_ptr
	lda temp_attr_hi
	sta ppubuf,x; inx
	lda temp_attr_lo
	sta ppubuf,x; inx
	lda #8
	sta ppubuf,x; inx

	lda platform_attr_table+0,y
	sta ppubuf,x; inx
	lda platform_attr_table+1,y
	sta ppubuf,x; inx
	lda platform_attr_table+2,y
	sta ppubuf,x; inx
	lda platform_attr_table+3,y
	sta ppubuf,x; inx
	lda platform_attr_table+4,y
	sta ppubuf,x; inx
	lda platform_attr_table+5,y
	sta ppubuf,x; inx
	lda platform_attr_table+6,y
	sta ppubuf,x; inx
	lda platform_attr_table+7,y
	sta ppubuf,x; inx

	stx ppubuf_ptr
	rts

platform_attr_table:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $44,$55,$55,$55,$55,$55,$55,$55

game_scrolling_mgr:
	//Offset and Reverse Squid Y Position
	lda squid_y_lo
	sec; sbc #$20
	sta temp_y_lower_lo
	lda squid_y_hi
	sbc #0
	sta temp_y_lower_hi

	//Divide by 30 and get Quotient (A, temp1) (for PPUCTRL) and Reminder (temp0) (for PPUSCROLL Y)
	//from tokumaru @ https://forums.nesdev.org/viewtopic.php?p=23266#p23266
	ldx #$08
-;
	cmp #$78
	bcc +
	sbc #$78		//positive
+;
	rol temp_y_lower_lo
	rol
	dex
	bne -

	sta temp_y_lower_hi
	lda #$F0
	sec; sbc temp_y_lower_hi
	cmp #$F0
	bne +
	//weird hacky workaround but it works
	lda temp_y_lower_lo
	eor #1
	sta temp_y_lower_lo
	lda #0
+;	sta buf_ppuscroll_y
	
	lda temp_y_lower_lo
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
	sta temp_y_lower_hi
	lda squid_y_lo
	lsr temp_y_lower_hi; ror
	lsr temp_y_lower_hi; ror
	lsr temp_y_lower_hi; ror
	lsr temp_y_lower_hi; ror
	asl; rol temp_y_lower_hi
	sta temp_y_lower_lo

	lda squid_dy_lo
	beq _game_scrolling_mgr_end
	bpl +
	//Positive
	lda temp_y_lower_lo
	clc; adc #32
	sta temp_y_lower_lo
	lda temp_y_lower_hi
	adc #0
	sta temp_y_lower_hi

	lda temp_y_lower_lo
	clc; adc #2
	sta temp_y_upper_lo
	lda temp_y_lower_hi
	adc #0
	sta temp_y_upper_hi
	jmp ++
+;	//Negative

	lda temp_y_lower_lo
	sec; sbc #4
	sta temp_y_upper_lo	
	lda temp_y_lower_hi
	sbc #0
	sta temp_y_upper_hi

	lda temp_y_upper_lo
	sec; sbc #2
	sta temp_y_lower_lo	
	lda temp_y_upper_hi
	sbc #0
	sta temp_y_lower_hi
+;	jsr game_platform_display_queue
	jsr game_platform_attr_display_queue
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
