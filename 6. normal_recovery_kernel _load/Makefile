all:
	nasm -f bin boot.asm -o boot.bin
	gcc -m32 -ffreestanding -fno-pic -c kernel.c -o kernel.o
	ld -m elf_i386 -Ttext 0x1000 --oformat binary -e _start kernel.o -o kernel.bin
	cat boot.bin kernel.bin  > disk.bin

	

clean:
	rm -f boot.bin kernel.bin disk.bin kernel.o
	
.PHONY: 
	all clean