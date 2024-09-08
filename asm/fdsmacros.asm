macro FDSheader(sides) {
	origin 0
	fill $10
	fill 65500,$FF
	origin 0
	db "FDS", $1A
	db {sides}
	db 0,0,0,0,0,0,0,0,0,0,0
}

variable fdsfilecount = 0
macro FDSbase(diskno, sideno, boot) {
	db 1					//Block Code
	db "*NINTENDO-HVC*"		//ASCII
	db 0					//Licensee Code
	db {GameCode}			//Game Code (4 bytes)
	db {GameVersion}		//Game Version
	db {sideno}				//Side Number
	db {diskno}				//Disk Number
	db 0					//Disk Type
	db 0
	db {boot}				//Boot read file code
	db $FF,$FF,$FF,$FF,$FF
	db 0,0,0				//Manufacturing Date
	db $49					//Country: Japan
	db $61,$00,$00,$02
	db $FF,$FF,$FF,$FF,$FF
	db 0,0,0				//Rewritten Disk Date
	db $00,$FF
	db $FF,$FF				//Disk Writer serial number
	db $FF
	db $00					//Disk Rewrite Count
	db {sideno}				//Actual Disk Side
	db $00					//Disk Type
	db $00					//Disk Version

	db 2					//Block Code
	db 0
}

inline FDSfile(filename, fileid, address, size, type) {
	db 3
	db fdsfilecount
	db {fileid}
	db {filename}
	dw {address}
	dw {size}
	db {type}
	
	db 4
	fdsfilecount = fdsfilecount + 1
	base {address}
}

inline FDSfileKyodaku() {
	FDSfile("KYODAKU-",0,$2800,$00E0,2)
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$17,$12,$17,$1D,$0E
	db $17,$0D,$18,$24,$28,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	db $24,$24,$24,$24,$24,$24,$24,$0F,$0A,$16,$12,$15,$22,$24,$0C,$18
	db $16,$19,$1E,$1D,$0E,$1B,$24,$1D,$16,$24,$24,$24,$24,$24,$24,$24
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	db $24,$24,$1D,$11,$12,$1C,$24,$19,$1B,$18,$0D,$1E,$0C,$1D,$24,$12
	db $1C,$24,$16,$0A,$17,$1E,$0F,$0A,$0C,$1D,$1E,$1B,$0E,$0D,$24,$24
	db $24,$24,$0A,$17,$0D,$24,$1C,$18,$15,$0D,$24,$0B,$22,$24,$17,$12
	db $17,$1D,$0E,$17,$0D,$18,$24,$0C,$18,$27,$15,$1D,$0D,$26,$24,$24
	db $24,$24,$18,$1B,$24,$0B,$22,$24,$18,$1D,$11,$0E,$1B,$24,$0C,$18
	db $16,$19,$0A,$17,$22,$24,$1E,$17,$0D,$0E,$1B,$24,$24,$24,$24,$24
	db $24,$24,$15,$12,$0C,$0E,$17,$1C,$0E,$24,$18,$0F,$24,$17,$12,$17
	db $1D,$0E,$17,$0D,$18,$24,$0C,$18,$27,$15,$1D,$0D,$26,$26,$24,$24
}

inline FDSend() {
	origin $49
	db fdsfilecount
}
