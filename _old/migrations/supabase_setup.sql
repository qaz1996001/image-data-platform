-- Supabase Migration Script for Medical Imaging System
-- This script sets up cache tables, job queue, and necessary functions

-- =====================================================
-- 1. CACHE IMPLEMENTATION
-- =====================================================

-- Drop existing cache table if exists (for clean migration)
DROP TABLE IF EXISTS django_cache CASCADE;

-- Create cache table
CREATE TABLE django_cache (
    cache_key VARCHAR(255) PRIMARY KEY,
    value JSONB NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for efficient cleanup
CREATE INDEX idx_django_cache_expires ON django_cache(expires_at);

-- Create function to cleanup expired cache entries
CREATE OR REPLACE FUNCTION cleanup_expired_cache()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM django_cache
    WHERE expires_at <= NOW();

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to get cache size
CREATE OR REPLACE FUNCTION get_cache_stats()
RETURNS TABLE(
    total_entries BIGINT,
    expired_entries BIGINT,
    active_entries BIGINT,
    total_size_bytes BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) AS total_entries,
        COUNT(*) FILTER (WHERE expires_at <= NOW()) AS expired_entries,
        COUNT(*) FILTER (WHERE expires_at > NOW()) AS active_entries,
        SUM(pg_column_size(value)) AS total_size_bytes
    FROM django_cache;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. JOB QUEUE IMPLEMENTATION
-- =====================================================

-- Drop existing queue tables if exist
DROP TABLE IF EXISTS job_queue_dead_letter CASCADE;
DROP TABLE IF EXISTS job_queue CASCADE;

-- Create job queue table
CREATE TABLE job_queue (
    id SERIAL PRIMARY KEY,
    queue_name VARCHAR(100) NOT NULL,
    job_type VARCHAR(100),
    payload JSONB NOT NULL,
    priority INTEGER DEFAULT 5,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    scheduled_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    timeout_seconds INTEGER DEFAULT 300,
    result JSONB
);

-- Create indexes for efficient queue operations
CREATE INDEX idx_job_queue_queue_status ON job_queue(queue_name, status, priority DESC, created_at);
CREATE INDEX idx_job_queue_scheduled ON job_queue(scheduled_at) WHERE status = 'pending';

-- Create dead letter queue table
CREATE TABLE job_queue_dead_letter (
    id SERIAL PRIMARY KEY,
    original_job_id INTEGER,
    queue_name VARCHAR(100) NOT NULL,
    job_type VARCHAR(100),
    payload JSONB NOT NULL,
    error_message TEXT,
    failure_count INTEGER,
    failed_at TIMESTAMPTZ DEFAULT NOW(),
    original_created_at TIMESTAMPTZ
);

-- Create function to enqueue a job
CREATE OR REPLACE FUNCTION enqueue_job(
    p_queue_name VARCHAR,
    p_payload JSONB,
    p_job_type VARCHAR DEFAULT NULL,
    p_priority INTEGER DEFAULT 5,
    p_max_retries INTEGER DEFAULT 3,
    p_timeout_seconds INTEGER DEFAULT 300,
    p_scheduled_at TIMESTAMPTZ DEFAULT NOW()
)
RETURNS INTEGER AS $$
DECLARE
    job_id INTEGER;
BEGIN
    INSERT INTO job_queue (
        queue_name, job_type, payload, priority,
        max_retries, timeout_seconds, scheduled_at
    )
    VALUES (
        p_queue_name, p_job_type, p_payload, p_priority,
        p_max_retries, p_timeout_seconds, p_scheduled_at
    )
    RETURNING id INTO job_id;

    RETURN job_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to dequeue a job (with row locking)
CREATE OR REPLACE FUNCTION dequeue_job(
    p_queue_name VARCHAR,
    p_job_types VARCHAR[] DEFAULT NULL
)
RETURNS TABLE(
    job_id INTEGER,
    job_type VARCHAR,
    payload JSONB,
    retry_count INTEGER,
    max_retries INTEGER,
    timeout_seconds INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH next_job AS (
        SELECT id, job_queue.job_type, job_queue.payload,
               job_queue.retry_count, job_queue.max_retries,
               job_queue.timeout_seconds
        FROM job_queue
        WHERE queue_name = p_queue_name
          AND status = 'pending'
          AND scheduled_at <= NOW()
          AND (p_job_types IS NULL OR job_queue.job_type = ANY(p_job_types))
        ORDER BY priority DESC, created_at
        LIMIT 1
        FOR UPDATE SKIP LOCKED
    )
    UPDATE job_queue
    SET status = 'processing',
        started_at = NOW()
    FROM next_job
    WHERE job_queue.id = next_job.id
    RETURNING next_job.id, next_job.job_type, next_job.payload,
              next_job.retry_count, next_job.max_retries, next_job.timeout_seconds;
END;
$$ LANGUAGE plpgsql;

-- Create function to complete a job
CREATE OR REPLACE FUNCTION complete_job(
    p_job_id INTEGER,
    p_result JSONB DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE job_queue
    SET status = 'completed',
        completed_at = NOW(),
        result = p_result
    WHERE id = p_job_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to fail a job (with retry logic)
CREATE OR REPLACE FUNCTION fail_job(
    p_job_id INTEGER,
    p_error_message TEXT
)
RETURNS VOID AS $$
DECLARE
    v_retry_count INTEGER;
    v_max_retries INTEGER;
    v_queue_name VARCHAR;
    v_job_type VARCHAR;
    v_payload JSONB;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Get job details
    SELECT retry_count, max_retries, queue_name, job_type, payload, created_at
    INTO v_retry_count, v_max_retries, v_queue_name, v_job_type, v_payload, v_created_at
    FROM job_queue
    WHERE id = p_job_id;

    IF v_retry_count < v_max_retries THEN
        -- Schedule retry with exponential backoff
        UPDATE job_queue
        SET retry_count = retry_count + 1,
            error_message = p_error_message,
            status = 'pending',
            scheduled_at = NOW() + INTERVAL '1 second' * POWER(2, v_retry_count)
        WHERE id = p_job_id;
    ELSE
        -- Mark as failed and move to dead letter queue
        UPDATE job_queue
        SET status = 'failed',
            error_message = p_error_message
        WHERE id = p_job_id;

        INSERT INTO job_queue_dead_letter (
            original_job_id, queue_name, job_type, payload,
            error_message, failure_count, original_created_at
        )
        VALUES (
            p_job_id, v_queue_name, v_job_type, v_payload,
            p_error_message, v_retry_count + 1, v_created_at
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create function to get queue statistics
CREATE OR REPLACE FUNCTION get_queue_stats(p_queue_name VARCHAR DEFAULT NULL)
RETURNS TABLE(
    queue_name VARCHAR,
    pending_count BIGINT,
    processing_count BIGINT,
    completed_count BIGINT,
    failed_count BIGINT,
    avg_processing_time INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        jq.queue_name,
        COUNT(*) FILTER (WHERE status = 'pending') AS pending_count,
        COUNT(*) FILTER (WHERE status = 'processing') AS processing_count,
        COUNT(*) FILTER (WHERE status = 'completed') AS completed_count,
        COUNT(*) FILTER (WHERE status = 'failed') AS failed_count,
        AVG(completed_at - started_at) FILTER (WHERE status = 'completed') AS avg_processing_time
    FROM job_queue jq
    WHERE (p_queue_name IS NULL OR jq.queue_name = p_queue_name)
      AND created_at > NOW() - INTERVAL '24 hours'
    GROUP BY jq.queue_name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. REAL-TIME SUBSCRIPTIONS SETUP
-- =====================================================

-- Enable Realtime for cache invalidation notifications
ALTER TABLE django_cache REPLICA IDENTITY FULL;

-- Enable Realtime for job queue notifications
ALTER TABLE job_queue REPLICA IDENTITY FULL;

-- Create function for broadcasting cache invalidation
CREATE OR REPLACE FUNCTION notify_cache_invalidation()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'cache_invalidation',
        json_build_object(
            'operation', TG_OP,
            'cache_key', NEW.cache_key
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for cache invalidation
CREATE TRIGGER cache_invalidation_trigger
AFTER INSERT OR UPDATE OR DELETE ON django_cache
FOR EACH ROW
EXECUTE FUNCTION notify_cache_invalidation();

-- Create function for job status notifications
CREATE OR REPLACE FUNCTION notify_job_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status != OLD.status THEN
        PERFORM pg_notify(
            'job_status_' || NEW.queue_name,
            json_build_object(
                'job_id', NEW.id,
                'old_status', OLD.status,
                'new_status', NEW.status,
                'job_type', NEW.job_type
            )::text
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for job status changes
CREATE TRIGGER job_status_trigger
AFTER UPDATE ON job_queue
FOR EACH ROW
EXECUTE FUNCTION notify_job_status_change();

-- =====================================================
-- 4. SCHEDULED MAINTENANCE JOBS (using pg_cron)
-- =====================================================

-- Note: pg_cron must be enabled in Supabase dashboard
-- These are example scheduled jobs - adjust as needed

-- Schedule cache cleanup every 5 minutes
-- SELECT cron.schedule(
--     'cleanup-expired-cache',
--     '*/5 * * * *',
--     'SELECT cleanup_expired_cache();'
-- );

-- Schedule job queue cleanup daily at 2 AM
-- SELECT cron.schedule(
--     'cleanup-completed-jobs',
--     '0 2 * * *',
--     'DELETE FROM job_queue WHERE status = ''completed'' AND completed_at < NOW() - INTERVAL ''7 days'';'
-- );

-- Schedule dead letter queue review weekly
-- SELECT cron.schedule(
--     'review-dead-letter-queue',
--     '0 0 * * 0',
--     'INSERT INTO job_queue (queue_name, job_type, payload)
--      SELECT ''admin_notifications'', ''dead_letter_review'',
--             json_build_object(''count'', COUNT(*), ''oldest'', MIN(failed_at))
--      FROM job_queue_dead_letter
--      WHERE failed_at > NOW() - INTERVAL ''7 days'';'
-- );

-- =====================================================
-- 5. MONITORING VIEWS
-- =====================================================

-- Create view for cache monitoring
CREATE OR REPLACE VIEW v_cache_monitor AS
SELECT
    COUNT(*) AS total_entries,
    COUNT(*) FILTER (WHERE expires_at > NOW()) AS active_entries,
    COUNT(*) FILTER (WHERE expires_at <= NOW()) AS expired_entries,
    ROUND(AVG(EXTRACT(EPOCH FROM (expires_at - created_at)))) AS avg_ttl_seconds,
    pg_size_pretty(SUM(pg_column_size(value))::BIGINT) AS total_size
FROM django_cache;

-- Create view for queue monitoring
CREATE OR REPLACE VIEW v_queue_monitor AS
SELECT
    queue_name,
    COUNT(*) FILTER (WHERE status = 'pending') AS pending,
    COUNT(*) FILTER (WHERE status = 'processing') AS processing,
    COUNT(*) FILTER (WHERE status = 'completed' AND completed_at > NOW() - INTERVAL '1 hour') AS recent_completed,
    COUNT(*) FILTER (WHERE status = 'failed' AND completed_at > NOW() - INTERVAL '1 hour') AS recent_failed,
    ROUND(AVG(EXTRACT(EPOCH FROM (completed_at - started_at))) FILTER (WHERE status = 'completed'), 2) AS avg_processing_seconds,
    MAX(created_at) AS last_job_created
FROM job_queue
GROUP BY queue_name;

-- =====================================================
-- 6. SECURITY & ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Note: Adjust these policies based on your security requirements

-- Enable RLS on cache table (optional)
-- ALTER TABLE django_cache ENABLE ROW LEVEL SECURITY;

-- Create policy for cache access (example)
-- CREATE POLICY "Service role can manage cache"
-- ON django_cache
-- FOR ALL
-- USING (auth.uid() IS NOT NULL)
-- WITH CHECK (auth.uid() IS NOT NULL);

-- Enable RLS on job queue (optional)
-- ALTER TABLE job_queue ENABLE ROW LEVEL SECURITY;

-- Create policy for job queue access (example)
-- CREATE POLICY "Service role can manage jobs"
-- ON job_queue
-- FOR ALL
-- USING (auth.uid() IS NOT NULL)
-- WITH CHECK (auth.uid() IS NOT NULL);

-- =====================================================
-- 7. HELPER FUNCTIONS
-- =====================================================

-- Function to estimate database size
CREATE OR REPLACE FUNCTION get_database_size_info()
RETURNS TABLE(
    table_name TEXT,
    row_count BIGINT,
    total_size TEXT,
    table_size TEXT,
    indexes_size TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        schemaname||'.'||tablename AS table_name,
        n_live_tup AS row_count,
        pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
        pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
        pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS indexes_size
    FROM pg_stat_user_tables
    ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. INITIAL DATA & TESTING
-- =====================================================

-- Insert test cache entry (optional)
-- INSERT INTO django_cache (cache_key, value, expires_at)
-- VALUES ('test:key', '{"test": "value"}'::jsonb, NOW() + INTERVAL '5 minutes');

-- Insert test job (optional)
-- SELECT enqueue_job(
--     'test_queue',
--     '{"action": "test", "timestamp": "2024-01-01T00:00:00Z"}'::jsonb,
--     'test_job',
--     5,
--     3,
--     300
-- );

-- =====================================================
-- 9. GRANT PERMISSIONS (adjust as needed)
-- =====================================================

-- Grant permissions to application user
-- GRANT ALL ON django_cache TO postgres;
-- GRANT ALL ON job_queue TO postgres;
-- GRANT ALL ON job_queue_dead_letter TO postgres;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Verify installation
SELECT 'Cache table created' AS status, COUNT(*) AS entries FROM django_cache
UNION ALL
SELECT 'Job queue created' AS status, COUNT(*) AS entries FROM job_queue
UNION ALL
SELECT 'Dead letter queue created' AS status, COUNT(*) AS entries FROM job_queue_dead_letter;