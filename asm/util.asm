empty_oambuffer:
	lda #$00
	tax
 -;	sta oambuf,x
	inx
	bne -
	rts

fill_ppudata100:
	ldx #$00
 -;	sta PPUDATA
	inx
	cpx #0
	bne -
	rts
