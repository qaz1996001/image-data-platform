# Supabase 實作指南與快速參考

## 快速開始

### 環境變數配置

```bash
# .env.supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_DB_HOST=db.xxxxx.supabase.co
SUPABASE_DB_PASSWORD=your-db-password
SUPABASE_DB_PORT=5432
SUPABASE_DB_NAME=postgres

# Django 設定
DJANGO_SECRET_KEY=your-secret-key
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,*.supabase.co

# 舊系統（遷移期間）
OLD_DB_HOST=your-old-db-host
OLD_DB_USER=postgres
OLD_DB_PASSWORD=old-password
OLD_DB_NAME=medical_imaging
```

---

## Django 設定更新

### 1. 資料庫配置

```python
# backend_django/config/settings.py
import os
from urllib.parse import urlparse

# Supabase 資料庫連線
if os.getenv('USE_SUPABASE', 'False') == 'True':
    # 解析 Supabase DATABASE_URL
    DATABASE_URL = f"postgresql://postgres:{os.getenv('SUPABASE_DB_PASSWORD')}@{os.getenv('SUPABASE_DB_HOST')}:6543/postgres?sslmode=require"

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'postgres',
            'USER': 'postgres',
            'PASSWORD': os.getenv('SUPABASE_DB_PASSWORD'),
            'HOST': os.getenv('SUPABASE_DB_HOST'),
            'PORT': 6543,  # Supavisor pooler port
            'OPTIONS': {
                'sslmode': 'require',
                'connect_timeout': 10,
                'keepalives': 1,
                'keepalives_idle': 30,
                'keepalives_interval': 10,
                'keepalives_count': 5,
            },
            'CONN_MAX_AGE': 60,
            'CONN_HEALTH_CHECKS': True,
        }
    }
else:
    # 保留原有配置作為備援
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.getenv('DB_NAME', 'medical_imaging'),
            'USER': os.getenv('DB_USER', 'postgres'),
            'PASSWORD': os.getenv('DB_PASSWORD', 'postgres'),
            'HOST': os.getenv('DB_HOST', 'localhost'),
            'PORT': os.getenv('DB_PORT', '5432'),
        }
    }
```

### 2. 快取配置

```python
# 快取後端配置
if os.getenv('USE_SUPABASE_CACHE', 'False') == 'True':
    CACHES = {
        'default': {
            'BACKEND': 'studies.cache_backend.SupabaseCache',
            'LOCATION': 'django_cache',
            'TIMEOUT': 300,  # 預設 5 分鐘
            'OPTIONS': {
                'MAX_ENTRIES': 10000,
                'CULL_FREQUENCY': 4,
            }
        }
    }
else:
    # 保留原有 Redis 配置
    CACHES = {
        'default': {
            'BACKEND': 'django_redis.cache.RedisCache',
            'LOCATION': os.getenv('REDIS_URL', 'redis://127.0.0.1:6379/1'),
            'OPTIONS': {
                'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            }
        }
    }
```

### 3. 佇列配置

```python
# 佇列設定
QUEUE_CONFIG = {
    'BACKEND': 'studies.queue_manager.JobQueue',
    'QUEUES': {
        'email': {
            'max_retries': 3,
            'timeout': 30,
            'priority': 5,
        },
        'report': {
            'max_retries': 2,
            'timeout': 300,
            'priority': 3,
        },
        'export': {
            'max_retries': 2,
            'timeout': 600,
            'priority': 3,
        },
    }
}
```

---

## 管理命令實作

### 1. 快取管理命令

```python
# backend_django/studies/management/commands/cache_manager.py
from django.core.management.base import BaseCommand
from django.core.cache import cache
from studies.cache_backend import SupabaseCache

class Command(BaseCommand):
    help = 'Supabase 快取管理工具'

    def add_arguments(self, parser):
        parser.add_argument(
            '--cleanup',
            action='store_true',
            help='清理過期快取',
        )
        parser.add_argument(
            '--stats',
            action='store_true',
            help='顯示快取統計',
        )
        parser.add_argument(
            '--clear',
            action='store_true',
            help='清空所有快取',
        )

    def handle(self, *args, **options):
        if options['cleanup']:
            if isinstance(cache._cache, SupabaseCache):
                deleted = cache._cache.cleanup()
                self.stdout.write(f'清理了 {deleted} 個過期項目')

        if options['stats']:
            from django.db import connection
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        COUNT(*) as total,
                        COUNT(*) FILTER (WHERE expires_at > NOW()) as active,
                        COUNT(*) FILTER (WHERE expires_at <= NOW()) as expired
                    FROM django_cache
                """)
                total, active, expired = cursor.fetchone()
                self.stdout.write(f'總計：{total}，有效：{active}，過期：{expired}')

        if options['clear']:
            cache.clear()
            self.stdout.write('快取已清空')
```

### 2. 佇列工作處理器

```python
# backend_django/studies/management/commands/queue_worker.py
from django.core.management.base import BaseCommand
from studies.queue_manager import QueueWorker, JobQueue
import logging
import signal
import sys

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    help = '啟動佇列工作處理器'

    def add_arguments(self, parser):
        parser.add_argument('queue_name', type=str, help='佇列名稱')
        parser.add_argument(
            '--batch-size',
            type=int,
            default=1,
            help='批次處理大小',
        )

    def handle(self, *args, **options):
        queue_name = options['queue_name']

        # 註冊處理函數
        handlers = {
            'send_email': self.process_email,
            'generate_report': self.process_report,
            'export_data': self.process_export,
        }

        # 建立工作處理器
        worker = QueueWorker(
            queue_name=queue_name,
            job_handlers=handlers,
            batch_size=options['batch_size']
        )

        # 優雅關閉處理
        def signal_handler(sig, frame):
            self.stdout.write('正在關閉工作處理器...')
            worker.stop()
            sys.exit(0)

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)

        self.stdout.write(f'啟動佇列工作處理器：{queue_name}')
        worker.run()

    def process_email(self, payload):
        """處理郵件發送"""
        self.stdout.write(f"發送郵件至：{payload.get('to')}")
        # 實際郵件發送邏輯
        return {'status': 'sent'}

    def process_report(self, payload):
        """處理報表生成"""
        self.stdout.write(f"生成報表：{payload.get('report_id')}")
        # 實際報表生成邏輯
        return {'report_url': f"/reports/{payload.get('report_id')}.pdf"}

    def process_export(self, payload):
        """處理資料匯出"""
        self.stdout.write(f"匯出資料：{payload.get('format')}")
        # 實際匯出邏輯
        return {'file_url': f"/exports/{payload.get('export_id')}.csv"}
```

### 3. 資料遷移命令

```python
# backend_django/studies/management/commands/migrate_to_supabase.py
from django.core.management.base import BaseCommand
from django.db import connections
import subprocess

class Command(BaseCommand):
    help = '執行 Supabase 資料遷移'

    def add_arguments(self, parser):
        parser.add_argument(
            '--phase',
            type=str,
            choices=['schema', 'data', 'verify', 'sync'],
            required=True,
            help='遷移階段',
        )

    def handle(self, *args, **options):
        phase = options['phase']

        if phase == 'schema':
            self.migrate_schema()
        elif phase == 'data':
            self.migrate_data()
        elif phase == 'verify':
            self.verify_migration()
        elif phase == 'sync':
            self.setup_sync()

    def migrate_schema(self):
        """遷移資料庫結構"""
        self.stdout.write('匯出 Schema...')
        subprocess.run([
            'pg_dump',
            '-h', os.getenv('OLD_DB_HOST'),
            '-U', os.getenv('OLD_DB_USER'),
            '-d', os.getenv('OLD_DB_NAME'),
            '--schema-only',
            '-f', 'schema.sql'
        ])

        self.stdout.write('匯入 Schema 至 Supabase...')
        subprocess.run([
            'psql',
            os.getenv('SUPABASE_DATABASE_URL'),
            '-f', 'schema.sql'
        ])

    def migrate_data(self):
        """遷移資料"""
        tables = ['studies_study', 'studies_report', 'studies_reportversion']

        for table in tables:
            self.stdout.write(f'遷移表格 {table}...')
            # 分批遷移邏輯
            self._migrate_table_in_batches(table)

    def _migrate_table_in_batches(self, table, batch_size=1000):
        """分批遷移資料表"""
        old_conn = connections['old']
        new_conn = connections['default']

        with old_conn.cursor() as old_cursor:
            old_cursor.execute(f"SELECT COUNT(*) FROM {table}")
            total = old_cursor.fetchone()[0]

            for offset in range(0, total, batch_size):
                old_cursor.execute(
                    f"SELECT * FROM {table} LIMIT %s OFFSET %s",
                    [batch_size, offset]
                )
                rows = old_cursor.fetchall()

                if rows:
                    with new_conn.cursor() as new_cursor:
                        # 動態建立 INSERT 語句
                        placeholders = ','.join(['%s'] * len(rows[0]))
                        insert_query = f"INSERT INTO {table} VALUES ({placeholders})"
                        new_cursor.executemany(insert_query, rows)

                self.stdout.write(f'已遷移 {offset + len(rows)}/{total} 筆資料')

    def verify_migration(self):
        """驗證遷移結果"""
        self.stdout.write('驗證資料完整性...')

        checks = {
            'studies_study': 'SELECT COUNT(*) FROM studies_study',
            'studies_report': 'SELECT COUNT(*) FROM studies_report',
            'indexes': "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public'",
        }

        for check_name, query in checks.items():
            with connections['default'].cursor() as cursor:
                cursor.execute(query)
                count = cursor.fetchone()[0]
                self.stdout.write(f'{check_name}: {count}')
```

---

## API 整合範例

### 1. Supabase Client 包裝器

```python
# backend_django/studies/supabase_client.py
from supabase import create_client, Client
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

class SupabaseService:
    """Supabase 服務包裝器"""

    def __init__(self):
        self.client: Client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_ANON_KEY
        )

    def subscribe_to_changes(self, table: str, callback):
        """訂閱資料表變更"""
        channel = self.client.channel(f'public:{table}')

        channel.on(
            'postgres_changes',
            {'event': '*', 'schema': 'public', 'table': table},
            callback
        ).subscribe()

        return channel

    def upload_file(self, bucket: str, file_path: str, file_data):
        """上傳檔案至 Storage"""
        try:
            result = self.client.storage.from_(bucket).upload(
                file_path,
                file_data
            )
            return result
        except Exception as e:
            logger.error(f'檔案上傳失敗：{e}')
            return None

    def get_file_url(self, bucket: str, file_path: str):
        """取得檔案 URL"""
        return self.client.storage.from_(bucket).get_public_url(file_path)

# 單例模式
supabase_service = SupabaseService()
```

### 2. 即時訂閱範例

```python
# backend_django/studies/realtime.py
from channels.generic.websocket import AsyncWebsocketConsumer
import json

class StudyConsumer(AsyncWebsocketConsumer):
    """WebSocket 消費者，轉發 Supabase 即時更新"""

    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = f'study_{self.room_name}'

        # 加入房間群組
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

        # 訂閱 Supabase 變更
        from studies.supabase_client import supabase_service

        def on_study_change(payload):
            # 轉發至 WebSocket
            self.send(text_data=json.dumps({
                'type': 'study_update',
                'data': payload
            }))

        supabase_service.subscribe_to_changes(
            'studies_study',
            on_study_change
        )

    async def disconnect(self, close_code):
        # 離開房間群組
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        """接收來自 WebSocket 的訊息"""
        data = json.loads(text_data)
        message_type = data.get('type')

        if message_type == 'subscribe':
            # 處理訂閱請求
            pass
```

---

## 監控設定

### 1. Prometheus 指標

```python
# backend_django/studies/metrics.py
from prometheus_client import Counter, Histogram, Gauge
import time

# 定義指標
cache_hits = Counter('cache_hits_total', '快取命中總數')
cache_misses = Counter('cache_misses_total', '快取未命中總數')
cache_latency = Histogram('cache_latency_seconds', '快取延遲')
queue_depth = Gauge('queue_depth', '佇列深度', ['queue_name'])
job_processing_time = Histogram('job_processing_seconds', '工作處理時間', ['job_type'])

def monitor_cache(func):
    """快取監控裝飾器"""
    def wrapper(*args, **kwargs):
        start = time.time()
        try:
            result = func(*args, **kwargs)
            if result is not None:
                cache_hits.inc()
            else:
                cache_misses.inc()
            return result
        finally:
            cache_latency.observe(time.time() - start)
    return wrapper

def monitor_job(job_type):
    """佇列工作監控裝飾器"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            start = time.time()
            try:
                return func(*args, **kwargs)
            finally:
                job_processing_time.labels(job_type=job_type).observe(
                    time.time() - start
                )
        return wrapper
    return decorator
```

### 2. Grafana Dashboard 配置

```json
{
  "dashboard": {
    "title": "Supabase 遷移監控面板",
    "panels": [
      {
        "title": "快取命中率",
        "targets": [
          {
            "expr": "rate(cache_hits_total[5m]) / (rate(cache_hits_total[5m]) + rate(cache_misses_total[5m]))"
          }
        ]
      },
      {
        "title": "佇列深度",
        "targets": [
          {
            "expr": "queue_depth"
          }
        ]
      },
      {
        "title": "API 延遲",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
```

---

## 故障排除指南

### 常見問題與解決方案

| 問題 | 症狀 | 解決方案 |
|------|------|----------|
| 連線池耗盡 | `too many connections` | 增加 pool_size 或優化查詢 |
| 快取延遲高 | P95 > 50ms | 檢查索引、考慮增加 Redis |
| 佇列堵塞 | 深度持續增長 | 增加 Worker 或優化處理邏輯 |
| 記憶體洩漏 | 記憶體持續上升 | 檢查連線釋放、物件生命週期 |
| SSL 錯誤 | `SSL connection` | 確認 sslmode=require 設定 |

### 診斷命令

```bash
# 檢查連線數
psql $SUPABASE_DB_URL -c "SELECT count(*) FROM pg_stat_activity;"

# 檢查慢查詢
psql $SUPABASE_DB_URL -c "
  SELECT query, mean_exec_time, calls
  FROM pg_stat_statements
  ORDER BY mean_exec_time DESC
  LIMIT 10;"

# 檢查快取狀態
python manage.py cache_manager --stats

# 檢查佇列狀態
psql $SUPABASE_DB_URL -c "
  SELECT queue_name, status, count(*)
  FROM job_queue
  GROUP BY queue_name, status;"

# 檢查資料表大小
psql $SUPABASE_DB_URL -c "
  SELECT tablename, pg_size_pretty(pg_total_relation_size(tablename::regclass))
  FROM pg_tables
  WHERE schemaname = 'public'
  ORDER BY pg_total_relation_size(tablename::regclass) DESC;"
```

---

## 回滾程序

### 緊急回滾步驟

```bash
#!/bin/bash
# rollback.sh - 緊急回滾腳本

echo "開始執行回滾程序..."

# 1. 切換流量至舊環境
echo "切換流量..."
kubectl set image deployment/django-app django=django:old-version

# 2. 停止 Supabase 連線
echo "停止 Supabase 連線..."
export USE_SUPABASE=False
export USE_SUPABASE_CACHE=False

# 3. 重啟應用
echo "重啟應用..."
kubectl rollout restart deployment/django-app

# 4. 驗證服務
echo "驗證服務狀態..."
curl -f http://localhost:8000/health || exit 1

echo "回滾完成！"
```

---

## 效能調優建議

### 資料庫調優

```sql
-- 1. 更新統計資訊
ANALYZE;

-- 2. 重建索引
REINDEX DATABASE postgres;

-- 3. 清理死元組
VACUUM FULL ANALYZE;

-- 4. 調整工作記憶體
ALTER SYSTEM SET work_mem = '256MB';
ALTER SYSTEM SET maintenance_work_mem = '1GB';

-- 5. 優化連線設定
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '2GB';
```

### 應用層調優

```python
# 1. 使用連線池
from psycopg2 import pool

connection_pool = pool.ThreadedConnectionPool(
    5, 20,
    host=settings.SUPABASE_DB_HOST,
    database="postgres",
    user="postgres",
    password=settings.SUPABASE_DB_PASSWORD
)

# 2. 批次查詢
from django.db import connection

def batch_insert(data):
    with connection.cursor() as cursor:
        cursor.executemany(
            "INSERT INTO table_name VALUES (%s, %s, %s)",
            data
        )

# 3. 查詢優化
Study.objects.select_related('report').prefetch_related('versions')
```

---

## 相關連結與資源

### 官方文件
- [Supabase 文件](https://supabase.com/docs)
- [Django 文件](https://docs.djangoproject.com/)
- [PostgreSQL 文件](https://www.postgresql.org/docs/)

### 工具與套件
- [supabase-py](https://github.com/supabase-community/supabase-py)
- [django-environ](https://django-environ.readthedocs.io/)
- [psycopg2](https://www.psycopg.org/)

### 監控工具
- [Grafana](https://grafana.com/)
- [Prometheus](https://prometheus.io/)
- [pgAdmin](https://www.pgadmin.org/)

---

*文件版本：1.0*
*最後更新：2024-11-12*
*維護團隊：系統開發組*