import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../domain/entities/company_entity.dart';
import '../../shell/cubit/app_shell_cubit.dart';
import '../../shell/cubit/app_shell_state.dart';
import '../cubit/master_data_cubit.dart';
import '../cubit/master_data_state.dart';

class CompaniesView extends StatefulWidget {
  const CompaniesView({super.key});

  @override
  State<CompaniesView> createState() => _CompaniesViewState();
}

class _CompaniesViewState extends State<CompaniesView> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _mobile1Ctrl = TextEditingController();
  final _mobile2Ctrl = TextEditingController();
  String? _selectedActivity;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _mobile1Ctrl.dispose();
    _mobile2Ctrl.dispose();
    super.dispose();
  }

  void _populate(CompanyEntity? company) {
    if (company == null) {
      _codeCtrl.clear();
      _nameCtrl.clear();
      _mobile1Ctrl.clear();
      _mobile2Ctrl.clear();
      setState(() => _selectedActivity = null);
    } else {
      _codeCtrl.text = company.code;
      _nameCtrl.text = company.name;
      _mobile1Ctrl.text = company.mobile1;
      _mobile2Ctrl.text = company.mobile2;
      setState(() => _selectedActivity = company.activity);
    }
  }

  Future<void> _exportExcel(MasterDataState state) async {
    final path = await ExportService.exportToCsv(
      fileNamePrefix: 'بيانات_الشركات',
      headers: ['كود', 'اسم الشركة', 'النشاط', 'موبايل 1', 'موبايل 2'],
      rows: state.filteredCompanies
          .map((c) => [c.code, c.name, c.activity, c.mobile1, c.mobile2])
          .toList(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تصدير ملف الإكسيل: $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterDataCubit, MasterDataState>(
      listenWhen: (prev, curr) =>
          prev.actionMessage != curr.actionMessage &&
          curr.actionMessage != null,
      listener: (context, state) {
        if (state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionMessage!)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<MasterDataCubit>();
        final selectedComp = state.selectedCompany;
        final inlineBanks = selectedComp == null
            ? state.bankAccounts
            : state.bankAccounts
                .where((b) => b.companyId == selectedComp.id)
                .toList();

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              DsScreenHeader(
                title: 'بيانات الشركات',
                subtitle:
                    'إدارة الشركات الفرعية في المجموعة لربط كل فاتورة أو دفعة أو تحصيل بالشركة الخاصة بها',
                icon: Icons.business_rounded,
                totalCount: state.filteredCompanies.length,
                countLabel: 'شركات',
                actions: [
                  DsButton(
                    label: 'إضافة',
                    icon: Icons.add_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectCompany(null);
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ الإضافة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      cubit.saveCompany(
                        code: _codeCtrl.text,
                        name: _nameCtrl.text,
                        activity: _selectedActivity ??
                            (state.activities.firstOrNull ?? ''),
                        mobile1: _mobile1Ctrl.text,
                        mobile2: _mobile2Ctrl.text,
                      );
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ التعديل',
                    icon: Icons.save_outlined,
                    variant: DsButtonVariant.info,
                    onPressed: selectedComp == null
                        ? null
                        : () {
                            cubit.saveCompany(
                              id: selectedComp.id,
                              code: _codeCtrl.text,
                              name: _nameCtrl.text,
                              activity: _selectedActivity ?? selectedComp.activity,
                              mobile1: _mobile1Ctrl.text,
                              mobile2: _mobile2Ctrl.text,
                            );
                          },
                  ),
                  DsButton(
                    label: 'حذف',
                    icon: Icons.delete_outline_rounded,
                    variant: DsButtonVariant.danger,
                    onPressed: selectedComp == null
                        ? null
                        : () {
                            cubit.deleteSelectedCompany();
                            _populate(null);
                          },
                  ),
                  DsButton(
                    label: 'شاشة الحسابات البنكية',
                    icon: Icons.account_balance_rounded,
                    variant: DsButtonVariant.warning,
                    onPressed: () {
                      context
                          .read<AppShellCubit>()
                          .selectTab(AppNavTab.bankAccounts);
                    },
                  ),
                  DsButton(
                    label: 'To_Excel',
                    icon: Icons.table_view_rounded,
                    variant: DsButtonVariant.excel,
                    onPressed: () => _exportExcel(state),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Form Panel
              DsCard(
                backgroundColor: AppColors.surfaceHighlight,
                borderColor: AppColors.warningBorder,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: DsTextField(
                            label: 'كود الشركة',
                            controller: _codeCtrl,
                            hint: '001',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 3,
                          child: DsTextField(
                            label: 'الشركة',
                            controller: _nameCtrl,
                            hint: 'اسم الشركة الفرعية...',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: DsDropdown<String>(
                            label: 'النشاط',
                            value: _selectedActivity,
                            allowClear: true,
                            items: state.activities
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedActivity = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: DsTextField(
                            label: 'موبايل 1',
                            controller: _mobile1Ctrl,
                            hint: '010...',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DsTextField(
                            label: 'موبايل 2',
                            controller: _mobile2Ctrl,
                            hint: '012...',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Inline Bank Accounts Toggle (إظهار / إخفاء الحسابات البنكية للشركة)
                        DsButton(
                          label: state.showInlineCompanyBanks
                              ? 'إخفاء الحسابات البنكية للشركة'
                              : 'إظهار الحسابات البنكية للشركة (${inlineBanks.length})',
                          icon: state.showInlineCompanyBanks
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          variant: DsButtonVariant.secondary,
                          onPressed: () => cubit.toggleInlineCompanyBanks(
                            !state.showInlineCompanyBanks,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Search Filter Bar
              DsCard(
                padding: AppSpacing.compactCardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث باسم الشركة أو الكود...',
                        value: state.companySearch,
                        onChanged: (v) => cubit.updateCompanyFilters(search: v),
                        onClear: () => cubit.updateCompanyFilters(search: ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بالنشاط...',
                        value: state.companyActivityFilter,
                        onChanged: (v) =>
                            cubit.updateCompanyFilters(activity: v),
                        onClear: () =>
                            cubit.updateCompanyFilters(activity: ''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Main Data Grid (+ optional inline bank accounts panel)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DsDataGrid<CompanyEntity>(
                        items: state.filteredCompanies,
                        selectedItem: state.selectedCompany,
                        isEqual: (a, b) => a.id == b.id,
                        onRowTap: (item) {
                          cubit.selectCompany(item);
                          _populate(item);
                        },
                        columns: [
                          DsColumn(
                            title: 'م',
                            flex: 1,
                            cellBuilder: (item) => Text(
                              item.code,
                              style: AppTypography.tabularNumber,
                            ),
                          ),
                          DsColumn(
                            title: 'اسم الشركة',
                            flex: 4,
                            cellBuilder: (item) => Text(item.name),
                          ),
                          DsColumn(
                            title: 'النشاط',
                            flex: 3,
                            cellBuilder: (item) => Text(
                              item.activity.isEmpty ? '-' : item.activity,
                            ),
                          ),
                          DsColumn(
                            title: 'موبايل 1',
                            flex: 2,
                            cellBuilder: (item) => Text(
                              item.mobile1,
                              style: AppTypography.tabularNumber,
                            ),
                          ),
                          DsColumn(
                            title: 'موبايل 2',
                            flex: 2,
                            cellBuilder: (item) => Text(
                              item.mobile2,
                              style: AppTypography.tabularNumber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.showInlineCompanyBanks) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: DsDataGrid<CompanyBankAccountEntity>(
                          items: inlineBanks,
                          emptyMessage: 'لا توجد حسابات بنكية مسجلة لهذه الشركة',
                          columns: [
                            DsColumn(
                              title: 'رقم الحساب',
                              flex: 2,
                              cellBuilder: (b) => Text(
                                b.accountNumber,
                                style: AppTypography.tabularNumber,
                              ),
                            ),
                            DsColumn(
                              title: 'البنك',
                              flex: 2,
                              cellBuilder: (b) => Text(b.bankName),
                            ),
                            DsColumn(
                              title: 'العملة',
                              flex: 1,
                              cellBuilder: (b) => Text(b.currency),
                            ),
                          ],
                        ),
                      ),
                    ],
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
