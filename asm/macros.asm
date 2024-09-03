//Seek NROM (assume NROM-256)
macro seekPRGAddr(n) {
	origin ({n} & 0x7FFF) + 0x10
	base {n}
}

macro seekCHRAddr(n) {
	origin ({n} & 0x7FFF) + 0x10 + 0x8000
	base {n}
}

macro setPPUADDR(n) {
	lda #(({n} >> 8) & $FF)
	sta PPUADDR
	lda #({n} & $FF)
	sta PPUADDR
}

macro waitVBlank() {
-;	bit PPUSTATUS
	bpl -
}

//Assume OAM Data is in $0200
variable ramalloc = $0300
inline setAllocAddr(n) {
	ramalloc = {n}
}

inline allocate(v) {
	constant {v} = ramalloc
	ramalloc = ramalloc + 1
}
