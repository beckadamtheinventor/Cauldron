define	null	$E40000

boot_common_patch:
 db	6	; patch count, order is important for safety
 
 dl	.p_000
 dl	.p_000_end - .p_000
 dl	$016066 ;(end of interrupt patch is 65)
 
 dl	.p_001
 dl	4
 dl	$000061
 
 dl	.p_002
 dl	1
 dl	$00003E
 
 dl	null
 dl	3
 dl	$000067
 
 dl	null
 dl	4
 dl	$00006B
 
 dl	.p_003
 dl	4
 dl	$016000
 
 ; full. Flash. Unlock. In. Plain. SIGHT
.p_000:
.flash_unlock:
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
.flash_lock:
	xor	a, a
	out0	($28), a
	in0	a, ($06)
	res	2, a
	out0	($06), a
	ret
; it would be a shame if we could use those. Oh, wait, we can
.port_out:
	out	(bc), a
	ret
.port_in:
	in	a, (bc)
	ret

.p_000_end:

.p_001:
	jp	$016004

.p_002:
	jr	$

; eyup
.p_003:
	db	$DE, $AD, $C0, $DE
