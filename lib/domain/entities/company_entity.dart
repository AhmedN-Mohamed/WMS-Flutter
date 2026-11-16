import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String activity;
  final String mobile1;
  final String mobile2;
  final String pdfPath;

  const CompanyEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.activity,
    this.mobile1 = '',
    this.mobile2 = '',
    this.pdfPath = '',
  });

  CompanyEntity copyWith({
    String? id,
    String? code,
    String? name,
    String? activity,
    String? mobile1,
    String? mobile2,
    String? pdfPath,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      activity: activity ?? this.activity,
      mobile1: mobile1 ?? this.mobile1,
      mobile2: mobile2 ?? this.mobile2,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'activity': activity,
        'mobile1': mobile1,
        'mobile2': mobile2,
        'pdfPath': pdfPath,
      };

  factory CompanyEntity.fromJson(Map<String, dynamic> json) => CompanyEntity(
        id: json['id'] as String,
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        activity: json['activity'] as String? ?? '',
        mobile1: json['mobile1'] as String? ?? '',
        mobile2: json['mobile2'] as String? ?? '',
        pdfPath: json['pdfPath'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, code, name, activity, mobile1, mobile2, pdfPath];
}

class CompanyBankAccountEntity extends Equatable {
  final String id;
  final String companyId;
  final String companyName;
  final String accountNumber;
  final String bankName;
  final String currency;

  const CompanyBankAccountEntity({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.accountNumber,
    required this.bankName,
    required this.currency,
  });

  CompanyBankAccountEntity copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? accountNumber,
    String? bankName,
    String? currency,
  }) {
    return CompanyBankAccountEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'companyName': companyName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'currency': currency,
      };

  factory CompanyBankAccountEntity.fromJson(Map<String, dynamic> json) =>
      CompanyBankAccountEntity(
        id: json['id'] as String,
        companyId: json['companyId'] as String? ?? '',
        companyName: json['companyName'] as String? ?? '',
        accountNumber: json['accountNumber'] as String? ?? '',
        bankName: json['bankName'] as String? ?? '',
        currency: json['currency'] as String? ?? 'جنيه مصرى',
      );

  @override
  List<Object?> get props =>
      [id, companyId, companyName, accountNumber, bankName, currency];
}
