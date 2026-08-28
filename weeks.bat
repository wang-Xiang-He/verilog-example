@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

pushd "%~dp0"

echo.
echo  ============================================================
echo   所有週次與範例
echo  ============================================================

for /d %%D in (week*) do (
    set "HAS="
    for %%F in ("%%D\*_tb.v") do set "HAS=1"

    if defined HAS (
        echo.
        echo   [ %%D ]
        echo      cd %%D
        for %%F in ("%%D\*_tb.v") do (
            set "B=%%~nF"
            echo      sim !B:_tb=!
        )
    ) else (
        echo.
        echo   [ %%D ]  ^(還沒建，之後補^)
    )
)

echo.
echo  ------------------------------------------------------------
echo   用法：先 cd 進資料夾，再 sim 範例名稱
echo   例如： cd week03_comb_seq
echo          sim 04_blocking_vs_non
echo  ------------------------------------------------------------
echo.

popd
endlocal
