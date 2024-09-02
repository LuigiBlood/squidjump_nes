//Build Sound Factory Patches
architecture nes.cpu

include "./asm/macros.asm"

output "./squidjump.nes", create
origin 0
fill $10,$00	//iNES Header
fill $10000,$FF	//PRG ROM
fill $2000,$FF	//CHR ROM

seekPRGAddr(0)
include "./asm/main.asm"


//Edit Header
origin 0
db "NES", $1A	//Magic
db $02			//PRG ROM Size
db $01			//CHR ROM Size (8 KB)
db $00			//Mapper 0 + Horizontal Mirroring
db $00			//Mapper 0 (NES 2.0)
db $00
db $00
db $00
db $00
db $00
db $00
