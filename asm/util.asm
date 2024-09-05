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
