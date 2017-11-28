arch ?= x86
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso

linker_script := src/arch/$(arch)/linker.ld
grub_cfg := src/arch/$(arch)/grub.cfg
kernel_source_files := $(wildcard src/arch/$(arch)/*.c)
# $(patsubst pattern,replacement,text)
kernel_object_files := $(patsubst src/arch/$(arch)/%.c, \
	build/arch/$(arch)/c/%.o, $(kernel_source_files))

assembly_source_files := $(wildcard src/arch/$(arch)/*.asm)
assembly_object_files := $(patsubst src/arch/$(arch)/%.asm, \
	build/arch/$(arch)/asm/%.o, $(assembly_source_files))

.PHONY: all clean run iso

all: $(kernel)

clean:
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -curses -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	@rm -r build/isofiles

# depends on object files and linker script
$(kernel): $(assembly_object_files) $(linker_script) c-kernel
	# -m elf_i386 force 32 bit emulation
	ld -m elf_i386 -n -T $(linker_script) -o $(kernel) $(assembly_object_files) $(kernel_object_files)

c-kernel: $(kernel_object_files)

# compile c files
build/arch/x86/c/%.o: src/arch/$(arch)/%.c
	@mkdir -p $(shell dirname $@)
	@gcc -m32 -c $< -o $@

# compile assembly files
# depends on asm source files make only builds this if the input files have changed
build/arch/x86/asm/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -f elf32 $< -o $@
