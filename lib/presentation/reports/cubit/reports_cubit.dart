import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/request_status.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/staff_entity.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../../../domain/repositories/wms_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final WmsRepository _repository;

  ReportsCubit(this._repository)
      : super(
          ReportsState(
            fromDate: DateTime(2017, 8, 1),
            toDate: DateTime(2026, 12, 31),
          ),
        );

  void initReports() {
    emit(
      state.copyWith(
        status: RequestStatus.success,
        companies: _repository.getCompanies(),
        customers: _repository.getCustomers(),
        salespeople: _repository.getStaff(StaffRole.salesperson),
        followers: _repository.getStaff(StaffRole.collectorFollower),
        legalActions: _repository
            .getSystemCodes(SystemCodeCategory.legalActions)
            .map((e) => e.name)
            .toList(),
        priorities: _repository
            .getSystemCodes(SystemCodeCategory.priorities)
            .map((e) => e.name)
            .toList(),
      ),
    );
    generateReport();
  }

  void updateDateRange({DateTime? from, DateTime? to}) {
    emit(
      state.copyWith(
        fromDate: from ?? state.fromDate,
        toDate: to ?? state.toDate,
      ),
    );
    generateReport();
  }

  void updateEntityFilters({
    String? companyId,
    bool clearCompany = false,
    String? customerId,
    bool clearCustomer = false,
    String? salespersonId,
    bool clearSalesperson = false,
    String? followerName,
    bool clearFollower = false,
    String? legalAction,
    bool clearLegalAction = false,
    String? priority,
    bool clearPriority = false,
  }) {
    emit(
      state.copyWith(
        selectedCompanyId: companyId,
        clearCompany: clearCompany,
        selectedCustomerId: customerId,
        clearCustomer: clearCustomer,
        selectedSalespersonId: salespersonId,
        clearSalesperson: clearSalesperson,
        selectedFollowerName: followerName,
        clearFollower: clearFollower,
        selectedLegalAction: legalAction,
        clearLegalAction: clearLegalAction,
        selectedPriority: priority,
        clearPriority: clearPriority,
      ),
    );
    generateReport();
  }

  void selectPresetReport(PresetReportItem item) {
    bool uncollectedFlag = state.onlyUncollectedOrPartial;
    if (item.code == 55) {
      uncollectedFlag = false;
    } else if (item.code == 22 || item.code == 23 || item.code == 57) {
      uncollectedFlag = true;
    }

    emit(
      state.copyWith(
        selectedPresetCode: item.code,
        selectedReportTitle: '${item.code} - ${item.title}',
        activeCategory: item.category,
        onlyUncollectedOrPartial: uncollectedFlag,
      ),
    );
    generateReport();
  }

  void selectCategory(String category) {
    final firstPreset = ReportsState.presetReports
        .where((p) => p.category == category)
        .firstOrNull;
    emit(
      state.copyWith(
        activeCategory: category,
        selectedPresetCode: firstPreset?.code ?? state.selectedPresetCode,
        selectedReportTitle: firstPreset != null
            ? '${firstPreset.code} - ${firstPreset.title}'
            : category,
      ),
    );
    generateReport();
  }

  void setDateInclusionMode(String mode) {
    emit(state.copyWith(dateInclusionMode: mode));
    generateReport();
  }

  void toggleOnlyUncollected(bool value) {
    emit(state.copyWith(onlyUncollectedOrPartial: value));
    generateReport();
  }

  void triggerSalespersonShortcut({required bool overdueOnly}) {
    emit(
      state.copyWith(
        activeCategory: 'الدفعات',
        onlyUncollectedOrPartial: true,
        selectedPresetCode: overdueOnly ? 23 : 24,
        selectedReportTitle:
            overdueOnly ? '23 - متأخرات عملاء لبائع' : '24 - دفعات آجلة لبائع',
      ),
    );
    generateReport();
  }

  bool _inDateRange(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final start =
        DateTime(state.fromDate.year, state.fromDate.month, state.fromDate.day);
    final end =
        DateTime(state.toDate.year, state.toDate.month, state.toDate.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  void generateReport() {
    final invoices = _repository.getInvoices();
    final installments = _repository.getInstallments();
    final collections = _repository.getCollections();

    List<String> columns = [];
    List<List<String>> rows = [];
    double sumTotal = 0.0;
    double sumCollected = 0.0;
    double sumRemaining = 0.0;

    if (state.activeCategory == 'الفواتير') {
      columns = const [
        'ر الفاتورة',
        'ت الفاتورة',
        'الشركة',
        'العميل',
        'البائع',
        'قيمة الفاتورة',
        'المسدد',
        'المتبقي',
        'العملة',
      ];
      for (final inv in invoices) {
        if (!_inDateRange(inv.invoiceDate)) continue;
        if (state.selectedCompanyId != null &&
            inv.companyId != state.selectedCompanyId) {
          continue;
        }
        if (state.selectedCustomerId != null &&
            inv.customerId != state.selectedCustomerId) {
          continue;
        }
        if (state.selectedSalespersonId != null &&
            inv.salespersonId != state.selectedSalespersonId) {
          continue;
        }
        final invInst =
            installments.where((i) => i.invoiceId == inv.id).toList();
        final scheduled =
            invInst.fold<double>(0.0, (s, i) => s + i.amount);
        final collected =
            invInst.fold<double>(0.0, (s, i) => s + i.collectedAmount);
        final remaining = (inv.totalAmount - collected).clamp(0.0, double.infinity);

        if (state.selectedPresetCode == 15 &&
            (inv.totalAmount - scheduled) <= 0.01) {
          continue;
        }
        if (state.onlyUncollectedOrPartial && remaining <= 0.01) continue;

        sumTotal += inv.totalAmount;
        sumCollected += collected;
        sumRemaining += remaining;

        rows.add([
          inv.invoiceNumber,
          AppFormatters.formatDate(inv.invoiceDate),
          inv.companyName,
          inv.customerName,
          inv.salespersonName,
          AppFormatters.formatAmount(inv.totalAmount),
          AppFormatters.formatAmount(collected),
          AppFormatters.formatAmount(remaining),
          inv.currency,
        ]);
      }
    } else if (state.activeCategory == 'التحصيلات') {
      columns = const [
        'ر الفاتورة',
        'ت التحصيل',
        'الشركة',
        'العميل',
        'القيمة المحصلة',
        'طريقة السداد',
        'المحصل',
        'ملاحظات السداد',
      ];
      for (final c in collections) {
        if (!_inDateRange(c.collectionDate)) continue;
        if (state.selectedCompanyId != null &&
            c.companyId != state.selectedCompanyId) {
          continue;
        }
        if (state.selectedCustomerId != null &&
            c.customerId != state.selectedCustomerId) {
          continue;
        }
        if (state.selectedFollowerName != null &&
            c.collectorName != state.selectedFollowerName) {
          continue;
        }
        sumCollected += c.collectedAmount;
        rows.add([
          c.invoiceNumber,
          AppFormatters.formatDate(c.collectionDate),
          c.companyName,
          c.customerName,
          AppFormatters.formatAmount(c.collectedAmount),
          c.paymentMethod,
          c.collectorName,
          c.notes,
        ]);
      }
      sumTotal = sumCollected;
    } else {
      // الدفعات أو المتابعات
      columns = const [
        'ر الفاتورة',
        'الشركة',
        'العميل',
        'البائع',
        'المتابع',
        'قيمة الدفعة',
        'المسدد',
        'الباقي للمتابعة',
        'ت الدفعة',
        'ت المتابعة',
        'الأولوية',
        'إجراء قانوني',
        'متابعة الدفعة',
      ];

      for (final inst in installments) {
        // Date Inclusion Rule
        final inDue = _inDateRange(inst.dueDate);
        final inFollow = _inDateRange(inst.followUpDate);
        if (state.dateInclusionMode == 'ضمن ت الدفعة' && !inDue) continue;
        if (state.dateInclusionMode == 'ضمن ت المتابعة' && !inFollow) continue;
        if (state.dateInclusionMode == 'ليست ضمن ت المتابعة' && inFollow) {
          continue;
        }

        if (state.selectedCompanyId != null &&
            inst.companyId != state.selectedCompanyId) {
          continue;
        }
        if (state.selectedCustomerId != null &&
            inst.customerId != state.selectedCustomerId) {
          continue;
        }
        if (state.selectedSalespersonId != null &&
            inst.salespersonId != state.selectedSalespersonId) {
          continue;
        }
        if (state.selectedFollowerName != null &&
            inst.followerName != state.selectedFollowerName) {
          continue;
        }
        if (state.selectedLegalAction != null &&
            inst.legalAction != state.selectedLegalAction) {
          continue;
        }
        if (state.selectedPriority != null &&
            inst.priority != state.selectedPriority) {
          continue;
        }

        // Preset specific filters
        if (state.selectedPresetCode == 55 && !inst.isFullyPaid) continue;
        if (state.selectedPresetCode == 56 && !inst.isPartiallyPaid) continue;
        if (state.selectedPresetCode == 57 && inst.isFullyPaid) continue;
        if (state.selectedPresetCode == 23 && !inst.isOverdue) continue;
        if (state.selectedPresetCode == 24 &&
            (inst.isFullyPaid || inst.isOverdue)) {
          continue;
        }
        if (state.selectedPresetCode == 25 && inst.legalAction == 'بدون') {
          continue;
        }
        if (state.onlyUncollectedOrPartial && inst.isFullyPaid) continue;

        sumTotal += inst.amount;
        sumCollected += inst.collectedAmount;
        sumRemaining += inst.remainingAmount;

        rows.add([
          inst.invoiceNumber,
          inst.companyName,
          inst.customerName,
          inst.salespersonName,
          inst.followerName,
          AppFormatters.formatAmount(inst.amount),
          AppFormatters.formatAmount(inst.collectedAmount),
          AppFormatters.formatAmount(inst.remainingAmount),
          AppFormatters.formatDate(inst.dueDate),
          AppFormatters.formatDate(inst.followUpDate),
          inst.priority,
          inst.legalAction,
          inst.followUpNotes.isEmpty ? inst.description : inst.followUpNotes,
        ]);
      }
    }

    emit(
      state.copyWith(
        status: RequestStatus.success,
        reportColumns: columns,
        reportRows: rows,
        summaryTotalAmount: sumTotal,
        summaryTotalCollected: sumCollected,
        summaryTotalRemaining: sumRemaining,
      ),
    );
  }
}
