nmi:
	pha
	txa
	pha
	tya
	pha

	//Skip NMI if frame update isn't done yet
	ldx #$00
	lda wait_nmi
	bne +
	jmp nmi_end

 +;	//OAM Update
	lda need_oam_update
	beq +

	stx OAMADDR
	lda #(oambuf >> 8)
	sta OAMDMA
	stx need_oam_update

 +;	//PPU Register Update
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