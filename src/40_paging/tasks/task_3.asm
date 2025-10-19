task_3:
    ; スタックフレームの構築
    mov ebp, esp

    push dword 0        ; x0=0  X座標原点
    push dword 0        ; y0=0  Y座標原点
    push dword 0        ; x=0   X座標描画
    push dword 0        ; y=0   Y座標描画
    push dword 0        ; r=0   角度

    ; 初期化
    mov esi, DRAM_PARAM     ; ESI=描画パラメータ

    ; タイトル表示
    mov eax, [esi + rose.x0]    ; x0座標
    mov ebx, [esi + rose.y0]    ; y0座標

    shr eax, 3                  ; EAX /= 8, X座標を文字位置に
    shr ebx, 4                  ; EBX /= 16, Y座標を文字位置に
    dec ebx                     ; EBXを1文字分上へ
    mov ecx, [esi + rose.color_s] ; 文字の色
    lea edx, [esi + rose.title]   ; 文字そのもの
    cdecl draw_str, eax, ebx, ecx, edx ; 描画！

    ; X軸の中点
    mov eax, [esi + rose.x0]    ; x0
    mov ebx, [esi + rose.x1]    ; x1
    sub ebx, eax                ; x1 = x1 - x0
    shr ebx, 1                  ; x1 /= 2, これで半分
    add ebx, eax                ; x0を足してoffsetずらし
    mov [ebp - 4], ebx          ; x0に中点を格納

    ; Y軸の中点
    mov eax, [esi + rose.y0]    ; y0
    mov ebx, [esi + rose.y1]    ; y1
    sub ebx, eax                ; y1 = y1 - y0
    shr ebx, 1                  ; y1 /= 2, これで半分
    add ebx, eax                ; y0を足してoffsetずらし
    mov [ebp - 8], ebx          ; y0に中点を格納    

    ; X軸の描画(真ん中の横線)
    mov eax, [esi + rose.x0]    ; x0
    mov ebx, [ebp - 8]          ; Y軸中点
    mov ecx, [esi + rose.x1]    ; x1

    cdecl draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]

    ; Y軸の描画(真ん中の縦線)
    mov eax, [esi + rose.y0]    ; y0
    mov ebx, [ebp - 4]          ; X軸の中点
    mov ecx, [esi + rose.y1]    ; y1

    cdecl draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_y]

    ; 枠の描画
    mov eax, [esi + rose.x0]    ; x0
    mov ebx, [esi + rose.y0]    ; y0
    mov ecx, [esi + rose.x1]    ; x1
    mov edx, [esi + rose.y1]    ; y1

    cdecl draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z] 

    ; 振幅をX軸の95%くらいへ制限する
    mov eax, [esi + rose.x1] ; x1
    sub eax, [esi + rose.x0] ; dist = x1 - x0
    shr eax, 1  ; dist /=2, つまり半分
    mov ebx, eax ; ebx = dist
    shr ebx, 4 ; ebx /= 16,つまり*=0.0625なので6%くらい
    sub eax, ebx ; eax(100%) - ebx(6%) ~= 95%くらい

    ; FPUの初期化
    cdecl fpu_rose_init, eax, dword [esi + rose.n], dword [esi + rose.d]

    ; メインループ
.10L:
    ; 座標計算(x,yを確定)
    lea ebx, [ebp - 12]  ; EBX = &x
    lea ecx, [ebp - 16]  ; ECX = &y
    mov eax, [ebp - 20]  ; EAX = r
    cdecl fpu_rose_update, ebx, ecx, eax

    ; 角度を更新しておく
    mov edx, 0  ; EDX = 0
    inc eax     ; r++
    mov ebx, 360 * 100 ; EBX = 36000
    div ebx ; EDX = r % 36000,つまり36000を超えない
    mov [ebp - 20], edx ; 角度更新完了

    ; ドットを描画
    mov ecx, [ebp - 12] ; ECX = x
    mov edx, [ebp - 16] ; EDX = y

    add ecx, [ebp - 4] ; ECX += x0
    add edx, [ebp - 8] ; EDX += y0

    mov ebx, [esi + rose.color_f] ; ドット色
    int 0x82    ; 色を塗る

    ; wait
    cdecl wait_tick, 2

    ; ドット描画(消去)
    mov ebx, [esi + rose.color_b] ; ドット消去色
    int 0x82 ; 色を塗る

    jmp .10L

; データ
ALIGN 4, db 0
DRAM_PARAM:
    istruc rose
        at rose.x0, dd 16                    ; 左上座標X
        at rose.y0, dd 32                    ; 左上座標Y
        at rose.x1, dd 416                   ; 右下座標X
        at rose.y1, dd 432                   ; 右下座標Y

        at rose.n, dd 2                      ; 変数:n
        at rose.d, dd 1                      ; 変数:d

        at rose.color_x, dd 0x0007           ; X軸の色
        at rose.color_y, dd 0x0007           ; Y軸の色
        at rose.color_z, dd 0x000F           ; 枠の色
        at rose.color_s, dd 0x030F           ; 文字の色
        at rose.color_f, dd 0x000F           ; グラフ描画色
        at rose.color_b, dd 0x0003           ; グラフ消去色

        at rose.title, db "Task-3", 0        ; タイトル
    iend

; バラ曲線の前処理用関数
fpu_rose_init:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; 後で使う変数を用意
    push dword 180 ; i = 180

    ; FPUのスタックを設定
    fldpi                               ; pi
    fidiv dword [ebp - 4]               ; pi/180
    fild dword [ebp + 12]               ; n | pi/180
    fidiv dword [ebp + 16]              ; n/d | pi/180
    fild dword [ebp + 8]                ; A | K=n/d | r=pi/180

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret

; 座標計算処理用関数
fpu_rose_update:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; レジスタの保存
    push eax
    push ebx

    ; X/Y座標の保存先を設定
    mov eax, [ebp + 8]      ; EAX = pX (X座標を保存するポインタ)
    mov ebx, [ebp + 12]     ; EBX = pY (Y座標を保存するポインタ)

    ; ラジアンへの変換
    fild dword [ebp + 16]   ; t | A | K | r
    fmul st0, st3           ; rt | A | K | r
    fld st0                 ; θ=rt | θ=rt | A | K | r

    ; sinθとcosθを計算
    fsincos                 ; cosθ | sinθ | θ | A | K | r

    ; 共通のAsin(kθ)を構築する
    fxch st2                ; θ | sinθ | cosθ | A | K | r
    fmul st0, st4           ; kθ | sinθ | cosθ | A | K | r
    fsin                    ; sin(kθ) | sinθ | cosθ | A | K | r
    fmul st0, st3           ; Asin(kθ) | sinθ | cosθ | A | K | r

    ; X = Asin(kθ)cos(θ)
    fxch st2                ; cosθ | sinθ | Asin(kθ) | A | K | r
    fmul st0, st2           ; Asin(kθ)cosθ | sinθ | Asin(kθ) | A | K | r
    fistp dword [eax]       ; sinθ | Asin(kθ) | A | K | r
    ; EAX=X

    ; Y = -Asin(kθ)sin(θ)
    fmulp st1, st0          ; Asin(kθ)sin(θ) | A | K | r
    fchs                    ; -Asin(kθ)sin(θ) | A | K | r
    fistp dword [ebx]       ; A | K | r
    ; EBX=Y

    ; レジスタの復帰
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret