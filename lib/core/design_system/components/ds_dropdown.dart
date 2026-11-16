import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class DsDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;
  final bool allowClear;

  const DsDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'اختر...',
    this.allowClear = false,
  });

  @override
  Widget build(BuildContext context) {
    final validValues = items.map((e) => e.value).toSet();
    final effectiveValue = (value != null && validValues.contains(value)) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (allowClear && effectiveValue != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => onChanged(null),
                  child: Text(
                    'الكل / مسح',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxs + 2),
        ],
        DropdownButtonFormField<T>(
          initialValue: effectiveValue,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          style: AppTypography.bodyMedium,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          hint: Text(
            hint,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 9,
            ),
          ),
        ),
      ],
    );
  }
}
