hellebore:

.unlock_flash_exploit = $3F0000

.setup:
	ld	a, $3F
	call	aspirin.sector_erase
	ld	hl, hellebore.privilege
	ld	de, $3F0000
	ld	bc, hellebore.payload
	jp	boot_write_flash

.payload = .end - .privilege

.privilege:
; full RAM privilege
	ld	a, $D3
	out0	($25), a
	ld	a, $FF
	out0	($24), a
	out0	($23), a
	ld	a, $D0
	out0	($22), a
	xor	a, a
	out0	($21), a
	out0	($20), a
.unlock:
	in0	a, ($06)
	or	a, 4
	out0	($06), a
	ld	a, 4
	di 
	jr	$+2
	di
	rsmix 
	im 1
	out0	($28), a
	in0	a, ($28)
	bit	2, a
	ret
.lock:
	xor	a, a
	out0	($28), a
	in0	a, ($06)
	res	2, a
	out0	($06), a
	ret
.end:
