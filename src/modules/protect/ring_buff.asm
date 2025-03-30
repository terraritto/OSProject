ring_rd:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push ebx
    push esi
    push edi

    ; 引数を取得
    mov esi, [ebp + 8]  ; リングバッファ
    mov edi, [ebp + 12] ; データアドレス

    ; 読み込み位置を確認
    mov eax, 0  ; EAX = 0はデータなしの場合
    mov ebx, [esi + ring_buff.rp] ; 読み込み位置
    cmp ebx, [esi + ring_buff.wp] ; 書き込み位置と比較

    je .10E ; 同じ位置なら書き込みがない判定なので終わり

    ; 同じ位置でないなら読み込み開始
    mov al, [esi + ring_buff.item + ebx] ; itemの初期位置 + indexでデータ取得

    mov [edi], al ; 読み込んだデータをデータアドレスに書き込む

    inc ebx ; 読み込み位置をずらす
    and ebx, RING_INDEX_MASK ; MASKで範囲外判定
    mov [esi + ring_buff.rp], ebx ; 読み込み位置を書き込んでおく

    mov eax, 1 ; EAX=1はデータありの場合

.10E:
    ; レジスタの復帰
    pop edi
    pop esi
    pop ebx

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

ring_wr:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    push ebx
    push ecx
    push esi

    ; 引数を取得
    mov esi, [ebp + 8]  ; リングバッファ

    ; 読み込み位置を確認
    mov eax, 0  ; EAX = 0は書き込み失敗の場合
    mov ebx, [esi + ring_buff.wp] ; 書き込み位置
    mov ecx, ebx ; ECXに書き込み位置を入れる
    inc ecx ; ECX++で次の書き込み位置
    and ecx, RING_INDEX_MASK ; 書き込み制限

    cmp ecx, [esi + ring_buff.rp] ; 読み込みまで来たら書き込まない
    je .10E

    ; 同じ位置でないなら書き込み開始
    mov al, [ebp + 12] ; 書き込みするデータの取得

    mov [esi + ring_buff.item + ebx], al ; データ書き込み
    mov [esi + ring_buff.wp], ecx ; 次の書き込み位置を入れておく
    mov eax, 1 ; EAX=1は書き込み成功の場合

.10E:
    ; レジスタの復帰
    pop esi
    pop ecx
    pop ebx

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

draw_key:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタを保存
    pusha

    ; 引数を取得
    mov edx, [ebp + 8]      ; EBX=row
    mov edi, [ebp + 12]     ; EDI=col
    mov esi, [ebp + 16]     ; ESI=リングバッファ
    
    ; リングバッファの情報を取得
    mov ebx, [esi + ring_buff.rp]   ; 読み込み位置
    lea esi, [esi + ring_buff.item] ; バッファの初期位置
    mov ecx, RING_ITEM_SIZE ; 要素数

    ; 表示
.10L:
     dec ebx
     and ebx, RING_INDEX_MASK ; マスクで位置補正
     mov al, [esi + ebx] ; AL=バッファの位置からデータを取得
     cdecl itoa, eax, .tmp, 2, 16, 0b0100 ; 数値を文字に
     cdecl draw_str, edx, edi, 0x02, .tmp ; 表示

     add edx, 3 ; 3文字分表示を更新

     loop .10L

.10E:
    ; レジスタの復帰
    popa

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

.tmp: db "-- ", 0