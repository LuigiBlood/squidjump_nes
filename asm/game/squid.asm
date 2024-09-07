game_squid_update:
	jsr squid_joypad
	jsr squid_anim
	
	jsr game_squid_gravity
	jsr game_squid_h_friction
	jsr game_squid_collision
	jsr apply_delta_physics_x
	jsr apply_delta_physics_y
	rts

squid_joypad:
	//A Button (Hold) - Charge Jump
	lda player1_hold
	bpl +
	ldx squid_hold
	cpx #$40
	beq ++
	inx
	stx squid_hold
	jmp ++
+;	lda squid_hold
	beq +
	clc
	adc #$10
	tax
	asl;asl;asl;asl;asl;
	eor #$ff
	sta squid_dy_frac
	txa
	lsr;lsr;lsr;
	eor #$ff
	sta squid_dy_lo
	lda #0
	sta squid_hold
+;
	//B Button (Press) - Debug Jump
	lda player1_push
	and #$40
	beq +
	lda #-6
	sta squid_dy_lo
+;
	//LEFT Button (Hold) - Move Left
	lda player1_hold
	and #$02
	beq +
	//Don't Move when standing
	lda squid_stand
	bne +
	//Cap Speed
	lda squid_dx_int
	cmp #-3
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
	//Don't Move when standing
	lda squid_stand
	bne +
	//Cap Speed
	lda squid_dx_int
	cmp #2
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

squid_anim:
	lda #0
	tax
	tay
	sta squid_display
	lda squid_hold
	beq squid_anim_end
	cmp #$01
	bcc +
	iny
+;	cmp #$0A
	bcc +
	iny
+;	cmp #$14
	bcc +
	iny
+;	cmp #$1E
	bcc +
	iny
+;
	sty squid_display

	ldy squid_hold
	cpy #$2A
	bcc +
	inx
+;	cpy #$30
	bcc +
	inx
+;	cpy #$38
	bcc +
	inx
+;	cpy #$40
	bcc squid_anim_end
	lda frame_count
	and #$04
	beq squid_anim_end
	inx
squid_anim_end:
	lda squid_anim_color,x
	sta squid_color
	rts

squid_anim_color:
	db $30, $35, $26, $16, $27

game_squid_gravity:
	//Apply Gravity
	lda squid_dy_frac
	clc
	adc #$40
	sta squid_dy_frac
	lda squid_dy_lo
	adc #0
	sta squid_dy_lo

	//Fall Speed Cap
	lda squid_dy_lo
	cmp #$01
	bmi +
	bcc +
	lda squid_dy_frac
	//cmp #$80
	bpl +
	lda #$01
	sta squid_dy_lo
	lda #$80
	sta squid_dy_frac

+;	rts

game_squid_h_friction:
	//Horizontal Movement (Friction, Moving Platform)
	lda squid_stand
	beq _game_squid_h_friction_end
_game_squid_h_friction_stand0:
	//Platform Type 0 (Just remove all horizontal movement)
	cmp #0+1
	bne _game_squid_h_friction_stand1
-;
	lda #0
	sta squid_dx_frac
	sta squid_dx_int
	jmp _game_squid_h_friction_end
_game_squid_h_friction_stand1:
	//Platform Type 1 (Ice, add a bit of slowdown)
	cmp #1+1
	bne _game_squid_update_stand2
	lda squid_dx_int
	ora squid_dx_frac
	beq _game_squid_h_friction_end
	lda squid_dx_int
	bmi +
	//Positive
	lda squid_dx_frac
	sec
	sbc #$04
	sta squid_dx_frac
	lda squid_dx_int
	sbc #0
	sta squid_dx_int
	jmp _game_squid_h_friction_end
	//Negative
+;	lda squid_dx_frac
	clc
	adc #$04
	sta squid_dx_frac
	lda squid_dx_int
	adc #0
	sta squid_dx_int
	jmp _game_squid_h_friction_end
_game_squid_update_stand2:
	jmp -
_game_squid_h_friction_end:
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
