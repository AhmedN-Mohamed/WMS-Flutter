import 'package:equatable/equatable.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/system_code_entity.dart';

class SystemCodesState extends Equatable {
  final RequestStatus status;
  final SystemCodeCategory selectedCategory;
  final List<SystemCodeEntity> codes;
  final SystemCodeEntity? selectedCode;
  final String searchQuery;
  final String? actionMessage;

  const SystemCodesState({
    this.status = RequestStatus.initial,
    this.selectedCategory = SystemCodeCategory.users,
    this.codes = const [],
    this.selectedCode,
    this.searchQuery = '',
    this.actionMessage,
  });

  List<SystemCodeEntity> get filteredCodes {
    if (searchQuery.trim().isEmpty) return codes;
    final q = searchQuery.trim().toLowerCase();
    return codes
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q),
        )
        .toList();
  }

  SystemCodesState copyWith({
    RequestStatus? status,
    SystemCodeCategory? selectedCategory,
    List<SystemCodeEntity>? codes,
    SystemCodeEntity? selectedCode,
    bool clearSelectedCode = false,
    String? searchQuery,
    String? actionMessage,
  }) {
    return SystemCodesState(
      status: status ?? this.status,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      codes: codes ?? this.codes,
      selectedCode:
          clearSelectedCode ? null : (selectedCode ?? this.selectedCode),
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedCategory,
        codes,
        selectedCode,
        searchQuery,
        actionMessage,
      ];
}
