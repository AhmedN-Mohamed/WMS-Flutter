import 'package:equatable/equatable.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/staff_entity.dart';

class MasterDataState extends Equatable {
  final RequestStatus status;

  // Companies & Bank Accounts
  final List<CompanyEntity> companies;
  final CompanyEntity? selectedCompany;
  final bool showInlineCompanyBanks;
  final String companySearch;
  final String companyActivityFilter;

  final List<CompanyBankAccountEntity> bankAccounts;
  final CompanyBankAccountEntity? selectedBankAccount;
  final String bankAccountSearch;
  final String bankNameCurrencySearch;

  // Customers
  final List<CustomerEntity> customers;
  final CustomerEntity? selectedCustomer;
  final String customerSearch;
  final String customerTypeRatingSearch;

  // Staff (Salespeople, Shipping Reps, Collectors/Followers)
  final List<StaffEntity> staffList;
  final StaffEntity? selectedStaff;
  final String staffSearch;
  final String staffRatingSearch;

  // Products
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final String productSearch;

  // Dynamic Lookups from System Codes
  final List<String> activities;
  final List<String> banks;
  final List<String> currencies;
  final List<String> customerTypes;
  final List<String> ratings;
  final List<String> units;

  final String? actionMessage;

  const MasterDataState({
    this.status = RequestStatus.initial,
    this.companies = const [],
    this.selectedCompany,
    this.showInlineCompanyBanks = false,
    this.companySearch = '',
    this.companyActivityFilter = '',
    this.bankAccounts = const [],
    this.selectedBankAccount,
    this.bankAccountSearch = '',
    this.bankNameCurrencySearch = '',
    this.customers = const [],
    this.selectedCustomer,
    this.customerSearch = '',
    this.customerTypeRatingSearch = '',
    this.staffList = const [],
    this.selectedStaff,
    this.staffSearch = '',
    this.staffRatingSearch = '',
    this.products = const [],
    this.selectedProduct,
    this.productSearch = '',
    this.activities = const [],
    this.banks = const [],
    this.currencies = const [],
    this.customerTypes = const [],
    this.ratings = const [],
    this.units = const [],
    this.actionMessage,
  });

  List<CompanyEntity> get filteredCompanies {
    return companies.where((c) {
      final matchName = companySearch.trim().isEmpty ||
          c.name.toLowerCase().contains(companySearch.trim().toLowerCase()) ||
          c.code.toLowerCase().contains(companySearch.trim().toLowerCase());
      final matchAct = companyActivityFilter.trim().isEmpty ||
          c.activity
              .toLowerCase()
              .contains(companyActivityFilter.trim().toLowerCase());
      return matchName && matchAct;
    }).toList();
  }

  List<CompanyBankAccountEntity> get filteredBankAccounts {
    return bankAccounts.where((b) {
      final q1 = bankAccountSearch.trim().toLowerCase();
      final q2 = bankNameCurrencySearch.trim().toLowerCase();
      final match1 = q1.isEmpty ||
          b.accountNumber.toLowerCase().contains(q1) ||
          b.companyName.toLowerCase().contains(q1);
      final match2 = q2.isEmpty ||
          b.bankName.toLowerCase().contains(q2) ||
          b.currency.toLowerCase().contains(q2);
      return match1 && match2;
    }).toList();
  }

  List<CustomerEntity> get filteredCustomers {
    return customers.where((c) {
      final q1 = customerSearch.trim().toLowerCase();
      final q2 = customerTypeRatingSearch.trim().toLowerCase();
      final match1 = q1.isEmpty ||
          c.name.toLowerCase().contains(q1) ||
          c.mobile1.toLowerCase().contains(q1) ||
          c.mobile2.toLowerCase().contains(q1);
      final match2 = q2.isEmpty ||
          c.customerType.toLowerCase().contains(q2) ||
          c.rating.toLowerCase().contains(q2);
      return match1 && match2;
    }).toList();
  }

  List<StaffEntity> filteredStaffByRole(StaffRole role) {
    return staffList.where((s) {
      if (s.role != role) return false;
      final q1 = staffSearch.trim().toLowerCase();
      final q2 = staffRatingSearch.trim().toLowerCase();
      final match1 = q1.isEmpty ||
          s.name.toLowerCase().contains(q1) ||
          s.mobile1.toLowerCase().contains(q1) ||
          s.mobile2.toLowerCase().contains(q1);
      final match2 = q2.isEmpty || s.rating.toLowerCase().contains(q2);
      return match1 && match2;
    }).toList();
  }

  List<ProductEntity> get filteredProducts {
    final q = productSearch.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.unit.toLowerCase().contains(q),
        )
        .toList();
  }

  MasterDataState copyWith({
    RequestStatus? status,
    List<CompanyEntity>? companies,
    CompanyEntity? selectedCompany,
    bool clearSelectedCompany = false,
    bool? showInlineCompanyBanks,
    String? companySearch,
    String? companyActivityFilter,
    List<CompanyBankAccountEntity>? bankAccounts,
    CompanyBankAccountEntity? selectedBankAccount,
    bool clearSelectedBankAccount = false,
    String? bankAccountSearch,
    String? bankNameCurrencySearch,
    List<CustomerEntity>? customers,
    CustomerEntity? selectedCustomer,
    bool clearSelectedCustomer = false,
    String? customerSearch,
    String? customerTypeRatingSearch,
    List<StaffEntity>? staffList,
    StaffEntity? selectedStaff,
    bool clearSelectedStaff = false,
    String? staffSearch,
    String? staffRatingSearch,
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    bool clearSelectedProduct = false,
    String? productSearch,
    List<String>? activities,
    List<String>? banks,
    List<String>? currencies,
    List<String>? customerTypes,
    List<String>? ratings,
    List<String>? units,
    String? actionMessage,
  }) {
    return MasterDataState(
      status: status ?? this.status,
      companies: companies ?? this.companies,
      selectedCompany: clearSelectedCompany
          ? null
          : (selectedCompany ?? this.selectedCompany),
      showInlineCompanyBanks:
          showInlineCompanyBanks ?? this.showInlineCompanyBanks,
      companySearch: companySearch ?? this.companySearch,
      companyActivityFilter:
          companyActivityFilter ?? this.companyActivityFilter,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      selectedBankAccount: clearSelectedBankAccount
          ? null
          : (selectedBankAccount ?? this.selectedBankAccount),
      bankAccountSearch: bankAccountSearch ?? this.bankAccountSearch,
      bankNameCurrencySearch:
          bankNameCurrencySearch ?? this.bankNameCurrencySearch,
      customers: customers ?? this.customers,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      customerSearch: customerSearch ?? this.customerSearch,
      customerTypeRatingSearch:
          customerTypeRatingSearch ?? this.customerTypeRatingSearch,
      staffList: staffList ?? this.staffList,
      selectedStaff:
          clearSelectedStaff ? null : (selectedStaff ?? this.selectedStaff),
      staffSearch: staffSearch ?? this.staffSearch,
      staffRatingSearch: staffRatingSearch ?? this.staffRatingSearch,
      products: products ?? this.products,
      selectedProduct: clearSelectedProduct
          ? null
          : (selectedProduct ?? this.selectedProduct),
      productSearch: productSearch ?? this.productSearch,
      activities: activities ?? this.activities,
      banks: banks ?? this.banks,
      currencies: currencies ?? this.currencies,
      customerTypes: customerTypes ?? this.customerTypes,
      ratings: ratings ?? this.ratings,
      units: units ?? this.units,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        companies,
        selectedCompany,
        showInlineCompanyBanks,
        companySearch,
        companyActivityFilter,
        bankAccounts,
        selectedBankAccount,
        bankAccountSearch,
        bankNameCurrencySearch,
        customers,
        selectedCustomer,
        customerSearch,
        customerTypeRatingSearch,
        staffList,
        selectedStaff,
        staffSearch,
        staffRatingSearch,
        products,
        selectedProduct,
        productSearch,
        activities,
        banks,
        currencies,
        customerTypes,
        ratings,
        units,
        actionMessage,
      ];
}
