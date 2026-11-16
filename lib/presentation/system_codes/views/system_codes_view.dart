import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../cubit/system_codes_cubit.dart';
import '../cubit/system_codes_state.dart';

class SystemCodesView extends StatefulWidget {
  const SystemCodesView({super.key});

  @override
  State<SystemCodesView> createState() => _SystemCodesViewState();
}

class _SystemCodesViewState extends State<SystemCodesView> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _populateForm(SystemCodeEntity? item) {
    if (item == null) {
      _codeCtrl.clear();
      _nameCtrl.clear();
    } else {
      _codeCtrl.text = item.code;
      _nameCtrl.text = item.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SystemCodesCubit, SystemCodesState>(
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
        final cubit = context.read<SystemCodesCubit>();
        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              DsScreenHeader(
                title: 'أكواد النظام (${state.selectedCategory.arabicTitle})',
                subtitle:
                    'إدارة القوائم المنسدلة والتصنيفات الأساسية للنظام (مستخدمين، بنوك، وحدات، أنظمة سداد، أولويات...)',
                icon: Icons.tune_rounded,
                totalCount: state.filteredCodes.length,
                countLabel: 'كود مسجل',
                actions: [
                  DsButton(
                    label: 'إضافة جديد',
                    icon: Icons.add_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {
                      cubit.selectCode(null);
                      _populateForm(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ الإضافة',
                    icon: Icons.check_circle_outline_rounded,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      cubit.saveCode(
                        code: _codeCtrl.text,
                        name: _nameCtrl.text,
                      );
                      _populateForm(null);
                    },
                  ),
                  DsButton(
                    label: 'حفظ التعديل',
                    icon: Icons.save_outlined,
                    variant: DsButtonVariant.info,
                    onPressed: state.selectedCode == null
                        ? null
                        : () {
                            cubit.saveCode(
                              id: state.selectedCode!.id,
                              code: _codeCtrl.text,
                              name: _nameCtrl.text,
                            );
                          },
                  ),
                  DsButton(
                    label: 'حذف',
                    icon: Icons.delete_outline_rounded,
                    variant: DsButtonVariant.danger,
                    onPressed: state.selectedCode == null
                        ? null
                        : () {
                            cubit.deleteSelectedCode();
                            _populateForm(null);
                          },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Right Side (in RTL): 12 Categories List (الكود)
                    SizedBox(
                      width: 280,
                      child: DsCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.tableHeaderBg,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(AppRadius.md),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الكود (التصنيفات)',
                                    style: AppTypography.tableHeader,
                                  ),
                                  Text(
                                    '${SystemCodeCategory.values.length}',
                                    style: AppTypography.tabularNumber
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: SystemCodeCategory.values.length,
                                separatorBuilder: (_, _) => const Divider(
                                  height: 1,
                                  color: AppColors.borderSubtle,
                                ),
                                itemBuilder: (context, index) {
                                  final cat = SystemCodeCategory.values[index];
                                  final isSelected =
                                      cat == state.selectedCategory;
                                  return Material(
                                    color: isSelected
                                        ? AppColors.tableRowSelected
                                        : Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        cubit.selectCategory(cat);
                                        _populateForm(null);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSelected
                                                  ? Icons.folder_open_rounded
                                                  : Icons.folder_outlined,
                                              size: 18,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: AppSpacing.xs),
                                            Expanded(
                                              child: Text(
                                                cat.arabicTitle,
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 18,
                                              color: AppColors.textMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Left Side (in RTL): Form + Registered Values Table (البيانات المسجلة في الجدول)
                    Expanded(
                      child: Column(
                        children: [
                          DsCard(
                            backgroundColor: AppColors.surfaceHighlight,
                            borderColor: AppColors.warningBorder,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: DsTextField(
                                    label: 'رقم / رمز الكود',
                                    controller: _codeCtrl,
                                    hint: 'تلقائي مثل 004',
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: DsTextField(
                                    label:
                                        'البيان المسجل في (${state.selectedCategory.arabicTitle})',
                                    controller: _nameCtrl,
                                    hint: 'اكتب الاسم أو البيان هنا...',
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                SizedBox(
                                  width: 240,
                                  child: DsSearchField(
                                    hint: 'بحث في البيانات المسجلة...',
                                    value: state.searchQuery,
                                    onChanged: cubit.updateSearch,
                                    onClear: () => cubit.updateSearch(''),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: DsDataGrid<SystemCodeEntity>(
                              items: state.filteredCodes,
                              selectedItem: state.selectedCode,
                              isEqual: (a, b) => a.id == b.id,
                              onRowTap: (item) {
                                cubit.selectCode(item);
                                _populateForm(item);
                              },
                              columns: [
                                DsColumn(
                                  title: 'الكود',
                                  flex: 1,
                                  cellBuilder: (item) => Text(
                                    item.code,
                                    style: AppTypography.tabularNumber,
                                  ),
                                ),
                                DsColumn(
                                  title: 'البيانات المسجلة في الجدول',
                                  flex: 4,
                                  cellBuilder: (item) => Text(item.name),
                                ),
                                DsColumn(
                                  title: 'التصنيف',
                                  flex: 2,
                                  cellBuilder: (item) => DsStatusBadge(
                                    label: item.category.arabicTitle,
                                    type: DsBadgeType.info,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
