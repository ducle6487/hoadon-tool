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

log_queue = asyncio.Queue()
is_processing = False
current_task = None
active_websockets = 0

# Cache ddddocr instance globally for speed
_ocr_instance = None

def _get_ocr():
    global _ocr_instance
    if _ocr_instance is None:
        import ddddocr
        _ocr_instance = ddddocr.DdddOcr(show_ad=False)
    return _ocr_instance


@app.get("/", response_class=HTMLResponse)
async def read_index():
    with open("static/index.html", "r", encoding="utf-8") as f:
        content = f.read()
    return HTMLResponse(content, headers={"Cache-Control": "no-store"})


@app.post("/api/run")
async def run_tool(
    file: UploadFile = File(...),
    headless: bool = Form(False)
):
    global is_processing
    if is_processing:
        return {"error": "Already processing. Please wait for the current task to complete."}

    is_processing = True

    while not log_queue.empty():
        log_queue.get_nowait()

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
                log_queue.put_nowait({"type": "log", "msg": msg.strip()})
            _original_print(*args, **kwargs)
        builtins.print = _ws_print

        try:
            async def auto_captcha_fn(page, auto_solve):
                """Always auto-solve CAPTCHA using Claude or ddddocr."""
                img = page.locator(
                    "img[src*='captcha'], img[src*='Captcha'], "
                    ".ant-form-item:has-text('Mã captcha') img, "
                    "img[alt*='captcha']"
                ).first
                try:
                    img_bytes = await img.screenshot()
                except Exception:
                    img_bytes = None

                if img_bytes:
                    print("    [CAPTCHA] Auto-solving (ddddocr)…")
                    ocr = _get_ocr()
                    ans = ocr.classification(img_bytes)
                    print(f"    [CAPTCHA] Answer: '{ans}'")
                    return ans

                return ""

            async def progress_cb(current, total):
                await log_queue.put({"type": "progress", "current": current, "total": total})

            res = await tool.process_rows_async(
                str(filepath), auto_solve=True, headless=headless,
                captcha_fn=auto_captcha_fn,
                progress_callback=progress_cb
            )
            await log_queue.put({"type": "done", "file": res})
        except Exception as e:
            await log_queue.put({"type": "error", "msg": str(e)})
        finally:
            builtins.print = _original_print
            is_processing = False

    global current_task
    current_task = asyncio.create_task(async_runner())
    return {"message": "Started", "filename": file.filename}


def cleanup_after_download(filepath: str):
    """Delete the result file and clear the output folder of screenshots."""
    # Delete the downloaded excel file
    try:
        if os.path.exists(filepath):
            os.remove(filepath)
    except Exception as e:
        print(f"Cleanup error (filepath): {e}")
        
    # Delete all screenshots in the output folder
    try:
        if os.path.exists("output"):
            shutil.rmtree("output")
        os.makedirs("output", exist_ok=True)
    except Exception as e:
        print(f"Cleanup error (output): {e}")

@app.get("/api/download")
async def download_result(filepath: str, background_tasks: BackgroundTasks):
    background_tasks.add_task(cleanup_after_download, filepath)
    return FileResponse(filepath, filename=Path(filepath).name)


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            msg = await log_queue.get()
            await websocket.send_json(msg)
    except WebSocketDisconnect:
        global current_task
        if current_task and not current_task.done():
            # Yêu cầu hủy tiến trình ngầm định. Task async_runner sẽ tự dọn dẹp Chromium và đặt lại các trạng thái an toàn.
            current_task.cancel()

