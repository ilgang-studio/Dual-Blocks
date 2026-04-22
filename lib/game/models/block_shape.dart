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

  static const List<BlockShape> starterSet = [
    single,
    line2H,
    l3,
  ];
}
