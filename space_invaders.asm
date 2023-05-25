; Felipe Stolze Vazquez                     -- RA21233 
; Maria Aclice Ferreira Pereira             -- RA21249
; Maria Julia Hofstetter Trevisan Pereira   -- RA21250
; Informatica -- Cotuca -- 06/06/2023
.MODEL small
.STACK 100h
.DATA
    msg db "DP Invaders!", 13, 10, '$'



.CODE

right PROC
    mov ah, 0ch
    inc cx
    inc dx
    mov al, 56

    

    ret
right ENDP


INICIO:
    ;set video mode
    ; 320x200 screen 
    mov ah, 00h
    mov al, 13h

    int 10h

    ;write pixels on screen
    mov ah, 0ch

    ; mov cx, 160 ; x = 160
    ; mov dx, 100 ; y = 100
    ; mov al, 56  ; color purple 
    ; int 10h

    mov cx, 0
    mov dx, 0
    borderLR: 
        mov al, 56
        int 10h
        inc cx
        cmp cx, 319
        jne borderLR

    borderTB:
        mov al, 56
        int 10h
        inc dx
        cmp dx, 199
        jne borderTB

    borderRL:
        mov al, 56
        int 10h
        dec cx
        cmp cx, 0
        jne borderRL

    borderBT:
        mov al, 56
        int 10h
        dec dx
        cmp dx, 0
        jne borderBT


    square:
        mov cx, 160
        mov dx, 100
        mov al, 56
        int 10h

        mov cx, 161
        mov dx, 100
        mov al, 56
        int 10h

        mov cx, 160
        mov dx, 101
        mov al, 56
        int 10h

        mov cx, 161
        mov dx, 101
        mov al, 56
        int 10h

    

    ;write text on screen
    mov ah, 00h 
    int 16h

    ;set video mode
    mov ah, 00
    mov al, 03h
    int 10h

    mov al, 0
    mov ah, 4ch
    int 21h

    
end inicio