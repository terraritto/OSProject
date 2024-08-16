KBC_Data_Write:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push cx
    
    ; 処理を開始
    mov cx, 0

.10L:
    in al, 0x64     ; ステータスレジスタ情報を取得
    test al, 0x02   ; 0x02,つまりbit1が0なら書き込み可能
    loopnz .10L     ; --cxしつつ判定、cxが0まで戻ってたらタイムアウト

    cmp cx, 0
    jz .20E         ; タイムアウトなら.20Eへ

    mov al, [bp+4]  ; データ
    out 0x60, al    ; KBC内のデータポートへ入力

.20E:
    mov ax, cx      ; cx値をaxに渡しておく
    
    ; レジスタの復帰
    pop cx

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret

KBC_Data_Read:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push cx
    
    ; 処理を開始
    mov cx, 0

.10L:
    in al, 0x64     ; ステータスレジスタ情報を取得
    test al, 0x01   ; 0x01,つまりbit0が1なら書き込み可能
    loopz .10L      ; --cxしつつ判定、cxが0まで戻ってたらタイムアウト

    cmp cx, 0
    jz .20E         ; タイムアウトなら.20Eへ

    mov ah, 0x00    ; データ
    in al, 0x60     ; KBCのデータポートからデータを取ってくる

    mov di, [bp+4]  ; ptrを設定
    mov [di+0], ax  ; ptrにデータを入れる

.20E:
    mov ax, cx      ; cx値をaxに渡しておく
    
    ; レジスタの復帰
    pop cx

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret

KBC_Cmd_Write:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push cx
    
    ; 処理を開始
    mov cx, 0

.10L:
    in al, 0x64     ; ステータスレジスタ情報を取得
    test al, 0x02   ; 0x02,つまりbit1が0なら書き込み可能
    loopnz .10L     ; --cxしつつ判定、cxが0まで戻ってたらタイムアウト

    cmp cx, 0
    jz .20E         ; タイムアウトなら.20Eへ

    mov al, [bp+4]  ; データ
    out 0x64, al    ; KBC内のデータポートへコマンドを入力

.20E:
    mov ax, cx      ; cx値をaxに渡しておく
    
    ; レジスタの復帰
    pop cx

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret