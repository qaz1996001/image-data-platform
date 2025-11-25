# 鬆散耦合架構設計

## 1. 設計原則

### 1.1 核心原則
- **獨立性**：每個模組可獨立開發、測試、部署
- **無強制依賴**：模組間無強制執行順序
- **介面簡單**：使用簡單的輸入/輸出介面
- **失敗隔離**：單一模組失敗不影響其他模組

### 1.2 反模式（避免）
❌ 緊密耦合的工作流引擎（如Prefect、Temporal）
❌ 強制的前置條件檢查
❌ 複雜的狀態機管理
❌ 模組間共享狀態

### 1.3 最佳實踐
✅ 簡單的函數介面
✅ 資料驅動的執行
✅ 可選的步驟執行
✅ 獨立的錯誤處理

## 2. 模組架構

### 2.1 系統架構圖

```
┌─────────────────────────────────────────────────┐
│                   Web UI / CLI                   │
│              (簡單的執行介面)                    │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│              Coordinator (協調器)                │
│         (簡單的步驟執行，無複雜狀態)            │
└─────────────┬───────────────────────────────────┘
              │
    ┌─────────┼─────────┬─────────┬─────────┐
    ▼         ▼         ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ PACS   │ │ LLM    │ │ DICOM  │ │ Excel  │ │Transfer│
│Service │ │Service │ │Service │ │Service │ │Service │
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘
    │         │         │         │         │
    ▼         ▼         ▼         ▼         ▼
┌─────────────────────────────────────────────────┐
│               資料儲存層                         │
│        (簡單的檔案系統 + 資料庫)                │
└─────────────────────────────────────────────────┘
```

### 2.2 模組定義

#### 協調器（Coordinator）
```python
class SimpleCoordinator:
    """簡單的協調器，無複雜狀態管理"""

    def execute_step(self, step_name: str, input_data: dict) -> dict:
        """執行單一步驟，返回結果"""
        # 每個步驟獨立執行，無前置檢查
        if step_name == 'pacs_search':
            return self.pacs_service.search(input_data)
        elif step_name == 'llm_analysis':
            return self.llm_service.analyze(input_data)
        # ... 其他步驟

    def execute_workflow(self, steps: List[str], initial_data: dict):
        """可選擇性執行步驟"""
        results = {}
        for step in steps:
            # 可跳過任何步驟
            if self.should_skip(step):
                continue
            results[step] = self.execute_step(step, initial_data)
        return results
```

#### 服務模組範例
```python
class PACSService:
    """獨立的PACS服務，無外部依賴"""

    def search(self, criteria: dict) -> dict:
        """簡單的輸入輸出"""
        # 執行搜尋
        studies = self._search_pacs(criteria)
        # 返回結果
        return {
            'status': 'success',
            'studies': studies,
            'count': len(studies)
        }

    def download(self, study_uid: str) -> dict:
        """獨立的下載功能"""
        # 下載DICOM
        path = self._download_dicom(study_uid)
        return {
            'status': 'success',
            'path': path
        }
```

## 3. 資料流設計

### 3.1 無狀態執行
每個模組執行時：
- 從輸入取得所需資料
- 執行處理
- 返回結果
- 不維護內部狀態

### 3.2 資料傳遞模式
```python
# 方式1：直接傳遞
result1 = pacs_service.search(criteria)
result2 = llm_service.analyze(result1['studies'])

# 方式2：透過檔案
pacs_service.search_and_save(criteria, 'studies.json')
llm_service.analyze_from_file('studies.json')

# 方式3：透過資料庫
study_ids = pacs_service.search_and_store(criteria)
llm_service.analyze_by_ids(study_ids)
```

### 3.3 錯誤處理
```python
def safe_execute(service_method, input_data):
    """每個服務獨立處理錯誤"""
    try:
        return service_method(input_data)
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e),
            'input': input_data
        }
```

## 4. 模組間通訊

### 4.1 簡單的JSON介面
所有模組使用JSON格式通訊：
```json
{
  "input": {
    "criteria": {},
    "options": {}
  },
  "output": {
    "status": "success",
    "data": {},
    "error": null
  }
}
```

### 4.2 可選的訊息佇列
對於非同步處理，可使用簡單的佇列：
```python
# 簡單的檔案佇列
class SimpleQueue:
    def push(self, task):
        # 寫入檔案
        with open(f'queue/{uuid4()}.json', 'w') as f:
            json.dump(task, f)

    def pop(self):
        # 讀取並刪除最舊的檔案
        files = sorted(os.listdir('queue'))
        if files:
            with open(f'queue/{files[0]}') as f:
                task = json.load(f)
            os.remove(f'queue/{files[0]}')
            return task
```

## 5. 實際執行範例

### 5.1 完整工作流執行
```python
# 可自由選擇要執行的步驟
coordinator = SimpleCoordinator()

# 執行步驟1-3
results = coordinator.execute_workflow(
    steps=['pacs_search', 'llm_analysis', 'statistics'],
    initial_data={'date_range': '2024-01-01 to 2024-11-01'}
)

# 稍後執行步驟4-6（無需重新執行1-3）
sampling_results = coordinator.execute_step(
    'random_sampling',
    input_data={'study_ids': results['statistics']['disease_cases']}
)

# 醫師審核後，可選擇性執行步驟7-9
if sampling_results['fp_rate'] < 0.1:
    coordinator.execute_workflow(
        steps=['excel_export', 'dicom_download', 'anonymize', 'transfer'],
        initial_data={'approved_studies': sampling_results['approved']}
    )
```

### 5.2 部分執行範例
```python
# 只執行LLM分析（用於測試新guideline）
llm_service = LLMService()
test_results = llm_service.analyze({
    'reports': load_test_reports(),
    'guideline': new_guideline
})

# 只執行DICOM處理（處理已下載的檔案）
dicom_service = DICOMService()
dicom_service.batch_anonymize({
    'input_dir': '/downloads/dicom',
    'output_dir': '/processed/anonymous'
})
```

### 5.3 錯誤恢復範例
```python
# 從失敗點恢復
checkpoint = load_checkpoint()
remaining_steps = checkpoint['remaining_steps']
coordinator.execute_workflow(
    steps=remaining_steps,
    initial_data=checkpoint['last_successful_output']
)
```

## 6. 配置管理

### 6.1 簡單的配置檔
```yaml
# config.yml
services:
  pacs:
    host: localhost
    port: 11112
    protocol: dicom  # 或 rest

  llm:
    url: http://localhost:11434
    model: qwen2.5:7b

  storage:
    base_path: /data/validation
    temp_path: /tmp/validation

workflow:
  max_sample_size: 20
  min_sample_size: 5
  fp_threshold: 0.1
```

### 6.2 環境變數覆寫
```python
# 可透過環境變數覆寫設定
PACS_HOST=192.168.1.100
LLM_MODEL=qwen2.5:14b
STORAGE_PATH=/mnt/nas/validation
```

## 7. 測試策略

### 7.1 單元測試
每個服務獨立測試：
```python
def test_pacs_service():
    service = PACSService()
    result = service.search({'date': '2024-01-01'})
    assert result['status'] == 'success'

def test_llm_service():
    service = LLMService()
    result = service.analyze({'report': 'test report'})
    assert result['classification'] in ['no_disease', 'uncertain', 'has_disease']
```

### 7.2 整合測試
測試模組間資料流：
```python
def test_data_flow():
    # 測試資料可以在模組間傳遞
    pacs_output = pacs_service.search(criteria)
    llm_input = transform_for_llm(pacs_output)
    llm_output = llm_service.analyze(llm_input)
    assert llm_output['status'] == 'success'
```

## 8. 部署選項

### 8.1 單機部署
```bash
# 所有服務在同一台機器
python app.py --all-services
```

### 8.2 分散式部署
```bash
# 機器1：PACS和儲存
python app.py --services pacs,storage

# 機器2：LLM服務
python app.py --services llm

# 機器3：Web介面和協調器
python app.py --services web,coordinator
```

### 8.3 容器化部署
```dockerfile
# Dockerfile
FROM python:3.9
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

```yaml
# docker-compose.yml
version: '3'
services:
  pacs:
    build: .
    command: python app.py --services pacs
  llm:
    build: .
    command: python app.py --services llm
  web:
    build: .
    command: python app.py --services web
    ports:
      - "8000:8000"
```

## 9. 監控與日誌

### 9.1 簡單的日誌
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(service)s - %(message)s'
)

# 每個服務記錄自己的日誌
logger = logging.getLogger('pacs_service')
logger.info('Search completed', extra={'count': 100})
```

### 9.2 基本監控
```python
# 簡單的健康檢查
@app.route('/health')
def health_check():
    return {
        'status': 'healthy',
        'services': {
            'pacs': pacs_service.is_healthy(),
            'llm': llm_service.is_healthy(),
            'storage': storage_service.is_healthy()
        }
    }
```

## 10. 優勢總結

### 相比複雜架構的優勢

| 複雜架構（Prefect/Temporal） | 鬆散耦合架構 |
|------------------------------|--------------|
| 需要學習工作流框架 | 使用簡單Python |
| 強制的DAG依賴 | 自由的執行順序 |
| 複雜的狀態管理 | 無狀態執行 |
| 難以單獨測試 | 每個模組獨立測試 |
| 部署複雜 | 簡單部署 |
| 除錯困難 | 容易除錯 |
| 修改需重新設計工作流 | 隨時增減步驟 |

### 實際效益
- 開發時間減少50%
- 測試覆蓋率提高
- 維護成本降低
- 新功能整合更容易
- 團隊學習曲線平緩

---

**文件版本**: 1.0
**更新日期**: 2024-11-12
**設計理念**: 簡單勝於複雜，鬆散優於緊密