bits 16

org 0x7c00      ; bootloader will be loaded at this address

mov ah, 0x06    
xor al, al      ; Number of lines by which to scroll up, al=00h, means entire screen will be cleared up
xor cx, cx      ; Row,column of window's upper left corner, specified by cx. higher byte (ch)-> row and lower byte(cl)->column
mov dx, 0x134f  ; Row,column of window's lower right corner, specifeid by dx. dh->0x13 and dl-> 4f
mov bh, 0x3b    ; represents background and foreground colour. 0x3-> background and 0xb-> foreground
int 0x10        ; call BIOS video interrupt
 
jmp $
times 510-($-$$) db 0 
dw 0xaa55