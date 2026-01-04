init_page:
    ; レジスタの保存
    pusha

    ; ページ変換テーブルの作成
    cdecl page_set_4m, CR3_BASE
    cdecl page_set_4m, CR3_TASK_4
    cdecl page_set_4m, CR3_TASK_5
    cdecl page_set_4m, CR3_TASK_6

    ; 0x0010_7000をページ不在に
    mov [0x0010_6000 + 0x107 * 4], dword 0

    ; アドレス変換設定(4~6)
    mov [0x0020_1000 + 0x107 * 4], dword PARAM_TASK_4 + 7
    mov [0x0020_3000 + 0x107 * 4], dword PARAM_TASK_5 + 7
    mov [0x0020_5000 + 0x107 * 4], dword PARAM_TASK_6 + 7

    ; 描画パラメータを設定(4~6)
    cdecl memcpy, PARAM_TASK_4, DRAM_PARAM.t4, rose_size ; 描画パラメータ:タスク4
    cdecl memcpy, PARAM_TASK_5, DRAM_PARAM.t5, rose_size ; 描画パラメータ:タスク5
    cdecl memcpy, PARAM_TASK_6, DRAM_PARAM.t6, rose_size ; 描画パラメータ:タスク6

    ; レジスタの復帰
    popa

    ret

page_set_4m:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタの保存
    pusha

    ; ページングディレクトリを作成していく
    cld ; DFをクリアしておく
    mov edi, [ebp + 8]  ; EDI=ページディレクトリの先頭
    mov eax, 0x00000000 ; P=0となるようなページ設定
    mov ecx, 1024       ; ページディレクトリ数
    rep stosd           ; 1024個すべてを0にする

    ; 先頭のページディレクトリは有効になるように設定をしていく
    mov eax, edi        ; EAX = ページディレクトリの直後の位置
    and eax, ~0x0000_0FFF ; 20bit分の物理アドレスの位置を指定
    or eax, 7   ; R/WはOK!Pも1でU/Sも1となる,つまり 0b0111で強制的にbitを立てる
    mov [edi - 1024 * 4], eax ; 先頭のページディレクトリに書き込む

    ; ここからページテーブルの設定
    mov eax, 0x00000007 ; 先ほどと同じものを指定
    mov ecx, 1024 ; ページテーブルも1024個
.10L:
    stosd ; 次にずらす
    add eax, 0x00001000 ; +1000ずつずらして、物理アドレスを設定
    loop .10L

    ; レジスタの復帰
    popa

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret