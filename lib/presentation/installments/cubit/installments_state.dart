import 'package:equatable/equatable.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/collection_entity.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/installment_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/staff_entity.dart';

class InstallmentsState extends Equatable {
  final RequestStatus status;
  final List<CompanyEntity> companies;
  final String? selectedCompanyId;
  final String companySearchQuery;
  final String customerInvoiceSearchQuery;

  final List<InvoiceEntity> allInvoices;
  final InvoiceEntity? selectedInvoice;

  final List<InstallmentEntity> allInstallments;
  final InstallmentEntity? selectedInstallment;

  final List<CollectionEntity> allCollections;

  // Lookups
  final List<String> paymentSystems;
  final List<String> priorities;
  final List<String> legalActions;
  final List<String> paymentMethods;
  final List<StaffEntity> followersAndCollectors;

  final String? copiedFollowUpNote;
  final String? actionMessage;

  const InstallmentsState({
    this.status = RequestStatus.initial,
    this.companies = const [],
    this.selectedCompanyId,
    this.companySearchQuery = '',
    this.customerInvoiceSearchQuery = '',
    this.allInvoices = const [],
    this.selectedInvoice,
    this.allInstallments = const [],
    this.selectedInstallment,
    this.allCollections = const [],
    this.paymentSystems = const [],
    this.priorities = const [],
    this.legalActions = const [],
    this.paymentMethods = const [],
    this.followersAndCollectors = const [],
    this.copiedFollowUpNote,
    this.actionMessage,
  });

  List<CompanyEntity> get filteredCompanies {
    final q = companySearchQuery.trim().toLowerCase();
    if (q.isEmpty) return companies;
    return companies.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  /// فواتير تخص الشركة المحددة
  List<InvoiceEntity> get companyInvoices {
    final q = customerInvoiceSearchQuery.trim().toLowerCase();
    return allInvoices.where((inv) {
      final matchCompany =
          selectedCompanyId == null || inv.companyId == selectedCompanyId;
      final matchSearch = q.isEmpty ||
          inv.customerName.toLowerCase().contains(q) ||
          inv.invoiceNumber.toLowerCase().contains(q);
      return matchCompany && matchSearch;
    }).toList();
  }

  /// عرض موقف دفعات للفاتورة المحددة
  List<InstallmentEntity> get invoiceInstallments {
    if (selectedInvoice == null) return const [];
    return allInstallments
        .where((i) => i.invoiceId == selectedInvoice!.id)
        .toList();
  }

  /// اجماليات دفعات الفاتورة
  double get totalScheduledForInvoice =>
      invoiceInstallments.fold<double>(0.0, (s, e) => s + e.amount);

  double get totalCollectedForInvoice =>
      invoiceInstallments.fold<double>(0.0, (s, e) => s + e.collectedAmount);

  double get totalRemainingForInvoice =>
      invoiceInstallments.fold<double>(0.0, (s, e) => s + e.remainingAmount);

  /// قيمة بدون دفعة
  double get unscheduledInvoiceAmount {
    if (selectedInvoice == null) return 0.0;
    return (selectedInvoice!.totalAmount - totalScheduledForInvoice)
        .clamp(0.0, double.infinity);
  }

  /// عرض موقف التحصيلات للدفعة المحددة من الفاتورة
  List<CollectionEntity> get installmentCollections {
    if (selectedInstallment == null) return const [];
    return allCollections
        .where((c) => c.installmentId == selectedInstallment!.id)
        .toList();
  }

  InstallmentsState copyWith({
    RequestStatus? status,
    List<CompanyEntity>? companies,
    String? selectedCompanyId,
    bool clearSelectedCompany = false,
    String? companySearchQuery,
    String? customerInvoiceSearchQuery,
    List<InvoiceEntity>? allInvoices,
    InvoiceEntity? selectedInvoice,
    bool clearSelectedInvoice = false,
    List<InstallmentEntity>? allInstallments,
    InstallmentEntity? selectedInstallment,
    bool clearSelectedInstallment = false,
    List<CollectionEntity>? allCollections,
    List<String>? paymentSystems,
    List<String>? priorities,
    List<String>? legalActions,
    List<String>? paymentMethods,
    List<StaffEntity>? followersAndCollectors,
    String? copiedFollowUpNote,
    String? actionMessage,
  }) {
    return InstallmentsState(
      status: status ?? this.status,
      companies: companies ?? this.companies,
      selectedCompanyId: clearSelectedCompany
          ? null
          : (selectedCompanyId ?? this.selectedCompanyId),
      companySearchQuery: companySearchQuery ?? this.companySearchQuery,
      customerInvoiceSearchQuery:
          customerInvoiceSearchQuery ?? this.customerInvoiceSearchQuery,
      allInvoices: allInvoices ?? this.allInvoices,
      selectedInvoice: clearSelectedInvoice
          ? null
          : (selectedInvoice ?? this.selectedInvoice),
      allInstallments: allInstallments ?? this.allInstallments,
      selectedInstallment: clearSelectedInstallment
          ? null
          : (selectedInstallment ?? this.selectedInstallment),
      allCollections: allCollections ?? this.allCollections,
      paymentSystems: paymentSystems ?? this.paymentSystems,
      priorities: priorities ?? this.priorities,
      legalActions: legalActions ?? this.legalActions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      followersAndCollectors:
          followersAndCollectors ?? this.followersAndCollectors,
      copiedFollowUpNote: copiedFollowUpNote ?? this.copiedFollowUpNote,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        companies,
        selectedCompanyId,
        companySearchQuery,
        customerInvoiceSearchQuery,
        allInvoices,
        selectedInvoice,
        allInstallments,
        selectedInstallment,
        allCollections,
        paymentSystems,
        priorities,
        legalActions,
        paymentMethods,
        followersAndCollectors,
        copiedFollowUpNote,
        actionMessage,
      ];
}
