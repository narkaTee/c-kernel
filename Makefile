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

# -m elf_i386 force 32 bit emulation
LD_FLAGS_x86 := -m elf_i386
GCC_FLAGS_x86 := -m32
NASM_FLAGS_x86 := -f elf32

LD_FLAGS := $(LD_FLAGS_$(arch))
GCC_FLAGS := $(GCC_FLAGS_$(arch))
NASM_FLAGS := $(NASM_FLAGS_$(arch))


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

# depends on asm object files, linker script and kernel object files
$(kernel): $(assembly_object_files) $(linker_script) $(kernel_object_files)
	@ld $(LD_FLAGS) -n -T $(linker_script) -o $(kernel) $(assembly_object_files) $(kernel_object_files)

# compile c files
build/arch/$(arch)/c/%.o: src/arch/$(arch)/%.c
	@mkdir -p $(shell dirname $@)
	@gcc $(GCC_FLAGS) -c $< -o $@

# compile assembly files
# depends on asm source files make only builds this if the input files have changed
build/arch/$(arch)/asm/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm $(NASM_FLAGS) $< -o $@
