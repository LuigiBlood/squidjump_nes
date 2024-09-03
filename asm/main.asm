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

_start:
	lda #$01
	jsr init_game_mode

_update:
	jsr update_game_mode

	inc wait_nmi
 -;	lda wait_nmi
	bne -
	jmp _update

init_game_mode:
	sta.b game_mode
	cmp #$00
	bne +
	jmp title_init
 +;	cmp #$01
	bne +
	jmp game_init
 +;	rts

update_game_mode:
	lda.b game_mode
	cmp #$00
	bne +
	jmp title_update
 +;	cmp #$01
	bne +
	jmp game_update
 +;	rts
