# Tool Tra Cứu Hóa Đơn Điện Tử Tự Động (Auto-Invoice Fetcher)

Công cụ tự động hóa việc tra cứu hàng loạt hóa đơn điện tử trên cổng thông tin Tổng cục Thuế Việt Nam (`hoadondientu.gdt.gov.vn`). Sử dụng **Playwright** kết hợp **FastAPI** và giao diện Web UI siêu mượt với **WebSocket**.

## 🚀 Tính Năng Nổi Bật

- **Tự Động Trải Nghiệm Mượt Mà (Web UI)**: Trải nghiệm sử dụng 100% qua web, kéo & thả file Excel. Phản hồi luồng nhật ký (log) theo thời gian thực (Real-time).
- **Vượt CAPTCHA "Offline" Siêu Việt**: Tích hợp `ddddocr` tự động nhận dạng mã CAPTCHA cục bộ với tốc độ siêu nhanh (0.1 giây), không tốn phí gọi API bên thứ ba.
- **Tiến Trình Chạy Ngầm Bền Bỉ**:
  - Tự động bỏ qua thời gian chết (Timeout) khi trang thuế bị lỗi giao diện thay vì việc bị kẹt (Freeze).
- **Bảo Vệ Tính Năng & RAM**: Nút Hủy / F5 dọn dẹp sạch sẽ. Chặn luồng độc lập chống lỗi chồng chéo (Race Condition).
- **Trích Xuất Báo Cáo Xịn Xò**: 
  - Ảnh chụp màn hình toàn trang được chèn và co giãn vừa khít vào file Excel!
  - Tự động xóa file rác sau khi tải xuống.
- **Duyệt Web Từ Xa (Remote Tunnel)**: Hỗ trợ tạo đường hầm (Cloudflare Tunnel) để sử dụng công cụ từ điện thoại mượt mà, cách ly bộ lọc IP nước ngoài của Tổng Cục Thuế.

## 📦 Cài Đặt (Installation)

Yêu cầu máy tính có cài đặt **Python 3.9+**.

1. **Clone repository này về máy:**
```bash
git clone https://github.com/ducle6487/hoadon-tool.git
cd hoadon-tool
```

2. **Cài đặt các thư viện lõi Python:**
```bash
pip install -r requirements.txt
```

3. **Cài đặt hệ điều hành trình duyệt giả lập Playwright:**
```bash
playwright install chromium
```

## 🎮 Hướng Dẫn Sử Dụng (Usage)

### Dành riêng cho người dùng MacOS (Chỉ cần 1-Click)
Trong thư mục chứa code, bạn đã được cấp sẵn 2 tệp kịch bản cực kỳ tiện lợi:
- Đúp chuột vào **`start_tool.command`**: Máy chủ sẽ tự động bật ngầm, đồng thời máy sẽ tự động kết nối và in ra đường dẫn Cloudflare Tunnel (`https://...trycloudflare.com`) giúp bạn truy cập trực tiếp bằng Điện thoại hoặc Máy tính khác mà không cần cấu hình phức tạp.
- Đúp chuột vào **`stop_tool.command`**: Dọn dẹp tắt hoàn toàn mọi tiến trình đang chạy ẩn để bảo vệ RAM.

### Chạy thủ công trên Terminal (Mọi hệ điều hành)
Mở Terminal và bật máy chủ cục bộ bằng dòng lệnh:
```bash
python -m uvicorn app:app --port 8000
```
 *(Gợi ý: Mở http://127.0.0.1:8000 trên trình duyệt của bạn sau khi khởi chạy).*

## 📖 Cách Setup Mã Số File Excel Mẫu

1. Tải về file mẫu Excel thông qua nút **Tải file mẫu (Excel)** trên giao diện màn hình chính. 
2. Thiết lập các cột trên file Excel bắt buộc phải có mã số tại dòng đầu tiên:
   - `nbmst`: Mã số thuế người bán.
   - `lhdon`: Loại hóa đơn.
   - `khhdon`: Ký hiệu số hóa đơn.
   - `shdon`: Số seri hóa đơn.
   - `tgtttbso`: Tổng tiền thanh toán (Cực kỳ quan trọng để Thuế xác nhận).
3. Kéo & thả file Excel vào khung upload và bấm chạy. Hệ thống sẽ trả cho bạn file `.xlsx` được chèn đầy đủ ảnh thu nhỏ.

## ⚖️ Giấy Phép
Dự án được xây dựng với mục đích học tập tự động hóa & luồng làm việc cá nhân, vui lòng tuân thủ quy định truy cập của Cổng tra cứu Thuế Việt Nam và không sử dụng Spam.
