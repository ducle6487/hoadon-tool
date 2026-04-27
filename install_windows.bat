@echo off
CHCP 65001 >NUL
cd /d "%~dp0"
Title Cai Dat Auto Hoa Don Tool

echo ==============================================================
echo        CAI DAT CONG CU AUTO HOA DON CHO WINDOWS
echo ==============================================================
echo.

echo [1/3] Kiem tra va cai dat Python tu dong...

SET "PYTHON_CMD=python"
python --version >nul 2>&1
IF %ERRORLEVEL% EQU 0 GOTO PYTHON_EXISTS

IF EXIST "%LocalAppData%\Programs\Python\Python311\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python311\python.exe"
    GOTO PYTHON_EXISTS
)
IF EXIST "%LocalAppData%\Programs\Python\Python312\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python312\python.exe"
    GOTO PYTHON_EXISTS
)
IF EXIST "%LocalAppData%\Programs\Python\Python310\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python310\python.exe"
    GOTO PYTHON_EXISTS
)

echo May tinh chua co Python. Dang tu dong bat dau qua trinh tai xuong...
echo Xin vui long khong tat cua so nay, he thong dang lam viec het suc minh!
echo.
echo Dang tai trinh cai dat ve may...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe' -OutFile 'python_installer.exe'"

IF NOT EXIST "python_installer.exe" GOTO DOWNLOAD_FAILED

echo Dang hoan tat cai dat thong minh (Giau kin, tu dong 100%%)...
start /wait "" "%~dp0python_installer.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
del "%~dp0python_installer.exe"

SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python311\python.exe"
echo Cai dat Python hoan tat thanh cong!
GOTO INSTALL_DEPS

:DOWNLOAD_FAILED
echo.
echo X_X [LOI MANG] Khong the tai duoc file cai dat Python tu dong. 
echo Nguyen nhan thuong la do Firewall hoac mang Internet qua yeu.
echo Giai phap: Ban thong cam mo Google, tu tai va cai dat Python 3.11 roi check vao o Add to PATH nhe.
pause
exit /b

:PYTHON_EXISTS
echo Da phat hien Python tren he thong!

:INSTALL_DEPS
echo.
echo ----------------------------------------------------
echo [2/3] Dang cai dat cac thu vien loi...
echo ----------------------------------------------------
"%PYTHON_CMD%" -m pip install -r requirements.txt

echo.
echo ----------------------------------------------------
echo [3/3] Dang tai trinh duyet gia lap Playwright...
echo ----------------------------------------------------
"%PYTHON_CMD%" -m playwright install chromium

echo.
echo ==============================================================
echo  [HOAN TAT] Cai dat thanh cong ruc ro!
echo  Tool da san sang o che do "Nitro Boost" (Sieu toc - 15 Tab).
echo  Bay gio ban chi can nhap dup chuot vao file 'start_windows.bat' la xai.
echo  Ban co the TAT cua so nay.
echo ==============================================================
pause
