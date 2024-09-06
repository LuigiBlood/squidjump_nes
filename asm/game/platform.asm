game_platform_update:
	//Constantly make Moving Platforms move to the right (for tests)
	//Including the squid if it stands on it
	ldx #0
-;	lda stgbuf+0,x
	cmp #$FF
	bne +
	rts
+;	cmp #$02
	beq _platform2_update
	cmp #$03
	beq _platform3_update
-;	inx;inx;inx;inx;inx
	jmp --
_platform2_update:
	//Moving Platforms to the Right
	inc stgbuf+1,x
	ldy squid_stand
	dey
	tya
	cmp stgbuf+0,x
	bne +
	cpx squid_stand_ptr
	bne +
	inc squid_x_int
+;	lda stgbuf+2,x
	asl;asl;asl
	clc; adc stgbuf+1,x
	cmp #$F0
	bne +
	//if on the right side, then change to Left
	inc stgbuf+0,x
+;	jmp -
	rts
_platform3_update:
	//Moving Platforms to the Left
	dec stgbuf+1,x
	ldy squid_stand
	dey
	tya
	cmp stgbuf+0,x
	bne +
	cpx squid_stand_ptr
	bne +
	dec squid_x_int
+;	lda stgbuf+1,x
	cmp #$10
	bne +
	//if on the left side, then change to Right
	dec stgbuf+0,x
+;	jmp -
	rts
