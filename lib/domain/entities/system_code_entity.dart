import 'package:equatable/equatable.dart';

enum SystemCodeCategory {
  users('مستخدمي النظام'),
  banks('اسماء البنوك'),
  productUnits('وحدات المنتجات'),
  customerTypes('انواع العملاء'),
  ratings('تقييم المتعاملين'),
  companyActivities('انشطة الشركات'),
  paymentSystems('انظمة السداد'),
  legalActions('الاجراءات القانونية'),
  currencies('العملات المستخدمة'),
  paymentMethods('طريقة السداد'),
  priorities('الاولويات'),
  followUpMessages('رسائل متابعة النظام');

  final String arabicTitle;
  const SystemCodeCategory(this.arabicTitle);
}

class SystemCodeEntity extends Equatable {
  final String id;
  final SystemCodeCategory category;
  final String code;
  final String name;

  const SystemCodeEntity({
    required this.id,
    required this.category,
    required this.code,
    required this.name,
  });

  SystemCodeEntity copyWith({
    String? id,
    SystemCodeCategory? category,
    String? code,
    String? name,
  }) {
    return SystemCodeEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'code': code,
        'name': name,
      };

  factory SystemCodeEntity.fromJson(Map<String, dynamic> json) {
    final catName = json['category'] as String? ?? '';
    final cat = SystemCodeCategory.values.firstWhere(
      (e) => e.name == catName,
      orElse: () => SystemCodeCategory.priorities,
    );
    return SystemCodeEntity(
      id: json['id'] as String,
      category: cat,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, category, code, name];
}
