org 0x7e00
bits 16

%define ENDL 0x0D,0x0A

jmp start

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7e00  

    push es
    push .after
    retf

.after:
    mov [ebr_drive_number], dl
    push es
    mov ah, 0x08
    int 0x13
    jc floppy_error
    pop es

    and cl, 0x3F
    xor ch, ch
    mov [bdb_sectors_per_track], cx

    inc dh
    mov [bdb_heads], dh

    ; Calculate LBA of root directory
    mov ax, [bdb_sectors_per_fat]
    mov bl, [bdb_fat_count]
    xor bh, bh
    mul bx
    add ax, [bdb_reserved_sectors]
    push ax

    ; Calculate size of root directory
    mov ax, [bdb_dir_entries_count]
    shl ax, 5  ;32 bytes per entry
    xor dx, dx
    div word [bdb_bytes_per_sector]
    test dx, dx
    jz .root_dir_after
    inc ax

.root_dir_after:
    mov cl, al
    pop ax
    mov dl, [ebr_drive_number]
    mov bx, buffer
    call disk_read

    ; Clear the screen
    mov ah, 0x06
    mov al, 0
    mov bh, 0x04
    mov cx, 0
    mov dx, 0x184F
    int 0x10

    ; Set cursor position
    mov dh, 0x01
    mov dl, 0x02
    call set_cursor_position

    ; Output boot menu message
    mov si, message_boot_menu
    call print_string              ; here i have only added Boot Menu to be printed but it will not be printed fully
                                   ; to check the issue, dont load the kernel.bin file in .img 

    ; Search for kernel.bin
    xor bx, bx
    mov di, buffer

.search_kernel:
    mov si, file_kernel_bin
    mov cx, 11
    push di
    repe cmpsb
    pop di
    je .found_kernel

    add di, 32
    inc bx
    cmp bx, [bdb_dir_entries_count]
    jl .search_kernel

    jmp kernel_not_found_error

.found_kernel:
    mov ax, [di + 26]
    mov [kernel_cluster], ax

    mov ax, [bdb_reserved_sectors]
    mov bx, buffer
    mov cl, [bdb_sectors_per_fat]
    mov dl, [ebr_drive_number]
    call disk_read

    ; Read kernel and process FAT chain
    mov bx, kernel_LOAD_SEGMENT
    mov es, bx
    mov bx, kernel_LOAD_OFFSET

.load_kernel_loop:
    ; Read next cluster
    mov ax, [kernel_cluster]
    add ax, 31

    mov cl, 1
    mov dl, [ebr_drive_number]
    call disk_read

    add bx, [bdb_bytes_per_sector]

    mov ax, [kernel_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx

    mov si, buffer
    add si, ax
    mov ax, [ds:si]

    or dx, dx
    jz .even

.odd:
    shr ax, 4
    jmp .next_cluster_after

.even:
    and ax, 0x0FFF

.next_cluster_after:
    cmp ax, 0x0FF8
    jae .read_finish

    mov [kernel_cluster], ax
    jmp .load_kernel_loop

.read_finish:
    ; Jump to kernel
    mov dl, [ebr_drive_number]
    mov ax, kernel_LOAD_SEGMENT
    mov ds, ax
    mov es, ax
    jmp kernel_LOAD_SEGMENT:kernel_LOAD_OFFSET

; Error handlers
floppy_error:
    mov si, msg_read_fail
    call print_string
    jmp err

kernel_not_found_error:
    mov si, msg_kernel_not_found
    call print_string
    jmp err

err:
    jmp $

; Print string to screen
print_string:
    mov ah, 0x0E             ; BIOS teletype function
.print_char:
    lodsb                    ; load next byte from string into AL
    cmp al, 0
    je .done                 ; 
    int 0x10                 ; BIOS video interrupt
    jmp .print_char
.done:
    ret

; Convert LBA to CHS
lba_to_chs:
    push ax
    push dx

    xor dx, dx
    div word [bdb_sectors_per_track]
    inc dx
    mov cx, dx

    xor dx, dx
    div word [bdb_heads]
    mov dh, dl
    mov ch, al
    shl ah, 06
    or cl, ah

    pop ax
    mov dl, al
    pop ax
    ret

; Read sectors from disk
disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx
    call lba_to_chs
    pop ax

    mov ah, 0x02
    mov di, 0x03

.retry:
    pusha
    stc
    int 013h
    jnc .done

    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    jmp floppy_error

.done:
    popa
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Reset disk
disk_reset:
    pusha
    mov ah, 0x00
    stc
    int 0x13
    jc floppy_error
    popa
    ret

; Set cursor position
set_cursor_position:
    pusha
    mov ah, 0x02
    xor bh, bh
    int 0x10
    popa
    ret
msg_boot:               db "Booting Up..", 0
msg_read_fail:          db "Read from disk failed", 0
msg_kernel_not_found:   db "KERNEL.BIN not found", 0
file_kernel_bin:        db "KERNEL  BIN"
kernel_cluster:         dw 0

kernel_LOAD_SEGMENT     equ 0x1000
kernel_LOAD_OFFSET      equ 0x0000

bdb_bytes_per_sector:               dw 512
bdb_sectors_per_cluster:            db 1
bdb_reserved_sectors:               dw 1 
bdb_fat_count:                      db 2
bdb_dir_entries_count:              dw 0E0h
bdb_total_sectors:                  dw 2880
bdb_sectors_per_fat:                dw 9
bdb_sectors_per_track:              dw 18
bdb_heads:                          dw 2
ebr_drive_number:                   db 0
                                    db 0

message_boot_menu:      db "Boot Menu:", ENDL
                        db "1. Normal Mode", ENDL
                        db "2. Recovery Mode", ENDL
                        db "Enter choice: ", 0
 
buffer:                 resb 512  