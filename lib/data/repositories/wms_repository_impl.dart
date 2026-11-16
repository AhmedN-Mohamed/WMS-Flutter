import '../../domain/entities/audit_log_entity.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/installment_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/system_code_entity.dart';
import '../../domain/repositories/wms_repository.dart';
import '../datasources/local_wms_datasource.dart';

class WmsRepositoryImpl implements WmsRepository {
  final LocalWmsDataSource _localDataSource;

  WmsRepositoryImpl(this._localDataSource);

  @override
  Future<void> init() => _localDataSource.init();

  // --- System Codes ---
  @override
  List<SystemCodeEntity> getSystemCodes([SystemCodeCategory? category]) {
    if (category == null) return List.unmodifiable(_localDataSource.systemCodes);
    return _localDataSource.systemCodes
        .where((e) => e.category == category)
        .toList();
  }

  @override
  Future<void> saveSystemCode(SystemCodeEntity code) async {
    final idx = _localDataSource.systemCodes.indexWhere((e) => e.id == code.id);
    if (idx >= 0) {
      _localDataSource.systemCodes[idx] = code;
    } else {
      _localDataSource.systemCodes.add(code);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل كود' : 'إضافة كود',
      module: 'أكواد النظام',
      details: '${code.category.arabicTitle}: ${code.name}',
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteSystemCode(String id) async {
    _localDataSource.systemCodes.removeWhere((e) => e.id == id);
    await addAuditLog(
      action: 'حذف كود',
      module: 'أكواد النظام',
      details: 'تم حذف كود رقم $id',
    );
    await _localDataSource.persist();
  }

  // --- Companies & Bank Accounts ---
  @override
  List<CompanyEntity> getCompanies() =>
      List.unmodifiable(_localDataSource.companies);

  @override
  Future<void> saveCompany(CompanyEntity company) async {
    final idx = _localDataSource.companies.indexWhere((e) => e.id == company.id);
    if (idx >= 0) {
      _localDataSource.companies[idx] = company;
    } else {
      _localDataSource.companies.add(company);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل شركة' : 'إضافة شركة',
      module: 'بيانات الشركات',
      details: '${company.code} - ${company.name}',
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteCompany(String id) async {
    _localDataSource.companies.removeWhere((e) => e.id == id);
    await _localDataSource.persist();
  }

  @override
  List<CompanyBankAccountEntity> getBankAccounts([String? companyId]) {
    if (companyId == null || companyId.isEmpty) {
      return List.unmodifiable(_localDataSource.bankAccounts);
    }
    return _localDataSource.bankAccounts
        .where((e) => e.companyId == companyId)
        .toList();
  }

  @override
  Future<void> saveBankAccount(CompanyBankAccountEntity account) async {
    final idx =
        _localDataSource.bankAccounts.indexWhere((e) => e.id == account.id);
    if (idx >= 0) {
      _localDataSource.bankAccounts[idx] = account;
    } else {
      _localDataSource.bankAccounts.add(account);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل حساب بنكي' : 'إضافة حساب بنكي',
      module: 'الحسابات البنكية للشركات',
      details: '${account.accountNumber} - ${account.bankName} (${account.companyName})',
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    _localDataSource.bankAccounts.removeWhere((e) => e.id == id);
    await _localDataSource.persist();
  }

  // --- Customers ---
  @override
  List<CustomerEntity> getCustomers() =>
      List.unmodifiable(_localDataSource.customers);

  @override
  Future<void> saveCustomer(CustomerEntity customer) async {
    final idx =
        _localDataSource.customers.indexWhere((e) => e.id == customer.id);
    if (idx >= 0) {
      _localDataSource.customers[idx] = customer;
      // Sync customer info into invoices
      for (int i = 0; i < _localDataSource.invoices.length; i++) {
        final inv = _localDataSource.invoices[i];
        if (inv.customerId == customer.id) {
          _localDataSource.invoices[i] = inv.copyWith(
            customerName: customer.name,
            customerMobile1: customer.mobile1,
            customerMobile2: customer.mobile2,
            customerNotes: customer.notes,
          );
        }
      }
    } else {
      _localDataSource.customers.insert(0, customer);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل عميل' : 'إضافة عميل',
      module: 'بيانات العملاء',
      details: customer.name,
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteCustomer(String id) async {
    _localDataSource.customers.removeWhere((e) => e.id == id);
    await _localDataSource.persist();
  }

  // --- Staff ---
  @override
  List<StaffEntity> getStaff([StaffRole? role]) {
    if (role == null) return List.unmodifiable(_localDataSource.staff);
    return _localDataSource.staff.where((e) => e.role == role).toList();
  }

  @override
  Future<void> saveStaff(StaffEntity member) async {
    final idx = _localDataSource.staff.indexWhere((e) => e.id == member.id);
    if (idx >= 0) {
      _localDataSource.staff[idx] = member;
    } else {
      _localDataSource.staff.add(member);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل بيانات' : 'إضافة جديد',
      module: member.role.screenTitle,
      details: member.name,
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteStaff(String id) async {
    _localDataSource.staff.removeWhere((e) => e.id == id);
    await _localDataSource.persist();
  }

  // --- Products ---
  @override
  List<ProductEntity> getProducts() =>
      List.unmodifiable(_localDataSource.products);

  @override
  Future<void> saveProduct(ProductEntity product) async {
    final idx = _localDataSource.products.indexWhere((e) => e.id == product.id);
    if (idx >= 0) {
      _localDataSource.products[idx] = product;
    } else {
      _localDataSource.products.add(product);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل صنف' : 'إضافة صنف',
      module: 'المنتجات والأصناف',
      details: '${product.name} (سعر استرشادي: ${product.guidingPrice})',
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteProduct(String id) async {
    _localDataSource.products.removeWhere((e) => e.id == id);
    await _localDataSource.persist();
  }

  // --- Invoices ---
  @override
  List<InvoiceEntity> getInvoices() {
    final list = List<InvoiceEntity>.from(_localDataSource.invoices);
    list.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    return list;
  }

  @override
  Future<void> saveInvoice(InvoiceEntity invoice) async {
    final idx = _localDataSource.invoices.indexWhere((e) => e.id == invoice.id);
    if (idx >= 0) {
      _localDataSource.invoices[idx] = invoice;
      // Update denormalized fields in installments
      for (int i = 0; i < _localDataSource.installments.length; i++) {
        final inst = _localDataSource.installments[i];
        if (inst.invoiceId == invoice.id) {
          _localDataSource.installments[i] = inst.copyWith(
            invoiceNumber: invoice.invoiceNumber,
            invoiceDate: invoice.invoiceDate,
            invoiceTotal: invoice.totalAmount,
            companyId: invoice.companyId,
            companyName: invoice.companyName,
            customerId: invoice.customerId,
            customerName: invoice.customerName,
            salespersonId: invoice.salespersonId,
            salespersonName: invoice.salespersonName,
            currency: invoice.currency,
          );
        }
      }
    } else {
      _localDataSource.invoices.insert(0, invoice);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل فاتورة' : 'إضافة فاتورة',
      module: 'فواتير الشركات',
      details: 'فاتورة رقم ${invoice.invoiceNumber} - ${invoice.customerName} (${invoice.totalAmount})',
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteInvoice(String id) async {
    final inv = _localDataSource.invoices.where((e) => e.id == id).firstOrNull;
    _localDataSource.invoices.removeWhere((e) => e.id == id);
    _localDataSource.installments.removeWhere((e) => e.invoiceId == id);
    _localDataSource.collections.removeWhere((e) => e.invoiceId == id);
    if (inv != null) {
      await addAuditLog(
        action: 'حذف فاتورة',
        module: 'فواتير الشركات',
        details: 'حذف الفاتورة رقم ${inv.invoiceNumber}',
      );
    }
    await _localDataSource.persist();
  }

  // --- Installments ---
  @override
  List<InstallmentEntity> getInstallments({
    String? invoiceId,
    String? companyId,
  }) {
    Iterable<InstallmentEntity> result = _localDataSource.installments;
    if (invoiceId != null && invoiceId.isNotEmpty) {
      result = result.where((e) => e.invoiceId == invoiceId);
    }
    if (companyId != null && companyId.isNotEmpty) {
      result = result.where((e) => e.companyId == companyId);
    }
    final list = result.toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  @override
  Future<void> saveInstallment(InstallmentEntity installment) async {
    final idx = _localDataSource.installments
        .indexWhere((e) => e.id == installment.id);
    if (idx >= 0) {
      _localDataSource.installments[idx] = installment;
    } else {
      _localDataSource.installments.add(installment);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل دفعة/متابعة' : 'إضافة دفعة للفاتورة',
      module: 'دفعات للتحصيل والمتابعة',
      details: 'فاتورة ${installment.invoiceNumber} - قيمة الدفعة: ${installment.amount}',
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteInstallment(String id) async {
    _localDataSource.installments.removeWhere((e) => e.id == id);
    _localDataSource.collections.removeWhere((e) => e.installmentId == id);
    await _localDataSource.persist();
  }

  // --- Collections ---
  @override
  List<CollectionEntity> getCollections({
    String? installmentId,
    String? invoiceId,
  }) {
    Iterable<CollectionEntity> result = _localDataSource.collections;
    if (installmentId != null && installmentId.isNotEmpty) {
      result = result.where((e) => e.installmentId == installmentId);
    }
    if (invoiceId != null && invoiceId.isNotEmpty) {
      result = result.where((e) => e.invoiceId == invoiceId);
    }
    final list = result.toList();
    list.sort((a, b) => b.collectionDate.compareTo(a.collectionDate));
    return list;
  }

  @override
  Future<void> saveCollection(CollectionEntity collection) async {
    final idx =
        _localDataSource.collections.indexWhere((e) => e.id == collection.id);
    if (idx >= 0) {
      _localDataSource.collections[idx] = collection;
    } else {
      _localDataSource.collections.insert(0, collection);
    }
    await addAuditLog(
      action: idx >= 0 ? 'تعديل تحصيل' : 'تسجيل تحصيل من دفعة',
      module: 'تحصيل من دفعة',
      details:
          'فاتورة ${collection.invoiceNumber} - المحصل: ${collection.collectedAmount} (${collection.paymentMethod})',
    );
    await _localDataSource.persist();
  }

  @override
  Future<void> deleteCollection(String id) async {
    _localDataSource.collections.removeWhere((e) => e.id == id);
    await _localDataSource.persist();
  }

  // --- Audit Logs & Session ---
  @override
  List<AuditLogEntity> getAuditLogs() =>
      List.unmodifiable(_localDataSource.auditLogs);

  @override
  Future<void> addAuditLog({
    required String action,
    required String module,
    required String details,
  }) async {
    final entry = AuditLogEntity(
      id: 'log_${DateTime.now().microsecondsSinceEpoch}',
      userCode: _localDataSource.currentUserCode,
      userName: _localDataSource.currentUserName,
      action: action,
      module: module,
      details: details,
      timestamp: DateTime.now(),
    );
    _localDataSource.auditLogs.insert(0, entry);
  }

  @override
  ({String code, String name}) getCurrentUser() => (
        code: _localDataSource.currentUserCode,
        name: _localDataSource.currentUserName,
      );

  @override
  Future<void> setCurrentUser({
    required String code,
    required String name,
  }) async {
    _localDataSource.currentUserCode = code;
    _localDataSource.currentUserName = name;
    await addAuditLog(
      action: 'تغيير المستخدم',
      module: 'النظام الرئيسي',
      details: 'تم التبديل إلى المستخدم $code - $name',
    );
    await _localDataSource.persist();
  }
}
