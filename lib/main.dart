import 'package:flutter/material.dart';

void main() {
  runApp(const BankOsApp());
}

class BankOsApp extends StatelessWidget {
  const BankOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BankOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate 900
          primary: const Color(0xFF1E3A8A), // Navy blue
          secondary: const Color(0xFF059669), // Emerald
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const BankOsHomePage(),
    );
  }
}

class BankOsHomePage extends StatefulWidget {
  const BankOsHomePage({super.key});

  @override
  State<BankOsHomePage> createState() => _BankOsHomePageState();
}

class _BankOsHomePageState extends State<BankOsHomePage> {
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance, size: 26),
            SizedBox(width: 8),
            Text(
              'BankOS',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No pending notifications.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Greeting
            const Text(
              'Hello, World!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome to your modern BankOS digital banking',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
            ),
            const SizedBox(height: 24),

            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _hideBalance ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _hideBalance = !_hideBalance;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hideBalance ? '••••••••' : '\$12,450,000 COP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Checking Account •••• 4829',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Chip(
                        label: Text(
                          'Active',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        backgroundColor: Color(0xFF10B981),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.send_rounded,
                  label: 'Transfer',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    _showActionDialog(context, 'Bank transfer initiated');
                  },
                ),
                _buildActionButton(
                  icon: Icons.download_rounded,
                  label: 'Receive',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    _showActionDialog(context, 'Your receiving account number is 4829');
                  },
                ),
                _buildActionButton(
                  icon: Icons.receipt_long_rounded,
                  label: 'Bills',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    _showActionDialog(context, 'Utility bills payment module');
                  },
                ),
                _buildActionButton(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  color: const Color(0xFF6B7280),
                  onTap: () {
                    _showActionDialog(context, 'More menu options');
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionTile(
              icon: Icons.arrow_downward,
              iconColor: const Color(0xFF10B981),
              title: 'Received Transfer',
              subtitle: 'From: John Doe • Today 10:45 AM',
              amount: '+\$450,000 COP',
              isPositive: true,
            ),
            _buildTransactionTile(
              icon: Icons.shopping_bag_outlined,
              iconColor: const Color(0xFFEF4444),
              title: 'Supermarket Purchase',
              subtitle: 'Debit Card • Yesterday',
              amount: '-\$125,000 COP',
              isPositive: false,
            ),
            _buildTransactionTile(
              icon: Icons.phone_android,
              iconColor: const Color(0xFF3B82F6),
              title: 'Mobile Top-up',
              subtitle: 'Mobile Banking • Nov 08',
              amount: '-\$20,000 COP',
              isPositive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.blueGrey[400], fontSize: 12),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isPositive ? const Color(0xFF10B981) : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
