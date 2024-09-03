//NES PPU Registers
constant PPUCTRL	= $2000
constant PPUMASK	= $2001
constant PPUSTATUS	= $2002
constant OAMADDR	= $2003
constant OAMDATA	= $2004
constant PPUSCROLL	= $2005
constant PPUADDR	= $2006
constant PPUDATA	= $2007

//NES CPU Registers
constant SQ1_VOL	= $4000
constant SQ1_SWEEP	= $4001
constant SQ1_LO		= $4002
constant SQ1_HI		= $4003

constant SQ2_VOL	= $4004
constant SQ2_SWEEP	= $4005
constant SQ2_LO		= $4006
constant SQ2_HI		= $4007

constant TRI_LINEAR	= $4008
constant TRI_LO		= $400A
constant TRI_HI		= $400B

constant NOISE_VOL	= $400C
constant NOISE_LO	= $400E
constant NOISE_HI	= $400F

constant DMC_FREQ	= $4010
constant DMC_RAW	= $4011
constant DMC_START	= $4012
constant DMC_LEN	= $4013

constant OAMDMA		= $4014

constant SND_CHN	= $4015

constant JOY1		= $4016
constant JOY2		= $4017
