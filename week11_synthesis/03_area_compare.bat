@echo off
chcp 65001 >nul
cd /d "%~dp0"
del /q report_area.txt 2>nul

echo.
echo  ============================================================
echo   把 8 個模組分別綜合，比較面積
echo  ============================================================
echo.

for %%M in (share_bad share_good mul9_bad mul9_good match_bad match_good pri_ifelse pri_casez) do (
    echo  ---- %%M ----
    yosys -p "read_verilog 03_area_compare.v; synth_ice40 -top %%M; tee -a report_area.txt stat" > nul 2>&1
    if errorlevel 1 (echo      [X] 綜合失敗) else (echo      OK)
)

echo.
echo  ============================================================
echo   完整報告寫在 report_area.txt
echo.
echo   用這個指令把重點抓出來：
echo       findstr /C:"===" /C:"SB_LUT4" /C:"SB_CARRY" /C:"cells" report_area.txt
echo  ============================================================
echo.
