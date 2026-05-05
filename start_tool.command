#!/bin/bash
# Lấy đúng thư mục hiện tại của file
cd "$(dirname "$0")"

echo "======================================"
echo "🚀 ĐANG KHỞI ĐỘNG HÓA ĐƠN TOOL..."
echo "======================================"

# Tắt các tiến trình bị kẹt cũ
pkill -f "uvicorn app:app" || true

# Tự động cài đặt thư viện thiếu (nếu có)
echo "📦 Đang kiểm tra và cập nhật thư viện hệ thống..."
python3 -m pip install -r requirements.txt --quiet

# Lấy địa chỉ IP nội bộ
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "unknown")

# Khởi động server trên tất cả network interfaces
python3 -m uvicorn app:app --host 0.0.0.0 --port 8000 &
SERVER_PID=$!

sleep 2

# Khởi động Cloudflare Tunnel để public ra internet
TUNNEL_LOG="/tmp/cloudflared_tunnel.log"
pkill -f "cloudflared tunnel" 2>/dev/null || true
cloudflared tunnel --url http://localhost:8000 > "$TUNNEL_LOG" 2>&1 &

# Đợi cloudflared lấy được public URL (tối đa 15 giây)
echo "🌍 Đang tạo đường link Internet (Cloudflare Tunnel)..."
PUBLIC_URL=""
for i in $(seq 1 15); do
    PUBLIC_URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' "$TUNNEL_LOG" 2>/dev/null | head -1)
    if [ -n "$PUBLIC_URL" ]; then break; fi
    sleep 1
done

echo "=========================================================="
echo "✅ KHỞI ĐỘNG THÀNH CÔNG!"
echo "🌐 TRUY CẬP VÀO TRÌNH DUYỆT BẰNG ĐƯỜNG LINK DƯỚI ĐÂY ĐỂ SỬ DỤNG:"
echo "👉 Máy này:       http://localhost:8000"
echo "👉 Mạng nội bộ:   http://${LOCAL_IP}:8000"
if [ -n "$PUBLIC_URL" ]; then
    echo "🌍 Internet:      ${PUBLIC_URL}"
else
    echo "⚠️  Internet link chưa sẵn sàng. Xem log: $TUNNEL_LOG"
fi
echo "=========================================================="
echo ""
echo "*Lưu ý: Bạn có thể đóng cửa sổ Terminal này mà tool vẫn tiếp tục sống (Chạy ngầm).*"
echo "*Khi nào nghỉ xài mới bấm vào file stop_tool.command để dọn dẹp tắt hoàn toàn*"
