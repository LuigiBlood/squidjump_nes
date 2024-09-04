game_display_platform_start:
	//assumes you can just upload to PPU

	//Check Platform Type (if FF then end)
	ldx #0
-;	lda game_platform_table+0,x
	cmp #$FF
	bne +
	rts

+;
	//temp = Platform Y Tile Position * 32
	lda game_platform_table+4,x
	bne +
	lda game_platform_table+3,x
	tay
	asl;asl;asl;asl;asl
	clc
	adc game_platform_table+1,x
	sta argument0
	tya
	lsr;lsr;lsr
	sta argument1
	//PPUADDR = $23C0 - temp
	lda #$C0
	clc
	adc argument0
	tay
	lda #$23
	sec
	sbc argument1
	sta PPUADDR
	sty PPUADDR

	//Get Platform Length
	lda game_platform_table+2,x
	sta argument2
	//Make Platform
	ldy #$00
	lda #6
 -;	sta PPUDATA
	iny
	cpy argument2
	bne -
	//Go To Next Platform
+;	txa
	clc
	adc #5
	tax
	jmp --

game_platform_table:
	//Type, X-Pos, Length, Y-Pos (16-bit)
	db $00, $00, $20; dw $0004
	db $00, $03, $05; dw $0014
	db $FF	//End
