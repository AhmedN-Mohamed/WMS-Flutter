import 'package:flutter/material.dart';
import '../../utils/formatters.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class DsDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;

  const DsDatePickerField({
    super.key,
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 4),
              InkWell(
                onTap: () => onDateSelected(DateTime.now()),
                child: Text(
                  'اليوم (D)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs + 2),
        ],
        InkWell(
          borderRadius: AppRadius.brSm,
          onTap: () async {
            final initial = date ?? DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2015),
              lastDate: DateTime(2035),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.calendar_month_rounded,
                size: 17,
                color: AppColors.primary,
              ),
            ),
            child: Text(
              AppFormatters.formatDate(date),
              style: AppTypography.tabularNumber.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
