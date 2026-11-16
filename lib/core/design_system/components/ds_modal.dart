import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class DsModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final double width;
  final double? maxHeight;
  final Widget body;
  final List<Widget> footerActions;

  const DsModal({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.width = 760,
    this.maxHeight,
    required this.body,
    this.footerActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.sidebarBg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.primaryLight, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTypography.h2.copyWith(color: Colors.white),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.sidebarTextMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'إغلاق (ESC)',
                  ),
                ],
              ),
            ),
            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: body,
              ),
            ),
            // Modal Footer
            if (footerActions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < footerActions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.xs),
                      footerActions[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
