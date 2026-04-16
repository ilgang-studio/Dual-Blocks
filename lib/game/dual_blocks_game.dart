import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

final bg = Paint()..color = const Color(0xFF1F2937);
final line = Paint()
  ..color = const Color(0xFF374151)
  ..strokeWidth = 1;
final trayPaint = Paint()..color = const Color(0xFF111827);
final scorePaint = Paint()..color = const Color(0xFF111827);

class DualBlocksGame extends FlameGame {
  static const int boardSize = 8;

  late double cellSize;
  late Rect boardRect;
  late Rect bottomTrayRect;
  late Rect scoreRect;
  // 점수 상태는 레이아웃 함수가 아니라 클래스 필드로 둬야 유지됨.
  int score = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _recalcLayout(size);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    _recalcLayout(canvasSize);
  }

  void _recalcLayout(Vector2 s) {
    const double horizontalPadding = 16;
    const double topPadding = 100;
    const double trayHeight = 120;
    const double gap = 16;

    // `int score = 0;`를 여기 두면 resize마다 초기화됨.
    // 점수는 클래스 필드에서 관리.

    final usableW = s.x - horizontalPadding * 2;
    final usableH = s.y - topPadding - trayHeight - gap - 16;

    cellSize = math.min(usableW / boardSize, usableH / boardSize);
    final boardPx = cellSize * boardSize;

    final boardLeft = (s.x - boardPx) / 2; // 중앙 정렬
    final boardTop = topPadding;

    boardRect = Rect.fromLTWH(boardLeft, boardTop, boardPx, boardPx);
    // scoreRect는 boardRect 계산 "이후"에 초기화해야 안전함.
    scoreRect = Rect.fromLTWH( // 점수 영역
      boardLeft,
      boardRect.top - 70,
      boardRect.width,
      50,
    );

    bottomTrayRect = Rect.fromLTWH( // 바텀 트레이 영역
      horizontalPadding,
      boardRect.bottom + gap,
      s.x - horizontalPadding * 2,
      trayHeight,
    );
  }

  // 화면 좌표 -> 보드 인덱스
  math.Point<int>? screenToBoard(Offset p) { 
    if (!boardRect.contains(p)) return null; // 만약 보드 밖ㅇ이라면 null
    final col = ((p.dx - boardRect.left) / cellSize).floor(); // 보드 왼쪽을 0, 오른쪽으로 갈수록 증가하는 col 계산
    final row = ((p.dy - boardRect.top) / cellSize).floor(); // 보드 위쪽을
    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) return null;
    return math.Point(row, col);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 보드 배경
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(12)),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scoreRect, const Radius.circular(12)),
      scorePaint,
    );
    // 점수 텍스트는 scoreRect를 그린 직후에 배치.
    final textPainter = TextPainter( // 점수 텍스트
      text: TextSpan(
        text: 'Score: $score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr, // 텍스트 방향 Lift -> Right
    );

    textPainter.layout(); // 텍스트 레이아웃 계산

    textPainter.paint( // 텍스트 배치
      canvas,
      Offset(
        scoreRect.center.dx - textPainter.width / 2,
        scoreRect.center.dy - textPainter.height / 2,
      ),
    );
    

    // 8x8 그리드
    // 세로선 (cols)
    for (int col = 0; col <= boardSize; col++) {
      final x = boardRect.left + col * cellSize;
      canvas.drawLine(
        Offset(x, boardRect.top),
        Offset(x, boardRect.bottom),
        line,
      );
    }

    // 가로선 (rows)
    for (int row = 0; row <= boardSize; row++) {
      final y = boardRect.top + row * cellSize;
      canvas.drawLine(
        Offset(boardRect.left, y),
        Offset(boardRect.right, y),
        line,
      );
    }

    // 하단 3블록 영역
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomTrayRect, const Radius.circular(12)),
      trayPaint,
    );
  }
}
