import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/installment_entity.dart';
import '../../installments/cubit/installments_cubit.dart';
import '../../invoices/cubit/invoices_cubit.dart';
import '../../invoices/cubit/invoices_state.dart';
import '../../master_data/cubit/master_data_cubit.dart';
import '../../shell/cubit/app_shell_cubit.dart';
import '../../shell/cubit/app_shell_state.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, invState) {
        final masterState = context.watch<MasterDataCubit>().state;
        final shellCubit = context.read<AppShellCubit>();

        final overdueInstallments = invState.allInstallments
            .where((i) => !i.isFullyPaid)
            .toList();

        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Banner (Kanza Group Identity)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF134E4A),
                      Color(0xFF0F766E),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: AppRadius.brLg,
                  boxShadow: AppShadows.md,
                ),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: AppRadius.brMd,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.hub_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نظام إدارة الشحن والتوزيع والتحصيلات — KANZA GROUP',
                                style: AppTypography.h1.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'إدارة الفواتير وجدولة الدفعات والمتابعة والتحصيلات النقدية والبنكية لجميع شركات المجموعة',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        DsButton(
                          label: 'تسجيل فاتورة جديدة',
                          icon: Icons.add_card_rounded,
                          variant: DsButtonVariant.warning,
                          onPressed: () =>
                              shellCubit.selectTab(AppNavTab.invoices),
                        ),
                        DsButton(
                          label: 'تقارير النظام',
                          icon: Icons.assessment_rounded,
                          variant: DsButtonVariant.secondary,
                          onPressed: () =>
                              shellCubit.selectTab(AppNavTab.reports),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Top Financial KPIs
              Row(
                children: [
                  Expanded(
                    child: DsKpiCard(
                      title: 'إجمالي فواتير الشركات (${invState.allInvoices.length})',
                      value: AppFormatters.formatAmount(
                        invState.totalInvoicesValue,
                        currency: 'ج.م',
                      ),
                      subtitle: 'اضغط لعرض وإدارة فواتير الشركات',
                      icon: Icons.receipt_long_rounded,
                      accentColor: AppColors.secondary,
                      onTap: () => shellCubit.selectTab(AppNavTab.invoices),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DsKpiCard(
                      title: 'إجمالي التحصيلات الفعلية',
                      value: AppFormatters.formatAmount(
                        invState.totalCollectedValue,
                        currency: 'ج.م',
                      ),
                      subtitle:
                          '${invState.allCollections.length} حركة تحصيل مسجلة',
                      icon: Icons.payments_rounded,
                      accentColor: AppColors.success,
                      onTap: () =>
                          shellCubit.selectTab(AppNavTab.installments),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DsKpiCard(
                      title: 'إجمالي المديونية المتبقية للتحصيل',
                      value: AppFormatters.formatAmount(
                        invState.totalRemainingDebt,
                        currency: 'ج.م',
                      ),
                      subtitle:
                          '${overdueInstallments.length} دفعة قيد المتابعة والتحصيل',
                      icon: Icons.account_balance_wallet_rounded,
                      accentColor: AppColors.danger,
                      onTap: () =>
                          shellCubit.selectTab(AppNavTab.installments),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DsKpiCard(
                      title: 'العملاء والشركات المسجلة',
                      value: '${masterState.customers.length} عميل',
                      subtitle:
                          '${masterState.companies.length} شركات فرعية • ${masterState.bankAccounts.length} حسابات بنكية',
                      icon: Icons.groups_rounded,
                      accentColor: AppColors.primary,
                      onTap: () => shellCubit.selectTab(AppNavTab.customers),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Quick Navigation Grid (All 11 Screens from Legacy Main Menu)
              Text(
                'وحدات وشاشات النظام الرئيسية',
                style: AppTypography.h2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _QuickModuleCard(
                    title: 'فواتير الشركات',
                    subtitle: 'إصدار الفواتير ومتابعة مديونية العملاء',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.secondary,
                    onTap: () => shellCubit.selectTab(AppNavTab.invoices),
                  ),
                  _QuickModuleCard(
                    title: 'دفعات للتحصيل والمتابعة',
                    subtitle: 'جدولة الدفعات وتسجيل التحصيلات الفعلية',
                    icon: Icons.event_repeat_rounded,
                    color: AppColors.primary,
                    onTap: () => shellCubit.selectTab(AppNavTab.installments),
                  ),
                  _QuickModuleCard(
                    title: 'تقارير النظام',
                    subtitle: 'تقارير الفواتير والدفعات والمتابعات والإكسيل',
                    icon: Icons.assessment_rounded,
                    color: AppColors.reportGold,
                    onTap: () => shellCubit.selectTab(AppNavTab.reports),
                  ),
                  _QuickModuleCard(
                    title: 'بيانات الشركات',
                    subtitle: 'الشركات الفرعية وأنشطتها وحساباتها',
                    icon: Icons.business_rounded,
                    color: AppColors.primary,
                    onTap: () => shellCubit.selectTab(AppNavTab.companies),
                  ),
                  _QuickModuleCard(
                    title: 'الحسابات البنكية للشركات',
                    subtitle: 'أرقام الحسابات والبنوك والعملات',
                    icon: Icons.account_balance_rounded,
                    color: AppColors.secondary,
                    onTap: () => shellCubit.selectTab(AppNavTab.bankAccounts),
                  ),
                  _QuickModuleCard(
                    title: 'بيانات العملاء',
                    subtitle: 'قاعدة بيانات العملاء والمواقع والتقييمات',
                    icon: Icons.groups_rounded,
                    color: AppColors.success,
                    onTap: () => shellCubit.selectTab(AppNavTab.customers),
                  ),
                  _QuickModuleCard(
                    title: 'بيانات البائعين',
                    subtitle: 'سجل مسئولي المبيعات والتقييمات',
                    icon: Icons.badge_rounded,
                    color: AppColors.info,
                    onTap: () => shellCubit.selectTab(AppNavTab.salespeople),
                  ),
                  _QuickModuleCard(
                    title: 'مندوبين الشحن',
                    subtitle: 'بيانات مندوبي الشحن والتوزيع',
                    icon: Icons.local_shipping_rounded,
                    color: AppColors.warning,
                    onTap: () => shellCubit.selectTab(AppNavTab.shippingReps),
                  ),
                  _QuickModuleCard(
                    title: 'المتابعين والمحصلين',
                    subtitle: 'فريق المتابعة والتحصيل الميداني',
                    icon: Icons.support_agent_rounded,
                    color: AppColors.primary,
                    onTap: () => shellCubit.selectTab(AppNavTab.collectors),
                  ),
                  _QuickModuleCard(
                    title: 'المنتجات والأصناف',
                    subtitle: 'الأصناف والأسعار الاسترشادية المرنة',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.secondary,
                    onTap: () => shellCubit.selectTab(AppNavTab.products),
                  ),
                  _QuickModuleCard(
                    title: 'أكواد النظام',
                    subtitle: 'إدارة القوائم والتصنيفات المنسدلة (12 جدول)',
                    icon: Icons.tune_rounded,
                    color: AppColors.danger,
                    onTap: () => shellCubit.selectTab(AppNavTab.systemCodes),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. Active Installments & Follow-up Queue Table
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(
                    'أحدث الدفعات المستحقة وقائمة المتابعة السريعة',
                    style: AppTypography.h2,
                  ),
                  DsButton(
                    label: 'فتح شاشة الدفعات والتحصيل الكاملة',
                    isCompact: true,
                    icon: Icons.arrow_back_rounded,
                    variant: DsButtonVariant.secondary,
                    onPressed: () =>
                        shellCubit.selectTab(AppNavTab.installments),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 270,
                child: DsDataGrid<InstallmentEntity>(
                  items: overdueInstallments,
                  emptyMessage: 'جميع الدفعات مسددة بالكامل!',
                  onRowTap: (inst) {
                    context
                        .read<InstallmentsCubit>()
                        .loadData(focusInvoiceId: inst.invoiceId);
                    shellCubit.selectTab(
                      AppNavTab.installments,
                      invoiceId: inst.invoiceId,
                    );
                  },
                  columns: [
                    DsColumn(
                      title: 'ر الفاتورة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        i.invoiceNumber,
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'الشركة',
                      flex: 3,
                      cellBuilder: (i) => Text(i.companyName),
                    ),
                    DsColumn(
                      title: 'العميل',
                      flex: 3,
                      cellBuilder: (i) => Text(i.customerName),
                    ),
                    DsColumn(
                      title: 'المتابع',
                      flex: 2,
                      cellBuilder: (i) => Text(i.followerName),
                    ),
                    DsColumn(
                      title: 'قيمة الدفعة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatAmount(i.amount),
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'الباقي للمتابعة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        AppFormatters.formatAmount(i.remainingAmount),
                        style: AppTypography.tabularNumber
                            .copyWith(color: AppColors.danger),
                      ),
                    ),
                    DsColumn(
                      title: 'ت الدفعة / ت المتابعة',
                      flex: 2,
                      cellBuilder: (i) => Text(
                        '${AppFormatters.formatDate(i.dueDate)} • ${AppFormatters.formatDate(i.followUpDate)}',
                        style: AppTypography.tabularNumber,
                      ),
                    ),
                    DsColumn(
                      title: 'الأولوية',
                      flex: 2,
                      cellBuilder: (i) => DsStatusBadge(
                        label: i.priority,
                        type: i.priority == 'عاجل جداً'
                            ? DsBadgeType.danger
                            : DsBadgeType.info,
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

class _QuickModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 255,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brMd,
        child: DsCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brSm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
