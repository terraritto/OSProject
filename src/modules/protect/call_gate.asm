call_gate:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push ds
    push es

    ; データ用セグメントの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; 文字を表示
    mov eax, dword [ebp + 12] ; X
    mov ebx, dword [ebp + 16] ; Y
    mov ecx, dword [ebp + 20] ; 色
    mov edx, dword [ebp + 24] ; 文字
    cdecl draw_str, eax, ebx, ecx, edx ; 文字を表示

    ; レジスタ復帰
    pop es
    pop ds

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    retf 4 * 4 ; dwordの4が4つ分引数としてコピーされてるので、その調整
