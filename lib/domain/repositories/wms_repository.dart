import '../entities/audit_log_entity.dart';
import '../entities/collection_entity.dart';
import '../entities/company_entity.dart';
import '../entities/customer_entity.dart';
import '../entities/installment_entity.dart';
import '../entities/invoice_entity.dart';
import '../entities/product_entity.dart';
import '../entities/staff_entity.dart';
import '../entities/system_code_entity.dart';

/// Clean Architecture Repository Contract.
/// Currently backed by local persistent storage; can be swapped or synced with a Remote API later.
abstract class WmsRepository {
  Future<void> init();

  // System Lookup Codes (أكواد النظام)
  List<SystemCodeEntity> getSystemCodes([SystemCodeCategory? category]);
  Future<void> saveSystemCode(SystemCodeEntity code);
  Future<void> deleteSystemCode(String id);

  // Sub-Companies & Bank Accounts (الشركات والحسابات البنكية)
  List<CompanyEntity> getCompanies();
  Future<void> saveCompany(CompanyEntity company);
  Future<void> deleteCompany(String id);

  List<CompanyBankAccountEntity> getBankAccounts([String? companyId]);
  Future<void> saveBankAccount(CompanyBankAccountEntity account);
  Future<void> deleteBankAccount(String id);

  // Customers (العملاء)
  List<CustomerEntity> getCustomers();
  Future<void> saveCustomer(CustomerEntity customer);
  Future<void> deleteCustomer(String id);

  // Staff: Salespeople, Shipping Reps, Collectors/Followers
  List<StaffEntity> getStaff([StaffRole? role]);
  Future<void> saveStaff(StaffEntity staff);
  Future<void> deleteStaff(String id);

  // Products (المنتجات والأصناف)
  List<ProductEntity> getProducts();
  Future<void> saveProduct(ProductEntity product);
  Future<void> deleteProduct(String id);

  // Invoices (فواتير الشركات)
  List<InvoiceEntity> getInvoices();
  Future<void> saveInvoice(InvoiceEntity invoice);
  Future<void> deleteInvoice(String id);

  // Installments (دفعات للتحصيل والمتابعة)
  List<InstallmentEntity> getInstallments({String? invoiceId, String? companyId});
  Future<void> saveInstallment(InstallmentEntity installment);
  Future<void> deleteInstallment(String id);

  // Collections (تحصيل من دفعة)
  List<CollectionEntity> getCollections({String? installmentId, String? invoiceId});
  Future<void> saveCollection(CollectionEntity collection);
  Future<void> deleteCollection(String id);

  // Audit Logs & Session
  List<AuditLogEntity> getAuditLogs();
  Future<void> addAuditLog({
    required String action,
    required String module,
    required String details,
  });

  ({String code, String name}) getCurrentUser();
  Future<void> setCurrentUser({required String code, required String name});
}
