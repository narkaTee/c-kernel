global start
extern kernel_main

section .text
bits 32 ; nasm directive: switch from protected mode to 32 bit mode
start:
    ; move the stack pointer to the top of the stack.
    ; esp could point to whatever was in there before.
    mov esp, stack_top ; The stack grows downwards thus we use the top

    call check_multiboot

    ; call kernel
    call kernel_main
    hlt

; Prints `ERR: ` and the given error code to screen and hangs.
; parameter: error code (in ascii) in al
error:
    ; 1 Byte color code, 1 Byte ascii char
    ; packed in one word 4 byte: color,ascii,color,ascii
    ; 1f = white bg & red text
    mov dword [0xb8000], 0x4f524f45 ;52 = R, 45 = E
    mov dword [0xb8004], 0x4f3a4f52 ;3a = :, 52 = R
    mov dword [0xb8008], 0x4f204f20 ;20 = <space>, the second space is overwritten by next command (we only increment the addr by 2 byte)
    mov byte  [0xb800a], al
    hlt

; Check if we're startet by a multiboot bootloader
check_multiboot:
    cmp eax, 0x36d76289 ; multiboot 2 magic number for bootloader
    jne .no_multiboot ; check the zero flag in the FLAGS register, if the cmp failed jump to label
    ret
.no_multiboot:
    mov al, "0" ; put ascii code "0" into al register
    jmp error

; create a unintialized stack
; -> only pop if we pushed something!
section .bss
stack_bottom:
    resb 8192     ;8kb for stack
stack_top:
