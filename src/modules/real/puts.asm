; 文字列を出力するだけの関数
puts:
    ; スタックフレームの構築
    push bp
    mov bp, sp ;すでにspには bp+2:戻り値, bp+4:出力文字となってる

    ; レジスタの保存
    push ax
    push bx
    push si
    
    ; 引数を取得
    mov si, [bp + 4]

    ; 処理を開始
    mov ah, 0x0E            ; 1文字出力
    mov bx, 0x0000          ; ページ番号,文字色を0に設定
    cld                     ; DF = 0
.10L:
    lodsb                   ; AL = *SI++ (DF=0なので)

    cmp al, 0               ; ALが0なら終わり
    je  .10E

    int 0x10                ; ビデオBIOSコール
    jmp .10L

.10E:
    ; レジスタの復帰
    pop si
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret