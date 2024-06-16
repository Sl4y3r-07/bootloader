[BITS 16]
[ORG 0x0000]  ; The offset within segment 0x1000 is 0x0000

start:
    ; Set up segments
    mov ax, 0x1000  ; Segment where the kernel is loaded
    mov ds, ax      ; Set DS to this segment
    mov es, ax      ; Set ES to this segment
    
    mov ah, 0x06    ; Scroll up function
    mov al, 0       ; Number of lines to scroll
    mov bh, 0x07    ; Display page
    mov cx, 0       ; Upper left corner (row 0, column 0)
    mov dx, 0x184F  ; Lower right corner (row 24, column 79)
    int 0x10   
    ; Read boot mode from memory
    mov ax, es:[0x200]  ; Boot mode is stored at address 0x0000
    cmp ax, 1
    je normal_mode
    cmp ax, 2
    je recovery_mode


    mov ah, 0x02    ; BIOS function to set cursor position
    mov bh, 0x00    ; Page number
    mov dx, 0x0000    ; Row (0)
    int 0x10        ; Call BIOS video interrupt
    mov si,unknown
    call print_string
    jmp done
    ; If boot mode is not recognized, halt
    cli
    hlt

normal_mode:
    ; Set cursor position to the start (top-left corner)
    mov ah, 0x02    ; BIOS function to set cursor position
    mov bh, 0x00    ; Page number
    mov dh, 0x00    ; Row (0)
    mov dl, 0x00    ; Column (0)
    int 0x10        ; Call BIOS video interrupt

    ; Print the normal mode message
    mov si, normal_mode_message
    call print_string
    jmp done

recovery_mode:
    ; Set cursor position to the start (top-left corner)
    mov ah, 0x02    ; BIOS function to set cursor position
    mov bh, 0x00    ; Page number
    mov dh, 0x00    ; Row (0)
    mov dl, 0x00    ; Column (0)
    int 0x10        ; Call BIOS video interrupt

    ; Print the recovery mode message
    mov si, recovery_mode_message
    call print_string
    jmp done

print_string:
    mov ah, 0x0E             ; BIOS teletype output function
.print_char:
    lodsb                    ; Load byte at address DS:SI into AL and increment SI
    or al, al                ; Check if end of string (null character)
    jz .done                 ; If zero (end of string), jump to .done
    int 0x10                 ; Call BIOS video interrupt
    jmp .print_char          ; Repeat for the next character
.done:
    ret

done:
    cli                      ; Disable interrupts
    hlt                      ; Halt the CPU

normal_mode_message db 'Normal Mode: Hi from Kernel', 0
recovery_mode_message db 'Recovery Mode: Hi from Kernel', 0
unknown db 'Dontknow',0
times 510 - ($ - $$) db 0
dw 0xAA55
