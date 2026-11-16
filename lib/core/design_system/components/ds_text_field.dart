import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class DsTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;
  final Color? fillColor;

  const DsTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppTypography.label),
          const SizedBox(height: AppSpacing.xxs + 2),
        ],
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: AppTypography.bodyMedium.copyWith(
            color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            fillColor: fillColor ??
                (readOnly ? AppColors.surfaceMuted : AppColors.surface),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 17, color: AppColors.textMuted)
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class DsSearchField extends StatelessWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final double? width;

  const DsSearchField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.onClear,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      onChanged: onChanged,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: onClear,
                tooltip: 'مسح البحث',
              )
            : null,
      ),
    );
    return width != null ? SizedBox(width: width, child: field) : field;
  }
}
