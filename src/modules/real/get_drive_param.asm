get_drive_param:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push bx
    push cx
    push es
    push si
    push di
    
    ; 処理を開始
    mov si, [bp+4]          ; SI = ドライブ構造体
    
    mov ax, 0               ; Disk Base Table Pointerの初期化
    mov es, ax              ; ES = 0
    mov di, ax              ; DI = 0

    mov ah, 8               ; 0x08: ドライブパラメータの取得
    mov dl, [si + drive.no] ; ドライブ番号を入れておく
    int 0x13                ; BIOSコール

.10Q:
    jc .10F

.10T:
    ; axにセクタ数
    mov al, cl              
    and ax, 0x3F            ; 0x3F->2^6なので、下位6bitが1の状態でand

    ; cxにシリンダ数を入れる
    shr cl, 6               ; 6bit右シフトさせる
                            ; 11111111 11000000 -> 11111111 00000011
    ror cx, 8               ; 8bit回転、これでシリンダになる
                            ; 11111111 00000011 -> 00000011 11111111
    inc cx                  ; 0開始なので1開始にする

    ; bxにヘッド数を入れる
    movzx bx, dh            ; dhコピーしつつ、上位ビットに0埋めしとく
    inc bx                  ; 0開始なので1開始にする

    ; データを詰める
    mov [si + drive.cyln], cx
    mov [si + drive.head], bx
    mov [si + drive.sect], ax

    jmp .10E

.10F:
    mov ax, 0               ; 失敗の場合はaxを0に

.10E:
    
    ; レジスタの復帰
    pop di
    pop si
    pop es
    pop cx
    pop bx

    ; スタックフレームを破棄
    mov sp, bp
    pop bp

    ret