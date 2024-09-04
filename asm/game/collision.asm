game_squid_collision:
	//Only do collision checks when going down
	lda squid_dy_lo
	bpl +
	rts
 +;
	ldx #0
-;
	//Check Platform Type (if FF then end)
	lda game_platform_table+0,x
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
	lda game_platform_table+3,x
	asl; asl; asl
	sta argument0
	lda game_platform_table+3,x
	lsr; lsr; lsr; lsr; lsr
	sta argument1
	lda game_platform_table+4,x
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
	//If both are true, then stop any downwards acceleration
+;	lda argument0
	sta squid_y_lo
	lda argument1
	sta squid_y_hi
	lda #0
	sta squid_dy_lo
	sta squid_dy_frac
	rts
