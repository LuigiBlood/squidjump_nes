empty_oambuffer:
	//Zero OAM Buffer
	lda #$00
	sta oambuf_ptr
	tax
 -;	sta oambuf,x
	inx
	bne -
	rts

fill_ppudata100:
	//Fill PPUDATA with A (provided value)
	ldx #$00
 -;	sta PPUDATA
	inx
	cpx #0
	bne -
	rts

division16bit_by_30:
	//Divide 16-bit value by 30, for scrolling purposes
	//Use div_val_hi and div_val_lo
	//Handle High byte
	lda div_val_hi
	beq _div_high_zero	//if zero, don't do anything
_div_high:
	//if not zero, then take advance
	//HH<<3 + (HH>>1 + ~HH.b0)
	tax
	//assert
	cpx #division_table1_end-division_table1
	bcc +
	brk #0
+;
	//temp = (HH>> + ~HH.b0)
	eor #1
	lsr
	adc #0
	sta div_temp
	//A = HH<<3 + temp
	txa
	asl;asl;asl
	clc; adc div_temp

	//couldn't figure this one out without having it massive cycle counts
	clc; adc division_table2,x
	sta div_result

	//check if low byte is high enough (if so, proceed as usual)
	lda div_val_lo
	sec; sbc division_table1,x
	bmi +			//if  < 0 then decrease result by one and end
	beq ++			//if == 0 then end
	jmp _div_low	//if  > 0 then calc low byte
+;	dec div_result
	sta mod_result
	lda #30
	sec; sbc mod_result
+;	sta mod_result
	rts
_div_high_zero:
	sta div_result
	lda div_val_lo
_div_low:
	//Divide Low byte by 30
	//((LL>>4 + (LL+1)) >>> 1) >> 4
	//Thx Omegamatrix from NESDev forums
	tay
	sta	div_temp
	lsr;lsr;lsr;lsr
	sec
	adc div_temp
	ror
	lsr;lsr;lsr;lsr
	tax
	clc; adc div_result
	sta div_result

	//Multiply by 30
	txa
	asl
	sta mod_result
	txa
	asl;asl;asl;asl;asl
	sec; sbc mod_result
	sta mod_result
	//Modulo by 30
	tya
	sec; sbc mod_result
	sta mod_result
	rts

division_table1:
	db $00
	db $0E,$1C,$0C,$1A,$0A,$18,$08,$16,$06,$14,$04,$12,$02,$10,$00
	db $0E,$1C,$0C,$1A,$0A,$18,$08,$16,$06,$14,$04,$12,$02,$10,$00
	db $0E,$1C,$0C,$1A,$0A,$18,$08,$16,$06,$14,$04,$12,$02,$10,$00
	db $0E,$1C,$0C,$1A,$0A,$18,$08,$16,$06,$14,$04,$12,$02,$10,$00
division_table1_end:

division_table2:
	db 0
	db 0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
	db 1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	db 0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
	db 1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
division_table2_end:

