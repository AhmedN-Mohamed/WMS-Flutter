import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/collection_entity.dart';
import '../../invoices/cubit/invoices_cubit.dart';
import '../cubit/installments_cubit.dart';
import '../cubit/installments_state.dart';

/// Modal matching Screenshot 12: `تحصيل من دفعة`
/// ("هنا بعد ما بدخل على الدفعات بدخل اسجل هو دفع كام")
class CollectionModal extends StatefulWidget {
  final String installmentId;

  const CollectionModal({
    super.key,
    required this.installmentId,
  });

  @override
  State<CollectionModal> createState() => _CollectionModalState();
}

class _CollectionModalState extends State<CollectionModal> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _collectionDate = DateTime.now();
  String? _selectedMethod;
  String? _selectedCollector;

  @override
  void initState() {
    super.initState();
    final state = context.read<InstallmentsCubit>().state;
    final inst = state.allInstallments
        .where((i) => i.id == widget.installmentId)
        .firstOrNull;
    if (inst != null) {
      _amountCtrl.text = inst.remainingAmount.toStringAsFixed(1);
    }
    _selectedMethod = state.paymentMethods.firstOrNull ?? 'نقدي';
    _selectedCollector =
        state.followersAndCollectors.firstOrNull?.name ?? 'مسئول البيع';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstallmentsCubit, InstallmentsState>(
      builder: (context, state) {
        final cubit = context.read<InstallmentsCubit>();
        final inst = state.allInstallments
            .where((i) => i.id == widget.installmentId)
            .firstOrNull;

        if (inst == null) {
          return const SizedBox.shrink();
        }

        final collections = state.allCollections
            .where((c) => c.installmentId == inst.id)
            .toList();

        return DsModal(
          title: 'تحصيل من دفعة (فاتورة رقم ${inst.invoiceNumber})',
          subtitle:
              'تسجيل المبالغ المحصلة فعلياً من العميل خصماً من الدفعة المحددة',
          icon: Icons.payments_rounded,
          width: 900,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Read-Only Context Header (الشركة، العميل، البائع، قيمة الدفعة، المسدد، الباقي)
              DsCard(
                backgroundColor: AppColors.surfaceMuted,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _InfoTile(
                            label: 'الشركة',
                            value: inst.companyName,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 3,
                          child: _InfoTile(
                            label: 'العميل',
                            value: inst.customerName,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 2,
                          child: _InfoTile(
                            label: 'البائع',
                            value: inst.salespersonName,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 2,
                          child: _InfoTile(
                            label: 'المتابع',
                            value: inst.followerName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            label: 'ر الفاتورة / تاريخها',
                            value:
                                '${inst.invoiceNumber} (${AppFormatters.formatDate(inst.invoiceDate)})',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _InfoTile(
                            label: 'قيمة الدفعة (${AppFormatters.formatDate(inst.dueDate)})',
                            value: AppFormatters.formatAmount(inst.amount),
                            highlightColor: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _InfoTile(
                            label: 'المسدد من الدفعة',
                            value:
                                AppFormatters.formatAmount(inst.collectedAmount),
                            highlightColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _InfoTile(
                            label: 'الباقي للتحصيل',
                            value:
                                AppFormatters.formatAmount(inst.remainingAmount),
                            highlightColor: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. New Collection Entry Form
              DsCard(
                backgroundColor: AppColors.surfaceHighlight,
                borderColor: AppColors.warningBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DsTextField(
                            label: 'القيمة المحصلة',
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: DsDatePickerField(
                            label: 'تاريخ التحصيل',
                            date: _collectionDate,
                            onDateSelected: (d) =>
                                setState(() => _collectionDate = d),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: DsDropdown<String>(
                            label: 'طريقة السداد',
                            value: _selectedMethod,
                            items: state.paymentMethods
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedMethod = v),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: DsDropdown<String>(
                            label: 'المحصل',
                            value: _selectedCollector,
                            items: state.followersAndCollectors
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f.name,
                                    child: Text(f.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCollector = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: DsTextField(
                            label: 'ملاحظات السداد',
                            controller: _notesCtrl,
                            hint:
                                'مثال: إيداع بحساب الشركة بنك مصر / تحصيل نقدي بمقر العميل...',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        DsButton(
                          label: 'حفظ التحصيل (إضافة)',
                          icon: Icons.add_task_rounded,
                          variant: DsButtonVariant.primary,
                          onPressed: () async {
                            final amount =
                                double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
                            if (amount <= 0) return;
                            await cubit.addCollection(
                              installment: inst,
                              collectedAmount: amount,
                              collectionDate: _collectionDate,
                              paymentMethod: _selectedMethod ?? 'نقدي',
                              collectorName:
                                  _selectedCollector ?? 'مسئول البيع',
                              notes: _notesCtrl.text,
                            );
                            if (context.mounted) {
                              context.read<InvoicesCubit>().loadInvoices();
                              final updatedInst = context
                                  .read<InstallmentsCubit>()
                                  .state
                                  .allInstallments
                                  .where((i) => i.id == inst.id)
                                  .firstOrNull;
                              _amountCtrl.text =
                                  (updatedInst?.remainingAmount ?? 0.0)
                                      .toStringAsFixed(1);
                              _notesCtrl.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Collections History Table (عرض موقف التحصيلات للدفعة المحددة من الفاتورة)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عرض موقف التحصيلات للدفعة المحددة من الفاتورة',
                    style: AppTypography.h3,
                  ),
                  DsCountBadge(count: collections.length, label: 'حركة تحصيل'),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 220,
                child: DsDataGrid<CollectionEntity>(
                  items: collections,
                  emptyMessage: 'لم يتم تسجيل أي تحصيلات على هذه الدفعة حتى الآن',
                  columns: [
                    DsColumn(
                      title: 'القيمة المحصلة',
                      flex: 2,
                      cellBuilder: (c) => Text(
                        AppFormatters.formatAmount(c.collectedAmount),
                        style: AppTypography.tabularNumber.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    DsColumn(
                      title: 'ت التحصيل',
                      flex: 2,
                      cellBuilder: (c) => Text(
                        AppFormatters.formatDate(c.collectionDate),
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'طريقة السداد',
                      flex: 2,
                      cellBuilder: (c) => DsStatusBadge(
                        label: c.paymentMethod,
                        type: DsBadgeType.info,
                      ),
                    ),
                    DsColumn(
                      title: 'اسم المتابع',
                      flex: 2,
                      cellBuilder: (c) => Text(c.followerName),
                    ),
                    DsColumn(
                      title: 'ملاحظات السداد',
                      flex: 3,
                      cellBuilder: (c) => Text(
                        c.notes.isEmpty ? '-' : c.notes,
                      ),
                    ),
                    DsColumn(
                      title: 'اسم المحصل',
                      flex: 2,
                      cellBuilder: (c) => Text(c.collectorName),
                    ),
                    DsColumn(
                      title: 'حذف',
                      flex: 1,
                      alignment: Alignment.center,
                      cellBuilder: (c) => IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        onPressed: () async {
                          await cubit.deleteCollection(c.id);
                          if (context.mounted) {
                            context.read<InvoicesCubit>().loadInvoices();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          footerActions: [
            DsButton(
              label: 'إغلاق (ESC)',
              variant: DsButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? highlightColor;

  const _InfoTile({
    required this.label,
    required this.value,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: highlightColor != null
            ? highlightColor!.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: AppRadius.brSm,
        border: Border.all(
          color: highlightColor != null
              ? highlightColor!.withValues(alpha: 0.35)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: highlightColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
