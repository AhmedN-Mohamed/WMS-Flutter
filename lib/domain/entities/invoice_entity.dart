import 'package:equatable/equatable.dart';

class InvoiceItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String unit;
  final double quantity;
  final double unitPrice; // Editable per invoice!
  final String notes;

  const InvoiceItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    this.unit = 'وحدة',
    required this.quantity,
    required this.unitPrice,
    this.notes = '',
  });

  double get lineTotal => quantity * unitPrice;

  InvoiceItemEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? unit,
    double? quantity,
    double? unitPrice,
    String? notes,
  }) {
    return InvoiceItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'unit': unit,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'notes': notes,
      };

  factory InvoiceItemEntity.fromJson(Map<String, dynamic> json) =>
      InvoiceItemEntity(
        id: json['id'] as String,
        productId: json['productId'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        unit: json['unit'] as String? ?? 'وحدة',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        unit,
        quantity,
        unitPrice,
        notes,
      ];
}

class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String companyId;
  final String companyName;
  final String customerId;
  final String customerName;
  final String customerMobile1;
  final String customerMobile2;
  final String salespersonId;
  final String salespersonName;
  final String shippingRepName;
  final double totalAmount;
  final String currency;
  final String notes;
  final String customerNotes;
  final String pdfPath;
  final List<InvoiceItemEntity> items;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.companyId,
    required this.companyName,
    required this.customerId,
    required this.customerName,
    this.customerMobile1 = '',
    this.customerMobile2 = '',
    required this.salespersonId,
    required this.salespersonName,
    this.shippingRepName = '',
    required this.totalAmount,
    this.currency = 'جنيه مصرى',
    this.notes = '',
    this.customerNotes = '',
    this.pdfPath = '',
    this.items = const [],
  });

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? companyId,
    String? companyName,
    String? customerId,
    String? customerName,
    String? customerMobile1,
    String? customerMobile2,
    String? salespersonId,
    String? salespersonName,
    String? shippingRepName,
    double? totalAmount,
    String? currency,
    String? notes,
    String? customerNotes,
    String? pdfPath,
    List<InvoiceItemEntity>? items,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerMobile1: customerMobile1 ?? this.customerMobile1,
      customerMobile2: customerMobile2 ?? this.customerMobile2,
      salespersonId: salespersonId ?? this.salespersonId,
      salespersonName: salespersonName ?? this.salespersonName,
      shippingRepName: shippingRepName ?? this.shippingRepName,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      customerNotes: customerNotes ?? this.customerNotes,
      pdfPath: pdfPath ?? this.pdfPath,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'invoiceDate': invoiceDate.toIso8601String(),
        'companyId': companyId,
        'companyName': companyName,
        'customerId': customerId,
        'customerName': customerName,
        'customerMobile1': customerMobile1,
        'customerMobile2': customerMobile2,
        'salespersonId': salespersonId,
        'salespersonName': salespersonName,
        'shippingRepName': shippingRepName,
        'totalAmount': totalAmount,
        'currency': currency,
        'notes': notes,
        'customerNotes': customerNotes,
        'pdfPath': pdfPath,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory InvoiceEntity.fromJson(Map<String, dynamic> json) => InvoiceEntity(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        invoiceDate: DateTime.tryParse(json['invoiceDate'] as String? ?? '') ??
            DateTime.now(),
        companyId: json['companyId'] as String? ?? '',
        companyName: json['companyName'] as String? ?? '',
        customerId: json['customerId'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        customerMobile1: json['customerMobile1'] as String? ?? '',
        customerMobile2: json['customerMobile2'] as String? ?? '',
        salespersonId: json['salespersonId'] as String? ?? '',
        salespersonName: json['salespersonName'] as String? ?? '',
        shippingRepName: json['shippingRepName'] as String? ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'جنيه مصرى',
        notes: json['notes'] as String? ?? '',
        customerNotes: json['customerNotes'] as String? ?? '',
        pdfPath: json['pdfPath'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => InvoiceItemEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        invoiceDate,
        companyId,
        companyName,
        customerId,
        customerName,
        customerMobile1,
        customerMobile2,
        salespersonId,
        salespersonName,
        shippingRepName,
        totalAmount,
        currency,
        notes,
        customerNotes,
        pdfPath,
        items,
      ];
}
