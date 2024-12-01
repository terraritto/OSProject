draw_color_bar:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; コピー元フォントアドレスを設定
    mov esi, [ebp + 8]      ; 列
    mov edi, [ebp + 12]     ; 行

    mov ecx, 0

.10L:
    cmp ecx, 16 ; 16回繰り返し
    jae .10E

    ; X方向
    mov eax, ecx    ; eaxにecxのものを入れる
    and eax, 0x01   ; 偶奇判定
    shl eax, 3      ; 偶数なら0の位置から、奇数なら8文字ずらした位置から
    add eax, esi    ; 起点の位置分を足す

    ; Y方向
    mov ebx, ecx
    shr ebx, 1      ; /2することで、2回に一回行が変わる
    add ebx, edi    ; 起点の位置分を足す

    ; 色を確定
    mov edx, ecx
    shl edx, 1      ; 色をずらしていくだけ
    mov edx, [.t0 + edx]

    ; 描画
    cdecl draw_str, eax, ebx, edx, .s0

    ; 次のところへジャンプ
    inc ecx
    jmp .10L

.10E:
    ; レジスタ復帰
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

.s0:    db '        ', 0
.t0     dw 0x0000, 0x0800
        dw 0x0100, 0x0900
        dw 0x0200, 0x0A00
        dw 0x0300, 0x0B00
        dw 0x0400, 0x0C00
        dw 0x0500, 0x0D00
        dw 0x0600, 0x0E00
        dw 0x0700, 0x0F00
