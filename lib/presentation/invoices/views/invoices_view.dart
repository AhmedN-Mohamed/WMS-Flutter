import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/staff_entity.dart';
import '../../installments/cubit/installments_cubit.dart';
import '../../shell/cubit/app_shell_cubit.dart';
import '../../shell/cubit/app_shell_state.dart';
import '../cubit/invoices_cubit.dart';
import '../cubit/invoices_state.dart';
import 'invoice_dialogs.dart';

class InvoicesView extends StatefulWidget {
  const InvoicesView({super.key});

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  final _invNumberCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '0.0');
  final _mobile1Ctrl = TextEditingController();
  final _mobile2Ctrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _customerNotesCtrl = TextEditingController();

  DateTime _invoiceDate = DateTime.now();
  String? _selectedCompanyId;
  String? _selectedCustomerId;
  String? _selectedSalespersonId;
  String? _selectedCurrency;
  List<InvoiceItemEntity> _draftItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selected = context.read<InvoicesCubit>().state.selectedInvoice;
      if (selected != null) {
        _populate(selected);
      }
    });
  }

  @override
  void dispose() {
    _invNumberCtrl.dispose();
    _amountCtrl.dispose();
    _mobile1Ctrl.dispose();
    _mobile2Ctrl.dispose();
    _notesCtrl.dispose();
    _customerNotesCtrl.dispose();
    super.dispose();
  }

  void _populate(InvoiceEntity? inv) {
    if (inv == null) {
      _invNumberCtrl.clear();
      _amountCtrl.text = '0.0';
      _mobile1Ctrl.clear();
      _mobile2Ctrl.clear();
      _notesCtrl.clear();
      _customerNotesCtrl.clear();
      setState(() {
        _invoiceDate = DateTime.now();
        _draftItems = [];
      });
    } else {
      _invNumberCtrl.text = inv.invoiceNumber;
      _amountCtrl.text = inv.totalAmount.toStringAsFixed(1);
      _mobile1Ctrl.text = inv.customerMobile1;
      _mobile2Ctrl.text = inv.customerMobile2;
      _notesCtrl.text = inv.notes;
      _customerNotesCtrl.text = inv.customerNotes;
      setState(() {
        _invoiceDate = inv.invoiceDate;
        _selectedCompanyId = inv.companyId;
        _selectedCustomerId = inv.customerId;
        _selectedSalespersonId = inv.salespersonId;
        _selectedCurrency = inv.currency;
        _draftItems = List<InvoiceItemEntity>.from(inv.items);
      });
    }
  }

  void _openInstallmentsForInvoice(InvoiceEntity invoice) {
    context.read<InstallmentsCubit>().loadData(focusInvoiceId: invoice.id);
    context
        .read<AppShellCubit>()
        .selectTab(AppNavTab.installments, invoiceId: invoice.id);
  }

  Future<void> _exportExcel(InvoicesState state) async {
    final path = await ExportService.exportToCsv(
      fileNamePrefix: 'فواتير_الشركات',
      headers: [
        'الشركة',
        'اسم العميل',
        'موبايل 1',
        'موبايل 2',
        'البائع',
        'ر الفاتورة',
        'ت الفاتورة',
        'قيمة الفاتورة',
        'المسدد',
        'المتبقي',
        'العملة',
        'ملاحظات',
      ],
      rows: state.filteredInvoices
          .map(
            (i) => [
              i.companyName,
              i.customerName,
              i.customerMobile1,
              i.customerMobile2,
              i.salespersonName,
              i.invoiceNumber,
              AppFormatters.formatDate(i.invoiceDate),
              i.totalAmount.toStringAsFixed(1),
              state.collectedAmountForInvoice(i.id).toStringAsFixed(1),
              state.remainingDebtForInvoice(i).toStringAsFixed(1),
              i.currency,
              i.notes,
            ],
          )
          .toList(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تصدير الفواتير إلى ملف إكسيل: $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoicesCubit, InvoicesState>(
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
        final cubit = context.read<InvoicesCubit>();
        final selected = state.selectedInvoice;

        CompanyEntity? resolvedCompany() {
          final id = _selectedCompanyId ?? state.companies.firstOrNull?.id;
          return state.companies.where((c) => c.id == id).firstOrNull;
        }

        CustomerEntity? resolvedCustomer() {
          final id = _selectedCustomerId ?? state.customers.firstOrNull?.id;
          return state.customers.where((c) => c.id == id).firstOrNull;
        }

        StaffEntity? resolvedSalesperson() {
          final id =
              _selectedSalespersonId ?? state.salespeople.firstOrNull?.id;
          return state.salespeople.where((s) => s.id == id).firstOrNull;
        }

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              // 1. Top Header & Action Bar (matching فواتير الشركات buttons)
              DsScreenHeader(
                title: 'فواتير الشركات',
                subtitle:
                    'تسجيل الفواتير الجديدة ومتابعة موقف سداد العملاء والدخول المباشر لجدولة الدفعات والتحصيل',
                icon: Icons.receipt_long_rounded,
                totalCount: state.filteredInvoices.length,
                countLabel: 'فاتورة',
                actions: [
                  DsButton(
                    label: 'إضافة',
                    icon: Icons.add_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectInvoice(null);
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ الإضافة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      final comp = resolvedCompany();
                      final cust = resolvedCustomer();
                      final sales = resolvedSalesperson();
                      if (comp == null || cust == null || sales == null) return;
                      if (_invNumberCtrl.text.trim().isEmpty) return;
                      cubit.saveInvoice(
                        invoiceNumber: _invNumberCtrl.text,
                        invoiceDate: _invoiceDate,
                        company: comp,
                        customer: cust,
                        salesperson: sales,
                        totalAmount:
                            double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
                        currency: _selectedCurrency ??
                            (state.currencies.firstOrNull ?? 'جنيه مصرى'),
                        notes: _notesCtrl.text,
                        customerNotes: _customerNotesCtrl.text,
                        items: _draftItems,
                      );
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
                            final cust = resolvedCustomer();
                            final sales = resolvedSalesperson();
                            if (comp == null || cust == null || sales == null) {
                              return;
                            }
                            cubit.saveInvoice(
                              id: selected.id,
                              invoiceNumber: _invNumberCtrl.text,
                              invoiceDate: _invoiceDate,
                              company: comp,
                              customer: cust,
                              salesperson: sales,
                              totalAmount:
                                  double.tryParse(_amountCtrl.text.trim()) ??
                                      0.0,
                              currency: _selectedCurrency ?? selected.currency,
                              notes: _notesCtrl.text,
                              customerNotes: _customerNotesCtrl.text,
                              items: _draftItems,
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
                            cubit.deleteSelectedInvoice();
                            _populate(null);
                          },
                  ),
                  DsButton(
                    label: 'إضافة المنتجات للفاتورة (${_draftItems.length})',
                    icon: Icons.inventory_2_outlined,
                    variant: DsButtonVariant.info,
                    onPressed: () async {
                      final result = await showDialog<List<InvoiceItemEntity>>(
                        context: context,
                        builder: (_) => InvoiceItemsModal(
                          products: state.products,
                          initialItems: _draftItems,
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _draftItems = result;
                          final sum = result.fold<double>(
                            0.0,
                            (s, e) => s + e.lineTotal,
                          );
                          if (sum > 0) {
                            _amountCtrl.text = sum.toStringAsFixed(1);
                          }
                        });
                      }
                    },
                  ),
                  DsButton(
                    label: 'موقف فواتير عميل',
                    icon: Icons.person_search_rounded,
                    variant: DsButtonVariant.info,
                    onPressed: () {
                      final cust = resolvedCustomer();
                      if (cust == null) return;
                      showDialog(
                        context: context,
                        builder: (_) => CustomerStatementModal(
                          customerId: cust.id,
                          customerName: cust.name,
                          state: state,
                          onOpenInvoiceInstallments: _openInstallmentsForInvoice,
                        ),
                      );
                    },
                  ),
                  DsButton(
                    label: state.onlyWithoutInstallments
                        ? 'عرض كل الفواتير'
                        : 'فواتير بدون دفعات',
                    icon: Icons.filter_alt_outlined,
                    variant: state.onlyWithoutInstallments
                        ? DsButtonVariant.warning
                        : DsButtonVariant.secondary,
                    onPressed: () => cubit.updateFilters(
                      onlyWithoutInstallments: !state.onlyWithoutInstallments,
                    ),
                  ),
                  DsButton(
                    label: 'مديونية قطاع',
                    icon: Icons.analytics_outlined,
                    variant: DsButtonVariant.danger,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => SectorDebtModal(state: state),
                      );
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
              const SizedBox(height: AppSpacing.sm),

              // 2. Invoice Entry & Edit Form Panel (matching Screenshot 9 layout)
              DsCard(
                backgroundColor: AppColors.surfaceHighlight,
                borderColor: AppColors.warningBorder,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Right & Center Form Columns
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DsDropdown<String>(
                                  label: 'الشركة',
                                  value: _selectedCompanyId ??
                                      state.companies.firstOrNull?.id,
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
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 3,
                                child: DsDropdown<String>(
                                  label: 'العميل',
                                  value: _selectedCustomerId ??
                                      state.customers.firstOrNull?.id,
                                  items: state.customers
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() => _selectedCustomerId = v);
                                    final cust = state.customers
                                        .where((c) => c.id == v)
                                        .firstOrNull;
                                    if (cust != null) {
                                      _mobile1Ctrl.text = cust.mobile1;
                                      _mobile2Ctrl.text = cust.mobile2;
                                      _customerNotesCtrl.text = cust.notes;
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsTextField(
                                  label: 'رقم الفاتورة',
                                  controller: _invNumberCtrl,
                                  hint: 'مثال: 26-291',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsDatePickerField(
                                  label: 'ت الفاتورة',
                                  date: _invoiceDate,
                                  onDateSelected: (d) =>
                                      setState(() => _invoiceDate = d),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 2,
                                child: DsDropdown<String>(
                                  label: 'البائع',
                                  value: _selectedSalespersonId ??
                                      state.salespeople.firstOrNull?.id,
                                  items: state.salespeople
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(
                                    () => _selectedSalespersonId = v,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsTextField(
                                  label: 'موبايل 1 للعميل',
                                  controller: _mobile1Ctrl,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsTextField(
                                  label: 'موبايل 2 للعميل',
                                  controller: _mobile2Ctrl,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              DsButton(
                                label: 'تحديث-موبايلات',
                                isCompact: true,
                                variant: DsButtonVariant.secondary,
                                onPressed: () {
                                  final cust = resolvedCustomer();
                                  if (cust == null) return;
                                  cubit.updateCustomerMobilesAndNotesFromInvoice(
                                    customerId: cust.id,
                                    mobile1: _mobile1Ctrl.text,
                                    mobile2: _mobile2Ctrl.text,
                                    customerNotes: _customerNotesCtrl.text,
                                  );
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsTextField(
                                  label: 'قيمة الفاتورة',
                                  controller: _amountCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: DsDropdown<String>(
                                  label: 'العملة',
                                  value: _selectedCurrency ??
                                      state.currencies.firstOrNull,
                                  items: state.currencies
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedCurrency = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: DsTextField(
                                  label: 'ملاحظات الفاتورة',
                                  controller: _notesCtrl,
                                  hint: 'بيان وملاحظات الفاتورة...',
                                ),
                              ),
                              if (selected != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                DsButton(
                                  label:
                                      'فتح الدفعات والتحصيلات للفاتورة (${selected.invoiceNumber})',
                                  icon: Icons.payments_rounded,
                                  variant: DsButtonVariant.warning,
                                  onPressed: () =>
                                      _openInstallmentsForInvoice(selected),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Customer Persistent Notes Box (تحديث ملاحظات العميل)
                    SizedBox(
                      width: 240,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DsTextField(
                            label: 'ملاحظات العميل الدائمة',
                            controller: _customerNotesCtrl,
                            maxLines: 4,
                            hint: 'ملاحظات عامة عن العميل...',
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          DsButton(
                            label: 'تحديث ملاحظات العميل',
                            isCompact: true,
                            variant: DsButtonVariant.secondary,
                            onPressed: () {
                              final cust = resolvedCustomer();
                              if (cust == null) return;
                              cubit.updateCustomerMobilesAndNotesFromInvoice(
                                customerId: cust.id,
                                mobile1: _mobile1Ctrl.text,
                                mobile2: _mobile2Ctrl.text,
                                customerNotes: _customerNotesCtrl.text,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 3. Multi-Search Bar (شركة - ملاحظات | عميل | بائع - رقم فاتورة) + Sort Buttons
              DsCard(
                padding: AppSpacing.compactCardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بـ (شركة - ملاحظات)...',
                        value: state.companyOrNotesSearch,
                        onChanged: (v) =>
                            cubit.updateFilters(companyOrNotes: v),
                        onClear: () => cubit.updateFilters(companyOrNotes: ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بـ (عميل / موبايل)...',
                        value: state.customerSearch,
                        onChanged: (v) => cubit.updateFilters(customer: v),
                        onClear: () => cubit.updateFilters(customer: ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بـ (بائع - رقم فاتورة)...',
                        value: state.salespersonOrNumberSearch,
                        onChanged: (v) =>
                            cubit.updateFilters(salespersonOrNumber: v),
                        onClear: () =>
                            cubit.updateFilters(salespersonOrNumber: ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    DsButton(
                      label: state.sortAscending ? 'ترتيب تصاعدي ⬆️' : 'ترتيب تنازلي ⬇️',
                      isCompact: true,
                      variant: DsButtonVariant.secondary,
                      onPressed: () => cubit.toggleSort(state.sortColumn),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 4. Invoices Data Grid (double-click to open Installments & Collections!)
              Expanded(
                child: DsDataGrid<InvoiceEntity>(
                  items: state.filteredInvoices,
                  selectedItem: state.selectedInvoice,
                  isEqual: (a, b) => a.id == b.id,
                  onRowTap: (item) {
                    cubit.selectInvoice(item);
                    _populate(item);
                  },
                  onRowDoubleTap: _openInstallmentsForInvoice,
                  columns: [
                    DsColumn(
                      title: 'الشركة',
                      flex: 3,
                      cellBuilder: (i) => Text(
                        i.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DsColumn(
                      title: 'اسم العميل',
                      flex: 3,
                      cellBuilder: (i) => Text(
                        i.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DsColumn(
                      title: 'موبايل 1',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        i.customerMobile1.isEmpty ? '-' : i.customerMobile1,
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'البائع',
                      flex: 2,
                      cellBuilder: (i) => Text(i.salespersonName),
                    ),
                    DsColumn(
                      title: 'ر الفاتورة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        i.invoiceNumber,
                        style: AppTypography.tabularNumber.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    DsColumn(
                      title: 'ت الفاتورة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatDate(i.invoiceDate),
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'قيمة الفاتورة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatAmount(i.totalAmount),
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'المتبقي للتحصيل',
                      flex: 2,
                      cellBuilder: (i) {
                        final rem = state.remainingDebtForInvoice(i);
                        return DsStatusBadge(
                          label: rem <= 0.01
                              ? 'مسددة بالكامل'
                              : AppFormatters.formatAmount(rem),
                          type: rem <= 0.01
                              ? DsBadgeType.success
                              : (rem < i.totalAmount
                                  ? DsBadgeType.warning
                                  : DsBadgeType.danger),
                        );
                      },
                    ),
                    DsColumn(
                      title: 'الدفعات / التحصيل',
                      flex: 2,
                      alignment: Alignment.center,
                      cellBuilder: (i) => DsButton(
                        label: 'الدفعات والتحصيل',
                        isCompact: true,
                        icon: Icons.open_in_new_rounded,
                        variant: DsButtonVariant.info,
                        onPressed: () => _openInstallmentsForInvoice(i),
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
