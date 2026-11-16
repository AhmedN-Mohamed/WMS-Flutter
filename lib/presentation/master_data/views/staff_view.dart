import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../domain/entities/staff_entity.dart';
import '../cubit/master_data_cubit.dart';
import '../cubit/master_data_state.dart';

class StaffView extends StatefulWidget {
  final StaffRole role;

  const StaffView({super.key, required this.role});

  @override
  State<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {
  final _nameCtrl = TextEditingController();
  final _mobile1Ctrl = TextEditingController();
  final _mobile2Ctrl = TextEditingController();
  String? _selectedRating;

  @override
  void didUpdateWidget(covariant StaffView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _populate(null);
      context.read<MasterDataCubit>().selectStaff(null);
      context.read<MasterDataCubit>().updateStaffFilters(
            nameMobile: '',
            rating: '',
          );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobile1Ctrl.dispose();
    _mobile2Ctrl.dispose();
    super.dispose();
  }

  void _populate(StaffEntity? item) {
    if (item == null) {
      _nameCtrl.clear();
      _mobile1Ctrl.clear();
      _mobile2Ctrl.clear();
      setState(() => _selectedRating = null);
    } else {
      _nameCtrl.text = item.name;
      _mobile1Ctrl.text = item.mobile1;
      _mobile2Ctrl.text = item.mobile2;
      setState(() => _selectedRating = item.rating.isEmpty ? null : item.rating);
    }
  }

  Future<void> _exportExcel(List<StaffEntity> items) async {
    final path = await ExportService.exportToCsv(
      fileNamePrefix: widget.role.screenTitle,
      headers: [widget.role.nameFieldLabel, 'موبايل 1', 'موبايل 2', 'التقييم'],
      rows: items
          .map((s) => [s.name, s.mobile1, s.mobile2, s.rating])
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
        final items = state.filteredStaffByRole(widget.role);
        final selected = state.selectedStaff?.role == widget.role
            ? state.selectedStaff
            : null;

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              DsScreenHeader(
                title: widget.role.screenTitle,
                subtitle:
                    'إدارة بيانات (${widget.role.screenTitle}) وأرقام الهواتف والتقييم لربطهم بالفواتير والتقارير',
                icon: widget.role == StaffRole.salesperson
                    ? Icons.badge_rounded
                    : widget.role == StaffRole.shippingRep
                        ? Icons.local_shipping_rounded
                        : Icons.support_agent_rounded,
                totalCount: items.length,
                countLabel: 'مسجل',
                actions: [
                  DsButton(
                    label: 'إضافة',
                    icon: Icons.add_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectStaff(null);
                      _populate(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ الإضافة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      cubit.saveStaff(
                        role: widget.role,
                        name: _nameCtrl.text,
                        mobile1: _mobile1Ctrl.text,
                        mobile2: _mobile2Ctrl.text,
                        rating: _selectedRating ?? '',
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
                            cubit.saveStaff(
                              id: selected.id,
                              role: widget.role,
                              name: _nameCtrl.text,
                              mobile1: _mobile1Ctrl.text,
                              mobile2: _mobile2Ctrl.text,
                              rating: _selectedRating ?? '',
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
                            cubit.deleteSelectedStaff();
                            _populate(null);
                          },
                  ),
                  DsButton(
                    label: 'To_Excel',
                    icon: Icons.table_view_rounded,
                    variant: DsButtonVariant.excel,
                    onPressed: () => _exportExcel(items),
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
                        label: widget.role.nameFieldLabel,
                        controller: _nameCtrl,
                        hint: 'الاسم بالكامل...',
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
                        hint: '012...',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: DsDropdown<String>(
                        label: 'التقييم',
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
                        onChanged: (v) => setState(() => _selectedRating = v),
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
                        hint: 'بحث بالاسم أو رقم الموبايل...',
                        value: state.staffSearch,
                        onChanged: (v) =>
                            cubit.updateStaffFilters(nameMobile: v),
                        onClear: () =>
                            cubit.updateStaffFilters(nameMobile: ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DsSearchField(
                        hint: 'بحث بالتقييم...',
                        value: state.staffRatingSearch,
                        onChanged: (v) => cubit.updateStaffFilters(rating: v),
                        onClear: () => cubit.updateStaffFilters(rating: ''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: DsDataGrid<StaffEntity>(
                  items: items,
                  selectedItem: selected,
                  isEqual: (a, b) => a.id == b.id,
                  onRowTap: (item) {
                    cubit.selectStaff(item);
                    _populate(item);
                  },
                  columns: [
                    DsColumn(
                      title: widget.role.nameFieldLabel,
                      flex: 3,
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
                      title: 'التقييم',
                      flex: 2,
                      cellBuilder: (item) => item.rating.isEmpty
                          ? const Text('-')
                          : DsStatusBadge(
                              label: item.rating,
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
