nasm -f bin stage1.asm -o stage1.bin
nasm -f bin stage2.asm -o stage2.bin
nasm -f bin kernel.asm -o kernel.bin

dd if=/dev/zero of=main_floppy.img bs=512 count=2880
mkfs.fat -F 12 -n "NBOS" main_floppy.img
dd if=stage1.bin of=main_floppy.img conv=notrunc
mcopy -i main_floppy.img stage2.bin "::stage2.bin"  #for root directory 
# mcopy -i main_floppy.img kernel.bin "::kernel.bin"  #for root directory
qemu-system-x86_64 main_floppy.img