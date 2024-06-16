[BITS 16]
[ORG 0x0000]  ; The offset within segment 0x1000 is 0x0000

start:
    ; Set up segments
    mov ax, 0x1000  ; Segment where the kernel is loaded
    mov ds, ax      ; Set DS to this segment
    mov es, ax      ; Set ES to this segment

    ; Set cursor position to the start (top-left corner)
    mov ah, 0x02    ; BIOS function to set cursor position
    mov bh, 0x00    ; Page number
    mov dh, 0x00    ; Row (2)
    mov dl, 0x00    ; Column (0)
    int 0x10        ; Call BIOS video interrupt

    ; Print the kernel message
    mov si, kernel_message

print_kernel:
    lodsb           ; Load byte at address DS:SI into AL and increment SI
    or al, al       ; Check if end of string (null character)
    jz done         ; If zero (end of string), jump to done
    mov ah, 0x0E    ; BIOS teletype output function
    int 0x10        ; Call BIOS video interrupt
    jmp print_kernel ; Repeat for the next character

done:
    cli             ; Disable interrupts
    hlt             ; Halt the CPU

kernel_message db 'Hi from Kernel', 0

times 510 - ($ - $$) db 0
dw 0xAA55
