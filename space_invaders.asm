; Felipe Stolze Vazquez                     -- RA21233 
; Maria Alice Ferreira Pereira             -- RA21249
; Maria Julia Hofstetter Trevisan Pereira   -- RA21250
; Informatica -- Cotuca -- 06/06/2023

STACK SEGMENT PARA STACK
    DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
    windowW dw 140h  ; window width
    windowH dw 0C8h     ; window height

    time_aux_centiseconds db 0   ; auxiliar variable to check centiseconds change  
    time_aux_seconds db 0        ; auxiliar variable to check seconds change
    score dw 0
    vidasNum dw 3

    shipX dw 160    ; ship position on X axis
    shipY dw 180    ; ship position on Y axis
    shipH dw 5      ; ship height
    shipW dw 15     ; ship width
    shipVel dw 4h   ; ship velocity
    
    bulletsX        dw 0, 0, 0, 0;, 0, 0, 0, 0   ; bullets position on X axis
    bulletsY        dw 0, 0, 0, 0;, 0, 0, 0, 0   ; bullets position on Y axis
    bulletsActive   dw 0, 0, 0, 0;, 0, 0, 0, 0   ; bullets active right now
    bulletsRN       dw 0      ; bullets active right now
    maxBullets      dw 4h     ; max amount of bullets
    bulletVel       DW 10

    invadersX       dw 40, 80, 120, 160, 200, 240, 280, 320; invaders position on X axis
    invadersY       db 20, 40, 60, 80, 100, 120, 140 ; invaders position on Y axis
    invadersH       dw 10     ; invaders height
    invadersW       dw 10     ; invaders width
    invadersVel     dw 1h     ; invaders velocity
    invadersRN      dw 77     ; invaders right now

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

            cmp dl, time_aux_centiseconds
            je check_time
            mov time_aux_centiseconds, dl

            call READ_KEYBOARD  ; checks keyboard input
            call CLEAR_SCREEN
            call DRAW_UI        ; borders, score, lives, etc
            call DRAW_SHIP      ; draws ship
            call MOVE_SHOTS     ; move shots
            call DRAW_INVADERS  ; 

            jmp CHECK_TIME
        ret
    MAIN ENDP


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
        ; mov ah, 09h 
        ; lea dx, play
        ; int 21h

        ; mov ah, 02h
        ; mov dh, 05h
        ; mov dl, 06h
        ; int 10h
        ; mov ah, 09h 
        ; lea dx, close
        ; int 21h


        ret
    DRAW_UI ENDP

    CLEAR_SCREEN PROC NEAR
        mov ah, 00h         ; set video mode
        mov al, 13h         ; 320x200 screen 
        int 10h             ; execute configuration
        mov ah, 0ch
        mov al, 38h  ; color purple 
        mov bh, 00h
        mov bl, 00h
        int 10h
        ret
    CLEAR_SCREEN ENDP

    DRAW_SHIP PROC NEAR

        MOV CX, shipX
        SUB CX, shipW
        MOV DX, shipY
        DRAW_HORIZONTAL_RIGHT:
            mov ah, 0ch
            mov al, 38h  ; color purple
            mov bh, 00h
            int 10h
            inc cx
            mov ax, cx
            sub ax, shipX
            mov bx, shipW
            cmp ax, bx 
            jng DRAW_HORIZONTAL_RIGHT

            mov cx, shipX
            sub cx, shipW
            inc dx
            mov ax, dx
            sub ax, shipY
            cmp ax, shipH
            jng DRAW_HORIZONTAL_RIGHT

        RET
    DRAW_SHIP ENDP

    DRAW_INVADERS PROC NEAR
        lea bx, invadersX
        lea si, invadersY
        xor di, di
        LINES:
            mov cx, [bx]
            mov dx, [si]
            mov ah, 0ch
            mov al, 38h  ; color purple
            xor bx, bx
            mov bh, 00h
            int 10h
            add di, 2
            
            lea bx, invadersX
            add bx, di
            cmp [bx], 320
            jl LINES

            lea bx, invadersX
            add si, 2
            xor di, di
            cmp [si], 140
            jl LINES

            


        ret
    DRAW_INVADERS ENDP
        
    MOVE_SHOTS PROC NEAR
    cmp bulletsRN, 0
    je MOVE_SHOTS_EXIT              ; if there are no bullets, exit
        xor si, si                  ; clears si register
        CHECK_BULLETS:              ; loop for checking valid bullets
            add bx, si
            add bx, si
            cmp [bx], 0
            jne EXIT_CHECK_BULLETS
            inc si
            cmp si, maxBullets
            jl CHECK_BULLETS
            jmp MOVE_SHOTS_EXIT
        ; si has the index of the active bullet  

        EXIT_CHECK_BULLETS:

        lea bx, bulletsY
        add bx, si
        add bx, si
        mov ax, bulletVel
        sub [bx], ax
        cmp [bx], 0
        jle OUT_OF_BOUNDS

        mov dx, [bx]
        lea bx, bulletsX
        add bx, si
        add bx, si
        mov cx, bulletsX 

        xor bx, bx
        mov ah, 0ch
        mov al, 28h  ; color red
        mov bh, 00h
        int 10h

        inc si
        cmp si, bulletsRN
        jle CHECK_BULLETS
        jmp MOVE_SHOTS_EXIT 

        OUT_OF_BOUNDS:
            lea bx, bulletsActive
            add bx, si
            add bx, si
            mov [bx], 0
            dec bulletsRN
            inc si
            cmp si, bulletsRN
            jl CHECK_BULLETS
            jmp MOVE_SHOTS_EXIT

        MOVE_SHOTS_EXIT:
        xor si, si
        ret
    MOVE_SHOTS ENDP
        
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
        je MOVE_LEFT_BRIDGE

        cmp al, 44h     ; D
        je MOVE_RIGHT_FAST_BRIDGE

        cmp al, 64h     ; d
        je MOVE_RIGHT_BRIDGE

        ; cmp al, 57h     ; W
        ; je MOVE_UP_FAST

        ; cmp al, 77h     ; w
        ; je MOVE_UP

        ; cmp al, 53h     ; S
        ; je MOVE_DOWN_FAST

        ; cmp al, 73h     ; s
        ; je MOVE_DOWN

        cmp al, 72h
        JE SHOOT
        jmp EXIT

        SHOOT:
            mov ax, maxBullets
            cmp bulletsRN, ax
            jge BRIDGE
            inc bulletsRN
            ; search first 0 value in bulletsActive
            lea bx, bulletsActive
            mov cx, 0
            search:
                cmp [bx], 0h
                je found
                inc bx
                inc bx
                inc cx
                cmp cx, 0Ah
                jne search
                jmp EXIT
            found:
            add cx, cx 
            lea bx, bulletsX
            mov si, cx
            add si, bx
            mov ax, shipX
            mov [si], ax
            lea bx, bulletsY
            mov si, cx
            add si, bx
            mov ax, shipY
            mov [si], ax
            lea bx, bulletsActive
            mov si, cx
            add si, bx
            mov [si], 01h

            jmp EXIT

        BRIDGE:
            jmp EXIT        ; its ugly but it works

        MOVE_LEFT_BRIDGE:
            jmp MOVE_LEFT

        MOVE_RIGHT_FAST_BRIDGE:
            jmp MOVE_RIGHT_FAST
        
        MOVE_RIGHT_BRIDGE:
            jmp MOVE_RIGHT

        MOVE_LEFT_FAST:

            mov ax, shipVel
            sub shipX, ax
            sub shipX, ax
            cmp shipX, 00h
            jg BRIDGE
            mov ax, shipVel
            add shipX, ax
            add shipX, ax
            jmp EXIT

        MOVE_LEFT:
            mov ax, shipVel
            sub shipX, ax
            cmp shipX, 00h
            jg BRIDGE
            mov ax, shipVel
            add shipX, ax
            jmp EXIT

        MOVE_RIGHT_FAST:
            mov ax, shipVel
            add shipX, ax
            add shipX, ax
            
            mov ax, windowW
            cmp shipX, ax
            jl EXIT

            mov ax, shipVel
            sub shipX, ax
            sub shipX, ax
            jmp EXIT

        MOVE_RIGHT:
            mov ax, shipVel
            add shipX, ax
            mov ax, windowW
            cmp shipX, ax
            jl EXIT
            mov ax, shipVel
            sub shipX, ax
            jmp EXIT

        ; MOVE_UP_FAST:
        ;     mov ax, shipVel
        ;     sub shipY, ax
        ;     sub shipY, ax
        ;     jmp EXIT

        ; MOVE_UP:
        ;     mov ax, shipVel
        ;     sub shipY, ax
        ;     jmp EXIT

        ; MOVE_DOWN_FAST:
        ;     mov ax, shipVel
        ;     add shipY, ax
        ;     add shipY, ax
        ;     jmp EXIT

        ; MOVE_DOWN:
        ;     mov ax, shipVel
        ;     add shipY, ax
        ;     jmp EXIT

        EXIT:

        ret
    READ_KEYBOARD ENDP

CODE ENDS
END MAIN
```

