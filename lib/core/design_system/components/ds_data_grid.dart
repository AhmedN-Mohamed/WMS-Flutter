import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class DsColumn<T> {
  final String title;
  final int flex;
  final Alignment alignment;
  final Widget Function(T item) cellBuilder;

  const DsColumn({
    required this.title,
    required this.cellBuilder,
    this.flex = 1,
    this.alignment = Alignment.centerRight,
  });
}

class DsDataGrid<T> extends StatelessWidget {
  final List<DsColumn<T>> columns;
  final List<T> items;
  final T? selectedItem;
  final bool Function(T a, T b)? isEqual;
  final ValueChanged<T>? onRowTap;
  final ValueChanged<T>? onRowDoubleTap;
  final String emptyMessage;
  final bool isLoading;

  const DsDataGrid({
    super.key,
    required this.columns,
    required this.items,
    this.selectedItem,
    this.isEqual,
    this.onRowTap,
    this.onRowDoubleTap,
    this.emptyMessage = 'لا توجد سجلات مطابقة للبحث',
    this.isLoading = false,
  });

  bool _checkSelected(T item) {
    if (selectedItem == null) return false;
    if (isEqual != null) return isEqual!(item, selectedItem as T);
    return item == selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Sticky Table Header
          Container(
            color: AppColors.tableHeaderBg,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 11,
            ),
            child: Row(
              children: columns
                  .map(
                    (col) => Expanded(
                      flex: col.flex,
                      child: Align(
                        alignment: col.alignment,
                        child: Text(
                          col.title,
                          style: AppTypography.tableHeader,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Table Body
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              emptyMessage,
                              style: AppTypography.subtitle.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.borderSubtle,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = _checkSelected(item);
                          final rowBg = isSelected
                              ? AppColors.tableRowSelected
                              : (index.isEven
                                  ? AppColors.tableRowEven
                                  : AppColors.tableRowOdd);

                          return GestureDetector(
                            onDoubleTap: onRowDoubleTap != null
                                ? () => onRowDoubleTap!(item)
                                : null,
                            child: Material(
                              color: rowBg,
                              child: InkWell(
                                hoverColor: AppColors.tableRowHover,
                                onTap:
                                    onRowTap != null ? () => onRowTap!(item) : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: columns
                                        .map(
                                          (col) => Expanded(
                                            flex: col.flex,
                                            child: Align(
                                              alignment: col.alignment,
                                              child: DefaultTextStyle(
                                                style: AppTypography.tableCell.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                ),
                                                child: col.cellBuilder(item),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
