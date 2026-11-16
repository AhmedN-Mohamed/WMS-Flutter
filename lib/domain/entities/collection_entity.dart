import 'package:equatable/equatable.dart';

class CollectionEntity extends Equatable {
  final String id;
  final String installmentId;
  final String invoiceId;
  final String invoiceNumber;
  final String companyId;
  final String companyName;
  final String customerId;
  final String customerName;
  final String salespersonName;
  final String followerName;
  final double collectedAmount; // القيمة المحصلة
  final DateTime collectionDate; // تاريخ التحصيل
  final String paymentMethod; // طريقة السداد
  final String collectorId;
  final String collectorName; // المحصل
  final String notes; // ملاحظات السداد

  const CollectionEntity({
    required this.id,
    required this.installmentId,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.companyId,
    required this.companyName,
    required this.customerId,
    required this.customerName,
    this.salespersonName = '',
    this.followerName = '',
    required this.collectedAmount,
    required this.collectionDate,
    this.paymentMethod = 'نقدي',
    this.collectorId = '',
    this.collectorName = 'مسئول البيع',
    this.notes = '',
  });

  CollectionEntity copyWith({
    String? id,
    String? installmentId,
    String? invoiceId,
    String? invoiceNumber,
    String? companyId,
    String? companyName,
    String? customerId,
    String? customerName,
    String? salespersonName,
    String? followerName,
    double? collectedAmount,
    DateTime? collectionDate,
    String? paymentMethod,
    String? collectorId,
    String? collectorName,
    String? notes,
  }) {
    return CollectionEntity(
      id: id ?? this.id,
      installmentId: installmentId ?? this.installmentId,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      salespersonName: salespersonName ?? this.salespersonName,
      followerName: followerName ?? this.followerName,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      collectionDate: collectionDate ?? this.collectionDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'installmentId': installmentId,
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'companyId': companyId,
        'companyName': companyName,
        'customerId': customerId,
        'customerName': customerName,
        'salespersonName': salespersonName,
        'followerName': followerName,
        'collectedAmount': collectedAmount,
        'collectionDate': collectionDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'collectorId': collectorId,
        'collectorName': collectorName,
        'notes': notes,
      };

  factory CollectionEntity.fromJson(Map<String, dynamic> json) =>
      CollectionEntity(
        id: json['id'] as String,
        installmentId: json['installmentId'] as String? ?? '',
        invoiceId: json['invoiceId'] as String? ?? '',
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        companyId: json['companyId'] as String? ?? '',
        companyName: json['companyName'] as String? ?? '',
        customerId: json['customerId'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        salespersonName: json['salespersonName'] as String? ?? '',
        followerName: json['followerName'] as String? ?? '',
        collectedAmount: (json['collectedAmount'] as num?)?.toDouble() ?? 0.0,
        collectionDate:
            DateTime.tryParse(json['collectionDate'] as String? ?? '') ??
                DateTime.now(),
        paymentMethod: json['paymentMethod'] as String? ?? 'نقدي',
        collectorId: json['collectorId'] as String? ?? '',
        collectorName: json['collectorName'] as String? ?? 'مسئول البيع',
        notes: json['notes'] as String? ?? '',
      );

  @override
  List<Object?> get props => [
        id,
        installmentId,
        invoiceId,
        invoiceNumber,
        companyId,
        companyName,
        customerId,
        customerName,
        salespersonName,
        followerName,
        collectedAmount,
        collectionDate,
        paymentMethod,
        collectorId,
        collectorName,
        notes,
      ];
}
