class LineClearResult {
  const LineClearResult({required this.fullRows, required this.fullCols});

  final Set<int> fullRows;
  final Set<int> fullCols;

  bool get hasAny => fullRows.isNotEmpty || fullCols.isNotEmpty;
}
