constant temp_platform_y_pixel_lo = temp0
constant temp_platform_y_pixel_hi = temp1

constant temp_platform_dy_pixel_lo = temp2
constant temp_platform_dy_pixel_hi = temp3

game_squid_collision:
	//Only do collision checks when going down
	lda #0
	sta.b squid_stand
	lda.b squid_dy_lo
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
	//Get Platform Y Tile Position and convert to Platform Y Pixel Position for temp0 and Platform Y Pixel Position + DY for temp2
	lda #0
	sta.b temp_platform_y_pixel_hi
	lda stgbuf+3,x
	asl; rol.b temp_platform_y_pixel_hi
	asl; rol.b temp_platform_y_pixel_hi
	asl; rol.b temp_platform_y_pixel_hi
	sta.b temp_platform_y_pixel_lo
	clc; adc.b squid_dy_lo
	php
	sta.b temp_platform_dy_pixel_lo
	lda stgbuf+4,x
	asl; asl; asl
	ora.b temp_platform_y_pixel_hi
	sta.b temp_platform_y_pixel_hi
	plp
	adc #0
	sta.b temp_platform_dy_pixel_hi
	//Compare Y <= Platform Y Pixel Position + DY
	lda.b squid_y_lo
	cmp.b temp_platform_dy_pixel_lo
	bcc +
	beq +
	jmp _skiptonextplatform
+;	lda.b squid_y_hi
	cmp.b temp_platform_dy_pixel_hi
	bcc +
	beq +
	jmp _skiptonextplatform
+;
	//Compare Y + DY >= Platform Y Pixel Position
	lda.b squid_y_frac
	clc;adc.b squid_dy_frac
	lda.b squid_y_lo
	adc.b squid_dy_lo
	php
	cmp.b temp_platform_y_pixel_lo
	bcs +
	plp
	jmp _skiptonextplatform
+;	lda.b squid_y_hi
	plp
	adc #0
	cmp.b temp_platform_y_pixel_hi
	bcs +
	jmp _skiptonextplatform
+;
	//Prepare Platform Pixel Positions
	lda stgbuf+1,x	//Left X
	lsr; lsr; lsr
	clc
	adc stgbuf+2,x	//Right X
	asl; asl; asl
	bcc +
	lda #$ff	//If it's more than 255, cap it
+;	sta temp_platform_dy_pixel_hi
	//Compare X (Leftmost Hitbox) <= Platform X Rightmost Pixel Position
	lda.b squid_x_int
	cmp.b temp_platform_dy_pixel_hi
	bcc +
	beq +
	jmp _skiptonextplatform
+;
	//Compare X (Rightmost Hitbox) > Platform X Leftmost Pixel Position
	lda.b squid_x_int
	clc
	adc #15
	cmp stgbuf+1,x
	bcs +
	jmp _skiptonextplatform
+;
	//If both are true, then stop any downwards acceleration
	lda.b temp_platform_y_pixel_lo
	sta.b squid_y_lo
	lda.b temp_platform_y_pixel_hi
	sta.b squid_y_hi
	lda #0
	sta.b squid_y_frac
	sta.b squid_dy_lo
	sta.b squid_dy_frac
	lda stgbuf+0,x
	clc
	adc #1
	sta.b squid_stand
	stx.b squid_stand_ptr
	rts
