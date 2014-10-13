; A boot sector that boots a C kernel in 32-bit protected mode
[org 0x7c00]

KERNEL_OFFSET equ 0x1000  ; Memory offset to which we will load our kernel

  mov [BOOT_DRIVE], dl    ; BIOS stores the boot drive in DL, so it's
                          ; best to remember this for later.

  mov bp, 0x9000          ; Set up the stack
  mov sp, bp

  mov bx, MSG_REAL_MODE   ; Announce that we are starting
  call print_string       ; booting from 16-bit real mode

  call load_kernel        ; Load our kernel

  call switch_to_pm       ; Switch to protected mode, from which
                          ; there is no return

  jmp $

; Include our routines
%include "print_string.asm"
%include "disk_load.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

[bits 16]

load_kernel:
  mov bx, MSG_LOAD_KERNEL
  call print_string

  mov bx, KERNEL_OFFSET
  mov dh, 15
  mov dl, [BOOT_DRIVE]
  call disk_load

  ret

[bits 32]

; This is where we arrive after switching to and initialising protected mode
BEGIN_PM:
  mov ebx, MSG_PROT_MODE   ; Use our 32-bit print routine to
  call print_string_pm     ; announce we are in protected mode

  call KERNEL_OFFSET       ; Now jump to the address of our loaded
                           ; kernel code, assume the brace position,
                           ; and cross your fingers. Here we go!

  halt:                    ; Hang
    hlt
    jmp halt

; Global variables
BOOT_DRIVE      db 0
MSG_REAL_MODE   db "Started in 16-bit real mode",0xd,0xa,0
MSG_PROT_MODE   db "Successfully landed in 32-bit protected mode",0
MSG_LOAD_KERNEL db "Loading kernel into memory",0xd,0xa,0

; Bootsector padding
times 510-($-$$) db 0
dw 0xaa55

