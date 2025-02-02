int_default:
    ; ここの時点でEIP|CS|EFLAGS|ダミー
    pushf           ; EFLAGS
    push cs         ; CS
    push int_stop   ; EIP

    ; この段階だと EIP|CS|EFLAGS|EIP|CS|EFLAGS|ダミー

    mov eax, .s0
    iret

    ; この段階ではiretでpopされて
    ; EIP|CS|EFLAGS|ダミー となる
    ; そしてiretはアドレスに戻す、つまり入ってるint_stopの処理の先頭に行く

.s0: db " <    STOP    > ", 0

int_stop:
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