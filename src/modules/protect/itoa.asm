; 数値を出力する関数
itoa:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタの保存
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; 引数を取得
    mov eax, [ebp + 8]        ; value = 変換する数値
    mov esi, [ebp + 12]        ; dst = 保存先アドレス
    mov ecx, [ebp + 16]        ; size = 保存先バッファのサイズ
    
    mov edi, esi
    add edi, ecx              ; dst = &dst[size]
    dec edi                  ; dst--でデクリメント、dst[size-1]となる

    mov ebx, [ebp + 24]  ; flag = ビット定義のフラグ

    ; 符号付きの判定
    test bx, 0b0001         ; if(flags & 0x01) 0x01なら符号付き
.10Q:
    je .10E
    cmp eax, 0               ; if(val < 0) 負の場合は0x01でも強制的に負にする
.12Q:
    jge .12E
    or ebx, 0b0010           ; 負の場合には-付与のために0b0010をorで判定を強制に入れる
.12E:
.10E:

    ; 符号出力判定
    test ebx, 0b0010         ; if(flags & 0x02) 0x02なら符号を付ける
.20Q:
    je .20E
    cmp eax, 0               ; if(val < 0)
.22Q:
    jge .22F
    neg eax                  ; val *= -1; 符号を反転
    mov [esi], byte '-'      ; *dst = '-'; 負なので、マイナスを先頭アドレスに入れる
    jmp .22E
.22F:
    mov [esi], byte '+'      ; *dst = '+'; 正なので、プラスに移動
.22E:
    dec ecx                  ; size--; バッファサイズを引いておく
.20E:

    ; ASCII変換
    mov ebx, [ebp + 20]       ; radix = 基数、何進数かの設定
.30L:
    mov edx, 0               ; dx初期化
    div ebx                  ; divは基数を指定、16ビットの場合は
                            ; DX:剰余, AX:商となる.
    mov esi, edx              ; 剰余を移動
    mov dl, byte[.ascii + esi]  ; DL = .ascii[DX]という風に参照

    mov [edi], dl            ; *dst = DL; dstの右端に入れていく
    dec edi                  ; dst--;

    cmp eax, 0               ; while(AX) axは商なので、商がなくなるまで続く
    loopnz .30L
.30E:

    ; 空欄を埋める
    cmp ecx, 0               ; if(size == 0)
.40Q:
    je .40E
    mov al, ' '             ; 空白で埋める
    cmp [ebp+24], word 0b0100 ; if(flag & 0x04) 0x04なら0埋め
.42Q:
    jne .42E
    mov al, '0'             ; 0埋めに変更
.42E:
    std                     ; DF = 1
    rep stosb               ; while(--cx){*dst-- = al; }
.40E:

    ; レジスタの復帰
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

.ascii db       "0123456789ABCDEF"  ; 変換テーブル