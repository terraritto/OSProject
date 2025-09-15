task_3:
    ; 文字列の表示(タスク表示)
    cdecl draw_str, 63, 2, 0x07, .s0

    ; 初期値を設定(スタックに積む)
    fild dword [.c1000] ; 1000
    fldpi ; pi 1000
    fidiv dword [.c180] ; pi/180 1000
    fldpi ; pi pi/180 1000
    fadd st0, st0 ; 2pi pi/180 1000
    fldz ; theta=0 2pi pi/180 1000

.10L:
    fadd st0, st2 ; theta=theta+pi/180 2pi pi/180 1000
    fprem ; mod(theta) 2pi pi/180 1000, ST1のmodを取る
    fld st0 ; theta theta 2pi pi/180 1000
    fcos ; sin(theta) theta 2pi pi/180 1000
    fmul st0, st4 ; 1000*sin(theta) theta 2pi pi/180 1000, 整数化
    
    fbstp [.bcd] ; theta 2pi pi/180 1000, .bcdに整数を格納

    ; 値の表示を行う
    mov eax, [.bcd] ; eax = 1000 * sin(theta)
    mov ebx, eax ; ebx = 1000 * sin(theta)

    and eax, 0x0F0F ; 上位4ビットをマスク
    or eax, 0x3030 ; 0x30を設定して数字を文字列に変換

    shr ebx, 4 ; ebx >> 4
    and ebx, 0x0F0F ; 上位4ビットをマスク
    or ebx, 0x3030 ; こちらも文字列へ

    mov [.s2 + 0], bh ; 整数部
    mov [.s3 + 0], ah ; 小数1桁目
    mov [.s3 + 1], bl ; 小数2桁目
    mov [.s3 + 2], al ; 小数3桁目
    
    mov eax, 7  ; 7ビット目
    bt [.bcd + 9], eax ; 7ビット目を取ってくる
    jc .10F ; 0ならマイナスなので、10Fに飛ぶ

    ; +の場合
    mov [.s1 + 0], byte '+'
    jmp .10E

.10F:
    ; -の場合
    mov [.s1 + 0], byte '-'

.10E:
    ; 数値を描画
    cdecl draw_str, 72, 2, 0x07, .s1

    ; 待ち
    cdecl wait_tick, 10

    jmp .10L

; データ
ALIGN 4, db 0
.c1000: dd 1000
.c180: dd 180

.bcd: times 10 db 0x00

.s0: db "Task-3", 0
.s1: db "-"
.s2: db "0."
.s3: db "000", 0