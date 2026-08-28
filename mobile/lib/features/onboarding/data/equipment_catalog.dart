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

const List<EquipmentItem> masterEquipmentCatalogue = [
  // Free weights
  EquipmentItem(
    id: 'db',
    code: 'dumbbell',
    name: 'Tạ đơn (Dumbbell)',
    description: 'Cặp tạ tay đa dụng cho hầu hết bài tập',
    category: 'Tạ tự do (Free Weights)',
    icon: Icons.fitness_center_rounded,
  ),
  EquipmentItem(
    id: 'bb',
    code: 'barbell',
    name: 'Thanh đòn Olympic & Bánh tạ',
    description: 'Thanh tạ dài 20kg và đĩa tạ các mức',
    category: 'Tạ tự do (Free Weights)',
    icon: Icons.fitness_center_rounded,
  ),
  EquipmentItem(
    id: 'kb',
    code: 'kettlebell',
    name: 'Tạ bình vôi (Kettlebell)',
    description: 'Tạ chuông tập swing, snatch, squat',
    category: 'Tạ tự do (Free Weights)',
    icon: Icons.fitness_center_rounded,
  ),
  EquipmentItem(
    id: 'ez',
    code: 'ez_bar',
    name: 'Đòn zíc-zắc (EZ Bar)',
    description: 'Bảo vệ cổ tay khi cuốn tay trước và tay sau',
    category: 'Tạ tự do (Free Weights)',
    icon: Icons.fitness_center_rounded,
  ),

  // Benches & Racks
  EquipmentItem(
    id: 'bench',
    code: 'bench',
    name: 'Ghế tập điều chỉnh (Incline/Flat)',
    description: 'Ghế dốc nhiều góc độ để tập ngực, vai',
    category: 'Ghế & Khung tập',
    icon: Icons.weekend_rounded,
  ),
  EquipmentItem(
    id: 'rack',
    code: 'squat_rack',
    name: 'Khung gánh tạ (Squat / Power Rack)',
    description: 'Khung an toàn cho Squat, Bench Press, OHP',
    category: 'Ghế & Khung tập',
    icon: Icons.grid_view_rounded,
  ),

  // Machines & Cables
  EquipmentItem(
    id: 'cable',
    code: 'cable_machine',
    name: 'Dàn kéo cáp đa năng (Cable Station)',
    description: 'Kéo xô, ép ngực cáp, tay sau cáp',
    category: 'Máy & Dây cáp',
    icon: Icons.alt_route_rounded,
  ),
  EquipmentItem(
    id: 'smith',
    code: 'smith_machine',
    name: 'Máy Smith Machine',
    description: 'Thanh đòn có ray trượt cố định an toàn',
    category: 'Máy & Dây cáp',
    icon: Icons.view_column_rounded,
  ),
  EquipmentItem(
    id: 'lat_pulldown',
    code: 'lat_pulldown',
    name: 'Máy kéo xô (Lat Pulldown Machine)',
    description: 'Chuyên biệt tập cơ lưng xô',
    category: 'Máy & Dây cáp',
    icon: Icons.height_rounded,
  ),

  // Accessories & Bodyweight
  EquipmentItem(
    id: 'bw',
    code: 'bodyweight',
    name: 'Trọng lượng cơ thể (Bodyweight)',
    description: 'Hít đất, kéo xà, squat tay không',
    category: 'Phụ kiện & Thể trọng',
    icon: Icons.accessibility_new_rounded,
  ),
  EquipmentItem(
    id: 'pullup_bar',
    code: 'pullup_bar',
    name: 'Xà đơn / Xà kép (Pull-up / Dip Bar)',
    description: 'Thiết bị tập thân trên thể trọng',
    category: 'Phụ kiện & Thể trọng',
    icon: Icons.horizontal_rule_rounded,
  ),
  EquipmentItem(
    id: 'band',
    code: 'resistance_band',
    name: 'Dây kháng lực (Resistance Bands)',
    description: 'Dây chun đàn hồi hỗ trợ khởi động và tập bổ trợ',
    category: 'Phụ kiện & Thể trọng',
    icon: Icons.all_inclusive_rounded,
  ),
];

abstract final class EquipmentPresets {
  static const fullGym = [
    'db',
    'bb',
    'kb',
    'ez',
    'bench',
    'rack',
    'cable',
    'smith',
    'lat_pulldown',
    'bw',
    'pullup_bar',
    'band',
  ];

  static const homeDumbbell = [
    'db',
    'bench',
    'bw',
    'band',
  ];

  static const bodyweightOnly = [
    'bw',
    'pullup_bar',
    'band',
  ];
}
