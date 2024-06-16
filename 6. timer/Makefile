all:
	nasm -f bin -o  boot.bin boot.asm
	nasm -f bin -o  kernel.bin kernel.asm
	dd if=/dev/zero bs=512 count=2880 of=disk.img
	dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc
	dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc

run: 
	qemu-system-x86_64 disk.img

clean:
	rm boot.bin kernel.bin disk.img
