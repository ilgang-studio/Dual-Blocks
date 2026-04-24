class PreviewClearResult {
  const PreviewClearResult({required this.rows, required this.cols});

  final Set<int> rows;
  final Set<int> cols;

  bool get hasAny => rows.isNotEmpty || cols.isNotEmpty;

  static const empty = PreviewClearResult(rows: {}, cols: {});
}
