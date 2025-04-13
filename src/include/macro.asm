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