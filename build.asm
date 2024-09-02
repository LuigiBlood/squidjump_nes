//Build Sound Factory Patches
architecture nes.cpu

include "./asm/macros.asm"
include "./asm/regs.inc"

output "./squidjump.nes", create
origin 0
fill $10,$00	//iNES Header
fill $8000,$00	//PRG ROM
fill $2000,$00	//CHR ROM

seekPRGAddr($8000)
include "./asm/main.asm"

//Vectors
seekPRGAddr($FFFA); dw nmi
seekPRGAddr($FFFC); dw reset
seekPRGAddr($FFFE); dw irq

seekCHRAddr(0)
insert "./chr/title.chr"

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
