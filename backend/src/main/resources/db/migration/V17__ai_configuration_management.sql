CREATE TABLE ai_prompt_templates (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    use_case VARCHAR(40) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description VARCHAR(500) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    fallback_model_name VARCHAR(100),
    draft_content TEXT NOT NULL,
    draft_revision BIGINT NOT NULL DEFAULT 0,
    published_revision BIGINT NOT NULL DEFAULT 0,
    active_version_id BIGINT,
    created_by BIGINT REFERENCES users (id) ON DELETE SET NULL,
    updated_by BIGINT REFERENCES users (id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_prompt_use_case CHECK (
        use_case IN ('WORKOUT_ENGINE', 'NUTRITION_ENGINE', 'CHAT_COACH', 'SAFETY_FILTER')
    ),
    CONSTRAINT chk_ai_prompt_draft_size CHECK (char_length(draft_content) BETWEEN 1 AND 16000)
);

CREATE TABLE ai_prompt_versions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    template_id BIGINT NOT NULL REFERENCES ai_prompt_templates (id) ON DELETE CASCADE,
    version_no INTEGER NOT NULL,
    version_label VARCHAR(30) NOT NULL,
    content TEXT NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    published_by BIGINT REFERENCES users (id) ON DELETE SET NULL,
    published_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_ai_prompt_version UNIQUE (template_id, version_no),
    CONSTRAINT chk_ai_prompt_version_content_size CHECK (char_length(content) BETWEEN 1 AND 16000)
);

ALTER TABLE ai_prompt_templates
    ADD CONSTRAINT fk_ai_prompt_active_version
    FOREIGN KEY (active_version_id) REFERENCES ai_prompt_versions (id) ON DELETE SET NULL;

CREATE INDEX idx_ai_prompt_versions_template_published
    ON ai_prompt_versions (template_id, published_at DESC);
CREATE INDEX idx_ai_prompt_templates_use_case ON ai_prompt_templates (use_case);

CREATE TABLE ai_safety_rules (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(240) NOT NULL,
    category VARCHAR(30) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    action VARCHAR(1000) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    version BIGINT NOT NULL DEFAULT 0,
    updated_by BIGINT REFERENCES users (id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_safety_rule_category CHECK (
        category IN ('CLINICAL', 'EQUIPMENT', 'INTENSITY', 'PII')
    ),
    CONSTRAINT chk_ai_safety_rule_severity CHECK (
        severity IN ('CRITICAL', 'WARNING', 'INFO')
    )
);

INSERT INTO ai_prompt_templates
    (code, use_case, title, description, model_name, fallback_model_name, draft_content)
VALUES
    ('PRM-0082', 'WORKOUT_ENGINE', 'Workout Planner — Gợi ý giáo án cá nhân hóa',
     'Sinh lịch tập an toàn theo hồ sơ và thiết bị khả dụng', 'configured-provider-model', NULL,
     'Create 1-3 safe Vietnamese fitness recommendations. Use only candidate IDs and allowed actions.'),
    ('PRM-0083', 'NUTRITION_ENGINE', 'Meal Planner — Khẩu phần & Phân bổ Macro',
     'Gợi ý dinh dưỡng theo mục tiêu và dị ứng', 'configured-provider-model', NULL,
     'Create safe Vietnamese nutrition recommendations using only the supplied food candidates.'),
    ('PRM-0084', 'CHAT_COACH', 'AI Coach — Trợ lý tương tác & Động lực hội viên',
     'Giải đáp kỹ thuật tập và hỗ trợ thói quen an toàn', 'configured-provider-model', NULL,
     'Provide concise Vietnamese fitness guidance. Never diagnose illness or override safety rules.'),
    ('PRM-0085', 'SAFETY_FILTER', 'Safety Guardrail — Bộ lọc chấn thương & dữ liệu nhạy cảm',
     'Các ràng buộc bắt buộc áp dụng trước khi trả kết quả', 'rule-engine', NULL,
     'Apply every active safety rule. When information is insufficient, prefer the safer recommendation.');

WITH inserted AS (
    INSERT INTO ai_prompt_versions
        (template_id, version_no, version_label, content, model_name)
    SELECT id, 1, 'v1.0.0', draft_content, model_name
    FROM ai_prompt_templates
    RETURNING id, template_id
)
UPDATE ai_prompt_templates t
SET active_version_id = i.id
FROM inserted i
WHERE t.id = i.template_id;

INSERT INTO ai_safety_rules (code, name, category, severity, description, action)
VALUES
    ('SAFE-001', 'Chặn tải trọng trục dọc cột sống khi có chấn thương lưng', 'CLINICAL', 'CRITICAL',
     'Không đề xuất tải trọng trục dọc khi hồ sơ có cờ chấn thương lưng dưới.',
     'Thay bằng chuyển động được hỗ trợ, tải nhẹ và khuyến nghị đánh giá chuyên môn.'),
    ('SAFE-002', 'Bảo vệ khớp gối sau chấn thương dây chằng', 'CLINICAL', 'CRITICAL',
     'Không đề xuất biên độ hoặc tải gây đau cho người có cờ chấn thương ACL/MCL.',
     'Ưu tiên bài chuỗi động học kín, kiểm soát biên độ và tải.'),
    ('SAFE-003', 'Giới hạn cường độ giai đoạn bắt đầu', 'INTENSITY', 'WARNING',
     'Không gán RPE trên 8 trong tuần đầu của chu kỳ.',
     'Giới hạn RPE 7.5 và giữ tối thiểu 2 reps dự trữ.'),
    ('SAFE-004', 'Loại bỏ dữ liệu nhận dạng cá nhân', 'PII', 'CRITICAL',
     'Không đưa họ tên, email, số điện thoại hoặc token vào prompt nhà cung cấp.',
     'Chỉ sử dụng định danh nội bộ và context tối thiểu cần thiết.'),
    ('SAFE-005', 'Kiểm tra dị ứng thực phẩm', 'CLINICAL', 'CRITICAL',
     'Không đề xuất nguyên liệu trùng với cờ dị ứng của người dùng.',
     'Loại bỏ nguyên liệu gây dị ứng và chọn phương án thay thế an toàn.');
