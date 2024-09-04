//Zero Page
setAllocAddr($00)
allocate(argument0)
allocate(argument1)
allocate(argument2)
allocate(argument3)
allocate(argument4)
allocate(argument5)

allocate(buf_ppuctrl)
allocate(buf_ppumask)
allocate(buf_ppuscroll_x)
allocate(buf_ppuscroll_y)

allocate(wait_nmi)
allocate(need_oam_update)
allocate(need_ppu_update)

allocate(frame_count)

allocate(player1_prev)
allocate(player1_hold)
allocate(player1_push)

//Game Mode
allocate(game_mode)
//Title Screen Selection
allocate(title_select)

//Squid
allocate(squid_display)	//Sprite to display
allocate(squid_hold)	//Hold
allocate(squid_stand)	//Standing on Floor
allocate(squid_color)	//Color (Temp)

allocate(squid_x_frac)
allocate(squid_x_int)

allocate(squid_y_frac)
allocate(squid_y_lo)
allocate(squid_y_hi)

allocate(squid_dx_frac)
allocate(squid_dx_int)

allocate(squid_dy_frac)
allocate(squid_dy_lo)

//OAM Buffer
setAllocAddr($0200)
allocate(oambuf)

//Game
setAllocAddr($0300)
