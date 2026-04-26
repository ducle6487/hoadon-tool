---
name: extreme_invoice_lookup_v2
description: Chuyên gia tra cứu hóa đơn điện tử siêu tốc với khả năng xử lý song song 15 luồng, giải mã CAPTCHA thông minh và báo cáo Word/Excel tự động.
---

# 🚀 Extreme Invoice Lookup Skill

Kỹ năng này cho phép trình trợ lý AI vận hành và bảo trì công cụ tra cứu hóa đơn điện tử tự động trên cổng `hoadondientu.gdt.gov.vn`.

## 🛠️ Kiến Trúc "Extreme Turbo"

AI cần nắm vững các thành phần cốt lõi sau để duy trì hiệu suất:

1. **Worker Pool (15 Tabs)**: Sử dụng `asyncio.Queue` và `persistent_worker` để duy trì 15 tab trình duyệt Chromium chạy song song.
2. **Hybrid Reload**:
   - `Soft Reset`: Nhấn nút "Làm mới" (Fast) để chuyển dòng.
   - `Hard Reload`: Thực hiện `page.goto` (Safe) khi gặp lỗi mạng hoặc IP.
3. **Resource Stripping**: Luôn luôn chặn (block) các tài nguyên nặng:
   - Resource Types: `font`, `media`, `image` (ngoại trừ logo & captcha).
   - URL Domains: `google-analytics.com`, `facebook.net`, `g2.js`, telemetry.
4. **Captcha Accuracy**:
   - Pre-processing: Phóng to 2x, Grayscale, Contrast Enhancement trước khi giải.
   - Hashing: MD5 Hashing ảnh để bypass giải mã nếu lặp lại ảnh cũ.

## 📋 Quy Trình Xử Lý "No-Fail"

Để đảm bảo tỉ lệ thành công 100%, hãy tuân thủ quy trình:

1. **Main Pass**: Chạy toàn bộ danh sách Excel.
2. **Post-Cleanup Modals**: Luôn thực hiện xóa các phần tử Modal/News bằng JavaScript trước khi chụp ảnh để tránh che khuất dữ liệu.
3. **5-Pass Retry**: Nếu còn dòng lỗi, tự động lập lịch chạy lại tối đa 5 lượt cho các dòng đó.
4. **Final Export**:
   - Excel: Đính kèm ảnh thumbnail co giãn.
   - Word: Tạo trang mục lục báo cáo và chèn toàn bộ ảnh chi tiết.
   - ZIP: Nén toàn bộ `OUTPUT_DIR`.

## ⚠️ Lưu Ý Quan Trọng Cho AI

- **Rate Limiting**: Nếu trang Thuế phản hồi lỗi 503 hoặc 403, hãy hạ `MAX_CONCURRENT` xuống 8-10 và tăng `stagger` lên 0.5s.
- **CAPTCHA**: Mã captca của trang Thuế Việt Nam luôn có độ dài 6 ký tự. Nếu kết quả OCR không phải 6 ký tự, hãy tự động làm mới ảnh và thử lại.
- **Selectors**: Luôn ưu tiên dùng `placeholder` hoặc `css selector` bền vững vì ID của trang Thuế có thể thay đổi theo từng phiên React.

## 🎮 Lệnh Vận Hành Nhanh

- Chạy Web UI: `python3 -m uvicorn app:app --port 8000`
- Cài đặt dependency: `python3 -m pip install -r requirements.txt python-docx`
- Cài đặt trình duyệt: `playwright install chromium`
