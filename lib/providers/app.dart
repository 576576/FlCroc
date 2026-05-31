import 'dart:convert';

import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<AppState> {
  static const _transfersKey = 'transfer_records';
  static const _maxTransfers = 100;

  AppStateNotifier()
      : super(AppState(
          viewSize: Size.zero,
          brightness: Brightness.light,
        )) {
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_transfersKey);
      if (data != null && data.isNotEmpty) {
        final transfers = data
            .map((e) => TransferRecord.fromJson(jsonDecode(e) as Map<String, dynamic>))
            .toList();
        state = state.copyWith(transfers: transfers);
      }
    } catch (_) {}
  }

  Future<void> _saveTransfers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = state.transfers
          .take(_maxTransfers)
          .map((t) => jsonEncode(t.toJson()))
          .toList();
      await prefs.setStringList(_transfersKey, data);
    } catch (_) {}
  }

  void updatePageLabel(PageLabel label) {
    state = state.copyWith(pageLabel: label);
  }

  void updateViewSize(Size size) {
    state = state.copyWith(viewSize: size);
  }

  void setInit(bool isInit) {
    state = state.copyWith(isInit: isInit);
  }

  void updateBrightness(Brightness brightness) {
    state = state.copyWith(brightness: brightness);
  }

  void addTransfer(TransferRecord transfer) {
    state = state.copyWith(transfers: [...state.transfers, transfer]);
    _saveTransfers();
  }

  void updateTransfer(TransferRecord transfer) {
    state = state.copyWith(
      transfers: state.transfers.map((t) => t.id == transfer.id ? transfer : t).toList(),
    );
    _saveTransfers();
  }

  void removeTransfer(String id) {
    state = state.copyWith(
      transfers: state.transfers.where((t) => t.id != id).toList(),
    );
    _saveTransfers();
  }

  void updateCoreStatus(CoreStatus status) {
    state = state.copyWith(coreStatus: status);
  }

  void updateSpeeds(Map<String, double> speeds) {
    state = state.copyWith(speeds: speeds);
  }

  void clearTransfers() {
    state = state.copyWith(transfers: []);
    _saveTransfers();
  }
}

final viewSizeProvider = Provider<Size>((ref) {
  return ref.watch(appStateProvider).viewSize;
});

final currentPageProvider = Provider<PageLabel>((ref) {
  return ref.watch(appStateProvider).pageLabel;
});

final coreStatusProvider = Provider<CoreStatus>((ref) {
  return ref.watch(appStateProvider).coreStatus;
});

final transfersProvider = Provider<List<TransferRecord>>((ref) {
  return ref.watch(appStateProvider).transfers;
});

final systemUiOverlayStyleStateProvider = StateProvider<SystemUiOverlayStyle>(
  (ref) => SystemUiOverlayStyle.light,
);

/// Holds file paths received via Android/iOS share intent.
/// The send page picks these up and clears the list after adding.
final pendingSharedFilesProvider = StateProvider<List<String>>((ref) => []);
