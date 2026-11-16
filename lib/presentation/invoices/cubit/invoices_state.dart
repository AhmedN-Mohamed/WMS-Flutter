import 'package:equatable/equatable.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/collection_entity.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/installment_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/staff_entity.dart';

class InvoicesState extends Equatable {
  final RequestStatus status;
  final List<InvoiceEntity> allInvoices;
  final InvoiceEntity? selectedInvoice;
  final List<InstallmentEntity> allInstallments;
  final List<CollectionEntity> allCollections;

  // Multi-Search & Filter Controls (matching فواتير الشركات)
  final String companyOrNotesSearch; // شركة - ملاحظات
  final String customerSearch; // عميل
  final String salespersonOrNumberSearch; // بائع - رقم فاتورة
  final bool onlyWithoutInstallments; // فواتير بدون دفعات
  final String sortColumn;
  final bool sortAscending;

  // Lookups for Invoice Form
  final List<CompanyEntity> companies;
  final List<CustomerEntity> customers;
  final List<StaffEntity> salespeople;
  final List<StaffEntity> shippingReps;
  final List<ProductEntity> products;
  final List<String> currencies;

  final String? actionMessage;

  const InvoicesState({
    this.status = RequestStatus.initial,
    this.allInvoices = const [],
    this.selectedInvoice,
    this.allInstallments = const [],
    this.allCollections = const [],
    this.companyOrNotesSearch = '',
    this.customerSearch = '',
    this.salespersonOrNumberSearch = '',
    this.onlyWithoutInstallments = false,
    this.sortColumn = 'invoiceDate',
    this.sortAscending = false,
    this.companies = const [],
    this.customers = const [],
    this.salespeople = const [],
    this.shippingReps = const [],
    this.products = const [],
    this.currencies = const [],
    this.actionMessage,
  });

  double scheduledAmountForInvoice(String invoiceId) {
    return allInstallments
        .where((i) => i.invoiceId == invoiceId)
        .fold<double>(0.0, (sum, i) => sum + i.amount);
  }

  double unscheduledAmountForInvoice(InvoiceEntity invoice) {
    return (invoice.totalAmount - scheduledAmountForInvoice(invoice.id))
        .clamp(0.0, double.infinity);
  }

  double collectedAmountForInvoice(String invoiceId) {
    return allInstallments
        .where((i) => i.invoiceId == invoiceId)
        .fold<double>(0.0, (sum, i) => sum + i.collectedAmount);
  }

  double remainingDebtForInvoice(InvoiceEntity invoice) {
    return (invoice.totalAmount - collectedAmountForInvoice(invoice.id))
        .clamp(0.0, double.infinity);
  }

  List<InvoiceEntity> get filteredInvoices {
    final qComp = companyOrNotesSearch.trim().toLowerCase();
    final qCust = customerSearch.trim().toLowerCase();
    final qSales = salespersonOrNumberSearch.trim().toLowerCase();

    final filtered = allInvoices.where((inv) {
      if (onlyWithoutInstallments) {
        if (unscheduledAmountForInvoice(inv) <= 0.01) return false;
      }
      final matchComp = qComp.isEmpty ||
          inv.companyName.toLowerCase().contains(qComp) ||
          inv.notes.toLowerCase().contains(qComp);
      final matchCust = qCust.isEmpty ||
          inv.customerName.toLowerCase().contains(qCust) ||
          inv.customerMobile1.toLowerCase().contains(qCust) ||
          inv.customerMobile2.toLowerCase().contains(qCust);
      final matchSales = qSales.isEmpty ||
          inv.salespersonName.toLowerCase().contains(qSales) ||
          inv.invoiceNumber.toLowerCase().contains(qSales);
      return matchComp && matchCust && matchSales;
    }).toList();

    filtered.sort((a, b) {
      int cmp;
      switch (sortColumn) {
        case 'companyName':
          cmp = a.companyName.compareTo(b.companyName);
          break;
        case 'customerName':
          cmp = a.customerName.compareTo(b.customerName);
          break;
        case 'salespersonName':
          cmp = a.salespersonName.compareTo(b.salespersonName);
          break;
        case 'invoiceNumber':
          cmp = a.invoiceNumber.compareTo(b.invoiceNumber);
          break;
        case 'totalAmount':
          cmp = a.totalAmount.compareTo(b.totalAmount);
          break;
        case 'invoiceDate':
        default:
          cmp = a.invoiceDate.compareTo(b.invoiceDate);
          break;
      }
      return sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  double get totalInvoicesValue =>
      allInvoices.fold<double>(0.0, (s, e) => s + e.totalAmount);

  double get totalCollectedValue =>
      allInstallments.fold<double>(0.0, (s, e) => s + e.collectedAmount);

  double get totalRemainingDebt =>
      (totalInvoicesValue - totalCollectedValue).clamp(0.0, double.infinity);

  InvoicesState copyWith({
    RequestStatus? status,
    List<InvoiceEntity>? allInvoices,
    InvoiceEntity? selectedInvoice,
    bool clearSelectedInvoice = false,
    List<InstallmentEntity>? allInstallments,
    List<CollectionEntity>? allCollections,
    String? companyOrNotesSearch,
    String? customerSearch,
    String? salespersonOrNumberSearch,
    bool? onlyWithoutInstallments,
    String? sortColumn,
    bool? sortAscending,
    List<CompanyEntity>? companies,
    List<CustomerEntity>? customers,
    List<StaffEntity>? salespeople,
    List<StaffEntity>? shippingReps,
    List<ProductEntity>? products,
    List<String>? currencies,
    String? actionMessage,
  }) {
    return InvoicesState(
      status: status ?? this.status,
      allInvoices: allInvoices ?? this.allInvoices,
      selectedInvoice: clearSelectedInvoice
          ? null
          : (selectedInvoice ?? this.selectedInvoice),
      allInstallments: allInstallments ?? this.allInstallments,
      allCollections: allCollections ?? this.allCollections,
      companyOrNotesSearch: companyOrNotesSearch ?? this.companyOrNotesSearch,
      customerSearch: customerSearch ?? this.customerSearch,
      salespersonOrNumberSearch:
          salespersonOrNumberSearch ?? this.salespersonOrNumberSearch,
      onlyWithoutInstallments:
          onlyWithoutInstallments ?? this.onlyWithoutInstallments,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      companies: companies ?? this.companies,
      customers: customers ?? this.customers,
      salespeople: salespeople ?? this.salespeople,
      shippingReps: shippingReps ?? this.shippingReps,
      products: products ?? this.products,
      currencies: currencies ?? this.currencies,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allInvoices,
        selectedInvoice,
        allInstallments,
        allCollections,
        companyOrNotesSearch,
        customerSearch,
        salespersonOrNumberSearch,
        onlyWithoutInstallments,
        sortColumn,
        sortAscending,
        companies,
        customers,
        salespeople,
        shippingReps,
        products,
        currencies,
        actionMessage,
      ];
}
