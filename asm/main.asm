nmi:
	rts

irq:
	rts

reset:
	sei			//Ignore IRQs
	cld			//Disable Decimal Mode
	ldx #$40
	stx JOY2	//Disable APU Frame IRQ
	ldx #$ff
	txs			//Set up stack
	inx			//X = 0
	stx PPUCTRL	//Disable NMI
	stx PPUMASK	//Disable Rendering
	stx DMC_FREQ	//Disable DMC IRQs

	//Could do more shit here

	bit PPUSTATUS
-;	bit PPUSTATUS
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
	stx PPUADDR
	sta PPUADDR

	//copy nametable
	ldx #$00
-;	lda title_nam+$000,x
	sta PPUDATA
	inx
	bne -
-;	lda title_nam+$100,x
	sta PPUDATA
	inx
	bne -
-;	lda title_nam+$200,x
	sta PPUDATA
	inx
	bne -
-;	lda title_nam+$300,x
	sta PPUDATA
	inx
	bne -
	//copy palette
	lda #$3F
	sta PPUADDR
	stx PPUADDR
-;	lda title_pal,x
	sta PPUDATA
	inx
	cpx #$04
	bne -

	//wait for VBlank
-;	bit PPUSTATUS
	bpl -

	lda #$00
	sta PPUCTRL
	bit PPUSTATUS
	sta PPUSCROLL
	sta PPUSCROLL
	//show stuff
	lda #%00001000
	sta PPUMASK
-;	jmp -

title_nam:
	insert "../chr/title.nam"
title_pal:
	insert "../chr/title.pal"
