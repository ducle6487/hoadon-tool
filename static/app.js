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

    let rowFinished = 0;

    const progressContainer = document.getElementById('progressContainer');
    const progressLabel = document.getElementById('progressLabel');
    const progressPercent = document.getElementById('progressPercent');
    const progressFill = document.getElementById('progressFill');
    const etaValue = document.getElementById('etaValue');

    function updateProgress(current, total) {
        rowFinished = current;
        if (total === 0) {
            etaValue.textContent = "Đang tính...";
            return;
        }
        
        const percent = Math.min(Math.round((current / total) * 100), 100);
        
        progressLabel.textContent = `Đang xử lý: ${current}/${total} hóa đơn`;
        progressPercent.textContent = `${percent}%`;
        progressFill.style.width = `${percent}%`;

        // ETA logic: Assuming 5 tabs
        const remaining = total - current;
        if (remaining > 0) {
            const avgTimePerRow = 9; 
            const totalSecondsRemaining = (remaining / 5) * avgTimePerRow;
            
            const m = Math.floor(totalSecondsRemaining / 60);
            const s = Math.round(totalSecondsRemaining % 60);
            etaValue.textContent = `${m}p ${s}s`;
        } else {
            etaValue.textContent = "Đã xong!";
        }
    }

    function connectWebSocket() {
        if (ws) ws.close();
        ws = new WebSocket(`ws://${window.location.host}/ws`);
        
        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.type === 'progress') {
                updateProgress(data.current, data.total);
            } else if (data.type === 'log') {
                let type = 'info';
                if (data.msg.includes('[ERROR]')) type = 'error';
                else if (data.msg.includes('✓') || data.msg.includes('Screenshot OK')) type = 'success';
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
        // Don't hide progress immediately so user can see 100%
    }

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        if (!fileInput.files.length) { alert('Vui lòng chọn một file Excel trước.'); return; }

        termOutput.innerHTML = '';
        addLog('>> Đang khởi tạo công cụ (Tiến trình xử lý song song)...', 'info');
        downloadBtn.classList.add('hidden');
        
        runBtn.disabled = true;
        btnText.textContent = 'Đang xử lý...';
        btnLoader.style.display = 'block';

        progressContainer.classList.remove('hidden');
        updateProgress(0, 0);
        etaValue.textContent = "Đang tính...";

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
