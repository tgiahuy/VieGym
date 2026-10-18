import {
  AiMetricItem,
  AllowlistVariable,
  PromptTemplateItem,
  SafetyRuleItem,
} from './types'

export const INITIAL_TEMPLATES: PromptTemplateItem[] = [
  {
    id: 'prompt-1',
    code: 'PRM-0082',
    useCase: 'WORKOUT_ENGINE',
    useCaseLabel: 'WORKOUT_ENGINE',
    title: 'Workout Planner — Gợi ý giáo án cá nhân hóa',
    description: 'Sinh lịch tập 7 ngày theo RPE, 1RM và chấn thương',
    version: 'v3.4.2',
    status: 'production',
    model: 'Claude 3.5 Sonnet',
    fallbackModel: 'GPT-4o',
    tokensEstimate: 1842,
    contextWindowPct: 14.2,
    updatedAt: '2 giờ trước',
    author: 'AI Eng Team',
    draftRevision: 0,
    content: `# ROLE & PERSONA DEFINITION
Bạn là VieGym AI Engine chuyên gia thiết kế giáo án thể hình cá nhân hóa chuẩn Khoa học Thể thao & Phục hồi Chức năng.

# USER PROFILE CONTEXT
- Cấp độ tập luyện: {{user.fitness_level}}
- Mục tiêu chính: {{user.primary_goal}}
- Số ngày tập/tuần: {{target_split_days}}
- Thiết bị khả dụng: {{equipment_available}}

# CLINICAL SAFETY & CONTRAINDICATIONS GUARDRAILS (STRICT COMPLIANCE)
TUYỆT ĐỐI KHÔNG chỉ định bất kỳ bài tập tải trọng dọc trục cột sống (Axial Loading: Barbell Back Squat, Deadlift, Overhead Press) nếu user có cờ chấn thương:
{{injury_flags.lower_back}} == true.
Trong trường hợp này, hãy thay thế ngay bằng: Leg Press máy nghiêng 45°, Dumbbell Bulgarian Split Squat hoặc Cable Romanian Deadlift hỗ trợ băng đai.

# VOLUME & INTENSITY RULES
Giữ cường độ trong khoảng RPE: {{target_rpe_range}}. Tránh tuyệt đối tình trạng RIR = 0 ở tuần 1 của chu kỳ Meso-cycle.
Định dạng đầu ra: Chuẩn cấu trúc JSON schema \`VieGymWorkoutPlanV3\`.`,
  },
  {
    id: 'prompt-2',
    code: 'PRM-0083',
    useCase: 'NUTRITION_ENGINE',
    useCaseLabel: 'NUTRITION_ENGINE',
    title: 'Meal Planner — Khẩu phần & Phân bổ Macro',
    description: 'Tối ưu hóa calo theo TDEE, dị ứng thực phẩm và văn hóa ẩm thực Việt',
    version: 'v2.8.0',
    status: 'production',
    model: 'Claude 3.5 Sonnet',
    fallbackModel: 'GPT-4o',
    tokensEstimate: 1420,
    contextWindowPct: 11.1,
    updatedAt: '1 ngày trước',
    author: 'Nutrition Lead',
    draftRevision: 0,
    content: `# ROLE & PERSONA DEFINITION
Bạn là Chuyên gia Dinh dưỡng Thể thao VieGym AI Nutritionist chuẩn ISSN & Viện Dinh Dưỡng Quốc Gia.

# NUTRITIONAL CONTEXT
- TDEE mục tiêu: {{target_calories}} kcal
- Phân bổ Macro: Protein {{target_protein}}g, Carbs {{target_carbs}}g, Fat {{target_fat}}g
- Dị ứng / Kiêng kỵ: {{allergy_flags}}

# VIETNAMESE CULINARY RULES
Ưu tiên thực phẩm tươi sống bản địa: Ức gà, cá hồi fillet, trứng gà ta, cơm gạo lài, khoai lang luộc. Tránh các loại sốt công nghiệp nhiều đường tinh luyện.`,
  },
  {
    id: 'prompt-3',
    code: 'PRM-0084',
    useCase: 'CHAT_COACH',
    useCaseLabel: 'CHAT_COACH',
    title: 'AI Coach — Trợ lý tương tác & Động lực hội viên',
    description: 'Giải đáp kỹ thuật tập và hỗ trợ tâm lý tập luyện',
    version: 'v1.5.0-rc2',
    status: 'review',
    model: 'GPT-4o',
    fallbackModel: 'Claude 3.5 Haiku',
    tokensEstimate: 980,
    contextWindowPct: 7.6,
    updatedAt: '3 ngày trước',
    author: 'UX Copywriter',
    draftRevision: 0,
    content: `# ROLE & VOICE GUIDELINES
Bạn là VieGym Coach — Huấn luyện viên thể hình thông minh, truyền cảm hứng, thân thiện và giàu năng lượng tích cực.

# TONE & STYLE
- Xưng hô: "Coach" và "bạn / bạn mình"
- Khích lệ tinh thần kiên trì, giải thích ngắn gọn, súc tích có dẫn chứng kỹ thuật chuyển động sinh học (biomechanics).
- Luôn nhắc nhở an toàn khởi động kỹ trước buổi tập.`,
  },
  {
    id: 'prompt-4',
    code: 'PRM-0085',
    useCase: 'SAFETY_FILTER',
    useCaseLabel: 'SAFETY_FILTER',
    title: 'Safety Guardrail — Bộ lọc chấn thương & Bệnh lý cột sống',
    description: 'Chặn tuyệt đối bài tập tải trọng dọc trục khi có thoát vị đĩa đệm',
    version: 'v4.1.0',
    status: 'production',
    model: 'Llama-3.1-Guard-70B',
    fallbackModel: 'RuleEngine v2',
    tokensEstimate: 620,
    contextWindowPct: 4.8,
    updatedAt: '5 ngày trước',
    author: 'Medical Advisory',
    draftRevision: 0,
    content: `# CLINICAL GUARDRAIL FILTER
Nếu phát hiện hồ sơ chấn thương cấp tính (Knee ACL/MCL, Lumbar Herniation, Rotator Cuff Tear):
- Tự động hạ cấp độ bài tập xuống 1 bậc.
- Loại trừ các chuyển động xoắn vặn đốt sống hoặc tải tạ tự do trên vai.
- Kèm cảnh báo tham vấn bác sĩ chuyên khoa vật lý trị liệu trước khi tập.`,
  },
]

export const ALLOWLIST_VARIABLES: AllowlistVariable[] = [
  {
    tag: '{{user.fitness_level}}',
    typeDesc: 'enum: beginner, intermediate, advanced',
    color: '#4d8dff',
  },
  {
    tag: '{{user.primary_goal}}',
    typeDesc: 'hypertrophy, strength, fat_loss',
    color: '#2cc7b5',
  },
  {
    tag: '{{injury_flags}}',
    typeDesc: 'sanitized flags: knee, shoulder, lower_back',
    color: '#ff5a5f',
  },
  {
    tag: '{{equipment_available}}',
    typeDesc: 'list of available gym gear',
    color: '#cdbdff',
  },
  {
    tag: '{{target_split_days}}',
    typeDesc: 'integer: 3, 4, 5, 6',
    color: '#f28c38',
  },
  {
    tag: '{{target_rpe_range}}',
    typeDesc: 'string: "RPE 7-8.5"',
    color: '#35c76f',
  },
]

export const SAFETY_RULES: SafetyRuleItem[] = [
  {
    id: 'rule-1',
    code: 'SAFE-001',
    name: 'Chặn tải trọng trục dọc cột sống khi thoát vị đĩa đệm (Lower Back)',
    category: 'clinical',
    severity: 'critical',
    description: 'Loại trừ Barbell Back Squat, Conventional Deadlift, Overhead Press khi có cờ chấn thương lưng dưới.',
    action: 'Thay thế bằng Leg Press 45° hoặc Dumbbell Split Squat',
    isActive: true,
    version: 0,
  },
  {
    id: 'rule-2',
    code: 'SAFE-002',
    name: 'Bảo vệ khớp gối sau phẫu thuật dây chằng chéo (ACL/MCL)',
    category: 'clinical',
    severity: 'critical',
    description: 'Chặn máy Leg Extension ở góc duỗi tối đa (0-30 độ). Khuyến nghị Closed Kinetic Chain exercises.',
    action: 'Chuyển sang Squat hộp nhẹ kiểm soát biên độ',
    isActive: true,
    version: 0,
  },
  {
    id: 'rule-3',
    code: 'SAFE-003',
    name: 'Giới hạn RPE chu kỳ khởi đầu Meso-cycle 1',
    category: 'intensity',
    severity: 'warning',
    description: 'Không cho phép AI gán RPE > 8.0 trong tuần đầu để chống quá tải thần kinh trung ương.',
    action: 'Khóa RPE tối đa 7.5 và RIR >= 2',
    isActive: true,
    version: 0,
  },
  {
    id: 'rule-4',
    code: 'SAFE-004',
    name: 'Lọc dữ liệu PII và danh tính cá nhân (ADR-008)',
    category: 'pii',
    severity: 'critical',
    description: 'Xóa toàn bộ họ tên thật, số điện thoại, email trước khi gửi prompt qua LLM gateway.',
    action: 'Sanitize và gán UUID ngẫu nhiên',
    isActive: true,
    version: 0,
  },
  {
    id: 'rule-5',
    code: 'SAFE-005',
    name: 'Kiểm tra xung đột dị ứng thực phẩm nặng (Hải sản / Lạc / Đậu nành)',
    category: 'clinical',
    severity: 'critical',
    description: 'Tự động kiểm tra chéo thành phần chi tiết trong công thức nấu ăn trước khi gợi ý thực đơn.',
    action: 'Loại bỏ hoàn toàn nhóm nguyên liệu gây dị ứng',
    isActive: true,
    version: 0,
  },
]

export const AI_METRICS: AiMetricItem[] = [
  {
    name: 'Độ khả dụng hệ thống AI (Uptime)',
    value: '99.85%',
    change: '+0.05% vs tháng trước',
    isPositive: true,
    description: 'Cluster Claude 3.5 + Fallback GPT-4o',
  },
  {
    name: 'Thời gian phản hồi trung bình (Latency)',
    value: '640 ms',
    change: '-80ms tối ưu prompt',
    isPositive: true,
    description: 'TTFT (Time To First Token) qua Streaming CDN',
  },
  {
    name: 'Tỷ lệ Guardrail kích hoạt an toàn',
    value: '4.12%',
    change: 'Bảo vệ 1,280 ca chấn thương',
    isPositive: true,
    description: 'Tự động can thiệp sửa đổi bài tập an toàn',
  },
  {
    name: 'Tỷ lệ chấp thuận giáo án của hội viên',
    value: '94.6%',
    change: '+2.1% hài lòng',
    isPositive: true,
    description: 'Hội viên hoàn thành trọn vẹn buổi tập',
  },
]
