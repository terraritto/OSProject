draw_time:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push ebx

    ; 時刻を取得
    mov eax, [ebp + 20]

    movzx ebx, al ; 秒を取得(下二桁)
    cdecl itoa, ebx, .sec, 2, 16, 0b0100

    mov bl, ah ; 分を取得(上二桁)
    cdecl itoa, ebx, .min, 2, 16, 0b0100

    shr eax, 16 ; 秒と分を右シフトで消し去る
    cdecl itoa, eax, .hour, 2, 16, 0b0100

    ; 描画！
    cdecl draw_str, dword[ebp + 8], dword[ebp + 12], dword[ebp + 16], .hour

    ; レジスタ復帰
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

    .hour: db "ZZ:"
    .min: db "ZZ:"
    .sec: db "ZZ", 0