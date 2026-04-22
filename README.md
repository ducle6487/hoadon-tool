# Tool Tra Cứu Hóa Đơn Điện Tử Tự Động (Auto-Invoice Fetcher)

Công cụ tự động hóa việc tra cứu hàng loạt hóa đơn điện tử trên cổng thông tin Tổng cục Thuế Việt Nam (`hoadondientu.gdt.gov.vn`). Sử dụng **Playwright** kết hợp **FastAPI** và giao diện Web UI siêu mượt với **WebSocket**.

## 🚀 Tính Năng Nổi Bật

- **Tự Động Trải Nghiệm Mượt Mà (Web UI)**: Trải nghiệm sử dụng 100% qua web, kéo & thả file Excel. Phản hồi luồng nhật ký (log) theo thời gian thực (Real-time).
- **Vượt CAPTCHA "Offline" Siêu Việt**: Tích hợp `ddddocr` tự động nhận dạng mã CAPTCHA cục bộ với tốc độ siêu nhanh (0.1 giây), không tốn phí gọi API bên thứ ba.
- **Tiến Trình Chạy Ngầm Bền Bỉ**:
  - Tự động bỏ qua thời gian chết (Timeout) khi trang thuế bị lỗi giao diện thay vì việc bị kẹt (Freeze).
  - Kết nối bảo vệ RAM: Tính năng Reload hoặc Stop hoàn toàn giải phóng bộ nhớ. Giữ kết nối 5 giây khi F5 tránh chết task giữa chừng.
- **Trích Xuất Báo Cáo Xịn Xò**: 
  - Ảnh chụp màn hình kiểm tra toàn bộ trang được lưu lại cùng file kết quả Excel.
  - Tự động chèn ảnh co giãn kích thước tiêu chuẩn trực tiếp thẳng vào trong file Excel để đối soát ngay lập tức!
  - Tự động xóa file rác (`output/`) sau khi tải xuống.

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

1. Mở Terminal và bật máy chủ cục bộ bằng dòng lệnh:
```bash
python -m uvicorn app:app --port 8000
```
 *(Gợi ý: Mở http://127.0.0.1:8000 trên trình duyệt của bạn sau khi khởi chạy).*

2. Tải về file mẫu Excel thông qua nút **Tải file mẫu (Excel)** trên giao diện màn hình chính. 
3. Thiết lập các cột trên file Excel bắt buộc phải có mã số (Header) tại dòng đầu tiên:
   - `nbmst`: Mã số thuế người bán.
   - `lhdon`: Loại hóa đơn (nếu trống sẽ mặc định lấy Hóa Đơn GTGT).
   - `khhdon`: Ký hiệu số hóa đơn (VD: C23TAA).
   - `shdon`: Số seri hóa đơn.
   - `tgtttbso`: Tổng tiền thanh toán số (Cực kỳ quan trọng để Thuế xác nhận).
4. Kéo & thả file Excel vào khung upload và bấm chạy. Hệ thống sẽ trả cho bạn file `.xlsx` được chèn sẵn ảnh thu nhỏ và toàn bộ tình trạng truy xuất.

## ⚖️ Giấy Phép
Dự án được xây dựng với mục đích học tập tự động hóa & luồng làm việc cá nhân, vui lòng tuân thủ quy định truy cập của Cổng tra cứu Thuế Việt Nam và không sử dụng Spam.
