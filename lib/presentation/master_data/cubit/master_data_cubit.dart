import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/staff_entity.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../../../domain/repositories/wms_repository.dart';
import 'master_data_state.dart';

class MasterDataCubit extends Cubit<MasterDataState> {
  final WmsRepository _repository;

  MasterDataCubit(this._repository) : super(const MasterDataState());

  void loadAllMasterData({String? actionMessage}) {
    emit(
      state.copyWith(
        status: RequestStatus.success,
        companies: _repository.getCompanies(),
        bankAccounts: _repository.getBankAccounts(),
        customers: _repository.getCustomers(),
        staffList: _repository.getStaff(),
        products: _repository.getProducts(),
        activities: _repository
            .getSystemCodes(SystemCodeCategory.companyActivities)
            .map((e) => e.name)
            .toList(),
        banks: _repository
            .getSystemCodes(SystemCodeCategory.banks)
            .map((e) => e.name)
            .toList(),
        currencies: _repository
            .getSystemCodes(SystemCodeCategory.currencies)
            .map((e) => e.name)
            .toList(),
        customerTypes: _repository
            .getSystemCodes(SystemCodeCategory.customerTypes)
            .map((e) => e.name)
            .toList(),
        ratings: _repository
            .getSystemCodes(SystemCodeCategory.ratings)
            .map((e) => e.name)
            .toList(),
        units: _repository
            .getSystemCodes(SystemCodeCategory.productUnits)
            .map((e) => e.name)
            .toList(),
        actionMessage: actionMessage,
      ),
    );
  }

  // --- Companies ---
  void selectCompany(CompanyEntity? company) {
    emit(
      state.copyWith(
        selectedCompany: company,
        clearSelectedCompany: company == null,
      ),
    );
  }

  void toggleInlineCompanyBanks(bool show) {
    emit(state.copyWith(showInlineCompanyBanks: show));
  }

  void updateCompanyFilters({String? search, String? activity}) {
    emit(
      state.copyWith(
        companySearch: search ?? state.companySearch,
        companyActivityFilter: activity ?? state.companyActivityFilter,
      ),
    );
  }

  Future<void> saveCompany({
    String? id,
    required String code,
    required String name,
    required String activity,
    required String mobile1,
    required String mobile2,
    String pdfPath = '',
  }) async {
    if (name.trim().isEmpty) return;
    final entity = CompanyEntity(
      id: id ?? 'comp_${DateTime.now().microsecondsSinceEpoch}',
      code: code.trim().isEmpty
          ? '${state.companies.length + 1}'.padLeft(3, '0')
          : code.trim(),
      name: name.trim(),
      activity: activity.trim(),
      mobile1: mobile1.trim(),
      mobile2: mobile2.trim(),
      pdfPath: pdfPath.trim(),
    );
    await _repository.saveCompany(entity);
    loadAllMasterData(actionMessage: 'تم حفظ بيانات الشركة "${entity.name}"');
    selectCompany(entity);
  }

  Future<void> deleteSelectedCompany() async {
    final c = state.selectedCompany;
    if (c == null) return;
    await _repository.deleteCompany(c.id);
    emit(state.copyWith(clearSelectedCompany: true));
    loadAllMasterData(actionMessage: 'تم حذف الشركة "${c.name}"');
  }

  // --- Bank Accounts ---
  void selectBankAccount(CompanyBankAccountEntity? account) {
    emit(
      state.copyWith(
        selectedBankAccount: account,
        clearSelectedBankAccount: account == null,
      ),
    );
  }

  void updateBankAccountFilters({String? accountCompany, String? bankCurrency}) {
    emit(
      state.copyWith(
        bankAccountSearch: accountCompany ?? state.bankAccountSearch,
        bankNameCurrencySearch: bankCurrency ?? state.bankNameCurrencySearch,
      ),
    );
  }

  Future<void> saveBankAccount({
    String? id,
    required String accountNumber,
    required CompanyEntity company,
    required String bankName,
    required String currency,
  }) async {
    if (accountNumber.trim().isEmpty) return;
    final entity = CompanyBankAccountEntity(
      id: id ?? 'ba_${DateTime.now().microsecondsSinceEpoch}',
      companyId: company.id,
      companyName: company.name,
      accountNumber: accountNumber.trim(),
      bankName: bankName,
      currency: currency,
    );
    await _repository.saveBankAccount(entity);
    loadAllMasterData(
      actionMessage: 'تم حفظ الحساب البنكي ${entity.accountNumber}',
    );
    selectBankAccount(entity);
  }

  Future<void> deleteSelectedBankAccount() async {
    final b = state.selectedBankAccount;
    if (b == null) return;
    await _repository.deleteBankAccount(b.id);
    emit(state.copyWith(clearSelectedBankAccount: true));
    loadAllMasterData(actionMessage: 'تم حذف الحساب البنكي ${b.accountNumber}');
  }

  // --- Customers ---
  void selectCustomer(CustomerEntity? customer) {
    emit(
      state.copyWith(
        selectedCustomer: customer,
        clearSelectedCustomer: customer == null,
      ),
    );
  }

  void updateCustomerFilters({String? nameMobile, String? typeRating}) {
    emit(
      state.copyWith(
        customerSearch: nameMobile ?? state.customerSearch,
        customerTypeRatingSearch: typeRating ?? state.customerTypeRatingSearch,
      ),
    );
  }

  Future<void> saveCustomer({
    String? id,
    required String name,
    required String mobile1,
    required String mobile2,
    required String customerType,
    required String rating,
    required String locationUrl,
    String notes = '',
    String pdfPath = '',
  }) async {
    if (name.trim().isEmpty) return;
    final entity = CustomerEntity(
      id: id ?? 'cust_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      mobile1: mobile1.trim(),
      mobile2: mobile2.trim(),
      customerType: customerType,
      rating: rating,
      locationUrl: locationUrl.trim(),
      notes: notes.trim(),
      pdfPath: pdfPath.trim(),
    );
    await _repository.saveCustomer(entity);
    loadAllMasterData(actionMessage: 'تم حفظ بيانات العميل "${entity.name}"');
    selectCustomer(entity);
  }

  Future<void> deleteSelectedCustomer() async {
    final c = state.selectedCustomer;
    if (c == null) return;
    await _repository.deleteCustomer(c.id);
    emit(state.copyWith(clearSelectedCustomer: true));
    loadAllMasterData(actionMessage: 'تم حذف العميل "${c.name}"');
  }

  // --- Staff (Salespeople, Shipping Reps, Collectors/Followers) ---
  void selectStaff(StaffEntity? staff) {
    emit(
      state.copyWith(
        selectedStaff: staff,
        clearSelectedStaff: staff == null,
      ),
    );
  }

  void updateStaffFilters({String? nameMobile, String? rating}) {
    emit(
      state.copyWith(
        staffSearch: nameMobile ?? state.staffSearch,
        staffRatingSearch: rating ?? state.staffRatingSearch,
      ),
    );
  }

  Future<void> saveStaff({
    String? id,
    required StaffRole role,
    required String name,
    required String mobile1,
    required String mobile2,
    required String rating,
    String pdfPath = '',
  }) async {
    if (name.trim().isEmpty) return;
    final entity = StaffEntity(
      id: id ?? 'st_${DateTime.now().microsecondsSinceEpoch}',
      role: role,
      name: name.trim(),
      mobile1: mobile1.trim(),
      mobile2: mobile2.trim(),
      rating: rating,
      pdfPath: pdfPath.trim(),
    );
    await _repository.saveStaff(entity);
    loadAllMasterData(actionMessage: 'تم حفظ "${entity.name}" في ${role.screenTitle}');
    selectStaff(entity);
  }

  Future<void> deleteSelectedStaff() async {
    final s = state.selectedStaff;
    if (s == null) return;
    await _repository.deleteStaff(s.id);
    emit(state.copyWith(clearSelectedStaff: true));
    loadAllMasterData(actionMessage: 'تم حذف "${s.name}"');
  }

  // --- Products ---
  void selectProduct(ProductEntity? product) {
    emit(
      state.copyWith(
        selectedProduct: product,
        clearSelectedProduct: product == null,
      ),
    );
  }

  void updateProductSearch(String query) {
    emit(state.copyWith(productSearch: query));
  }

  Future<void> saveProduct({
    String? id,
    required String name,
    required String unit,
    required double guidingPrice,
    String notes = '',
  }) async {
    if (name.trim().isEmpty) return;
    final entity = ProductEntity(
      id: id ?? 'prod_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      unit: unit,
      guidingPrice: guidingPrice,
      notes: notes.trim(),
    );
    await _repository.saveProduct(entity);
    loadAllMasterData(actionMessage: 'تم حفظ الصنف "${entity.name}"');
    selectProduct(entity);
  }

  Future<void> deleteSelectedProduct() async {
    final p = state.selectedProduct;
    if (p == null) return;
    await _repository.deleteProduct(p.id);
    emit(state.copyWith(clearSelectedProduct: true));
    loadAllMasterData(actionMessage: 'تم حذف الصنف "${p.name}"');
  }
}
