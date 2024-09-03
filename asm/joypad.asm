read_joy:
	lda.b player1_hold
	sta.b player1_prev

    lda #$01
    sta JOY1
    sta.b player1_hold
    lsr

    sta JOY1
-;  lda JOY1
    lsr
    rol.b player1_hold
    bcc -

	lda.b player1_prev
	eor #$FF
	and.b player1_hold
	sta.b player1_push
    rts
