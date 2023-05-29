; Felipe Stolze Vazquez                     -- RA21233 
; Maria Aclice Ferreira Pereira             -- RA21249
; Maria Julia Hofstetter Trevisan Pereira   -- RA21250
; Informatica -- Cotuca -- 06/06/2023

STACK SEGMENT PARA STACK; C:\Users\user\Desktop\Cotuca\Tecnico\Assembly\space-invaders-tasm\space_invaders.asm
    DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
    naveX dw 0Ah
    naveY dw 0Ah
    
    msg db "DP Invaders!", 13, 10, '$'
    vidas db "VIDAS: ", 13, 10, '$'
    pontos db "PONTOS: ", 13, 10, '$'
    vidasNum db 3, '$'
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

        mov ah, 00h         ; set video mode
        mov al, 13h         ; 320x200 screen 
        int 10h             ; execute configuration

        ;write pixels on screen
        mov ah, 0ch
        mov al, 56  ; color purple 
        mov bh, 00h

        mov cx, naveX ; x = 160
        mov dx, naveY ; y = 100
        int 10h

        xor cx, cx
        xor dx, dx
        borderLR: 
            ;mov al, 56
            int 10h
            inc cx
            cmp cx, 319
            jne borderLR

        borderTB:
            ;mov al, 56
            int 10h
            inc dx
            cmp dx, 199
            jne borderTB

        borderRL:
            ;mov al, 56
            int 10h
            dec cx
            cmp cx, 0
            jne borderRL

        borderBT:
            ;mov al, 56
            int 10h
            dec dx
            cmp dx, 0
            jne borderBT

        square:
            mov cx, naveX
            mov dx, naveY
            mov al, 60
            int 10h
            mov al, 56
            inc cx
            int 10h
            inc dx
            int 10h
            dec cx
            int 10h
            dec cx
            int 10h
            dec dx
            int 10h
            dec dx
            int 10h
            inc cx
            int 10h
            inc cx
            int 10h

            call DRAW_UI


        ret
    MAIN ENDP


    DRAW_UI PROC NEAR
        mov ah, 02h
        mov bh, 00h
        mov dh, 04h
        mov dl, 06h
        int 10h

        mov ah, 09h 
        lea DX, msg
        int 21h
        ret
    DRAW_UI ENDP

CODE ENDS


END MAIN
```