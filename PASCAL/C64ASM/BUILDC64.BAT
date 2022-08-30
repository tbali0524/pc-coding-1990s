@echo off
rem  This batch file builds all files for the C64 Assembler Package
rem  A better way to do this is to use the MAKEFILE with Borland's MAKE utility
rem
echo Building C64ASM package...
tvhc c64help.txt c64ide.hlp cvhelp.pas
if errorlevel 1 goto error
bpc /m c64res
if errorlevel 1 goto error
c64res
if errorlevel 1 goto error
bpc /m c64ide
if errorlevel 1 goto error
copy /b c64ide.exe+c64ide.tvr temp.exe
copy temp.exe c64ide.exe
del temp.exe
bpc /m c64asm
if errorlevel 1 goto error
bpc /m c64disa
if errorlevel 1 goto error
bpc /m bas2txt
if errorlevel 1 goto error
echo -------
echo All files (C64IDE.EXE, C64IDE.HLP, C64ASM.EXE, C64DISA.EXE, BAS2TXT.EXE)
echo   are now up-to-date.
goto ok
:error
echo Error! Cannot complete building.
:ok