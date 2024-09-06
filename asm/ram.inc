//Zero Page (Critical data here for lower cycles)
//Watch out not to overtake the stack
setAllocAddr($00)
	allocate(temp0)				//Temp Variable 0
	allocate(temp1)				//Temp Variable 1
	allocate(temp2)				//Temp Variable 2
	allocate(temp3)				//Temp Variable 3
	allocate(temp4)				//Temp Variable 4
	allocate(temp5)				//Temp Variable 5
	allocate(temp6)				//Temp Variable 6
	allocate(temp7)				//Temp Variable 7

	allocate(buf_ppuctrl)		//PPUCTRL Write Shadow
	allocate(buf_ppumask)		//PPUMASK Write Shadow
	allocate(buf_ppuscroll_x)	//PPUSCROLL Write Shadow (1)
	allocate(buf_ppuscroll_y)	//PPUSCROLL Write Shadow (2)

	allocate(wait_nmi)			//Waiting for NMI flag
	allocate(need_oam_update)	//Flag to upload OAM on next NMI
	allocate(need_ppu_update)	//Flag to update PPU Registers on next NMI
	allocate(need_ppu_upload)	//Flag to upload to PPU on next NMI

	allocate(oambuf_ptr)		//Current OAM Pointer
	allocate(ppubuf_ptr)		//Current PPU Upload Buffer Pointer

	allocate(frame_count)		//Frame Counter
	allocate(first_game_frame)	//First Game Frame has been rendered flag

	allocate(div_result)		//Division Result
	allocate(mod_result)		//Division Reminder
	allocate(div_val_lo)
	allocate(div_val_hi)

	allocate(player1_prev)		//Joypad 1 Button Data (Held on Previous Frame)
	allocate(player1_hold)		//Joypad 1 Button Data (Held Buttons)
	allocate(player1_push)		//Joypad 1 Button Data (Pressed Buttons)

	allocate(game_mode)			//Game Mode (handles management of code)

	allocate(title_select)		//Title Screen Option Selection

	allocate(squid_display)		//Squid: Sprite Graphics to display
	allocate(squid_hold)		//Squid: Hold (Charge Jump)
	allocate(squid_stand)		//Squid: Standing on Platform (Type)
	allocate(squid_stand_ptr)	//Squid: Standing on Platform (Ptr)
	allocate(squid_color)		//Squid: Color (Temp)
	allocate(squid_x_frac)		//Squid: X Position (Subpixel)
	allocate(squid_x_int)		//Squid: X Position (Pixel)
	allocate(squid_y_frac)		//Squid: Y Position (Subpixel)
	allocate(squid_y_lo)		//Squid: Y Position (Pixel)
	allocate(squid_y_hi)		//Squid: Y Position (Pixel)
	allocate(squid_dx_frac)		//Squid: Delta X Movement (Subpixel)
	allocate(squid_dx_int)		//Squid: Delta X Movement (Pixel)
	allocate(squid_dy_frac)		//Squid: Delta Y Movement (Subpixel)
	allocate(squid_dy_lo)		//Squid: Delta Y Movement (Pixel)

setAllocAddr($0200)
	allocate(oambuf)	//OAM Buffer, $100 bytes

setAllocAddr($0300)
	allocate(ppubuf)	//PPU Upload Buffer, $100 bytes (Queue for PPU uploads for NMI)

//Game
setAllocAddr($0400)
	allocate(stgbuf)	//Stage Platform Data, $100 bytes
						//allows up to exactly 51 platforms if we use 256 bytes, which is actually more than enough, at worst we could allow even more
