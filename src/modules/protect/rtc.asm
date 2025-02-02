rtc_get_time:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push ebx

    ; RTCの読み込みを行う
    mov al, 0x0A ; UIPを確認するためにAレジスタを読み込み
    out 0x70, al ; 0x70に書き込み
    in al, 0x71 ; 0x71からUIP読み込み

    test al, 0x80 ; 更新中かを確認
    je .10F ; 成功
    
    mov eax, 1 ; 失敗時はeax=1とする
    jmp .10E

.10F:
    mov al, 0x04 ; 0x04はRTCの時を読み出し
    out 0x70, al ; 0x70に書き込み
    in al, 0x71 ; 0x71からデータ読み込み

    shl eax, 8 ; EAX << 8でデータを退避

    mov al, 0x02 ; 0x02はRTCの分を読み出し
    out 0x70, al ; 0x70に書き込み
    in al, 0x71 ; 0x71からデータ読み込み

    shl eax, 8 ; EAX << 8でデータを退避

    mov al, 0x00 ; 0x00はRTCの秒を読み出し
    out 0x70, al ; 0x70に書き込み
    in al, 0x71 ; 0x71からデータ読み込み

    and eax, 0x00_FF_FF_FF ; 下位3ビットのみ1は立つようにする

    mov ebx, [ebp + 8] ; 保存先
    mov [ebx], eax ; 時刻を入れる

    mov eax, 0 ; 成功は0にしておく

.10E:
    ; レジスタ復帰
    pop ebx

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret
