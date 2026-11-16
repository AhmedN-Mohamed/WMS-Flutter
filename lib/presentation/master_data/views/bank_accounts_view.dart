import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../domain/entities/company_entity.dart';
import '../cubit/master_data_cubit.dart';
import '../cubit/master_data_state.dart';

class BankAccountsView extends StatefulWidget {
  const BankAccountsView({super.key});

  @override
  State<BankAccountsView> createState() => _BankAccountsViewState();
}

class _BankAccountsViewState extends State<BankAccountsView> {
  final _accountCtrl = TextEditingController();
  String? _selectedCompanyId;
  String? _selectedBank;
  String? _selectedCurrency;

  @override
  void dispose() {
    _accountCtrl.dispose();
    super.dispose();
  }

  void _populate(CompanyBankAccountEntity? item) {
    if (item == null) {
      _accountCtrl.clear();
      setState(() {
        _selectedCompanyId = null;
        _selectedBank = null;
        _selectedCurrency = null;
      });
    } else {
      _accountCtrl.text = item.accountNumber;
      setState(() {
        _selectedCompanyId = item.companyId;
        _selectedBank = item.bankName;
        _selectedCurrency = item.currency;
      });
    }
  }

  Future<void> _exportExcel(MasterDataState state) async {
    final path = await ExportService.exportToCsv(
      fileNamePrefix: 'الحسابات_البنكية_للشركات',
      headers: ['رقم الحساب', 'اسم الشركة', 'اسم البنك', 'العملة'],
      rows: state.filteredBankAccounts
          .map((b) => [b.accountNumber, b.companyName, b.bankName, b.currency])
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
        final selected = state.selectedBankAccount;

        CompanyEntity? resolvedCompany() {
          final id = _selectedCompanyId ?? state.companies.firstOrNull?.id;
          return state.companies.where((c) => c.id == id).firstOrNull;
        }

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              DsScreenHeader(
                title: 'الحسابات البنكية للشركات',
                subtitle:
                    'ربط كل شركة فرعية بحساباتها البنكية وعملاتها لتسجيل الإيداعات والتحويلات',
                icon: Icons.account_balance_rounded,
                totalCount: state.filteredBankAccounts.length,
                countLabel: 'حساب بنكي',
                actions: [
                  DsButton(
                    label: 'إضافة',
                    icon: Icons.add_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectBankAccount(null);
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ الإضافة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      final comp = resolvedCompany();
                      if (comp == null) return;
                      cubit.saveBankAccount(
                        accountNumber: _accountCtrl.text,
                        company: comp,
                        bankName:
                            _selectedBank ?? (state.banks.firstOrNull ?? 'بنك مصر'),
                        currency: _selectedCurrency ??
                            (state.currencies.firstOrNull ?? 'جنيه مصرى'),
                      );
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ التعديل',
                    icon: Icons.save_outlined,
                    variant: DsButtonVariant.info,
                    onPressed: selected == null
                        ? null
                        : () {
                            final comp = resolvedCompany();
                            if (comp == null) return;
                            cubit.saveBankAccount(
                              id: selected.id,
                              accountNumber: _accountCtrl.text,
                              company: comp,
                              bankName: _selectedBank ?? selected.bankName,
                              currency: _selectedCurrency ?? selected.currency,
                            );
                          },
                  ),
                  DsButton(
                    label: 'حذف',
                    icon: Icons.delete_outline_rounded,
                    variant: DsButtonVariant.danger,
                    onPressed: selected == null
                        ? null
                        : () {
                            cubit.deleteSelectedBankAccount();
                            _populate(null);
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
              DsCard(
                backgroundColor: AppColors.surfaceHighlight,
                borderColor: AppColors.warningBorder,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DsTextField(
                        label: 'ر الحساب (رقم الحساب)',
                        controller: _accountCtrl,
                        hint: 'مثال: 155/1/78399',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: DsDropdown<String>(
                        label: 'الشركة',
                        value: _selectedCompanyId ?? state.companies.firstOrNull?.id,
                        items: state.companies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCompanyId = v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: DsDropdown<String>(
                        label: 'البنك',
                        value: _selectedBank ?? state.banks.firstOrNull,
                        items: state.banks
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(b),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedBank = v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: DsDropdown<String>(
                        label: 'العملة',
                        value: _selectedCurrency ?? state.currencies.firstOrNull,
                        items: state.currencies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCurrency = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Dual Search Bar (الحساب - الشركة | البنك - العملة)
              DsCard(
                padding: AppSpacing.compactCardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بـ (الحساب - الشركة)...',
                        value: state.bankAccountSearch,
                        onChanged: (v) =>
                            cubit.updateBankAccountFilters(accountCompany: v),
                        onClear: () =>
                            cubit.updateBankAccountFilters(accountCompany: ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بـ (البنك - العملة)...',
                        value: state.bankNameCurrencySearch,
                        onChanged: (v) =>
                            cubit.updateBankAccountFilters(bankCurrency: v),
                        onClear: () =>
                            cubit.updateBankAccountFilters(bankCurrency: ''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: DsDataGrid<CompanyBankAccountEntity>(
                  items: state.filteredBankAccounts,
                  selectedItem: state.selectedBankAccount,
                  isEqual: (a, b) => a.id == b.id,
                  onRowTap: (item) {
                    cubit.selectBankAccount(item);
                    _populate(item);
                  },
                  columns: [
                    DsColumn(
                      title: 'رقم الحساب',
                      flex: 2,
                      cellBuilder: (item) => Text(
                        item.accountNumber,
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'اسم الشركة',
                      flex: 3,
                      cellBuilder: (item) => Text(item.companyName),
                    ),
                    DsColumn(
                      title: 'اسم البنك',
                      flex: 2,
                      cellBuilder: (item) => Text(item.bankName),
                    ),
                    DsColumn(
                      title: 'العملة',
                      flex: 2,
                      cellBuilder: (item) => DsStatusBadge(
                        label: item.currency,
                        type: DsBadgeType.success,
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
