import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../../../domain/repositories/wms_repository.dart';
import 'system_codes_state.dart';

class SystemCodesCubit extends Cubit<SystemCodesState> {
  final WmsRepository _repository;

  SystemCodesCubit(this._repository) : super(const SystemCodesState());

  void loadCodes([SystemCodeCategory? category]) {
    final targetCategory = category ?? state.selectedCategory;
    final list = _repository.getSystemCodes(targetCategory);
    emit(
      state.copyWith(
        status: RequestStatus.success,
        selectedCategory: targetCategory,
        codes: list,
        clearSelectedCode: true,
      ),
    );
  }

  void selectCategory(SystemCodeCategory category) {
    loadCodes(category);
  }

  void selectCode(SystemCodeEntity? code) {
    emit(
      state.copyWith(
        selectedCode: code,
        clearSelectedCode: code == null,
      ),
    );
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> saveCode({
    String? id,
    required String code,
    required String name,
  }) async {
    if (name.trim().isEmpty) return;
    final entity = SystemCodeEntity(
      id: id ?? 'sc_${DateTime.now().microsecondsSinceEpoch}',
      category: state.selectedCategory,
      code: code.trim().isEmpty
          ? '${state.codes.length + 1}'.padLeft(3, '0')
          : code.trim(),
      name: name.trim(),
    );
    await _repository.saveSystemCode(entity);
    final updated = _repository.getSystemCodes(state.selectedCategory);
    emit(
      state.copyWith(
        status: RequestStatus.success,
        codes: updated,
        selectedCode: entity,
        actionMessage: 'تم حفظ البيان في ${state.selectedCategory.arabicTitle}',
      ),
    );
  }

  Future<void> deleteSelectedCode() async {
    final current = state.selectedCode;
    if (current == null) return;
    await _repository.deleteSystemCode(current.id);
    final updated = _repository.getSystemCodes(state.selectedCategory);
    emit(
      state.copyWith(
        status: RequestStatus.success,
        codes: updated,
        clearSelectedCode: true,
        actionMessage: 'تم حذف "${current.name}" بنجاح',
      ),
    );
  }
}
