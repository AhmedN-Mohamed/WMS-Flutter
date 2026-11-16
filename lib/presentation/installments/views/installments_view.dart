import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/installment_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../invoices/cubit/invoices_cubit.dart';
import '../cubit/installments_cubit.dart';
import '../cubit/installments_state.dart';
import 'collection_modal.dart';

class InstallmentsView extends StatefulWidget {
  const InstallmentsView({super.key});

  @override
  State<InstallmentsView> createState() => _InstallmentsViewState();
}

class _InstallmentsViewState extends State<InstallmentsView> {
  final _amountCtrl = TextEditingController(text: '0');
  final _descCtrl = TextEditingController();
  final _followUpNotesCtrl = TextEditingController();

  DateTime _dueDate = DateTime.now();
  DateTime _followUpDate = DateTime.now();
  String? _selectedPaymentSystem;
  String? _selectedPriority;
  String? _selectedFollower;
  String? _selectedLegalAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<InstallmentsCubit>().state;
      _populateInstallment(state.selectedInstallment, state);
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _followUpNotesCtrl.dispose();
    super.dispose();
  }

  void _populateInstallment(
    InstallmentEntity? inst,
    InstallmentsState state,
  ) {
    if (inst == null) {
      final unscheduled = state.unscheduledInvoiceAmount;
      _amountCtrl.text = unscheduled > 0 ? unscheduled.toStringAsFixed(0) : '0';
      _descCtrl.clear();
      _followUpNotesCtrl.text = state.copiedFollowUpNote ?? '';
      setState(() {
        _dueDate = DateTime.now();
        _followUpDate = DateTime.now();
        _selectedPaymentSystem = state.paymentSystems.firstOrNull;
        _selectedPriority = state.priorities.firstOrNull ?? 'بدون';
        _selectedFollower =
            state.followersAndCollectors.firstOrNull?.name ?? 'مسئول البيع';
        _selectedLegalAction = state.legalActions.firstOrNull ?? 'بدون';
      });
    } else {
      _amountCtrl.text = inst.amount.toStringAsFixed(0);
      _descCtrl.text = inst.description;
      _followUpNotesCtrl.text = inst.followUpNotes;
      setState(() {
        _dueDate = inst.dueDate;
        _followUpDate = inst.followUpDate;
        _selectedPaymentSystem = inst.paymentSystem;
        _selectedPriority = inst.priority;
        _selectedFollower = inst.followerName;
        _selectedLegalAction = inst.legalAction;
      });
    }
  }

  void _openCollectionModal(InstallmentEntity inst) {
    showDialog(
      context: context,
      builder: (_) => CollectionModal(installmentId: inst.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InstallmentsCubit, InstallmentsState>(
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
        final cubit = context.read<InstallmentsCubit>();
        final inv = state.selectedInvoice;
        final selectedInst = state.selectedInstallment;

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              // 1. Top Screen Header & Action Bar (matching دفعات للتحصيل والمتابعة)
              DsScreenHeader(
                title: 'دفعات للتحصيل والمتابعة',
                subtitle:
                    'جدولة دفعات الفاتورة وتحديد مواعيد الاستحقاق والمتابعة وتسجيل التحصيلات الفعلية لكل دفعة',
                icon: Icons.event_repeat_rounded,
                totalCount: state.invoiceInstallments.length,
                countLabel: 'دفعة للفاتورة',
                actions: [
                  DsButton(
                    label: 'إضافة الدفعة (جديد)',
                    icon: Icons.add_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectInstallment(null);
                      _populateInstallment(null, state);
                    },
                  ),
                  DsButton(
                    label: 'حفظ إضافة الدفعة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: inv == null
                        ? null
                        : () async {
                            await cubit.saveInstallment(
                              amount:
                                  double.tryParse(_amountCtrl.text.trim()) ??
                                      0.0,
                              dueDate: _dueDate,
                              followUpDate: _followUpDate,
                              paymentSystem: _selectedPaymentSystem ??
                                  (state.paymentSystems.firstOrNull ?? 'آجل'),
                              priority: _selectedPriority ?? 'بدون',
                              followerName: _selectedFollower ?? 'مسئول البيع',
                              legalAction: _selectedLegalAction ?? 'بدون',
                              description: _descCtrl.text,
                              followUpNotes: _followUpNotesCtrl.text,
                            );
                            if (context.mounted) {
                              context.read<InvoicesCubit>().loadInvoices();
                            }
                          },
                  ),
                  DsButton(
                    label: 'حفظ تعديل الدفعة',
                    icon: Icons.save_outlined,
                    variant: DsButtonVariant.info,
                    onPressed: selectedInst == null
                        ? null
                        : () async {
                            await cubit.saveInstallment(
                              id: selectedInst.id,
                              amount:
                                  double.tryParse(_amountCtrl.text.trim()) ??
                                      selectedInst.amount,
                              dueDate: _dueDate,
                              followUpDate: _followUpDate,
                              paymentSystem: _selectedPaymentSystem ??
                                  selectedInst.paymentSystem,
                              priority:
                                  _selectedPriority ?? selectedInst.priority,
                              followerName: _selectedFollower ??
                                  selectedInst.followerName,
                              legalAction: _selectedLegalAction ??
                                  selectedInst.legalAction,
                              description: _descCtrl.text,
                              followUpNotes: _followUpNotesCtrl.text,
                            );
                            if (context.mounted) {
                              context.read<InvoicesCubit>().loadInvoices();
                            }
                          },
                  ),
                  DsButton(
                    label: 'حذف الدفعة',
                    icon: Icons.delete_outline_rounded,
                    variant: DsButtonVariant.danger,
                    onPressed: selectedInst == null
                        ? null
                        : () async {
                            await cubit.deleteSelectedInstallment();
                            if (context.mounted) {
                              context.read<InvoicesCubit>().loadInvoices();
                            }
                          },
                  ),
                  DsButton(
                    label: 'نسخ المتابعة',
                    icon: Icons.copy_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed:
                        selectedInst == null ? null : cubit.copyFollowUpNote,
                  ),
                  DsButton(
                    label: 'تحصيل من دفعة',
                    icon: Icons.payments_rounded,
                    variant: DsButtonVariant.warning,
                    onPressed: selectedInst == null
                        ? null
                        : () => _openCollectionModal(selectedInst),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // 2. Upper Split Workspace:
              //    Right Side (in RTL): Company & Invoice Selector
              //    Left Side (in RTL): Selected Invoice Summary + Installment Form
              Expanded(
                flex: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Right Panel: Companies & Invoices of Selected Company
                    Expanded(
                      flex: 4,
                      child: DsCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DsSearchField(
                                    hint: 'البحث في الشركات...',
                                    value: state.companySearchQuery,
                                    onChanged: (v) => cubit.updateSearchQueries(
                                      companyQuery: v,
                                    ),
                                    onClear: () => cubit.updateSearchQueries(
                                      companyQuery: '',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: DsSearchField(
                                    hint: 'البحث عن فواتير عملاء لشركة...',
                                    value: state.customerInvoiceSearchQuery,
                                    onChanged: (v) => cubit.updateSearchQueries(
                                      invoiceQuery: v,
                                    ),
                                    onClear: () => cubit.updateSearchQueries(
                                      invoiceQuery: '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            // Companies Selector Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: ChoiceChip(
                                      label: const Text('كل الشركات'),
                                      selected: state.selectedCompanyId == null,
                                      onSelected: (_) =>
                                          cubit.selectCompany(null),
                                    ),
                                  ),
                                  for (final CompanyEntity c
                                      in state.filteredCompanies)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: ChoiceChip(
                                        label: Text(c.name),
                                        selected:
                                            state.selectedCompanyId == c.id,
                                        onSelected: (_) =>
                                            cubit.selectCompany(c.id),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'فواتير تخص الشركة المحددة',
                                  style: AppTypography.label,
                                ),
                                DsCountBadge(
                                  count: state.companyInvoices.length,
                                  label: 'فاتورة',
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Expanded(
                              child: DsDataGrid<InvoiceEntity>(
                                items: state.companyInvoices,
                                selectedItem: state.selectedInvoice,
                                isEqual: (a, b) => a.id == b.id,
                                onRowTap: (invoice) {
                                  cubit.selectInvoice(invoice);
                                  final firstInst = state.allInstallments
                                      .where((i) => i.invoiceId == invoice.id)
                                      .firstOrNull;
                                  _populateInstallment(firstInst, state);
                                },
                                columns: [
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
                                    title: 'ر الفاتورة',
                                    flex: 2,
                                    cellBuilder: (i) => Text(
                                      i.invoiceNumber,
                                      style: AppTypography.tabularNumber,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Left Panel: Selected Invoice Summary + Add/Edit Installment Form
                    Expanded(
                      flex: 6,
                      child: DsCard(
                        backgroundColor: AppColors.surfaceHighlight,
                        borderColor: AppColors.warningBorder,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: inv == null
                            ? const Center(
                                child: Text('اختر فاتورة من القائمة لعرض أو إضافة دفعاتها'),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Invoice Read-Only Summary Bar
                                    Container(
                                      padding:
                                          const EdgeInsets.all(AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: AppRadius.brSm,
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: _SummaryStat(
                                              label: 'ر الفاتورة',
                                              value: inv.invoiceNumber,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _SummaryStat(
                                              label: 'ت الفاتورة',
                                              value: AppFormatters.formatDate(
                                                inv.invoiceDate,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: _SummaryStat(
                                              label: 'العميل',
                                              value: inv.customerName,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _SummaryStat(
                                              label: 'البائع',
                                              value: inv.salespersonName,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _SummaryStat(
                                              label: 'قيمة الفاتورة',
                                              value: AppFormatters.formatAmount(
                                                inv.totalAmount,
                                              ),
                                              valueColor: AppColors.danger,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _SummaryStat(
                                              label: 'قيمة بدون دفعة',
                                              value: AppFormatters.formatAmount(
                                                state.unscheduledInvoiceAmount,
                                              ),
                                              valueColor: AppColors.info,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),

                                    // Installment Scheduling Fields (اضافة الدفعة)
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: DsTextField(
                                            label: 'قيمة الدفعة',
                                            controller: _amountCtrl,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          flex: 2,
                                          child: DsDatePickerField(
                                            label: 'ت الدفعة (الاستحقاق)',
                                            date: _dueDate,
                                            onDateSelected: (d) =>
                                                setState(() => _dueDate = d),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          flex: 2,
                                          child: DsDatePickerField(
                                            label: 'ت المتابعة',
                                            date: _followUpDate,
                                            onDateSelected: (d) => setState(
                                              () => _followUpDate = d,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          flex: 2,
                                          child: DsDropdown<String>(
                                            label: 'نظام السداد',
                                            value: _selectedPaymentSystem ??
                                                state.paymentSystems.firstOrNull,
                                            items: state.paymentSystems
                                                .map(
                                                  (s) => DropdownMenuItem(
                                                    value: s,
                                                    child: Text(s),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (v) => setState(
                                              () => _selectedPaymentSystem = v,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: DsDropdown<String>(
                                            label: 'المتابع',
                                            value: _selectedFollower ??
                                                state.followersAndCollectors
                                                    .firstOrNull?.name,
                                            items: state.followersAndCollectors
                                                .map(
                                                  (f) => DropdownMenuItem(
                                                    value: f.name,
                                                    child: Text(f.name),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (v) => setState(
                                              () => _selectedFollower = v,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          flex: 2,
                                          child: DsDropdown<String>(
                                            label: 'الأولوية',
                                            value: _selectedPriority ??
                                                state.priorities.firstOrNull,
                                            items: state.priorities
                                                .map(
                                                  (p) => DropdownMenuItem(
                                                    value: p,
                                                    child: Text(p),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (v) => setState(
                                              () => _selectedPriority = v,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          flex: 2,
                                          child: DsDropdown<String>(
                                            label: 'الإجراء القانوني',
                                            value: _selectedLegalAction ??
                                                state.legalActions.firstOrNull,
                                            items: state.legalActions
                                                .map(
                                                  (l) => DropdownMenuItem(
                                                    value: l,
                                                    child: Text(l),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (v) => setState(
                                              () => _selectedLegalAction = v,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          flex: 2,
                                          child: _SummaryStat(
                                            label: 'المسدد منها / الباقي للمتابعة',
                                            value: selectedInst == null
                                                ? '0.0 / 0.0'
                                                : '${AppFormatters.formatAmount(selectedInst.collectedAmount)} / ${AppFormatters.formatAmount(selectedInst.remainingAmount)}',
                                            valueColor: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DsTextField(
                                            label: 'بيان الدفعة',
                                            controller: _descCtrl,
                                            hint: 'تفاصيل أو شروط الدفعة...',
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: DsTextField(
                                            label: 'متابعة الدفعة',
                                            controller: _followUpNotesCtrl,
                                            hint:
                                                'سجل ما تم في الاتصال أو المتابعة مع العميل...',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 3. Installments Totals Bar (اجماليات دفعات الفاتورة)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sidebarBg,
                  borderRadius: AppRadius.brSm,
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  runSpacing: 4,
                  children: [
                    Text(
                      'عرض موقف دفعات للفاتورة المحددة (${inv?.invoiceNumber ?? '-'})',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: 4,
                      children: [
                        Text(
                          'إجمالي الدفعات المجدولة: ${AppFormatters.formatAmount(state.totalScheduledForInvoice)}',
                          style: AppTypography.tabularNumber
                              .copyWith(color: AppColors.secondaryLight),
                        ),
                        Text(
                          'إجمالي القيمة المحصلة: ${AppFormatters.formatAmount(state.totalCollectedForInvoice)}',
                          style: AppTypography.tabularNumber
                              .copyWith(color: AppColors.successBorder),
                        ),
                        Text(
                          'إجمالي الباقي للمتابعة: ${AppFormatters.formatAmount(state.totalRemainingForInvoice)}',
                          style: AppTypography.tabularNumber
                              .copyWith(color: AppColors.dangerBorder),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // 4. Bottom Installments Grid (double-click or click button to open تحصيل من دفعة)
              Expanded(
                flex: 5,
                child: DsDataGrid<InstallmentEntity>(
                  items: state.invoiceInstallments,
                  selectedItem: state.selectedInstallment,
                  isEqual: (a, b) => a.id == b.id,
                  emptyMessage:
                      'لا توجد دفعات مسجلة لهذه الفاتورة بعد - استخدم نموذج الإضافة بالأعلى',
                  onRowTap: (inst) {
                    cubit.selectInstallment(inst);
                    _populateInstallment(inst, state);
                  },
                  onRowDoubleTap: _openCollectionModal,
                  columns: [
                    DsColumn(
                      title: 'قيمة الدفعة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatAmount(i.amount),
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'ت الدفعة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatDate(i.dueDate),
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'القيمة المحصلة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatAmount(i.collectedAmount),
                        style: AppTypography.tabularNumber
                            .copyWith(color: AppColors.success),
                      ),
                    ),
                    DsColumn(
                      title: 'الباقي للمتابعة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatAmount(i.remainingAmount),
                        style: AppTypography.tabularNumber.copyWith(
                          color: i.isFullyPaid
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ),
                    DsColumn(
                      title: 'نظام السداد',
                      flex: 2,
                      cellBuilder: (i) => Text(i.paymentSystem),
                    ),
                    DsColumn(
                      title: 'المتابع / ت المتابعة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        '${i.followerName} (${AppFormatters.formatDate(i.followUpDate)})',
                      ),
                    ),
                    DsColumn(
                      title: 'الأولوية',
                      flex: 2,
                      cellBuilder: (i) => DsStatusBadge(
                        label: i.priority,
                        type: i.priority == 'عاجل جداً'
                            ? DsBadgeType.danger
                            : (i.priority == 'مشروعات'
                                ? DsBadgeType.info
                                : DsBadgeType.neutral),
                      ),
                    ),
                    DsColumn(
                      title: 'بيان ومتابعة الدفعة',
                      flex: 3,
                      cellBuilder: (i) => Text(
                        i.followUpNotes.isNotEmpty
                            ? i.followUpNotes
                            : i.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DsColumn(
                      title: 'تحصيل من دفعة',
                      flex: 2,
                      alignment: Alignment.center,
                      cellBuilder: (i) => DsButton(
                        label: 'تحصيل (${i.isFullyPaid ? "مكتمل" : "سداد"})',
                        isCompact: true,
                        icon: Icons.payments_outlined,
                        variant: i.isFullyPaid
                            ? DsButtonVariant.secondary
                            : DsButtonVariant.warning,
                        onPressed: () => _openCollectionModal(i),
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

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
