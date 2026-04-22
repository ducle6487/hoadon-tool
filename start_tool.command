#!/bin/bash
# Lấy đúng thư mục hiện tại của file
cd "$(dirname "$0")"

echo "======================================"
echo "🚀 ĐANG KHỞI ĐỘNG HÓA ĐƠN TOOL..."
echo "======================================"

# Tắt các tiến trình bị kẹt cũ
pkill -f "uvicorn app:app" || true
pkill -f "cloudflared tunnel" || true

# Khởi động server nội bộ
python3 -m uvicorn app:app --port 8000 &
SERVER_PID=$!

sleep 2
echo "✅ Server nội bộ đã mở tại: http://localhost:8000"

# Khởi động Cloudflare Tunnel
echo "🔄 Đang kết nối lên Cloudflare để xin Link mượn tạm..."
cloudflared tunnel --url http://localhost:8000 > /tmp/tunnel_hoadon.log 2>&1 &
TUNNEL_PID=$!

# Đợi vài giây rồi bóc tách lấy URL vừa tạo ra trong file Log
echo "⏳ Chờ chút xíu..."
sleep 6
LINK=$(grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' /tmp/tunnel_hoadon.log | tail -n 1)

echo "=========================================================="
if [ -n "$LINK" ]; then
    echo "✅ KHỞI ĐỘNG THÀNH CÔNG!"
    echo "🌐 COPY ĐƯỜNG LINK NÀY VÀO ĐIỆN THOẠI ĐỂ SỬ DỤNG TỪ XA:"
    echo "👉 $LINK"
else
    echo "⚠️ Bị lỗi mạng hoặc chưa cài Cloudflare!"
    echo "Chỉ có thể xài bộ nhớ trong bằng link: http://localhost:8000"
fi
echo "=========================================================="
echo ""
echo "*Lưu ý: Bạn có thể đóng cửa sổ Terminal này mà tool vẫn tiếp tục sống (Chạy ngầm).*"
echo "*Khi nào nghỉ xài mới bấm vào file stop_tool.command để dọn dẹp tắt hoàn toàn*"
