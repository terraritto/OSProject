memcpy:
                                ; bp+4: コピー先, bp+6:コピー元, bp+8:バイト数
    push        bp              ; bp+2 戻り値
    mov         bp,     sp      ; spにbpを合わせる
   
    push        cx              ; ローカル変数で使用するレジスタを保存
    push        si
    push        di

    cld                         ; DF=0にする処理, DF=0だとmovsbで++,DF=1で--
    mov         di, [bp + 4]    ; DI=コピー先
    mov         si, [bp + 6]    ; SI=コピー元
    mov         cx, [bp + 8]    ; cx=バイト数
    rep movsb                   ; while(CF != 0) { *DI++ = *SI++; CF--; }みたいな？

    pop di                      ; レジスタを復帰
    pop si
    pop cx

    mov sp, bp                  ; スタックフレームの破棄
    pop bp

    ret                         ; 呼び出し元に戻る