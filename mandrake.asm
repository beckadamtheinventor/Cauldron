define	PATCH_NUMBER	0

define	PATCH_ADRESS	0
define	PATCH_SIZE	3
define	PATCH_BOOT	6
define	PATCH_OFFSET	9

mandrake:

.patch:
; iy is patch, combined with the default common patch
	call	.check_patch
	jr	c, .failure
	push	iy
	ld	iy, boot_common_patch
	call	.check_patch
	pop	iy
	jr	c, .failure
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
	call	aspirin.wait_ipbs_500_us
	xor	a, a
	ret
	
.failure:
	ld	a, 1
	scf
	ret
	
.apply_patch:
; iy is patch
	push	iy
	ld	b, (iy+PATCH_NUMBER)
	inc	iy
	ld	a, b
	or	a, a
	jr	z, .error_null
.loop:
	push	bc
	ld	hl, (iy+PATCH_ADRESS)
	ld	bc, (iy+PATCH_SIZE)
	ld	de, (iy+PATCH_BOOT)
	call	aspirin.write
	pop	bc
	lea	iy, iy+PATCH_OFFSET
	djnz	.loop
	pop	iy
	xor	a, a
	ret

.error_mismatch:
.error_null:
	scf
	ret

.check_patch:
	push	iy
	ld	b, (iy+PATCH_NUMBER)
	inc	iy
	ld	a, b
	or	a, a
	jr	z, .error_null
.verify_loop:
	push	bc
	ld	hl, (iy+PATCH_ADRESS)
	ld	bc, (iy+PATCH_SIZE)
	ld	de, (iy+PATCH_BOOT)
	call	.check_apply
	pop	bc
	jr	nz, .error_mismatch
	djnz	.verify_loop
	pop	iy
	xor	a, a
	ret
	
.check_apply:
	ld	a, (de)	; boot 
	and	a, (hl)	; value to write
	cpi
	ret	nz
	inc	de
	jp	pe, .check_apply
	ret
