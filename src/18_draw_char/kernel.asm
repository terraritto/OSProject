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

    ; 文字の表示
    cdecl draw_char, 0, 0, 0x010F, 'A' ; 背景青,白文字:A
    cdecl draw_char, 1, 0, 0x010F, 'B' ; 背景青,白文字:B
    cdecl draw_char, 2, 0, 0x010F, 'C' ; 背景青,白文字:C

    cdecl draw_char, 0, 0, 0x0402, '0' ; 上書き:0
    cdecl draw_char, 1, 0, 0x0212, '1' ; 透過モード:1
    cdecl draw_char, 2, 0, 0x0212, '_' ; 透過モード:_

    ; 処理の終了
    jmp $

ALIGN 4, db 0
FONT_ADR: dd 0

; モジュール
%include "../modules/protect/vga.asm"
%include "../modules/protect/draw_char.asm"

    ; パディング
    times KERNEL_SIZE - ($ - $$) db 0
