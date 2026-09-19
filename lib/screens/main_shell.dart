import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/farm_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell_background.dart';
import 'home_dashboard_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.service,
  });

  final FarmService service;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void dispose() {
    widget.service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return AnimatedBuilder(
      animation: widget.service,
      builder: (context, _) {
        final screens = [
          HomeDashboardScreen(service: widget.service),
          SettingsScreen(service: widget.service),
        ];

        return Scaffold(
          extendBody: true,
          body: AppShellBackground(
            child: IndexedStack(
              index: _index,
              children: [
                for (final screen in screens) SafeArea(child: screen),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: NavigationBar(
                selectedIndex: _index,
                backgroundColor:
                    Theme.of(context).navigationBarTheme.backgroundColor,
                indicatorColor: AppColors.cream,
                onDestinationSelected: (index) =>
                    setState(() => _index = index),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: strings.navHome,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings_rounded),
                    label: strings.navSettings,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
