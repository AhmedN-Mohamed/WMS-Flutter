import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../domain/entities/customer_entity.dart';
import '../cubit/master_data_cubit.dart';
import '../cubit/master_data_state.dart';

class CustomersView extends StatefulWidget {
  const CustomersView({super.key});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  final _nameCtrl = TextEditingController();
  final _mobile1Ctrl = TextEditingController();
  final _mobile2Ctrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedType;
  String? _selectedRating;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobile1Ctrl.dispose();
    _mobile2Ctrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _populate(CustomerEntity? item) {
    if (item == null) {
      _nameCtrl.clear();
      _mobile1Ctrl.clear();
      _mobile2Ctrl.clear();
      _locationCtrl.clear();
      _notesCtrl.clear();
      setState(() {
        _selectedType = null;
        _selectedRating = null;
      });
    } else {
      _nameCtrl.text = item.name;
      _mobile1Ctrl.text = item.mobile1;
      _mobile2Ctrl.text = item.mobile2;
      _locationCtrl.text = item.locationUrl;
      _notesCtrl.text = item.notes;
      setState(() {
        _selectedType = item.customerType.isEmpty ? null : item.customerType;
        _selectedRating = item.rating.isEmpty ? null : item.rating;
      });
    }
  }

  Future<void> _exportExcel(MasterDataState state) async {
    final path = await ExportService.exportToCsv(
      fileNamePrefix: 'بيانات_العملاء',
      headers: [
        'اسم العميل',
        'موبايل 1',
        'موبايل 2',
        'نوع العميل',
        'التقييم',
        'موقع العميل',
        'ملاحظات',
      ],
      rows: state.filteredCustomers
          .map(
            (c) => [
              c.name,
              c.mobile1,
              c.mobile2,
              c.customerType,
              c.rating,
              c.locationUrl,
              c.notes,
            ],
          )
          .toList(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تصدير بيانات العملاء إلى: $path')),
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
        final selected = state.selectedCustomer;

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              DsScreenHeader(
                title: 'بيانات العملاء',
                subtitle:
                    'سجل بيانات العملاء الجدد والحاليين وأرقام التواصل ونوع النشاط والتقييم والموقع الجغرافي',
                icon: Icons.groups_rounded,
                totalCount: state.filteredCustomers.length,
                countLabel: 'عميل',
                actions: [
                  DsButton(
                    label: 'إضافة',
                    icon: Icons.person_add_alt_1_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectCustomer(null);
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ الإضافة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      cubit.saveCustomer(
                        name: _nameCtrl.text,
                        mobile1: _mobile1Ctrl.text,
                        mobile2: _mobile2Ctrl.text,
                        customerType: _selectedType ?? '',
                        rating: _selectedRating ?? '',
                        locationUrl: _locationCtrl.text,
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
                            cubit.saveCustomer(
                              id: selected.id,
                              name: _nameCtrl.text,
                              mobile1: _mobile1Ctrl.text,
                              mobile2: _mobile2Ctrl.text,
                              customerType: _selectedType ?? '',
                              rating: _selectedRating ?? '',
                              locationUrl: _locationCtrl.text,
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
                            cubit.deleteSelectedCustomer();
                            _populate(null);
                          },
                  ),
                  DsButton(
                    label: 'موقع العميل',
                    icon: Icons.location_on_outlined,
                    variant: DsButtonVariant.warning,
                    onPressed: () {
                      final loc = _locationCtrl.text.trim().isNotEmpty
                          ? _locationCtrl.text.trim()
                          : (selected?.locationUrl ?? '');
                      if (loc.isNotEmpty) {
                        ExportService.openExternalLink(loc);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لا يوجد عنوان أو رابط موقع مسجل لهذا العميل'),
                          ),
                        );
                      }
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DsTextField(
                            label: 'اسم العميل',
                            controller: _nameCtrl,
                            hint: 'اسم العميل / المزرعة / الشركة...',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: DsTextField(
                            label: 'موبايل 1',
                            controller: _mobile1Ctrl,
                            hint: '010...',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: DsTextField(
                            label: 'موبايل 2',
                            controller: _mobile2Ctrl,
                            hint: '011...',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DsDropdown<String>(
                            label: 'نوع العميل',
                            value: _selectedType,
                            allowClear: true,
                            items: state.customerTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _selectedType = v),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: DsDropdown<String>(
                            label: 'تقييم العميل',
                            value: _selectedRating,
                            allowClear: true,
                            items: state.ratings
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedRating = v),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 3,
                          child: DsTextField(
                            label: 'موقع العميل (العنوان أو رابط الخريطة)',
                            controller: _locationCtrl,
                            hint: 'طريق مصر إسكندرية الصحراوي / رابط Google Maps...',
                            prefixIcon: Icons.place_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Dual Search Bar (العميل - موبايل | النوع - التقييم)
              DsCard(
                padding: AppSpacing.compactCardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بـ (العميل - موبايل)...',
                        value: state.customerSearch,
                        onChanged: (v) =>
                            cubit.updateCustomerFilters(nameMobile: v),
                        onClear: () =>
                            cubit.updateCustomerFilters(nameMobile: ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بـ (النوع - التقييم)...',
                        value: state.customerTypeRatingSearch,
                        onChanged: (v) =>
                            cubit.updateCustomerFilters(typeRating: v),
                        onClear: () =>
                            cubit.updateCustomerFilters(typeRating: ''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: DsDataGrid<CustomerEntity>(
                  items: state.filteredCustomers,
                  selectedItem: state.selectedCustomer,
                  isEqual: (a, b) => a.id == b.id,
                  onRowTap: (item) {
                    cubit.selectCustomer(item);
                    _populate(item);
                  },
                  columns: [
                    DsColumn(
                      title: 'اسم العميل',
                      flex: 4,
                      cellBuilder: (item) => Text(item.name),
                    ),
                    DsColumn(
                      title: 'موبايل 1',
                      flex: 2,
                      cellBuilder: (item) => Text(
                        item.mobile1.isEmpty ? '-' : item.mobile1,
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'موبايل 2',
                      flex: 2,
                      cellBuilder: (item) => Text(
                        item.mobile2.isEmpty ? '-' : item.mobile2,
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'نوع العميل',
                      flex: 2,
                      cellBuilder: (item) => Text(
                        item.customerType.isEmpty ? '-' : item.customerType,
                      ),
                    ),
                    DsColumn(
                      title: 'التقييم',
                      flex: 2,
                      cellBuilder: (item) => item.rating.isEmpty
                          ? const Text('-')
                          : DsStatusBadge(
                              label: item.rating,
                              type: item.rating.contains('A')
                                  ? DsBadgeType.success
                                  : DsBadgeType.warning,
                            ),
                    ),
                    DsColumn(
                      title: 'موقع العميل',
                      flex: 2,
                      cellBuilder: (item) => Text(
                        item.locationUrl.isEmpty ? '-' : item.locationUrl,
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
