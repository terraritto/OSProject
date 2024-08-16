@echo off
if exist kernel.asm (
    nasm boot.asm -o boot.bin -l boot.lst
    nasm kernel.asm -o kernel.bin -l kernel.lst
    copy /B boot.bin+kernel.bin boot.img
) else (
    nasm boot.asm -o boot.bin -l boot.lst
)