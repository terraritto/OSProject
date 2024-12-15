draw_rect:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov eax, [ebp + 8] ; x0
    mov ebx, [ebp + 12] ; y0
    mov ecx, [ebp + 16] ; x1
    mov edx, [ebp + 20] ; y1
    mov esi, [ebp + 24] ; 色

    cmp eax, ecx ; x1 < x0
    jl .10E
    xchg eax, ecx ; x0の方が大きいなら入れ替える

.10E:
    cmp ebx, edx; y1 < y0
    jl .20E
    xchg ebx, edx ; y0の方が大きいなら入れ替える

.20E:
    cdecl draw_line, eax, ebx, ecx, ebx, esi ; 上
    cdecl draw_line, eax, ebx, eax, edx, esi ; 左

    dec edx ; 1ドット下げる
    cdecl draw_line, eax, edx, ecx, edx, esi ; 下

    dec ecx; 1ドット左
    cdecl draw_line, ecx, ebx, ecx, edx, esi ; 右

    ; レジスタ復帰
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret
