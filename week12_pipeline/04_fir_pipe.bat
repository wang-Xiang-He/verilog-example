@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   FIR 濾波器：單週期 vs 三級管線，實測最高時脈
echo  ============================================================
echo.

echo  ---- 1/2  fir_comb（單週期）----
yosys -q -p "read_verilog 04_fir_pipe.v; synth_ice40 -top fir_comb -json fir_comb.json; stat"
nextpnr-ice40 --hx8k --package ct256 --json fir_comb.json --freq 50 --placer heap 2>&1 | findstr /C:"Max frequency" /C:"ICESTORM_LC"

echo.
echo  ---- 2/2  fir_pipe（三級管線）----
yosys -q -p "read_verilog 04_fir_pipe.v; synth_ice40 -top fir_pipe -json fir_pipe.json; stat"
nextpnr-ice40 --hx8k --package ct256 --json fir_pipe.json --freq 50 --placer heap 2>&1 | findstr /C:"Max frequency" /C:"ICESTORM_LC"

echo.
echo  ============================================================
echo   參考數據（本專案實測，iCE40 HX8K ct256）
echo.
echo                      單週期       三級管線     變化
echo     ------------------------------------------------------
echo     最高時脈        65.77 MHz   118.46 MHz   ★ +80%%
echo     延遲 latency       2 拍         4 拍       +2 拍
echo     吞吐量          每拍 1 筆    每拍 1 筆     一樣
echo     ★ 每秒可算       65.8 M 次   118.5 M 次   ★ +80%%
echo     ------------------------------------------------------
echo     SB_LUT4            744          678        -9%%
echo     SB_DFF (合計)       52          152       ★ +192%%
echo     SB_CARRY            14           97       +593%%
echo.
echo   ★ FIR 的改善（+80%%）比單顆乘法器（+50%%）還大 ——
echo     因為它原本的關鍵路徑更長（4 顆乘法器 + 3 層加法），
echo     切開之後省下來的自然更多。
echo.
echo     ★★ 一句話：關鍵路徑越長，切管線的效益越大。
echo.
echo   ⚠️ nextpnr 佈局有隨機性，你跑出來會差個幾 MHz。
echo      要重現同樣結果就加 --seed 1
echo  ============================================================
echo.
