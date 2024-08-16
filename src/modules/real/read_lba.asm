read_lba:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push si
    
    ; 処理を開始
    mov si, [bp+4]          ; SI = ドライブ情報
    
    ; LBA->CHS
    mov ax, [bp + 6]        ; LBA
    cdecl lba_chs, si, .chs, ax

    ; ドライブ番号のコピー
    mov al, [si + drive.no]
    mov [.chs + drive.no], al

    ; セクタ読み込み
    cdecl read_chs, .chs, word[bp + 8], word[bp + 10] ; +8:セクタ数,+10:読み出し先アドレス

    ; レジスタの復帰
    pop si

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret

ALIGN 2
.chs:   times drive_size db 0