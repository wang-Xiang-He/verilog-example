@echo off
chcp 65001 >nul
cd /d "%~dp0"
del /q report_generic.txt 2>nul

echo.
echo  ============================================================
echo   ASIC 流程第一步：綜合成【通用邏輯閘】
echo.
echo   和 FPGA 流程的差別：
echo     FPGA  synth_ice40  -^> 目標是查表 LUT（元件固定）
echo     ASIC  synth + abc  -^> 目標是邏輯閘（之後再挑真的元件）
echo  ============================================================
echo.

for %%M in (fa adder4 counter4 alu4) do (
    echo  ---- %%M ----
    yosys -p "read_verilog 01_generic_synth.v; synth -top %%M -flatten; abc -g AND,OR,XOR,NAND,NOR,NOT,MUX; opt_clean; tee -a report_generic.txt stat" > nul 2>&1
    if errorlevel 1 (echo      [X] 失敗) else (echo      OK)
)

echo.
echo  ============================================================
echo   報告寫在 report_generic.txt
echo.
echo   看重點：
echo       findstr /C:"===" /C:"$_" /C:"cells" report_generic.txt
echo.
echo   ★ 這時候的網表還是「抽象的閘」（$_AND_、$_XOR_ …），
echo     還沒對應到任何一顆真實元件。
echo     下一步 02_liberty_map.bat 才會挑真的元件。
echo  ============================================================
echo.
