read_joy:
	//Put Current Held Buttons into Last Frame info
	lda.b player1_hold
	sta.b player1_prev

	//Read Currently Held Joypad 1 Button
	lda #$01
	sta JOY1
	sta.b player1_hold
	lsr

	sta JOY1
 -;	lda JOY1
	lsr
	rol.b player1_hold
	bcc -

	//Compare to last frame to have Pressed Button info at the moment
	lda.b player1_prev
	eor #$FF
	and.b player1_hold
	sta.b player1_push
	rts
