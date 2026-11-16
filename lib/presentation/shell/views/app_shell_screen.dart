import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/export_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/audit_log_entity.dart';
import '../../../domain/entities/staff_entity.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../installments/views/installments_view.dart';
import '../../invoices/views/invoices_view.dart';
import '../../master_data/views/bank_accounts_view.dart';
import '../../master_data/views/companies_view.dart';
import '../../master_data/views/customers_view.dart';
import '../../master_data/views/products_view.dart';
import '../../master_data/views/staff_view.dart';
import '../../reports/views/reports_view.dart';
import '../../system_codes/views/system_codes_view.dart';
import '../cubit/app_shell_cubit.dart';
import '../cubit/app_shell_state.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  void _showSwitchUserModal(BuildContext context, AppShellState state) {
    final cubit = context.read<AppShellCubit>();
    cubit.refreshLogs();
    showDialog(
      context: context,
      builder: (_) => DsModal(
        title: 'تغيير المستخدم الحالي للنظام',
        subtitle:
            'اختر المستخدم لتسجيل جميع الحركات والإضافات والتعديلات باسمه',
        icon: Icons.switch_account_rounded,
        width: 480,
        body: state.availableUsers.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'لا يوجد مستخدمين مسجلين في أكواد النظام',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يمكنك إضافة مستخدمي النظام من شاشة "أكواد النظام > مستخدمي النظام"',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DsButton(
                      label: 'الذهاب إلى أكواد النظام',
                      icon: Icons.tune_rounded,
                      variant: DsButtonVariant.primary,
                      onPressed: () {
                        Navigator.of(context).pop();
                        cubit.selectTab(AppNavTab.systemCodes);
                      },
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  for (final SystemCodeEntity user in state.availableUsers)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySubtle,
                        child: Text(
                          user.code,
                          style: AppTypography.tabularNumber
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                      title: Text(user.name, style: AppTypography.h3),
                      subtitle: Text('كود المستخدم: ${user.code}'),
                      trailing: user.code == state.currentUserCode
                          ? const DsStatusBadge(
                              label: 'المستخدم الحالي',
                              type: DsBadgeType.success,
                            )
                          : null,
                      onTap: () {
                        cubit.switchUser(user);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
      ),
    );
  }

  void _showLogViewerModal(BuildContext context) {
    final cubit = context.read<AppShellCubit>();
    cubit.refreshLogs();
    final logs = cubit.state.auditLogs;

    showDialog(
      context: context,
      builder: (_) => DsModal(
        title: 'سجل حركات النظام (LogViewer)',
        subtitle: 'سجل تدقيق العمليات التي تمت بواسطة مستخدمي النظام',
        icon: Icons.history_edu_rounded,
        width: 860,
        body: SizedBox(
          height: 380,
          child: DsDataGrid<AuditLogEntity>(
            items: logs,
            columns: [
              DsColumn(
                title: 'التاريخ والوقت',
                flex: 2,
                cellBuilder: (l) => Text(
                  AppFormatters.formatDateTime(l.timestamp),
                  style: AppTypography.tabularNumber,
                ),
              ),
              DsColumn(
                title: 'المستخدم',
                flex: 2,
                cellBuilder: (l) => Text('${l.userCode} - ${l.userName}'),
              ),
              DsColumn(
                title: 'الشاشة / الوحدة',
                flex: 2,
                cellBuilder: (l) => Text(l.module),
              ),
              DsColumn(
                title: 'نوع الحركة',
                flex: 2,
                cellBuilder: (l) => DsStatusBadge(
                  label: l.action,
                  type: l.action.contains('حذف')
                      ? DsBadgeType.danger
                      : DsBadgeType.info,
                ),
              ),
              DsColumn(
                title: 'التفاصيل',
                flex: 4,
                cellBuilder: (l) => Text(l.details),
              ),
            ],
          ),
        ),
        footerActions: [
          DsButton(
            label: 'إغلاق',
            variant: DsButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellCubit, AppShellState>(
      builder: (context, state) {
        final cubit = context.read<AppShellCubit>();
        final now = DateTime.now();

        return Scaffold(
          body: Row(
            children: [
              // Right-Hand Sidebar (in Arabic RTL, first child in Row is on the RIGHT!)
              Container(
                width: 250,
                color: AppColors.sidebarBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.sidebarSurface,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.sidebarActive,
                              borderRadius: AppRadius.brSm,
                            ),
                            child: const Icon(
                              Icons.warehouse_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KANZA GROUP',
                                  style: AppTypography.h3.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  'نظام الشحن والتوزيع والتحصيلات',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.sidebarTextMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation Items (Matching exact order & highlights of Legacy Main Menu)
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.sm,
                        ),
                        children: [
                          _NavTile(
                            tab: AppNavTab.dashboard,
                            selectedTab: state.selectedTab,
                            icon: Icons.dashboard_rounded,
                            onTap: () => cubit.selectTab(AppNavTab.dashboard),
                          ),
                          const _NavSectionDivider('العمليات والفواتير والتقارير'),
                          _NavTile(
                            tab: AppNavTab.invoices,
                            selectedTab: state.selectedTab,
                            icon: Icons.receipt_long_rounded,
                            badgeColor: AppColors.secondary,
                            onTap: () => cubit.selectTab(AppNavTab.invoices),
                          ),
                          _NavTile(
                            tab: AppNavTab.installments,
                            selectedTab: state.selectedTab,
                            icon: Icons.payments_rounded,
                            badgeColor: AppColors.secondary,
                            onTap: () =>
                                cubit.selectTab(AppNavTab.installments),
                          ),
                          _NavTile(
                            tab: AppNavTab.reports,
                            selectedTab: state.selectedTab,
                            icon: Icons.assessment_rounded,
                            badgeColor: AppColors.reportGold,
                            onTap: () => cubit.selectTab(AppNavTab.reports),
                          ),
                          const _NavSectionDivider('البيانات الأساسية'),
                          _NavTile(
                            tab: AppNavTab.companies,
                            selectedTab: state.selectedTab,
                            icon: Icons.business_rounded,
                            onTap: () => cubit.selectTab(AppNavTab.companies),
                          ),
                          _NavTile(
                            tab: AppNavTab.bankAccounts,
                            selectedTab: state.selectedTab,
                            icon: Icons.account_balance_rounded,
                            onTap: () =>
                                cubit.selectTab(AppNavTab.bankAccounts),
                          ),
                          _NavTile(
                            tab: AppNavTab.customers,
                            selectedTab: state.selectedTab,
                            icon: Icons.groups_rounded,
                            onTap: () => cubit.selectTab(AppNavTab.customers),
                          ),
                          _NavTile(
                            tab: AppNavTab.salespeople,
                            selectedTab: state.selectedTab,
                            icon: Icons.badge_rounded,
                            onTap: () => cubit.selectTab(AppNavTab.salespeople),
                          ),
                          _NavTile(
                            tab: AppNavTab.shippingReps,
                            selectedTab: state.selectedTab,
                            icon: Icons.local_shipping_rounded,
                            onTap: () =>
                                cubit.selectTab(AppNavTab.shippingReps),
                          ),
                          _NavTile(
                            tab: AppNavTab.collectors,
                            selectedTab: state.selectedTab,
                            icon: Icons.support_agent_rounded,
                            onTap: () => cubit.selectTab(AppNavTab.collectors),
                          ),
                          _NavTile(
                            tab: AppNavTab.products,
                            selectedTab: state.selectedTab,
                            icon: Icons.inventory_2_rounded,
                            onTap: () => cubit.selectTab(AppNavTab.products),
                          ),
                          const _NavSectionDivider('إعدادات وأكواد النظام'),
                          _NavTile(
                            tab: AppNavTab.systemCodes,
                            selectedTab: state.selectedTab,
                            icon: Icons.tune_rounded,
                            badgeColor: AppColors.danger,
                            onTap: () => cubit.selectTab(AppNavTab.systemCodes),
                          ),
                        ],
                      ),
                    ),

                    // Bottom System Utilities (تغيير المستخدم | Folder_For_Excel | LogViewer)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.sidebarSurface,
                        border: Border(
                          top: BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Current User Session Box (002 - محمد أسعد | الأحد | 08/11/2026)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.sidebarBg,
                              borderRadius: AppRadius.brSm,
                              border: Border.all(
                                color: const Color(0xFF334155),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      state.currentUserName,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: AppRadius.brXs,
                                      ),
                                      child: Text(
                                        state.currentUserCode,
                                        style: AppTypography.tabularNumber
                                            .copyWith(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppFormatters.arabicDayName(now),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.sidebarTextMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      AppFormatters.formatDate(now),
                                      style: AppTypography.tabularNumber
                                          .copyWith(
                                        color: AppColors.primaryLight,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Expanded(
                                child: DsButton(
                                  label: 'تغيير المستخدم',
                                  isCompact: true,
                                  variant: DsButtonVariant.secondary,
                                  onPressed: () =>
                                      _showSwitchUserModal(context, state),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: DsButton(
                                  label: 'LogViewer',
                                  isCompact: true,
                                  variant: DsButtonVariant.secondary,
                                  onPressed: () =>
                                      _showLogViewerModal(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          DsButton(
                            label: 'Folder_For_Excel (مجلد التصدير)',
                            isCompact: true,
                            icon: Icons.folder_open_rounded,
                            variant: DsButtonVariant.excel,
                            onPressed: () async {
                              final dir =
                                  await ExportService.getExportDirectory();
                              await ExportService.openExportFolder();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'مسار مجلد ملفات الإكسيل: ${dir.path}',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top System Status Bar ("المستخدم الحالي للنظام هو 002 محمد أسعد")
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          bottom: BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'المستخدم الحالي للنظام هو  ${state.currentUserCode}  ${state.currentUserName}',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '--- نظام إدارة الشحن والتوزيع والتحصيلات ---',
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (state.selectedTab != AppNavTab.dashboard)
                            InkWell(
                              onTap: () =>
                                  cubit.selectTab(AppNavTab.dashboard),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'عودة للشاشة الرئيسية (ESC)',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.home_outlined,
                                    size: 16,
                                    color: AppColors.danger,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Active Module View
                    Expanded(
                      child: _buildActiveView(state.selectedTab),
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

  Widget _buildActiveView(AppNavTab tab) {
    switch (tab) {
      case AppNavTab.dashboard:
        return const DashboardView();
      case AppNavTab.invoices:
        return const InvoicesView();
      case AppNavTab.installments:
        return const InstallmentsView();
      case AppNavTab.reports:
        return const ReportsView();
      case AppNavTab.companies:
        return const CompaniesView();
      case AppNavTab.bankAccounts:
        return const BankAccountsView();
      case AppNavTab.customers:
        return const CustomersView();
      case AppNavTab.salespeople:
        return const StaffView(role: StaffRole.salesperson);
      case AppNavTab.shippingReps:
        return const StaffView(role: StaffRole.shippingRep);
      case AppNavTab.collectors:
        return const StaffView(role: StaffRole.collectorFollower);
      case AppNavTab.products:
        return const ProductsView();
      case AppNavTab.systemCodes:
        return const SystemCodesView();
    }
  }
}

class _NavSectionDivider extends StatelessWidget {
  final String label;

  const _NavSectionDivider(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: AppSpacing.sm,
        left: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: 4,
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.sidebarTextMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final AppNavTab tab;
  final AppNavTab selectedTab;
  final IconData icon;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.tab,
    required this.selectedTab,
    required this.icon,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selectedTab;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: isSelected ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: AppRadius.brSm,
        child: InkWell(
          borderRadius: AppRadius.brSm,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 9,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (badgeColor ?? AppColors.sidebarTextMuted),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    tab.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.sidebarText,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeColor != null && !isSelected)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
