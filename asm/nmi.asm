nmi:
	php
	pha
	txa
	pha
	tya
	pha

	//Skip NMI if game frame update isn't done yet
	ldx #$00
	lda.b wait_nmi
	bne +
	jmp nmi_end

 +;	//Do OAM Update if pending
	lda.b need_oam_update
	beq +

	stx OAMADDR
	lda #(oambuf >> 8)
	sta OAMDMA
	stx.b need_oam_update

 +;
	//Update Color for Squid
	setPPUADDR($3F13)
	lda.b squid_color
	sta PPUDATA
	lda #0
	sta PPUADDR
	sta PPUADDR

	//Do PPU Upload
	lda.b need_ppu_upload
	beq +
	jsr _ppu_upload
	stx.b need_ppu_upload
+;
	//Do PPU Register Update if pending
	lda.b need_ppu_update
	beq +

	bit PPUSTATUS
	lda.b buf_ppuscroll_x
	sta PPUSCROLL
	lda.b buf_ppuscroll_y
	sta PPUSCROLL

	lda.b buf_ppumask
	sta PPUMASK
	lda.b buf_ppuctrl
	sta PPUCTRL

	stx.b need_ppu_update

 +;	
	//Read Joypad
	jsr read_joy
	inc.b frame_count
	//Let next frame be managed
	lda #$00
	sta.b wait_nmi

nmi_end:
	pla
	tay
	pla
	tax
	pla
	plp
	rti

_ppu_upload:
	lda.b ppubuf_ptr
	beq +
	ldy #0
_ppu_upload_loop:
	lda ppubuf+0,y	//Set Addr
	sta PPUADDR
	lda ppubuf+1,y
	sta PPUADDR
	lda ppubuf+2,y	//Size
	tax
	iny;iny;iny
	//Upload Data
-;	lda ppubuf,y
	sta PPUDATA
	iny
	dex
	bne -

	cpy.b ppubuf_ptr
	bne _ppu_upload_loop
+;	lda #0
	sta.b ppubuf_ptr
	rts
