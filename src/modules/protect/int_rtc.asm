int_rtc:
    ; レジスタの保存
    pusha       ; 各レジスタをpush
    push ds
    push es

    ; 16進数は1バイトで2桁
    ; データ用セグメントセレクタを設定
    mov ax, 0x0010 ; ディスクリプタが8byteなので、先頭からのバイト数だと16だと16byteずらすのと同じ
    mov ds, ax
    mov es, ax

    ; RTCから時刻を取得
    cdecl rtc_get_time, RTC_TIME

    ; RTCの割り込み要因を取得
    outp 0x70, 0x0C ; Cレジスタを選択
    in al, 0x71 ; データアクセス

    ; 割り込みフラグのクリア(EOI)
    mov al, 0x20 ; 32の部分のビットを立てたらクリア

    ; 実際にEOIを設定してやる
    out 0xA0, al
    out 0x20, al

    ; レジスタの復帰
    pop es
    pop ds
    popa

    iret ; 割り込み処理の終了

rtc_int_en:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタの保存
    push eax

    ; 割り込み許可設定
    outp 0x70, 0x0B ; レジスタB

    in al, 0x71 ; ALに読み出し
    or al, [ebp + 8] ; 指定された部分のビットを立てる

    out 0x71, al ; レジスタBに書き込み

    ; レジスタの復帰
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret