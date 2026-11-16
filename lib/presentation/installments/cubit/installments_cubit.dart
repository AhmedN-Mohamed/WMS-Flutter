import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/collection_entity.dart';
import '../../../domain/entities/installment_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/staff_entity.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../../../domain/repositories/wms_repository.dart';
import 'installments_state.dart';

class InstallmentsCubit extends Cubit<InstallmentsState> {
  final WmsRepository _repository;

  InstallmentsCubit(this._repository) : super(const InstallmentsState());

  void loadData({String? focusInvoiceId, String? actionMessage}) {
    final companies = _repository.getCompanies();
    final invoices = _repository.getInvoices();
    final installments = _repository.getInstallments();
    final collections = _repository.getCollections();

    InvoiceEntity? targetInvoice;
    String? targetCompanyId = state.selectedCompanyId;

    if (focusInvoiceId != null) {
      targetInvoice = invoices.where((e) => e.id == focusInvoiceId).firstOrNull;
      if (targetInvoice != null) {
        targetCompanyId = targetInvoice.companyId;
      }
    } else if (state.selectedInvoice != null) {
      targetInvoice = invoices
          .where((e) => e.id == state.selectedInvoice!.id)
          .firstOrNull;
    } else {
      targetInvoice = invoices.firstOrNull;
      targetCompanyId ??= targetInvoice?.companyId;
    }

    InstallmentEntity? targetInstallment;
    if (targetInvoice != null) {
      final invInst =
          installments.where((i) => i.invoiceId == targetInvoice!.id).toList();
      if (state.selectedInstallment != null) {
        targetInstallment = invInst
            .where((i) => i.id == state.selectedInstallment!.id)
            .firstOrNull;
      }
      targetInstallment ??= invInst.firstOrNull;
    }

    emit(
      state.copyWith(
        status: RequestStatus.success,
        companies: companies,
        selectedCompanyId: targetCompanyId,
        allInvoices: invoices,
        selectedInvoice: targetInvoice,
        clearSelectedInvoice: targetInvoice == null,
        allInstallments: installments,
        selectedInstallment: targetInstallment,
        clearSelectedInstallment: targetInstallment == null,
        allCollections: collections,
        paymentSystems: _repository
            .getSystemCodes(SystemCodeCategory.paymentSystems)
            .map((e) => e.name)
            .toList(),
        priorities: _repository
            .getSystemCodes(SystemCodeCategory.priorities)
            .map((e) => e.name)
            .toList(),
        legalActions: _repository
            .getSystemCodes(SystemCodeCategory.legalActions)
            .map((e) => e.name)
            .toList(),
        paymentMethods: _repository
            .getSystemCodes(SystemCodeCategory.paymentMethods)
            .map((e) => e.name)
            .toList(),
        followersAndCollectors:
            _repository.getStaff(StaffRole.collectorFollower),
        actionMessage: actionMessage,
      ),
    );
  }

  void selectCompany(String? companyId) {
    final compInvoices = companyId == null
        ? state.allInvoices
        : state.allInvoices.where((i) => i.companyId == companyId).toList();
    final firstInv = compInvoices.firstOrNull;
    final firstInst = firstInv == null
        ? null
        : state.allInstallments
            .where((i) => i.invoiceId == firstInv.id)
            .firstOrNull;

    emit(
      state.copyWith(
        selectedCompanyId: companyId,
        clearSelectedCompany: companyId == null,
        selectedInvoice: firstInv,
        clearSelectedInvoice: firstInv == null,
        selectedInstallment: firstInst,
        clearSelectedInstallment: firstInst == null,
      ),
    );
  }

  void selectInvoice(InvoiceEntity invoice) {
    final firstInst = state.allInstallments
        .where((i) => i.invoiceId == invoice.id)
        .firstOrNull;
    emit(
      state.copyWith(
        selectedInvoice: invoice,
        selectedInstallment: firstInst,
        clearSelectedInstallment: firstInst == null,
      ),
    );
  }

  void selectInstallment(InstallmentEntity? installment) {
    emit(
      state.copyWith(
        selectedInstallment: installment,
        clearSelectedInstallment: installment == null,
      ),
    );
  }

  void updateSearchQueries({String? companyQuery, String? invoiceQuery}) {
    emit(
      state.copyWith(
        companySearchQuery: companyQuery ?? state.companySearchQuery,
        customerInvoiceSearchQuery:
            invoiceQuery ?? state.customerInvoiceSearchQuery,
      ),
    );
  }

  void copyFollowUpNote() {
    final inst = state.selectedInstallment;
    if (inst == null) return;
    emit(
      state.copyWith(
        copiedFollowUpNote: inst.followUpNotes,
        actionMessage: 'تم نسخ نص المتابعة',
      ),
    );
  }

  Future<void> saveInstallment({
    String? id,
    required double amount,
    required DateTime dueDate,
    required DateTime followUpDate,
    required String paymentSystem,
    required String priority,
    required String followerName,
    required String legalAction,
    required String description,
    required String followUpNotes,
  }) async {
    final inv = state.selectedInvoice;
    if (inv == null || amount <= 0) return;

    final existingCollected = id != null
        ? (state.allInstallments
                .where((e) => e.id == id)
                .firstOrNull
                ?.collectedAmount ??
            0.0)
        : 0.0;

    final entity = InstallmentEntity(
      id: id ?? 'inst_${DateTime.now().microsecondsSinceEpoch}',
      invoiceId: inv.id,
      invoiceNumber: inv.invoiceNumber,
      invoiceDate: inv.invoiceDate,
      invoiceTotal: inv.totalAmount,
      companyId: inv.companyId,
      companyName: inv.companyName,
      customerId: inv.customerId,
      customerName: inv.customerName,
      salespersonId: inv.salespersonId,
      salespersonName: inv.salespersonName,
      currency: inv.currency,
      amount: amount,
      dueDate: dueDate,
      followUpDate: followUpDate,
      paymentSystem: paymentSystem,
      priority: priority,
      followerName: followerName,
      legalAction: legalAction,
      description: description.trim(),
      followUpNotes: followUpNotes.trim(),
      collectedAmount: existingCollected,
    );

    await _repository.saveInstallment(entity);
    loadData(
      focusInvoiceId: inv.id,
      actionMessage: id != null
          ? 'تم حفظ تعديل الدفعة بنجاح'
          : 'تمت إضافة الدفعة للفاتورة ${inv.invoiceNumber}',
    );
    selectInstallment(entity);
  }

  Future<void> deleteSelectedInstallment() async {
    final inst = state.selectedInstallment;
    if (inst == null) return;
    await _repository.deleteInstallment(inst.id);
    emit(state.copyWith(clearSelectedInstallment: true));
    loadData(
      focusInvoiceId: inst.invoiceId,
      actionMessage: 'تم حذف الدفعة بنجاح',
    );
  }

  Future<void> addCollection({
    required InstallmentEntity installment,
    required double collectedAmount,
    required DateTime collectionDate,
    required String paymentMethod,
    required String collectorName,
    required String notes,
  }) async {
    if (collectedAmount <= 0) return;
    final entity = CollectionEntity(
      id: 'coll_${DateTime.now().microsecondsSinceEpoch}',
      installmentId: installment.id,
      invoiceId: installment.invoiceId,
      invoiceNumber: installment.invoiceNumber,
      companyId: installment.companyId,
      companyName: installment.companyName,
      customerId: installment.customerId,
      customerName: installment.customerName,
      salespersonName: installment.salespersonName,
      followerName: installment.followerName,
      collectedAmount: collectedAmount,
      collectionDate: collectionDate,
      paymentMethod: paymentMethod,
      collectorName: collectorName,
      notes: notes.trim(),
    );

    await _repository.saveCollection(entity);
    loadData(
      focusInvoiceId: installment.invoiceId,
      actionMessage:
          'تم تسجيل تحصيل بمبلغ $collectedAmount من الفاتورة ${installment.invoiceNumber}',
    );
  }

  Future<void> deleteCollection(String collectionId) async {
    final inst = state.selectedInstallment;
    await _repository.deleteCollection(collectionId);
    loadData(
      focusInvoiceId: inst?.invoiceId,
      actionMessage: 'تم حذف حركة التحصيل',
    );
  }
}
