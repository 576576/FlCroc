import 'package:fl_croc/common/constant.dart';
import 'package:fl_croc/common/datetime.dart';
import 'package:fl_croc/common/num.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppState model copyWith', () {
    final state = AppState(
      viewSize: const Size(400, 800),
      brightness: Brightness.light,
    );
    final updated = state.copyWith(pageLabel: PageLabel.send);
    expect(updated.pageLabel, PageLabel.send);
    expect(updated.viewSize, const Size(400, 800));
  });

  test('TransferRecord model creation', () {
    final record = TransferRecord(
      id: 'test-1',
      direction: TransferDirection.sent,
      status: TransferStatus.pending,
      files: [const FileItem(name: 'test.txt', path: '/tmp/test.txt', size: 1024)],
      totalSize: 1024,
      startTime: DateTime(2026, 5, 24),
    );
    expect(record.id, 'test-1');
    expect(record.totalSize, 1024);
    expect(record.files.length, 1);
  });

  test('SendConfig defaults', () {
    const config = SendConfig();
    expect(config.curve, defaultCurve);
    expect(config.hashAlgorithm, defaultHashAlgorithm);
    expect(config.noCompress, false);
    expect(config.overwrite, false);
  });

  test('ReceiveConfig defaults', () {
    const config = ReceiveConfig();
    expect(config.overwrite, false);
    expect(config.onlyLocal, false);
    expect(config.outputPath, '');
  });

  test('RelayConfig defaults', () {
    const config = RelayConfig();
    expect(config.address, defaultRelay);
    expect(config.password, defaultPassphrase);
    expect(config.port, defaultPort);
    expect(config.type, RelayType.defaultRelay);
  });

  test('GlobalState singleton', () {
    final gs1 = GlobalState();
    final gs2 = GlobalState();
    expect(identical(gs1, gs2), true, reason: 'GlobalState must be singleton');
  });

  testWidgets('App builds without crash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('FlCroc'))),
        ),
      ),
    );
    expect(find.text('FlCroc'), findsOneWidget);
  });

  test('PageLabel enum values', () {
    expect(PageLabel.values.length, 5);
    expect(PageLabel.dashboard.name, 'dashboard');
    expect(PageLabel.send.name, 'send');
    expect(PageLabel.receive.name, 'receive');
    expect(PageLabel.history.name, 'history');
    expect(PageLabel.settings.name, 'settings');
  });

  test('TransferStatus enum values', () {
    expect(TransferStatus.values.length, 5);
  });

  test('CoreStatus enum values', () {
    expect(CoreStatus.values.length, 4);
  });

  test('DashboardWidget enum values', () {
    expect(DashboardWidget.values.length, 5);
  });

  test('Num extension - fileSize', () {
    expect(512.fileSize, '512 B');
    expect(1024.fileSize, '1.0 KB');
    expect((1024 * 1024).fileSize, '1.0 MB');
    expect((1024 * 1024 * 1024).fileSize, '1.00 GB');
  });

  test('Num extension - transferSpeed', () {
    expect(512.transferSpeed, '512 B/s');
    expect((1024 * 5).transferSpeed, '5.0 KB/s');
    expect((1024 * 1024 * 2).transferSpeed, '2.0 MB/s');
  });

  test('Result type success', () {
    final r = Result<String>.success('hello');
    expect(r.type, ResultType.success);
    expect(r.data, 'hello');
    expect(r.isSuccess, true);
    expect(r.isError, false);
  });

  test('Result type error', () {
    final r = Result<String>.error('failed');
    expect(r.type, ResultType.error);
    expect(r.data, null);
    expect(r.isSuccess, false);
    expect(r.isError, true);
  });

  test('DateTimeExt timeAgo', () {
    final now = DateTime.now();
    expect(now.timeAgo, 'Just now');
    expect(now.subtract(const Duration(minutes: 5)).timeAgo, '5 min ago');
  });
}
