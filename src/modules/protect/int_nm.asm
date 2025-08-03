; デバイス使用不可例外が発生したときの割り込み処理
int_nm:
    ; レジスタの保存
    pusha
    push ds
    push es

    ; カーネル用セレクタを設定
    mov ax, DS_KERNEL
    mov ds, ax
    mov es, ax

    ; タスクスイッチフラグのクリア
    clts        ; CR0.TS=0でクリア

    ; 前回/今回FPUを使用するタスク
    mov edi, [.last_tss] ; 前回FPUを使ったTSS
    str esi ; 今回FPUを使用したTSS
    and esi, ~0x0007 ; いらないTLとRPLは消す

    ; FPUの初回利用チェック
    cmp edi, 0
    je .10F ; 0なら初回なので、10Fへ

    cmp esi, edi ; 前と今回のコンテキストが同じかチェック
    je .12E ; 同じなら何もしない

    ; 同じでない場合の処理
    cli ; 割り込み禁止

    ; 前回のFPUコンテキストを保存しておく
    mov ebx, edi
    call get_tss_base ; アドレスを取得
    call save_fpu_context ; コンテキストを保存しておく

    ; 今回のFPUコンテキストを復帰
    mov ebx, esi
    call get_tss_base ; アドレスを取得
    call load_fpu_context ; コンテキストを復帰(初回は初期化)

    sti

.12E:
    jmp .10E

.10F:
    ;初回の処理
    cli ; 割り込み禁止にする

    mov ebx, esi ; 今回FPUを使用したTSSを選択
    call get_tss_base ; アドレスを取得
    call load_fpu_context ; 初期化

    sti ; 割り込み許可

.10E:
    mov [.last_tss], esi ; 前回のコンテキストを今回のものに

    pop es
    pop ds
    popa

    iret

ALIGN 4, db 0
.last_tss: dd 0

; TSSセレクタからベースアドレスを取り出す
get_tss_base:
    mov eax, [GDT + ebx + 2] ; EAX=Base[23,0],つまり3byteゲット
    shl eax, 8 ; 上位8bitを消すためにずらす
    mov al, [GDT + ebx + 7] ; 1Byte分持ってくる(Base[31,24])
    ror eax, 8 ; 回転させて完成！
    
    ret

; fpuのコンテキストをセーブする
save_fpu_context:
    fnsave [eax + 104] ; 0~104->CPUコンテキスト,この後ろに保存
    mov [eax + 104 + 108], dword 1 ; 105~105+108->FPUコンテキスト,ここにFPUの保存フラグを立てる
    
    ret

; fpuのコンテキストを復帰する
load_fpu_context:
    cmp [eax + 104 + 108], dword 0 ; セーブされてるか確認
    jne .10F
    
    fninit ; もし初回の場合はFNINITで初期化
    jmp .10E

.10F:
    frstor [eax + 104] ; セーブされてるならFPUコンテキストを復帰

.10E:
    ret
