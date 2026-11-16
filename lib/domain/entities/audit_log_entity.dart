import 'package:equatable/equatable.dart';

class AuditLogEntity extends Equatable {
  final String id;
  final String userCode;
  final String userName;
  final String action;
  final String module;
  final String details;
  final DateTime timestamp;

  const AuditLogEntity({
    required this.id,
    required this.userCode,
    required this.userName,
    required this.action,
    required this.module,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userCode': userCode,
        'userName': userName,
        'action': action,
        'module': module,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AuditLogEntity.fromJson(Map<String, dynamic> json) => AuditLogEntity(
        id: json['id'] as String,
        userCode: json['userCode'] as String? ?? '002',
        userName: json['userName'] as String? ?? 'محمد أسعد',
        action: json['action'] as String? ?? '',
        module: json['module'] as String? ?? '',
        details: json['details'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );

  @override
  List<Object?> get props =>
      [id, userCode, userName, action, module, details, timestamp];
}
