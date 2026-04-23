enum CellState {
  empty,
  filled,
  angelFilled,
  devilFilled,
}

extension CellStateX on CellState {
  bool get isOccupied => this != CellState.empty;
}
