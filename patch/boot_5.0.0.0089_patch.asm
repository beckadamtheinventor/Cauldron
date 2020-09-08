 boot_5.0.0.0089_patch:
 
 db	1
  
 dl	.p_000
 dl	.p_000_end - .p_000
 dl	$016004

.p_000:
	push	hl
	push	af
	push	bc
	ld	hl, $020100
	ld	hl, (hl)
	ld	bc, $FFA55A
	or	a, a
	sbc	hl, bc
	jr	nz, .do_boot_int
	ld	a, ($020103)
	inc	a
	jr	z, .do_legacy_multiboot
	ld	a, ($D177BA)
	or	a, a
	jr	nz, .do_boot_int
	pop	bc
	pop	af
	jp	$02010C
.do_legacy_multiboot:
	pop	bc
	pop	af
	pop	hl
	ld	a, $03
	out0	($06), a
	ld	hl, ($D02AD7)
	push	hl
	ld	iy, $D00080
	set	6, (iy+$1B)
	ld	a, ($D177BA)
	or	a, a
	jr	nz, .jump
	jp	$02010C
.do_boot_int:
	pop	bc
	pop	af
	pop	hl
	ld	a, $03
	out0	($06), a
	ld	hl, ($D02AD7)
	push	hl
	ld	iy, $D00080
	set	6, (iy+$1B)
.jump:
	jp	$00132F

.p_000_end:
