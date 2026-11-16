import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/staff_entity.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../../../domain/repositories/wms_repository.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final WmsRepository _repository;

  InvoicesCubit(this._repository) : super(const InvoicesState());

  void loadInvoices({String? actionMessage}) {
    final invoices = _repository.getInvoices();
    final currentSelected = state.selectedInvoice;
    final updatedSelected = currentSelected != null
        ? invoices.where((e) => e.id == currentSelected.id).firstOrNull
        : invoices.firstOrNull;

    emit(
      state.copyWith(
        status: RequestStatus.success,
        allInvoices: invoices,
        selectedInvoice: updatedSelected,
        clearSelectedInvoice: updatedSelected == null,
        allInstallments: _repository.getInstallments(),
        allCollections: _repository.getCollections(),
        companies: _repository.getCompanies(),
        customers: _repository.getCustomers(),
        salespeople: _repository.getStaff(StaffRole.salesperson),
        shippingReps: _repository.getStaff(StaffRole.shippingRep),
        products: _repository.getProducts(),
        currencies: _repository
            .getSystemCodes(SystemCodeCategory.currencies)
            .map((e) => e.name)
            .toList(),
        actionMessage: actionMessage,
      ),
    );
  }

  void selectInvoice(InvoiceEntity? invoice) {
    emit(
      state.copyWith(
        selectedInvoice: invoice,
        clearSelectedInvoice: invoice == null,
      ),
    );
  }

  void updateFilters({
    String? companyOrNotes,
    String? customer,
    String? salespersonOrNumber,
    bool? onlyWithoutInstallments,
  }) {
    emit(
      state.copyWith(
        companyOrNotesSearch: companyOrNotes ?? state.companyOrNotesSearch,
        customerSearch: customer ?? state.customerSearch,
        salespersonOrNumberSearch:
            salespersonOrNumber ?? state.salespersonOrNumberSearch,
        onlyWithoutInstallments:
            onlyWithoutInstallments ?? state.onlyWithoutInstallments,
      ),
    );
  }

  void toggleSort(String column) {
    if (state.sortColumn == column) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortColumn: column, sortAscending: true));
    }
  }

  Future<void> saveInvoice({
    String? id,
    required String invoiceNumber,
    required DateTime invoiceDate,
    required CompanyEntity company,
    required CustomerEntity customer,
    required StaffEntity salesperson,
    String shippingRepName = '',
    required double totalAmount,
    required String currency,
    String notes = '',
    String customerNotes = '',
    String pdfPath = '',
    List<InvoiceItemEntity> items = const [],
  }) async {
    final entity = InvoiceEntity(
      id: id ?? 'inv_${DateTime.now().microsecondsSinceEpoch}',
      invoiceNumber: invoiceNumber.trim(),
      invoiceDate: invoiceDate,
      companyId: company.id,
      companyName: company.name,
      customerId: customer.id,
      customerName: customer.name,
      customerMobile1: customer.mobile1,
      customerMobile2: customer.mobile2,
      salespersonId: salesperson.id,
      salespersonName: salesperson.name,
      shippingRepName: shippingRepName,
      totalAmount: totalAmount,
      currency: currency,
      notes: notes.trim(),
      customerNotes: customerNotes.trim(),
      pdfPath: pdfPath.trim(),
      items: items,
    );
    await _repository.saveInvoice(entity);
    loadInvoices(actionMessage: 'تم حفظ الفاتورة رقم ${entity.invoiceNumber}');
    selectInvoice(entity);
  }

  Future<void> updateCustomerMobilesAndNotesFromInvoice({
    required String customerId,
    required String mobile1,
    required String mobile2,
    required String customerNotes,
  }) async {
    final cust = state.customers.where((c) => c.id == customerId).firstOrNull;
    if (cust == null) return;
    final updated = cust.copyWith(
      mobile1: mobile1.trim(),
      mobile2: mobile2.trim(),
      notes: customerNotes.trim(),
    );
    await _repository.saveCustomer(updated);
    loadInvoices(actionMessage: 'تم تحديث موبايلات وملاحظات العميل "${cust.name}"');
  }

  Future<void> deleteSelectedInvoice() async {
    final inv = state.selectedInvoice;
    if (inv == null) return;
    await _repository.deleteInvoice(inv.id);
    emit(state.copyWith(clearSelectedInvoice: true));
    loadInvoices(actionMessage: 'تم حذف الفاتورة رقم ${inv.invoiceNumber}');
  }
}
