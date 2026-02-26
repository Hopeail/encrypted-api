# NTP 时间同步工具 - PowerShell 打包脚本
# 在 Windows PowerShell 中运行

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  NTP 时间同步工具 - 打包脚本" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Python
Write-Host "[1/4] 检查 Python 环境..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  ✓ $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 未找到 Python，请先安装 Python 3.8+" -ForegroundColor Red
    Write-Host "  下载地址：https://www.python.org/downloads/" -ForegroundColor Yellow
    pause
    exit 1
}

# 安装 PyInstaller
Write-Host ""
Write-Host "[2/4] 安装 PyInstaller..." -ForegroundColor Yellow
pip install pyinstaller -q
Write-Host "  ✓ PyInstaller 安装完成" -ForegroundColor Green

# 打包
Write-Host ""
Write-Host "[3/4] 打包生成 EXE..." -ForegroundColor Yellow
pyinstaller --onefile `
    --name "NTP 时间同步" `
    --icon NONE `
    --console `
    ntp_sync.py

# 清理
Write-Host ""
Write-Host "[4/4] 清理临时文件..." -ForegroundColor Yellow
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path "ntp_sync.spec") { Remove-Item -Force "ntp_sync.spec" }

# 完成
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  打包完成！" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "EXE 文件位置：dist\NTP 时间同步.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "使用方法:" -ForegroundColor Yellow
Write-Host "  1. 右键点击 'NTP 时间同步.exe'" -ForegroundColor White
Write-Host "  2. 选择 '以管理员身份运行'" -ForegroundColor White
Write-Host "  3. 程序将自动同步时间到阿里云 NTP 服务器" -ForegroundColor White
Write-Host ""
pause
