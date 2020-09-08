include	'include/ez80.inc'
include	'include/tiformat.inc'
include	'include/ti84pce.inc'

format	ti executable 'CAULDRON'

define	boot_write_flash	$0002E0
define	boot_erase_flash	$0002DC

define	boot_get_HardwareVers	$000084
define	boot_getKey_ID		$000088
define	boot_getBootVerMinor	$00008C
define	boot_getBootVerBuild    $000090
define	boot_delay10ms		$0003B4

assume adl = 1

Cauldron:
	di
; detect ourselves
	ld	hl, ($016000)
	ld	bc, $C0ADDE
	or	a, a
	sbc	hl, bc
	ret	z
; detect boot code first
	xor	a, a
	ld	bc, 0
	call	boot_getBootVerMinor	; 05
	push	af
	call	boot_getBootVerBuild
	pop	af
	cp	a, $05
	jr	z, .boot_5.1.5
	cp	a, $01
	jr	z, .boot_5.3.1
	cp	a, $00
	jr	z, .boot_5.0.0
; invalid boot, nz set
	ret
.boot_5.1.5:
	ld	hl, 14*256
	sbc	hl, bc
	ret	nz
	ld	hl, boot_5.1.5.0014_patch
	jr	.pscht
.boot_5.3.1:
	ld	hl, 50*256
	sbc	hl, bc
	ret	nz
	ld	hl, boot_5.3.1.0050_patch
	jr	.pscht
.boot_5.0.0:
	ld	hl, 89*256
	sbc	hl, bc
	ret	nz
	ld	hl, boot_5.0.0.0089_patch
.pscht:
	push	hl
	call	gentian.port_setup
	call	gentian.unlock
	call	hellebore.setup
	call	hellebore.unlock_flash_exploit
	pop	iy
	call	mandrake.patch
	jp	gentian.lock

include	'mandrake.asm'
include	'gentian.asm'
include	'hellebore.asm'
include	'aspirin.asm'
include	'patch/boot_common_patch.asm'
include	'patch/boot_5.3.1.0050_patch.asm'
include	'patch/boot_5.1.5.0014_patch.asm'
include	'patch/boot_5.0.0.0089_patch.asm'
