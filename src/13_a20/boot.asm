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
ACPI_DATA:
.adr:   dd 0
.len:   dd 0

    ; モジュール(512Byte以降に配置)
%include "../modules/real/itoa.asm"
%include "../modules/real/get_drive_param.asm"
%include "../modules/real/get_font_adr.asm"
%include "../modules/real/get_mem_info.asm"
%include "../modules/real/kbc.asm"

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

    ; メモリ情報の取得と表示
    cdecl get_mem_info

    mov eax, [ACPI_DATA.adr]
    cmp eax, 0 ; 0以外なら表示
    je .10E

    ; 表示
    cdecl itoa, ax, .p4, 4, 16, 0b0100 ; 下位アドレス
    shr eax, 16
    cdecl itoa, ax, .p3, 4, 16, 0b0100 ; 上位アドレス
    cdecl puts, .s2

.10E:

    ; 次のステージへ移行
    jmp stage_4

    ; データ
.s0  db "3rd stage...", 0x0A, 0x0D, 0
.s1  db " Font Address="
.p1  db "ZZZZ:"
.p2  db "ZZZZ", 0x0A, 0x0D, 0
     db 0x0A, 0x0D, 0

.s2  db " ACPI data="
.p3  db "ZZZZ"
.p4  db "ZZZZ", 0x0A, 0x0D, 0

stage_4:
    ; 文字列の表示
    cdecl puts, .s0

    ; A20ゲートの有効化
    cli ; 割り込みを禁止

    cdecl KBC_Cmd_Write, 0xAD   ; キーボードを無効に

    cdecl KBC_Cmd_Write, 0xD0   ; 出力ポートから読み出しにセット
    cdecl KBC_Data_Read, .key    ; リセット信号を読み出しておく
    
    mov bl, [.key]
    or bl, 0x02                 ; リセット信号を保ちつつ、
                                ; A20ゲートを有効にする

    cdecl KBC_Cmd_Write, 0xD1   ; 出力ポートへ書き出しにセット
    cdecl KBC_Data_Read, bx     ; 書き込む

    cdecl KBC_Cmd_Write, 0xAE   ; キーボードを有効に

    sti ; 割り込みを許可に戻す

        ; 文字列の表示
    cdecl puts, .s1

    ; 処理の終了
    jmp $

.s0  db "4th stage...", 0x0A, 0x0D, 0
.s1  db "A20 Gate Enabled.", 0x0A, 0x0D, 0
.key dw 0

    ; パディングは8k Byte
    times BOOT_SIZE - ($ - $$) db 0