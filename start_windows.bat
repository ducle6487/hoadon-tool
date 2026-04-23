@echo off
CHCP 65001 >NUL
cd /d "%~dp0"
Title Chay Auto Hoa Don Tool

echo ==============================================================
echo        KHOI DONG SERVER HOA DON...
echo ==============================================================

echo He thong dang duoc khoi chay ngam, vui long DOI KHONG DONG CUA SO NAY.
echo.
echo ==========================================================
echo ✅ KHOI DONG THANH CONG!
echo 🌐 TRUY CAP VAO TRINH DUYET BANG DUONG LINK DUOI DAY:
echo 👉 http://localhost:8000
echo ==========================================================
echo.

SET "PYTHON_CMD=python"
IF EXIST "%LocalAppData%\Programs\Python\Python311\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python311\python.exe"
) ELSE IF EXIST "%LocalAppData%\Programs\Python\Python312\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python312\python.exe"
) ELSE IF EXIST "%LocalAppData%\Programs\Python\Python310\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python310\python.exe"
)

start http://localhost:8000
"%PYTHON_CMD%" -m uvicorn app:app --port 8000

pause
