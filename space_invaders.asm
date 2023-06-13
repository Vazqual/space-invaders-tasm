; Felipe Stolze Vazquez                     -- RA21233 
; Maria Alice Ferreira Pereira              -- RA21249
; Maria Julia Hofstetter Trevisan Pereira   -- RA21250
; Informatica -- Cotuca -- 06/06/2023
;
; Data extendida para       13/06/2023

STACK SEGMENT PARA STACK
    DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
    RUNNING db 1h       ; 1 = running, 0 = stopped

    windowW dw 140h     ; window width
    windowH dw 0C8h     ; window height

    time_aux_centiseconds db 0   ; auxiliar variable to check centiseconds change  
    time_aux_seconds    db 0        ; auxiliar variable to check seconds change

    shipX dw 0A0h    ; ship position on X axis
    shipY dw 0B4h    ; ship position on Y axis
    shipH dw 5      ; ship height
    shipW dw 15     ; ship width
    shipVel dw 4h   ; ship velocity
    
    bulletsX        dw 0, 0, 0, 0, 0, 0, 0, 0;, 0;, 0, 0, 0, 0, 0, 0, 0   ; bullets position on X axis
    bulletsY        dw 0, 0, 0, 0, 0, 0, 0, 0;, 0;, 0, 0, 0, 0, 0, 0, 0   ; bullets position on Y axis
    bulletVel       DW 5h       ; bullet velocity
    bulletsRN       dw 0h       ; bullets active right now
    maxBullets      dw 8h       ; max amount of bullets

    invadersX           dw  40, 100, 160, 220,  40, 100, 160, 220,  40, 100, 160, 220,  40, 100, 160, 220   ; invaders position on X axis
    invadersY           dw  20,  20,  20,  20,  45,  45,  45,  45,  70,  70,  70,  70,  95,  95,  95,  95
    invadersPadding     dw 0Fh      ; invaders height
    invadersVel         dw 1h       ; invaders velocity
    invadersRN          dw 10h      ; 16d invaders right now
    maxInvaders         dw 10h      ; max amount of invaders
    invadersDir         dw  0h      ; 0 = right, 1 = down, 2 = left
    invadersPos         dw  0h      ; auxilary variable to check invaders position
    
    msgWin db "VOCE VENCEU O DP INVADERS!!!", 13, 10, '$'
    msgLost db "VOCE PERDEU O DP INVADERS!!!", 13, 10, '$'

    credits db "CREDITOS", 13, 10, '$'
    creditsFSV db "FELIPE STOLZE VAZQUEZ", 13, 10, '$'
    creditsMAFP db "MARIA ALICE FERREIRA PEREIRA", 13, 10, '$'
    creditsMJHTP db "MARIA JULIA HOFSTETTER TREVISAN PEREIRA", 13, 10, '$'

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
            je CHECK_TIME
            mov time_aux_centiseconds, dl

            call READ_KEYBOARD      ; checks keyboard input
            call CLEAR_SCREEN
            call DRAW_UI            ; borders 
            call DRAW_SHIP          ; draws ship
            call MOVE_SHOTS         ; move shots
            call MOVE_INVADERS      ; move invaders
            call CHECK_COLLISIONS   ; checks for any dead invader
            call DRAW_INVADERS

            cmp RUNNING, 0
            je LOST

            cmp invadersRN, 0
            jne CHECK_TIME

            call WINNER
            jmp CHECK_TIME


            LOST:
                mov ah, 02h
                mov bh, 00h 
                mov dh, 08h ; set row 
                mov dl, 6h ; set column
                int 10h

                mov ah, 09h
                lea dx, msgLost  
                int 21h

                mov ah, 4ch
                int 21h


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

        MOV CX, shipX       ; cx will hold the X value on screen
        SUB CX, shipW
        MOV DX, shipY       ; dx will hold the Y value on screen
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

            ; cx and dx need to have the right values here
            jng DRAW_HORIZONTAL_RIGHT

        RET
    DRAW_SHIP ENDP

    MOVE_INVADERS PROC NEAR
        cmp invadersRN, 0       ; if there are no invaders, exit
        je B_MOVE_INVADERS_EXIT
        lea bx, invadersX
        xor si, si      ; clears index
        START_LOOKING:
        cmp invadersDir, 0      ; if invaders are moving right
        je MOVE_DIR_RIGHT
        cmp invadersDir, 1      ; if invaders are moving down
        je MOVE_DIR_DOWN
        cmp invadersDir, 2      ; if invaders are moving left
        je MOVE_DIR_LEFT

        MOVE_DIR_RIGHT:
            cmp [bx], 0
            je B_NEXT_ALIEN
            mov ax, [bx]
            add ax, invadersVel
            mov [bx], ax
            inc si
            add bx, 2
            cmp invadersPos, 60
            je B_CHANGE_DIR_DOWN
            cmp si, maxInvaders
            jl MOVE_DIR_RIGHT
            jmp MOVE_INVADERS_EXIT

        MOVE_DIR_DOWN:
            lea bx, invadersY
            xor si, si
            jmp MOVE_INVADERS_DOWN
            NEXT_INVADER_DOWN:
                add bx, 2
                inc si
                cmp si, maxInvaders
                jl MOVE_INVADERS_DOWN
                jmp MOVE_INVADERS_EXIT
            MOVE_INVADERS_DOWN:
                cmp [bx], 0
                je NEXT_INVADER_DOWN
                mov ax, [bx]
                add ax, invadersVel
                mov [bx], ax
                inc si
                add bx, 2
                mov ax, shipY
                cmp [bx], ax
                jge GAME_OVER
                cmp invadersPos, 11
                je CHANGE_DIR_LEFT
                cmp si, maxInvaders
                jl MOVE_INVADERS_DOWN

            jmp MOVE_INVADERS_EXIT

            B_MOVE_INVADERS_EXIT:
                jmp MOVE_INVADERS_EXIT

            B_CHANGE_DIR_DOWN:
                jmp CHANGE_DIR_DOWN

            B_NEXT_ALIEN:
                jmp NEXT_ALIEN

        MOVE_DIR_LEFT:
            cmp [bx], 0
            je NEXT_ALIEN
            mov ax, [bx]
            sub ax, invadersVel
            mov [bx], ax
            inc si
            add bx, 2
            cmp invadersPos, 60
            je CHANGE_DIR_RIGHT
            cmp si, maxInvaders
            jl MOVE_DIR_LEFT
            jmp MOVE_INVADERS_EXIT


            NEXT_ALIEN:
                add bx, 2
                inc si
                cmp si, maxInvaders
                jmp START_LOOKING

        CHANGE_DIR_RIGHT:
            mov invadersDir, 0
            mov invadersPos, 0
            jmp MOVE_INVADERS_EXIT

        CHANGE_DIR_DOWN:
            mov invadersDir, 1
            mov invadersPos, 0
            jmp MOVE_INVADERS_EXIT

        CHANGE_DIR_LEFT:
            mov invadersDir, 2
            mov invadersPos, 0
            jmp MOVE_INVADERS_EXIT

        MOVE_INVADERS_EXIT:
        inc invadersPos
        ret

        GAME_OVER:
            mov RUNNING, 0

        ret
    MOVE_INVADERS ENDP

    DRAW_INVADERS PROC NEAR
        xor si, si
        SEARCH_INVADERS:
            lea bx, invadersY
            add bx, si
            add bx, si
            cmp [bx], 0
            je SKIP_INVADER
            
            lea bx, invadersY
            add bx, si
            add bx, si
            mov dx, [bx]
            lea bx, invadersX
            add bx, si
            add bx, si
            mov cx, [bx]
            mov ax, si   ; makes the invaders colors change
            add al, 3Dh  
            mov ah, 0ch
            mov bh, 00h
            int 10h

            sub dx, 5h
            sub cx, 5h
            int 10h 
            add cx, 5h
            int 10h
            add cx, 5h
            int 10h
            add dx, 0Ah
            int 10h            
            sub cx, 0Ah
            int 10h


            SKIP_INVADER:
            inc si
            cmp si, maxInvaders
            jl SEARCH_INVADERS

        


        ret
    DRAW_INVADERS ENDP
        
    MOVE_SHOTS PROC NEAR
        cmp bulletsRN, 0
        je MOVE_SHOTS_EXIT              ; if there are no bullets, exit
        lea bx, bulletsY
        xor si, si                  ; clears si register, that we will use as index
                                    ; for checking the bullets
        CHECK_BULLETS:              ; loop for checking valid bullets
            lea bx, bulletsY        ; positions bx to the start of bulletsY
            add bx, si
            add bx, si              ; positions bx to the right bullet
            cmp [bx], 0             ; checks if the bullet is active
            jne EXIT_CHECK_BULLETS  ; if it is, exit the loop
            inc si               ; if not, check the next bullet
                                    ; (we sum 2 because we store bulletY in a word array)
            cmp si, maxBullets      
            jl CHECK_BULLETS
            jmp MOVE_SHOTS_EXIT
        ; si has the index of the active bullet  

        EXIT_CHECK_BULLETS:

        mov ax, bulletVel
        sub [bx], ax
        mov ax, [bx]
        cmp ax, 0
        jle OUT_OF_BOUNDS

        lea bx, bulletsY
        add bx, si
        add bx, si
        mov dx, [bx]
        lea bx, bulletsX
        add bx, si
        add bx, si
        mov cx, [bx] 

        xor bx, bx
        mov ah, 0ch
        mov al, 28h  ; color red
        mov bh, 00h
        int 10h

        inc si
        cmp si, maxBullets
        jl CHECK_BULLETS
        jmp MOVE_SHOTS_EXIT 

        OUT_OF_BOUNDS:
            lea bx, bulletsY
            add bx, si
            add bx, si
            mov [bx], 0
            lea bx, bulletsX
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
        xor bx, bx
        xor ax, ax
        xor dx, dx
        ret
    MOVE_SHOTS ENDP

    CHECK_COLLISIONS PROC NEAR
        lea ax, bulletsRN
        cmp ax, 0           ; if there are no bullets
        je B_EXIT_CHECK_COLLISIONS  ; exit
        lea bx, bulletsY
        xor si, si
        xor dx, dx
        SEARCH_BULLETS:     ; finds a bullet
            cmp si, maxBullets
            je B_EXIT_CHECK_COLLISIONS
            cmp [bx], 0h
            jne VALID_BULLET
            add bx, 2
            inc si
            jmp SEARCH_BULLETS
        
        VALID_BULLET:
        
        xor di, di
        CHECK_INVADERS:
            lea bx, bulletsY
            add bx, si
            add bx, si
            push bx         ; saves the y value of the bullet
            
            lea ax, invadersY
            add ax, di
            add ax, di
            mov bx, ax
            mov cx, [bx]
            sub cx, invadersPadding ; invader isnt just a point in space
                                    ; it has width and height
            pop bx
            cmp [bx], cx        ; if bullet is above invader
            jl B_NEXT           ; not valid, next invader
            push bx             ; resaves the y value of the bullet
            
            lea ax, invadersY   
            add ax, di
            add ax, di
            mov bx, ax
            mov cx, [bx]
            sub cx, invadersPadding

            pop bx
            cmp [bx], cx    ; if bullet is below invader
            jg NEXT         ; not valid, next invader

            lea bx, bulletsX
            add bx, si  
            add bx, si
            push bx         ; saves the x value of the bullet

            lea ax, invadersX
            add ax, di
            add ax, di
            mov bx, ax
            mov cx, [bx]
            sub cx, invadersPadding
            jmp continue1

B_CHECK_INVADERS:
    jmp CHECK_INVADERS

B_NEXT:
    jmp NEXT

B_EXIT_CHECK_COLLISIONS:
    jmp EXIT_CHECK_COLLISIONS

            continue1:
            pop bx
            cmp [bx], cx        ; if bullet is to the left of invader
            jl NEXT             ; not valid, next invader
            lea ax, invadersX   
            add ax, di
            add ax, di
            push bx
            mov bx, ax
            mov cx, [bx]
            add cx, invadersPadding
            pop bx
            cmp [bx], cx        ; if bullet is to the right of invader
            jg NEXT             ; not valid, next invader
        


        IMPACT:
            lea bx, invadersY   
            add bx, di
            add bx, di
            mov [bx], 0
            lea bx, invadersX
            add bx, di
            add bx, di
            mov [bx], 0
            dec invadersRN

            lea bx, bulletsY
            add bx, si
            add bx, si
            mov [bx], 0
            lea bx, bulletsX
            add bx, si
            add bx, si
            mov [bx], 0
            dec bulletsRN
        jmp NEXT_BULLET

            

        NEXT:

        NEXT_INVADER:
            inc di
            cmp di, maxInvaders
            jl B_CHECK_INVADERS

        NEXT_BULLET:

            cmp si, maxBullets
            je EXIT_CHECK_COLLISIONS
            inc si
            lea bx, bulletsY
            add bx, si
            add bx, si
            jmp SEARCH_BULLETS

        EXIT_CHECK_COLLISIONS:
        ret
    CHECK_COLLISIONS ENDP

    READ_KEYBOARD PROC NEAR
        mov ah, 01h
        int 16h
        jz BRIDGE       ; JZ cant connect to EXIT directly because it is too far,
                        ; so we use a bridge

        mov ah, 00h
        int 16h

        cmp al, 'A'     ; A
        je MOVE_LEFT_FAST

        cmp al, 'a'     ; a
        je MOVE_LEFT_BRIDGE

        cmp al, 'D'     ; D
        je MOVE_RIGHT_FAST_BRIDGE

        cmp al, 'd'     ; d
        je MOVE_RIGHT_BRIDGE

        ; cmp al, 57h     ; W
        ; je MOVE_UP_FAST

        ; cmp al, 77h     ; w
        ; je MOVE_UP

        ; cmp al, 53h     ; S
        ; je MOVE_DOWN_FAST

        ; cmp al, 73h     ; s
        ; je MOVE_DOWN

        cmp al, 'p'
        JE SHOOT
        jmp EXIT

        SHOOT:
            mov bx, bulletsRN       ; amount of bullets on screen
            cmp bx, maxBullets 
            jge BRIDGE

            inc bulletsRN
            ; search first 0 value in bulletsActive
            lea bx, bulletsY
            xor cx, cx      ; index of search
            search:         ; search for a free bullet  
                cmp cx, maxBullets
                je BRIDGE       ; cant exit directly so we use the bridge
                cmp [bx], 0h    ; if bullet is not active,
                je found        ; we found a free bullet
                add bx, 2       ; else, we check the next bullet
                inc cx          ; and increment the index
                jmp search

            found:
            lea bx, bulletsX 
            add bx, cx 
            add bx, cx      ; now [bx] has the value of the x position of the bullet
            mov ax, shipX
            mov [bx], ax    ; we atribute a value to the x position of the bullet
            lea bx, bulletsY
            add bx, cx
            add bx, cx      ; now [bx] has the value of the y position of the bullet
            mov ax, shipY   
            mov [bx], ax    ; we atribute a value to the y position of the bullet

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
            
            xor ax, ax
            xor bx, bx
            xor cx, cx
            xor dx, dx

        ret
    READ_KEYBOARD ENDP

    WINNER PROC NEAR
            mov ah, 02h
            mov bh, 00h 
            mov dh, 08h ; set row 
            mov dl, 6h ; set column
            int 10h

            mov ah, 09h
            lea dx, msgWin  
            int 21h

            mov ah, 02h
            mov bh, 00h
            mov dh, 0Ah ; set row
            mov dl, 10h ; set column
            int 10h

            mov ah, 09h
            lea dx, credits
            int 21h

            mov ah, 02h
            mov bh, 00h
            mov dh, 0Ch ; set row
            mov dl, 9h ; set column
            int 10h

            mov ah, 09h
            lea dx, creditsFSV
            int 21h

            mov ah, 02h
            mov bh, 00h
            mov dh, 0Dh ; set row
            mov dl, 6h ; set column
            int 10h
            
            mov ah, 09h
            lea dx, creditsMAFP
            int 21h

            mov ah, 02h
            mov bh, 00h
            mov dh, 0Eh ; set row
            mov dl, 01h ; set column
            int 10h

            mov ah, 09h
            lea dx, creditsMJHTP
            int 21h

        ret
    WINNER ENDP
CODE ENDS
END MAIN
```


