@echo off
CHCP 65001 >NUL
cd /d "%~dp0"
Title Chay Auto Hoa Don Tool

echo ==============================================================
echo        KHOI DONG SERVER HOA DON...
echo ==============================================================

REM --- Tim Python ---
SET "PYTHON_CMD=python"
IF EXIST "%LocalAppData%\Programs\Python\Python312\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python312\python.exe"
) ELSE IF EXIST "%LocalAppData%\Programs\Python\Python311\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python311\python.exe"
) ELSE IF EXIST "%LocalAppData%\Programs\Python\Python310\python.exe" (
    SET "PYTHON_CMD=%LocalAppData%\Programs\Python\Python310\python.exe"
)

REM --- Tat tien trinh cu (neu co) ---
taskkill /F /FI "WINDOWTITLE eq uvicorn*" >nul 2>&1
taskkill /F /IM cloudflared.exe >nul 2>&1

REM --- Cai thu vien ---
echo 📦 Dang kiem tra va cap nhat thu vien he thong...
"%PYTHON_CMD%" -m pip install -r requirements.txt --quiet

REM --- Lay IP noi bo ---
FOR /F "tokens=2 delims=:" %%A IN ('ipconfig ^| findstr /C:"IPv4"') DO (
    SET "LOCAL_IP=%%A"
    GOTO :got_ip
)
:got_ip
SET "LOCAL_IP=%LOCAL_IP: =%"

REM --- Khoi dong server nen ---
echo 🚀 Dang khoi dong server...
start /B "" "%PYTHON_CMD%" -m uvicorn app:app --host 0.0.0.0 --port 8000
timeout /t 2 /nobreak >nul

REM --- Kiem tra / tai cloudflared.exe ---
IF NOT EXIST "cloudflared.exe" (
    echo 🌍 Dang tai cloudflared.exe (chi can 1 lan)...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile 'cloudflared.exe'"
)

REM --- Khoi dong Cloudflare Tunnel ---
SET "TUNNEL_LOG=%TEMP%\cloudflared_tunnel.log"
echo 🌍 Dang tao duong link Internet (Cloudflare Tunnel)...
start /B "" cloudflared.exe tunnel --url http://localhost:8000 > "%TUNNEL_LOG%" 2>&1

REM --- Doi lay public URL (toi da 20 giay) ---
SET "PUBLIC_URL="
SET /A WAIT=0
:wait_loop
timeout /t 1 /nobreak >nul
SET /A WAIT+=1
FOR /F "delims=" %%L IN ('findstr /R "trycloudflare\.com" "%TUNNEL_LOG%" 2^>nul') DO (
    FOR /F "tokens=*" %%U IN ('echo %%L ^| powershell -Command "$input | Select-String -o -Pattern 'https://[a-zA-Z0-9\-]+\.trycloudflare\.com' | %% { $_.Matches.Value } | Select-Object -First 1"') DO (
        SET "PUBLIC_URL=%%U"
    )
)
IF DEFINED PUBLIC_URL GOTO :show_links
IF %WAIT% LSS 20 GOTO :wait_loop

:show_links
echo.
echo ==========================================================
echo ✅ KHOI DONG THANH CONG!
echo 🌐 TRUY CAP VAO TRINH DUYET BANG DUONG LINK DUOI DAY:
echo 👉 May nay:        http://localhost:8000
echo 👉 Mang noi bo:    http://%LOCAL_IP%:8000
IF DEFINED PUBLIC_URL (
    echo 🌍 Internet:       %PUBLIC_URL%
) ELSE (
    echo ⚠️  Internet link chua san sang. Xem log: %TUNNEL_LOG%
)
echo ==========================================================
echo.
echo *Luu y: Giu cua so nay mo de server tiep tuc chay.*
echo *Khi nghi xai thi bam vao file stop_windows.bat de tat.*
echo.
start http://localhost:8000
pause
