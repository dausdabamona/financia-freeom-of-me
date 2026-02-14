import 'package:flutter/material.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/core/navigation/app_state.dart';
import 'package:financial_freedom/domain/repositories/account_repository.dart';
import 'package:financial_freedom/ui/pages/shell/main_shell_page.dart';
import 'package:financial_freedom/ui/pages/onboarding/onboarding_flow_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const FinancialFreedomApp());
}

class FinancialFreedomApp extends StatelessWidget {
  const FinancialFreedomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Freedom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Green - symbolizing growth & freedom
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      home: const AppEntryPoint(),
    );
  }
}

/// Entry point that checks if user needs onboarding
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoading = true;
  bool _isFirstTimeUser = true;

  @override
  void initState() {
    super.initState();
    resetAppToWelcome = _resetToWelcome;
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    final accountRepo = getIt<AccountRepository>();
    final accountsResult = await accountRepo.getAllAccounts();

    accountsResult.fold(
      (failure) {
        // If error, assume first time user
        setState(() {
          _isFirstTimeUser = true;
          _isLoading = false;
        });
      },
      (accounts) {
        setState(() {
          _isFirstTimeUser = accounts.isEmpty;
          _isLoading = false;
        });
      },
    );
  }

  void _resetToWelcome() {
    setState(() {
      _isFirstTimeUser = true;
    });
  }

  void _navigateToOnboarding() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const OnboardingFlowPage(),
      ),
    );

    // If completed onboarding, refresh state
    if (result == true) {
      setState(() {
        _isFirstTimeUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat...'),
            ],
          ),
        ),
      );
    }

    if (_isFirstTimeUser) {
      return _WelcomeScreen(onStartOnboarding: _navigateToOnboarding);
    }

    return const MainShellPage();
  }
}

/// Welcome screen for first-time users
class _WelcomeScreen extends StatelessWidget {
  final VoidCallback onStartOnboarding;

  const _WelcomeScreen({required this.onStartOnboarding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),

              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore,
                  size: 64,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Financial Freedom',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Kompas Kebebasan Finansialmu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Philosophy message
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.format_quote, color: Colors.green),
                      const SizedBox(height: 12),
                      Text(
                        '"Kebebasan finansial bukan tentang jadi kaya.\n'
                        'Tapi tentang memiliki waktumu sendiri."',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // What to expect
              Text(
                'Dalam beberapa menit, kamu akan:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              _ExpectationItem(
                icon: Icons.visibility,
                text: 'Melihat realita keuanganmu dengan jujur',
              ),
              _ExpectationItem(
                icon: Icons.explore,
                text: 'Mengetahui posisimu dalam perjalanan',
              ),
              _ExpectationItem(
                icon: Icons.directions_walk,
                text: 'Mendapat langkah kecil pertamamu',
              ),

              const SizedBox(height: 32),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStartOnboarding,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Mulai Perjalanan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Privacy note
              Text(
                'Semua datamu tersimpan lokal di perangkatmu.\nTidak ada cloud, tidak ada iklan.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpectationItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ExpectationItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
