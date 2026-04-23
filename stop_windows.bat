@echo off
CHCP 65001 >NUL
cd /d "%~dp0"
Title Tat Auto Hoa Don Tool

echo ==============================================================
echo        DANG DONG CA HA HE THONG...
echo ==============================================================
echo.

echo Dang tat server uvicorn...
taskkill /F /IM python.exe /T >nul 2>&1
taskkill /F /IM uvicorn.exe /T >nul 2>&1

echo.
echo ==============================================================
echo  [HOAN TAT] Da huy toan bo cac server dang chay ngam!
echo ==============================================================
pause
