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

  static const BlockShape line3 = BlockShape(
    id: 'line3',
    cells: [math.Point<int>(0, 0), math.Point<int>(1, 0), math.Point<int>(2, 0)],
    weight: 8,
  );

  static const BlockShape l3 = BlockShape(
    id: 'l3',
    cells: [math.Point<int>(0, 0), math.Point<int>(0, 1), math.Point<int>(1, 1)],
    weight: 5,
  );

  static const BlockShape reverseL3 = BlockShape(
    id: 'reverse_l3',
    cells: [math.Point<int>(1, 0), math.Point<int>(1, 1), math.Point<int>(0, 1)],
    weight: 5,
  );

  static const BlockShape line4 = BlockShape(
    id: 'line4',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
      math.Point<int>(3, 0),
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
    weight: 7,
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

  static const List<BlockShape> pool = [
    single,
    line2,
    line3,
    square2,
    l3,
    reverseL3,
    line4,
    t4,
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
