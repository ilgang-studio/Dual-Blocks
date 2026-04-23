import 'dart:math' as math;

class BlockShape {
  const BlockShape({
    required this.id,
    required this.cells,
  });

  final String id;
  final List<math.Point<int>> cells;
}

class BlockCatalog {
  static const BlockShape single = BlockShape(
    id: 'single',
    cells: [math.Point<int>(0, 0)],
  );

  static const BlockShape line2H = BlockShape(
    id: 'line2_h',
    cells: [math.Point<int>(0, 0), math.Point<int>(1, 0)],
  );

  static const BlockShape line2V = BlockShape(
    id: 'line2_v',
    cells: [math.Point<int>(0, 0), math.Point<int>(0, 1)],
  );

  static const BlockShape l3 = BlockShape(
    id: 'l3',
    cells: [math.Point<int>(0, 0), math.Point<int>(0, 1), math.Point<int>(1, 1)],
  );

  static const BlockShape line3H = BlockShape(
    id: 'line3_h',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(2, 0),
    ],
  );

  static const BlockShape line3V = BlockShape(
    id: 'line3_v',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(0, 1),
      math.Point<int>(0, 2),
    ],
  );

  static const BlockShape square2 = BlockShape(
    id: 'square2',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(0, 1),
      math.Point<int>(1, 1),
    ],
  );

  static const BlockShape zig3 = BlockShape(
    id: 'zig3',
    cells: [
      math.Point<int>(0, 0),
      math.Point<int>(1, 0),
      math.Point<int>(1, 1),
    ],
  );

  static const List<BlockShape> all = [
    single,
    line2H,
    line2V,
    l3,
    line3H,
    line3V,
    square2,
    zig3,
  ];

  static List<BlockShape> randomTray({
    required math.Random random,
    int count = 3,
  }) {
    final pool = List<BlockShape>.from(all);
    pool.shuffle(random);

    if (count <= pool.length) {
      return pool.take(count).toList(growable: false);
    }

    final result = <BlockShape>[];
    while (result.length < count) {
      result.add(all[random.nextInt(all.length)]);
    }
    return result;
  }
}
