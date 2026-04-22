document.addEventListener('DOMContentLoaded', () => {
    const fileArea = document.getElementById('fileDropArea');
    const fileInput = document.getElementById('fileInput');
    const fileMsg = document.querySelector('.file-msg');
    const form = document.getElementById('uploadForm');
    const runBtn = document.getElementById('runBtn');
    const btnText = runBtn.querySelector('span');
    const btnLoader = document.getElementById('btnLoader');
    
    const termOutput = document.getElementById('terminalOutput');
    const downloadBtn = document.getElementById('downloadBtn');
    
    let ws = null;

    // File Drag & Drop
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(evt => {
        fileArea.addEventListener(evt, e => { e.preventDefault(); e.stopPropagation(); });
    });
    ['dragenter', 'dragover'].forEach(evt => {
        fileArea.addEventListener(evt, () => fileArea.classList.add('dragover'));
    });
    ['dragleave', 'drop'].forEach(evt => {
        fileArea.addEventListener(evt, () => fileArea.classList.remove('dragover'));
    });
    fileArea.addEventListener('drop', e => {
        if (e.dataTransfer.files.length) {
            fileInput.files = e.dataTransfer.files;
            updateFileName(e.dataTransfer.files[0]);
        }
    });
    fileInput.addEventListener('change', () => {
        if (fileInput.files.length) updateFileName(fileInput.files[0]);
    });

    function updateFileName(file) {
        fileArea.classList.add('has-file');
        fileMsg.innerHTML = `<strong>${file.name}</strong><br><span>Đã sẵn sàng xử lý</span>`;
    }

    function addLog(msg, type = 'info') {
        const div = document.createElement('div');
        div.className = `log-line text-${type}`;
        div.textContent = msg;
        termOutput.appendChild(div);
        termOutput.scrollTop = termOutput.scrollHeight;
    }

    function connectWebSocket() {
        if (ws) ws.close();
        ws = new WebSocket(`ws://${window.location.host}/ws`);
        
        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.type === 'log') {
                let type = 'info';
                if (data.msg.includes('[ERROR]')) type = 'error';
                else if (data.msg.includes('✓') || data.msg.includes('Screenshot')) type = 'success';
                addLog(data.msg, type);
            } else if (data.type === 'done') {
                addLog('\n>> QUÁ TRÌNH XỬ LÝ HOÀN TẤT THÀNH CÔNG', 'success');
                downloadBtn.href = `/api/download?filepath=${encodeURIComponent(data.file)}`;
                downloadBtn.classList.remove('hidden');
                resetBtn();
            } else if (data.type === 'error') {
                addLog(`\n>> QUÁ TRÌNH XỬ LÝ THẤT BẠI: ${data.msg}`, 'error');
                resetBtn();
            }
        };
    }

    function resetBtn() {
        btnLoader.style.display = 'none';
        btnText.textContent = 'Bắt Đầu Tự Động Hóa';
        runBtn.disabled = false;
    }

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        if (!fileInput.files.length) { alert('Vui lòng chọn một file Excel trước.'); return; }

        termOutput.innerHTML = '';
        addLog('>> Đang khởi tạo công cụ (Tiến trình xử lý lần lượt)...', 'info');
        downloadBtn.classList.add('hidden');
        
        runBtn.disabled = true;
        btnText.textContent = 'Đang xử lý...';
        btnLoader.style.display = 'block';

        connectWebSocket();

        const formData = new FormData();
        formData.append('file', fileInput.files[0]);
        formData.append('headless', document.getElementById('headless').checked);

        try {
            const res = await fetch('/api/run', { method: 'POST', body: formData });
            const data = await res.json();
            if (data.error) { addLog(`LỖI: ${data.error}`, 'error'); resetBtn(); }
        } catch (error) {
            addLog(`Yêu cầu thất bại: ${error}`, 'error');
            resetBtn();
        }
    });
});
