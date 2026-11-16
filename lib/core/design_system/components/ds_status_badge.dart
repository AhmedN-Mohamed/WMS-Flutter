import 'package:flutter/material.dart';
import '../../utils/formatters.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum DsBadgeType {
  success,
  warning,
  danger,
  info,
  neutral,
}

class DsStatusBadge extends StatelessWidget {
  final String label;
  final DsBadgeType type;

  const DsStatusBadge({
    super.key,
    required this.label,
    this.type = DsBadgeType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final style = _resolve(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: AppRadius.brFull,
        border: Border.all(color: style.border),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: style.fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  ({Color bg, Color fg, Color border}) _resolve(DsBadgeType t) {
    switch (t) {
      case DsBadgeType.success:
        return (
          bg: AppColors.successBg,
          fg: AppColors.success,
          border: AppColors.successBorder,
        );
      case DsBadgeType.warning:
        return (
          bg: AppColors.warningBg,
          fg: AppColors.warning,
          border: AppColors.warningBorder,
        );
      case DsBadgeType.danger:
        return (
          bg: AppColors.dangerBg,
          fg: AppColors.danger,
          border: AppColors.dangerBorder,
        );
      case DsBadgeType.info:
        return (
          bg: AppColors.infoBg,
          fg: AppColors.info,
          border: AppColors.infoBorder,
        );
      case DsBadgeType.neutral:
        return (
          bg: AppColors.surfaceMuted,
          fg: AppColors.textSecondary,
          border: AppColors.border,
        );
    }
  }
}

/// Signature green record counter badge inspired by the legacy Kanza Group UI.
class DsCountBadge extends StatelessWidget {
  final int count;
  final String? label;

  const DsCountBadge({
    super.key,
    required this.count,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tableHeaderBg,
        borderRadius: AppRadius.brSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppFormatters.formatNumber(count),
            style: AppTypography.tabularNumber.copyWith(
              color: Colors.white,
              fontSize: 13.5,
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label!,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
