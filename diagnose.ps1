<#
.SYNOPSIS
Gemini CLI - 系統自動化診斷腳本

.DESCRIPTION
此腳本會自動收集系統硬體體質、資源瓶頸、錯誤日誌與啟動項，
作為 Gemini AI 診斷的先期數據收集工具。
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Gemini CLI 系統診斷開始 (Phase 2)   " -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# 階段 1：系統體質與環境掃描
# ---------------------------------------------------------
Write-Host "[1/4] 正在掃描系統體質與儲存空間..." -ForegroundColor Green
$sysInfo = Get-ComputerInfo | Select-Object CsModel, OsName, OsVersion, CsProcessors, WindowsProductName
Write-Host "主機板型號: $($sysInfo.CsModel)"
Write-Host "作業系統: $($sysInfo.OsName) ($($sysInfo.OsVersion))"
Write-Host "處理器: $($sysInfo.CsProcessors)"
Write-Host ""

$volumes = Get-Volume | Where-Object {$_.DriveLetter -ne $null}
foreach ($v in $volumes) {
    $freeGB = [math]::Round($v.SizeRemaining / 1GB, 2)
    $totalGB = [math]::Round($v.Size / 1GB, 2)
    Write-Host "磁碟 $($v.DriveLetter): 剩餘 ${freeGB}GB / 總共 ${totalGB}GB"
}
Write-Host ""

# ---------------------------------------------------------
# 階段 2：資源瓶頸即時監控
# ---------------------------------------------------------
Write-Host "[2/4] 正在抓取前 5 大 CPU 效能怪獸..." -ForegroundColor Green
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 -Property Name, CPU, WorkingSet | Format-Table -AutoSize
Write-Host ""

# ---------------------------------------------------------
# 階段 3：穩定性與錯誤日誌
# ---------------------------------------------------------
Write-Host "[3/4] 正在讀取最近 3 筆系統錯誤日誌..." -ForegroundColor Green
try {
    Get-EventLog -LogName System -EntryType Error -Newest 3 | Select-Object TimeGenerated, Source, Message | Format-Table -AutoSize -Wrap
} catch {
    Write-Host "無法讀取日誌或目前無錯誤紀錄。" -ForegroundColor DarkGray
}
Write-Host ""

# ---------------------------------------------------------
# 階段 4：啟動項與服務檢查
# ---------------------------------------------------------
Write-Host "[4/4] 正在列出開機自動啟動的程式..." -ForegroundColor Green
Get-CimInstance Win32_StartupCommand | Select-Object Caption, Command | Format-Table -AutoSize -Wrap
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "           診斷數據收集完畢！           " -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
