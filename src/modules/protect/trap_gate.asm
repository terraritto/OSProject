trap_gate_81:
    ; 1文字出力するだけ
    cdecl draw_char, ecx, edx, ebx, eax

    iret

trap_gate_82:
    ; 1ピクセル描画するだけ
    cdecl draw_pixel, ecx, edx, ebx

    iret