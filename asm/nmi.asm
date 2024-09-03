nmi:
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

 +;	//Do PPU Register Update if pending
	lda need_ppu_update
	beq +

	lda.b buf_ppumask
	sta PPUMASK
	lda.b buf_ppuctrl
	sta PPUCTRL

	bit PPUSTATUS
	lda.b buf_ppuscroll_x
	sta PPUSCROLL
	lda.b buf_ppuscroll_y
	sta PPUSCROLL

	stx need_ppu_update

 +;	//Read Joypad
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

	rti
