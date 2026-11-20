import 'package:flutter_test/flutter_test.dart';
import 'package:bankos_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bankos_frontend/features/operations/data/datasources/operations_remote_data_source.dart';
import 'package:bankos_frontend/core/network/dio_client.dart';

void main() {
  setUp(() {
    OperationsRemoteDataSourceImpl.onUserLogout();
  });

  tearDown(() {
    OperationsRemoteDataSourceImpl.onUserLogout();
  });

  group('New Account Registration & Isolation Suite', () {
    test('1. New user registration starts with zero balance and zero transactions', () async {
      final authDs = AuthRemoteDataSourceImpl(dioClient: DioClient());
      final opsDs = OperationsRemoteDataSourceImpl(dioClient: DioClient());

      // Register new user under Bancolombia
      final user = await authDs.register(
        fullName: 'Mateo Valencia',
        documentNumber: '1098765432',
        email: 'mateo.valencia@gmail.com',
        phone: '3009998877',
        password: 'ClaveSegura123',
        transactionalPin: '5678',
        tenantSlug: 'banco-lombia',
      );

      expect(user.name, 'Mateo Valencia');
      expect(user.email, 'mateo.valencia@gmail.com');

      // Verify accounts
      final accounts = await opsDs.getAccounts();
      expect(accounts.isNotEmpty, true);
      final primaryAcc = accounts.first;

      // Balance must strictly be 0.00
      expect(primaryAcc.balance, 0.0);
      expect(primaryAcc.accountNumber, isNot('7007007001'));
      expect(primaryAcc.accountNumber.startsWith('70'), true);
      expect(primaryAcc.accountNumber.length, 10);

      // Verify cards
      final cards = await opsDs.getCards();
      expect(cards.isNotEmpty, true);
      final primaryCard = cards.first;
      expect(primaryCard.availableBalance, 0.0);
      expect(primaryCard.cardNumber, primaryAcc.accountNumber);
      expect(primaryCard.cardNumber, isNot('7007007001'));
      expect(primaryCard.cardHolder, 'Mateo Valencia');

      // Verify history is strictly clean (0 transactions)
      final history = await opsDs.getHistory();
      expect(history.isEmpty, true);
    });

    test('2. Unique account number is generated and never repeated across banks or customers', () async {
      final opsDs = OperationsRemoteDataSourceImpl(dioClient: DioClient());

      OperationsRemoteDataSourceImpl.initNewUserSession(
        fullName: 'Usuario Uno',
        email: 'uno@gmail.com',
        tenantSlug: 'banco-bogota',
      );
      final accounts1 = await opsDs.getAccounts();
      final num1 = accounts1.first.accountNumber;
      expect(num1.startsWith('10'), true);
      expect(num1, isNot('7007007001'));

      OperationsRemoteDataSourceImpl.initNewUserSession(
        fullName: 'Usuario Dos',
        email: 'dos@gmail.com',
        tenantSlug: 'banco-santander',
      );
      final accounts2 = await opsDs.getAccounts();
      final num2 = accounts2.first.accountNumber;
      expect(num2.startsWith('90'), true);
      expect(num2, isNot('7007007001'));
      expect(num2, isNot(num1));
    });

    test('3. New user can log in successfully after logout using registered password or PIN', () async {
      final authDs = AuthRemoteDataSourceImpl(dioClient: DioClient());

      // Register new user
      await authDs.register(
        fullName: 'Sara Bermúdez',
        documentNumber: '1122334455',
        email: 'sara.bermudez@gmail.com',
        phone: '3157778899',
        password: 'PasswordSara2026',
        transactionalPin: '4321',
        tenantSlug: 'banco-nu',
      );

      // Simulate logout
      OperationsRemoteDataSourceImpl.onUserLogout();

      // Login back with registered password
      final loggedInUser = await authDs.login(
        'sara.bermudez@gmail.com',
        'PasswordSara2026',
        tenantSlug: 'banco-nu',
      );

      expect(loggedInUser.email, 'sara.bermudez@gmail.com');
      expect(loggedInUser.name, 'Sara Bermúdez');

      // Operations data should still have zero balance and clean slate
      final opsDs = OperationsRemoteDataSourceImpl(dioClient: DioClient());
      final accounts = await opsDs.getAccounts();
      expect(accounts.first.balance, 0.0);
      expect(accounts.first.accountNumber.startsWith('80'), true);

      final history = await opsDs.getHistory();
      expect(history.isEmpty, true);
    });
  });
}
