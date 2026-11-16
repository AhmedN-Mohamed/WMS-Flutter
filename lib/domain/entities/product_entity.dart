import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String unit;
  final double guidingPrice;
  final String notes;

  const ProductEntity({
    required this.id,
    required this.name,
    this.unit = 'وحدة',
    required this.guidingPrice,
    this.notes = '',
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    String? unit,
    double? guidingPrice,
    String? notes,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      guidingPrice: guidingPrice ?? this.guidingPrice,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'guidingPrice': guidingPrice,
        'notes': notes,
      };

  factory ProductEntity.fromJson(Map<String, dynamic> json) => ProductEntity(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        unit: json['unit'] as String? ?? 'وحدة',
        guidingPrice: (json['guidingPrice'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, name, unit, guidingPrice, notes];
}
