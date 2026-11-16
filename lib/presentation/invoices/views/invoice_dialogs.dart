import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../cubit/invoices_state.dart';

/// Modal for `اضافة المنتجات للفاتورة` with auto-filled Guiding Price (`سعر استرشادي`)
/// that can be freely modified per invoice.
class InvoiceItemsModal extends StatefulWidget {
  final List<ProductEntity> products;
  final List<InvoiceItemEntity> initialItems;

  const InvoiceItemsModal({
    super.key,
    required this.products,
    required this.initialItems,
  });

  @override
  State<InvoiceItemsModal> createState() => _InvoiceItemsModalState();
}

class _InvoiceItemsModalState extends State<InvoiceItemsModal> {
  late List<InvoiceItemEntity> _items;
  ProductEntity? _selectedProduct;
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List<InvoiceItemEntity>.from(widget.initialItems);
    if (widget.products.isNotEmpty) {
      _selectedProduct = widget.products.first;
      _priceCtrl.text = _selectedProduct!.guidingPrice.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _totalSum =>
      _items.fold<double>(0.0, (sum, item) => sum + item.lineTotal);

  void _addItem() {
    final prod = _selectedProduct;
    if (prod == null) return;
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 1.0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? prod.guidingPrice;
    if (qty <= 0) return;

    setState(() {
      _items.add(
        InvoiceItemEntity(
          id: 'ii_${DateTime.now().microsecondsSinceEpoch}',
          productId: prod.id,
          productName: prod.name,
          unit: prod.unit,
          quantity: qty,
          unitPrice: price,
          notes: _notesCtrl.text.trim(),
        ),
      );
      _qtyCtrl.text = '1';
      _notesCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DsModal(
      title: 'إضافة المنتجات والأصناف للفاتورة',
      subtitle:
          'يظهر السعر الاسترشادي تلقائياً عند اختيار الصنف ويمكنك تعديل السعر في نفس اللحظة حسب الاتفاق',
      icon: Icons.shopping_cart_checkout_rounded,
      width: 820,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsCard(
            backgroundColor: AppColors.surfaceHighlight,
            borderColor: AppColors.warningBorder,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: DsDropdown<ProductEntity>(
                    label: 'اختر الصنف',
                    value: _selectedProduct,
                    items: widget.products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              '${p.name} (استرشادي: ${AppFormatters.formatAmount(p.guidingPrice)})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (p) {
                      setState(() {
                        _selectedProduct = p;
                        if (p != null) {
                          _priceCtrl.text =
                              p.guidingPrice.toStringAsFixed(0);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 1,
                  child: DsTextField(
                    label: 'الكمية',
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: DsTextField(
                    label: 'سعر البيع الفعلي للوحدة',
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DsButton(
                  label: 'إضافة للفاتورة',
                  icon: Icons.add_circle_outline_rounded,
                  variant: DsButtonVariant.primary,
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 260,
            child: DsDataGrid<InvoiceItemEntity>(
              items: _items,
              emptyMessage: 'لم يتم إضافة أصناف بعد لهذه الفاتورة',
              columns: [
                DsColumn(
                  title: 'اسم الصنف',
                  flex: 3,
                  cellBuilder: (i) => Text(i.productName),
                ),
                DsColumn(
                  title: 'الوحدة',
                  flex: 2,
                  cellBuilder: (i) => Text(i.unit),
                ),
                DsColumn(
                  title: 'الكمية',
                  flex: 1,
                  cellBuilder: (i) => Text(
                    i.quantity.toString(),
                    style: AppTypography.tabularNumber,
                  ),
                ),
                DsColumn(
                  title: 'سعر الوحدة',
                  flex: 2,
                  cellBuilder: (i) => Text(
                    AppFormatters.formatAmount(i.unitPrice),
                    style: AppTypography.tabularNumber,
                  ),
                ),
                DsColumn(
                  title: 'الإجمالي',
                  flex: 2,
                  cellBuilder: (i) => Text(
                    AppFormatters.formatAmount(i.lineTotal),
                    style: AppTypography.tabularNumber
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                DsColumn(
                  title: 'حذف',
                  flex: 1,
                  alignment: Alignment.center,
                  cellBuilder: (i) => IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    onPressed: () {
                      setState(() => _items.removeWhere((e) => e.id == i.id));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadius.brSm,
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي الأصناف المضافة للفاتورة:',
                  style: AppTypography.h3,
                ),
                Text(
                  AppFormatters.formatAmount(_totalSum, currency: 'جنيه مصرى'),
                  style: AppTypography.tabularNumber.copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footerActions: [
        DsButton(
          label: 'إلغاء',
          variant: DsButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          label: 'اعتماد الأصناف وتحديث قيمة الفاتورة',
          icon: Icons.check_circle_rounded,
          variant: DsButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(_items),
        ),
      ],
    );
  }
}

/// Modal for `موقف فواتير عميل` (Customer Account Statement across all invoices)
class CustomerStatementModal extends StatelessWidget {
  final String customerId;
  final String customerName;
  final InvoicesState state;
  final ValueChanged<InvoiceEntity> onOpenInvoiceInstallments;

  const CustomerStatementModal({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.state,
    required this.onOpenInvoiceInstallments,
  });

  @override
  Widget build(BuildContext context) {
    final customerInvoices = state.allInvoices
        .where((i) => i.customerId == customerId)
        .toList();

    final totalInvoiced = customerInvoices.fold<double>(
      0.0,
      (s, i) => s + i.totalAmount,
    );
    final totalCollected = customerInvoices.fold<double>(
      0.0,
      (s, i) => s + state.collectedAmountForInvoice(i.id),
    );
    final totalRemaining =
        (totalInvoiced - totalCollected).clamp(0.0, double.infinity);

    return DsModal(
      title: 'موقف فواتير عميل: $customerName',
      subtitle: 'كشف حساب تفصيلي بجميع الفواتير والمسدد والمتبقي للعميل',
      icon: Icons.account_balance_wallet_rounded,
      width: 900,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DsKpiCard(
                  title: 'إجمالي فواتير العميل',
                  value: AppFormatters.formatAmount(totalInvoiced),
                  icon: Icons.receipt_long_rounded,
                  accentColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DsKpiCard(
                  title: 'إجمالي المسدد',
                  value: AppFormatters.formatAmount(totalCollected),
                  icon: Icons.check_circle_rounded,
                  accentColor: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DsKpiCard(
                  title: 'إجمالي المديونية المتبقية',
                  value: AppFormatters.formatAmount(totalRemaining),
                  icon: Icons.warning_amber_rounded,
                  accentColor: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 320,
            child: DsDataGrid<InvoiceEntity>(
              items: customerInvoices,
              columns: [
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
                  title: 'الشركة',
                  flex: 3,
                  cellBuilder: (i) => Text(i.companyName),
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
                  title: 'المسدد',
                  flex: 2,
                  cellBuilder: (i) => Text(
                    AppFormatters.formatAmount(
                      state.collectedAmountForInvoice(i.id),
                    ),
                    style: AppTypography.tabularNumber
                        .copyWith(color: AppColors.success),
                  ),
                ),
                DsColumn(
                  title: 'المتبقي',
                  flex: 2,
                  cellBuilder: (i) => Text(
                    AppFormatters.formatAmount(
                      state.remainingDebtForInvoice(i),
                    ),
                    style: AppTypography.tabularNumber
                        .copyWith(color: AppColors.danger),
                  ),
                ),
                DsColumn(
                  title: 'الدفعات والتحصيل',
                  flex: 2,
                  alignment: Alignment.center,
                  cellBuilder: (i) => DsButton(
                    label: 'الدفعات',
                    isCompact: true,
                    variant: DsButtonVariant.info,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpenInvoiceInstallments(i);
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
          label: 'إغلاق',
          variant: DsButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Modal for `مديونية قطاع` (Sector / Sub-Company Debt Breakdown)
class SectorDebtModal extends StatelessWidget {
  final InvoicesState state;

  const SectorDebtModal({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return DsModal(
      title: 'مديونية قطاع / الشركات الفرعية',
      subtitle: 'إجمالي الفواتير والتحصيلات والمديونيات المتبقية لكل شركة في المجموعة',
      icon: Icons.pie_chart_rounded,
      width: 820,
      body: Column(
        children: [
          for (final comp in state.companies) ...[
            Builder(
              builder: (context) {
                final compInvs = state.allInvoices
                    .where((i) => i.companyId == comp.id)
                    .toList();
                final totalInv = compInvs.fold<double>(
                  0.0,
                  (s, i) => s + i.totalAmount,
                );
                final totalColl = compInvs.fold<double>(
                  0.0,
                  (s, i) => s + state.collectedAmountForInvoice(i.id),
                );
                final remaining =
                    (totalInv - totalColl).clamp(0.0, double.infinity);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: DsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${comp.code} - ${comp.name}',
                              style: AppTypography.h3,
                            ),
                            DsCountBadge(
                              count: compInvs.length,
                              label: 'فاتورة',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: DsKpiCard(
                                title: 'إجمالي الفواتير',
                                value: AppFormatters.formatAmount(totalInv),
                                icon: Icons.receipt_rounded,
                                accentColor: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: DsKpiCard(
                                title: 'المحصل الفعلي',
                                value: AppFormatters.formatAmount(totalColl),
                                icon: Icons.payments_rounded,
                                accentColor: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: DsKpiCard(
                                title: 'مديونية القطاع المتبقية',
                                value: AppFormatters.formatAmount(remaining),
                                icon: Icons.account_balance_wallet_rounded,
                                accentColor: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      footerActions: [
        DsButton(
          label: 'إغلاق',
          variant: DsButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
