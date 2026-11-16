import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/installment_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/system_code_entity.dart';

class LocalWmsDataSource {
  static const String _storageKey = 'kanza_wms_db_v1';

  SharedPreferences? _prefs;

  List<SystemCodeEntity> systemCodes = [];
  List<CompanyEntity> companies = [];
  List<CompanyBankAccountEntity> bankAccounts = [];
  List<CustomerEntity> customers = [];
  List<StaffEntity> staff = [];
  List<ProductEntity> products = [];
  List<InvoiceEntity> invoices = [];
  List<InstallmentEntity> installments = [];
  List<CollectionEntity> collections = [];
  List<AuditLogEntity> auditLogs = [];

  String currentUserCode = '001';
  String currentUserName = 'مدير النظام';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _loadFromMap(map);
        _recalculateInstallmentCollections();
        return;
      } catch (_) {
        // Fallback to empty state
      }
    }
    // No mock data: start completely empty for the user to add everything
    currentUserCode = '001';
    currentUserName = 'مدير النظام';
    systemCodes = [];
    companies = [];
    bankAccounts = [];
    customers = [];
    staff = [];
    products = [];
    invoices = [];
    installments = [];
    collections = [];
    auditLogs = [];
    await persist();
  }

  void _loadFromMap(Map<String, dynamic> map) {
    currentUserCode = map['currentUserCode'] as String? ?? '001';
    currentUserName = map['currentUserName'] as String? ?? 'مدير النظام';
    systemCodes = (map['systemCodes'] as List<dynamic>? ?? [])
        .map((e) => SystemCodeEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    companies = (map['companies'] as List<dynamic>? ?? [])
        .map((e) => CompanyEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    bankAccounts = (map['bankAccounts'] as List<dynamic>? ?? [])
        .map((e) => CompanyBankAccountEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    customers = (map['customers'] as List<dynamic>? ?? [])
        .map((e) => CustomerEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    staff = (map['staff'] as List<dynamic>? ?? [])
        .map((e) => StaffEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    products = (map['products'] as List<dynamic>? ?? [])
        .map((e) => ProductEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    invoices = (map['invoices'] as List<dynamic>? ?? [])
        .map((e) => InvoiceEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    installments = (map['installments'] as List<dynamic>? ?? [])
        .map((e) => InstallmentEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    collections = (map['collections'] as List<dynamic>? ?? [])
        .map((e) => CollectionEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    auditLogs = (map['auditLogs'] as List<dynamic>? ?? [])
        .map((e) => AuditLogEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> persist() async {
    _recalculateInstallmentCollections();
    final map = <String, dynamic>{
      'currentUserCode': currentUserCode,
      'currentUserName': currentUserName,
      'systemCodes': systemCodes.map((e) => e.toJson()).toList(),
      'companies': companies.map((e) => e.toJson()).toList(),
      'bankAccounts': bankAccounts.map((e) => e.toJson()).toList(),
      'customers': customers.map((e) => e.toJson()).toList(),
      'staff': staff.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
      'invoices': invoices.map((e) => e.toJson()).toList(),
      'installments': installments.map((e) => e.toJson()).toList(),
      'collections': collections.map((e) => e.toJson()).toList(),
      'auditLogs': auditLogs.map((e) => e.toJson()).toList(),
    };
    await _prefs?.setString(_storageKey, jsonEncode(map));
  }

  void _recalculateInstallmentCollections() {
    for (int i = 0; i < installments.length; i++) {
      final inst = installments[i];
      final sumCollected = collections
          .where((c) => c.installmentId == inst.id)
          .fold<double>(0.0, (sum, item) => sum + item.collectedAmount);
      installments[i] = inst.copyWith(collectedAmount: sumCollected);
    }
  }

  /// Clears all stored data completely (reset)
  Future<void> clearAllData() async {
    systemCodes.clear();
    companies.clear();
    bankAccounts.clear();
    customers.clear();
    staff.clear();
    products.clear();
    invoices.clear();
    installments.clear();
    collections.clear();
    auditLogs.clear();
    currentUserCode = '001';
    currentUserName = 'مدير النظام';
    await persist();
  }
}
