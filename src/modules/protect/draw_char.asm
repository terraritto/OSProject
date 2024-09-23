draw_char:
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

    ; コピー元フォントアドレスを設定
    movzx esi, byte [ebp + 20] ; 文字を格納
    shl esi, 4 ; 32bitへ
    add esi, [FONT_ADR] ; アドレス位置を特定

    ; コピー先アドレスを取得
    mov edi, [ebp + 12] ; 行
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA0000] ; 行特定
    add edi, [ebp + 8] ; 列でずらす

    ; 1も自分のフォントを出力
    movzx ebx, word[ebp + 16] ; 色を出力

    cdecl vga_set_read_plane, 0x03 ; 書き込みプレーン(輝度)
    cdecl vga_set_write_plane, 0x08 ; 読み込みプレーン(輝度)
    cdecl vram_font_copy, esi, edi, 0x08, ebx ; フォント書き込み(輝度)

    cdecl vga_set_read_plane, 0x02 ; 書き込みプレーン(赤)
    cdecl vga_set_write_plane, 0x04 ; 読み込みプレーン(赤)
    cdecl vram_font_copy, esi, edi, 0x04, ebx ; フォント書き込み(赤)

    cdecl vga_set_read_plane, 0x01 ; 書き込みプレーン(緑)
    cdecl vga_set_write_plane, 0x02 ; 読み込みプレーン(緑)
    cdecl vram_font_copy, esi, edi, 0x02, ebx ; フォント書き込み(緑)

    cdecl vga_set_read_plane, 0x00 ; 書き込みプレーン(青)
    cdecl vga_set_write_plane, 0x01 ; 読み込みプレーン(青)
    cdecl vram_font_copy, esi, edi, 0x01, ebx ; フォント書き込み(青)


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
