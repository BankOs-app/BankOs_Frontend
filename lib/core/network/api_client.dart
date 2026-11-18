abstract class ApiClient {
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  });
}

/// In-memory mock API client providing default responses
/// that match the BankOS contract until real backend endpoints are hooked up.
class MockApiClient implements ApiClient {
  const MockApiClient();

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 100));

    if (endpoint == '/account/summary') {
      return {
        'id': 'acc_001',
        'accountNumber': '4829',
        'accountType': 'Checking Account',
        'balance': 12450000.0,
        'currency': 'COP',
        'isActive': true,
      };
    }

    if (endpoint == '/transactions/recent') {
      return {
        'transactions': [
          {
            'id': 'tx_001',
            'title': 'Received Transfer',
            'subtitle': 'From: John Doe • Today 10:45 AM',
            'amount': 450000.0,
            'currency': 'COP',
            'isPositive': true,
            'category': 'transfer',
            'date': DateTime.now().toIso8601String(),
          },
          {
            'id': 'tx_002',
            'title': 'Supermarket Purchase',
            'subtitle': 'Debit Card • Yesterday',
            'amount': 125000.0,
            'currency': 'COP',
            'isPositive': false,
            'category': 'shopping',
            'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'id': 'tx_003',
            'title': 'Mobile Top-up',
            'subtitle': 'Mobile Banking • Nov 08',
            'amount': 20000.0,
            'currency': 'COP',
            'isPositive': false,
            'category': 'utilities',
            'date': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          },
        ]
      };
    }

    throw Exception('Endpoint not found: $endpoint');
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {'status': 'success', 'data': body};
  }
}
