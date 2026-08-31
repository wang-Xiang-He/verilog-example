@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   把設計畫成電路圖（產生 .dot 檔）
echo  ============================================================
echo.

rem ---- 每個模組畫兩張：綜合前的 RTL 圖、綜合後的閘級圖 ----

echo  ---- fa（全加器）----
yosys -q -p "read_verilog 04_show_netlist.v; hierarchy -top fa; proc; opt; show -format dot -prefix fa_rtl -notitle"
yosys -q -p "read_verilog 04_show_netlist.v; synth_ice40 -top fa; show -format dot -prefix fa_gate -notitle"
echo       fa_rtl.dot   ^(綜合前：看得到 XOR / AND / OR^)
echo       fa_gate.dot  ^(綜合後：全部變成 SB_LUT4^)

echo.
echo  ---- adder2（階層式，兩顆 fa）----
yosys -q -p "read_verilog 04_show_netlist.v; hierarchy -top adder2; proc; opt; show -format dot -prefix adder2_rtl -notitle"
echo       adder2_rtl.dot  ^(★ 看得到兩個 fa 方塊和中間的進位線^)

echo.
echo  ---- counter2（有正反器）----
yosys -q -p "read_verilog 04_show_netlist.v; hierarchy -top counter2; proc; opt; show -format dot -prefix counter2_rtl -notitle"
yosys -q -p "read_verilog 04_show_netlist.v; synth_ice40 -top counter2; show -format dot -prefix counter2_gate -notitle"
echo       counter2_rtl.dot   ^(★ 找那條從輸出繞回輸入的回授線^)
echo       counter2_gate.dot  ^(看得到 SB_DFF^)

echo.
echo  ---- mux2（多工器）----
yosys -q -p "read_verilog 04_show_netlist.v; synth_ice40 -top mux2; show -format dot -prefix mux2_gate -notitle"
echo       mux2_gate.dot  ^(★ 一個 2 選 1 多工器 = 一顆 LUT^)

echo.
echo  ============================================================
echo   .dot 檔怎麼看？（這台機器沒有裝 graphviz）
echo.
echo     方法 1（最快）：線上看
echo       開 https://dreampuf.github.io/GraphvizOnline/
echo       把 .dot 的內容整個貼進去
echo.
echo     方法 2：VS Code
echo       裝「Graphviz Interactive Preview」擴充套件，
echo       直接開 .dot 檔按預覽
echo.
echo     方法 3：裝 graphviz 之後
echo       dot -Tpng fa_rtl.dot -o fa_rtl.png
echo  ============================================================
echo.
