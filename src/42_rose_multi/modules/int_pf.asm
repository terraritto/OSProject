int_pf:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタの保存
    pusha
    push ds
    push es

    ; 例外を生成したアドレスの確認
    mov eax, cr2    ; CR2レジスタからアドレスが得られる
    and eax, ~0x0FFF ; 下位12ビットを0に
    cmp eax, 0x0010_7000 ; アドレスが0x0010_07000になってる？
    jne .10F

    mov [0x0010_6000 + 0x107 * 4], dword 0x00107007 ; 7でページ有効化
    cdecl memcpy, 0x0010_7000, DRAM_PARAM, rose_size ; 描画パラメータを用意

    jmp .10E

.10F:
    ; スタックの調整
    add esp, 4  ; pop es
    add esp, 4  ; pop ds
    popa
    pop ebp

    ; タスクの終了処理
    pushf           ; eflags
    push cs         ; cs
    push int_stop   ; スタック表示

    mov eax, .s0    ; 割り込み種別
    iret

.10E:
    ; レジスタの復帰
    pop es
    pop ds
    popa

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ; エラーコードの破棄
    add esp, 4
    iret

.s0     db " < PAGE FAULT > ", 0