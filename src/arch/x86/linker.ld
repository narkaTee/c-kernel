ENTRY(start)

SECTIONS {
    /* Kernel code should start at address 0x100000 -> 1M */
    . = 1M;
    .boot : {
        /* ensure that the multiboot header is at the beginning */
        *(.multiboot_header)
    }
    .text : {
        /* * = all Files, (.text) = all ".text" input sections */
        *(.text)
    }
}
