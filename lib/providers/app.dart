import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
      : super(AppState(
          viewSize: Size.zero,
          brightness: Brightness.light,
        ));

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
  }

  void updateTransfer(TransferRecord transfer) {
    state = state.copyWith(
      transfers: state.transfers.map((t) => t.id == transfer.id ? transfer : t).toList(),
    );
  }

  void removeTransfer(String id) {
    state = state.copyWith(
      transfers: state.transfers.where((t) => t.id != id).toList(),
    );
  }

  void updateCoreStatus(CoreStatus status) {
    state = state.copyWith(coreStatus: status);
  }

  void updateSpeeds(Map<String, double> speeds) {
    state = state.copyWith(speeds: speeds);
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
