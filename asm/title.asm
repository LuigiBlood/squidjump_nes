title_init:
	ldx #$00
	stx PPUCTRL	//Disable NMI
	stx PPUMASK	//Disable Rendering

	//Init RAM
	stx.b title_select

	//Upload to PPU
	setPPUADDR($2000); copyPPUDATA(title_nam, $400)
	setPPUADDR($3F00); copyPPUDATA(title_pal, 4)
	setPPUADDR($3F10); copyPPUDATA(title_pal, 4)

	//PPU
	lda #%10010000
	sta.b buf_ppuctrl
	lda #$00
	sta.b buf_ppuscroll_x
	sta.b buf_ppuscroll_y
	//show stuff
	lda #%00011000
	sta.b buf_ppumask

	//OAM
	jsr empty_oambuffer
	lda #$8F
	sta oambuf+$00
	lda #$1A
	sta oambuf+$01
	lda #$60
	sta oambuf+$03

	lda #$01
	sta.b need_oam_update
	sta.b need_ppu_update

	waitVBlank()

	//Acknowledge VBlank
	bit PPUSTATUS
	//Enable NMI
	lda #$80
	sta PPUCTRL
	rts

title_update:
	lda.b player1_push
	and #%00000100
	//DOWN
	beq +
	ldx.b title_select
	inx
	cpx #$03
	bcc _title_update_oam
	ldx #$00
	jmp _title_update_oam
 +;	lda.b player1_push
	and #%00001000
	//UP
	bne +
	rts
 +;	ldx.b title_select
	dex
	bpl _title_update_oam
	ldx #$02
_title_update_oam:
	stx.b title_select
	cpx #$00
	bne +
	lda #$8F
	jmp _title_update_oam_end
 +;	cpx #$01
	bne +
	lda #$9F
	jmp _title_update_oam_end
 +;	lda #$AF
_title_update_oam_end:
	sta oambuf+$00
	sta.b need_oam_update
	rts

title_nam:
	insert "../chr/title.nam"
title_pal:
	insert "../chr/title.pal"
