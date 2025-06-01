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

    ; TSS ディスクリプタの設定
    set_desc GDT.tss_0, TSS_0   ; TSS0のディスクリプタアドレスのベースアドレスを設定
    set_desc GDT.tss_1, TSS_1   ; TSS1のディスクリプタアドレスのベースアドレスを設定

    ; LDTの設定
    set_desc GDT.ldt, LDT, word LDT_LIMIT

    ; GDTをロード(BOOTでやったが、ここで再設定する)
    lgdt [GDTR]
    
    ; タスク0用のスタックを設定(カーネル用)
    mov esp, SP_TASK_0

    ; タスクレジスタの初期化
    mov ax, SS_TASK_0   ; タスク0のスタックセグメント
    ltr ax ; セグメントセレクタをタスク0に設定

    ; 割り込みベクタの初期化
    cdecl init_int
    cdecl init_pic

    set_vect 0x00, int_zero_div     ; ゼロ除算割り込み
    set_vect 0x20, int_timer        ; タイマー割り込み
    set_vect 0x21, int_keyboard     ; キーボード割り込み
    set_vect 0x28, int_rtc          ; RTC割り込み

    ; 割り込みの許可
    cdecl rtc_int_en, 0x10          ; 0x10のビットは割り込み許可
    cdecl int_en_timer0

    ; 割り込みマスクレジスタ(IMR)の設定
    outp 0x21, 0b_1111_1000 ; 1ビット目がスレーブから流れてくるので、ここを許可
    outp 0xA1, 0b_1111_1110 ; スレーブの1ビット目がRTCなので、ここを許可

    ; CPUの割り込み許可(ここから割り込みの発生が行われる)
    sti

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

.10L:
    ; 回転する棒を表示
    cdecl draw_rotation_bar

    ; キーコードを表示
    cdecl ring_rd, _KEY_BUFF, .int_key ; 読み込み
    cmp eax, 0 ; データはある？
    je .10E

    ; あるなら書き込み
    cdecl draw_key, 2, 29, _KEY_BUFF

.10E:
    jmp .10L

.s0: db " Hello, kernel! ", 0

.int_key: dd 0

ALIGN 4, db 0
FONT_ADR: dd 0
RTC_TIME: dd 0

; タスク
%include "descriptor.asm"
%include "modules/int_timer.asm"
%include "tasks/task_1.asm"

; モジュール
%include "../modules/protect/vga.asm"
%include "../modules/protect/draw_char.asm"
%include "../modules/protect/draw_font.asm"
%include "../modules/protect/draw_str.asm"
%include "../modules/protect/draw_color_bar.asm"
%include "../modules/protect/draw_pixel.asm"
%include "../modules/protect/draw_line.asm"
%include "../modules/protect/draw_rect.asm"
%include "../modules/protect/itoa.asm"
%include "../modules/protect/rtc.asm"
%include "../modules/protect/draw_time.asm"
%include "../modules/protect/interrupt.asm"
%include "../modules/protect/pic.asm"
%include "../modules/protect/int_rtc.asm"
%include "../modules/protect/int_keyboard.asm"
%include "../modules/protect/ring_buff.asm"

%include "../modules/protect/timer.asm"
%include "../modules/protect/draw_rotation_bar.asm"

; パディング
    times KERNEL_SIZE - ($ - $$) db 0
