@echo off
chcp 65001 >nul
cd /d "%~dp0"
setlocal

rem ============================================================
rem   FPGA 完整流程：Verilog -> bitstream
rem
rem   用法：  build.bat <檔名不含.v> <頂層模組名>
rem   例如：  build.bat 01_blink blink
rem
rem   ★ 這支腳本做的事，就是課本第 2.5 節那 40 頁 Vivado 截圖
rem     在做的同一件事，只是用開源工具、三行指令搞定。
rem ============================================================

if "%~2"=="" (
    echo.
    echo  用法： build.bat ^<檔名不含.v^> ^<頂層模組名^>
    echo.
    echo  例如：
    echo      build.bat 01_blink   blink
    echo      build.bat 02_pwm     pwm
    echo      build.bat 03_button  button_counter
    echo      build.bat 04_seg7    seg7_top
    echo      build.bat 05_uart_tx uart_tx_top
    echo.
    exit /b 1
)

set SRC=%~1
set TOP=%~2
set DEV=--hx8k
set PKG=ct256
set PCF=pins_hx8k.pcf

echo.
echo  ============================================================
echo   FPGA 建置流程： %SRC%.v  頂層=%TOP%
echo   目標元件： iCE40 HX8K, %PKG% 封裝
echo  ============================================================
echo.

rem ---- 第 1 步：綜合 ----
echo  [1/3] 綜合 (yosys) ...
yosys -q -p "read_verilog %SRC%.v; synth_ice40 -top %TOP% -json %SRC%.json; stat"
if errorlevel 1 (
    echo.
    echo  [X] 綜合失敗。先確認 iverilog 模擬跑得過，再回來。
    exit /b 1
)
echo       -^> %SRC%.json
echo.

rem ---- 第 2 步：佈局繞線 ----
echo  [2/3] 佈局繞線 + 時序分析 (nextpnr-ice40) ...
nextpnr-ice40 %DEV% --package %PKG% --json %SRC%.json --pcf %PCF% --asc %SRC%.asc --freq 12 --placer heap
if errorlevel 1 (
    echo.
    echo  [X] 佈局繞線失敗。常見原因：
    echo      - %PCF% 裡沒有定義到你用的某個腳位名稱
    echo      - 資源不夠（LUT 或正反器用超過）
    echo      - 時序不滿足（會顯示 FAIL at ... MHz）
    exit /b 1
)
echo       -^> %SRC%.asc
echo.

rem ---- 第 3 步：打包成 bitstream ----
echo  [3/3] 產生 bitstream (icepack) ...
icepack %SRC%.asc %SRC%.bin
if errorlevel 1 (
    echo  [X] 打包失敗
    exit /b 1
)
echo       -^> %SRC%.bin
echo.

rem ---- 額外：靜態時序分析報告 ----
echo  [額外] 靜態時序分析 (icetime) ...
icetime -d hx8k -mtr %SRC%.rpt %SRC%.asc
echo       -^> %SRC%.rpt
echo.

echo  ============================================================
echo   ★★ 完成！%SRC%.bin 就是【真正的 bitstream】。
echo.
echo   這個檔案是真的 —— 如果你有一塊 iCE40 HX8K 開發板，
echo   直接 iceprog %SRC%.bin 就會跑起來。
echo   沒有板子也沒關係，檔案本身是完整且正確的。
echo.
echo   產生的檔案：
for %%F in (%SRC%.json %SRC%.asc %SRC%.bin %SRC%.rpt) do (
    if exist %%F (
        for %%S in (%%F) do echo       %%F   %%~zS bytes
    )
)
echo.
echo   各檔案是什麼：
echo     .json  綜合後的網表（給 nextpnr 吃）
echo     .asc   佈局繞線結果（文字檔，可以打開看）
echo     .bin   ★ bitstream，燒進晶片的就是這個
echo     .rpt   靜態時序分析報告，看最高時脈
echo  ============================================================
echo.
endlocal
