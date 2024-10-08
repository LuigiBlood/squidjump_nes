include "squid.asm"
include "oam.asm"
include "platform.asm"
include "collision.asm"
include "stage.asm"
include "display.asm"
include "poison.asm"

game_init:
	ldx #$00
	stx PPUCTRL	//Disable NMI
	stx PPUMASK	//Disable Rendering

	//Init RAM
	stx game_state
	stx countdown
	stx frame_count

	stx squid_display
	stx squid_hold
	stx squid_x_frac
	stx squid_x_int
	stx squid_y_frac
	stx squid_y_lo
	stx squid_y_hi

	stx squid_dx_frac
	stx squid_dx_int
	stx squid_dy_frac
	stx squid_dy_lo

	lda #$80
	sta squid_x_int
	sta squid_y_lo

	sta poison_y_lo
	dex
	stx poison_y_hi

	jsr game_stage_copy

	lda #0
	sta temp1
	sta temp3
	sta temp0
	lda #60
	sta temp2
	jsr game_platform_display_direct

	setPPUADDR($3F00); copyPPUDATA(game_pal, $20)
	sta PPUADDR
	sta PPUADDR

	//PPU
	lda #%10100000
	sta.b buf_ppuctrl
	lda #$00
	sta.b buf_ppuscroll_x
	sta.b buf_ppuscroll_y
	//show stuff
	lda #%00011110
	sta.b buf_ppumask

	//OAM
	jsr empty_oambuffer

	//Set NMI Management
	inc need_oam_update
	inc need_ppu_update

	waitVBlank()

	//Ack VBlank
	bit PPUSTATUS
	//Enable NMI
	lda #$80
	sta PPUCTRL

	rts

game_joypad_mgr:
	lda.b player1_push
	and #$10
	beq +
	lda.b game_state
	eor #1
	sta.b game_state
+
	rts

game_lose_state_mgr:
	lda.b game_state
	cmp #2
	bne +
	lda.b countdown
	bne +
	lda #$01
	jsr init_game_mode
+;	rts

game_update:
	jsr game_joypad_mgr
	lda.b game_state
	cmp #1
	beq ++
	cmp #2
	beq +

	jsr game_squid_update
	jsr game_platform_update
	jsr game_poison_update
	jsr game_scrolling_mgr
+;
	jsr game_set_oam
+;
	inc.b need_ppu_update
	jsr game_spr0_effect

	jsr game_lose_state_mgr
	rts

game_pal:
	db $01, $17, $27, $01	//BG 0 (Dirt, Sprite 0 Hit)
	db $01, $11, $21, $30	//BG 1 (Ice)
	db $01, $17, $27, $30	//BG 2
	db $01, $17, $27, $30	//BG 3
	db $01, $0F, $00, $30	//SPR0 Grey (Squid)
	db $01, $11, $21, $30	//SPR1 Blue (Moving Platform)
	db $01, $2D, $3D, $38	//SPR2 Grey, Yellow Tint (Conveyor Belt)
	db $01, $16, $27, $30	//SPR3 Red
