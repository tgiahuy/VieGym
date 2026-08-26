INSERT INTO equipment (code, name, description) VALUES
    ('BODYWEIGHT', 'Trọng lượng cơ thể', 'Bài tập không cần thiết bị đặc thù'),
    ('DUMBBELL', 'Tạ đơn', NULL),
    ('BARBELL', 'Tạ đòn', NULL),
    ('BENCH', 'Ghế tập', NULL),
    ('CABLE_MACHINE', 'Máy cáp', NULL),
    ('MACHINE', 'Máy tập', NULL),
    ('RESISTANCE_BAND', 'Dây kháng lực', NULL),
    ('KETTLEBELL', 'Tạ ấm', NULL),
    ('PULL_UP_BAR', 'Xà đơn', NULL),
    ('TREADMILL', 'Máy chạy bộ', NULL)
ON CONFLICT (code) DO NOTHING;
