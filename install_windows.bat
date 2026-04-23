@echo off
CHCP 65001 >NUL
Title Cai Dat Auto Hoa Don Tool

echo ==============================================================
echo        MAU CAI DAT CONG CU AUTO HOA DON CHO WINDOWS
echo ==============================================================
echo.

echo Kiem tra nen tang Python...
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ----------------------------------------------------
    echo [CANH BAO] May tinh cua ban chua cai dat Python!
    echo Dang thao tac mo trinh duyet de tai file cai dat Python...
    echo.
    echo   *** LUU Y CUC KY QUAN TRONG ***
    echo O bang cai dat Python hien len, ban BAT BUOC phai tich chon o:
    echo "[x] Add Python.exe to PATH" o muc duoi cung!
    echo Sau do moi bam Install Now. Neu khong Tool se khong chay duoc!
    echo ----------------------------------------------------
    start https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
    echo Sau khi file tai ve, hay cai dat roi MO LAI file nay nhe!
    pause
    exit /b
)

echo.
echo ----------------------------------------------------
echo [1/2] Dang cai dat cac phan mem va thu vien loi...
echo ----------------------------------------------------
pip install -r requirements.txt

echo.
echo ----------------------------------------------------
echo [2/2] Dang tai trinh duyet gia lap Playwright...
echo ----------------------------------------------------
playwright install chromium

echo.
echo ==============================================================
echo  [HOAN TAT] Cai dat thanh cong ruc ro!
echo  Bay gio ban chi can nhap dup chuot vao file 'start_windows.bat' la xai thoi.
echo  Ban co the tat cua so nay.
echo ==============================================================
pause
