@echo off
echo Assembling code... (Disk)
"./tools/bass/bass" build_fds.asm
IF ERRORLEVEL 1 pause