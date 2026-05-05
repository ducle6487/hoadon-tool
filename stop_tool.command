#!/bin/bash
echo "======================================"
echo "🛑 ĐANG DỌN DẸP VÀ TẮT HÓA ĐƠN TOOL..."
echo "======================================"

pkill -f "uvicorn app:app" || true
pkill -f "cloudflared tunnel" || true


sleep 1
echo "✅ Đã tắt toàn bộ server ngầm thành công!"
echo "Giờ bạn có thể yên tâm tắt máy tính hoặc đi làm việc khác an toàn."
