import 'package:flutter/material.dart';

/// Centralized semantic color tokens for the Kanza Group WMS & Collections Design System.
class AppColors {
  AppColors._();

  // Brand Primary (Modern Emerald-Teal inspired by Kanza Group's signature green grids)
  static const Color primary = Color(0xFF0F766E); // Teal 700
  static const Color primaryHover = Color(0xFF115E59); // Teal 800
  static const Color primaryLight = Color(0xFFCCFBF1); // Teal 100
  static const Color primarySubtle = Color(0xFFF0FDFA); // Teal 50

  // Brand Secondary / Accent (Royal Blue for Invoice & Installment highlights)
  static const Color secondary = Color(0xFF0284C7); // Sky 600
  static const Color secondaryHover = Color(0xFF0369A1); // Sky 700
  static const Color secondaryLight = Color(0xFFE0F2FE); // Sky 100

  // Sidebar & Navigation Shell (Deep Enterprise Slate)
  static const Color sidebarBg = Color(0xFF0F172A); // Slate 900
  static const Color sidebarSurface = Color(0xFF1E293B); // Slate 800
  static const Color sidebarActive = Color(0xFF0D9488); // Teal 600
  static const Color sidebarText = Color(0xFFF8FAFC);
  static const Color sidebarTextMuted = Color(0xFF94A3B8);

  // Canvas & Surface Hierarchy
  static const Color background = Color(0xFFF1F5F9); // Slate 100
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceHighlight = Color(0xFFFFFBEB); // Warm amber tint for active input panels

  // Table / Data Grid Specific Colors
  static const Color tableHeaderBg = Color(0xFF134E4A); // Deep Kanza Green (Teal 900)
  static const Color tableHeaderText = Color(0xFFFFFFFF);
  static const Color tableRowEven = Color(0xFFFFFFFF);
  static const Color tableRowOdd = Color(0xFFF8FAFC);
  static const Color tableRowSelected = Color(0xFFCCFBF1); // Teal 100
  static const Color tableRowHover = Color(0xFFF0FDFA);

  // Borders & Dividers
  static const Color border = Color(0xFFCBD5E1); // Slate 300
  static const Color borderSubtle = Color(0xFFE2E8F0); // Slate 200
  static const Color borderFocus = Color(0xFF0D9488);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Financial & Operational Status Colors
  static const Color success = Color(0xFF15803D); // Green 700 (Fully Collected / مسدد بالكامل)
  static const Color successBg = Color(0xFFDCFCE7); // Green 100
  static const Color successBorder = Color(0xFF86EFAC);

  static const Color warning = Color(0xFFB45309); // Amber 700 (Partially Collected / تحصيل جزئي)
  static const Color warningBg = Color(0xFFFEF3C7); // Amber 100
  static const Color warningBorder = Color(0xFFFCD34D);

  static const Color danger = Color(0xFFB91C1C); // Red 700 (Overdue / متأخرات / مديونية)
  static const Color dangerBg = Color(0xFFFEE2E2); // Red 100
  static const Color dangerBorder = Color(0xFFFCA5A5);

  static const Color info = Color(0xFF1D4ED8); // Blue 700 (Scheduled / مجدول)
  static const Color infoBg = Color(0xFFDBEAFE); // Blue 100
  static const Color infoBorder = Color(0xFF93C5FD);

  // Action Specific (Excel, PDF, Reports)
  static const Color excelGreen = Color(0xFF166534);
  static const Color pdfRed = Color(0xFF991B1B);
  static const Color reportGold = Color(0xFFD97706);
}
