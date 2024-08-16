    BOOT_LOAD equ 0x7c00 ; ブートプログラムのロード位置
    ORG BOOT_LOAD        ; ロードアドレスをアセンブラに指示

; マクロ
%include "../include/macro.asm"

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

    mov [BOOT.DRIVE], dl    ; ブートドライブを保存する

    ; 文字表示
    cdecl   puts, .s0

    ; 次の512Byteを読み込んでいく
    mov ah, 0x02            ; AH=0x02は読み込み
    mov al, 1               ; 処理するセクタ数(今回は1つ)
    mov cx, 0x0002          ; CH=シリンダ CL=セクタ 
                            ; 今回はシリンダ:0 セクター:2
    mov dh, 0x00            ; DH=ヘッド番号(今回は1つ0)
    mov dl, [BOOT.DRIVE]    ; DL=ドライブ番号
    mov bx, 0x7C00 + 512    ; BX=オフセット
                            ; 0x7C00がアドレス開始位置なので、
                            ; そこから+512進んだ位置に512Byteを読み込む
    int 0x13                ; 読み込み開始
.10Q:
    jnc .10E
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
.DRIVE: dw 0

; モジュール
%include "../modules/real/puts.asm"
%include "../modules/real/itoa.asm"
%include "../modules/real/reboot.asm"

    ; 9.2のブート用フラグ
    times   510 - ($ - $$) db 0x00
    db      0x55, 0xAA

; ブート処理の第二ステージ
stage_2:
    cdecl puts, .s0

    jmp $

.s0  db "2nd stage...", 0x0A, 0x0D, 0

; パディングは8k Byte
times (1024 * 8) - ($ - $$) db 0x00