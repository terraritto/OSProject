get_mem_info:
    ; レジスタの保存
    push eax
    push ebx
    push ecx
    push edx
    push si
    push di
    push bp
    
    ; 処理を開始,32bitに合わせておく
ALIGN 4, db 0
.b0:
    ; 1レコード分確保
    times E820_RECORD_SIZE db 0

    ; 前情報を表示しておく
    cdecl puts, .s0

    mov bp, 0           ; 行数
    mov ebx, 0          ; インデックス(初回は0でOK)

.10L:
    mov eax, 0x0000E820         ; 機能コードをeaxに
    mov ecx, E820_RECORD_SIZE   ; 要求バイト数=レコードサイズ
    mov edx, 'PAMS'             ; "SMAP"
    mov di, .b0                 ; BIOSが入力するアドレス
                                ; RECORD_SIZEで確保してるのでOK
    
    int 0x15                    ; 処理を開始

    ; コマンドに対応してるかの確認
    ; 対応してる場合は"SMAP"だが、そうでない場合は"PAMS"なのでx
    cmp eax, 'PAMS'
    je .12E
    jmp .10E

.12E:
    jnc .14E        ; エラーの場合はCFが1にセットされるので、
                    ; その場合もエラーに移る
    jmp .10E

.14E:
    ; 1レコード分のメモリ情報を表示
    cdecl put_mem_info, di

    ; ACPIデータのアドレスを取得
    mov eax, [di + 16]          ; EAX: レコードタイプだけ取得
    cmp eax, 3                  ; 3ならACPI
    jne .15E

    mov eax, [di + 0]           ; BASEアドレスを保存
    mov [ACPI_DATA.adr], eax

    mov eax, [di + 8]           ; Lengthを保存
    mov [ACPI_DATA.len], eax

.15E:
    cmp ebx, 0                  ; ここが0の場合は終了と同じ
    jz .16E

    inc bp                      ; 行数を+1する
    and bp, 0x07                ; andを取る、8の場合に0となる
    jnz .16E

    ; 中断処理
    cdecl puts, .s2             ; 中断メッセージ(カーソルを左端へ)

    mov ah, 0x10
    int 0x16                    ; 中断

    cdecl puts, .s3             ; 中断メッセージを消去(左端から埋める)

.16E:
    cmp ebx, 0                  ; まだ0でないならまた処理へ
    jne .10L

.10E:
    cdecl puts, .s1

    ; レジスタの復帰
    pop bp
    pop di
    pop si
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

    ; データ
.s0:    db " E820 Memory Map:", 0x0A, 0x0D
        db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:    db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:    db " <more...>", 0
.s3:    db 0x0D, "          ", 0x0D, 0

put_mem_info:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push bx
    push si
    
    ; 引数を取得
    mov si, [bp + 4]

    ; レコードを表示していく
    ; baseアドレスの表示(64bit)
    cdecl itoa, word[si + 6], .p2 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 4], .p2 + 4, 4, 16, 0b0100
    cdecl itoa, word[si + 2], .p3 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 0], .p3 + 4, 4, 16, 0b0100

    ; Lengthの表示(64bit)
    cdecl itoa, word[si + 14], .p4 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 12], .p4 + 4, 4, 16, 0b0100
    cdecl itoa, word[si + 10], .p5 + 0, 4, 16, 0b0100
    cdecl itoa, word[si +  8], .p5 + 4, 4, 16, 0b0100

    ; typeの表示(32bit)
    cdecl itoa, word[si + 18], .p6 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 16], .p6 + 4, 4, 16, 0b0100

    cdecl puts, .s1

    ; レコードタイプを文字で表示する対応
    mov bx, [si + 16]
    and bx, 0x07            ; Typeは0~5,上でやった通り3はACPI
    shl bx, 1               ; byteサイズに変換、2byteなので2倍
                            ; これで疑似的なindexを生成完了
    add bx, .t0             ; BX += .t0でアドレスを指定
    cdecl puts, word[bx]    ; 表示

    ; レジスタの復帰
    pop si
    pop bx

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret

; データ
.s1:        db " "
.p2:        db "ZZZZZZZZ_"
.p3:        db "ZZZZZZZZ "
.p4:        db "ZZZZZZZZ_"
.p5:        db "ZZZZZZZZ "
.p6:        db "ZZZZZZZZ", 0

.s4:        db " (Unknown)", 0x0A, 0x0D, 0
.s5:        db " (usable)", 0x0A, 0x0D, 0
.s6:        db " (reserved)", 0x0A, 0x0D, 0
.s7:        db " (ACPI data)", 0x0A, 0x0D, 0
.s8:        db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:        db " (bad memory)", 0x0A, 0x0D, 0

.t0:        dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4
