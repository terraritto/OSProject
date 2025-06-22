task_1:
    ; 文字列の表示(コールゲート)
    ;cdecl draw_str, 63, 0, 0x07, .s0
    cdecl SS_GATE_0:0, 63, 0, 0x07, .s0

.10L:
    ; 時間表示
    ; ここも時間表示を使ってるので一旦消しとく
    ; mov eax, [RTC_TIME]
    ; cdecl draw_time, 72, 0, 0x0700, eax

    ; 時間表示に戻る
    jmp .10L

    ; データ
.s0 db "Task-1", 0