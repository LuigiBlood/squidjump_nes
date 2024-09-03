game_squid_collision:
	//Only do collision checks when going down
	lda squid_dy_lo
	bpl +
	rts
 +;
	ldx #0
-;
	lda game_platform_table+0,x
	cmp #$FF
	bne _checkplatforms
	rts
_skiptonextplatform:
	txa
	clc
	adc #5
	tax
	jmp -
_checkplatforms:
	lda game_platform_table+3,x
	asl; asl; asl
	sta argument0

	lda squid_y_lo
	cmp argument0
	bcc +
	beq +
	jmp _skiptonextplatform
+;	clc
	adc squid_dy_lo
	cmp argument0
	bcs +
	jmp _skiptonextplatform
+;	lda argument0
	sta squid_y_lo
	lda #0
	sta squid_dy_lo
	sta squid_dy_frac
	rts
