import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/ui/bloc/compass/compass.dart';
import 'package:financial_freedom/ui/pages/home/home_compass_page.dart';
import 'package:financial_freedom/ui/pages/manage/manage_hub_page.dart';
import 'package:financial_freedom/ui/pages/settings/settings_page.dart';
import 'package:financial_freedom/core/navigation/app_state.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  late final CompassBloc _compassBloc;

  @override
  void initState() {
    super.initState();
    _compassBloc = getIt<CompassBloc>()..add(const LoadCompassEvent());
  }

  @override
  void dispose() {
    _compassBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BlocProvider<CompassBloc>.value(
            value: _compassBloc,
            child: const HomeCompassBody(),
          ),
          const ManageHubPage(),
          SettingsPage(
            onResetComplete: () {
              // After reset, trigger AppEntryPoint to show welcome screen
              resetAppToWelcome?.call();
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Kompas',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Kelola',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_currentIndex) {
      case 0:
        return AppBar(
          title: const Text('Financial Freedom'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _compassBloc.add(const RefreshCompassEvent());
              },
            ),
          ],
        );
      case 1:
        return AppBar(
          title: const Text('Kelola Data'),
          centerTitle: true,
        );
      case 2:
        return AppBar(
          title: const Text('Pengaturan'),
          centerTitle: true,
        );
      default:
        return AppBar(title: const Text('Financial Freedom'));
    }
  }
}
