int_en_timer0:
    ; レジスタの保存
    push eax

    ; タイマー
    outp 0x43, 0b_00_11_010_0
    outp 0x40, 0x9C
    outp 0x40, 0x2E

    pop eax

    ret