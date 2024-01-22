memcmp:
                                ; bp+4: アドレス0, bp+6:アドレス1, bp+8:バイト数
    push        bp              ; bp+2 戻り値
    mov         bp,     sp      ; spにbpを合わせる
   
    push        bx              ; ローカル変数で使用するレジスタを保存
    push        cx
    push        dx
    push        si
    push        di

    cld                         ; DF=0にする処理
    mov         si, [bp + 4]    ; SI=アドレス0
    mov         di, [bp + 6]    ; DI=アドレス1
    mov         cx, [bp + 8]    ; CX=バイト数

    repe cmpsb                  ; SIとDIを1バイトずつ比較, 0になるまで繰り返すが失敗したらそこで終わり
    jnz .10F                    ; 0じゃなかったら".10F"にジャンプ
    mov ax, 0                   ; 一致を返す
    jmp .10E
.10F:
    mov ax, -1                  ; 不一致を返す
.10E:
    pop di                      ; レジスタを復帰
    pop si
    pop dx
    pop cx
    pop bx

    mov sp, bp                  ; スタックフレームの破棄
    pop bp

    ret                         ; 呼び出し元に戻る