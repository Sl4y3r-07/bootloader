bits 16
org 0x7c00

start:
    ; Clear the screen
    mov ah, 0x06
    mov al, 0
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x184F
    int 0x10

    ; Display Boot Menu
    mov si, message
    call print_string
    mov si, message_1
    call print_string
    mov si, message_2
    call print_string
    mov si, message_3
    call print_string

    ; Set cursor position for input
    mov dl, 27
    mov dh, 5
    call set_cursor_position

input_loop:
    mov ah, 0x00    ; Get keyboard input
    int 0x16        ; BIOS keyboard interrupt
    cmp al, '1'     ; Check if '1' is pressed
    je load_normal_mode
    cmp al, '2'     ; Check if '2' is pressed
    je load_recovery_mode
    jmp input_loop  ; Invalid input, loop again

load_normal_mode:
    ; Load kernel for Normal Mode
    mov bx, kernel_normal_segment
    call load_kernel
    jmp transfer_control

load_recovery_mode:
    ; Load kernel for Recovery Mode
    mov bx, kernel_recovery_segment
    call load_kernel
    jmp transfer_control

load_kernel:
    ; Load the kernel into memory at segment specified in BX
    pusha
    mov ax, bx
    mov es, ax
    xor bx, bx
    mov ah, 0x02    ; BIOS read sector function
    mov al, num_sectors  ; Number of sectors to read
    mov ch, 0       ; Cylinder
    mov cl, 2       ; Sector
    mov dh, 0       ; Head
    mov dl, 0       ; Drive (floppy)
    int 0x13        ; BIOS disk interrupt
    jc disk_error   ; Jump to disk error handler if carry flag is set
    popa
    ret

transfer_control:
    ; Jump to the kernel entry point
    jmp kernel_normal_segment:0x0000  ; Adjust segment:offset as needed

disk_error:
    ; Handle disk read error (optional)
    mov si, disk_error_msg
    call print_string
    jmp $

; Print a null-terminated string at the current cursor position
print_string:
    pusha
print_loop:
    lodsb           ; Load next character into AL
    cmp al, 0       ; Check if end of string (null character)
    je print_done
    mov ah, 0x0e    ; BIOS teletype output function
    int 0x10        ; BIOS video interrupt
    jmp print_loop
print_done:
    popa
    ret

; Set cursor position (DH=row, DL=column)
set_cursor_position:
    pusha
    mov ah, 0x02    ; BIOS set cursor position function
    xor bh, bh      ; Page number 0
    int 0x10        ; BIOS video interrupt
    popa
    ret

message db 'Boot Options', 0
message_1 db 13, 10, '1. Normal Mode', 0
message_2 db 13, 10, '2. Recovery Mode', 0
message_3 db 13, 10, 'Select Your Choice (1/2): ', 0

disk_error_msg db 'Disk read error!', 0

kernel_normal_segment equ 0x1000
kernel_recovery_segment equ 0x2000
num_sectors equ 1 ; Number of sectors to read (adjust as needed)

times 510-($-$$) db 0 ; Fill the rest of the sector with 0s
dw 0xaa55             ; Boot sector signature
