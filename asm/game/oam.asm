game_set_oam:
	jsr empty_oambuffer
	jsr game_set_spr0
	jsr game_squid_oam
	jsr game_platform_oam
	inc.b need_oam_update
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
	ldx.b oambuf_ptr
	lda.b squid_display
	asl
	ora #$80
	sta oambuf+$00+1,x
	sta oambuf+$04+1,x
	lda #$40
	sta oambuf+$00+2,x

	//X Position
	lda.b squid_x_int
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
	sta.b oambuf_ptr
	rts

constant temp_oam_length = temp0
constant temp_oam_platform_y_lo = temp1
constant temp_oam_platform_y_md = temp2
constant temp_oam_platform_y_hi = temp3
constant temp_oam_platform_x_shift = temp2

game_platform_oam:
	ldx #0	//X = Stage Buffer
	ldy.b oambuf_ptr	//Y = OAM Buffer

-;	lda stgbuf+0,x
	cmp #$FF
	bne +
	sty.b oambuf_ptr
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
+;	sta.b temp_oam_length

	//Calc Y Position
	//Convert Tile Y to Pixel Y
	//temp1 = Low, temp2 = Mid, temp3 = Hi
	lda #0
	sta.b temp_oam_platform_y_md
	sta.b temp_oam_platform_y_hi
	lda stgbuf+3,x
	asl; rol.b temp_oam_platform_y_md; rol.b temp_oam_platform_y_hi
	asl; rol.b temp_oam_platform_y_md; rol.b temp_oam_platform_y_hi
	asl; rol.b temp_oam_platform_y_md; rol.b temp_oam_platform_y_hi
	sta.b temp_oam_platform_y_lo
	//Platform Y - Squid Y
	lda.b temp_oam_platform_y_lo
	sec; sbc.b squid_y_lo
	sta.b temp_oam_platform_y_lo
	lda.b temp_oam_platform_y_md
	sbc.b squid_y_hi
	sta.b temp_oam_platform_y_md
	lda.b temp_oam_platform_y_hi
	sbc #0
	sta.b temp_oam_platform_y_hi
	//Check if platform is close enough to be rendered
	lda.b temp_oam_platform_y_hi
	cmp #-1
	beq +
	cmp #0
	beq ++
	jmp _game_platform_oam_next
	//handle negative -1
+;	lda.b temp_oam_platform_y_md
	cmp #-1
	bne _game_platform_oam_next
	lda.b temp_oam_platform_y_lo
	cmp #-7*8
	bcc _game_platform_oam_next
	jmp game_platform_oam_render
+;	//handle 00
	lda.b temp_oam_platform_y_md
	bne _game_platform_oam_next
	lda.b temp_oam_platform_y_lo
	cmp #25*8
	bcs _game_platform_oam_next
game_platform_oam_render:
	lda stgbuf+0,x
	lsr
	cmp #$01
	beq +
	cmp #$02
	beq ++
	jmp _game_platform_oam_next
+;	jmp _game_platform_oam_render_2_3
+;	jmp _game_platform_oam_render_4_5
_game_platform_oam_render_2_3:
	lda #$C8
	clc; sbc.b temp_oam_platform_y_lo
	sta.b temp_oam_platform_y_lo
	lda stgbuf+1,x	//X Pos
	sta.b temp_oam_platform_x_shift
-;	lda.b temp_oam_platform_x_shift
	//X Position
	sta oambuf+3,y
	//Y Position (Temp)
	lda.b temp_oam_platform_y_lo
	sta oambuf+0,y
	//Sprite
	lda #10
	sta oambuf+1,y
	//Attributes (Palette)
	lda #$01
	sta oambuf+2,y
	//Next
	iny;iny;iny;iny
	lda.b temp_oam_platform_x_shift
	clc; adc #8
	sta.b temp_oam_platform_x_shift
	dec.b temp_oam_length
	bne -
	jmp _game_platform_oam_next
_game_platform_oam_render_4_5:
	lda stgbuf+0,x
	lsr
	bcs +
	lda.b frame_count
	and #7
	sec; sbc #8
	jmp ++
+;	lda.b frame_count
	and #7
	eor #$FF
	clc; adc #1
+;	sta.b temp_oam_platform_x_shift

	and #8
	beq +
	inc.b temp_oam_length
+;
	lda #$C8
	clc; sbc.b temp_oam_platform_y_lo
	sta.b temp_oam_platform_y_lo
	lda stgbuf+1,x	//X Pos
	clc; adc.b temp_oam_platform_x_shift
	sta.b temp_oam_platform_x_shift
-;	lda.b temp_oam_platform_x_shift
	//X Position
	sta oambuf+3,y
	//Y Position (Temp)
	lda.b temp_oam_platform_y_lo
	sta oambuf+0,y
	//Sprite
	lda #12
	sta oambuf+1,y
	//Attributes (Palette)
	lda #$22
	sta oambuf+2,y
	//Next
	iny;iny;iny;iny
	lda.b temp_oam_platform_x_shift
	clc; adc #8
	sta.b temp_oam_platform_x_shift
	dec.b temp_oam_length
	bne -
	jmp _game_platform_oam_next

