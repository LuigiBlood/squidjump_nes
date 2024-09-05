nmi:
	php
	pha
	txa
	pha
	tya
	pha

	//Skip NMI if game frame update isn't done yet
	ldx #$00
	lda wait_nmi
	bne +
	jmp nmi_end

 +;	//Do OAM Update if pending
	lda need_oam_update
	beq +

	stx OAMADDR
	lda #(oambuf >> 8)
	sta OAMDMA
	stx need_oam_update

 +;
	//Test Color for Squid
	setPPUADDR($3F13)
	lda squid_color
	sta PPUDATA
	lda #0
	sta PPUADDR
	sta PPUADDR
	
	//Do PPU Register Update if pending
	lda need_ppu_update
	beq +

	bit PPUSTATUS
	lda buf_ppuscroll_x
	sta PPUSCROLL
	lda buf_ppuscroll_y
	sta PPUSCROLL

	lda buf_ppumask
	sta PPUMASK
	lda buf_ppuctrl
	sta PPUCTRL

	stx need_ppu_update

 +;	
	//Read Joypad
	jsr read_joy
	inc frame_count
	//Let next frame be managed
	lda #$00
	sta wait_nmi

nmi_end:
	pla
	tay
	pla
	tax
	pla
	plp
	rti
