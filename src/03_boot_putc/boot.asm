    BOOT_LOAD equ 0x7c00 ; ブートプログラムのロード位置
    ORG BOOT_LOAD        ; ロードアドレスをアセンブラに指示

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

    mov al, 'A'             ; AL=出力文字
    mov ah, 0x0E            ; 1文字出力
    mov bx, 0x0000          ; ページ番号,文字色を0に設定
    int 0x10                ; ビデオBIOSコール

    jmp     $   ; while(1)

ALIGN 2, db 0
BOOT:
.DRIVE: dw 0

    ; 9.2のブート用フラグ
    times   510 - ($ - $$) db 0x00
    db      0x55, 0xAA