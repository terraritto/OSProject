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

    ; リアルモード時に取得した情報
FONT:
.seg:   dw 0
.off:   dw 0

    ; モジュール(512Byte以降に配置)
%include "../modules/real/itoa.asm"
%include "../modules/real/get_drive_param.asm"
%include "../modules/real/get_font_adr.asm"

    ; ブート処理の第二ステージ
stage_2:
    ; 2nd Stageの表示
    cdecl puts, .s0

    ; ドライブ情報を取得
    cdecl get_drive_param, BOOT
    
    cmp ax, 0
.10Q:
    jne .10E

.10T:
    ; axが0ならドライブ情報取得失敗
    cdecl puts, .e0
    call reboot

.10E:
    ; ドライブ情報を表示
    mov ax, [BOOT + drive.no]
    cdecl itoa, ax, .p1, 2, 16, 0b0100
    mov ax, [BOOT + drive.cyln]
    cdecl itoa, ax, .p2, 4, 16, 0b0100
    mov ax, [BOOT + drive.head]
    cdecl itoa, ax, .p3, 2, 16, 0b0100
    mov ax, [BOOT + drive.sect]
    cdecl itoa, ax, .p4, 2, 16, 0b0100
    cdecl puts, .s1

    ; 次のステージへ移行
    jmp stage_3

    ; データ
.s0  db "2nd stage...", 0x0A, 0x0D, 0
.s1  db "Drive:0x"
.p1  db " , C:0x"
.p2  db "   , H:0x"
.p3  db " , S:0x"
.p4  db "  ", 0x0A, 0x0D, 0
.e0  db "Can't get drive parameter.", 0

    ; ブート処理の第3ステージ
stage_3:
    ; 文字列の表示
    cdecl puts, .s0

    ; プロテクトモードのフォントは
    ; BIOS内蔵のものを使用
    cdecl get_font_adr, FONT

    ; フォントアドレスを表示
    cdecl itoa, word[FONT.seg], .p1, 4, 16, 0b0100
    cdecl itoa, word[FONT.off], .p2, 4, 16, 0b0100
    cdecl puts, .s1

    ; 処理を終了
    jmp $

    ; データ
.s0  db "3rd stage...", 0x0A, 0x0D, 0
.s1  db " Font Address="
.p1  db "ZZZZ:"
.p2  db "ZZZZ", 0x0A, 0x0D, 0
     db 0x0A, 0x0D, 0

    ; パディングは8k Byte
    times BOOT_SIZE - ($ - $$) db 0