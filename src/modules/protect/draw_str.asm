draw_str:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push ebx
    push ecx
    push edx
    push esi

    ; コピー元フォントアドレスを設定
    mov ecx, [ebp + 8] ; 列
    mov edx, [ebp + 12] ; 行
    movzx ebx, word [ebp + 16] ; 表示色
    mov esi, [ebp + 20] ; 文字列のアドレス

    cld ; DF=0

.10L:
    lodsb   ; AL = ESI++ でアドレスをずらしつつ文字取得
    cmp al, 0 ; 最後の文字は0想定、0なら終了
    je .10E

    ; 描画！
    cdecl draw_char, ecx, edx, ebx, eax

    ; 次の文字へ
    inc ecx ; 列方向にずらす
    cmp ecx, 80 ; 80文字で判定
    jl .12E ; まだ列方向にずらせるなら次のループへ

    mov ecx, 0 ; 列方向が最初に戻る
    inc edx ; 行方向にずらす
    cmp edx, 30 ; 30行以上かの判定
    jl .12E ; まだ行方向にずらせるなら次のループへ
    mov edx, 0 ; 行方向が最初に戻る

.12E:
    jmp .10L

.10E:
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
