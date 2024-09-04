game_squid_collision:
	//Only do collision checks when going down
	lda #0
	sta squid_stand
	lda squid_dy_lo
	bpl +
	rts
 +;
	ldx #0
-;
	//Check Platform Type (if FF then end)
	lda stgbuf+0,x
	cmp #$FF
	bne _checkplatforms
	rts
_skiptonextplatform:
	//Go to next platform data
	txa
	clc
	adc #5
	tax
	jmp -
_checkplatforms:
	//Get Platform Y Tile Position and convert to pixel based
	lda stgbuf+3,x
	asl; asl; asl
	sta argument0
	lda stgbuf+3,x
	lsr; lsr; lsr; lsr; lsr
	sta argument1
	lda stgbuf+4,x
	asl; asl; asl
	ora argument1
	sta argument1
	//Compare Y <= Platform Y Pixel Position
	lda squid_y_lo
	cmp argument0
	bcc +
	beq +
	jmp _skiptonextplatform
+;	lda squid_y_hi
	cmp argument1
	bcc +
	beq +
	jmp _skiptonextplatform
+;
	//Compare Y + DY >= Platform Y Pixel Position
	lda squid_y_lo
	clc
	adc squid_dy_lo
	cmp argument0
	bcs +
	jmp _skiptonextplatform
+;	lda squid_y_hi
	adc #0
	cmp argument1
	bcs +
	jmp _skiptonextplatform
+;
	//Prepare Platform Pixel Positions
	lda stgbuf+1,x	//Left X
	lsr; lsr; lsr
	//sta argument2
	clc
	adc stgbuf+2,x	//Right X
	asl; asl; asl
	bcc +
	lda #$ff	//If it's more than 255, cap it
+;	sta argument3
	//Compare X (Leftmost Hitbox) <= Platform X Rightmost Pixel Position
	lda squid_x_int
	cmp argument3
	bcc +
	beq +
	jmp _skiptonextplatform
+;
	//Compare X (Rightmost Hitbox) > Platform X Leftmost Pixel Position
	lda squid_x_int
	clc
	adc #15
	cmp stgbuf+1,x
	bcs +
	jmp _skiptonextplatform
+;
	//If both are true, then stop any downwards acceleration
	lda argument0
	sta squid_y_lo
	lda argument1
	sta squid_y_hi
	lda #0
	sta squid_dy_lo
	sta squid_dy_frac
	lda stgbuf+0,x
	clc
	adc #1
	sta squid_stand
	stx squid_stand_ptr
	rts
