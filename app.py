import asyncio
import base64
import os
import shutil
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, File, UploadFile, WebSocket, WebSocketDisconnect, Form, BackgroundTasks
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles

import tool

app = FastAPI(title="Hoa Don Tools UI")

os.makedirs("static", exist_ok=True)
os.makedirs("uploads", exist_ok=True)

app.mount("/static", StaticFiles(directory="static"), name="static")

active_websockets = set()
is_processing = False
current_task = None
_ocr_instance = None

def _get_ocr():
    global _ocr_instance
    if _ocr_instance is None:
        import ddddocr
        _ocr_instance = ddddocr.DdddOcr(show_ad=False)
    return _ocr_instance

async def broadcast_log(msg: dict):
    """Send log message to all connected clients."""
    if not active_websockets: return
    disconnected = []
    for ws in active_websockets:
        try: await ws.send_json(msg)
        except: disconnected.append(ws)
    for ws in disconnected: active_websockets.remove(ws)

@app.get("/", response_class=HTMLResponse)
async def read_index():
    with open("static/index.html", "r", encoding="utf-8") as f:
        content = f.read()
    return HTMLResponse(content, headers={"Cache-Control": "no-store"})

@app.post("/api/run")
async def run_tool(file: UploadFile = File(...), headless: bool = Form(False)):
    global is_processing
    if is_processing:
        return {"error": "Already processing. Please wait for current task."}
    is_processing = True

    filepath = Path("uploads") / file.filename
    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    async def async_runner():
        global is_processing
        import builtins
        _original_print = builtins.print
        def _ws_print(*args, **kwargs):
            msg = " ".join(str(a) for a in args)
            if msg.strip():
                asyncio.create_task(broadcast_log({"type": "log", "msg": msg.strip()}))
            _original_print(*args, **kwargs)
        builtins.print = _ws_print

        await broadcast_log({"type": "log", "msg": ">> Đang chuẩn bị môi trường xử lý song song..."})
        await broadcast_log({"type": "log", "msg": ">> Đang khởi chạy trình duyệt lõi (Chromium)..."})

        try:
            async def auto_captcha_fn(page, auto_solve):
                img = page.locator("img[src*='captcha'], img[src*='Captcha'], .ant-form-item:has-text('Mã captcha') img, img[alt*='captcha']").first
                img_bytes = await img.screenshot()
                if img_bytes:
                    await broadcast_log({"type": "log", "msg": "    [CAPTCHA] Giải mã tự động..."})
                    ans = _get_ocr().classification(img_bytes)
                    await broadcast_log({"type": "log", "msg": f"    [CAPTCHA] Kết quả: '{ans}'"})
                    return ans
                return ""

            async def progress_cb(current, total):
                await broadcast_log({"type": "progress", "current": current, "total": total})

            res = await tool.process_rows_async(
                str(filepath), auto_solve=True, headless=headless,
                captcha_fn=auto_captcha_fn, progress_callback=progress_cb
            )
            await broadcast_log({"type": "done", "file": res})
        except Exception as e:
            await broadcast_log({"type": "log", "msg": f">> LỖI: {str(e)}"})
            await broadcast_log({"type": "error", "msg": str(e)})
        finally:
            builtins.print = _original_print
            is_processing = False

    global current_task
    current_task = asyncio.create_task(async_runner())
    return {"message": "Started"}

def cleanup_after_download(filepath: str):
    try:
        if os.path.exists(filepath): os.remove(filepath)
        if os.path.exists("output"): shutil.rmtree("output")
        os.makedirs("output", exist_ok=True)
    except: pass

@app.get("/api/download")
async def download_result(filepath: str, background_tasks: BackgroundTasks):
    background_tasks.add_task(cleanup_after_download, filepath)
    return FileResponse(filepath, filename=Path(filepath).name)

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_websockets.add(websocket)
    try:
        while True: await websocket.receive_text()
    except WebSocketDisconnect:
        active_websockets.remove(websocket)
