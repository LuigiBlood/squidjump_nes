game_platform_display_start:
	//assumes you can just upload to PPU

	//Check Platform Type (if FF then end)
	ldx #0
_game_platform_display_start_loop:
	lda stgbuf+0,x
	cmp #$FF
	bne +
	rts

+;
	cmp #$02
	beq _game_platform_display_start_next
	cmp #$03
	beq _game_platform_display_start_next
	jmp ++
_game_platform_display_start_next:
	//Go To Next Platform
+;	txa
	clc
	adc #5
	tax
	jmp _game_platform_display_start_loop
	rts
+;
	//Avoid all platforms above Y Tile position 32
	lda stgbuf+4,x
	bne _game_platform_display_start_next
	lda stgbuf+3,x
	cmp #$20
	bcs _game_platform_display_start_next
	//temp = Platform Y Tile Position * 32 - Platform X Position
	tay
	lda stgbuf+1,x
	lsr;lsr;lsr
	sta temp0
	tya
	asl;asl;asl;asl;asl
	clc; adc temp0
	eor #$1F
	clc; adc #1
	sta temp0
	tya
	lsr;lsr;lsr
	sta temp1
	//PPUADDR = $23E0 - temp
	lda #$E0
	sec; sbc temp0
	tay
	lda #$23
	sbc temp1
	sta PPUADDR
	sty PPUADDR

	//Get Platform Length
	lda stgbuf+2,x
	sta temp2
	//Make Platform
	ldy #$00
	lda #6
	clc
	adc stgbuf+0,x
	adc stgbuf+0,x
 -;	sta PPUDATA
	iny
	cpy temp2
	bne -

	//Change Attributes
	lda stgbuf+3,x
	and #$FC
	asl
	eor #$F8
	ldy #$23
	sty PPUADDR
	sta PPUADDR
	lda stgbuf+0,x
	tay
	lda table_attr,y
	ldy #0
-;	sta PPUDATA
	iny
	cpy #8
	bne -
	jmp _game_platform_display_start_next

table_attr:
	db $00,$55,$AA,$FF

game_platform_update:
	//Constantly make Moving Platforms move to the right (for tests)
	//Including the squid if it stands on it
	ldx #0
-;	lda stgbuf+0,x
	cmp #$FF
	bne +
	rts
+;	cmp #$02
	beq _platform2_update
	cmp #$03
	beq _platform3_update
-;	inx;inx;inx;inx;inx
	jmp --
_platform2_update:
	inc stgbuf+1,x
	ldy squid_stand
	dey
	tya
	cmp stgbuf+0,x
	bne +
	cpx squid_stand_ptr
	bne +
	inc squid_x_int
+;	lda stgbuf+2,x
	asl;asl;asl
	clc; adc stgbuf+1,x
	cmp #$F0
	bne +
	inc stgbuf+0,x
+;	jmp -
	rts
_platform3_update:
	dec stgbuf+1,x
	ldy squid_stand
	dey
	tya
	cmp stgbuf+0,x
	bne +
	cpx squid_stand_ptr
	bne +
	dec squid_x_int
+;	lda stgbuf+1,x
	cmp #$10
	bne +
	dec stgbuf+0,x
+;	jmp -
	rts
