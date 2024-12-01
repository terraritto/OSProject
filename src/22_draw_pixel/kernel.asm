; マクロ
%include "../include/define.asm"
%include "../include/macro.asm"

    ORG KERNEL_LOAD        ; ロードアドレスをアセンブラに指示

; Bitはプロテクトモードなので32bit
[BITS 32]

; エントリーポイント
kernel:
    ; フォントアドレスを取得
    mov esi, BOOT_LOAD + SECT_SIZE ; フォントアドレスの位置
    movzx eax, word[esi + 0] ; セグメント
    movzx ebx, word[esi + 2] ; オフセット
    shl eax, 4 ; 32bitにする
    add eax, ebx ; オフセットを足して確定
    mov [FONT_ADR], eax ; 保持する

    ; フォント一覧の表示
    cdecl draw_font, 63, 13
    cdecl draw_color_bar, 63, 4

    ; 文字列を表示
    cdecl draw_str, 25, 14, 0x010F, .s0

    ; ピクセルの描画
    cdecl draw_pixel, 8,   4, 0x01
    cdecl draw_pixel, 9,   5, 0x01
    cdecl draw_pixel, 10,  6, 0x02
    cdecl draw_pixel, 11,  7, 0x02
    cdecl draw_pixel, 12,  8, 0x03
    cdecl draw_pixel, 13,  9, 0x03
    cdecl draw_pixel, 14, 10, 0x04
    cdecl draw_pixel, 15, 11, 0x04

    cdecl draw_pixel, 15,  4, 0x03
    cdecl draw_pixel, 14,  5, 0x03
    cdecl draw_pixel, 13,  6, 0x04
    cdecl draw_pixel, 12,  7, 0x04
    cdecl draw_pixel, 11,  8, 0x01
    cdecl draw_pixel, 10,  9, 0x01
    cdecl draw_pixel,  9, 10, 0x02
    cdecl draw_pixel,  8, 11, 0x02

    ; 処理の終了
    jmp $

.s0: db " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR: dd 0

; モジュール
%include "../modules/protect/vga.asm"
%include "../modules/protect/draw_char.asm"
%include "../modules/protect/draw_font.asm"
%include "../modules/protect/draw_str.asm"
%include "../modules/protect/draw_color_bar.asm"
%include "../modules/protect/draw_pixel.asm"

; パディング
    times KERNEL_SIZE - ($ - $$) db 0
