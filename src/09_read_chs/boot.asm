; マクロ
%include "../include/define.asm"
%include "../include/macro.asm"

    ORG BOOT_LOAD        ; ロードアドレスをアセンブラに指示

entry:
    jmp     ipl   ; IPLにジャンプ

    ; BPB(BIOS Parameter Block)
    times 90 - ($ - $$) db 0x90

ipl:
    cli         ; 割り込みを禁止する

    mov ax, 0x0000 ; AXレジスタ(汎用)に0を設定

    ; 汎用レジスタを使用してCS以外のレジスタを0にする
    mov ds, ax     ; DSレジスタ
    mov es, ax     ; ESレジスタ
    mov ss, ax     ; SSレジスタ
    
    ; スタックポインタは0x7c00
    mov sp, BOOT_LOAD

    sti         ; 割り込みを許可する

    mov [BOOT + drive.no], dl    ; ブートドライブを保存する

    ; 文字表示
    cdecl   puts, .s0

    ; 残りのセクタをすべて読み込む
    mov bx, BOOT_SECT - 1
    mov cx, BOOT_LOAD + SECT_SIZE

    cdecl read_chs, BOOT, bx, cx ; 読み込み

    cmp ax, bx ; AXが残りセクタ数と違うのはおかしいので再帰

.10Q:
    jz .10E
.10T: 
    cdecl puts, .e0         ; ここに来るのはエラー時なので、エラー出力
    call reboot             ; 再起動
.10E:
    ; 次のステージへ移行
    jmp stage_2

.s0  db "Booting...", 0x0A, 0x0D, 0
.e0  db "Error:sector read", 0 

ALIGN 2, db 0
BOOT:
    istruc drive
        at drive.no,        dw 0
        at drive.cyln,      dw 0
        at drive.head,      dw 0
        at drive.sect,      dw 2
    iend

    ; モジュール
%include "../modules/real/puts.asm"
%include "../modules/real/reboot.asm"
%include "../modules/real/read_chs.asm"

    ; 9.2のブート用フラグ
    times   510 - ($ - $$) db 0x00
    db      0x55, 0xAA

    ; ブート処理の第二ステージ
stage_2:
    cdecl puts, .s0

    jmp $

.s0  db "2nd stage...", 0x0A, 0x0D, 0

    ; パディングは8k Byte
    times BOOT_SIZE - ($ - $$) db 0