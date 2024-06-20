bits 16

org 0x7c00      ; bootloader will be loaded at this address

mov ah, 0x06    
xor al, al      ; Number of lines by which to scroll up, al=00h, means entire screen will be cleared up
xor cx, cx      ; Row,column of window's upper left corner, specified by cx. higher byte (ch)-> row and lower byte(cl)->column
mov dx, 0x184f  ; Row,column of window's lower right corner, specifeid by dx. dh->0x18 and dl-> 0x4f
mov bh, 0x38    ; represents background and foreground colour. 0x3-> background and 0x8-> foreground
int 0x10        ; call BIOS video interrupt

;printing `Sl4y3rOS` in center

mov si, message
mov cx, message_len

;calculating rows and columns for center position

mov dh, 0xc ; setting row for center pos
mov dl, 40  ; setting column for center pos
sub dl, cl  ; adjusting the length 

mov ah, 0x02 ; for setting the cursor position
xor bh,bh    ; default page number, 0
int 0x10     ; BIOS video interrupt

print_:
    mov ah, 0x0e       ; BIOS function 0Eh (print character)
    mov al, [si]       ; load the next character into AL
    int 0x10           ; call BIOS video interrupt
    inc si             ; move to the next character
    loop print_        ; repeat until CX is zero

jmp $

message db 'Sl4y3rOS', 0
message_len equ $ - message

times 510-($-$$) db 0 ; rest bytes with 0
dw 0xaa55   ; boot sector signature/ magic number