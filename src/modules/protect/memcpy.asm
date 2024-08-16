memcpy:
                                ; bp+8: コピー先, bp+12:コピー元, bp+16:バイト数
    push        ebp             ; bp+4 戻り値
    mov         ebp,    esp     ; spにbpを合わせる
   
    push        ecx             ; ローカル変数で使用するレジスタを保存
    push        esi
    push        edi

    cld                         ; DF=0にする処理, DF=0だとmovsbで++,DF=1で--
    mov         edi, [ebp + 8]  ; EDI=コピー先
    mov         esi, [ebp + 12] ; ESI=コピー元
    mov         ecx, [ebp + 16] ; ECX=バイト数
    rep movsb                   ; while(CF != 0) { *EDI++ = *ESI++; CF--; }みたいな？

    pop edi                     ; レジスタを復帰
    pop esi
    pop ecx

    mov esp, ebp                ; スタックフレームの破棄
    pop ebp

    ret                         ; 呼び出し元に戻る