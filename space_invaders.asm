; Felipe Stolze Vazquez                     -- RA21233 
; Maria Aclice Ferreira Pereira             -- RA21249
; Maria Julia Hofstetter Trevisan Pereira   -- RA21250
; Informatica -- Cotuca -- 06/06/2023

STACK SEGMENT PARA STACK
    DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
    time_aux db 0   ; auxiliar variable to check time 
    score dw 0
    vidasNum dw 3

    ISRUNNING dw 0  ; 0 = false, 1 = true

    shipX dw 160    ; ship position on X axis
    shipY dw 150    ; ship position on Y axis
    shipH dw 5      ; ship height
    shipW dw 15     ; ship width
    shipVel dw 4h   ; ship velocity
    
    
    msg db "DP Invaders!", 13, 10, '$'
    play db "Press : [1] to play", 13, 10, '$'
    close db "Press : [2] to close", 13, 10, '$'
    vidas db "VIDAS: ", 13, 10, '$'
    pontos db "PONTOS: ", 13, 10, '$'

DATA ENDS


CODE SEGMENT PARA 'CODE'
    MAIN PROC FAR
    ASSUME CS:CODE,DS:DATA,SS:STACK     ; assume code, data and stack segments to respective registers 
    PUSH DS                             ; push to the stack the DS segment
    XOR ax, ax                          ; clean ax register
    PUSH ax                             ; push to the stack the ax register
    mov ax, DATA                        ; save the contents of DATA segment to on ax register
    mov ds, ax 
    pop ax                              ; release top item from the stack and save it on ax register
    pop ax                              ; release top item from the stack and save it on ax register

        call CLEAR_SCREEN
        call DRAW_UI


        CHECK_TIME:
            mov ah, 2Ch     ; get system time
            int 21h         ; ch = hour, cl = minutes, dh = seconds, dl = centiseconds

            cmp dl, time_aux
            je check_time
            mov time_aux, dl

            call READ_KEYBOARD
            call CLEAR_SCREEN
            call DRAW_UI
            call DRAW_SHIP

            jmp CHECK_TIME
        ret
    MAIN ENDP


    DRAW_SHIP PROC NEAR
        MOV CX, shipX
        MOV DX, shipY

        drawHorizontal:
            mov ah, 0ch
            mov al, 38h  ; color purple
            mov bh, 00h
            int 10h
            inc cx
            mov ax, cx
            sub ax, shipX
            cmp ax, shipW
            jng drawHorizontal
            mov cx, shipX
            inc dx
            mov ax, dx
            sub ax, shipY
            cmp ax, shipH
            jng drawHorizontal


        RET
    DRAW_SHIP ENDP

    DRAW_UI PROC NEAR

        xor cx, cx
        xor dx, dx
        borders:
            borderLR: 
                int 10h
                inc cx
                cmp cx, 319
                jne borderLR

            borderTB:
                int 10h
                inc dx
                cmp dx, 199
                jne borderTB

            borderRL:
                int 10h
                dec cx
                cmp cx, 0
                jne borderRL

            borderBT:
                int 10h
                dec dx
                cmp dx, 0
                jne borderBT


        mov ah, 02h
        mov bh, 00h
        mov dh, 04h
        mov dl, 06h
        int 10h
        mov ah, 09h 
        lea dx, play
        int 21h

        mov ah, 02h
        mov dh, 05h
        mov dl, 06h
        int 10h
        mov ah, 09h 
        lea dx, close
        int 21h


        ret
    DRAW_UI ENDP

    CLEAR_SCREEN PROC NEAR
        mov ah, 00h         ; set video mode
        mov al, 13h         ; 320x200 screen 
        int 10h             ; execute configuration
        mov ah, 0ch
        mov al, 56  ; color purple 
        mov bh, 00h
        mov bl, 00h
        int 10h
        ret
    CLEAR_SCREEN ENDP

    READ_KEYBOARD PROC NEAR
        mov ah, 01h
        int 16h
        jz BRIDGE       ; JZ cant connect to EXIT directly because it is too far,
                        ; so we use a bridge

        mov ah, 00h
        int 16h

        cmp al, 41h     ; A
        je MOVE_LEFT_FAST

        cmp al, 61h     ; a
        je MOVE_LEFT

        cmp al, 44h     ; D
        je MOVE_RIGHT_FAST

        cmp al, 64h     ; d
        je MOVE_RIGHT

        cmp al, 57h     ; W
        je MOVE_UP_FAST

        cmp al, 77h     ; w
        je MOVE_UP

        cmp al, 53h     ; S
        je MOVE_DOWN_FAST

        cmp al, 73h     ; s
        je MOVE_DOWN
        jmp EXIT


        BRIDGE:
            jmp EXIT        ; its ugly but it works

        MOVE_LEFT_FAST:
            mov ax, shipVel
            sub shipX, ax
            sub shipX, ax
            jmp EXIT

        MOVE_LEFT:
            mov ax, shipVel
            sub shipX, ax
            jmp EXIT


        MOVE_RIGHT_FAST:
            mov ax, shipVel
            add shipX, ax
            add shipX, ax
            jmp EXIT

        MOVE_RIGHT:
            mov ax, shipVel
            add shipX, ax
            jmp EXIT

        MOVE_UP_FAST:
            mov ax, shipVel
            sub shipY, ax
            sub shipY, ax
            jmp EXIT

        MOVE_UP:
            mov ax, shipVel
            sub shipY, ax
            jmp EXIT

        MOVE_DOWN_FAST:
            mov ax, shipVel
            add shipY, ax
            add shipY, ax
            jmp EXIT

        MOVE_DOWN:
            mov ax, shipVel
            add shipY, ax
            jmp EXIT

        EXIT:

        ret
    READ_KEYBOARD ENDP

CODE ENDS
END MAIN
```

