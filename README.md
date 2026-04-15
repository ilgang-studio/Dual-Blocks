# Dual Blocks

A strategic block puzzle game where every choice shapes your playstyle — angel, devil, or neutral.

전략적인 선택이 플레이 스타일을 결정하는 블록 퍼즐 게임

---

## Overview

Dual Blocks is a block puzzle game built with Flutter and Flame.

Unlike traditional puzzle games, each turn presents three block choices with different characteristics.  
The player must decide between immediate survival, long-term score gain, or stability.

This creates a dynamic gameplay loop driven by decision-making rather than simple placement.

---

## 개요

Dual Blocks는 Flutter와 Flame으로 개발된 블록 퍼즐 게임입니다.

기존 퍼즐 게임과 달리, 매 턴 서로 다른 특성을 가진 3개의 블록이 주어지며  
플레이어는 생존, 점수 누적, 안정성 중 하나를 선택해야 합니다.

단순한 배치가 아닌 “선택” 중심의 게임 플레이를 제공합니다.

---

## Core Mechanics

- 8x8 grid-based board
- Each turn provides 3 blocks:
  - Normal block
  - Angel block (score investment)
  - Devil block (immediate effect with penalty)
- Player selects one block and places it on the board
- Filled rows are cleared
- Angel and Devil selections accumulate effects

---

## 핵심 시스템

- 8x8 그리드 기반 보드
- 매 턴 3개의 블록 제공
  - 일반 블록
  - 천사 블록 (점수 누적)
  - 악마 블록 (즉시 효과 + 패널티)
- 하나를 선택해 보드에 배치
- 가로줄이 채워지면 제거
- 천사/악마 선택은 누적되어 추가 효과 발생

---

## Gameplay Design

The game is designed around trade-offs:

- Angel: weaker in the short term but rewards long-term planning
- Devil: powerful immediately but comes with a cost
- Normal: stable and safe option

Players must constantly adapt their strategy based on the current board state.

---

## 게임 설계

이 게임은 선택에 따른 트레이드오프를 중심으로 설계되었습니다.

- 천사: 당장은 약하지만 장기적으로 큰 보상
- 악마: 즉시 강력하지만 대가가 존재
- 일반: 안정적인 선택

플레이어는 상황에 따라 전략을 계속 바꿔야 합니다.

---

## Tech Stack

- Flutter
- Flame Engine
- Dart

---

## 프로젝트 구조
```
lib/
└─ game/
├─ dual_blocks_game.dart
├─ board/
├─ block/
└─ system/
```

---

## Current Status

- Base Flame setup
- Grid rendering
- Core structure initialized

---

## 현재 진행 상황

- Flame 기본 구조 완료
- 보드 렌더링 구현
- 프로젝트 구조 설계 완료

---

## Roadmap

- Block selection system
- Drag and placement logic
- Line clear system
- Angel / Devil mechanics
- Score system
- UI polish

---

## 개발 계획

- 블록 선택 시스템
- 드래그 및 배치 로직
- 줄 제거 시스템
- 천사 / 악마 메커니즘
- 점수 시스템
- UI 개선

---

## Author

Developed by [Your Name]