//Seek NROM (assume NROM-256)
macro seekPRGAddr(n) {
	origin ({n} & 0x7FFF) + 0x10
	base {n}
}

macro seekCHRAddr(n) {
	origin ({n} & 0x7FFF) + 0x10 + 0x8000
	base {n}
}
