[BITS 16]
[ORG 0x1000]

start:
    mov si, kernel_message
print_kernel:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_kernel
done:
    cli
    hlt

kernel_message db 'Kernel loaded successfully!!', 0
times 510 - ($-$$) db 0
dw 0xAA55
