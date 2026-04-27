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

## 📦 Cài Đặt "1-Click" (Easy Installation)

Công cụ đã được tối ưu để bạn có thể cài đặt và sử dụng mà không cần gõ lệnh:

### Đối với Windows (PC)
1. Đúp chuột vào **`install_windows.bat`**: Hệ thống sẽ tự động cài đặt Python, thư viện và trình duyệt.
2. Sau khi xong, đúp chuột vào **`start_windows.bat`** để bắt đầu sử dụng.

### Đối với macOS (Macbook)
1. Đúp chuột vào **`start_tool.command`**: Hệ thống sẽ tự động kiểm tra thư viện và bật máy chủ tra cứu ngay lập tức.
2. Khi không dùng nữa, đúp chuột vào **`stop_tool.command`** để dọn dẹp RAM.

---

## 🎮 Cách Sử Dụng (Usage)

1. Mở trình duyệt và truy cập: `http://localhost:8000`
2. Kéo thả file Excel chứa danh sách hóa đơn.
3. Bấm **START** và quan sát 15 Tab làm việc cùng lúc với tốc độ "Nitro".
4. Tải về file ZIP kết quả bao gồm: **Excel (có ảnh)**, **Word (báo cáo tổng hợp)** và toàn bộ **Ảnh gốc**.

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
