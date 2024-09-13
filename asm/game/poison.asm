game_poison_update:
	lda.b poison_y_lo
	clc; adc #1
	sta.b poison_y_lo
	lda.b poison_y_hi
	adc #0
	sta.b poison_y_hi
	rts
