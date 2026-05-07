import 'dart:math' as math;

class BlockShape {
  const BlockShape({
    required this.id,
    required this.cells,
    required this.weight,
  });

  final String id;
  final List<math.Point<int>> cells;
  final double weight;
}

class BlockCatalog {
  static const BlockShape single = BlockShape(
    id: 'single',
    cells: [math.Point<int>(0, 0)],
    weight: 10,
  );

  static const BlockShape line2 = BlockShape(
    id: 'line2',
    cells: [math.Point<int>(0, 0), math.Point<int>(1, 0)],
    weight: 10,
  );

  static const BlockShape line2V = BlockShape(
    id: 'line2_v',
    cells: [math.Point<int>(0, 0), math.Point<int>(0, 1)],
    weight: 10,
  );

  static const BlockShape line3 = BlockShape(
    id: 'line3',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
    ],
    weight: 8,
  );

  static const BlockShape line3V = BlockShape(
    id: 'line3_v',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(0, 1),
      math.Point<int>(0, 2),
    ],
    weight: 8,
  );

  static const BlockShape line4 = BlockShape(
    id: 'line4',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
      math.Point<int>(3, 0),
    ],
    weight: 5,
  );

  static const BlockShape line4V = BlockShape(
    id: 'line4_v',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(0, 1),
      math.Point<int>(0, 2),
      math.Point<int>(0, 3),
    ],
    weight: 5,
  );

  static const BlockShape line5 = BlockShape(
    id: 'line5',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
      math.Point<int>(3, 0),
      math.Point<int>(4, 0),
    ],
    weight: 3,
  );

  static const BlockShape line5V = BlockShape(
    id: 'line5_v',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(0, 1),
      math.Point<int>(0, 2),
      math.Point<int>(0, 3),
      math.Point<int>(0, 4),
    ],
    weight: 3,
  );

  static const BlockShape square2 = BlockShape(
    id: 'square2',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(0, 1),
      math.Point<int>(1, 1),
    ],
    weight: 8,
  );

  static const BlockShape rect2x3 = BlockShape(
    id: 'rect2x3',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(0, 1),
      math.Point<int>(1, 1),
      math.Point<int>(0, 2),
      math.Point<int>(1, 2),
    ],
    weight: 2,
  );

  static const BlockShape square3 = BlockShape(
    id: 'square3',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
      math.Point<int>(0, 1),
      math.Point<int>(1, 1),
      math.Point<int>(2, 1),
      math.Point<int>(0, 2),
      math.Point<int>(1, 2),
      math.Point<int>(2, 2),
    ],
    weight: 1,
  );

  static const BlockShape l3 = BlockShape(
    id: 'l3',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(0, 1),
      math.Point<int>(1, 1),
    ],
    weight: 5,
  );

  static const BlockShape reverseL3 = BlockShape(
    id: 'reverse_l3',
    cells: [
      math.Point<int>(1, 0),
      math.Point<int>(1, 1),
      math.Point<int>(0, 1),
    ],
    weight: 5,
  );

  static const BlockShape l4 = BlockShape(
    id: 'l4',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(0, 1),
      math.Point<int>(0, 2),
      math.Point<int>(1, 2),
    ],
    weight: 4,
  );

  static const BlockShape reverseL4 = BlockShape(
    id: 'reverse_l4',
    cells: [
      math.Point<int>(1, 0),
      math.Point<int>(1, 1),
      math.Point<int>(1, 2),
      math.Point<int>(0, 2),
    ],
    weight: 4,
  );

  static const BlockShape corner4 = BlockShape(
    id: 'corner4',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
      math.Point<int>(2, 1),
    ],
    weight: 4,
  );

  static const BlockShape t4 = BlockShape(
    id: 't4',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
      math.Point<int>(1, 1),
    ],
    weight: 3,
  );

  static const BlockShape s4 = BlockShape(
    id: 's4',
    cells: [
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
      math.Point<int>(0, 1),
      math.Point<int>(1, 1),
    ],
    weight: 4,
  );

  static const BlockShape z4 = BlockShape(
    id: 'z4',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(1, 1),
      math.Point<int>(2, 1),
    ],
    weight: 4,
  );

  static const List<BlockShape> pool = [
    line2,
    line2V,
    line3,
    line3V,
    line4,
    line4V,
    line5,
    line5V,
    square2,
    rect2x3,
    square3,
    l3,
    reverseL3,
    l4,
    reverseL4,
    corner4,
    t4,
    s4,
    z4,
  ];

  // Backward-compatible aliases while systems migrate to new IDs.
  static const BlockShape line2H = line2;

  static List<BlockShape> randomTray({
    required math.Random random,
    int count = 3,
  }) {
    final shuffled = List<BlockShape>.from(pool)..shuffle(random);
    return shuffled.take(count).toList(growable: false);
  }
}
