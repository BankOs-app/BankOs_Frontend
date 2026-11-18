import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import 'dashboard_providers.dart';
import 'dashboard_state.dart';

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(loadDashboardData);
    return const DashboardState(status: DashboardStatus.initial);
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(status: DashboardStatus.loading);
    try {
      final getAccountUseCase = ref.read(getAccountUseCaseProvider);
      final getRecentTransactionsUseCase =
          ref.read(getRecentTransactionsUseCaseProvider);

      final account = await getAccountUseCase(const NoParams());
      final transactions = await getRecentTransactionsUseCase(const NoParams());

      state = state.copyWith(
        status: DashboardStatus.success,
        account: account,
        transactions: transactions,
      );
    } catch (e) {
      state = state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void toggleBalanceVisibility() {
    state = state.copyWith(hideBalance: !state.hideBalance);
  }
}
