import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const _threshold = 90;
const _minimumRegionArea = 400;
const _simplifyEpsilon = 1.35;

void main() {
  final front = _vectorize(
    sourcePath: 'assets/images/body/body_muscles_front_v2.jpg',
    side: 'front',
  );
  final back = _vectorize(
    sourcePath: 'assets/images/body/body_muscles_back_v2.jpg',
    side: 'back',
  );

  _writeSvg(front);
  _writeSvg(back);
  _writeDart(front, back);

  stdout.writeln(
    'Generated ${front.regions.length} front paths and '
    '${back.regions.length} back paths.',
  );
}

_VectorizedImage _vectorize({
  required String sourcePath,
  required String side,
}) {
  final image = img.decodeImage(File(sourcePath).readAsBytesSync());
  if (image == null) throw StateError('Cannot decode $sourcePath');

  final width = image.width;
  final height = image.height;
  final mask = Uint8List(width * height);
  for (final pixel in image) {
    if (pixel.luminance >= _threshold) {
      mask[pixel.y * width + pixel.x] = 1;
    }
  }

  final queue = Int32List(mask.length);
  final regions = <_Region>[];
  for (var start = 0; start < mask.length; start++) {
    if (mask[start] != 1) continue;
    var head = 0;
    var tail = 0;
    queue[tail++] = start;
    mask[start] = 2;
    final pixels = <int>{};
    var sumX = 0;
    var sumY = 0;

    while (head < tail) {
      final index = queue[head++];
      final x = index % width;
      final y = index ~/ width;
      pixels.add(index);
      sumX += x;
      sumY += y;

      void add(int next) {
        if (next >= 0 && next < mask.length && mask[next] == 1) {
          mask[next] = 2;
          queue[tail++] = next;
        }
      }

      if (x > 0) add(index - 1);
      if (x + 1 < width) add(index + 1);
      if (y > 0) add(index - width);
      if (y + 1 < height) add(index + width);
    }

    if (pixels.length < _minimumRegionArea) continue;
    final centerX = sumX / pixels.length;
    final centerY = sumY / pixels.length;
    final group = side == 'front'
        ? _frontGroup(centerX, centerY, pixels.length)
        : _backGroup(centerX, centerY, pixels.length);
    final contour = _outerContour(pixels, width);
    regions.add(
      _Region(
        group: group,
        points: _simplifyClosed(contour, _simplifyEpsilon),
        area: pixels.length,
        centerX: centerX,
        centerY: centerY,
      ),
    );
  }

  regions.sort((a, b) {
    final groupOrder = a.group.compareTo(b.group);
    if (groupOrder != 0) return groupOrder;
    final yOrder = a.centerY.compareTo(b.centerY);
    return yOrder != 0 ? yOrder : a.centerX.compareTo(b.centerX);
  });

  return _VectorizedImage(
    side: side,
    sourcePath: sourcePath,
    width: width,
    height: height,
    regions: regions,
  );
}

String _frontGroup(double x, double y, int area) {
  if (y < 335) return 'traps';
  if (y < 430) return area > 9000 ? 'chest' : 'frontDelts';
  if (y < 540) {
    if (x < 290 || x > 549) return 'biceps';
    if (x > 340 && x < 479) return 'abs';
    return 'obliques';
  }
  if (y < 690) {
    if (x < 260 || x > 559) return 'forearms';
    if (x > 355 && x < 464) return 'abs';
    return 'obliques';
  }
  if (y < 1050) {
    if (y < 900 && x > 360 && x < 459) return 'adductors';
    return 'quads';
  }
  return 'calves';
}

String _backGroup(double x, double y, int area) {
  if (y < 410) return area > 10000 ? 'traps' : 'rearDelts';
  if (y < 450) return 'upperBack';
  if (y < 555) return area > 8000 ? 'lats' : 'triceps';
  if (y < 710) {
    if (x < 260 || x > 565) return 'forearms';
    return 'lowerBack';
  }
  if (y < 830) return 'glutes';
  if (y < 1120) return 'hamstrings';
  return 'calves';
}

List<_Point> _outerContour(Set<int> pixels, int width) {
  final vertexWidth = width + 1;
  final nextVertices = <int, List<int>>{};

  void edge(int x1, int y1, int x2, int y2) {
    final start = y1 * vertexWidth + x1;
    final end = y2 * vertexWidth + x2;
    nextVertices.putIfAbsent(start, () => <int>[]).add(end);
  }

  for (final index in pixels) {
    final x = index % width;
    final y = index ~/ width;
    if (!pixels.contains(index - width)) edge(x, y, x + 1, y);
    if (!pixels.contains(index + 1) || x + 1 == width) {
      edge(x + 1, y, x + 1, y + 1);
    }
    if (!pixels.contains(index + width)) {
      edge(x + 1, y + 1, x, y + 1);
    }
    if (!pixels.contains(index - 1) || x == 0) edge(x, y + 1, x, y);
  }

  final vertexCount = vertexWidth * 2000;
  final used = <int>{};
  final loops = <List<_Point>>[];
  for (final entry in nextVertices.entries) {
    for (final firstEnd in entry.value) {
      final firstKey = entry.key * vertexCount + firstEnd;
      if (used.contains(firstKey)) continue;
      final loop = <_Point>[];
      final start = entry.key;
      var current = start;
      var next = firstEnd;
      while (true) {
        loop.add(_decodeVertex(current, vertexWidth));
        used.add(current * vertexCount + next);
        current = next;
        if (current == start) break;
        final candidates = nextVertices[current];
        if (candidates == null) break;
        final unused = candidates.where(
          (candidate) => !used.contains(current * vertexCount + candidate),
        );
        if (unused.isEmpty) break;
        next = unused.first;
      }
      if (loop.length >= 3 && current == start) loops.add(loop);
    }
  }

  if (loops.isEmpty) throw StateError('Could not trace component boundary');
  loops.sort((a, b) => _signedArea(b).abs().compareTo(_signedArea(a).abs()));
  return loops.first;
}

_Point _decodeVertex(int value, int vertexWidth) =>
    _Point(value % vertexWidth, value ~/ vertexWidth);

double _signedArea(List<_Point> points) {
  var area = 0.0;
  for (var i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    area += a.x * b.y - b.x * a.y;
  }
  return area / 2;
}

List<_Point> _simplifyClosed(List<_Point> points, double epsilon) {
  if (points.length < 4) return points;
  var farthest = 1;
  var farthestDistance = -1.0;
  for (var i = 1; i < points.length; i++) {
    final distance = _distanceSquared(points.first, points[i]);
    if (distance > farthestDistance) {
      farthestDistance = distance;
      farthest = i;
    }
  }
  final firstArc = _simplifyOpen(points.sublist(0, farthest + 1), epsilon);
  final secondArc = _simplifyOpen([
    ...points.sublist(farthest),
    points.first,
  ], epsilon);
  return [...firstArc.sublist(0, firstArc.length - 1), ...secondArc]
    ..removeLast();
}

List<_Point> _simplifyOpen(List<_Point> points, double epsilon) {
  if (points.length <= 2) return points;
  var maxDistance = 0.0;
  var split = 0;
  for (var i = 1; i < points.length - 1; i++) {
    final distance = _segmentDistance(points[i], points.first, points.last);
    if (distance > maxDistance) {
      maxDistance = distance;
      split = i;
    }
  }
  if (maxDistance <= epsilon) return [points.first, points.last];
  final left = _simplifyOpen(points.sublist(0, split + 1), epsilon);
  final right = _simplifyOpen(points.sublist(split), epsilon);
  return [...left.sublist(0, left.length - 1), ...right];
}

double _segmentDistance(_Point point, _Point start, _Point end) {
  final dx = end.x - start.x;
  final dy = end.y - start.y;
  if (dx == 0 && dy == 0) return math.sqrt(_distanceSquared(point, start));
  final t =
      (((point.x - start.x) * dx + (point.y - start.y) * dy) /
              (dx * dx + dy * dy))
          .clamp(0.0, 1.0);
  final projectedX = start.x + t * dx;
  final projectedY = start.y + t * dy;
  final px = point.x - projectedX;
  final py = point.y - projectedY;
  return math.sqrt(px * px + py * py);
}

double _distanceSquared(_Point a, _Point b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return (dx * dx + dy * dy).toDouble();
}

void _writeSvg(_VectorizedImage image) {
  final outputPath = 'assets/images/body/body_muscles_${image.side}.svg';
  final sourceName = image.sourcePath.split('/').last;
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'viewBox="0 0 ${image.width} ${image.height}">',
    )
    ..writeln(
      '  <image href="$sourceName" x="0" y="0" '
      'width="${image.width}" height="${image.height}"/>',
    )
    ..writeln('  <g id="muscle-regions" fill="none" pointer-events="all">');
  final counts = <String, int>{};
  for (final region in image.regions) {
    final count = (counts[region.group] ?? 0) + 1;
    counts[region.group] = count;
    buffer.writeln(
      '    <path id="${_svgId(region.group)}-$count" '
      'data-muscle="${_svgId(region.group)}" d="${_svgPath(region.points)}"/>',
    );
  }
  buffer
    ..writeln('  </g>')
    ..writeln('</svg>');
  File(outputPath).writeAsStringSync(buffer.toString());
}

void _writeDart(_VectorizedImage front, _VectorizedImage back) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT EDIT BY HAND.')
    ..writeln('// Run: dart run tool/generate_muscle_svg.dart')
    ..writeln()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln("import '../../domain/muscle_models.dart';")
    ..writeln()
    ..writeln('Size generatedMuscleReferenceSize(BodySide side) =>')
    ..writeln('    side == BodySide.front')
    ..writeln('        ? const Size(${front.width}, ${front.height})')
    ..writeln('        : const Size(${back.width}, ${back.height});')
    ..writeln()
    ..writeln(
      'Map<MuscleGroup, List<Path>> generatedMuscleRegions(BodySide side) =>',
    )
    ..writeln('    side == BodySide.front ? _frontRegions : _backRegions;')
    ..writeln();

  _writeDartMap(buffer, '_frontRegions', front.regions, front: true);
  _writeDartMap(buffer, '_backRegions', back.regions, front: false);
  buffer
    ..writeln('Map<MuscleGroup, List<Path>> _withAliases(')
    ..writeln('  Map<MuscleGroup, List<Path>> regions,')
    ..writeln('  Map<MuscleGroup, MuscleGroup> aliases,')
    ..writeln(') {')
    ..writeln('  for (final entry in aliases.entries) {')
    ..writeln('    regions[entry.key] = regions[entry.value]!;')
    ..writeln('  }')
    ..writeln('  return Map.unmodifiable(regions);')
    ..writeln('}')
    ..writeln()
    ..writeln(
      'Path _region(List<Offset> points) => Path()..addPolygon(points, true);',
    );

  File(
    'lib/features/workout/presentation/widgets/body_muscle_regions_generated.dart',
  ).writeAsStringSync(buffer.toString());
}

void _writeDartMap(
  StringBuffer buffer,
  String name,
  List<_Region> regions, {
  required bool front,
}) {
  final grouped = <String, List<_Region>>{};
  for (final region in regions) {
    grouped.putIfAbsent(region.group, () => <_Region>[]).add(region);
  }
  buffer.writeln('final Map<MuscleGroup, List<Path>> $name = _withAliases({');
  for (final entry in grouped.entries) {
    buffer.writeln('  MuscleGroup.${entry.key}: [');
    for (final region in entry.value) {
      buffer.writeln('    _region([');
      for (final point in region.points) {
        buffer.writeln('      Offset(${point.x}, ${point.y}),');
      }
      buffer.writeln('    ]),');
    }
    buffer.writeln('  ],');
  }
  buffer.writeln('}, {');
  if (front) {
    buffer
      ..writeln('  MuscleGroup.upperChest: MuscleGroup.chest,')
      ..writeln('  MuscleGroup.sideDelts: MuscleGroup.frontDelts,');
  } else {
    buffer.writeln('  MuscleGroup.sideDelts: MuscleGroup.rearDelts,');
  }
  buffer
    ..writeln('});')
    ..writeln();
}

String _svgPath(List<_Point> points) {
  final buffer = StringBuffer('M ${points.first.x} ${points.first.y}');
  for (final point in points.skip(1)) {
    buffer.write(' L ${point.x} ${point.y}');
  }
  return '${buffer.toString()} Z';
}

String _svgId(String value) => value.replaceAllMapped(
  RegExp('[A-Z]'),
  (match) => '_${match.group(0)!.toLowerCase()}',
);

class _VectorizedImage {
  const _VectorizedImage({
    required this.side,
    required this.sourcePath,
    required this.width,
    required this.height,
    required this.regions,
  });

  final String side;
  final String sourcePath;
  final int width;
  final int height;
  final List<_Region> regions;
}

class _Region {
  const _Region({
    required this.group,
    required this.points,
    required this.area,
    required this.centerX,
    required this.centerY,
  });

  final String group;
  final List<_Point> points;
  final int area;
  final double centerX;
  final double centerY;
}

class _Point {
  const _Point(this.x, this.y);

  final int x;
  final int y;
}
