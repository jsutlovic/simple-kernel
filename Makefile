LD=i386-elf-ld
GCC=gcc
NASM=nasm
QEMU=qemu-system-i386
#QUIET=&>1 >> /dev/null
QUIET=

# Automatically generate lists of sources using wildcards
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# Convert the *.c filenames to *.o to give a list of object files to build
OBJ = ${C_SOURCES:.c=.o}

all: os-image

# Run qemu to simulate booting our code
run: all
	$(QEMU) os-image

# This is the actual disk image (with extra padding) that the computer loads
os-image: os-image-pre
	dd if=/dev/zero of=$@ bs=512 count=20 $(QUIET)
	dd if=$< of=$@ conv=notrunc $(QUIET)

# This is our compiled bootsector and kernel
os-image-pre: boot/boot_sect.bin kernel.bin
	cat $^ > $@

# This builds the binary of our kernel from two object files:
#  - the kernel_entry, which jumps to main() in our kernel
#  - the compiled C kernel
kernel.bin: kernel/kernel_entry.o ${OBJ}
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary $(QUIET)

# Generic rule for compiling C code to an object file
# For simplicity, our C files depend on all header files.
%.o : %.c ${HEADERS}
	$(GCC) --target=elf32-i386 -ffreestanding -c $< -o $@

# Build our kernel entry object file
%.o: %.asm
	$(NASM) $< -f elf -o $@

# Assemble the boot sector into raw machine code
#   The -I options tells nasm where to find our useful assembly
#   routines that we include in boot_sect.asm
%.bin : %.asm
	$(NASM) $< -f bin -I'boot/inc/' -o $@

# Special directive to make sure clean runs even if
# there is a file called "clean" in this directory
.PHONY: clean

# Clear away all generated files
clean:
	rm -rf *.bin *.o os-image os-image-pre *.dis
	rm -rf kernel/*.o boot/*.bin drivers/*.o

# Disassemble our kernel - might be useful for debugging
kernel.dis : kernel.bin
	ndisasm -b 32 $< > $@
