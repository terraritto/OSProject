; 割り込みディスクリプタテーブルの初期化
ALIGN 4
IDTR: dw 8 * 256 - 1 ; リミット(サイズ)
      dd VECT_BASE ; アドレス

; 割り込みテーブルの初期化
init_int:
    push eax
    push ebx
    push ecx
    push edi

    lea eax, [int_default] ; 割り込み処理のアドレスをeaxに
    mov ebx, 0x0008_8E00 ; セグメントレジスタと各種設定
    xchg ax, bx ; 下位レジスタを入れ替えて、欲しい形に

    mov ecx, 256 ; 割り込みベクタの数
    mov edi, VECT_BASE ; 割り込みベクタのテーブル

.10L:
    mov [edi + 0], ebx ; 下位のデータ
    mov [edi + 4], eax ; 上位のデータ
    add edi, 8 ; アドレスずらし
    loop .10L ;256個初期化する

; 割り込みディスクリプタの登録
    lidt [IDTR] 

; レジスタの復帰
    pop edi
    pop ecx
    pop ebx
    pop eax

    ret

; デフォルトの割り込みテーブル
int_default:
    pushf           ; EFLAGS
    push cs         ; CS
    push int_stop   ; EIP

    mov eax, .s0
    iret

.s0: db " <    STOP    > ", 0

int_stop:
    sti ; 割り込みを許可するようにしておく

    ; EAXに入ってる割り込み種別を表示
    cdecl draw_str, 25, 15, 0x060F, eax

    ; スタックのデータを文字列に置換していく
    mov eax, [esp + 0] ; esp + 0 : EIP or ErrorCode
    cdecl itoa, eax, .p1, 8, 16, 0b0100

    mov eax, [esp + 4] ; esp + 4 : CS or EIP
    cdecl itoa, eax, .p2, 8, 16, 0b0100

    mov eax, [esp + 8] ; esp + 8 : EFLAGS or CS
    cdecl itoa, eax, .p3, 8, 16, 0b0100

    mov eax, [esp + 12] ; esp + 12 : - or EFLAGS
    cdecl itoa, eax, .p4, 8, 16, 0b0100

    ; 文字列を表示していく
    cdecl draw_str, 25, 16, 0x0F04, .s1
    cdecl draw_str, 25, 17, 0x0F04, .s2
    cdecl draw_str, 25, 18, 0x0F04, .s3
    cdecl draw_str, 25, 19, 0x0F04, .s4

    ; 無限ループ
    jmp $


.s1: db "ESP + 0:"
.p1: db "-------- ", 0
.s2: db "ESP + 4:"
.p2: db "-------- ", 0
.s3: db "ESP + 8:"
.p3: db "-------- ", 0
.s4: db "ESP +12:"
.p4: db "-------- ", 0

int_zero_div:
    pushf
    push cs
    push int_stop

    mov eax, .s0
    iret

.s0: db " <  ZERO DIV  > ", 0