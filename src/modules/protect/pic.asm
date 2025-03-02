init_pic:
    push eax

    ; マスタPIC
    outp 0x20, 0x11     ; master ICW1
    outp 0x21, 0x20     ; master ICW2
    outp 0x21, 0x04     ; master ICW3
    outp 0x21, 0x01     ; master ICW4
    outp 0x21, 0xFF     ; master割り込みマスク

    ; スレーブPIC
    outp 0xA0, 0x11     ; slave ICW1
    outp 0xA1, 0x28     ; slave ICW2
    outp 0xA1, 0x02     ; slave ICW3
    outp 0xA1, 0x01     ; slave ICW4
    outp 0xA1, 0xFF     ; slave割り込みマスク

    pop eax

    ret