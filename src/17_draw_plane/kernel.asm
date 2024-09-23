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

    ;------------------------------------------
    ; 8ビットの横線
    ;------------------------------------------
    mov ah, 0x07 ; 書き込みを指定、0111なので、RGB
    mov al, 0x02 ; マップマスクレジスタ
    mov dx, 0x03C4 ; シーケンサ制御用ポート
    out dx, ax ; 出力

    mov [0x000A_0000 + 0], byte 0xFF ; 1バイト分書き込み

    mov ah, 0x04　; 0100なので、B
    out dx, ax

    mov [0x000A_0000 + 1], byte 0xFF ; 1バイト分ずらして1バイト分書き込み

    mov ah, 0x02 ; 0010なので、G
    out dx, ax

    mov [0x000A_0000 + 2], byte 0xFF

    mov ah, 0x01 ; 0001なので、R
    out dx, ax

    mov [0x000A_0000 + 3], byte 0xFF

    ;------------------------------------------
    ; 画面を横切る横線
    ;------------------------------------------
    mov ah, 0x02
    out dx, ax

    lea edi, [0x000A_0000 + 80] ; 二行目へ
    mov ecx, 80 ; 80回=直線を描画
    mov al, 0xFF ; 緑色で書き込み
    rep stosb

    ;------------------------------------------
    ; 2行目に8ドットの矩形
    ;------------------------------------------
    mov edi, 1 ; 1行目

    shl edi, 8 ; 00000001 -> 1_0000,0000
    lea edi, [edi * 4 + edi + 0xA_0000] ; 101_0000,0000に

    ; 8行に渡って1byteずつ書き込み
    mov [edi + (80 * 0)], word 0xFF
    mov [edi + (80 * 1)], word 0xFF
    mov [edi + (80 * 2)], word 0xFF
    mov [edi + (80 * 3)], word 0xFF
    mov [edi + (80 * 4)], word 0xFF
    mov [edi + (80 * 5)], word 0xFF
    mov [edi + (80 * 6)], word 0xFF
    mov [edi + (80 * 7)], word 0xFF

    ;------------------------------------------
    ; 3行目に文字を描画
    ;------------------------------------------
    mov esi, 'A' ; 書き込みたい数値
    shl esi, 4 ; 32byteへ
    add esi, [FONT_ADR] ; フォントアドレスで位置を確定

    mov edi, 2 ; 2行目にする
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000]

    mov ecx, 16 ; 16行書き込む
.10L:
    movsb ; edi=esiで書き込む
    add edi, 80 - 1 ; ずらし
    loop .10L
    ; 処理の終了
    jmp $

ALIGN 4, db 0
FONT_ADR: dd 0

    ; パディング
    times KERNEL_SIZE - ($ - $$) db 0
