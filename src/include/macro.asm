%macro  cdecl 1-*.nolist ; 全部の引数を取る

    %rep %0 - 1 ; 引数がある場合はpushしていく
        push %{-1:-1}
        %rotate -1
    %endrep
    %rotate -1 ; これで完全に元の形に戻る

        call %1
    
    %if 1 < %0 ; 引数がある場合はpop
        add sp, (__BITS__ >> 3) * (%0 - 1)
    %endif
%endmacro

; 割り込みディスクリプタに登録を行う
%macro  set_vect 1-*.nolist ; 全部の引数を取る
    push eax
    push edi

    mov edi, VECT_BASE + (%1 * 8) ; 第一引数で書き込み位置を特定
    mov eax, %2 ; 書き込みアドレス

    %if 3 == %0
        mov [edi + 4], %3
    %endif

    mov [edi + 0], ax ; [15:0]のアドレス
    shr eax, 16 ; ずらして後半に
    mov [edi + 6], ax ; [31:16]のアドレス

    pop edi
    pop eax
%endmacro

; ポート出力命令
%macro outp 2
    mov al, %2
    out %1, al
%endmacro

; descriptorにリミットとベースを設定
%macro set_desc 2-*
    push eax
    push edi

    mov edi, %1 ; ディスクリプタアドレス
    mov eax, %2 ; ベースアドレス

    %if 3 == %0 ; 3つめの変数がある？
        mov [edi + 0], %3 ; リミットを設定
    %endif

    mov [edi + 2], ax ; ベース[15:0]
    shr eax, 16 ; 右ずらし
    mov [edi + 4], al ; ベース[23:16]
    mov [edi + 7], ah ; ベース[31:24]

    pop edi
    pop eax
%endmacro

; descriptorにベースを設定
%macro set_gate 2-*
    push eax
    push edi

    mov edi, %1 ; ディスクリプタアドレス
    mov eax, %2 ; ベースアドレス

    mov [edi + 0], ax ; ベース[15:0]
    shr eax, 16 ; 右ずらし
    mov [edi + 6], al ; ベース[31:16]

    pop edi
    pop eax
%endmacro

struc drive
    .no     resw 1 ; ドライブ番号
    .cyln   resw 1 ; シリンダ
    .head   resw 1 ; ヘッド
    .sect   resw 1 ; セクタ
endstruc

; リングバッファ
%define RING_ITEM_SIZE (1 << 4) ; 16のこと、リングバッファのサイズ
%define RING_INDEX_MASK (RING_ITEM_SIZE - 1) ; 15は 0000 1111 となるので、そこでマスク

struc ring_buff
    .rp resd 1      ; 書き込み位置
    .wp resd 1      ; 読み込み位置
    .item resb RING_ITEM_SIZE ; バッファ
endstruc

struc rose
    .x0 resd 1              ; 左上座標X
    .y0 resd 1              ; 左上座標Y
    .x1 resd 1              ; 右下座標X
    .y1 resd 1              ; 右下座標Y

    .n resd 1               ; 変数:n
    .d resd 1               ; 変数:d

    .color_x resd 1         ; X軸の色
    .color_y resd 1         ; Y軸の色
    .color_z resd 1         ; 枠の色
    .color_s resd 1         ; 文字の色
    .color_f resd 1         ; グラフ描画色
    .color_b resd 1         ; グラフ消去色

    .title resb 16          ; タイトル
endstruc