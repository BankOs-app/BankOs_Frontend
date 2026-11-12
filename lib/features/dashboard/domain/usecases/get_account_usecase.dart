import '../../../../core/usecases/usecase.dart';
import '../entities/account_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetAccountUseCase implements UseCase<AccountEntity, NoParams> {
  final DashboardRepository repository;

  GetAccountUseCase(this.repository);

  @override
  Future<AccountEntity> call(NoParams params) {
    return repository.getAccountSummary();
  }
}
