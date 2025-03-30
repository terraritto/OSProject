int_keyboard:
    ; レジスタの保存
    pusha
    push ds
    push es

    ; データ用セグメントの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; KBCのバッファ読み取り
    in al, 0x60

    ; キーコードの保存
    cdecl ring_wr, _KEY_BUFF, eax ; EAXのデータを書き込んでいく

    ; 割り込み終了コマンド送信
    outp 0x20, 0x20 ; マスタPICのEOIコマンド送信

    ; レジスタの復帰
    pop es
    pop ds
    popa

    iret

; xxx_sizeはxxxの構造体のメモリをNASMが置き換えてくれる
ALIGN 4, db 0
_KEY_BUFF: times ring_buff_size db 0