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
