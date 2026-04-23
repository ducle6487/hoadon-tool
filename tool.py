#!/usr/bin/env python3
"""
Hoa Don Dien Tu Auto-Fill Tool
Reads an Excel file, auto-fills the public invoice lookup form at
https://hoadondientu.gdt.gov.vn/lookup, and writes a results Excel file
with the original data plus an embedded screenshot in the last column.

Usage:
    python tool.py invoices.xlsx
    python tool.py invoices.xlsx --auto-captcha   # Claude AI solves CAPTCHA
    python tool.py invoices.xlsx --headless        # no visible browser window

Excel columns (case-insensitive):
    nbmst     - MST người bán (Tax code, 10 or 14 digits) [required]
    lhdon     - Loại hóa đơn (GTGT/HDBH/HDK/...) [default: GTGT]
    khhdon    - Ký hiệu hóa đơn [required]
    shdon     - Số hóa đơn (digits only) [required]
    tgtthue   - Tổng tiền thuế [optional]
    tgtttbso  - Tổng tiền thanh toán [required]
"""

import argparse
import base64
import io
import os
import sys
import time
from datetime import datetime
from pathlib import Path

import openpyxl
import pandas as pd
from openpyxl.drawing.image import Image as XLImage
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter
from PIL import Image as PILImage
from playwright.sync_api import sync_playwright, Page, Locator

# ── Config ────────────────────────────────────────────────────────────────────

OUTPUT_DIR = Path("output")
LOOKUP_URL = "https://hoadondientu.gdt.gov.vn/"
MAX_CAPTCHA_RETRIES = 5

# Thumbnail size embedded in the results Excel
THUMB_W = 1920   # pixels wide
THUMB_H = 1080   # pixels tall (max — aspect ratio is preserved)

INVOICE_TYPE_MAP = {
    "GTGT":   "Hóa đơn giá trị gia tăng",
    "HDBH":   "Hóa đơn bán hàng",
    "HBBTSC": "Hóa đơn bán tài sản công",
    "HDDTQG": "Hóa đơn bán hàng dự trữ quốc gia",
    "HDK":    "Hóa đơn khác",
    "CT":     "Chứng từ được in, phát hàng, sử dụng và quản lý như hóa đơn",
}

# ── CAPTCHA helpers ───────────────────────────────────────────────────────────

def get_captcha_answer(page: Page, auto_solve: bool) -> str:
    img = page.locator(
        "img[src*='captcha'], img[src*='Captcha'], "
        ".ant-form-item:has-text('Mã captcha') img, "
        "img[alt*='captcha']"
    ).first
    try:
        img_bytes = img.screenshot()
    except Exception:
        img_bytes = None

    if img_bytes:
        Path("captcha_last.png").write_bytes(img_bytes)
    print("    [CAPTCHA] captcha_last.png saved — check browser window.")
    return input("    [CAPTCHA] Type the CAPTCHA: ").strip()


# ── Form-fill helpers ─────────────────────────────────────────────────────────

def _clear_fill(loc: Locator, value: str) -> None:
    loc.click()
    loc.press("Control+a")
    loc.press("Backspace")
    loc.fill(value)


def _fill_number(page: Page, label_text: str, value, field_id: str = "") -> bool:
    if value is None or str(value).strip() in ("", "nan"):
        return False
    raw = str(value).replace(",", "").replace(" ", "").strip()
    try:
        raw = str(int(float(raw)))
    except ValueError:
        return False

    inp = None
    # Try by ID first (most reliable)
    if field_id:
        loc = page.locator(f"input#{field_id}")
        if loc.count():
            inp = loc.first

    # Fallback: label text match
    if inp is None:
        item = page.locator(".ant-form-item").filter(has_text=label_text)
        loc = item.locator("input").first
        if loc.count():
            inp = loc

    if inp is None:
        print(f"    [WARN] Could not find input for '{label_text}'")
        return False

    inp.click()
    time.sleep(0.2)
    # Select all (Meta for macOS, Control for Linux/Windows)
    inp.press("Meta+a")
    inp.press("Backspace")
    inp.type(raw, delay=50)
    # Blur to trigger Ant Design value change
    inp.press("Tab")
    return True


def _select_invoice_type(page: Page, lhdon: str) -> None:
    lhdon = lhdon.upper().strip() if lhdon else "GTGT"
    label_text = INVOICE_TYPE_MAP.get(lhdon, INVOICE_TYPE_MAP["GTGT"])
    trigger = (
        page.locator(".ant-form-item")
        .filter(has_text="Loại hóa đơn")
        .locator(".ant-select-selector")
        .first
    )
    trigger.click()
    page.wait_for_selector(".ant-select-dropdown:visible", timeout=5000)
    option = page.locator(
        f'.ant-select-item-option[title*="{label_text}"],'
        f'.ant-select-item-option:has-text("{label_text}")'
    ).first
    if option.count():
        option.click()
    else:
        page.locator(".ant-select-item-option").first.click()


# ── Core browser logic ────────────────────────────────────────────────────────

def fill_form(page: Page, row: dict, auto_solve: bool, captcha_fn=None) -> None:
    page.wait_for_selector(".ant-form", timeout=20000)

    # ── Dismiss any announcement / popup modal that covers the form ───────
    try:
        # Try the close button (X) on the modal
        close_btn = page.locator(
            ".ant-modal-close, "
            ".ant-modal-wrap button.ant-modal-close, "
            "button[aria-label='Close']"
        ).first
        if close_btn.count() and close_btn.is_visible():
            close_btn.click(timeout=3000)
            page.wait_for_timeout(500)
    except Exception:
        pass

    # If a modal is still blocking, press Escape to dismiss it
    try:
        modal = page.locator(".ant-modal-wrap").first
        if modal.count() and modal.is_visible():
            page.keyboard.press("Escape")
            page.wait_for_timeout(500)
    except Exception:
        pass

    mst = str(row.get("nbmst", "")).strip()
    if mst:
        inp = page.locator(
            'input[id*="nbmst"], input[placeholder*="MST"]'
        ).or_(
            page.locator(".ant-form-item").filter(has_text="MST người bán").locator("input")
        ).first
        _clear_fill(inp, mst)

    lhdon = str(row.get("lhdon", "GTGT"))
    try:
        _select_invoice_type(page, lhdon)
    except Exception as exc:
        print(f"    [WARN] Invoice type select failed: {exc}")

    khhdon = str(row.get("khhdon", "")).strip()
    if khhdon:
        inp = page.locator(
            'input[id*="khhdon"], input[placeholder*="Ký hiệu"]'
        ).or_(
            page.locator(".ant-form-item").filter(has_text="Ký hiệu hóa đơn").locator("input")
        ).first
        _clear_fill(inp, khhdon)

    shdon = str(row.get("shdon", "")).strip()
    if shdon:
        inp = page.locator(
            'input[id*="shdon"], input[placeholder*="Số hóa đơn"]'
        ).or_(
            page.locator(".ant-form-item").filter(has_text="Số hóa đơn").locator("input")
        ).first
        _clear_fill(inp, shdon)

    _fill_number(page, "Tổng tiền thuế", row.get("tgtthue"), field_id="tgtthue")
    _fill_number(page, "Tổng tiền thanh toán", row.get("tgtttbso"), field_id="tgtttbso")

    solver = captcha_fn or get_captcha_answer
    captcha_answer = solver(page, auto_solve)
    captcha_inp = page.locator(
        'input[id*="captcha"], input[placeholder*="captcha"], '
        'input[placeholder*="Captcha"], input[placeholder*="mã"]'
    ).or_(
        page.locator(".ant-form-item").filter(has_text="Nhập mã captcha").locator("input")
    ).first
    _clear_fill(captcha_inp, captcha_answer)

    page.locator(
        'button[type="submit"]:has-text("Tìm kiếm"), button:has-text("Tìm kiếm")'
    ).first.click()
    page.wait_for_load_state("networkidle", timeout=20000)
    time.sleep(0.8)


# ── Screenshot embedding ──────────────────────────────────────────────────────

def _make_thumb(screenshot_path: str) -> tuple[io.BytesIO, int, int]:
    """Resize screenshot to thumbnail; return (BytesIO_png, width_px, height_px)."""
    with PILImage.open(screenshot_path) as img:
        img = img.convert("RGB")
        img.thumbnail((THUMB_W, THUMB_H), PILImage.LANCZOS)
        w, h = img.size
        buf = io.BytesIO()
        img.save(buf, format="PNG", optimize=True)
        buf.seek(0)
    return buf, w, h


