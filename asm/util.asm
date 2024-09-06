empty_oambuffer:
	//Zero OAM Buffer
	lda #$00
	sta.b oambuf_ptr
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
	//Divide by 30
	//Base From Omegamatrix @ https://forums.nesdev.org/viewtopic.php?p=129849#p129849
	lda.b div_val_hi
	sta.b mod_result
	lda.b div_val_lo

	//use mod_result for high byte temp
	//use div_result for low byte temp
	sta.b div_result		//@3
	lsr.b mod_result; ror		//@5+2
	lsr.b mod_result; ror		//@5+2
	lsr.b mod_result; ror		//@5+2
	lsr.b mod_result; ror		//@5+2
	sec						//@2
	adc.b div_result		//@3
	bcc +					//@2(+1)
	inc.b mod_result			//@5
+;
	lsr.b mod_result; ror		//@5+2
	lsr.b mod_result; ror		//@5+2
	lsr.b mod_result; ror		//@5+2
	lsr.b mod_result; ror		//@5+2
	lsr.b mod_result; ror		//@5+2
	sta.b div_result

	//Subtract low byte with result*30 for reminder
	tax
	lda.b div_val_lo
	and #$7F
	sec; sbc multiply_30_table,x
	sta.b mod_result
	rts

multiply_30_table:
{
	variable i = 0
	while (i < $80) {
		db i*30
		i = i + 1
	}
}
