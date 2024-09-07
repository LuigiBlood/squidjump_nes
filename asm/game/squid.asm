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
	lda.b player1_hold
	bpl +
	ldx.b squid_hold
	cpx #$40
	beq ++
	inx
	stx.b squid_hold
	jmp ++
+;	lda.b squid_hold
	beq +
	clc
	adc #$10
	tax
	asl;asl;asl;asl;asl;
	eor #$ff
	sta.b squid_dy_frac
	txa
	lsr;lsr;lsr;
	eor #$ff
	sta.b squid_dy_lo
	lda #0
	sta.b squid_hold
+;
	//B Button (Press) - Debug Jump
	lda.b player1_push
	and #$40
	beq +
	lda #-6
	sta.b squid_dy_lo
+;
	//LEFT Button (Hold) - Move Left
	lda.b player1_hold
	and #$02
	beq +
	//Don't Move when standing
	lda.b squid_stand
	bne +
	//Cap Speed
	lda.b squid_dx_int
	cmp #-3
	beq +
	sec
	lda.b squid_dx_frac
	sbc #$10
	sta.b squid_dx_frac
	lda.b squid_dx_int
	sbc #0
	sta.b squid_dx_int
	rts
+;
	//RIGHT Button (Hold) - Move Right
	lda.b player1_hold
	and #$01
	beq +
	//Don't Move when standing
	lda.b squid_stand
	bne +
	//Cap Speed
	lda.b squid_dx_int
	cmp #2
	beq +
	clc
	lda.b squid_dx_frac
	adc #$10
	sta.b squid_dx_frac
	lda.b squid_dx_int
	adc #0
	sta.b squid_dx_int
	rts
+;
	rts

squid_anim:
	lda #0
	tax
	tay
	sta.b squid_display
	lda.b squid_hold
	beq _squid_anim_end
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
	sty.b squid_display

	ldy.b squid_hold
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
	bcc _squid_anim_end
	lda.b frame_count
	and #$04
	beq _squid_anim_end
	inx
_squid_anim_end:
	lda squid_anim_color_table,x
	sta squid_color
	rts

squid_anim_color_table:
	db $30, $35, $26, $16, $27

game_squid_gravity:
	//Apply Gravity
	lda.b squid_dy_frac
	clc
	adc #$40
	sta.b squid_dy_frac
	lda.b squid_dy_lo
	adc #0
	sta.b squid_dy_lo

	//Fall Speed Cap
	lda.b squid_dy_lo
	cmp #$01
	bmi +
	bcc +
	lda.b squid_dy_frac
	//cmp #$80
	bpl +
	lda #$01
	sta.b squid_dy_lo
	lda #$80
	sta.b squid_dy_frac

+;	rts

game_squid_h_friction:
	//Horizontal Movement (Friction, Moving Platform)
	lda.b squid_stand
	beq _game_squid_h_friction_end
_game_squid_h_friction_stand0:
	//Platform Type 0 (Just remove all horizontal movement)
	cmp #0+1
	bne _game_squid_h_friction_stand1
-;
	lda #0
	sta.b squid_dx_frac
	sta.b squid_dx_int
	jmp _game_squid_h_friction_end
_game_squid_h_friction_stand1:
	//Platform Type 1 (Ice, add a bit of slowdown)
	cmp #1+1
	bne _game_squid_update_stand2
	lda.b squid_dx_int
	ora.b squid_dx_frac
	beq _game_squid_h_friction_end
	lda.b squid_dx_int
	bmi +
	//Positive
	lda.b squid_dx_frac
	sec
	sbc #$04
	sta.b squid_dx_frac
	lda.b squid_dx_int
	sbc #0
	sta.b squid_dx_int
	jmp _game_squid_h_friction_end
	//Negative
+;	lda.b squid_dx_frac
	clc
	adc #$04
	sta.b squid_dx_frac
	lda.b squid_dx_int
	adc #0
	sta.b squid_dx_int
	jmp _game_squid_h_friction_end
_game_squid_update_stand2:
	jmp -
_game_squid_h_friction_end:
	rts

apply_delta_physics_x:
	//Apply Acceleration to Position
	clc
	lda.b squid_x_frac
	adc.b squid_dx_frac
	sta.b squid_x_frac
	lda.b squid_x_int
	adc.b squid_dx_int
	sta.b squid_x_int
	rts

apply_delta_physics_y:
	//Apply Acceleration to Position
	lda.b squid_dy_lo
	sec
	bmi +
	//Positive
	lda.b squid_y_frac
	sbc.b squid_dy_frac
	sta.b squid_y_frac
	lda.b squid_y_lo
	sbc.b squid_dy_lo
	sta.b squid_y_lo
	lda.b squid_y_hi
	sbc #0
	sta.b squid_y_hi
	rts
+;	//Negative
	lda.b squid_y_frac
	sbc.b squid_dy_frac
	sta.b squid_y_frac
	lda.b squid_y_lo
	sbc.b squid_dy_lo
	sta.b squid_y_lo
	lda.b squid_y_hi
	adc #0
	sta.b squid_y_hi
	rts
