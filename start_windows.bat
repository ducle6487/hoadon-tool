@echo off
CHCP 65001 >NUL
Title Chay Auto Hoa Don Tool

echo ==============================================================
echo        KHOI DONG SERVER HOA DON...
echo ==============================================================

echo He thong dang duoc khoi chay ngam, vui long DOI KHONG DONG CUA SO NAY.
echo An phuong thuc chay:
echo python -m uvicorn app:app --port 8000
echo.

start http://localhost:8000
python -m uvicorn app:app --port 8000

pause
