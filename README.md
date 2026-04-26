# 🚀 Extreme Turbo: Tool Tra Cứu Hóa Đơn Điện Tử Tự Động 2.0

Phiên bản tối thượng được thiết kế để đạt tốc độ xử lý **50+ hóa đơn/phút** với độ ổn định tuyệt đối và báo cáo chuyên nghiệp.

## 🌟 Tính Năng "Extreme Turbo" Mới Cập Nhật

- **🌊 Đa Luồng Siêu Tốc (Concurrency 15)**: Khởi chạy 15 tab trình duyệt song song, tối ưu hóa băng thông để xử lý hàng loạt cực nhanh.
- **🛡️ Cơ Chế "No-Fail" (5-Pass Retry)**: Tự động lọc các hóa đơn lỗi sau khi kết thúc lượt chạy đầu và thực hiện **5 đợt quét vét** bổ sung, đảm bảo tỉ lệ thành công 100%.
- **🏎️ Hybrid Reload Strategy**: Tiết kiệm 4-5 giây mỗi hóa đơn bằng cách sử dụng **Soft Reset (Làm mới nhanh)** mặc định, chỉ thực hiện tải lại trang (Hard Reload) khi gặp lỗi hoặc bắt đầu phiên mới.
- **🧠 Captcha Hashing Cache**: Ghi nhớ mã Captcha đã giải. Nếu gặp lại ảnh cũ, hệ thống trả kết quả ngay lập tức trong 0.001 giây, bỏ qua bước gọi AI.
- **📸 Extreme Image Stripping**: Tự động chặn tải tất cả ảnh trang trí, font và script theo dõi (G2, Analytics, Facebook...) giúp trang web nhẹ như một bản văn bản, giảm tải CPU & RAM tối đa.
- **📄 Word Report & TOC**: Tự động xuất tệp **Bao_cao_anh_hoa_don.docx** chuyên nghiệp, bao gồm:
  - **Mục lục (Table of Contents)** ở trang đầu để theo dõi trạng thái tất cả hóa đơn.
  - Mỗi hóa đơn được trình bày chi tiết kèm ảnh chụp sắc nét ở các trang tiếp theo.
- **🧹 Zero-Modal Cleanup**: Tự động dọn dẹp các thông báo tin tức, cửa sổ quảng cáo của trang Thuế để ảnh chụp luôn sạch sẽ, không bị che khuất.

## 📦 Cài Đặt (Installation)

Yêu cầu máy tính có cài đặt **Python 3.9+**.

1. **Clone repository này về máy:**
```bash
git clone https://github.com/ducle6487/hoadon-tool.git
cd hoadon-tool
```

2. **Cài đặt các thư viện lõi Python:**
```bash
python3 -m pip install -r requirements.txt
python3 -m pip install python-docx
```

3. **Cài đặt hệ điều hành trình duyệt giả lập Playwright:**
```bash
playwright install chromium
```

## 🎮 Hướng Dẫn Sử Dụng (Usage)

### Dành riêng cho người dùng MacOS (1-Click)
- Chạy **`start_tool.command`**: Khởi động máy chủ giao diện web.
- Chạy **`stop_tool.command`**: Tắt toàn bộ hệ thống và dọn dẹp RAM.

### Chạy thủ công (Mọi hệ điều hành)
```bash
python3 -m uvicorn app:app --port 8000
```
Truy cập: `http://127.0.0.1:8000`

## 📖 Cấu Hình File Excel
File Excel đầu vào cần có tiêu đề cột (dòng 1):
- `nbmst`: MST người bán.
- `khhdon`: Ký hiệu.
- `shdon`: Số hóa đơn.
- `tgtttbso`: Tổng tiền thanh toán.
- `lhdon`: Loại hóa đơn (không bắt buộc, mặc định GTGT).

## 🛠️ Công Nghệ Sử Dụng
- **Playwright**: Browser automation (Chromium).
- **ddddocr**: Local CAPTCHA recognition (0.1s).
- **FastAPI & WebSocket**: Real-time logging UI.
- **python-docx**: Automated Word reporting.

## ⚖️ Giấy Phép
Dự án được xây dựng với mục đích học tập tự động hóa & luồng làm việc cá nhân. Vui lòng tuân thủ quy định truy cập của Cổng tra cứu Thuế Việt Nam.
