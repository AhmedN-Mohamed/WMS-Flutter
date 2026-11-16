import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/product_entity.dart';
import '../cubit/master_data_cubit.dart';
import '../cubit/master_data_state.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  String? _selectedUnit;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _populate(ProductEntity? item) {
    if (item == null) {
      _nameCtrl.clear();
      _priceCtrl.text = '0';
      _notesCtrl.clear();
      setState(() => _selectedUnit = null);
    } else {
      _nameCtrl.text = item.name;
      _priceCtrl.text = item.guidingPrice.toStringAsFixed(0);
      _notesCtrl.text = item.notes;
      setState(() => _selectedUnit = item.unit);
    }
  }

  Future<void> _exportExcel(MasterDataState state) async {
    final path = await ExportService.exportToCsv(
      fileNamePrefix: 'المنتجات_والاصناف',
      headers: ['اسم المنتج', 'الوحدة', 'سعر استرشادي', 'ملاحظات'],
      rows: state.filteredProducts
          .map(
            (p) => [
              p.name,
              p.unit,
              p.guidingPrice.toStringAsFixed(1),
              p.notes,
            ],
          )
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
        final selected = state.selectedProduct;

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              DsScreenHeader(
                title: 'المنتجات والأصناف',
                subtitle:
                    'تسجيل الأصناف مع سعر استرشادي يظهر تلقائياً في الفاتورة مع إمكانية تعديل السعر بحرية لكل فاتورة',
                icon: Icons.inventory_2_rounded,
                totalCount: state.filteredProducts.length,
                countLabel: 'صنف',
                actions: [
                  DsButton(
                    label: 'إضافة',
                    icon: Icons.add_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectProduct(null);
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ الإضافة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      cubit.saveProduct(
                        name: _nameCtrl.text,
                        unit: _selectedUnit ??
                            (state.units.firstOrNull ?? 'وحدة'),
                        guidingPrice:
                            double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
                        notes: _notesCtrl.text,
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
                            cubit.saveProduct(
                              id: selected.id,
                              name: _nameCtrl.text,
                              unit: _selectedUnit ?? selected.unit,
                              guidingPrice:
                                  double.tryParse(_priceCtrl.text.trim()) ??
                                      0.0,
                              notes: _notesCtrl.text,
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
                            cubit.deleteSelectedProduct();
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
                      flex: 3,
                      child: DsTextField(
                        label: 'اسم المنتج',
                        controller: _nameCtrl,
                        hint: 'مثال: بلادين 200 كجم / رول بلاستيك...',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: DsDropdown<String>(
                        label: 'وحدة القياس',
                        value: _selectedUnit ?? state.units.firstOrNull,
                        items: state.units
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUnit = v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: DsTextField(
                        label: 'س استرشادى (قابل للتعديل بالفاتورة)',
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: DsTextField(
                        label: 'ملاحظات الصنف',
                        controller: _notesCtrl,
                        hint: 'أي تفاصيل إضافية...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DsCard(
                padding: AppSpacing.compactCardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بالاسم أو الوحدة...',
                        value: state.productSearch,
                        onChanged: cubit.updateProductSearch,
                        onClear: () => cubit.updateProductSearch(''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: DsDataGrid<ProductEntity>(
                  items: state.filteredProducts,
                  selectedItem: state.selectedProduct,
                  isEqual: (a, b) => a.id == b.id,
                  onRowTap: (item) {
                    cubit.selectProduct(item);
                    _populate(item);
                  },
                  columns: [
                    DsColumn(
                      title: 'اسم المنتج',
                      flex: 3,
                      cellBuilder: (item) => Text(item.name),
                    ),
                    DsColumn(
                      title: 'الوحدة',
                      flex: 2,
                      cellBuilder: (item) => DsStatusBadge(
                        label: item.unit,
                        type: DsBadgeType.info,
                      ),
                    ),
                    DsColumn(
                      title: 'س استرشادى',
                      flex: 2,
                      cellBuilder: (item) => Text(
                        AppFormatters.formatAmount(item.guidingPrice),
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'ملاحظات',
                      flex: 3,
                      cellBuilder: (item) => Text(
                        item.notes.isEmpty ? '-' : item.notes,
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
