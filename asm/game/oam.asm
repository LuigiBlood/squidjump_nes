game_set_oam:
	lda frame_count
	and #$1F
	cmp #0
	bne ++
	ldx squid_display
	inx
	cpx #5
	bcc +
	ldx #0
+;	stx squid_display
+;
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

	lda #$E0
	clc
	sbc squid_y_lo
	sta oambuf+$00+0
	sta oambuf+$04+0

	//Sprite look
	lda squid_display
	asl
	ora #$80
	sta oambuf+$00+1
	sta oambuf+$04+1
	lda #$40
	sta oambuf+$00+2

	rts
