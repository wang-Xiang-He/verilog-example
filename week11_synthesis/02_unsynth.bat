@echo off
chcp 65001 >nul
cd /d "%~dp0"
del /q report_unsynth.txt 2>nul

echo.
echo  ============================================================
echo   分別綜合三個模組，看 Yosys 各自怎麼反應
echo  ============================================================
echo.

echo  ---- 1/3  good_design（正確寫法，應該乾乾淨淨）----
yosys -q -p "read_verilog 02_unsynth.v; synth_ice40 -top good_design; tee -a report_unsynth.txt stat"
if %ERRORLEVEL% EQU 0 (echo      結果：綜合成功，沒有警告) else (echo      結果：失敗)
echo.

echo  ---- 2/3  bad_design（有 initial / #延遲 / === ）----
yosys -q -p "read_verilog 02_unsynth.v; synth_ice40 -top bad_design; tee -a report_unsynth.txt stat"
if %ERRORLEVEL% EQU 0 (
    echo      結果：★★ 綜合【成功】了！
    echo             #3 延遲被默默丟掉、initial 被默默處理、=== 被默默化簡。
    echo             工具一句話都沒說 —— 這就是最可怕的「等級 3」。
) else (echo      結果：綜合失敗)
echo.

echo  ---- 3/3  subtle_trap（漏 else 生 latch）----
yosys -q -p "read_verilog 02_unsynth.v; synth_ice40 -top subtle_trap; tee -a report_unsynth.txt stat"
if %ERRORLEVEL% EQU 0 (
    echo      結果：綜合成功
) else (
    echo      結果：★ 綜合【失敗】—— 這是【正確】的行為！
    echo             往上看 Warning：Latch inferred for signal 'latched'
    echo             Yosys 幫你把漏寫 else 擋下來了。
)
echo.

echo  ============================================================
echo   三種結果對照：
echo     good_design   成功、無警告          ← 你要的樣子
echo     subtle_trap   失敗、有 latch 警告   ← 幸運，被擋下來了
echo     bad_design    ★ 成功、無警告        ← 最危險，錯得無聲無息
echo.
echo   面積報告在 report_unsynth.txt
echo  ============================================================
echo.
