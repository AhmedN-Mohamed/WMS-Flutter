import 'package:equatable/equatable.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/staff_entity.dart';

class PresetReportItem extends Equatable {
  final int code;
  final String title;
  final String category; // الفواتير | الدفعات | التحصيلات | المتابعات

  const PresetReportItem({
    required this.code,
    required this.title,
    required this.category,
  });

  @override
  List<Object?> get props => [code, title, category];
}

class ReportsState extends Equatable {
  final RequestStatus status;
  final DateTime fromDate;
  final DateTime toDate;

  // Entity Filters
  final String? selectedCompanyId;
  final String? selectedCustomerId;
  final String? selectedSalespersonId;
  final String? selectedFollowerName;
  final String? selectedLegalAction;
  final String? selectedPriority;

  // Mode Toggles (matching تقارير النظام)
  final String activeCategory; // الفواتير | الدفعات | التحصيلات | المتابعات
  final String dateInclusionMode; // ضمن ت الدفعة | ضمن ت المتابعة | ليست ضمن ت المتابعة
  final bool onlyUncollectedOrPartial; // دفعات لم تحصل او حصلت جزئياً

  final int selectedPresetCode;
  final String selectedReportTitle;

  final List<String> reportColumns;
  final List<List<String>> reportRows;

  // Totals
  final double summaryTotalAmount;
  final double summaryTotalCollected;
  final double summaryTotalRemaining;

  // Lookups
  final List<CompanyEntity> companies;
  final List<CustomerEntity> customers;
  final List<StaffEntity> salespeople;
  final List<StaffEntity> followers;
  final List<String> legalActions;
  final List<String> priorities;

  final String? actionMessage;

  const ReportsState({
    this.status = RequestStatus.initial,
    required this.fromDate,
    required this.toDate,
    this.selectedCompanyId,
    this.selectedCustomerId,
    this.selectedSalespersonId,
    this.selectedFollowerName,
    this.selectedLegalAction,
    this.selectedPriority,
    this.activeCategory = 'المتابعات',
    this.dateInclusionMode = 'ضمن ت الدفعة',
    this.onlyUncollectedOrPartial = false,
    this.selectedPresetCode = 51,
    this.selectedReportTitle = '51 - كل المتابعات',
    this.reportColumns = const [],
    this.reportRows = const [],
    this.summaryTotalAmount = 0.0,
    this.summaryTotalCollected = 0.0,
    this.summaryTotalRemaining = 0.0,
    this.companies = const [],
    this.customers = const [],
    this.salespeople = const [],
    this.followers = const [],
    this.legalActions = const [],
    this.priorities = const [],
    this.actionMessage,
  });

  static const List<PresetReportItem> presetReports = [
    // المتابعات (51-57)
    PresetReportItem(code: 51, title: 'كل المتابعات', category: 'المتابعات'),
    PresetReportItem(code: 52, title: 'متابعات شركة', category: 'المتابعات'),
    PresetReportItem(code: 53, title: 'متابعات بائع', category: 'المتابعات'),
    PresetReportItem(code: 54, title: 'متابعات متابع', category: 'المتابعات'),
    PresetReportItem(code: 55, title: 'متابعات تم تحصيلها بالكامل', category: 'المتابعات'),
    PresetReportItem(code: 56, title: 'متابعات تم تحصيل جزء منها', category: 'المتابعات'),
    PresetReportItem(code: 57, title: 'متابعات لم تحصل (متأخرات)', category: 'المتابعات'),
    // الفواتير (11-15)
    PresetReportItem(code: 11, title: 'كل الفواتير خلال الفترة', category: 'الفواتير'),
    PresetReportItem(code: 12, title: 'فواتير شركة محددة', category: 'الفواتير'),
    PresetReportItem(code: 13, title: 'كشف حساب فواتير عميل', category: 'الفواتير'),
    PresetReportItem(code: 14, title: 'مبيعات وفواتير بائع', category: 'الفواتير'),
    PresetReportItem(code: 15, title: 'فواتير بدون دفعات مجدولة', category: 'الفواتير'),
    // الدفعات (21-25)
    PresetReportItem(code: 21, title: 'كل الدفعات المجدولة', category: 'الدفعات'),
    PresetReportItem(code: 22, title: 'دفعات لم تحصل أو حصلت جزئياً', category: 'الدفعات'),
    PresetReportItem(code: 23, title: 'متأخرات عملاء لبائع', category: 'الدفعات'),
    PresetReportItem(code: 24, title: 'دفعات آجلة لبائع', category: 'الدفعات'),
    PresetReportItem(code: 25, title: 'دفعات ذات إجراءات قانونية', category: 'الدفعات'),
    // التحصيلات (31-34)
    PresetReportItem(code: 31, title: 'كل التحصيلات الفعلية خلال الفترة', category: 'التحصيلات'),
    PresetReportItem(code: 32, title: 'تحصيلات شركة محددة', category: 'التحصيلات'),
    PresetReportItem(code: 33, title: 'تحصيلات محصل محدد', category: 'التحصيلات'),
    PresetReportItem(code: 34, title: 'تحصيلات عميل محدد', category: 'التحصيلات'),
  ];

  ReportsState copyWith({
    RequestStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedCompanyId,
    bool clearCompany = false,
    String? selectedCustomerId,
    bool clearCustomer = false,
    String? selectedSalespersonId,
    bool clearSalesperson = false,
    String? selectedFollowerName,
    bool clearFollower = false,
    String? selectedLegalAction,
    bool clearLegalAction = false,
    String? selectedPriority,
    bool clearPriority = false,
    String? activeCategory,
    String? dateInclusionMode,
    bool? onlyUncollectedOrPartial,
    int? selectedPresetCode,
    String? selectedReportTitle,
    List<String>? reportColumns,
    List<List<String>>? reportRows,
    double? summaryTotalAmount,
    double? summaryTotalCollected,
    double? summaryTotalRemaining,
    List<CompanyEntity>? companies,
    List<CustomerEntity>? customers,
    List<StaffEntity>? salespeople,
    List<StaffEntity>? followers,
    List<String>? legalActions,
    List<String>? priorities,
    String? actionMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedCompanyId:
          clearCompany ? null : (selectedCompanyId ?? this.selectedCompanyId),
      selectedCustomerId: clearCustomer
          ? null
          : (selectedCustomerId ?? this.selectedCustomerId),
      selectedSalespersonId: clearSalesperson
          ? null
          : (selectedSalespersonId ?? this.selectedSalespersonId),
      selectedFollowerName: clearFollower
          ? null
          : (selectedFollowerName ?? this.selectedFollowerName),
      selectedLegalAction: clearLegalAction
          ? null
          : (selectedLegalAction ?? this.selectedLegalAction),
      selectedPriority: clearPriority
          ? null
          : (selectedPriority ?? this.selectedPriority),
      activeCategory: activeCategory ?? this.activeCategory,
      dateInclusionMode: dateInclusionMode ?? this.dateInclusionMode,
      onlyUncollectedOrPartial:
          onlyUncollectedOrPartial ?? this.onlyUncollectedOrPartial,
      selectedPresetCode: selectedPresetCode ?? this.selectedPresetCode,
      selectedReportTitle: selectedReportTitle ?? this.selectedReportTitle,
      reportColumns: reportColumns ?? this.reportColumns,
      reportRows: reportRows ?? this.reportRows,
      summaryTotalAmount: summaryTotalAmount ?? this.summaryTotalAmount,
      summaryTotalCollected:
          summaryTotalCollected ?? this.summaryTotalCollected,
      summaryTotalRemaining:
          summaryTotalRemaining ?? this.summaryTotalRemaining,
      companies: companies ?? this.companies,
      customers: customers ?? this.customers,
      salespeople: salespeople ?? this.salespeople,
      followers: followers ?? this.followers,
      legalActions: legalActions ?? this.legalActions,
      priorities: priorities ?? this.priorities,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        fromDate,
        toDate,
        selectedCompanyId,
        selectedCustomerId,
        selectedSalespersonId,
        selectedFollowerName,
        selectedLegalAction,
        selectedPriority,
        activeCategory,
        dateInclusionMode,
        onlyUncollectedOrPartial,
        selectedPresetCode,
        selectedReportTitle,
        reportColumns,
        reportRows,
        summaryTotalAmount,
        summaryTotalCollected,
        summaryTotalRemaining,
        companies,
        customers,
        salespeople,
        followers,
        legalActions,
        priorities,
        actionMessage,
      ];
}
