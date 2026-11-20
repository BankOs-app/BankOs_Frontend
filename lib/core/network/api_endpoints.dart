import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

abstract class ApiEndpoints {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bankosbackend-production.up.railway.app/api/v1',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return 'https://bankosbackend-production.up.railway.app/api/v1';
  }

  // Legacy / Direct accessors
  static const String accountSummary = '/accounts/me';
  static const String recentTransactions = '/transactions';

  // Identity / Auth
  static const String login = '/identity/login';
  static const String me = '/identity/me';
  static const String devToken = '/identity/token';

  // Customers
  static const String registerCustomer = '/customers/register';

  // Tenants
  static const String tenants = '/tenants';
  static String tenantDetail(String slug) => '/tenants/$slug';
  static String tenantSettings(String slug) => '/tenants/$slug/settings';

  // Accounts
  static const String myAccounts = '/accounts/me';
  static String tenantAccounts(String slug) => '/tenants/$slug/accounts';
  static String accountByNumber(String slug, String accountNumber) =>
      '/tenants/$slug/accounts/$accountNumber';

  // Transactions
  static String deposits(String slug) => '/tenants/$slug/transactions/deposits';
  static String withdrawals(String slug) =>
      '/tenants/$slug/transactions/withdrawals';
  static String transfers(String slug) =>
      '/tenants/$slug/transactions/transfers';
  static String previewTransfer(String slug) =>
      '/tenants/$slug/transactions/preview';
  static String transactions(String slug) => '/tenants/$slug/transactions';
}
