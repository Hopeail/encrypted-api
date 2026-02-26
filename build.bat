# NTP 时间同步工具 - 打包脚本
# 在 Windows 上运行此脚本生成 exe 文件

@echo off
chcp 65001 >nul
echo ================================================
echo   NTP 时间同步工具 - 打包脚本
echo ================================================
echo.

REM 检查 Python 是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Python，请先安装 Python 3.8+
    echo 下载地址：https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [1/4] 检查 Python 环境...
python -c "import sys; print(f'Python {sys.version}')"

echo.
echo [2/4] 安装 PyInstaller...
pip install pyinstaller -q

echo.
echo [3/4] 打包生成 EXE...
pyinstaller --onefile ^
    --name "NTP 时间同步" ^
    --icon=NONE ^
    --console ^
    --add-data "README.md;." ^
    ntp_sync.py

echo.
echo [4/4] 清理临时文件...
if exist "build" rmdir /s /q "build"
if exist "ntp_sync.spec" del /q "ntp_sync.spec"

echo.
echo ================================================
echo   打包完成！
echo ================================================
echo.
echo EXE 文件位置：dist\NTP 时间同步.exe
echo.
echo 使用方法:
echo   1. 右键点击 "NTP 时间同步.exe"
echo   2. 选择 "以管理员身份运行"
echo   3. 程序将自动同步时间到阿里云 NTP 服务器
echo.
pause
