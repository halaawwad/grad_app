import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_controller.dart';
import 'l10n/app_strings.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoseCareApp());
}

class RoseCareApp extends StatefulWidget {
  const RoseCareApp({super.key});

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppControllerScope>();
    assert(scope != null, 'No AppController found in context');
    return scope!.controller;
  }

  @override
  State<RoseCareApp> createState() => _RoseCareAppState();
}

class _RoseCareAppState extends State<RoseCareApp> {
  final AppController _controller = AppController();

  @override
  Widget build(BuildContext context) {
    return _AppControllerScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppStrings.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _controller.themeMode,
            locale: _controller.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class _AppControllerScope extends InheritedWidget {
  const _AppControllerScope({
    required this.controller,
    required super.child,
  });

  final AppController controller;

  @override
  bool updateShouldNotify(_AppControllerScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
