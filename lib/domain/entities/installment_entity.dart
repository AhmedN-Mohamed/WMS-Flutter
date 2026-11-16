import 'package:equatable/equatable.dart';

class InstallmentEntity extends Equatable {
  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceTotal;
  final String companyId;
  final String companyName;
  final String customerId;
  final String customerName;
  final String salespersonId;
  final String salespersonName;
  final String currency;

  final double amount; // قيمة الدفعة
  final DateTime dueDate; // تاريخ الدفعة
  final DateTime followUpDate; // تاريخ المتابعة
  final String paymentSystem; // نظام السداد
  final String priority; // الأولوية
  final String followerId;
  final String followerName; // المتابع
  final String legalAction; // الإجراء القانوني
  final String description; // بيان الدفعة
  final String followUpNotes; // متابعة الدفعة
  final double collectedAmount; // المسدد منها

  const InstallmentEntity({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceTotal,
    required this.companyId,
    required this.companyName,
    required this.customerId,
    required this.customerName,
    required this.salespersonId,
    required this.salespersonName,
    this.currency = 'جنيه مصرى',
    required this.amount,
    required this.dueDate,
    required this.followUpDate,
    this.paymentSystem = 'آجل',
    this.priority = 'بدون',
    this.followerId = '',
    this.followerName = 'مسئول البيع',
    this.legalAction = 'بدون',
    this.description = '',
    this.followUpNotes = '',
    this.collectedAmount = 0.0,
  });

  /// الباقي للمتابعة
  double get remainingAmount =>
      (amount - collectedAmount).clamp(0.0, double.infinity);

  bool get isFullyPaid => remainingAmount <= 0.01;
  bool get isPartiallyPaid => collectedAmount > 0.01 && !isFullyPaid;
  bool get isUnpaid => collectedAmount <= 0.01 && !isFullyPaid;

  bool get isOverdue {
    if (isFullyPaid) return false;
    final today = DateTime.now();
    final cleanToday = DateTime(today.year, today.month, today.day);
    final cleanDue = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return cleanDue.isBefore(cleanToday);
  }

  InstallmentEntity copyWith({
    String? id,
    String? invoiceId,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? invoiceTotal,
    String? companyId,
    String? companyName,
    String? customerId,
    String? customerName,
    String? salespersonId,
    String? salespersonName,
    String? currency,
    double? amount,
    DateTime? dueDate,
    DateTime? followUpDate,
    String? paymentSystem,
    String? priority,
    String? followerId,
    String? followerName,
    String? legalAction,
    String? description,
    String? followUpNotes,
    double? collectedAmount,
  }) {
    return InstallmentEntity(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTotal: invoiceTotal ?? this.invoiceTotal,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      salespersonId: salespersonId ?? this.salespersonId,
      salespersonName: salespersonName ?? this.salespersonName,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      followUpDate: followUpDate ?? this.followUpDate,
      paymentSystem: paymentSystem ?? this.paymentSystem,
      priority: priority ?? this.priority,
      followerId: followerId ?? this.followerId,
      followerName: followerName ?? this.followerName,
      legalAction: legalAction ?? this.legalAction,
      description: description ?? this.description,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      collectedAmount: collectedAmount ?? this.collectedAmount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'invoiceDate': invoiceDate.toIso8601String(),
        'invoiceTotal': invoiceTotal,
        'companyId': companyId,
        'companyName': companyName,
        'customerId': customerId,
        'customerName': customerName,
        'salespersonId': salespersonId,
        'salespersonName': salespersonName,
        'currency': currency,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'followUpDate': followUpDate.toIso8601String(),
        'paymentSystem': paymentSystem,
        'priority': priority,
        'followerId': followerId,
        'followerName': followerName,
        'legalAction': legalAction,
        'description': description,
        'followUpNotes': followUpNotes,
        'collectedAmount': collectedAmount,
      };

  factory InstallmentEntity.fromJson(Map<String, dynamic> json) =>
      InstallmentEntity(
        id: json['id'] as String,
        invoiceId: json['invoiceId'] as String? ?? '',
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        invoiceDate: DateTime.tryParse(json['invoiceDate'] as String? ?? '') ??
            DateTime.now(),
        invoiceTotal: (json['invoiceTotal'] as num?)?.toDouble() ?? 0.0,
        companyId: json['companyId'] as String? ?? '',
        companyName: json['companyName'] as String? ?? '',
        customerId: json['customerId'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        salespersonId: json['salespersonId'] as String? ?? '',
        salespersonName: json['salespersonName'] as String? ?? '',
        currency: json['currency'] as String? ?? 'جنيه مصرى',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        dueDate:
            DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
        followUpDate: DateTime.tryParse(json['followUpDate'] as String? ?? '') ??
            DateTime.now(),
        paymentSystem: json['paymentSystem'] as String? ?? 'آجل',
        priority: json['priority'] as String? ?? 'بدون',
        followerId: json['followerId'] as String? ?? '',
        followerName: json['followerName'] as String? ?? 'مسئول البيع',
        legalAction: json['legalAction'] as String? ?? 'بدون',
        description: json['description'] as String? ?? '',
        followUpNotes: json['followUpNotes'] as String? ?? '',
        collectedAmount: (json['collectedAmount'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        invoiceNumber,
        invoiceDate,
        invoiceTotal,
        companyId,
        companyName,
        customerId,
        customerName,
        salespersonId,
        salespersonName,
        currency,
        amount,
        dueDate,
        followUpDate,
        paymentSystem,
        priority,
        followerId,
        followerName,
        legalAction,
        description,
        followUpNotes,
        collectedAmount,
      ];
}
