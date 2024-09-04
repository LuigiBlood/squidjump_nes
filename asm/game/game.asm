include "squid.asm"
include "oam.asm"
include "display.asm"
include "collision.asm"
include "stage.asm"

game_init:
	ldx #$00
	stx PPUCTRL	//Disable NMI
	stx PPUMASK	//Disable Rendering

	//Init RAM
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

	jsr game_stage_copy

	//Upload to PPU
	setPPUADDR($2000)
	lda #$00
	jsr fill_ppudata100
	jsr fill_ppudata100
	jsr fill_ppudata100
	jsr fill_ppudata100
	setPPUADDR($2800)
	lda #$00
	jsr fill_ppudata100
	jsr fill_ppudata100
	jsr fill_ppudata100
	jsr fill_ppudata100

	jsr game_display_platform_start

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

game_update:
	jsr game_squid_physics
	jsr game_set_oam
	rts

game_pal:
	db $01, $17, $27, $30	//BG 0
	db $01, $17, $27, $30	//BG 1
	db $01, $17, $27, $30	//BG 2
	db $01, $17, $27, $30	//BG 3
	db $01, $0F, $00, $30	//SPR0
	db $01, $00, $10, $30	//SPR1
	db $01, $00, $10, $30	//SPR2
	db $01, $00, $10, $30	//SPR3
