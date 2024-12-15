draw_line:
    ; スタックフレームの構築
    push ebp
    mov ebp, esp

    ; ローカル変数
    push dword 0 ; sum
    push dword 0 ; x0
    push dword 0 ; dx
    push dword 0 ; inc_x
    push dword 0 ; y0
    push dword 0 ; dy
    push dword 0 ; inc_y

    ; レジスタを保存
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; 幅を計算(X方向)
    mov eax, [ebp + 8] ; x0
    mov ebx, [ebp + 16] ; x1
    sub ebx, eax ; x1 - x0
    jge .10F

    neg ebx ; x1-x0がマイナスなら-で反転
    mov esi, -1 ; マイナス方向に増える増分をESIに保存
    jmp .10E

.10F:
    mov esi, 1  ; プラス方向に増える増分をESIに保存


.10E:
    ; 高さを計算(Y方向)
    mov ecx, [ebp + 12] ; y0
    mov edx, [ebp + 20] ; y1
    sub edx, ecx ; y1 - y0
    jge .20F

    neg edx ; y1-y0がマイナスなら-で反転
    mov edi, -1 ; マイナス方向に増える増分をEDIに保存
    jmp .20E

.20F:
    mov edi, 1  ; プラス方向に増える増分をEDIに保存

.20E:
    ; ローカル変数に保存していく
    ; X軸
    mov [ebp - 8], eax      ; x0
    mov [ebp - 12], ebx     ; abs(x1 - x0)
    mov [ebp - 16], esi     ; 増分

    ; Y軸
    mov [ebp - 20], ecx     ; y0
    mov [ebp - 24], edx     ; abs(y1 - y0)
    mov [ebp - 28], edi     ; 増分

    ; 長い方を基準とする
    cmp ebx, edx    ; height <= widthならジャンプ
    jg .22F

    lea esi, [ebp - 20] ; Yを基準に
    lea edi, [ebp - 8]  ; Xを相対に

    jmp .22E

.22F:
    lea esi, [ebp - 8]  ; Xを基準に
    lea edi, [ebp - 20] ; Yを相対に

.22E:
    ; 繰り返し回数を定義
    mov ecx, [esi - 4] ; 基準となるwidth or heightを取ってくる
    cmp ecx, 0
    jnz .30E
    mov ecx, 1 ; 幅が0なら1回描画のみにする

.30E:

    ; 線の描画をしていく
.50L:
    ; x,y,colorでピクセルを打つ
    cdecl draw_pixel, dword [ebp - 8], dword [ebp - 20], dword [ebp + 24]

    ; 基準の軸を更新
    mov eax, [esi - 8] ; 増分をEAXに入れる
    add [esi - 0], eax  ; 増分してx0 or y0から++(or --)していく

    ; 相対軸の更新
    mov eax, [ebp - 4] ; EAX=sum
    add eax, [edi - 4] ; sum += 相対描画幅
    mov ebx, [esi - 4] ; ebx=基準幅

    cmp eax, ebx
    jl .52E ; 超えてないなら相対は足さない
    sub eax, ebx ; sumが基準幅を超えたら、基準分を引く

    mov ebx, [edi - 8] ; EBX=相対軸幅を入れる
    add [edi - 0], ebx ; 増分してx0 or y0から++(or --)していく
    ; 相対軸の更新終了

.52E:
    mov [ebp - 4], eax ; sumに現状のものを入れておく

    loop .50L

.50E:

    ; レジスタ復帰
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; スタックフレームの破棄
    mov esp, ebp
    pop ebp

    ret
