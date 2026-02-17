@echo off
chcp 65001 > nul
cd /d "%~dp0"
echo 正在更新相册数据...
echo Scanning photos...

powershell -NoProfile -ExecutionPolicy Bypass -File "tools\sync_photos.ps1"

if errorlevel 1 (
    echo.
    echo [错误] 脚本执行失败。
    echo 请检查是否已将照片放入 photos 目录。
    pause
    exit /b
)

echo.
echo [成功] 相册数据已更新！
echo 请在浏览器中刷新网页查看最新照片。
pause
