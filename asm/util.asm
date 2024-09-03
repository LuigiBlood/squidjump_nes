empty_oambuffer:
	lda #$00
	tax
 -;	sta oambuf,x
	inx
	bne -
	rts
