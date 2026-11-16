import 'package:equatable/equatable.dart';

enum StaffRole {
  salesperson('بيانات البائعين', 'اسم البائع'),
  shippingRep('مندوبين الشحن', 'اسم مندوب الشحن'),
  collectorFollower('المتابعين والمحصلين', 'اسم المتابع-المحصل');

  final String screenTitle;
  final String nameFieldLabel;
  const StaffRole(this.screenTitle, this.nameFieldLabel);
}

class StaffEntity extends Equatable {
  final String id;
  final StaffRole role;
  final String name;
  final String mobile1;
  final String mobile2;
  final String rating;
  final String pdfPath;

  const StaffEntity({
    required this.id,
    required this.role,
    required this.name,
    this.mobile1 = '',
    this.mobile2 = '',
    this.rating = '',
    this.pdfPath = '',
  });

  StaffEntity copyWith({
    String? id,
    StaffRole? role,
    String? name,
    String? mobile1,
    String? mobile2,
    String? rating,
    String? pdfPath,
  }) {
    return StaffEntity(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      mobile1: mobile1 ?? this.mobile1,
      mobile2: mobile2 ?? this.mobile2,
      rating: rating ?? this.rating,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'name': name,
        'mobile1': mobile1,
        'mobile2': mobile2,
        'rating': rating,
        'pdfPath': pdfPath,
      };

  factory StaffEntity.fromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String? ?? '';
    final role = StaffRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => StaffRole.salesperson,
    );
    return StaffEntity(
      id: json['id'] as String,
      role: role,
      name: json['name'] as String? ?? '',
      mobile1: json['mobile1'] as String? ?? '',
      mobile2: json['mobile2'] as String? ?? '',
      rating: json['rating'] as String? ?? '',
      pdfPath: json['pdfPath'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, role, name, mobile1, mobile2, rating, pdfPath];
}
