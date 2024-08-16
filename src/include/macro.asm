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

struc drive
    .no     resw 1 ; ドライブ番号
    .cyln   resw 1 ; シリンダ
    .head   resw 1 ; ヘッド
    .sect   resw 1 ; セクタ
endstruc