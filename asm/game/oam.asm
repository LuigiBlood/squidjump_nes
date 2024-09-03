game_set_oam:
	jsr game_squid_oam
	inc need_oam_update
	rts

game_squid_oam:
	//Position
	lda squid_x_int
	sta oambuf+$00+3
	clc
	adc #7
	sta oambuf+$04+3

	lda squid_y_lo
	sta oambuf+$00+0
	sta oambuf+$04+0

	//Sprite look
	lda #$80
	sta oambuf+$00+1
	sta oambuf+$04+1
	lsr
	sta oambuf+$00+2

	rts
