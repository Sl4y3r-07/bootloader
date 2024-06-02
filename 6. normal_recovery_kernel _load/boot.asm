bits 16
org 0x7c00

start:
    ; Clear the screen
    mov ah, 0x06    ; Scroll up function
    mov al, 0       ; Number of lines to scroll
    mov bh, 0x07    ; Display page
    mov cx, 0       ; Upper left corner (row 0, column 0)
    mov dx, 0x184F  ; Lower right corner (row 24, column 79)
    int 0x10        ; Video BIOS interrupt

    ; Display boot menu
    mov si, message
    mov dh, 0x1  ; setting row for center pos
    mov dl, 0x2  ; setting column for center pos
    call set_cursor_position
    call print_string

    ; Display Normal Mode
    mov si, message_1
    inc dh
    call set_cursor_position
    call print_string

    ; Display Recovery Mode
    mov si, message_2
    inc dh
    call set_cursor_position
    call print_string

    ; Display Select Choice
select_choice:
    mov si, message_3
    inc dh
    call set_cursor_position
    call print_string
    
    mov dl, 28
    call set_cursor_position
    
    xor di, di
    ; Get input
input:
    mov ax, 0x00             ; get keyboard input
    int 0x16                 ; hold for input
    cmp al, 0x08             ; Check if backspace key pressed
    je backspace
    cmp al, 0x0d             ; Check if Enter key pressed
    je enter
    cmp al, 0x00             ; Check for special key (e.g., arrow keys)
    je skip_input            ; Skip handling for special keys
    cmp al, 0xE0             ; Check for extended key (e.g., arrow keys)
    je skip_input            ; Skip handling for extended keys
    inc dl  
    mov [input_buffer + di], al
    inc di                   ; 
    mov ah, 0x0E             ; display input char
    int 0x10
    jmp input

skip_input:
    int 0x16                 ; Get the second byte of the key code
    jmp input                ; Return to input loop

backspace:
    cmp dl, 28               ; Check if cursor is at starting column
    jl input                 ; If at starting column, do nothing
    mov ah, 0x0E
    mov al, 0x20             ; Space character
    int 0x10  
    dec dl                   ; Move cursor back one column
    call set_cursor_position         
    jmp input

enter:
    mov si, input_buffer
    call check_input
    hlt

check_input:
    inc dh
    mov dl, 0x2              ; setting column for center pos
    call set_cursor_position
    cmp byte [si], '1'
    je normal_mode
    cmp byte [si], '2'
    je recovery_mode

    ; If input is neither 1 nor 2
    mov si, wrong_choice_msg
    call print_string
    jmp select_choice

normal_mode:
    mov word [boot_mode], 1  ; Set boot mode to normal
    jmp load_kernel

recovery_mode:
    mov word [boot_mode], 2  ; Set boot mode to recovery
    jmp load_kernel

load_kernel:
    ; Load the kernel (assuming it's at sector 2)
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x1000           ; Load address

    mov ah, 0x02             ; BIOS read sectors function
    mov al, 1                ; Number of sectors to read
    mov ch, 0                ; Cylinder number
    mov cl, 2                ; Sector number (starting from 1)
    mov dh, 0                ; Head number
    mov dl, 0x80             ; Drive number (0x80 = first hard drive)
    int 0x13                 ; BIOS disk interrupt
    jc disk_error            ; Jump if there was an error

    ; Pass boot mode to kernel
    mov ax, [boot_mode]
    mov [0x1000], ax

    ; Jump to the kernel entry point
    jmp 0x0000:0x1000

disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $

print_string:
    mov ah, 0x0E             ; BIOS teletype function
.print_char:
    lodsb                    ; Load next byte from string into AL
    cmp al, 0
    je .done                 ; If null-terminator, we're done
    int 0x10                 ; BIOS video interrupt
    jmp .print_char
.done:
    ret

set_cursor_position:
    pusha
    mov ah, 0x02             ; Set cursor position function
    xor bh, bh               ; Default page number, 0
    int 0x10                 ; BIOS video interrupt
    popa
    ret

message db 'Boot Options', 0
message_1 db '1. Normal Mode [Default mode]', 0
message_2 db '2. Recovery Mode', 0
message_3 db 'Select Your Choice (1/2) ', 0
wrong_choice_msg db 'Wrong choice', 0
disk_error_msg db 'Disk read error!', 0

input_buffer times 1 db 0
boot_mode dw 0              ; Variable to store boot mode

times 510-($-$$) db 0       ; 
dw 0xaa55                   ; Boot sector signature
