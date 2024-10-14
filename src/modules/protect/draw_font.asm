draw_font:
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
    mov esi, [ebp + 8] ; 列
    mov edi, [ebp + 12] ; 行

    ; フォント一覧を表示していく
    mov ecx, 0

.10L:
    cmp ecx, 256 ; 256文字描画したら終了
    jae .10E

    ; X方向
    mov eax, ecx ; 現在の文字のindexをeaxに入れる
    and eax, 0x0F ; 00001111で16文字をループし続ける,
    add eax, esi ; 元の位置を足す

    ; Y方向
    mov ebx, ecx ; 現在の文字のindexをeax
    shr ebx, 4 ; 16で割った値が現在の列となる、17文字目で1行下に行く
    add ebx, edi ; 元の位置を足す

    ; 描画！
    cdecl draw_char, eax, ebx, 0x07, ecx

    ; 次の文字へ
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
