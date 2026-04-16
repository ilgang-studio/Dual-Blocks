import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class DualBlocksGame extends FlameGame {
    static const int boardRows = 8;
    static const int boardCols = 8;

    late final double cellSize;
    late final Vector2 boardSize;
    late final Vector2 boardPosition;

    @override
    Future<void> onLoad() async {
        await super.onLoad();

        final maxBoardWidth = size.x * 0.85;
        final maxBoardHeight = size.y * 0.6;

        cellSize = (maxBoardWidth / boardCols < maxBoardHeight / boardRows)
            ? maxBoardWidth / boardCols
            : maxBoardHeight / boardRows;

        boardSize = Vector2(
        boardCols * cellSize,
        boardRows * cellSize,
        );

        boardPosition = Vector2(
        (size.x - boardSize.x) / 2,
        size.y * 0.14,
        );

        add(
        RectangleComponent(
            position: boardPosition,
            size: boardSize,
            paint: Paint()..color = const Color(0xFFF4F4F4),
        ),
        );

        add(
        BoardGrid(
            position: boardPosition,
            size: boardSize,
            rows: boardRows,
            cols: boardCols,
            cellSize: cellSize,
        ),
        );
    }

@override
Color backgroundColor() => const Color(0xFFE7E7E7);
}

class BoardGrid extends PositionComponent {
    BoardGrid({
        required super.position,
        required super.size,
        required this.rows,
        required this.cols,
        required this.cellSize,
    });

    final int rows;
    final int cols;
    final double cellSize;

    final Paint linePaint = Paint()
        ..color = const Color(0xFFBDBDBD)
        ..strokeWidth = 1;

    final Paint borderPaint = Paint()
        ..color = const Color(0xFF6E6E6E)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

    @override
    void render(Canvas canvas) {
        super.render(canvas);

        for (int row = 0; row <= rows; row++) {
        final y = row * cellSize;
        canvas.drawLine(
            Offset(0, y),
            Offset(size.x, y),
            linePaint,
        );
        }

        for (int col = 0; col <= cols; col++) {
        final x = col * cellSize;
        canvas.drawLine(
            Offset(x, 0),
            Offset(x, size.y),
            linePaint,
        );
        }

        canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        borderPaint,
        );
    }
}