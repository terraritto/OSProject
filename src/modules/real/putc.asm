; 1文字を出力するだけの関数
putc:
    ; スタックフレームの構築
    push bp
    mov bp, sp ;すでにspには bp+2:戻り値, bp+4:出力文字となってる

    ; レジスタの保存
    push ax
    push bx

    ; 処理を開始
    mov al, [bp+4]          ; AL=出力文字
    mov ah, 0x0E            ; 1文字出力
    mov bx, 0x0000          ; ページ番号,文字色を0に設定
    int 0x10                ; ビデオBIOSコール

    ; レジスタの復帰
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret