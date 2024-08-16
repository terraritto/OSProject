get_font_adr:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push ax
    push bx
    push si
    push es
    push bp
    
    ; 処理を開始
    mov si, [bp+4]          ; SI = フォントアドレスの格納先
    
    ; フォントアドレスの取得
    mov ax, 0x1130
    mov bh, 0x06
    int 10h

    ; フォントアドレスの保存
    mov [si + 0], es        ; dst[0]=セグメント
    mov [si + 2], bp        ; dst[1]=オフセット
    
    ; レジスタの復帰
    pop bp
    pop es
    pop si
    pop bx
    pop ax

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret