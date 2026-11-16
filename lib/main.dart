import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/design_system/design_system.dart';
import 'data/datasources/local_wms_datasource.dart';
import 'data/repositories/wms_repository_impl.dart';
import 'domain/repositories/wms_repository.dart';
import 'presentation/installments/cubit/installments_cubit.dart';
import 'presentation/invoices/cubit/invoices_cubit.dart';
import 'presentation/master_data/cubit/master_data_cubit.dart';
import 'presentation/reports/cubit/reports_cubit.dart';
import 'presentation/shell/cubit/app_shell_cubit.dart';
import 'presentation/shell/views/app_shell_screen.dart';
import 'presentation/system_codes/cubit/system_codes_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dataSource = LocalWmsDataSource();
  final WmsRepository repository = WmsRepositoryImpl(dataSource);
  await repository.init();

  runApp(KanzaWmsApp(repository: repository));
}

class KanzaWmsApp extends StatelessWidget {
  final WmsRepository repository;

  const KanzaWmsApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<WmsRepository>.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppShellCubit>(
            create: (_) => AppShellCubit(repository)..loadSession(),
          ),
          BlocProvider<SystemCodesCubit>(
            create: (_) => SystemCodesCubit(repository)..loadCodes(),
          ),
          BlocProvider<MasterDataCubit>(
            create: (_) => MasterDataCubit(repository)..loadAllMasterData(),
          ),
          BlocProvider<InvoicesCubit>(
            create: (_) => InvoicesCubit(repository)..loadInvoices(),
          ),
          BlocProvider<InstallmentsCubit>(
            create: (_) => InstallmentsCubit(repository)..loadData(),
          ),
          BlocProvider<ReportsCubit>(
            create: (_) => ReportsCubit(repository)..initReports(),
          ),
        ],
        child: MaterialApp(
          title: 'نظام إدارة الشحن والتوزيع والتحصيلات - Kanza Group',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [
            Locale('ar', 'EG'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AppShellScreen(),
        ),
      ),
    );
  }
}
