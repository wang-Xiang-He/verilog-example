@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   實測：單週期 vs 三級管線，到底差多少
echo.
echo   流程： yosys（綜合）-^> nextpnr-ice40（佈局繞線 + 時序分析）
echo   目標元件：iCE40 HX8K, ct256 封裝
echo  ============================================================
echo.

echo  ---- 1/2  單週期版 mult_comb ----
yosys -q -p "read_verilog 01_mult_comb.v; synth_ice40 -top mult_comb -json mc.json; tee -a report_area.txt stat"
if errorlevel 1 (echo      [X] 綜合失敗 & goto :pipe)
nextpnr-ice40 --hx8k --package ct256 --json mc.json --freq 100 --placer heap 2>&1 | findstr /C:"Max frequency" /C:"ICESTORM_LC" /C:"Device utilisation"

:pipe
echo.
echo  ---- 2/2  三級管線版 mult_pipe3 ----
yosys -q -p "read_verilog 02_mult_pipe3.v; synth_ice40 -top mult_pipe3 -json mp.json; tee -a report_area.txt stat"
if errorlevel 1 (echo      [X] 綜合失敗 & goto :done)
nextpnr-ice40 --hx8k --package ct256 --json mp.json --freq 200 --placer heap 2>&1 | findstr /C:"Max frequency" /C:"ICESTORM_LC" /C:"Device utilisation"

:done
echo.
echo  ============================================================
echo   參考數據（本專案實測，Yosys 0.68 + nextpnr-ice40, HX8K）
echo.
echo                       單週期      三級管線     變化
echo     -------------------------------------------------------
echo     最高時脈         120.15 MHz  180.15 MHz   ★ +50%%
echo     延遲 latency        2 拍        4 拍        +2 拍
echo     吞吐量           每拍 1 筆    每拍 1 筆     一樣
echo     每秒可算          120 M 次    180 M 次     ★ +50%%
echo     -------------------------------------------------------
echo     SB_LUT4             159         133        -16%%
echo     SB_DFF               34         102        ★ +200%%
echo     SB_CARRY             12          66        +450%%
echo.
echo   ★ 結論：管線用【更多正反器】和【更長的延遲】，
echo            換到【更高的時脈】和【更高的每秒處理量】。
echo.
echo   ⚠️ 你自己跑出來的數字可能和上表略有出入 ——
echo      nextpnr 的佈局有隨機性，每次跑都會差個幾 MHz。
echo      加 --seed 數字 可以固定結果。
echo  ============================================================
echo.
