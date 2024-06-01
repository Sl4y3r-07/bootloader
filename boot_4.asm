bits 16

org 0x7c00 

    mov ah, 0x06    ; Scroll up function
    mov al, 0       ; Number of lines to scroll
    mov bh, 0x07    ; Display page
    mov cx, 0       ; Upper left corner (row 0, column 0)
    mov dx, 0x184F  ; Lower right corner (row 24, column 79)
    int 0x10        ; Video BIOS interrupt

  ; for Boot Menu 
    mov si, message
    mov cx, message_len
    mov dh, 0x1 ; setting row for center pos
    mov dl, 0x2  ; setting column for center pos
    mov ah, 0x02 ; for setting the cursor position
    xor bh,bh    ; default page number, 0
    int 0x10     ; BIOS video interrupt
print_:
    mov ah, 0x0e       ; BIOS function 0Eh, teletype output (print character)
    mov al, [si]       ; Load the next character into AL
    int 0x10           ; Call BIOS video interrupt
    inc si             ; Move to the next character
    loop print_        ; Repeat until CX is zero

  ; for Normal Mode
    mov si, message_1
    mov cx, message_len_1
    inc dh
    mov ah, 0x02 ; for setting the cursor position
    xor bh,bh    ; default page number, 0
    int 0x10     ; BIOS video interrupt
print_1:
    mov ah, 0x0e       ; BIOS function 0Eh, teletype output (print character)
    mov al, [si]       ; Load the next character into AL
    int 0x10           ; Call BIOS video interrupt
    inc si             ; Move to the next character
    loop print_1 

; for Recovery Mode
    mov si, message_2
    mov cx, message_len_2
    inc dh
    mov ah, 0x02 ; for setting the cursor position
    xor bh,bh    ; default page number, 0
    int 0x10     ; BIOS video interrupt
print_2:
    mov ah, 0x0e       ; BIOS function 0Eh, teletype output (print character)
    mov al, [si]       ; Load the next character into AL
    int 0x10           ; Call BIOS video interrupt
    inc si             ; Move to the next character
    loop print_2

; for Selecting Choice
    mov si, message_3
    mov cx, message_len_3
    inc dh
    mov ah, 0x02 ; for setting the cursor position
    xor bh,bh    ; default page number, 0
    int 0x10     ; BIOS video interrupt
print_3:
    mov ah, 0x0e       ; BIOS function 0Eh, teletype output (print character)
    mov al, [si]       ; Load the next character into AL
    int 0x10           ; Call BIOS video interrupt
    inc si             ; Move to the next character
    loop print_3
    
    mov dl, 27
    mov ah, 0x02 ; for setting the cursor position
    mov bh,0    ; default page number, 0
    int 0x10
    

; for input
input:
    mov ax,0x00             ; get keyboard input
	int 0x16		        ; hold for input
    cmp al, 0x08            ; Check if backspace key pressed
    je backspace
    cmp al, 0x0d
    je enter
    cmp al, 0x00        ; Check for special key (e.g., arrow keys)
    je skip_input       ; Skip handling for special keys
    cmp al, 0xE0        ; Check for extended key (e.g., arrow keys)
    je skip_input       ; Skip handling for extended keys
    inc dl              ; If backspace, handle deletion
    mov ah,0x0E         ; display input char
    int 0x10
    jmp input

skip_input:
    int 0x16            ; Get the second byte of the key code
    jmp input           ; Return to input loop


backspace:
    cmp dl, 27         ; Check if cursor is at starting column
    jl input           ; If at starting column, do nothing
    mov ah, 0x0E       ; 
    mov al, 0x20       ; 
    int 0x10  
    dec dl             ; Move cursor back one column
    mov ah, 0x02       ; Set cursor position function
    mov bh, 0          ; Default page number, 0
    int 0x10         
    jmp input

enter:
    inc dh
    mov dl, 0x2
    mov ah, 0x02
    xor bh,bh        
    int 0x10
    jmp $


message db 'Boot Options', 0
message_len equ $ - message

message_1 db '1. Normal Mode', 0
message_len_1 equ $ - message_1

message_2 db '2. Recovery Mode', 0
message_len_2 equ $ - message_2

message_3 db 'Select Your Choice (1/2) ', 0
message_len_3 equ $ - message_3

; jmp $
times 510-($-$$) db 0 ; rest bytes with 0
dw 0xaa55   ; boot sector signature/ magic number

