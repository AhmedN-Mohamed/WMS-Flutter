import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../core/utils/formatters.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  Future<void> _exportReportToExcel(
    BuildContext context,
    ReportsState state,
  ) async {
    final path = await ExportService.exportToCsv(
      fileNamePrefix: 'تقرير_${state.selectedReportTitle}',
      headers: state.reportColumns,
      rows: state.reportRows,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تصدير التقرير إلى ملف إكسيل: $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              // 1. Top Screen Header
              DsScreenHeader(
                title: 'تقارير النظام',
                subtitle:
                    'فترة الفواتير بناءً على ت إصدار الفاتورة • والدفعات بناءً على ت الدفعة / ت المتابعة • وحركة السداد بناءً على ت التحصيل',
                icon: Icons.assessment_rounded,
                totalCount: state.reportRows.length,
                countLabel: 'سجل بالتقرير',
                actions: [
                  DsButton(
                    label: 'تحديث الجداول',
                    icon: Icons.refresh_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: cubit.initReports,
                  ),
                  DsButton(
                    label: 'تشغيل التقرير (OK)',
                    icon: Icons.play_arrow_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: cubit.generateReport,
                  ),
                  DsButton(
                    label: 'To_Excel',
                    icon: Icons.table_view_rounded,
                    variant: DsButtonVariant.excel,
                    onPressed: () => _exportReportToExcel(context, state),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // 2. Top Filter Control Panel (matching تقارير النظام screenshot)
              DsCard(
                backgroundColor: AppColors.surfaceHighlight,
                borderColor: AppColors.warningBorder,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Right Column: Date Range + Entity Filters
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Row 1: Date Range + Company + Customer + Salesperson
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DsDatePickerField(
                                  label: 'حدد الفترة (من)',
                                  date: state.fromDate,
                                  onDateSelected: (d) =>
                                      cubit.updateDateRange(from: d),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsDatePickerField(
                                  label: 'حدد الفترة (إلى)',
                                  date: state.toDate,
                                  onDateSelected: (d) =>
                                      cubit.updateDateRange(to: d),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 3,
                                child: DsDropdown<String>(
                                  label: 'الشركات',
                                  value: state.selectedCompanyId,
                                  allowClear: true,
                                  hint: 'كل الشركات',
                                  items: state.companies
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => cubit.updateEntityFilters(
                                    companyId: v,
                                    clearCompany: v == null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 3,
                                child: DsDropdown<String>(
                                  label: 'العملاء',
                                  value: state.selectedCustomerId,
                                  allowClear: true,
                                  hint: 'كل العملاء',
                                  items: state.customers
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => cubit.updateEntityFilters(
                                    customerId: v,
                                    clearCustomer: v == null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Row 2: Salesperson + Follower/Collector + Legal Action + Priority
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DsDropdown<String>(
                                  label: 'البائعين',
                                  value: state.selectedSalespersonId,
                                  allowClear: true,
                                  hint: 'كل البائعين',
                                  items: state.salespeople
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => cubit.updateEntityFilters(
                                    salespersonId: v,
                                    clearSalesperson: v == null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsDropdown<String>(
                                  label: 'متابعين - محصلين',
                                  value: state.selectedFollowerName,
                                  allowClear: true,
                                  hint: 'الكل',
                                  items: state.followers
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f.name,
                                          child: Text(f.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => cubit.updateEntityFilters(
                                    followerName: v,
                                    clearFollower: v == null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsDropdown<String>(
                                  label: 'الإجراءات القانونية',
                                  value: state.selectedLegalAction,
                                  allowClear: true,
                                  hint: 'الكل',
                                  items: state.legalActions
                                      .map(
                                        (l) => DropdownMenuItem(
                                          value: l,
                                          child: Text(l),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => cubit.updateEntityFilters(
                                    legalAction: v,
                                    clearLegalAction: v == null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsDropdown<String>(
                                  label: 'الأولوية',
                                  value: state.selectedPriority,
                                  allowClear: true,
                                  hint: 'الكل',
                                  items: state.priorities
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(p),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => cubit.updateEntityFilters(
                                    priority: v,
                                    clearPriority: v == null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Row 3: Quick Filter Toggles (الفواتير | الدفعات | التحصيلات | المتابعات | دفعات لم تحصل او حصلت جزئياً | ضمن ت الدفعة...)
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (final cat in const [
                                'الفواتير',
                                'الدفعات',
                                'التحصيلات',
                                'المتابعات',
                              ])
                                ChoiceChip(
                                  label: Text(cat),
                                  selected: state.activeCategory == cat,
                                  onSelected: (_) => cubit.selectCategory(cat),
                                ),
                              const SizedBox(width: AppSpacing.xs),
                              FilterChip(
                                label: const Text(
                                  'دفعات لم تحصل أو حصلت جزئياً',
                                ),
                                selected: state.onlyUncollectedOrPartial,
                                onSelected: cubit.toggleOnlyUncollected,
                              ),
                              for (final mode in const [
                                'ضمن ت الدفعة',
                                'ضمن ت المتابعة',
                                'ليست ضمن ت المتابعة',
                              ])
                                ChoiceChip(
                                  label: Text(mode),
                                  selected: state.dateInclusionMode == mode,
                                  onSelected: (_) =>
                                      cubit.setDateInclusionMode(mode),
                                ),
                              DsButton(
                                label: 'متأخرات عملاء لبائع',
                                isCompact: true,
                                variant: DsButtonVariant.danger,
                                onPressed: () => cubit.triggerSalespersonShortcut(
                                  overdueOnly: true,
                                ),
                              ),
                              DsButton(
                                label: 'دفعات آجلة لبائع',
                                isCompact: true,
                                variant: DsButtonVariant.info,
                                onPressed: () => cubit.triggerSalespersonShortcut(
                                  overdueOnly: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Left Column (in RTL): Numbered Preset Reports List (51 - كل المتابعات, etc.)
                    SizedBox(
                      width: 270,
                      height: 175,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.tableHeaderBg,
                          borderRadius: AppRadius.brSm,
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: ListView.separated(
                          itemCount: ReportsState.presetReports.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                          itemBuilder: (context, index) {
                            final item = ReportsState.presetReports[index];
                            final isSelected =
                                item.code == state.selectedPresetCode;
                            return Material(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () => cubit.selectPresetReport(item),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${item.code}',
                                        style: AppTypography.tabularNumber
                                            .copyWith(
                                          color: AppColors.warningBorder,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 3. Selected Report Title Banner & Financial Totals Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.brSm,
                  border: Border.all(color: AppColors.danger, width: 1.4),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'عنوان التقرير الذي تم اختياره: ',
                          style: AppTypography.label,
                        ),
                        Text(
                          state.selectedReportTitle,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: 4,
                      children: [
                        Text(
                          'الإجمالي: ${AppFormatters.formatAmount(state.summaryTotalAmount)}',
                          style: AppTypography.tabularNumber,
                        ),
                        Text(
                          'المحصل: ${AppFormatters.formatAmount(state.summaryTotalCollected)}',
                          style: AppTypography.tabularNumber.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'المتبقي للمتابعة: ${AppFormatters.formatAmount(state.summaryTotalRemaining)}',
                          style: AppTypography.tabularNumber.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // 4. Report Output Grid
              Expanded(
                child: DsDataGrid<List<String>>(
                  items: state.reportRows,
                  emptyMessage: 'لا توجد سجلات مطابقة لشروط التقرير المحددة',
                  columns: [
                    for (int colIdx = 0;
                        colIdx < state.reportColumns.length;
                        colIdx++)
                      DsColumn<List<String>>(
                        title: state.reportColumns[colIdx],
                        flex: colIdx == 1 || colIdx == 2 || colIdx == 12 ? 3 : 2,
                        cellBuilder: (row) => Text(
                          colIdx < row.length ? row[colIdx] : '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
