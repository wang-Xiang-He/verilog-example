# 批次編譯 + 模擬 + 產生 .gtkw
# 用法:  powershell -File _tools\build.ps1 week02_types_ops
param([Parameter(Mandatory = $true)][string]$WeekDir)

$root = Split-Path $PSScriptRoot -Parent
$dir = Join-Path $root $WeekDir
if (-not (Test-Path $dir)) { Write-Host "找不到 $dir" -ForegroundColor Red; exit 1 }

. "D:\oss-cad-suite\environment.ps1" 2>$null | Out-Null
Push-Location $dir

$tbs = Get-ChildItem "*_tb.v" | Sort-Object Name
$fail = 0
foreach ($tb in $tbs) {
    $n = $tb.BaseName -replace '_tb$', ''
    Write-Host "`n===== $n =====" -ForegroundColor Cyan
    if (-not (Test-Path "$n.v")) { Write-Host "  [X] 缺 $n.v" -ForegroundColor Red; $fail++; continue }

    Remove-Item wave.vcd, sim.out -Force -ErrorAction SilentlyContinue
    $xf = @()
    if (Test-Path "$n.flags") { $xf = Get-Content "$n.flags" | Where-Object { $_.Trim() -ne "" } }
    iverilog -g2012 @xf -o sim.out "$n.v" "$($tb.Name)"
    if ($LASTEXITCODE -ne 0) { Write-Host "  [X] 編譯失敗 $LASTEXITCODE" -ForegroundColor Red; $fail++; continue }

    vvp sim.out
    if ($LASTEXITCODE -ne 0) { Write-Host "  [X] 模擬失敗 $LASTEXITCODE" -ForegroundColor Red; $fail++; continue }

    if (Test-Path wave.vcd) {
        python "$root\_tools\mkgtkw.py" wave.vcd "$n.gtkw"
    } else {
        Write-Host "  [!] 沒有 wave.vcd" -ForegroundColor Yellow
    }
}

Remove-Item wave.vcd, sim.out -Force -ErrorAction SilentlyContinue
Pop-Location
Write-Host "`n========== $WeekDir 完成，失敗 $fail 個 ==========" -ForegroundColor $(if ($fail) { "Red" } else { "Green" })
exit $fail
