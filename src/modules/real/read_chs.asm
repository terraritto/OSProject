read_chs:
    ; スタックフレームの構築
    push bp
    mov bp, sp
    push 3      ; リトライ回数
    push 0      ; 読み込みセクタ数

    ; レジスタの保存
    push bx
    push cx
    push dx
    push es
    push si
    
    ; 処理を開始
    mov si, [bp+4]          ; SI = ドライブ構造体
                            ; 構造体の中身を取りたい場合は
                            ; si + struct.variable的な感じでokっぽい
    
    ; CXレジスタの指定
    ; CH = シリンダ, CL:上位2ビットがシリンダ、それ以外がセクタ
    mov ch, [si + drive.cyln + 0] ; シリンダの下位ビット(0なので、1Byte目)
    mov cl, [si + drive.cyln + 1] ; シリンダの上位ビット(1なので、2Byte目)
    shl cl, 6                     ; CL << 6;でシリンダを適正な位置に持ってく
    or  cl, [si + drive.sect]     ; CL |= セクタ番号

    ; セクタ読み込み
    mov dh, [si + drive.head]     ; DH = ヘッド番号
    mov dl, [si + 0]              ; DL = ドライブ番号
    mov ax, 0x0000                ; AX = 0x0000
    mov es, ax                    ; ES = 0x0000
                                  ; (これは特に使わないけどバッファアドレス表してるっぽい)
                                  ; (上位ビット？)
    mov bx, [bp + 8]              ; コピー先

.10L:
    mov ah, 0x02                  ; 読み込み命令
    mov al, [bp + 6]              ; セクタ数
    
    int 0x13
    jnc .11E                      ; 成功時に.11Eに飛ぶ

    mov al, 0                     ; 読み込みセクタ数は0
    jmp .10E                      ; 終了

.11E:
    cmp al, 0                     ; 読み込みセクタ数が0じゃない
    jne .10E                      ; セクタ数そのままで終了
    
    mov ax, 0                     ; AX:0にしておく
    dec word[bp - 2]             ; リトライ回数を減らしておく
    jnz .10L                      ; リトライ終了

.10E:
    mov ah, 0                     ; ah = 0で上位ビットは消しておく

    ; レジスタの復帰
    pop si
    pop es
    pop dx
    pop cx
    pop bx

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret