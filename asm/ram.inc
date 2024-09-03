//Zero Page
setAllocAddr($0000)
allocate(argument1)
allocate(argument2)

allocate(buf_ppuctrl)
allocate(buf_ppumask)
allocate(buf_ppuscroll_x)
allocate(buf_ppuscroll_y)

allocate(wait_nmi)
allocate(need_oam_update)
allocate(need_ppu_update)

allocate(game_mode)

allocate(player1_prev)
allocate(player1_hold)
allocate(player1_push)

allocate(title_select)

//OAM Buffer
setAllocAddr($0200)
allocate(oambuf)

//Game
setAllocAddr($0300)

allocate(squid_display)

allocate(squid_x_freq)
allocate(squid_x_int)

allocate(squid_y_lo)
allocate(squid_y_hi)
allocate(squid_y_freq)
