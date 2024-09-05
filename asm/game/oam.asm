game_set_oam:
	jsr empty_oambuffer
	jsr game_squid_oam
	jsr game_platform_oam
	inc need_oam_update
	rts

game_squid_oam:
	//Sprite Look
	ldx oambuf_ptr
	lda squid_display
	asl
	ora #$80
	sta oambuf+$00+1,x
	sta oambuf+$04+1,x
	lda #$40
	sta oambuf+$00+2,x

	//X Position
	lda squid_x_int
	sta oambuf+$00+3,x
	clc
	adc #7
	sta oambuf+$04+3,x

	//Y Position (offset by 0xD8, for camera scrolling purposes)
	lda #$D8
	clc
	sbc squid_y_lo
	sta oambuf+$00+0,x
	sta oambuf+$04+0,x

	txa
	clc; adc #8
	sta oambuf_ptr
	rts

game_platform_oam:
	ldx #0	//X = Stage Buffer
	ldy oambuf_ptr	//Y = OAM Buffer

-;	lda stgbuf+0,x
	cmp #$FF
	bne +
	sty oambuf_ptr
	rts
+;
	cmp #$02
	beq +
	cmp #$03
	beq +
-;	//Next Platform
	inx;inx;inx;inx;inx
	jmp --
+;
	//Render Moving Platform
	lda stgbuf+2,x	//Length in Tiles
	sta temp0
	lda stgbuf+3,x	//Y Position (offset by 0xF0)
	asl; asl; asl
	sta temp1
	lda #$E8
	clc; sbc temp1
	sta temp1
	lda stgbuf+1,x	//X Pos
	sta temp2
-;	lda temp2
	//X Position
	sta oambuf+3,y
	//Y Position (Temp)
	lda temp1
	sta oambuf+0,y
	//Sprite
	lda #10
	sta oambuf+1,y
	//Attributes (Palette)
	lda #$01
	sta oambuf+2,y
	//Next
	iny;iny;iny;iny
	lda temp2
	clc; adc #8
	sta temp2
	dec temp0
	bne -
	jmp --
	rts
