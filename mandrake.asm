define	PATCH_NUMBER	0

define	PATCH_ADRESS	0
define	PATCH_SIZE	3
define	PATCH_BOOT	6
define	PATCH_OFFSET	9

mandrake:

.patch:
; iy is patch, combined with the default common patch
	push	iy
	call	aspirin.reset_all_ipbs
	call	aspirin.wait_ipbs_500_us
	pop	iy
; we can now write boot code
; please no erase okay ?
; custom patch
	call	.apply_patch
; apply the common patch
	ld	iy, boot_common_patch
	call	.apply_patch
	call	aspirin.set_boot_ipbs
	jp	aspirin.wait_ipbs_500_us

.apply_patch:
; iy is patch
	ld	b, (iy+PATCH_NUMBER)
	inc	iy
	ld	a, b
	or	a, a
	ret	z
.loop:
	push	bc
	ld	hl, (iy+PATCH_ADRESS)
	ld	bc, (iy+PATCH_SIZE)
	ld	de, (iy+PATCH_BOOT)
	call	aspirin.write
	pop	bc
	lea	iy, iy+PATCH_OFFSET
	djnz	.loop
	ret
