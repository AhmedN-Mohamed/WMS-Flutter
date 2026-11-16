import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String mobile1;
  final String mobile2;
  final String customerType;
  final String rating;
  final String locationUrl;
  final String notes;
  final String pdfPath;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.mobile1 = '',
    this.mobile2 = '',
    this.customerType = '',
    this.rating = '',
    this.locationUrl = '',
    this.notes = '',
    this.pdfPath = '',
  });

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? mobile1,
    String? mobile2,
    String? customerType,
    String? rating,
    String? locationUrl,
    String? notes,
    String? pdfPath,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile1: mobile1 ?? this.mobile1,
      mobile2: mobile2 ?? this.mobile2,
      customerType: customerType ?? this.customerType,
      rating: rating ?? this.rating,
      locationUrl: locationUrl ?? this.locationUrl,
      notes: notes ?? this.notes,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile1': mobile1,
        'mobile2': mobile2,
        'customerType': customerType,
        'rating': rating,
        'locationUrl': locationUrl,
        'notes': notes,
        'pdfPath': pdfPath,
      };

  factory CustomerEntity.fromJson(Map<String, dynamic> json) => CustomerEntity(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        mobile1: json['mobile1'] as String? ?? '',
        mobile2: json['mobile2'] as String? ?? '',
        customerType: json['customerType'] as String? ?? '',
        rating: json['rating'] as String? ?? '',
        locationUrl: json['locationUrl'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        pdfPath: json['pdfPath'] as String? ?? '',
      );

  @override
  List<Object?> get props => [
        id,
        name,
        mobile1,
        mobile2,
        customerType,
        rating,
        locationUrl,
        notes,
        pdfPath,
      ];
}
