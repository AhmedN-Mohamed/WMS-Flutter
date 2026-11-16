import 'package:equatable/equatable.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/audit_log_entity.dart';
import '../../../domain/entities/system_code_entity.dart';

enum AppNavTab {
  dashboard('الرئيسية ولوحة المتابعة'),
  invoices('فواتير الشركات'),
  installments('دفعات للتحصيل والمتابعة'),
  reports('تقارير النظام'),
  companies('بيانات الشركات'),
  bankAccounts('الحسابات البنكية للشركات'),
  customers('بيانات العملاء'),
  salespeople('بيانات البائعين'),
  shippingReps('مندوبين الشحن'),
  collectors('المتابعين والمحصلين'),
  products('المنتجات والأصناف'),
  systemCodes('أكواد النظام');

  final String title;
  const AppNavTab(this.title);
}

class AppShellState extends Equatable {
  final RequestStatus status;
  final AppNavTab selectedTab;
  final String currentUserCode;
  final String currentUserName;
  final List<SystemCodeEntity> availableUsers;
  final List<AuditLogEntity> auditLogs;
  final String? focusedInvoiceId;

  const AppShellState({
    this.status = RequestStatus.initial,
    this.selectedTab = AppNavTab.dashboard,
    this.currentUserCode = '002',
    this.currentUserName = 'محمد أسعد',
    this.availableUsers = const [],
    this.auditLogs = const [],
    this.focusedInvoiceId,
  });

  AppShellState copyWith({
    RequestStatus? status,
    AppNavTab? selectedTab,
    String? currentUserCode,
    String? currentUserName,
    List<SystemCodeEntity>? availableUsers,
    List<AuditLogEntity>? auditLogs,
    String? focusedInvoiceId,
    bool clearFocusedInvoice = false,
  }) {
    return AppShellState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      currentUserCode: currentUserCode ?? this.currentUserCode,
      currentUserName: currentUserName ?? this.currentUserName,
      availableUsers: availableUsers ?? this.availableUsers,
      auditLogs: auditLogs ?? this.auditLogs,
      focusedInvoiceId:
          clearFocusedInvoice ? null : (focusedInvoiceId ?? this.focusedInvoiceId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        currentUserCode,
        currentUserName,
        availableUsers,
        auditLogs,
        focusedInvoiceId,
      ];
}
