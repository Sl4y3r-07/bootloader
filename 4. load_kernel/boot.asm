BITS 16
ORG 0x7C00  

start:
    ; Clear the screen
    mov ah, 0x06    ; BIOS function
    xor al, al       
    xor cx, cx       
    mov dx, 0x184F   
    mov bh, 0x38     ; background color 0x3 (blue), foreground color 0x8 (dark gray)
    int 0x10        

    ; Print 'Sl4y3rOS' in the center
    mov si, message
    mov cx, message_len

    ; Calculate rows and columns for center position
    mov dh, 0x0C     ; center row (12)
    mov dl, 40       ; center column (40)
    shr cl, 1        ; divide message length by 2
   

    mov ah, 0x02     ; set cursor position
    xor bh, bh       ; page number 0
    int 0x10         ; BIOS video interrupt

print_:
    mov ah, 0x0E     ; BIOS function 0Eh, teletype output (print character)
    mov al, [si]     ; load the next character into AL
    int 0x10         ; call BIOS video interrupt
    inc si           ; move to the next character
    loop print_      ; repeat until CX is zero

    ; Load the kernel (assuming it's located at sector 2)
    mov bx, 0x1000   ; load segment address for the kernel
    mov es, bx       ; ES:BX points to 0x1000:0x0000
    xor bx, bx       ; offset address 0x0000
    mov ah, 0x02     ; BIOS read sectors function
    mov al, 0x01     ; number of sectors to read (1 sector)
    xor ch, ch       ; cylinder number 0
    mov cl, 0x02     ; sector number 2
    xor dh, dh       ; head number 0
    mov dl, 0x80     ; drive number (first hard drive)
    int 0x13         ; BIOS disk interrupt
    jc disk_error    ; jump if carry flag is set (error)

    jmp 0x1000:0x0000

disk_error:
    ; Handle disk error
    mov si, disk_error_msg
    mov cx, disk_error_len

    mov dh, 0x01     ; Row (1)
    mov dl, 40       ; Column (40)
    shr cl, 1        ; Divide message length by 2
    sub dl, cl       ; Adjust for half the message length

    mov ah, 0x02     ; Set cursor position
    xor bh, bh       ; Page number 0
    int 0x10         ; BIOS video interrupt

print__:
    mov ah, 0x0E     ; 
    mov al, [si]     ;
    int 0x10         ;
    inc si           ; 
    loop print__
    hlt

message db 'Sl4y3rOS', 0
message_len equ $ - message

disk_error_msg db 'Disk read error!', 0
disk_error_len equ $ - disk_error_msg

jmp $

times 510 - ($ - $$) db 0 ; Pad the rest with 0
dw 0xAA55                ; Boot sector signature
