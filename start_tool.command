#!/bin/bash
# Lấy đúng thư mục hiện tại của file
cd "$(dirname "$0")"

echo "======================================"
echo "🚀 ĐANG KHỞI ĐỘNG HÓA ĐƠN TOOL..."
echo "======================================"

# Tắt các tiến trình bị kẹt cũ
pkill -f "uvicorn app:app" || true

# Khởi động server nội bộ
python3 -m uvicorn app:app --port 8000 &
SERVER_PID=$!

sleep 2
echo "=========================================================="
echo "✅ KHỞI ĐỘNG THÀNH CÔNG!"
echo "🌐 TRUY CẬP VÀO TRÌNH DUYỆT BẰNG ĐƯỜNG LINK DƯỚI ĐÂY ĐỂ SỬ DỤNG:"
echo "👉 http://localhost:8000"
echo "=========================================================="
echo ""
echo "*Lưu ý: Bạn có thể đóng cửa sổ Terminal này mà tool vẫn tiếp tục sống (Chạy ngầm).*"
echo "*Khi nào nghỉ xài mới bấm vào file stop_tool.command để dọn dẹp tắt hoàn toàn*"
