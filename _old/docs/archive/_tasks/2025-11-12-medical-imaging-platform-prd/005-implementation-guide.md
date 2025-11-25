# 實施指南 - 簡化版驗證工作流系統

## 1. 快速開始

### 1.1 最小可行產品（2天內完成）

```bash
# 目錄結構
validation_system/
├── models.py           # 5個簡化的資料表
├── workflow.py         # 簡單的工作流執行器
├── services/
│   ├── pacs.py       # PACS搜尋/下載
│   ├── llm.py        # LLM報告分析
│   ├── dicom.py      # DICOM處理
│   └── excel.py      # Excel匯出
└── main.py            # 主程式進入點
```

### 1.2 零依賴啟動

```python
# main.py - 最簡單的執行方式
from workflow import SimpleValidationWorkflow

# 執行完整流程
workflow = SimpleValidationWorkflow()
workflow.execute_all({
    'date_from': '2024-01-01',
    'date_to': '2024-11-01'
})

# 或只執行需要的步驟
workflow.step1_pacs_search({'date': '2024-01-01'})
workflow.step2_llm_analysis()
workflow.step6_excel_export()
```

## 2. 資料庫設置（簡化版）

### 2.1 建立Migration

```python
# migrations/create_validation_tables.py
from django.db import migrations, models

class Migration(migrations.Migration):
    operations = [
        migrations.CreateModel(
            name='ValidationWorkflow',
            fields=[
                ('id', models.AutoField(primary_key=True)),
                ('name', models.CharField(max_length=200)),
                ('study_type', models.CharField(max_length=50)),
                ('status', models.CharField(max_length=20)),
                ('search_criteria', models.JSONField()),
                ('created_at', models.DateTimeField()),
            ],
        ),
        # 其他4個表...
    ]
```

### 2.2 執行Migration

```bash
python manage.py makemigrations
python manage.py migrate
```

## 3. 核心服務實作

### 3.1 PACS服務（最簡版）

```python
# services/pacs.py
import requests

class SimplePACSService:
    def search(self, criteria):
        """最簡單的PACS搜尋"""
        # 方式1: REST API
        response = requests.get(
            'http://pacs-server/studies',
            params=criteria
        )
        return response.json()

    def download(self, study_uid):
        """下載DICOM"""
        response = requests.get(
            f'http://pacs-server/studies/{study_uid}/download'
        )
        with open(f'{study_uid}.zip', 'wb') as f:
            f.write(response.content)
        return f'{study_uid}.zip'
```

### 3.2 LLM服務（使用Ollama）

```python
# services/llm.py
import requests

class SimpleLLMService:
    def analyze(self, report_text):
        """使用Ollama分析報告"""
        prompt = f"""
        分析以下報告，分類為：
        1. no_disease（無疾病）
        2. uncertain（不確定）
        3. has_disease（有疾病）

        報告：{report_text}

        回答格式：classification: [分類]
        """

        response = requests.post(
            'http://localhost:11434/api/generate',
            json={
                'model': 'qwen2.5:7b',
                'prompt': prompt,
                'stream': False
            }
        )

        # 解析回應
        text = response.json()['response']
        if 'no_disease' in text:
            return 'no_disease'
        elif 'has_disease' in text:
            return 'has_disease'
        else:
            return 'uncertain'
```

### 3.3 DICOM處理（使用pydicom）

```python
# services/dicom.py
import pydicom
import uuid

class SimpleDICOMService:
    def anonymize(self, dicom_path):
        """簡單的DICOM匿名化"""
        ds = pydicom.dcmread(dicom_path)

        # 移除敏感資訊
        ds.PatientName = 'ANONYMOUS'
        ds.PatientID = f'ANON_{uuid.uuid4().hex[:8]}'

        # 儲存
        output_path = dicom_path.replace('.dcm', '_anon.dcm')
        ds.save_as(output_path)
        return output_path

    def convert_to_nifti(self, dicom_path):
        """轉換為NIfTI（使用dcm2niix）"""
        import subprocess
        output_path = dicom_path.replace('.dcm', '.nii.gz')
        subprocess.run([
            'dcm2niix',
            '-o', output_path,
            dicom_path
        ])
        return output_path
```

### 3.4 Excel服務（使用pandas）

```python
# services/excel.py
import pandas as pd

class SimpleExcelService:
    def export(self, data, output_path):
        """匯出Excel"""
        df = pd.DataFrame(data)
        df.to_excel(output_path, index=False)
        return output_path

    def create_mapping(self, mapping_dict, output_path):
        """建立匿名對應表"""
        df = pd.DataFrame(
            mapping_dict.items(),
            columns=['Original_ID', 'Anonymous_ID']
        )
        df.to_excel(output_path, index=False)
        return output_path
```

## 4. Web介面（選用）

### 4.1 最簡單的Flask介面

```python
# web_app.py
from flask import Flask, request, jsonify
from workflow import SimpleValidationWorkflow

app = Flask(__name__)

@app.route('/workflow/start', methods=['POST'])
def start_workflow():
    """啟動工作流"""
    workflow = SimpleValidationWorkflow()
    criteria = request.json
    result = workflow.step1_pacs_search(criteria)
    return jsonify(result)

@app.route('/workflow/status/<workflow_id>')
def get_status(workflow_id):
    """取得狀態"""
    workflow = SimpleValidationWorkflow(workflow_id)
    return jsonify(workflow.get_status())

@app.route('/workflow/step/<step_name>', methods=['POST'])
def execute_step(step_name):
    """執行特定步驟"""
    workflow = SimpleValidationWorkflow()
    step_map = {
        'pacs': workflow.step1_pacs_search,
        'llm': workflow.step2_llm_analysis,
        'stats': workflow.step3_statistics,
        # ...
    }
    if step_name in step_map:
        result = step_map[step_name](request.json)
        return jsonify(result)
    return jsonify({'error': 'Unknown step'}), 404

if __name__ == '__main__':
    app.run(debug=True)
```

### 4.2 簡單的HTML介面

```html
<!-- templates/index.html -->
<!DOCTYPE html>
<html>
<head>
    <title>醫療影像驗證系統</title>
</head>
<body>
    <h1>驗證工作流控制台</h1>

    <div id="step1">
        <h2>步驟1：PACS搜尋</h2>
        <input type="date" id="date_from">
        <input type="date" id="date_to">
        <button onclick="executePACS()">執行搜尋</button>
        <div id="pacs_result"></div>
    </div>

    <div id="step2">
        <h2>步驟2：LLM分析</h2>
        <button onclick="executeLLM()">執行分析</button>
        <div id="llm_result"></div>
    </div>

    <!-- 其他步驟... -->

    <script>
    async function executePACS() {
        const response = await fetch('/workflow/step/pacs', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                date_from: document.getElementById('date_from').value,
                date_to: document.getElementById('date_to').value
            })
        });
        const result = await response.json();
        document.getElementById('pacs_result').innerText =
            `找到 ${result.count} 個studies`;
    }

    async function executeLLM() {
        const response = await fetch('/workflow/step/llm', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({})
        });
        const result = await response.json();
        document.getElementById('llm_result').innerText =
            `分析完成 ${result.analyzed} 份報告`;
    }
    </script>
</body>
</html>
```

## 5. 部署指南

### 5.1 開發環境

```bash
# 安裝依賴
pip install django pandas pydicom openpyxl requests flask

# 啟動Ollama
ollama serve
ollama pull qwen2.5:7b

# 執行系統
python main.py
```

### 5.2 生產環境（Docker）

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# 安裝依賴
COPY requirements.txt .
RUN pip install -r requirements.txt

# 複製程式碼
COPY . .

# 執行
CMD ["python", "main.py"]
```

```yaml
# docker-compose.yml
version: '3'
services:
  validation:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./data:/data
    environment:
      - PACS_HOST=pacs-server
      - LLM_URL=http://ollama:11434

  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama

volumes:
  ollama_data:
```

### 5.3 快速部署腳本

```bash
#!/bin/bash
# deploy.sh

# 1. 檢查環境
echo "檢查環境..."
python --version
pip --version

# 2. 安裝依賴
echo "安裝依賴..."
pip install -r requirements.txt

# 3. 初始化資料庫
echo "初始化資料庫..."
python manage.py migrate

# 4. 啟動服務
echo "啟動服務..."
python main.py
```

## 6. 測試指南

### 6.1 單元測試

```python
# tests/test_workflow.py
import unittest
from workflow import SimpleValidationWorkflow

class TestWorkflow(unittest.TestCase):
    def test_pacs_search(self):
        workflow = SimpleValidationWorkflow()
        result = workflow.step1_pacs_search({'date': '2024-01-01'})
        self.assertEqual(result['status'], 'success')

    def test_llm_analysis(self):
        workflow = SimpleValidationWorkflow()
        workflow.results['pacs_search'] = {
            'studies': [{'report_text': 'test'}]
        }
        result = workflow.step2_llm_analysis()
        self.assertEqual(result['status'], 'success')

if __name__ == '__main__':
    unittest.main()
```

### 6.2 整合測試

```python
# tests/test_integration.py
def test_full_workflow():
    """測試完整工作流"""
    workflow = SimpleValidationWorkflow()

    # 執行所有步驟
    results = workflow.execute_all({
        'date_from': '2024-01-01',
        'date_to': '2024-01-31'
    })

    # 驗證結果
    assert 'pacs_search' in results
    assert 'llm_analysis' in results
    assert 'statistics' in results
    print("整合測試通過！")
```

## 7. 常見問題處理

### 7.1 PACS連線問題

```python
# 多協議支援
def connect_pacs(protocol='dicom'):
    if protocol == 'dicom':
        # 使用pynetdicom
        from pynetdicom import AE
        ae = AE()
        return ae
    elif protocol == 'rest':
        # 使用REST API
        import requests
        return requests.Session()
```

### 7.2 LLM服務故障

```python
# 後備方案：規則基礎分類
def fallback_classification(report_text):
    keywords = {
        'no_disease': ['normal', 'unremarkable', '正常'],
        'has_disease': ['aneurysm', 'dissection', '動脈瘤'],
    }

    for classification, words in keywords.items():
        if any(word in report_text.lower() for word in words):
            return classification

    return 'uncertain'
```

### 7.3 大檔案處理

```python
# 分批處理
def process_large_dataset(studies, batch_size=100):
    for i in range(0, len(studies), batch_size):
        batch = studies[i:i+batch_size]
        process_batch(batch)
        print(f"處理進度: {i+len(batch)}/{len(studies)}")
```

## 8. 效能優化

### 8.1 並行處理

```python
# 使用多執行緒
from concurrent.futures import ThreadPoolExecutor

def parallel_llm_analysis(reports, max_workers=3):
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = executor.map(analyze_single_report, reports)
    return list(results)
```

### 8.2 快取機制

```python
# 簡單的檔案快取
import pickle
import os

def cached_operation(key, operation):
    cache_file = f'cache/{key}.pkl'
    if os.path.exists(cache_file):
        with open(cache_file, 'rb') as f:
            return pickle.load(f)

    result = operation()
    os.makedirs('cache', exist_ok=True)
    with open(cache_file, 'wb') as f:
        pickle.dump(result, f)

    return result
```

## 9. 維護與監控

### 9.1 日誌記錄

```python
# 設定日誌
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('validation.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
logger.info("系統啟動")
```

### 9.2 簡單監控

```python
# 健康檢查端點
@app.route('/health')
def health():
    checks = {
        'database': check_database(),
        'pacs': check_pacs(),
        'llm': check_llm(),
        'storage': check_storage()
    }

    all_healthy = all(checks.values())
    status_code = 200 if all_healthy else 503

    return jsonify({
        'status': 'healthy' if all_healthy else 'degraded',
        'checks': checks
    }), status_code
```

## 10. 下一步計畫

### Phase 1（當前）
✅ 核心9步驟工作流
✅ 簡化資料模型
✅ 基本服務整合

### Phase 2（2週後）
- [ ] Web UI改進
- [ ] 批次處理優化
- [ ] 錯誤恢復機制

### Phase 3（1個月後）
- [ ] 多報告來源整合
- [ ] 自動排程執行
- [ ] 進階統計分析

---

**重點**：保持簡單、快速迭代、逐步改進

**聯絡**：如有問題，請參考簡化版PRD文件