import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanza_wms/data/datasources/local_wms_datasource.dart';
import 'package:kanza_wms/data/repositories/wms_repository_impl.dart';
import 'package:kanza_wms/main.dart';
import 'package:kanza_wms/presentation/shell/cubit/app_shell_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'Kanza WMS desktop shell renders and navigates across all 12 screens cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final dataSource = LocalWmsDataSource();
    final repo = WmsRepositoryImpl(dataSource);
    await repo.init();

    await tester.pumpWidget(KanzaWmsApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.textContaining('KANZA GROUP'), findsWidgets);

    // Navigate through every module tab in the sidebar
    for (final tab in AppNavTab.values) {
      await tester.tap(find.text(tab.title).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Failed on tab: ${tab.name}');
    }
  });
}
