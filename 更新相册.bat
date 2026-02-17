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
echo 正在推送到 GitHub 以发布网页...

git add .
git commit -m "Auto-update photos: %date% %time%"
git push origin main

if errorlevel 1 (
    echo.
    echo [警告] 推送失败。请检查网络连接或 Git 配置。
    echo 本地更新已完成，您可以稍后手动推送。
    pause
    exit /b
)

echo.
echo [完成] 网页更新成功！
echo 请访问您的网站查看：https://huruzun.github.io/memory/
pause
