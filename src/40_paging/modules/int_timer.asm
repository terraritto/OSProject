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

    ; タスク切り替え
    str ax ; 現在のタスクレジスタ
    cmp ax, SS_TASK_0
    je .11L
    cmp ax, SS_TASK_1
    je .12L
    cmp ax, SS_TASK_2
    je .13L

    jmp SS_TASK_0:0 ; TASK0へ
    jmp .10E

.11L:
    jmp SS_TASK_1:0 ; TASK1へ
    jmp .10E

.12L:
    jmp SS_TASK_2:0 ; TASK2へ
    jmp .10E

.13L:
    jmp SS_TASK_3:0 ; TASK3へ
    jmp .10E

.10E:
    ; レジスタの復帰
    pop es
    pop ds
    popad

    iret

ALIGN 4, db 0
TIMER_COUNT: dq 0