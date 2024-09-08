game_set_oam:
	jsr empty_oambuffer
	jsr game_set_spr0
	jsr game_squid_oam
	jsr game_platform_oam
	inc need_oam_update
	rts

game_set_spr0:
	ldx.b oambuf_ptr
	lda.b frame_count
	eor #$FF
	sta oambuf+$00,x
	lda #$FE
	sta oambuf+$01,x
	lda #$23
	sta oambuf+$02,x
	lda #$00
	sta oambuf+$03,x
	inx;inx;inx;inx;
	stx.b oambuf_ptr
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
	lda #$B8-1
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
	cmp #$04
	beq +
	cmp #$05
	beq +
_game_platform_oam_next:
	//Next Platform
	inx;inx;inx;inx;inx
	jmp -
+;
_game_platform_oam:
	//Render Moving Platform
	//Length in Tiles (max 8 sprites per platform)
	lda stgbuf+2,x
	cmp #9
	bcc +
	lda #8
+;	sta temp0

	//Calc Y Position (offset by 0xF8)
	//Convert Tile Y to Pixel Y
	//temp1 = Low, temp2 = Mid, temp3 = Hi
	lda #0
	sta temp2
	sta temp3
	lda stgbuf+3,x
	asl; rol temp2; rol temp3
	asl; rol temp2; rol temp3
	asl; rol temp2; rol temp3
	sta temp1
	//Platform Y - Squid Y
	lda temp1
	sec; sbc squid_y_lo
	sta temp1
	lda temp2
	sbc squid_y_hi
	sta temp2
	lda temp3
	sbc #0
	sta temp3
	//Check if platform is close enough to be rendered
	lda temp3
	cmp #-1
	beq +
	cmp #0
	beq ++
	jmp _game_platform_oam_next
	//handle negative -1
+;	lda temp2
	cmp #-1
	bne _game_platform_oam_next
	lda temp1
	cmp #-7*8
	bcc _game_platform_oam_next
	jmp game_platform_oam_render
+;	//handle 00
	lda temp2
	bne _game_platform_oam_next
	lda temp1
	cmp #25*8
	bcs _game_platform_oam_next
game_platform_oam_render:
	lda stgbuf+0,x
	cmp #$02
	beq +
	cmp #$03
	beq +
	cmp #$04
	beq ++
	cmp #$05
	beq ++
+;	jmp game_platform_oam_render_2_3
+;	jmp game_platform_oam_render_4_5
game_platform_oam_render_2_3:
	lda #$C8
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
	jmp _game_platform_oam_next
game_platform_oam_render_4_5:
	cmp #$05
	beq +
	lda frame_count
	and #7
	sec; sbc #8
	jmp ++
+;	lda frame_count
	and #7
	eor #$FF
	clc; adc #1
+;	sta temp2

	and #8
	beq +
	inc temp0
+;
	lda #$C8
	clc; sbc temp1
	sta temp1
	lda stgbuf+1,x	//X Pos
	clc; adc.b temp2
	sta temp2
-;	lda temp2
	//X Position
	sta oambuf+3,y
	//Y Position (Temp)
	lda temp1
	sta oambuf+0,y
	//Sprite
	lda #12
	sta oambuf+1,y
	//Attributes (Palette)
	lda #$22
	sta oambuf+2,y
	//Next
	iny;iny;iny;iny
	lda temp2
	clc; adc #8
	sta temp2
	dec temp0
	bne -
	jmp _game_platform_oam_next

