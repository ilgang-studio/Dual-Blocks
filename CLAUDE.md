# Dual Blocks — Codebase Guide

Flutter/Flame 기반 블록 퍼즐 게임. 천사/악마 운명 시스템이 특징.

## 아키텍처 개요

```
lib/game/
├── dual_blocks_game.dart            ← 메인: 상태 선언 + FlameGame 오버라이드
├── dual_blocks_game_lifecycle.dart  ← part: 게임 시작/리셋/턴 흐름
├── dual_blocks_game_tray.dart       ← part: 트레이 관리 (손패 생성/선택/소모)
├── dual_blocks_game_placement.dart  ← part: 블록 배치 + 라인 클리어 + 파괴
├── dual_blocks_game_fate.dart       ← part: 천사/악마 운명 시스템
├── dual_blocks_game_score.dart      ← part: 점수 카운트업 애니메이션
├── dual_blocks_game_input.dart      ← part: 좌표 변환, 드래그, 테마 메뉴 탭
│
├── components/
│   ├── dual_blocks_renderer.dart         ← 렌더링 진입점 (위임자)
│   ├── dual_blocks_renderer_board.dart   ← 보드 셀 그리기
│   ├── dual_blocks_renderer_tray.dart    ← 트레이 블록 그리기
│   ├── dual_blocks_renderer_header.dart  ← 점수/턴/콤보 헤더 그리기
│   └── dual_blocks_renderer_effects.dart ← 이펙트 (클리어 하이라이트, 운명 제거 등)
│
├── systems/                         ← 순수 로직 (상태 없음, 정적 메서드)
│   ├── placement_system.dart        ← 블록 배치 가능 여부 + 실제 배치
│   ├── line_clear_system.dart       ← 가득 찬 행/열 감지 + 제거
│   ├── score_system.dart            ← 점수 계산 (콤보, 저장 점수 정책)
│   ├── hand_generation_system.dart  ← 손패 생성 (가중치 기반 랜덤)
│   ├── fate_system.dart             ← 운명 발동 조건 판정
│   ├── fate_effect_system.dart      ← 운명 효과 (천사 구제, 악마 파괴 셀 선택)
│   ├── devil_block_system.dart      ← 악마 선물 블록 선택 로직
│   ├── alignment_turn_system.dart   ← 정렬 턴 확률 테이블 관리
│   ├── game_flow_system.dart        ← 게임오버 판정 (배치 가능 블록 존재 여부)
│   ├── layout_system.dart           ← 화면 크기 → GameLayout 계산
│   └── turn_flow_system.dart        ← 트레이 소모 후 다음 선택 인덱스 결정
│
├── models/                          ← 불변 데이터 구조
│   ├── render_frame_data.dart       ← 렌더러에 넘기는 스냅샷 (단방향 데이터)
│   ├── game_layout.dart             ← 레이아웃 좌표 (보드/트레이/헤더 rect)
│   ├── block_shape.dart             ← 블록 모양 + 셀 좌표 + 가중치
│   ├── cell_state.dart              ← 셀 상태 (empty / filled / angel / devil)
│   ├── fate_effect.dart             ← FateType / DevilGiftType / FateRemovalEffectType
│   ├── line_clear_result.dart       ← 클리어된 행/열 집합
│   ├── preview_clear_result.dart    ← 드래그 중 예상 클리어 행/열
│   └── block_theme_mode.dart        ← 렌더링 테마 (solid / gradient 등)
│
└── config/
    └── game_constants.dart          ← 보드 크기, 타이머, 가중치 등 전역 상수
```

## 파일 분할 방식

`dual_blocks_game.dart`는 Dart `part`/`part of` 패턴으로 분리됨.  
part 파일들은 각각 `extension _GameXxx on DualBlocksGame { ... }` 형태로 기능을 추가한다.  
상태 필드(`_angelStack`, `board` 등)는 메인 파일에만 선언되고, 모든 part 파일에서 직접 접근 가능 (같은 라이브러리이므로 `_` private도 공유됨).

## 게임 핵심 흐름

1. `onLoad` → `_startNewGame` → `_refillTray` → 손패 생성
2. 플레이어 드래그 → `trySelectTrayFromScreen` → `placeBlock`
3. `placeBlock` → `_applyLineClear` → 콤보/점수 계산 → `_consumeSelectedTrayBlock`
4. 트레이 소진 → `_refillTray(increaseTurn: true)` → 다음 턴
5. 정렬 턴(`isAlignmentTurn`) → 세 슬롯 중 하나 선택 → 천사/악마 발동 가능
6. `_evaluateGameOver` → 배치 가능한 블록이 없으면 게임오버

## 운명 시스템

- **천사** (`angelStack` 3회 누적): 저장 점수 지급 + 구제 클린업 / 배율 / 손패 개선 중 하나
- **악마** (`devilStack` 3회 누적): 점수 -10% + 탐욕(최고 블록 획득) 또는 파괴(셀 제거)
- 클리어 점수는 천사 스택이 있을 때 `_storedScore`에 누적됨
