import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/farm_service.dart';
import '../theme/app_colors.dart';
import '../widgets/alert_tile.dart';
import '../widgets/section_heading.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.service,
  });

  final FarmService service;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isSendingMode = false;

  Future<void> _setEnvironmentMode(String mode) async {
    if (_isSendingMode) {
      return;
    }

    setState(() => _isSendingMode = true);

    try {
      await widget.service.setRobotEnvironmentMode(mode);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mode == 'indoor'
                ? 'Indoor mode command sent to Raspberry Pi'
                : 'Outdoor mode command sent to Raspberry Pi',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send robot mode command'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingMode = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final service = widget.service;
    final robot = service.robotStatus;
    final moisture = service.moisture;
    final alerts = service.alerts.take(4).toList();
    final isArabic = strings.isArabic;
    final displayedTankHeight = (12 - robot.tankDistanceCm).clamp(0.0, 12.0);
    final displayedTankLow = displayedTankHeight <= 2;
    final soilStatus = moisture.displayStatus;
    final soilStatusColor =
        soilStatus == 'DRY' ? AppColors.warning : AppColors.success;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        Text(
          isArabic ? 'متابعة الحقل' : 'Field overview',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          isArabic
              ? 'واجهة بسيطة تعرض رطوبة التربة، حالة خزّان المبيد، وحالة المضخات والتحكم بالمود.'
              : 'A simple view for soil moisture, pesticide tank status, pump activity, and mode control.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        _EnvironmentModeHeroCard(
          isArabic: isArabic,
          currentModeLabel: robot.environmentModeLabel,
          currentCommand: robot.lastModeCommand,
          isBusy: _isSendingMode,
          isIndoorSelected: robot.isIndoorMode,
          onIndoorTap: () => _setEnvironmentMode('indoor'),
          onOutdoorTap: () => _setEnvironmentMode('outdoor'),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.soilMoisture,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _StatusPill(
                    label: soilStatus,
                    backgroundColor: soilStatusColor.withValues(alpha: 0.12),
                    foregroundColor: soilStatusColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                strings.lastUpdatedAt(_formatTime(robot.lastUpdated)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    soilStatus,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'حالة التربة: $soilStatus'
                          : 'Status: $soilStatus',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                moisture.recommendation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isArabic ? 'خزان المبيد الخلفي' : 'Rear pesticide tank',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _StatusPill(
                    label: displayedTankLow
                        ? (isArabic ? 'تحذير' : 'Warning')
                        : 'OK',
                    backgroundColor:
                        (displayedTankLow ? AppColors.warning : AppColors.leaf)
                            .withValues(alpha: 0.12),
                    foregroundColor:
                        displayedTankLow ? AppColors.warning : AppColors.leaf,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: (displayedTankLow
                              ? AppColors.warning
                              : AppColors.leaf)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        displayedTankHeight.toStringAsFixed(1),
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: displayedTankLow
                                      ? AppColors.warning
                                      : AppColors.forest,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? 'الارتفاع الحالي للمبيد'
                              : 'Current pesticide height',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayedTankLow
                              ? (isArabic
                                  ? 'بقي مستوى قليل جدًا داخل الخزان.'
                                  : 'Only a very small level remains in the tank.')
                              : (isArabic
                                  ? 'المستوى الحالي مناسب للعمل.'
                                  : 'The current level is suitable for work.'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                displayedTankLow
                    ? (isArabic
                        ? 'تحذير: الخزان فيه كمية قليلة من المبيد. حضّر التعبئة.'
                        : 'Warning: the tank has a low amount of pesticide. Prepare a refill.')
                    : (isArabic
                        ? 'الخزان فيه كمية مناسبة من المبيد.'
                        : 'The tank has a suitable amount of pesticide.'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: displayedTankLow ? AppColors.warning : null,
                      fontWeight: displayedTankLow ? FontWeight.w700 : null,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PumpStatusCard(
          title: strings.irrigation,
          status: robot.irrigationEnabled,
          activeLabel: isArabic
              ? 'مضخة الري تعمل الآن'
              : 'Irrigation pump is running now',
          idleLabel: isArabic
              ? 'مضخة الري متوقفة حاليًا'
              : 'Irrigation pump is currently off',
          detail: isArabic
              ? 'يتم السحب من الخزان الرئيسي لري التربة عند الحاجة.'
              : 'Water is drawn from the main tank to irrigate the soil when needed.',
          tankLabel:
              '${strings.waterTank}: ${robot.waterTankLevel}% | Water height: ${robot.waterHeightCm.toStringAsFixed(1)}',
          icon: Icons.water_drop_rounded,
          activeColor: AppColors.info,
        ),
        const SizedBox(height: 16),
        _PumpStatusCard(
          title: isArabic ? 'تعبئة خزان المبيد' : 'Pesticide tank refill',
          status: robot.sprayEnabled,
          activeLabel: isArabic
              ? 'مضخة المبيد تعمل وتعبئ الخزان الخلفي'
              : 'Pesticide pump is running and refilling the rear tank',
          idleLabel: isArabic
              ? 'مضخة تعبئة المبيد متوقفة حاليًا'
              : 'Pesticide refill pump is currently off',
          detail: isArabic
              ? 'يتم نقل المبيد من الخزان الرئيسي إلى الخزان الفرعي على ظهر الروبوت.'
              : 'Pesticide is moved from the main tank into the smaller rear tank on the robot.',
          tankLabel: displayedTankLow
              ? (isArabic ? 'تحذير: كمية قليلة' : 'Warning: low amount')
              : (isArabic ? 'الحالة: جيدة' : 'Status: good'),
          icon: Icons.local_shipping_rounded,
          activeColor: AppColors.leaf,
        ),
        const SizedBox(height: 24),
        SectionHeading(
          title: strings.alertsAndNotifications,
          actionLabel: strings.markAllRead,
          onActionTap: service.markAlertsRead,
        ),
        const SizedBox(height: 10),
        if (alerts.isEmpty)
          _InfoCard(
            child: Text(
              isArabic
                  ? 'لا توجد تنبيهات جديدة حاليًا.'
                  : 'No new alerts right now.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        else
          ...alerts.map((alert) => AlertTile(alert: alert)),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _EnvironmentModeHeroCard extends StatelessWidget {
  const _EnvironmentModeHeroCard({
    required this.isArabic,
    required this.currentModeLabel,
    required this.currentCommand,
    required this.isBusy,
    required this.isIndoorSelected,
    required this.onIndoorTap,
    required this.onOutdoorTap,
  });

  final bool isArabic;
  final String currentModeLabel;
  final String currentCommand;
  final bool isBusy;
  final bool isIndoorSelected;
  final VoidCallback onIndoorTap;
  final VoidCallback onOutdoorTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.forest,
            AppColors.leaf,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isArabic ? 'تبديل بيئة الروبوت' : 'Robot Environment Mode',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  currentModeLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'من هنا بدّل مباشرة بين المود الداخلي والمود الخارجي. الأمر الحالي المرسل للرازبيري: $currentCommand'
                : 'Switch directly between indoor and outdoor mode here. Current command sent to Raspberry Pi: $currentCommand',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _EnvironmentModeActionButton(
                  label: isArabic ? 'Mode 1\nداخلي' : 'Mode 1\nIndoor',
                  icon: Icons.home_rounded,
                  isSelected: isIndoorSelected,
                  isBusy: isBusy,
                  onTap: onIndoorTap,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _EnvironmentModeActionButton(
                  label: isArabic ? 'Mode 2\nخارجي' : 'Mode 2\nOutdoor',
                  icon: Icons.park_rounded,
                  isSelected: !isIndoorSelected,
                  isBusy: isBusy,
                  onTap: onOutdoorTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnvironmentModeActionButton extends StatelessWidget {
  const _EnvironmentModeActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isBusy,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isBusy ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.24),
          ),
        ),
        child: Column(
          children: [
            if (isBusy)
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSelected ? AppColors.forest : Colors.white,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 28,
                color: isSelected ? AppColors.forest : Colors.white,
              ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.forest : Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PumpStatusCard extends StatelessWidget {
  const _PumpStatusCard({
    required this.title,
    required this.status,
    required this.activeLabel,
    required this.idleLabel,
    required this.detail,
    required this.tankLabel,
    required this.icon,
    required this.activeColor,
  });

  final String title;
  final bool status;
  final String activeLabel;
  final String idleLabel;
  final String detail;
  final String tankLabel;
  final IconData icon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final color = status ? activeColor : AppColors.sand;
    final foreground =
        status ? activeColor : Theme.of(context).textTheme.bodyLarge?.color;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _StatusPill(
                label: status ? 'ON' : 'OFF',
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: status ? activeColor : AppColors.forest,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            status ? activeLabel : idleLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: status ? activeColor : null,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            tankLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
