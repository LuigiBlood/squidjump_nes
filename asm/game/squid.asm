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
	jmp ++
+;	lda #$00
	sta squid_dy_frac
	lda #$F8
	sta squid_dy_lo
+;	jsr apply_delta_physics_y
	rts

apply_delta_physics_y:
	lda squid_dy_lo
	bmi +
	//Positive
	lda squid_y_frac
	clc
	adc squid_dy_frac
	sta squid_y_frac
	lda squid_y_lo
	adc squid_dy_lo
	sta squid_y_lo
	lda squid_y_hi
	adc #0
	sta squid_y_hi
	rts
+;	//Negative
	lda squid_y_frac
	clc
	adc squid_dy_frac
	sta squid_y_frac
	lda squid_y_lo
	adc squid_dy_lo
	sta squid_y_lo
	lda squid_y_hi
	sbc #0
	sta squid_y_hi
	rts
