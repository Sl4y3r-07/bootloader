bits 16
org 0x7C00      ; Bootloader will be loaded at this address

start:
    ; Clear the screen
    mov ah, 0x06    
    xor al, al      ; Number of lines to scroll up (0 = clear entire screen)
    xor cx, cx      ; Upper left corner (row 0, column 0)
    mov dx, 0x184F  ; Lower right corner (row 24, column 79)
    mov bh, 0x38    ; represents background and foreground colour. 0x3-> background and 0x8-> foreground
    int 0x10        ; call BIOS video interrupt

    ; Print `Sl4y3rOS` in the center
    mov si, message
    mov cx, message_len

    ; Calculate rows and columns for center position
    mov dh, 0x0C    ; Center row
    mov dl, 40      ; Center column
    sub dl, cl      ; Adjust for message length

    mov ah, 0x02    ; Set cursor position
    xor bh, bh      ; Page number 0
    int 0x10        ; BIOS video interrupt

print_:
    mov ah, 0x0e       ; BIOS function 0Eh, teletype output (print character)
    mov al, [si]       ; Load the next character into AL
    int 0x10           ; Call BIOS video interrupt
    inc si             ; Move to the next character
    loop print_        ; Repeat until CX is zero


    ; Load the kernel (assuming it's located at sector 2)
    mov bx, 0x1000  ; Load segment address for the kernel
    mov es, bx      ; ES:BX points to 0x1000:0x0000
    mov bx, 0x0000  ; Offset address
    mov ah, 0x02    ; BIOS read sectors function
    mov al, 0x01    ; Number of sectors to read (1 sector)
    mov ch, 0x00    ; Cylinder number
    mov cl, 0x02    ; Sector number (sector 2)
    mov dh, 0x00    ; Head number
    mov dl, 0x80    ; Drive number (first hard drive)
    int 0x13        ; BIOS disk interrupt
    jc disk_error   ; Jump if carry flag is set (error)
     ; Print 'Kernel loaded successfully!' message
    mov si, kernel_loaded_msg
    mov cx, kernel_loaded_len

    mov dh, 0x02    ; Row
    mov dl, 40      ; Column
    sub dl, cl      ; Adjust for message length

    mov ah, 0x02    ; Set cursor position
    xor bh, bh      ; Page number 0
    int 0x10        ; BIOS video interrupt

print_kernel_loaded:
    mov ah, 0x0E    ; BIOS teletype output
    mov al, [si]    ; Load the next character
    int 0x10        ; BIOS video interrupt
    inc si          ; Move to the next character
    loop print_kernel_loaded

    ; Jump to kernel entry point
    jmp 0x1000:0x0000
   

disk_error:
    ; Handle disk error
    mov si, disk_error_msg
    mov cx, disk_error_len

    mov dh, 0x01 ; setting row for center pos
    mov dl, 40  ; setting column for center pos
    sub dl, cl  ; adjusting the length 

    mov ah, 0x02 ; for setting the cursor position
    xor bh,bh    ; default page number, 0
    int 0x10     ; BIOS video interrupt

print__:
    mov ah, 0x0e       ; BIOS function 0Eh, teletype output (print character)
    mov al, [si]       ; Load the next character into AL
    int 0x10           ; Call BIOS video interrupt
    inc si             ; Move to the next character
    loop print__       ; Repeat until CX is zero
    hlt

    
message db 'Sl4y3rOS', 0
message_len equ $ - message

disk_error_msg db 'Disk read error!', 0
disk_error_len equ $ - disk_error_msg


kernel_loaded_msg db 'Kernel loaded successfully!', 0
kernel_loaded_len equ $-kernel_loaded_msg

jmp $

times 510-($-$$) db 0 ; rest bytes with 0
dw 0xaa55   ; boot sector signature/ magic number
