game_set_oam:
	//Automatically cycle through Squid Displays
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
	//Set OAM Data for Squid
	jsr game_squid_oam
	inc need_oam_update
	rts

game_squid_oam:
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

	//Sprite Look
	lda squid_display
	asl
	ora #$80
	sta oambuf+$00+1
	sta oambuf+$04+1
	lda #$40
	sta oambuf+$00+2

	rts
