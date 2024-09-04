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
	bne +
	rts
+;
	//Avoid all platforms above Y Tile position 32
	lda stgbuf+4,x
	bne +
	lda stgbuf+3,x
	cmp #$20
	bcs +
	//temp = Platform Y Tile Position * 32 - Platform X Position
	tay
	lda stgbuf+1,x
	lsr;lsr;lsr
	sta argument0
	tya
	asl;asl;asl;asl;asl
	clc; adc argument0
	eor #$1F
	clc; adc #1
	sta argument0
	tya
	lsr;lsr;lsr
	sta argument1
	//PPUADDR = $23E0 - temp
	lda #$E0
	sec; sbc argument0
	tay
	lda #$23
	sbc argument1
	sta PPUADDR
	sty PPUADDR

	//Get Platform Length
	lda stgbuf+2,x
	sta argument2
	//Make Platform
	ldy #$00
	lda #6
	clc
	adc stgbuf+0,x
	adc stgbuf+0,x
 -;	sta PPUDATA
	iny
	cpy argument2
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

	//Go To Next Platform
+;	txa
	clc
	adc #5
	tax
	jmp _game_platform_display_start_loop

table_attr:
	db $00,$55,$AA,$FF
