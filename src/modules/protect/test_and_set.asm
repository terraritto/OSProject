test_and_set:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタの保存
    push eax
    push ebx

    ; テストアンドセット
    mov eax, 0  ; local=0
    mov ebx, [ebp + 8] ; アドレス
    
.10L:
    lock bts [ebx], eax ; アドレスに1を書き込む
    jnc .10E ; 1が書き込めたかチェック

.12L:
    ; 1の書き込み失敗
    bt [ebx], eax ; 書き込みをしてみる
    jc .12L ; 書き込みテストが失敗したらまた.12Lへ

    jmp .10L ; 書き込みテストに成功したら書きこみができる状態
             ; また書き込みのテストに入る

.10E: ; 書き込み成功


; レジスタの復帰
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret
