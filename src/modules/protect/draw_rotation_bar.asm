draw_rotation_bar:
    ; レジスタを保存
    push eax

    ; 周期的にテーブルを回転
    mov eax, [TIMER_COUNT] ; 割り込みカウンタ
    shr eax, 4 ; 16で割る,つまり160ms毎に変わる
    cmp eax, [.index] ; 前回と違う？
    je .10E

    ; 違う場合
    mov [.index], eax ; indexを更新
    and eax, 0x03 ; 0~3に限定させる

    mov al, [.table + eax] ; テーブルから参照
    cdecl draw_char, 0, 29, 0x000F, eax

.10E:
    ; レジスタ復帰
    pop eax

    ret

ALIGN 4, db 0
.index: dd 0
.table: db "|/-\"