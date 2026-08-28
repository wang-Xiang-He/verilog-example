@echo off
chcp 65001 >nul
rem 重新產生閘級網表 04_netlist_syn.v
cd /d "%~dp0"
echo 用 Yosys 把 _synth_src.v 綜合成 iCE40 網表 ...
yosys -q -p "read_verilog _synth_src.v; synth_ice40 -top logic_gate; write_verilog -noattr 04_netlist_syn.v; stat"
if %ERRORLEVEL% NEQ 0 (echo [X] 綜合失敗 & exit /b 1)
echo.
echo 完成 -^> 04_netlist_syn.v
