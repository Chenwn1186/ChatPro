@echo off
echo Preparing environment...

REM 检测 Python 环境
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Python not found. Please install Python and ensure it is added to PATH.
    pause
    exit /b 1
)

REM 检查是否安装了依赖
echo Checking Python dependencies...
pip show Flask >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Flask not found. Installing dependencies from requirements.txt...
    pip install -r requirements.txt
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to install dependencies. Please check requirements.txt.
        pause
        exit /b 1
    )
)

REM 打包 Flutter 应用
echo Building Flutter application...
cd /d %~dp0
call flutter build windows --release
if %ERRORLEVEL% neq 0 (
    echo Error: Flutter build failed. Please ensure Flutter is installed and configured.
    pause
    exit /b 1
)

REM 启动 Flask 服务器
echo Starting Flask server...
start /b python backend\backend.py

echo Waiting for Flask server to start (5 seconds)...
timeout /t 5 /nobreak

REM 启动打包后的 Flutter 应用
echo Launching Flutter application...
start "" build\windows\x64\runner\Release\chat_pro.exe

echo Done.
pause