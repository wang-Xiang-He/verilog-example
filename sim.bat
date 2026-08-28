@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo.
    echo   用法：sim ^<範例名稱^>
    echo.
    echo   例如：sim 01_gates
    echo         會編譯 01_gates.v + 01_gates_tb.v，跑模擬，然後開波形
    echo.
    echo   這個資料夾裡可以跑的範例：
    for %%F in (*_tb.v) do (
        set "B=%%~nF"
        echo         sim !B:_tb=!
    )
    echo.
    goto fail
)

set "N=%~1"
set "GUI=1"
if /i "%~2"=="/nogui" set "GUI=0"

if not exist "%N%.v" (
    echo   [X] 找不到設計檔 %N%.v
    goto fail
)
if not exist "%N%_tb.v" (
    echo   [X] 找不到測試檔 %N%_tb.v
    goto fail
)

if exist wave.vcd del /q wave.vcd
if exist sim.out  del /q sim.out

echo.
rem 若有同名的 .flags 檔，把裡面的內容當成額外的 iverilog 參數
set "XFLAGS="
if exist "%N%.flags" (
    for /f "usebackq delims=" %%L in ("%N%.flags") do set "XFLAGS=!XFLAGS! %%L"
)

echo [1/3] 編譯 %N%.v + %N%_tb.v ...
if defined XFLAGS echo       額外參數：!XFLAGS!
iverilog -g2012 !XFLAGS! -o sim.out "%N%.v" "%N%_tb.v" 2>_iverilog.log
set "RC=!ERRORLEVEL!"
rem 濾掉閘級模擬時大量無害的警告，只留下真正該看的訊息
if exist _iverilog.log (
    findstr /V /C:"Timing checks are not supported" /C:"Choosing typ expression" _iverilog.log
    del /q _iverilog.log
)
if !RC! NEQ 0 (
    echo   [X] 編譯失敗，結束碼 = !RC!
    echo       ^(0xC0000139/0xC0000135 之類的負數 = PATH 少了 oss-cad-suite\lib，請用 env.bat 開視窗^)
    goto fail
)
echo       OK

echo.
echo [2/3] 模擬 ...
echo ----------------------------------------------------------
vvp sim.out
set "RC=!ERRORLEVEL!"
echo ----------------------------------------------------------
if !RC! NEQ 0 (
    echo   [X] 模擬失敗，結束碼 = !RC!
    goto fail
)

if not exist wave.vcd (
    echo   [!] 沒有產生 wave.vcd —— 測試檔裡要有 $dumpfile / $dumpvars
    goto done
)

if "!GUI!"=="0" (
    echo.
    echo [3/3] 略過 GTKWave ^(有 /nogui^)
    goto done
)

echo.
echo [3/3] 開啟波形 ...
if exist "%N%.gtkw" (
    start "" gtkwave "%CD%\%N%.gtkw"
    echo       用 %N%.gtkw ^(已預設好訊號與顏色^)
) else (
    start "" gtkwave "%CD%\wave.vcd"
    echo       用 wave.vcd ^(要自己拉訊號^)
)

:done
echo.
echo 完成。
endlocal & exit /b 0

:fail
echo.
endlocal & exit /b 1
