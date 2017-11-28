section .multiboot_header
header_start:
    ; dw = define word - 2 byte
    ; dd = define double word - 4 Byte
    dd 0xe85250d6                ; magic number (multiboot 2)
    dd 0                         ; architecture 0 (protected mode i386)
    dd header_end - header_start ; header length
    ; checksum
    ; "hacked" to prevent compiler warning:
    ;  https://os.phil-opp.com/multiboot-kernel/#fn-checksum_hack
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; insert optional multiboot tags here

    ; required end tag
    ;  (u16, u16, u32)
    ;  (0, 0, 8)
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:
