import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../main.dart';
import '../services/farm_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell_background.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: 'awwadh311@gmail.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'hala1234',
  );
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: AppShellBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    strings.loginTitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forest.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: strings.adminEmail,
                            hintText: 'awwadh311@gmail.com',
                            prefixIcon: const Icon(Icons.alternate_email_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: strings.password,
                            hintText: 'hala1234',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 14),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              _errorText!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.danger,
                                  ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            strings.adminRoleHint,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.muted,
                                ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : () => _enterApp(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.forest,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(strings.loginAsAdmin),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.sand,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(strings.fullControlPanel),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.sand,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _enterApp(BuildContext context) async {
    final strings = AppStrings.of(context);

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final service = FarmService();
    try {
      await service.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await service.initialize();
      if (!context.mounted) {
        service.dispose();
        return;
      }
      final appController = RoseCareApp.of(context);
      appController.setDarkMode(service.darkMode);
      appController.setLanguage(service.language);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => MainShell(service: service)),
      );
    } catch (error) {
      service.dispose();
      if (!mounted) {
        return;
      }
      final errorMessage = error.toString();
      setState(() {
        _errorText = errorMessage.contains('status 401')
            ? strings.invalidAdminCredentials
            : 'Unable to reach backend at ${FarmService.defaultApiBaseUrl}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
