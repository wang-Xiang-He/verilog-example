@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   佈局繞線流程：拆開來一步一步看
echo   （第 15 週的 build.bat 是把這些包成一鍵）
echo  ============================================================
echo.

echo  ---- 第 1 步：綜合 ----
echo        RTL -^> 邏輯閘網表。這時候還【不知道】要擺在晶片的哪裡。
echo.
yosys -q -p "read_verilog 01_pnr_flow.v; synth_ice40 -top pnr_demo -json 01_pnr_flow.json; stat"
if errorlevel 1 (echo [X] 綜合失敗 & exit /b 1)
echo.
echo        產出 01_pnr_flow.json（純文字，可以打開看）
echo.

echo  ---- 第 2 步：佈局繞線 ----
echo        決定每個 LUT 擺在晶片的哪一格、線怎麼繞。
echo        ★ 這是整條流程裡【最花時間】的一步，
echo          大型設計可以跑好幾個小時。
echo.
nextpnr-ice40 --hx8k --package ct256 --json 01_pnr_flow.json --pcf pins.pcf --asc 01_pnr_flow.asc --freq 50 --placer heap --seed 1
if errorlevel 1 (echo [X] 佈局繞線失敗 & exit /b 1)
echo.
echo        產出 01_pnr_flow.asc
echo.

echo  ---- 第 3 步：靜態時序分析 ----
icetime -d hx8k -mtr 01_pnr_flow.rpt 01_pnr_flow.asc
echo.
echo        產出 01_pnr_flow.rpt（★ 這份要看，02_timing_report.bat 會解釋）
echo.

echo  ---- 第 4 步：打包 ----
icepack 01_pnr_flow.asc 01_pnr_flow.bin
echo        產出 01_pnr_flow.bin
echo.

echo  ============================================================
echo   ★★ 這一步和「綜合」差在哪？
echo.
echo     綜合（第 11 週）回答的是：「要用幾顆什麼元件？」
echo     佈局繞線回答的是：「這些元件擺在哪？線怎麼走？」
echo.
echo     ★ 同一份網表，擺法不同，最高時脈可以差【好幾成】——
echo       因為晶片上的【走線本身也有延遲】。
echo       兩顆邏輯單元擺得近，訊號跑得快；擺得遠，就慢。
echo.
echo     這就是為什麼 nextpnr 要花那麼多時間在「擺」這件事上。
echo.
echo   ★ 試試看換一個 seed：
echo       nextpnr-ice40 --hx8k --package ct256 --json 01_pnr_flow.json ^
echo           --pcf pins.pcf --asc t.asc --freq 50 --placer heap --seed 7
echo     同一份設計，最高時脈會不一樣 —— 佈局是有隨機性的啟發式演算法。
echo  ============================================================
echo.
