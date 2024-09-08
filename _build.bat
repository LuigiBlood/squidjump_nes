@echo off
echo Assembling code... (Cartridge)
"./tools/bass/bass" build_nes.asm
IF ERRORLEVEL 1 pause