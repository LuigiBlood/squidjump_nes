title_init:
	ldx #$00
	stx PPUCTRL	//Disable NMI
	stx PPUMASK	//Disable Rendering

	//init RAM
	stx.b title_select

	waitVBlank()

	//copy nametable
	setPPUADDR($2000)
	ldx #$00
 -;	lda title_nam+$000,x
	sta PPUDATA
	inx
	bne -
 -;	lda title_nam+$100,x
	sta PPUDATA
	inx
	bne -
 -;	lda title_nam+$200,x
	sta PPUDATA
	inx
	bne -
 -;	lda title_nam+$300,x
	sta PPUDATA
	inx
	bne -

	//copy palette
	setPPUADDR($3F00)
	ldx #$00
 -;	lda title_pal,x
	sta PPUDATA
	inx
	cpx #$04
	bne -

	setPPUADDR($3F10)
	ldx #$00
 -;	lda title_pal,x
	sta PPUDATA
	inx
	cpx #$04
	bne -

//PPU
	lda #%10001000
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
	lda #$0D
	sta oambuf+$01
	lda #$60
	sta oambuf+$03

	lda #$01
	sta.b need_oam_update
	sta.b need_ppu_update

	waitVBlank()

	bit PPUSTATUS
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
