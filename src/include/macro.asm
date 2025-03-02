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

    mov edi, VECT_BASE + (%1 * 8) ; 第一引数で書き込み位置を解くデイ
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

struc drive
    .no     resw 1 ; ドライブ番号
    .cyln   resw 1 ; シリンダ
    .head   resw 1 ; ヘッド
    .sect   resw 1 ; セクタ
endstruc