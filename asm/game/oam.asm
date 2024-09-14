game_set_oam:
	jsr empty_oambuffer
	jsr game_set_spr0
	jsr game_squid_oam
	jsr game_platform_oam
	inc.b need_oam_update
	rts

game_set_spr0:
	ldx.b oambuf_ptr
	stx oambuf+0
	lda.b poison_y_lo		// \
	sec; sbc.b squid_y_lo	// |
	pha						// | Subtract Poison Water Y with Squid Y
	lda.b poison_y_hi		// |
	sbc.b squid_y_hi		// /
	beq _game_set_spr0_pos	// * Check if value is positive (00** only, beyond that, don't manage it)
	cmp #-1					// \
	beq _game_set_spr0_neg	// / Check if value is negative (FF** only, beyond that, don't manage it)
	pla
	jmp _game_set_spr0_end
_game_set_spr0_neg:
	pla						// \
	cmp #-1					// |
	beq +					// | Check if value is between -1 to -7*8, if so, then place Sprite 0 Y
	cmp #-7*8				// |
	bcs +					// /
	jmp _game_set_spr0_end
_game_set_spr0_pos:
	pla						// \
	beq +					// | Check if value is between 0 and 10*8, if so, then place Sprite 0 Y
	cmp #10*8				// |
	bcc +					// /
	jmp _game_set_spr0_end
+;
	sta.b temp0
	lda #$B8-1
	sec; sbc.b temp0
	sta oambuf+$00,x
_game_set_spr0_end:
	lda #$FE
	sta oambuf+$01,x
	lda #$23
	sta oambuf+$02,x
	lda #$00
	sta oambuf+$03,x
	inx;inx;inx;inx;
	stx.b oambuf_ptr
	rts

game_squid_oam:
	//Uses two sprites
	ldx.b oambuf_ptr
	//Sprite Graphics
	lda.b squid_display
	asl
	tay

	lda _game_squid_oam_table_chr+0,y
	sta oambuf+$00+1,x
	lda _game_squid_oam_table_chr+1,y
	sta oambuf+$04+1,x

	lda _game_squid_oam_table_attr+0,y
	sta oambuf+$00+2,x
	lda _game_squid_oam_table_attr+1,y
	sta oambuf+$04+2,x

	//X Position
	lda.b squid_x_int
	sta oambuf+$00+3,x
	clc
	adc #7	//Yes, +7 is normal
	sta oambuf+$04+3,x

	//Y Position (offset by 0xB7, for camera scrolling purposes)
	lda #$B8-1
	sta oambuf+$00+0,x
	sta oambuf+$04+0,x

	//Update OAM Pointer to the next unused ones
	txa
	clc; adc #4*2
	sta.b oambuf_ptr
	rts

_game_squid_oam_table_chr:
	db $80, $80,  $82, $82,  $84, $84,  $86, $86
	db $88, $88,  $8A, $8C,  $80, $80,  $8C, $8A

_game_squid_oam_table_attr:
	db $40, $00,  $40, $00,  $40, $00,  $40, $00
	db $40, $00,  $00, $00,  $C0, $80,  $40, $40

constant temp_oam_length = temp0
constant temp_oam_platform_y_lo = temp1
constant temp_oam_platform_y_md = temp2
constant temp_oam_platform_y_hi = temp3
constant temp_oam_platform_x_shift = temp2

game_platform_oam:
	ldx #0	//X = Stage Buffer
	ldy.b oambuf_ptr	//Y = OAM Buffer

	//Loop until it finds the end type (FF)
-;	lda stgbuf+0,x
	cmp #$FF
	bne +
	//Update OAM Pointer to the next unused ones
	sty.b oambuf_ptr
	rts
+;
	cmp #$02	//Moving Platform
	beq +
	cmp #$03
	beq +
	cmp #$04	//Conveyor Belt
	beq +
	cmp #$05
	beq +
_game_platform_oam_next:
	//Go to Next Platform
	inx;inx;inx;inx;inx
	jmp -
+;
_game_platform_oam:
	//Render Moving Platform
	//Length in Tiles (force max 8 sprites per platform)
	lda stgbuf+2,x
	cmp #9
	bcc +
	lda #8
+;	sta.b temp_oam_length

	//It's probably possible to optimize this further, but it's smooth as it is
	//Convert Platform Tile Y Position to Global Pixel Y Position (24-bit Value)
	// LO = Subpixel, MD and HI = Pixel, Multiply by 8
	lda #0
	sta.b temp_oam_platform_y_md
	sta.b temp_oam_platform_y_hi
	lda stgbuf+3,x
	asl; rol.b temp_oam_platform_y_md; rol.b temp_oam_platform_y_hi
	asl; rol.b temp_oam_platform_y_md; rol.b temp_oam_platform_y_hi
	asl; rol.b temp_oam_platform_y_md; rol.b temp_oam_platform_y_hi
	sta.b temp_oam_platform_y_lo

	//Then subtract with Squid Pixel Y Position, to get a difference
	lda.b temp_oam_platform_y_lo
	sec; sbc.b squid_y_lo
	sta.b temp_oam_platform_y_lo
	lda.b temp_oam_platform_y_md
	sbc.b squid_y_hi
	sta.b temp_oam_platform_y_md
	lda.b temp_oam_platform_y_hi
	sbc #0
	sta.b temp_oam_platform_y_hi

	//Check if platform is close enough to be rendered
	//Between -7*8 and 25*8 pixels
	lda.b temp_oam_platform_y_hi // \
	beq ++                       // |
	cmp #-1                      // | Check if the difference is between $FF0000 and $00FFFF
	beq +                        // | Else do not bother, it's too far to render
	jmp _game_platform_oam_next  // /
+;	                             // Handle Negative number
	lda.b temp_oam_platform_y_md // \
	cmp #-1                      // | Check if the difference is between -1 and -7*8
	bne _game_platform_oam_next  // | Else do not bother
	lda.b temp_oam_platform_y_lo // |
	cmp #-7*8                    // |
	bcc _game_platform_oam_next  // /
	jmp game_platform_oam_render
+;	                             // Handle Positive number
	lda.b temp_oam_platform_y_md // \
	bne _game_platform_oam_next  // | Check if the difference is between 0 and 25*8
	lda.b temp_oam_platform_y_lo // | Else do not bother
	cmp #25*8                    // |
	bcs _game_platform_oam_next  // /
game_platform_oam_render:
	//Render platform
	lda stgbuf+0,x
	lsr
	cmp #$01	//Moving Platform
	beq +
	cmp #$02	//Conveyor Belt
	beq ++
	jmp _game_platform_oam_next
+;	jmp _game_platform_oam_render_2_3
+;	jmp _game_platform_oam_render_4_5
_game_platform_oam_render_2_3:
	//Moving Platform
	//Calculate Y Position Offset by $C8
	lda #$C8
	clc; sbc.b temp_oam_platform_y_lo
	sta.b temp_oam_platform_y_lo

	//Save Base X Position
	lda stgbuf+1,x	//X Pos
	sta.b temp_oam_platform_x_shift

	//Render Sprites
-;	lda.b temp_oam_platform_x_shift // \ X Position
	sta oambuf+3,y                  // /
	lda.b temp_oam_platform_y_lo    // \ Y Position
	sta oambuf+0,y                  // /
	lda #$0A                        // \ Sprite Graphics ($0A)
	sta oambuf+1,y                  // /
	lda #$01                        // \ Attributes
	sta oambuf+2,y                  // / Palette 1

	iny;iny;iny;iny                 // Set to Next OAM Sprite
	lda.b temp_oam_platform_x_shift // \
	clc; adc #8                     // | Next Sprite should be +8 pixels to the right
	sta.b temp_oam_platform_x_shift // /
	dec.b temp_oam_length           // Count down length left, continue until 0
	bne -
	jmp _game_platform_oam_next
_game_platform_oam_render_4_5:
	//Conveyor Belt

	//Check if Conveyor Belt goes to the left or right
	lda stgbuf+0,x
	lsr
	bcs +
	lda.b frame_count  // \ If it moves to the right:
	and #7             // | Offset X Position by -8 + frame_count&7
	sec; sbc #8        // /
	jmp ++
+;	lda.b frame_count  // \ If it moves to the left:
	and #7             // | Offset X Position by -frame_count&7
	eor #$FF           // |
	clc; adc #1        // /
+;	sta.b temp_oam_platform_x_shift

	//The effect is done by using one more sprite and priority behind opaque background, BUT
	//Optimization: If Offset X Position is by -8 or 0 then do not use the extra sprite, it's unnecessary
	and #8
	beq +
	inc.b temp_oam_length
+;
	//Calculate Y Position Offset by $C8
	lda #$C8
	clc; sbc.b temp_oam_platform_y_lo
	sta.b temp_oam_platform_y_lo

	//Save Base X Position + Offset
	lda stgbuf+1,x	//X Pos
	clc; adc.b temp_oam_platform_x_shift
	sta.b temp_oam_platform_x_shift

	//Render Sprites
-;	lda.b temp_oam_platform_x_shift // \ X Position
	sta oambuf+3,y                  // /
	lda.b temp_oam_platform_y_lo    // \ Y Position
	sta oambuf+0,y                  // /
	lda #$0C                        // \ Sprite Graphics ($0C)
	sta oambuf+1,y                  // /
	lda #$22                        // \ Attributes
	sta oambuf+2,y                  // / Palette 2, Priority behind background

	iny;iny;iny;iny                 // Set to Next OAM Sprite
	lda.b temp_oam_platform_x_shift // \
	clc; adc #8                     // | Next Sprite should be +8 pixels to the right
	sta.b temp_oam_platform_x_shift // /
	dec.b temp_oam_length           // Count down length left, continue until 0
	bne -
	jmp _game_platform_oam_next

