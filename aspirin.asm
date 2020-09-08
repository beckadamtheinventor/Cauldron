; please, take an aspirin
aspirin: 
 
.sector_erase:
	ld	bc, $F8
	push	bc
	jp	boot_erase_flash
	
.reset_all_ipbs:
	call	.enter_ipb_program
	ld 	a, $80
	ld	($00), a
	ld	a, $30
	ld	($00), a
	ld 	hl, 24000*71/33

.wait_ipbs:
	dec	hl
	add	hl, de
	or	a, a
	sbc	hl, de
	jr	nz, .wait_ipbs
	jp	.exit_ipb_program

.set_boot_ipbs:
	ld  b, 9
	ld  hl, 0
	ld  de, 8192

.set_ipb:
	call	.enter_ipb_program
	ld	a, $A0
	ld	($000), a
	ld	a, $00
	ld	(hl), a
	add	hl, de
	call	.wait_ipbs_500_us
	call	.exit_ipb_program
	djnz	.set_ipb
	ret

.wait_ipbs_500_us:
	push	hl
	ld	hl, 24000/33
.wait_busy_loop:
	dec	hl
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz, .wait_busy_loop
	pop	hl
	ret

.enter_ipb_program:
	ld 	a, $AA
	ld	($AAA), a
	ld	a, $55
	ld	($555), a
	ld	a, $C0
	ld	($AAA), a
	ret

.exit_ipb_program:
	ld	a, $90
	ld	($00), a
	xor	a,a
	ld 	($00), a
	ret
	
.write:
; write hl to flash for bc bytes
.write_loop:
	ld	a, (hl)
	push	hl
	ld	hl, $000AAA
	ld	(hl), l
	ld	hl, $000555
	ld	(hl), l
	add	hl, hl
	ld	(hl), $A0
; byte to program = a
; safe and with the byte
	ld	(de), a
if ~defined CEMU_ONLY
	ex	de, hl
.wait:
	cp	a, (hl)
	jr	nz, .wait
	ex	de, hl
end if
	pop	hl
	inc	de
	cpi
	jp	pe, .write_loop
	ret
	
	
