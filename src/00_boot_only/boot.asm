; 何もせずbootするだけ
jmp     $   ; while(1)

; 9.2のブート用フラグ
times   510 - ($ - $$) db 0x00
db      0x55, 0xAA