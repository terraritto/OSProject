lba_chs:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push ax
    push bx
    push dx
    push si
    push di
    
    ; 処理を開始
    mov si, [bp+4]          ; SI = ドライブ構造体(ドライブパラメータ)
    mov di, [bp+6]          ; DI = ドライブ構造体(変換後のCHS保存)
    
    ; ヘッド数 * セクタ数
    mov al, [si + drive.head]
    mul byte [si + drive.sect]
    mov bx, ax

    ; C = LBA / (ヘッド数 * セクタ数)
    mov dx, 0
    mov ax, [bp + 8] ; LBA
    div bx

    ; Cを保存
    mov [di + drive.cyln], ax

    ; T(Hと同じ) = Cの余り / セクタ数
    mov ax, dx
    div byte [si + drive.sect]

    ; S = Tの余り + 1
    movzx dx, ah ; ahをコピー
    inc dx ; +1

    mov ah, 0x00 ; 余りの方は0にしてHのみにする

    ; HSを保存
    mov [di + drive.head], ax
    mov [di + drive.sect], dx

    ; レジスタの復帰
    pop di
    pop si
    pop dx
    pop bx
    pop ax

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret