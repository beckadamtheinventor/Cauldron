include	'include/ez80.inc'
include	'include/tiformat.inc'
include	'include/ti84pce.inc'

define	CEMU_ONLY

format	ti executable 'CAULDRON'

define	boot_write_flash	$0002E0
define	boot_erase_flash	$0002DC
define	boot_get_hardware_vers	$000084
define	boot_get_key_ID		$000088
define	boot_get_boot_verminor	$00008C
define	boot_get_boot_verbuild	$000090
define	boot_delay_10ms		$0003B4
define	boot_battery_level	$0003B0

assume adl = 1

Cauldron:
	call	ti.RunIndicOff
	call	ti.HomeUp
	call	ti.ClrScrn
	call	ti.DrawStatusBar
	call	boot_battery_level
	jp	c, .error_battery_low
; ask at least 40% charged battery before trying to execute the program
	cp	a, 2
	jp	c, .error_battery_low
	di
; detect ourselves
	ld	hl, ($016000)
	ld	bc, $C0ADDE
	or	a, a
	sbc	hl, bc
	jp	z, .error_already_present
; detect boot code first
	xor	a, a
	ld	bc, 0
	call	boot_get_boot_verminor	; 05
	push	af
	call	boot_get_boot_verbuild
	pop	af
	cp	a, $05
	jr	z, .boot_5.1.5
	cp	a, $01
	jr	z, .boot_5.3.1
	cp	a, $00
; invalid boot, nz set
	jp	nz, .error_boot_unknown
.boot_5.0.0:
	ld	hl, 89*256
	sbc	hl, bc
	ret	nz
	ld	hl, boot_5.0.0.0089_patch
	jr	.patch
.boot_5.1.5:
	ld	hl, 14*256
	sbc	hl, bc
	ret	nz
	ld	hl, boot_5.1.5.0014_patch
	jr	.patch
.boot_5.3.1:
	ld	hl, 50*256
	sbc	hl, bc
	ret	nz
	ld	hl, boot_5.3.1.0050_patch

.patch:
	push	hl
	call	gentian.port_setup
	call	gentian.unlock
	call	hellebore.setup
	pop	iy
	call	mandrake.patch
	push	af
	call	gentian.lock
	pop	af
	ld	hl, .failure_string
	jr	c, .exit_status
	ld	hl, .success_string
.exit_status:
	ld	iy, $D00080
	push	hl
	or	a, a
	sbc	hl, hl
	call	ti.SetTextFGBGcolors
	pop	hl
	call	ti.PutS
; wait for key and exit
	call	ti.NewLine
	call	ti.NewLine
	ld	hl, .key_string
	call	ti.PutS
.wait_key:
	call	ti.os.GetCSC
	ld	a, h
	or	a, l
	jr	z, .wait_key
	call	ti.ClrScrn
	call	ti.DrawStatusBar
	call	ti.RunIndicOn
	jp	ti.DrawBatteryIndicator

.error_battery_low:
	ld	hl, .battery_string
	jr	.exit_status
.error_already_present:
	ld	hl, .present_string
	jr	.exit_status
.error_boot_unknown:
	ld	hl, .unknown_string
	jr	.exit_status

.present_string:
 db "Boot code has already been patched !", 0
.battery_string:
 db "Battery too low to try patching.", 0
.success_string:
 db "Boot code has been successfully patched.", 0
.key_string:
 db "Press any key to continue.", 0
.unknown_string:
 db "Unknown boot code. Are you sure the hardware is compatible ?", 0
.failure_string:
 db "Patch can't be applied !", 0
 
include	'mandrake.asm'
include	'gentian.asm'
include	'hellebore.asm'
include	'aspirin.asm'
include	'patch/boot_common_patch.asm'
include	'patch/boot_5.3.1.0050_patch.asm'
include	'patch/boot_5.1.5.0014_patch.asm'
include	'patch/boot_5.0.0.0089_patch.asm'
