[bits 32]
; Define some constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f
LINE_LEN equ 80*2

; Prints a null-terminated string pointed to by EDX
print_string_pm:
  pusha

  mov edx, VIDEO_MEMORY + LINE_LEN*11    ; Set EDX to the start of vid mem.

print_string_pm_loop:
  mov al, [ebx]            ; Store the char at EBX in al
  mov ah, WHITE_ON_BLACK   ; Store the attributes in AH

  cmp al, 0                ; Check if we're at the end of the string
  je print_string_pm_done  ;   if so, jump to done

  mov [edx], ax            ; Store the char and attributes at current
                           ; character cell.

  add ebx, 1               ; Increment EBX to the next char in the string
  add edx, 2               ; Move to next character cell in vid mem

  jmp print_string_pm_loop ; loop to the next char

print_string_pm_done:
  popa
  ret

