import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/request_status.dart';
import '../../../domain/entities/system_code_entity.dart';
import '../../../domain/repositories/wms_repository.dart';
import 'app_shell_state.dart';

class AppShellCubit extends Cubit<AppShellState> {
  final WmsRepository _repository;

  AppShellCubit(this._repository) : super(const AppShellState());

  void loadSession() {
    final user = _repository.getCurrentUser();
    final users = _repository.getSystemCodes(SystemCodeCategory.users);
    final logs = _repository.getAuditLogs();
    emit(
      state.copyWith(
        status: RequestStatus.success,
        currentUserCode: user.code,
        currentUserName: user.name,
        availableUsers: users,
        auditLogs: logs,
      ),
    );
  }

  void selectTab(AppNavTab tab, {String? invoiceId}) {
    emit(
      state.copyWith(
        selectedTab: tab,
        focusedInvoiceId: invoiceId,
        clearFocusedInvoice: invoiceId == null,
        auditLogs: _repository.getAuditLogs(),
      ),
    );
  }

  Future<void> switchUser(SystemCodeEntity userCodeEntity) async {
    await _repository.setCurrentUser(
      code: userCodeEntity.code,
      name: userCodeEntity.name,
    );
    loadSession();
  }

  void refreshLogs() {
    emit(
      state.copyWith(
        availableUsers: _repository.getSystemCodes(SystemCodeCategory.users),
        auditLogs: _repository.getAuditLogs(),
      ),
    );
  }
}
