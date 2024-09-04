game_set_oam:
	jsr empty_oambuffer
	jsr game_squid_oam
	jsr game_platform_oam
	inc need_oam_update
	rts

game_squid_oam:
	//Sprite Look
	lda squid_display
	asl
	ora #$80
	sta oambuf+$00+1
	sta oambuf+$04+1
	lda #$40
	sta oambuf+$00+2

	//X Position
	lda squid_x_int
	sta oambuf+$00+3
	clc
	adc #7
	sta oambuf+$04+3

	//Y Position (offset by 0xE0, for camera scrolling purposes)
	lda #$E0
	clc
	sbc squid_y_lo
	sta oambuf+$00+0
	sta oambuf+$04+0

	rts

game_platform_oam:
	ldx #0	//X = Stage Buffer
	ldy #8	//Y = OAM Buffer

-;	lda stgbuf+0,x
	cmp #$FF
	bne +
	rts
+;	cmp #$02
	beq +
-;	//Next Platform
	inx;inx;inx;inx;inx
	jmp --
+;
	//Render Moving Platform
	lda stgbuf+2,x	//Length in Tiles
	sta argument0
	lda stgbuf+3,x	//Y Position (offset by 0xF0)
	asl; asl; asl
	sta argument1
	lda #$F0
	clc; sbc argument1
	sta argument1
	lda stgbuf+1,x	//X Pos
	sta argument2
-;	lda argument2
	//X Position
	sta oambuf+3,y
	//Y Position (Temp)
	lda argument1
	sta oambuf+0,y
	//Sprite
	lda #10
	sta oambuf+1,y
	//Attributes (Palette)
	lda #$01
	sta oambuf+2,y
	//Next
	iny;iny;iny;iny
	lda argument2
	clc; adc #8
	sta argument2
	dec argument0
	bne -
	jmp --
	rts
