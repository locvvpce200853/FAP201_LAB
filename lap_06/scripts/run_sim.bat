@echo off
setlocal
cd /d "%~dp0\.."
if not exist build mkdir build
if not exist waveforms mkdir waveforms
cd build
ghdl -a --std=08 ..\src\key_conditioner.vhd ..\src\lab06_game.vhd ..\src\sevenseg_74hc595.vhd ..\src\lab06_top_ledonly.vhd ..\src\lab06_top_74hc595.vhd ..\sim\key_conditioner_tb.vhd ..\sim\lab06_game_tb.vhd
if errorlevel 1 goto :failed
ghdl -e --std=08 key_conditioner_tb
if errorlevel 1 goto :failed
ghdl -r --std=08 key_conditioner_tb --wave=..\waveforms\key_conditioner.ghw
if errorlevel 1 goto :failed
ghdl -e --std=08 lab06_game_tb
if errorlevel 1 goto :failed
ghdl -r --std=08 lab06_game_tb --wave=..\waveforms\lab06_game.ghw
if errorlevel 1 goto :failed
echo SUCCESS: ALL CHECKS PASS
exit /b 0
:failed
echo FAILED: Read the first error above
exit /b 1