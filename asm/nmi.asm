nmi:
	pha
	txa
	pha
	tya
	pha

	ldx #$00
	lda wait_nmi
	bne +
	jmp nmi_end
+;
	lda need_oam_update
	beq +

	stx OAMADDR
	lda #(oambuf >> 8)
	sta OAMDMA
	stx need_oam_update

+;
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

+;
	lda #$00
	sta wait_nmi

nmi_end:
	jsr read_joy
	pla
	tay
	pla
	tax
	pla

	rti
