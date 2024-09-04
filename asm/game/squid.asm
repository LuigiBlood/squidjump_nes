game_squid_physics:
	//Apply Gravity
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
	jsr apply_delta_physics_x
	jsr apply_delta_physics_y
	rts

squid_joypad:
	//Detect A Button Press then Jump (Apply Acceleration)
	//A Button (Push)
	lda player1_push
	bpl +
	lda #-6
	sta squid_dy_lo
+;
	//LEFT Button (Hold) - Move Left
	lda player1_hold
	and #$02
	beq +
	//Cap Speed
	lda squid_dx_int
	cmp #-4
	beq +
	sec
	lda squid_dx_frac
	sbc #$10
	sta squid_dx_frac
	lda squid_dx_int
	sbc #0
	sta squid_dx_int
	rts
+;
	//RIGHT Button (Hold) - Move Right
	lda player1_hold
	and #$01
	beq +
	//Cap Speed
	lda squid_dx_int
	cmp #3
	beq +
	clc
	lda squid_dx_frac
	adc #$10
	sta squid_dx_frac
	lda squid_dx_int
	adc #0
	sta squid_dx_int
	rts
+;
	rts

apply_delta_physics_x:
	//Apply Acceleration to Position
	clc
	lda squid_x_frac
	adc squid_dx_frac
	sta squid_x_frac
	lda squid_x_int
	adc squid_dx_int
	sta squid_x_int
	rts

apply_delta_physics_y:
	//Apply Acceleration to Position
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
