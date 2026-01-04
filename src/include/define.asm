BOOT_LOAD equ 0x7C00

BOOT_SIZE equ (1024 * 8)
SECT_SIZE equ (512)
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE)

BOOT_END equ (BOOT_LOAD + BOOT_SIZE)

E820_RECORD_SIZE equ 20

KERNEL_LOAD equ 0x0010_1000     ; カーネルは上位アドレスに配置
KERNEL_SIZE equ (1024 * 8)      ; カーネルのサイズ


KERNEL_SECT equ (KERNEL_SIZE / SECT_SIZE)

VECT_BASE equ 0x0010_0000   ; 割り込みディスクリプタのアドレス

; タスク関係
STACK_BASE equ 0x0010_3000 ; タスクのスタック領域の開始位置
STACK_SIZE equ 1024 ; 1タスクのスタックサイズ

SP_TASK_0 equ STACK_BASE + (STACK_SIZE * 1) ; タスク0のスタックポインタの初期値
SP_TASK_1 equ STACK_BASE + (STACK_SIZE * 2) ; タスク1のスタックポインタの初期値
SP_TASK_2 equ STACK_BASE + (STACK_SIZE * 3) ; タスク2のスタックポインタの初期値
SP_TASK_3 equ STACK_BASE + (STACK_SIZE * 4) ; タスク3のスタックポインタの初期値
SP_TASK_4 equ STACK_BASE + (STACK_SIZE * 5) ; タスク4のスタックポインタの初期値
SP_TASK_5 equ STACK_BASE + (STACK_SIZE * 6) ; タスク5のスタックポインタの初期値
SP_TASK_6 equ STACK_BASE + (STACK_SIZE * 7) ; タスク6のスタックポインタの初期値

PARAM_TASK_4 equ 0x0010_8000                ; 描画パラメータ:タスク4
PARAM_TASK_5 equ 0x0010_9000                ; 描画パラメータ:タスク5
PARAM_TASK_6 equ 0x0010_A000                ; 描画パラメータ:タスク6

CR3_BASE equ 0x0010_5000            ; ページ変換テーブル(タスク3用)
CR3_TASK_4 equ 0x0020_0000          ; ページ変換テーブル(タスク4用)
CR3_TASK_5 equ 0x0020_2000          ; ページ変換テーブル(タスク5用)
CR3_TASK_6 equ 0x0020_4000          ; ページ変換テーブル(タスク6用)