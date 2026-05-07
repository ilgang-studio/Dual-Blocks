enum BlockThemeMode { solid, custom, rainbow }

extension BlockThemeModeX on BlockThemeMode {
  String get label {
    switch (this) {
      case BlockThemeMode.solid:
        return '단색';
      case BlockThemeMode.custom:
        return '커스텀';
      case BlockThemeMode.rainbow:
        return '알록달록';
    }
  }
}
