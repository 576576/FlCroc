enum CoreStatus { disconnected, connecting, connected, error }

enum TransferStatus { pending, transferring, completed, failed, cancelled }

enum TransferDirection { sent, received }

enum PageLabel {
  dashboard,
  send,
  receive,
  history,
  settings,
}

enum ThemeModeOption { system, light, dark }

enum ColorSchemeType {
  fidelity,
  expressive,
  rainbow,
  fruitSalad,
  monochrome,
}

enum FontFamily { system, notoSans, roboto }

enum FunctionTag {
  updateStatus,
  savePreferences,
  sendFile,
  receiveFile,
  pageChange,
}

enum DashboardWidget {
  transferStats,
  quickTransfer,
  recentTransfers,
}

enum RelayType { defaultRelay, customRelay, noRelay }
