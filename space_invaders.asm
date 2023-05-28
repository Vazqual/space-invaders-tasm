; Felipe Stolze Vazquez                     -- RA21233 
; Maria Aclice Ferreira Pereira             -- RA21249
; Maria Julia Hofstetter Trevisan Pereira   -- RA21250
; Informatica -- Cotuca -- 06/06/2023

STACK SEGMENT PARA STACK
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
    SUB ax, ax                          ; clean ax register
    PUSH ax                             ; push to the stack the ax register
    mov ax, DATA                        ; save the contents of DATA segment to on ax register
    mov ds, ax 
    pop ax                              ; release top item from the stack and save it on ax register
    pop ax                              ; release top item from the stack and save it on ax register

        mov ah, 00h ; set video mode
        mov al, 13h ; 320x200 screen 
        int 10h     ; execute configuration

        ;write pixels on screen
        mov ah, 0ch
        mov bh, 00h
        mov cx, naveX ; x = 160
        mov dx, naveY ; y = 100
        mov al, 56  ; color purple 
        int 10h

        ret
    MAIN ENDP

CODE ENDS
END MAIN
```