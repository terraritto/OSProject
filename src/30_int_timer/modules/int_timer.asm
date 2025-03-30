int_timer:
    ; レジスタの保存
    pushad
    push ds
    push es

    ; データ用セグメントの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; Tick
    inc dword [TIMER_COUNT] ; タイマーを一つ進める

    ; 割り込み終了コマンド送信
    outp 0x20, 0x20 ; マスタPICのEOIコマンド送信

    ; レジスタの復帰
    pop es
    pop ds
    popad

    iret

ALIGN 4, db 0
TIMER_COUNT: dq 0