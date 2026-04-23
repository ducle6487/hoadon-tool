@echo off
CHCP 65001 >NUL
cd /d "%~dp0"
Title Cai Dat Auto Hoa Don Tool

echo ==============================================================
echo        CAI DAT CONG CU AUTO HOA DON CHO WINDOWS
echo ==============================================================
echo.

echo [1/3] Kiem tra va cai dat Python tu dong...
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo May tinh chua co Python. Dang tu dong bat dau qua trinh tai xuong...
    echo (Vui long khong tat cua so nay, he thong dang lam viec het suc minh!)
    echo.
    curl -L -o python_installer.exe https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
    
    echo Dang hoan tat cai dat thong minh (Giau kin, tu dong 100%%)...
    start /wait "" "%~dp0python_installer.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
    del "%~dp0python_installer.exe"
    
    :: Nhan dien PATH ngay lap tuc trong phien hien tai
    SET "PATH=%PATH%;%LocalAppData%\Programs\Python\Python311\;%LocalAppData%\Programs\Python\Python311\Scripts\"
    
    echo Cai dat Python hoan tat thanh cong!
) ELSE (
    echo Da phat hien Python tren he thong!
)

echo.
echo ----------------------------------------------------
echo [2/3] Dang cai dat cac phan mem va thu vien loi...
echo ----------------------------------------------------
pip install -r requirements.txt

echo.
echo ----------------------------------------------------
echo [3/3] Dang tai trinh duyet gia lap Playwright...
echo ----------------------------------------------------
playwright install chromium

echo.
echo ==============================================================
echo  [HOAN TAT] Cai dat thanh cong cham diem 10!
echo  Bay gio ban chi can nhap dup chuot vao file 'start_windows.bat' la xai thoi.
echo  Ban co the TẮT cua so MAU DEN nay.
echo ==============================================================
pause
