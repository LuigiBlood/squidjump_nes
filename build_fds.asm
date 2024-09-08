//Build Sound Factory Patches
architecture nes.cpu

include "./asm/macros.asm"
include "./asm/fdsmacros.asm"
include "./asm/regs.inc"

define GameCode = "IKA "
define GameVersion = $00
define FDSVERSION = 1

print "PRGMAIN-\n"
output "./temp/PRGMAIN", create
origin 0
base $6000
fill $8000,$FF
origin 0
include "./asm/main.asm"
origin $7FFA
dw nmi
dw reset
dw irq

print "CHRMAIN-\n"
output "./temp/CHRMAIN", create
origin 0
base 0
insert "./chr/game.chr"
insert "./chr/title.chr"

print "FDS File\n"
output "./squidjump.fds", create
origin 0
base 0
FDSheader(1)
FDSbase(0,0,$0F)
FDSfileKyodaku()
FDSfile("PRGMAIN-",$0F,$6000,$8000,0)
insert "./temp/PRGMAIN"
FDSfile("CHRMAIN-",$0F,$0000,$2000,1)
insert "./temp/CHRMAIN"
FDSend()
