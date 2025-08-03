wait_tick:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタの保存
    push eax
    push ecx

    ; 待ち
    mov ecx, [ebp + 8] ; 待ちの回数
    mov eax, [TIMER_COUNT] ; 現在のタイマーカウント

.10L:
    cmp [TIMER_COUNT], eax ; 現在のタイマーカウントと保持したものを比較
    je .10L ; 変わってないならループ
    inc eax ; もし変わってるならタイマーカウントを++
    loop .10L ; ecx--して0になってるか判定,なってたらループしない

    ; レジスタの復帰
    pop ecx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret