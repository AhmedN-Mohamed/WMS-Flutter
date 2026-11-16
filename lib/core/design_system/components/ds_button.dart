import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum DsButtonVariant {
  primary,
  secondary,
  info,
  warning,
  danger,
  excel,
  pdf,
  ghost,
}

class DsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final DsButtonVariant variant;
  final bool isCompact;
  final bool isLoading;
  final bool fullWidth;

  const DsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = DsButtonVariant.primary,
    this.isCompact = false,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);
    final padding = isCompact
        ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 7)
        : const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10);

    final Widget childContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.fg,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ] else if (icon != null) ...[
          Icon(icon, size: isCompact ? 15 : 17, color: colors.fg),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.fg,
              fontWeight: FontWeight.w700,
              fontSize: isCompact ? 12 : 13,
            ),
          ),
        ),
      ],
    );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        disabledBackgroundColor: colors.bg.withValues(alpha: 0.45),
        disabledForegroundColor: colors.fg.withValues(alpha: 0.65),
        padding: padding,
        minimumSize: Size(0, isCompact ? 32 : 38),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brSm,
          side: BorderSide(color: colors.border),
        ),
      ),
      child: childContent,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ({Color bg, Color fg, Color border}) _resolveColors(DsButtonVariant v) {
    switch (v) {
      case DsButtonVariant.primary:
        return (
          bg: AppColors.primary,
          fg: Colors.white,
          border: AppColors.primary,
        );
      case DsButtonVariant.secondary:
        return (
          bg: AppColors.surface,
          fg: AppColors.textPrimary,
          border: AppColors.border,
        );
      case DsButtonVariant.info:
        return (
          bg: AppColors.secondary,
          fg: Colors.white,
          border: AppColors.secondary,
        );
      case DsButtonVariant.warning:
        return (
          bg: AppColors.reportGold,
          fg: Colors.white,
          border: AppColors.reportGold,
        );
      case DsButtonVariant.danger:
        return (
          bg: AppColors.danger,
          fg: Colors.white,
          border: AppColors.danger,
        );
      case DsButtonVariant.excel:
        return (
          bg: AppColors.excelGreen,
          fg: Colors.white,
          border: AppColors.excelGreen,
        );
      case DsButtonVariant.pdf:
        return (
          bg: AppColors.pdfRed,
          fg: Colors.white,
          border: AppColors.pdfRed,
        );
      case DsButtonVariant.ghost:
        return (
          bg: Colors.transparent,
          fg: AppColors.textSecondary,
          border: Colors.transparent,
        );
    }
  }
}
