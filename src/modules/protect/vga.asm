vga_set_read_plane:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push edx

    ; 読み込みプレーンの選択
    mov ah, [ebp + 8] ; 3:輝度, 2~0:RGB
    and ah, 0x03 ; 2桁目以降はマスクで消す
    mov al, 0x04 ; 読み込み指定
    mov dx, 0x03CE ; グラフィックス制御ポートの設定
    out dx, ax ; ポート出力

    ; レジスタ復帰
    pop edx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

vga_set_write_plane:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push edx

    ; 読み込みプレーンの選択
    mov ah, [ebp + 8] ; xxxxの4桁で指定
    and ah, 0x0F ; 4桁目以降はマスクで消す
    mov al, 0x02 ; 書き込み指定
    mov dx, 0x03C4 ; グラフィックス制御ポートの設定
    out dx, ax ; ポート出力

    ; レジスタ復帰
    pop edx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

vram_font_copy:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; マスクデータの作成
    mov esi, [ebp + 8] ; フォントアドレス
    mov edi, [ebp + 12] ; VRAMアドレス
    movzx eax, byte [ebp + 16] ; プレーン
    movzx ebx, word [ebp + 20] ; 描画する色

    ; 背景色とカラープレーンが一致->0xFF そうでないなら 0x00
    test bh, al ; 0なら1,それ以外なら0
    setz dh ; DH = test ? 0x01 : 0x00
    dec dh ; 0xFFと0x00に変換

    ; 前景色も同じように
    test bl, al
    setz dl
    dec dl ; dLに

    ; 16ドットフォントのコピー
    cld ; DF = 0に

    mov ecx, 16 ; 16を入れておく

.10L:
    ; フォントマスクを作成
    lodsb ; al=esi++;なので、フォントアドレスを入れつつ移動

    mov ah, al ; ah = ~alとしておく
    not ah

    ; 前景色
    and al, dl ; al = 前景色(DL) & フォント(al)

    test ebx, 0x0010 ; 透過モード？
    jz .11F 
    and ah, [edi] ; 透過モードの場合、 ah = !フォント(ah) & 現在値(EDI)
    jmp .11E

.11F:
    and ah, dh ; ah = !フォント(ah) & dh(背景色)

.11E:
    or al, ah ; al = 背景色 or 前景色
    mov [edi], al ; edi = alでプレーンに書き込む

    add edi, 80 ; 書き込み
    loop .10L ; 16bit分を書き込むまでループ

.10E: 
    ; レジスタ復帰
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
