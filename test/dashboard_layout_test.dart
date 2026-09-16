// Regression tests for GitHub issue #6 — "Dashboard edits not saving".
//
// These drive the REAL production widgets: DashboardView, the real
// appSettingProvider (which persists through SharedPreferences) and the real
// PageView used for switching tabs. Nothing is re-implemented here, so a
// regression in the actual save/restore chain fails the suite.
//
// The issue reported two symptoms:
//   1. cards could not be dragged to where the user dropped them;
//   2. after tapping the tick to save, switching tabs and coming back reverted
//      the layout to the original.
import 'dart:convert';

import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _qt = DashboardWidget.quickTransfer;
const _ts = DashboardWidget.transferStats;
const _rt = DashboardWidget.recentTransfers;
const _default = [_qt, _ts, _rt];

List<String> _names(Iterable<DashboardWidget> w) =>
    w.map((e) => e.name).toList();

AppSettingProps _roundTrip(AppSettingProps props) => AppSettingProps.fromJson(
      jsonDecode(jsonEncode(props.toJson())) as Map<String, Object?>,
    );

Widget _app(ProviderContainer c, Widget home) => UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        // A fresh key so that repeated pumpWidget() calls really rebuild from
        // scratch instead of reusing the previous MaterialApp subtree.
        key: UniqueKey(),
        locale: const Locale('en'),
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

/// Same navigation mechanism as lib/pages/home.dart: the page is a PageView
/// child, so it is disposed whenever the neighbouring page becomes visible.
Widget _twoPage(ProviderContainer c, PageController pc) => _app(
      c,
      PageView(
        controller: pc,
        children: const [DashboardView(), Center(child: Text('other-page'))],
      ),
    );

Future<void> _seed(ProviderContainer c, List<DashboardWidget> w) => c
    .read(appSettingProvider.notifier)
    .update((s) => s.copyWith(dashboardWidgets: w));

/// What the user actually sees: read the on-screen card order back from the
/// rendered geometry, never from the provider.
List<DashboardWidget> _onScreenOrder(WidgetTester t) {
  final placed = <(double, double, DashboardWidget)>[];
  for (final w in DashboardWidget.values) {
    final f = find.byKey(ValueKey(w));
    if (f.evaluate().isEmpty) continue;
    final o = t.getTopLeft(f.first);
    placed.add((o.dy, o.dx, w));
  }
  placed.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
  return placed.map((e) => e.$3).toList();
}

/// Scoped to the AppBar: SegmentedButton also draws a check icon.
Finder _appBarAction(IconData i) =>
    find.descendant(of: find.byType(AppBar), matching: find.byIcon(i));

/// Fixed pumps only — edit mode runs an endless shake animation, so
/// pumpAndSettle() would never return.
Future<void> _settleFrames(WidgetTester t, [int n = 12]) async {
  for (var i = 0; i < n; i++) {
    await t.pump(const Duration(milliseconds: 40));
  }
}

/// Long-press [from] and drop it on top of [to].
Future<void> _dragCard(
  WidgetTester t,
  DashboardWidget from,
  DashboardWidget to,
) async {
  final g = await t.startGesture(t.getCenter(find.byKey(ValueKey(from))));
  await t.pump(const Duration(milliseconds: 400)); // past the 200 ms delay
  await g.moveTo(t.getCenter(find.byKey(ValueKey(to))));
  await t.pump(const Duration(milliseconds: 120));
  await g.up();
  await _settleFrames(t);
}

/// Switch to the neighbouring page and back, disposing the dashboard.
Future<void> _switchTabAndBack(WidgetTester t, PageController pc) async {
  pc.jumpToPage(1);
  await _settleFrames(t);
  pc.jumpToPage(0);
  await _settleFrames(t);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('config decoding', () {
    test('a non-default layout survives the real JSON codec', () {
      const saved = [_ts, _rt, _qt];
      final props = const AppSettingProps().copyWith(dashboardWidgets: saved);
      expect(_roundTrip(props).dashboardWidgets, saved);
    });

    test('legacy quickSend / quickReceive names migrate to quickTransfer', () {
      // Written by builds before 8684da4, which split quick transfer in two.
      expect(
        _names(const DashboardWidgetListConverter()
            .fromJson(['quickSend', 'transferStats', 'quickReceive'])),
        [_qt.name, _ts.name],
      );
    });

    test('one unknown name no longer discards the whole saved layout', () {
      expect(
        _names(const DashboardWidgetListConverter()
            .fromJson(['transferStats', 'nonsense', 'quickTransfer'])),
        [_ts.name, _qt.name],
      );
    });

    test('duplicates collapse and the first occurrence keeps its position', () {
      expect(
        _names(const DashboardWidgetListConverter()
            .fromJson(['recentTransfers', 'quickTransfer', 'recentTransfers'])),
        [_rt.name, _qt.name],
      );
    });

    test('a missing key falls back to the default layout', () {
      expect(_names(AppSettingProps.fromJson(const {}).dashboardWidgets),
          _names(_default));
    });

    test('an explicitly empty layout is respected, not resurrected', () {
      expect(
          AppSettingProps.fromJson(const {'dashboardWidgets': <Object>[]})
              .dashboardWidgets,
          isEmpty);
    });
  });

  group('dashboard renders what was saved', () {
    testWidgets('a saved layout that does not start with quickTransfer is kept',
        (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _seed(c, const [_ts, _rt, _qt]);

      await t.pumpWidget(_app(c, const DashboardView()));
      await _settleFrames(t);

      expect(_onScreenOrder(t), const [_ts, _rt, _qt],
          reason: '挂载时不得把 quickTransfer 挪回首位');
    });

    testWidgets('a layout the user deleted quickTransfer from stays deleted',
        (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _seed(c, const [_ts, _rt]);

      await t.pumpWidget(_app(c, const DashboardView()));
      await _settleFrames(t);

      expect(_onScreenOrder(t), const [_ts, _rt],
          reason: '用户删掉的卡片不得被自动塞回');
    });

    testWidgets('control: the default layout renders as the default',
        (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _seed(c, _default);

      await t.pumpWidget(_app(c, const DashboardView()));
      await _settleFrames(t);

      expect(_onScreenOrder(t), _default);
    });
  });

  group('saving through the edit button', () {
    testWidgets('removing a card survives a tab round-trip', (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final pc = PageController();
      addTearDown(pc.dispose);

      await _seed(c, _default);
      await t.pumpWidget(_twoPage(c, pc));
      await _settleFrames(t);

      await t.tap(_appBarAction(Icons.edit_outlined));
      await _settleFrames(t);

      final del = find.descendant(
          of: find.byKey(const ValueKey(_qt)), matching: find.byIcon(Icons.close));
      expect(del, findsOneWidget, reason: 'Quick Transfer 卡片上应有删除按钮');
      await t.tap(del.first);
      await _settleFrames(t);
      expect(_onScreenOrder(t), const [_ts, _rt]);

      await t.tap(_appBarAction(Icons.check));
      await _settleFrames(t);

      final persisted =
          (await SharedPreferences.getInstance()).getString('app_settings');
      expect(jsonDecode(persisted!)['dashboardWidgets'], [_ts.name, _rt.name]);

      await _switchTabAndBack(t, pc);
      expect(_onScreenOrder(t), const [_ts, _rt],
          reason: '切走再切回，删除应当仍在（issue #6 症状 2）');
    });

    testWidgets('a reorder survives a tab round-trip', (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final pc = PageController();
      addTearDown(pc.dispose);

      await _seed(c, _default);
      await t.pumpWidget(_twoPage(c, pc));
      await _settleFrames(t);

      await t.tap(_appBarAction(Icons.edit_outlined));
      await _settleFrames(t);
      await _dragCard(t, _rt, _qt);
      final dragged = _onScreenOrder(t);
      expect(dragged, const [_rt, _qt, _ts]);

      await t.tap(_appBarAction(Icons.check));
      await _settleFrames(t);

      await _switchTabAndBack(t, pc);
      expect(_onScreenOrder(t), dragged,
          reason: '切走再切回，拖出来的顺序应当保留');
    });
  });

  group('dragging cards in edit mode', () {
    Future<void> openEditor(WidgetTester t, ProviderContainer c) async {
      await _seed(c, _default);
      await t.pumpWidget(_app(c, const DashboardView()));
      await _settleFrames(t);
      await t.tap(_appBarAction(Icons.edit_outlined));
      await _settleFrames(t);
    }

    testWidgets('a card dragged forward lands on the card it was dropped on',
        (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await openEditor(t, c);

      await _dragCard(t, _qt, _rt);
      expect(_onScreenOrder(t), const [_ts, _rt, _qt],
          reason: '向前拖到末尾就该落到末尾，而不是只前进一格');
    });

    testWidgets('a card dragged backward lands on the card it was dropped on',
        (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await openEditor(t, c);

      await _dragCard(t, _rt, _qt);
      expect(_onScreenOrder(t), const [_rt, _qt, _ts]);
    });

    testWidgets('a one-slot forward drag still moves exactly one slot',
        (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await openEditor(t, c);

      await _dragCard(t, _qt, _ts);
      expect(_onScreenOrder(t), const [_ts, _qt, _rt]);
    });

    testWidgets('cards do not move while not in edit mode', (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await _seed(c, _default);
      await t.pumpWidget(_app(c, const DashboardView()));
      await _settleFrames(t);

      await _dragCard(t, _qt, _rt);
      expect(_onScreenOrder(t), _default);
    });
  });
}
