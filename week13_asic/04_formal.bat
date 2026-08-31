@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   形式驗證：用數學證明，不是用測試
echo   工具：SymbiYosys (sby) + z3 定理證明器
echo  ============================================================
echo.

echo  ---- 1/2  有 bug 的版本（預期【失敗】）----
echo.
sby -f 04_formal_buggy.sby
echo.
if errorlevel 1 (
    echo      ★ 如預期【失敗】—— 這就是我們要的結果。
    echo        證明器找到了一組會出事的輸入，寫在：
    echo          04_formal_buggy\engine_0\trace.vcd
    echo        用 gtkwave 打開就看得到完整過程。
) else (
    echo      [X] 竟然通過了？bug 應該要被抓到才對。
)

echo.
echo  ---- 2/2  修好的版本（預期【成功】）----
echo.
sby -f 04_formal_fixed.sby
echo.
if errorlevel 1 (
    echo      [X] 沒過 —— 修法有問題
) else (
    echo      ★ 通過！而且是 successful proof by k-induction ——
    echo        這【不是】「測了 20 拍都沒事」，
    echo        是【數學證明】它在任何長度、任何輸入下都不會違反。
)

echo.
echo  ============================================================
echo   反例長什麼樣（buggy 版實際跑出來的）
echo.
echo     cycle  rst_n  wr  rd  wp  rp  empty  full  count
echo     ------------------------------------------------------
echo         1     1    1   0   0   0    1     0      0
echo         2     1    1   0   1   0    0     0      1
echo         ...           連續寫入，沒有讀
echo         8     1    1   0   7   0    0     0      7
echo         9     1    1   0   8   0    0     0      8   ← 這裡已經滿了
echo        10     1    1   1   9   0    0     1      9   ← ★★ 但 full 才剛跳起來
echo.
echo   ★★ 看第 9 和第 10 拍：
echo.
echo       第 9 拍  count 已經是 8（滿了），但 full 還是 0
echo                因為 full 被上了正反器，要下一拍才反應
echo       第 10 拍 那一拍的寫入沒被擋住 -^> count 變成 9
echo                容量只有 8，第 9 筆把第 1 筆蓋掉了
echo.
echo   ★ 要用模擬抓到這個 bug，你得【連續寫 9 次中間一次都不讀】。
echo     隨機測試灌到這種序列的機率不高，
echo     而且就算灌到了，症狀只是「某一筆資料不見」，
echo     很容易被當成別的問題。
echo.
echo     形式驗證花了不到 1 秒就把它找出來，還附完整波形。
echo  ============================================================
echo.
echo   ⚠️ 注意 .sby 檔【只能用英文】。
echo      sby 用系統語系（cp950）讀設定檔，寫中文會直接
echo      UnicodeDecodeError 掛掉。中文說明放 README.md。
echo.
