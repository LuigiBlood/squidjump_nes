game_init:
	ldx #$00
	stx PPUCTRL	//Disable NMI
	stx PPUMASK	//Disable Rendering

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

	setPPUADDR($2340); copyPPUDATA_fill($06, $20)

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
	lda #$01
	sta.b need_oam_update
	sta.b need_ppu_update

	waitVBlank()

	//Ack VBlank
	bit PPUSTATUS
	//Enable NMI
	lda #$80
	sta PPUCTRL

	rts
game_update:
	rts

game_pal:
	db $01, $17, $27, $30	//BG 0
	db $01, $17, $27, $30	//BG 1
	db $01, $17, $27, $30	//BG 2
	db $01, $17, $27, $30	//BG 3
	db $01, $00, $10, $30	//SPR0
	db $01, $00, $10, $30	//SPR1
	db $01, $00, $10, $30	//SPR2
	db $01, $00, $10, $30	//SPR3
