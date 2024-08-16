    BOOT_LOAD equ 0x7c00 ; ブートプログラムのロード位置
    ORG BOOT_LOAD        ; ロードアドレスをアセンブラに指示

; マクロ
%include "../include/macro.asm"

entry:
    jmp     ipl   ; IPLにジャンプ

    ; BPB(BIOS Parameter Block)
    times 90 - ($ - $$) db 0x90

ipl:
    cli         ; 割り込みを禁止する

    mov ax, 0x0000 ; AXレジスタ(汎用)に0を設定

    ; 汎用レジスタを使用してCS以外のレジスタを0にする
    mov ds, ax     ; DSレジスタ
    mov es, ax     ; ESレジスタ
    mov ss, ax     ; SSレジスタ
    
    ; スタックポインタは0x7c00
    mov sp, BOOT_LOAD

    sti         ; 割り込みを許可する

    mov [BOOT.DRIVE], dl    ; ブートドライブを保存する

    ; 文字表示
    cdecl   puts, .s0

    cdecl reboot

    jmp     $   ; while(1)

.s0  db "Booting...", 0x0A, 0x0D, 0
.s1  db "--------", 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:
.DRIVE: dw 0

; モジュール
%include "../modules/real/puts.asm"
%include "../modules/real/itoa.asm"
%include "../modules/real/reboot.asm"

    ; 9.2のブート用フラグ
    times   510 - ($ - $$) db 0x00
    db      0x55, 0xAA