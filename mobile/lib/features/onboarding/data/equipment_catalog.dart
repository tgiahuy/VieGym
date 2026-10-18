import 'package:flutter/material.dart';

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final String category;
  final IconData icon;
}

/// Danh mục 11 thiết bị chuẩn khớp 1:1 với cơ sở dữ liệu VieGym (PostgreSQL).
const List<EquipmentItem> masterEquipmentCatalogue = [
  // 1. Thể trọng
  EquipmentItem(
    id: 'bw',
    code: 'bodyweight',
    name: 'Trọng lượng cơ thể (Bodyweight)',
    description: 'Các bài tập tận dụng trọng lượng cơ thể, không cần tạ',
    category: 'Thể trọng & Calisthenics',
    icon: Icons.accessibility_new_rounded,
  ),
  EquipmentItem(
    id: 'pullup_bar',
    code: 'pullup_bar',
    name: 'Xà đơn (Pull-up Bar)',
    description: 'Thanh xà treo cố định cho bài tập kéo thân trên toàn diện',
    category: 'Thể trọng & Calisthenics',
    icon: Icons.horizontal_rule_rounded,
  ),

  // 2. Tạ tự do
  EquipmentItem(
    id: 'db',
    code: 'dumbbell',
    name: 'Tạ đơn (Dumbbell)',
    description: 'Cặp tạ tay đa dụng cho hầu hết bài tập',
    category: 'Tạ tự do (Free Weights)',
    icon: Icons.fitness_center_outlined,
  ),
  EquipmentItem(
    id: 'bb',
    code: 'barbell',
    name: 'Tạ đòn (Barbell)',
    description: 'Thanh đòn tiêu chuẩn Olympic kết hợp đĩa tạ',
    category: 'Tạ tự do (Free Weights)',
    icon: Icons.fitness_center_rounded,
  ),
  EquipmentItem(
    id: 'kb',
    code: 'kettlebell',
    name: 'Tạ ấm (Kettlebell)',
    description: 'Tạ quả chuông tập swing, snatch và squat bùng nổ',
    category: 'Tạ tự do (Free Weights)',
    icon: Icons.fitness_center_rounded,
  ),

  // 3. Ghế & Giá đỡ
  EquipmentItem(
    id: 'bench',
    code: 'bench',
    name: 'Ghế tập phẳng (Flat Bench)',
    description: 'Ghế tập phẳng tiêu chuẩn chịu lực cao',
    category: 'Ghế & Giá đỡ',
    icon: Icons.chair_alt_rounded,
  ),
  EquipmentItem(
    id: 'adjustable_bench',
    code: 'adjustable_bench',
    name: 'Ghế tập điều chỉnh (Adjustable Bench)',
    description: 'Ghế có thể tùy chỉnh độ dốc từ phẳng, dốc lên đến dốc xuống',
    category: 'Ghế & Giá đỡ',
    icon: Icons.airline_seat_recline_extra_rounded,
  ),

  // 4. Máy & Dây cáp
  EquipmentItem(
    id: 'cable',
    code: 'cable_machine',
    name: 'Máy cáp (Cable Station)',
    description: 'Hệ thống ròng rọc và cáp đa hướng cung cấp lực căng liên tục',
    category: 'Máy & Dây cáp',
    icon: Icons.alt_route_rounded,
  ),
  EquipmentItem(
    id: 'machine',
    code: 'machine',
    name: 'Máy tập khối (Machine)',
    description: 'Máy tập cô lập nhóm cơ với quỹ đạo chuyển động cố định',
    category: 'Máy & Dây cáp',
    icon: Icons.precision_manufacturing_rounded,
  ),

  // 5. Phụ kiện & Dụng cụ bổ trợ
  EquipmentItem(
    id: 'band',
    code: 'resistance_band',
    name: 'Dây kháng lực (Resistance Bands)',
    description: 'Dây chun đàn hồi hỗ trợ khởi động và tăng lực cản',
    category: 'Dụng cụ bổ trợ',
    icon: Icons.all_inclusive_rounded,
  ),

  // 6. Cardio
  EquipmentItem(
    id: 'treadmill',
    code: 'treadmill',
    name: 'Máy chạy bộ (Treadmill)',
    description: 'Máy chạy bộ điện hỗ trợ điều chỉnh tốc độ và độ dốc',
    category: 'Thiết bị Cardio',
    icon: Icons.directions_run_rounded,
  ),
];

abstract final class EquipmentPresets {
  static const fullGym = [
    'bw',
    'pullup_bar',
    'db',
    'bb',
    'kb',
    'bench',
    'adjustable_bench',
    'cable',
    'machine',
    'band',
    'treadmill',
  ];

  static const homeDumbbell = ['db', 'bench', 'bw', 'band'];

  static const bodyweightOnly = ['bw', 'pullup_bar', 'band'];
}
