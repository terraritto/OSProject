draw_pixel:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push eax
    push ebx
    push ecx
    push edi

    ; 80倍してHeight方向の行を特定
    mov edi, [ebp + 12]      ; Y
    shl edi, 4  ; 16倍
    lea edi, [edi * 4 + edi + 0xA_0000] ; 16 * 4 + 16 = 80倍した位置のアドレス

    ; Width方向の位置を特定(各文字の先頭単位なので、完全な位置ではない)
    mov ebx, [ebp + 8] ; X
    mov ecx, ebx ; ECXにXを保存
    shr ebx, 3 ; 8で割る
    add edi, ebx ; EDIの値に足して、EDIをYだけでなくXも整える

    ; 8で割った余りでX方向の位置を完全に特定
    and ecx, 0x07 ; 00000111でマスクすることで、8で割った余りを実現
    mov ebx, 0x80 ; EBX=0x80 (= 1000 0000)
    shr ebx, cl   ; EBX >> ECX,つまり桁をずらす
    ; イメージとしては2桁目の場合は(= 0010 0000)のようにビットで位置を特定できる

    ; 色を読み出し
    mov ecx, [ebp + 16]

    ; 出力(bit単位)
    cdecl vga_set_read_plane, 0x03 ; 書き込みプレーン(輝度)
    cdecl vga_set_write_plane, 0x08 ; 読み込みプレーン(輝度)
    cdecl vram_bit_copy, ebx, edi, 0x08, ecx ; フォント書き込み(輝度)

    cdecl vga_set_read_plane, 0x02 ; 書き込みプレーン(赤)
    cdecl vga_set_write_plane, 0x04 ; 読み込みプレーン(赤)
    cdecl vram_bit_copy, ebx, edi, 0x04, ecx ; フォント書き込み(赤)

    cdecl vga_set_read_plane, 0x01 ; 書き込みプレーン(緑)
    cdecl vga_set_write_plane, 0x02 ; 読み込みプレーン(緑)
    cdecl vram_bit_copy, ebx, edi, 0x02, ecx ; フォント書き込み(緑)

    cdecl vga_set_read_plane, 0x00 ; 書き込みプレーン(青)
    cdecl vga_set_write_plane, 0x01 ; 読み込みプレーン(青)
    cdecl vram_bit_copy, ebx, edi, 0x01, ecx ; フォント書き込み(青)


.10E:
    ; レジスタ復帰
    pop edi
    pop ecx
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

.s0:    db '        ', 0
.t0     dw 0x0000, 0x0800
        dw 0x0100, 0x0900
        dw 0x0200, 0x0A00
        dw 0x0300, 0x0B00
        dw 0x0400, 0x0C00
        dw 0x0500, 0x0D00
        dw 0x0600, 0x0E00
        dw 0x0700, 0x0F00
