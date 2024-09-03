game_squid_physics:
	//test some acceleration
	//- apply gravity
	//- automatically apply force upwards
	lda squid_dy_lo
	cmp #4
	beq +
	lda squid_dy_frac
	clc
	adc #$40
	sta squid_dy_frac
	lda squid_dy_lo
	adc #0
	sta squid_dy_lo

+;
	jsr squid_joypad
	jsr game_squid_collision
	jsr apply_delta_physics_y
	rts

squid_joypad:
	lda player1_push
	bpl +
	lda #-6
	sta squid_dy_lo
+;
	rts

apply_delta_physics_y:
	lda squid_dy_lo
	sec
	bmi +
	//Positive
	lda squid_y_frac
	sbc squid_dy_frac
	sta squid_y_frac
	lda squid_y_lo
	sbc squid_dy_lo
	sta squid_y_lo
	lda squid_y_hi
	sbc #0
	sta squid_y_hi
	rts
+;	//Negative
	lda squid_y_frac
	sbc squid_dy_frac
	sta squid_y_frac
	lda squid_y_lo
	sbc squid_dy_lo
	sta squid_y_lo
	lda squid_y_hi
	adc #0
	sta squid_y_hi
	rts
