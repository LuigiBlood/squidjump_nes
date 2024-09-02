nmi:
	rts

irq:
	rts

reset:
	sei			//Ignore IRQs
	cld			//Disable Decimal Mode
	ldx #$40
	stx $4017	//Disable APU Frame IRQ
	ldx #$ff
	txs			//Set up stack
	inx			//X = 0
	stx $2000	//Disable NMI
	stx $2001	//Disable Rendering
	stx $4010	//Disable DMC IRQs

	//Could do more shit here

	bit $2002
-;	bit $2002
	bpl -

	//clr memory
	txa
-;	sta $0000,x
	sta $0100,x
	sta $0200,x
	sta $0300,x
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	inx
	bne -

	//Could do more stuff

	//test a copy of the title screen for now
	ldx #$20
	stx $2006
	sta $2006

	//copy nametable
	ldx #$00
-;	lda title_nam+$000,x
	sta $2007
	inx
	bne -
-;	lda title_nam+$100,x
	sta $2007
	inx
	bne -
-;	lda title_nam+$200,x
	sta $2007
	inx
	bne -
-;	lda title_nam+$300,x
	sta $2007
	inx
	bne -
	//copy palette
	lda #$3F
	sta $2006
	stx $2006
-;	lda title_pal,x
	sta $2007
	inx
	cpx #$04
	bne -

	//wait for VBlank
-;	bit $2002
	bpl -

	lda #$00
	sta $2000
	bit $2002
	sta $2005
	sta $2005
	//show stuff
	lda #%00001000
	sta $2001
-;	jmp -

title_nam:
	insert "../chr/title.nam"
title_pal:
	insert "../chr/title.pal"
