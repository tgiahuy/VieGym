import 'package:flutter/material.dart';

enum BodySide {
  front('Mặt trước'),
  back('Mặt sau');

  const BodySide(this.label);
  final String label;
}

enum MuscleHighlightLevel { none, secondary, primary }

enum MuscleGroup {
  chest('Ngực', 'Pectoralis Major', BodySide.front, 'chest'),
  upperChest(
    'Ngực trên',
    'Clavicular Pectoralis',
    BodySide.front,
    'upper_chest',
  ),
  frontDelts('Vai trước', 'Anterior Deltoid', BodySide.front, 'front_delts'),
  sideDelts('Vai giữa', 'Lateral Deltoid', BodySide.front, 'side_delts'),
  rearDelts('Vai sau', 'Posterior Deltoid', BodySide.back, 'rear_delts'),
  biceps('Tay trước', 'Biceps Brachii', BodySide.front, 'biceps'),
  triceps('Tay sau', 'Triceps Brachii', BodySide.back, 'triceps'),
  forearms('Cẳng tay', 'Brachioradialis & Flexors', BodySide.front, 'forearms'),
  abs('Cơ bụng', 'Rectus Abdominis', BodySide.front, 'abs'),
  obliques('Cơ liên sườn', 'External Obliques', BodySide.front, 'obliques'),
  lats('Lưng xô', 'Latissimus Dorsi', BodySide.back, 'lats'),
  traps('Cầu vai', 'Trapezius', BodySide.back, 'traps'),
  upperBack(
    'Lưng trên',
    'Rhomboids & Teres Major',
    BodySide.back,
    'upper_back',
  ),
  lowerBack('Lưng dưới', 'Erector Spinae', BodySide.back, 'lower_back'),
  glutes('Cơ mông', 'Gluteus Maximus', BodySide.back, 'glutes'),
  quads('Đùi trước', 'Quadriceps Femoris', BodySide.front, 'quads'),
  hamstrings(
    'Đùi sau',
    'Hamstrings Biceps Femoris',
    BodySide.back,
    'hamstrings',
  ),
  calves('Bắp chân', 'Gastrocnemius & Soleus', BodySide.back, 'calves'),
  adductors(
    'Cơ khép đùi',
    'Adductor Longus & Magnus',
    BodySide.front,
    'adductors',
  );

  const MuscleGroup(
    this.nameVi,
    this.nameAnatomy,
    this.primarySide,
    this.keyId,
  );

  final String nameVi;
  final String nameAnatomy;
  final BodySide primarySide;
  final String keyId;

  static MuscleGroup? fromString(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final normalized = input.trim().toLowerCase();

    // Match exact keyId
    for (final muscle in MuscleGroup.values) {
      if (muscle.keyId == normalized) return muscle;
    }

    // Match Vietnamese keywords
    if (normalized.contains('ngực trên')) return MuscleGroup.upperChest;
    if (normalized.contains('ngực')) return MuscleGroup.chest;
    if (normalized.contains('vai sau')) return MuscleGroup.rearDelts;
    if (normalized.contains('vai trước')) return MuscleGroup.frontDelts;
    if (normalized.contains('vai')) return MuscleGroup.sideDelts;
    if (normalized.contains('tay trước') || normalized.contains('biceps')) {
      return MuscleGroup.biceps;
    }
    if (normalized.contains('tay sau') || normalized.contains('triceps')) {
      return MuscleGroup.triceps;
    }
    if (normalized.contains('cẳng tay') || normalized.contains('forearm')) {
      return MuscleGroup.forearms;
    }
    if (normalized.contains('bụng') ||
        normalized.contains('trọng tâm') ||
        normalized.contains('abs')) {
      return MuscleGroup.abs;
    }
    if (normalized.contains('liên sườn') || normalized.contains('oblique')) {
      return MuscleGroup.obliques;
    }
    if (normalized.contains('xô') || normalized.contains('lat')) {
      return MuscleGroup.lats;
    }
    if (normalized.contains('cầu vai') || normalized.contains('trap')) {
      return MuscleGroup.traps;
    }
    if (normalized.contains('lưng dưới')) return MuscleGroup.lowerBack;
    if (normalized.contains('lưng trên') || normalized.contains('lưng')) {
      return MuscleGroup.upperBack;
    }
    if (normalized.contains('mông') || normalized.contains('glute')) {
      return MuscleGroup.glutes;
    }
    if (normalized.contains('đùi trước') || normalized.contains('quad')) {
      return MuscleGroup.quads;
    }
    if (normalized.contains('đùi sau') || normalized.contains('hamstring')) {
      return MuscleGroup.hamstrings;
    }
    if (normalized.contains('bắp chân') ||
        normalized.contains('calf') ||
        normalized.contains('calves')) {
      return MuscleGroup.calves;
    }
    if (normalized.contains('khép đùi') || normalized.contains('adductor')) {
      return MuscleGroup.adductors;
    }

    return null;
  }

  Offset get focusNormalizedCenter {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.upperChest:
        return const Offset(0.50, 0.27);
      case MuscleGroup.frontDelts:
      case MuscleGroup.sideDelts:
        return const Offset(0.50, 0.23);
      case MuscleGroup.rearDelts:
        return const Offset(0.50, 0.23);
      case MuscleGroup.traps:
        return const Offset(0.50, 0.18);
      case MuscleGroup.lats:
      case MuscleGroup.upperBack:
        return const Offset(0.50, 0.28);
      case MuscleGroup.lowerBack:
        return const Offset(0.50, 0.38);
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
        return const Offset(0.50, 0.29);
      case MuscleGroup.forearms:
        return const Offset(0.50, 0.36);
      case MuscleGroup.abs:
      case MuscleGroup.obliques:
        return const Offset(0.50, 0.37);
      case MuscleGroup.glutes:
        return const Offset(0.50, 0.47);
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
      case MuscleGroup.adductors:
        return const Offset(0.50, 0.58);
      case MuscleGroup.calves:
        return const Offset(0.50, 0.76);
    }
  }

  double get zoomScale {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.upperChest:
      case MuscleGroup.lats:
      case MuscleGroup.upperBack:
      case MuscleGroup.lowerBack:
      case MuscleGroup.abs:
      case MuscleGroup.obliques:
      case MuscleGroup.traps:
      case MuscleGroup.frontDelts:
      case MuscleGroup.sideDelts:
      case MuscleGroup.rearDelts:
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return 1.55;
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
      case MuscleGroup.adductors:
        return 1.50;
    }
  }

  String get anatomicalFunction {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.upperChest:
        return 'Gập, khép ngang và xoay trong khớp vai; tạo lực đẩy mạnh mẽ cho thân trên.';
      case MuscleGroup.frontDelts:
      case MuscleGroup.sideDelts:
      case MuscleGroup.rearDelts:
        return 'Nâng cánh tay ra trước, sang ngang và kéo ra sau; bảo vệ ổ chảo khớp vai.';
      case MuscleGroup.biceps:
        return 'Gập cùi chỏ và ngửa cẳng tay; phát lực kéo chính trong các bài pull.';
      case MuscleGroup.triceps:
        return 'Duỗi cùi chỏ và hỗ trợ khép cánh tay; điểm tựa lực đẩy khóa khớp.';
      case MuscleGroup.forearms:
        return 'Kiểm soát lực nắm (Grip strength) và ổn định khớp cổ tay.';
      case MuscleGroup.abs:
      case MuscleGroup.obliques:
        return 'Gập cột sống, chống xoay và truyền lực ổn định giữa thân trên - thân dưới.';
      case MuscleGroup.lats:
      case MuscleGroup.upperBack:
        return 'Kéo cánh tay xuống và ra sau, ép xương bả vai; tạo độ rộng chữ V cho lưng.';
      case MuscleGroup.traps:
        return 'Nâng, xoay và cố định xương bả vai trong các chuyển động nâng/kéo nặng.';
      case MuscleGroup.lowerBack:
        return 'Duỗi và giữ thẳng cột sống thắt lưng, chống cong lưng khi chịu tải trọng.';
      case MuscleGroup.glutes:
        return 'Duỗi hông, xoay ngoài và giữ thăng bằng khung chậu khi đứng dậy.';
      case MuscleGroup.quads:
        return 'Duỗi khớp gối và gập hông; nhóm cơ phát lực đẩy chính của thân dưới.';
      case MuscleGroup.hamstrings:
        return 'Gập khớp gối và duỗi khớp hông; giảm tốc và bảo vệ dây chằng gối.';
      case MuscleGroup.adductors:
        return 'Khép đùi và ổn định khớp háng trong chuyển động ngồi xổm.';
      case MuscleGroup.calves:
        return 'Gập lòng bàn chân (Plantarflexion), truyền lực đẩy bật cho bước chân.';
    }
  }
}
