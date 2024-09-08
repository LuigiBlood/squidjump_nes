include "ram.inc"

include "irq.asm"
include "nmi.asm"
include "util.asm"
include "joypad.asm"
include "./game/game.asm"
include "title.asm"

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
	waitVBlank()

	//Clear RAM
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

	if {defined FDSVERSION} {
	lda #$C0
	sta $0100
	}

_start:
	//Set Game Mode
	lda #$01
	jsr init_game_mode

_update:
	//Update Game Frame
	jsr update_game_mode
	//Wait for NMI to update again
	inc.b wait_nmi
 -;	lda.b wait_nmi
	bne -
	lda.b first_game_frame
	bne +
	inc.b first_game_frame
+;	jmp _update

init_game_mode:
	//Initialize Game Mode
	//Argument: A = Game Mode
	ldx #0
	stx.b first_game_frame
	sta.b game_mode
	cmp #$00
	bne +
	jmp title_init
 +;	cmp #$01
	bne +
	jmp game_init
 +;	rts

update_game_mode:
	//Update Game Frame
	lda.b game_mode
	cmp #$00
	bne +
	jmp title_update
 +;	cmp #$01
	bne +
	jmp game_update
 +;	rts
