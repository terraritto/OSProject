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
    cdecl draw_line, 100, 100, 0, 0, 0x0F
    cdecl draw_line, 100, 100, 200, 0, 0x0F
    cdecl draw_line, 100, 100, 200, 200, 0x0F
    cdecl draw_line, 100, 100, 0, 200, 0x0F

    cdecl draw_line, 100, 100, 50, 0, 0x02
    cdecl draw_line, 100, 100, 150, 0, 0x03
    cdecl draw_line, 100, 100, 150, 200, 0x04
    cdecl draw_line, 100, 100, 50, 200, 0x05

    cdecl draw_line, 100, 100, 0, 50, 0x02
    cdecl draw_line, 100, 100, 200, 50, 0x03
    cdecl draw_line, 100, 100, 200, 150, 0x04
    cdecl draw_line, 100, 100, 0, 150, 0x05

    cdecl draw_line, 100, 100, 100, 0, 0x0F
    cdecl draw_line, 100, 100, 200, 100, 0x0F
    cdecl draw_line, 100, 100, 100, 200, 0x0F
    cdecl draw_line, 100, 100, 0, 100, 0x0F

    ; 矩形を描画
    cdecl draw_rect, 100, 100, 200, 200, 0x03
    cdecl draw_rect, 400, 250, 150, 150, 0x05
    cdecl draw_rect, 350, 400, 300, 100, 0x06

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
%include "../modules/protect/draw_line.asm"
%include "../modules/protect/draw_rect.asm"

; パディング
    times KERNEL_SIZE - ($ - $$) db 0
