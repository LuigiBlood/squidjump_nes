game_squid_physics:
	lda #$04
	sta squid_dy_frac
	jsr apply_delta_physics_y
	rts

apply_delta_physics_y:
	lda squid_y_frac
	clc
	adc squid_dy_frac
	sta squid_y_frac
	lda squid_y_lo
	adc squid_dy_lo
	sta squid_y_lo
	bcc ++
	bmi +
	inc squid_y_hi
	jmp ++
+;	dec squid_y_hi
+;	rts
