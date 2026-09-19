import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../l10n/app_strings.dart';
import '../main.dart';
import '../services/farm_service.dart';
import '../theme/app_colors.dart';
import '../widgets/live_telemetry_banner.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.service,
  });

  final FarmService service;

  @override
  Widget build(BuildContext context) {
    final appController = RoseCareApp.of(context);
    final strings = AppStrings.of(context);
    final isArabic = service.language == 'ar';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        Text(strings.settingsTitle,
            style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          strings.settingsSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        LiveTelemetryBanner(
          updatedLabel: strings
              .lastUpdatedAt(_formatTime(service.robotStatus.lastUpdated)),
          onlineLabel: strings.online,
          offlineLabel: strings.offline,
          soilLabel: strings.soilMoisture,
          humidityLabel: strings.humidity,
          waterLabel: strings.waterTank,
          temperatureLabel: 'Temperature',
          robot: service.robotStatus,
          moisture: service.moisture,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child:
                    const Icon(Icons.person_rounded, color: AppColors.forest),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.profileName,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(service.profileEmail,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      strings.roleLabel(service.role ?? 'user'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Material(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                value: service.notificationsEnabled,
                onChanged: service.toggleNotifications,
                title: Text(strings.notifications),
                subtitle: Text(strings.notificationsDescription),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: service.autoMode,
                onChanged: service.toggleAutoMode,
                title: Text(strings.robotAutoMode),
                subtitle: Text(strings.robotAutoModeDescription),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(strings.darkMode),
                subtitle: Text(service.darkMode
                    ? strings.darkThemeActive
                    : strings.lightThemeActive),
                trailing: Switch(
                  value: service.darkMode,
                  onChanged: (value) async {
                    await service.toggleDarkMode(value);
                    appController.setDarkMode(value);
                  },
                ),
                onTap: () async {
                  final nextValue = !service.darkMode;
                  await service.toggleDarkMode(nextValue);
                  appController.setDarkMode(nextValue);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(strings.language),
                subtitle: Text(isArabic
                    ? strings.arabicInterface
                    : strings.englishInterface),
                trailing: Text(isArabic ? strings.arabic : strings.english),
                onTap: () =>
                    _showLanguagePicker(context, service, appController),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.aboutApp,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                strings.aboutAppDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    FarmService service,
    AppController appController,
  ) async {
    final strings = AppStrings.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(strings.english),
                trailing: service.language == 'en'
                    ? const Icon(Icons.check_rounded, color: AppColors.forest)
                    : null,
                onTap: () => Navigator.of(context).pop('en'),
              ),
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: Text(strings.arabic),
                trailing: service.language == 'ar'
                    ? const Icon(Icons.check_rounded, color: AppColors.forest)
                    : null,
                onTap: () => Navigator.of(context).pop('ar'),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    await service.updateLanguage(selected);
    appController.setLanguage(selected);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
