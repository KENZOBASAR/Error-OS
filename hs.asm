[BITS 16]
[ORG 0x7C00]

start:
    ; Set video mode to 80x25 text mode
    mov ax, 0x03
    int 0x10

    ; Clear the screen
    mov si, clear_screen
    call print_string

    ; Print welcome message
    mov si, welcome_message
    call print_string

    ; Main loop to handle user input
main_loop:
    call get_input       ; Get user input
    ; Check commands
    mov si, input_buffer
    cmp byte [si], 'h'   ; Check if command is 'help'
    je show_help

    cmp byte [si], 'c'   ; Check if command is 'clear'
    je clear_screen_cmd

    cmp byte [si], 'a'   ; Check if command is 'about'
    je show_date

    cmp byte [si], 'e'   ; Check if command is 'echo'
    je echo_cmd

    cmp byte [si], 'x'   ; Check if command is 'exit'
    je exit_cmd

    ; Invalid command
    mov si, invalid_cmd
    call print_string
    jmp main_loop

show_help:
    mov si, help_message
    call print_string
    jmp main_loop

clear_screen_cmd:
    mov si, clear_screen
    call print_string
    jmp main_loop

show_date:
    ; Display a fixed date for demonstration purposes
    mov si, date_message
    call print_string
    jmp main_loop

echo_cmd:
    ; Echo everything after 'echo '
    mov si, input_buffer
    add si, 5            ; Skip the 'echo ' part
    mov di, si
    call print_string
    jmp main_loop

exit_cmd:
    ; Halt the system
    cli                 ; Clear interrupts
    hlt                 ; Halt the CPU

; Subroutine: print string
print_string:
    .print_loop:
        lodsb               ; Load byte at [SI] into AL
        or al, al           ; Check for null terminator
        jz .done            ; End if null
        mov ah, 0x0E        ; BIOS teletype output
        int 0x10            ; Print character
        jmp .print_loop
    .done:
        ret

; Subroutine: get user input
get_input:
    mov si, prompt
    call print_string     ; Print the prompt '> '

    xor di, di            ; Reset input buffer index
    .input_loop:
        xor ah, ah
        int 0x16           ; BIOS: get key press
        cmp al, 0x0D       ; Enter key
        je .end_input
        mov [input_buffer + di], al  ; Store character in input buffer
        mov ah, 0x0E       ; Echo character to screen
        int 0x10
        inc di
        jmp .input_loop
    .end_input:
        mov byte [input_buffer + di], 0  ; Null terminate string
        mov ah, 0x0E       ; Print newline
        mov al, 0x0D
        int 0x10
        mov al, 0x0A
        int 0x10
        ret

; Data
welcome_message db 'Welcome to Error OS', 0x0D, 0x0A, 0
prompt          db 'erroros.command.user$> ', 0
help_message    db 'Available commands: help, clear, echo, about, exit', 0x0D, 0x0A, 0
invalid_cmd     db 'Invalid command', 0x0D, 0x0A, 0
clear_screen    db '[ ERROR ]: Clear screen command cannot be executed!', 0x0D, 0x0A, 0
date_message    db 'Made by Kenzo Basar at 13/09/2024 08:28', 0x0D, 0x0A, 0

input_buffer    times 128 db 0   ; Buffer for user input

times 510-($-$$) db 0    ; Fill remaining space
dw 0xAA55                ; Boot sector signature
