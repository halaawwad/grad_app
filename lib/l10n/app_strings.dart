import 'package:flutter/widgets.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get isArabic => locale.languageCode == 'ar';

  String get appTitle => 'RoseCare AI';
  String get splashSubtitle => isArabic
      ? 'ذكاء ميداني أنيق لورود أكثر صحة'
      : 'Elegant field intelligence for healthier roses';
  String get skip => isArabic ? 'تخطي' : 'Skip';
  String get getStarted => isArabic ? 'ابدأ' : 'Get Started';
  String get continueText => isArabic ? 'متابعة' : 'Continue';

  String get onboardingTitle1 =>
      isArabic ? 'راقب كل حوض بدقة' : 'Watch every bed breathe';
  String get onboardingDesc1 => isArabic
      ? 'تابع رطوبة التربة والحرارة والرطوبة الجوية عبر معلومات هادئة وسهلة القراءة.'
      : 'Track soil moisture, temperature, and humidity with calm, easy-to-read insights.';
  String get onboardingTitle2 =>
      isArabic ? 'ابق قريبًا من الروبوت' : 'Stay close to your robot';
  String get onboardingDesc2 => isArabic
      ? 'شاهد حالة الروبوت وحركة العمل ومستويات الخزانات من مركز تحكم أنيق.'
      : 'See live robot action, tank levels, and movement status from a polished control center.';
  String get onboardingTitle3 => isArabic
      ? 'استجب قبل أن تتضرر النباتات'
      : 'Respond before plants suffer';
  String get onboardingDesc3 => isArabic
      ? 'استقبل تنبيهات سريعة للجفاف والرش والري وحالة الاتصال.'
      : 'Receive quick alerts for dryness, spraying, irrigation events, and connectivity changes.';

  String get loginTitle => isArabic ? 'تسجيل دخول المزارع الأدمن' : 'Farmer Admin Login';
  String get loginSubtitle => isArabic
      ? 'سجّل الدخول بصفة الأدمن للتحكم بالروبوت ومراقبة التربة وعرض كل بيانات اللوحة.'
      : 'Sign in as the farmer admin to control the robot, monitor soil health, and view all dashboard data.';
  String get adminEmail => isArabic ? 'إيميل الأدمن' : 'Admin Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get adminRoleHint => isArabic
      ? 'صلاحية الأدمن: مزارع مع وصول كامل إلى جميع أقسام التطبيق.'
      : 'Admin role: farmer with full access to all app sections.';
  String get loginAsAdmin => isArabic ? 'دخول كأدمن' : 'Login As Admin';
  String get fullControlPanel => isArabic ? 'لوحة تحكم المزارع الكاملة' : 'Full farmer control panel';
  String get invalidAdminCredentials =>
      isArabic ? 'بيانات الأدمن غير صحيحة.' : 'Invalid admin credentials.';

  String get navHome => isArabic ? 'الرئيسية' : 'Home';
  String get navAlerts => isArabic ? 'التنبيهات' : 'Alerts';
  String get navStatus => isArabic ? 'الحالة' : 'Status';
  String get navHistory => isArabic ? 'السجل' : 'History';
  String get navSettings => isArabic ? 'الإعدادات' : 'Settings';
  String get moistureFab => isArabic ? 'الرطوبة' : 'Moisture';
  String get back => isArabic ? 'رجوع' : 'Back';
  String get refresh => isArabic ? 'تحديث' : 'Refresh';

  String get goodMorningFarmer => isArabic ? 'صباح الخير يا مزارع' : 'Good Morning, Farmer';
  String get dashboardSubtitle => isArabic
      ? 'روبوت العناية بالورد يرسل حالة الحقل بشكل لحظي.'
      : 'Your rose-care robot is reporting fresh field conditions in real time.';
  String get connectedReady => isArabic
      ? 'متصل وجاهز لتنفيذ مهام الحقل.'
      : 'Connected and ready for field actions.';
  String get connectionInterrupted => isArabic
      ? 'انقطع الاتصال. افحص رابط الروبوت.'
      : 'Connection interrupted. Check robot link.';
  String get waterTank => isArabic ? 'خزان الماء' : 'Water Tank';
  String get refillSoon => isArabic ? 'أعد التعبئة قريبًا' : 'Refill soon';
  String get healthyReserve => isArabic ? 'مخزون جيد' : 'Healthy reserve';
  String get sprayTank => isArabic ? 'خزان الرش' : 'Spray Tank';
  String get lowSolution => isArabic ? 'المحلول منخفض' : 'Low solution';
  String get readyForWork => isArabic ? 'جاهز للعمل' : 'Operational';
  String get quickActions => isArabic ? 'إجراءات سريعة' : 'Quick actions';
  String get startRobot => isArabic ? 'تشغيل الروبوت' : 'Start Robot';
  String get stopRobot => isArabic ? 'إيقاف الروبوت' : 'Stop Robot';
  String get manualSpray => isArabic ? 'رش يدوي' : 'Manual Spray';
  String get manualIrrigation => isArabic ? 'ري يدوي' : 'Manual Irrigation';
  String get moistureTrend => isArabic ? 'اتجاه الرطوبة' : 'Moisture trend';
  String get moistureTrendSubtitle => isArabic
      ? 'حركة صحة التربة الأخيرة في أحواض الورد المراقبة.'
      : 'Recent soil health movement across the monitored rose bed.';
  String get recentActivity => isArabic ? 'النشاط الأخير' : 'Recent activity';

  String get robotStatusTitle => isArabic ? 'حالة الروبوت' : 'Robot Status';
  String get robotStatusSubtitle => isArabic
      ? 'عرض تفصيلي لصحة الروبوت والاتصال في نظام الزراعة الذكي.'
      : 'Detailed health and connection view for your smart farming robot.';
  String get currentTask => isArabic ? 'المهمة الحالية' : 'Current task';
  String get connectionStable => isArabic ? 'الاتصال مستقر' : 'Connection stable';
  String get connectionLost => isArabic ? 'الاتصال مفقود' : 'Connection lost';
  String get power => isArabic ? 'الطاقة' : 'Power';
  String get operational => isArabic ? 'قيد التشغيل' : 'Operational';
  String get paused => isArabic ? 'متوقف' : 'Paused';
  String get connection => isArabic ? 'الاتصال' : 'Connection';
  String get robotLinkStatus => isArabic ? 'حالة ربط الروبوت' : 'Robot link status';
  String get online => isArabic ? 'متصل' : 'Online';
  String get offline => isArabic ? 'غير متصل' : 'Offline';
  String get solution => isArabic ? 'محلول' : 'solution';
  String get waterLeft => isArabic ? 'ماء متبق' : 'water left';
  String get sprayStatus => isArabic ? 'حالة الرش' : 'Spray Status';
  String get active => isArabic ? 'نشط' : 'Active';
  String get standby => isArabic ? 'جاهز' : 'Standby';
  String get irrigation => isArabic ? 'الري' : 'Irrigation';
  String get running => isArabic ? 'يعمل' : 'Running';
  String get idle => isArabic ? 'خامل' : 'Idle';
  String get humidity => isArabic ? 'الرطوبة الجوية' : 'Humidity';
  String get fieldHumidity => isArabic ? 'رطوبة الحقل' : 'Field humidity';
  String lastUpdatedStatus(String time, bool online) => isArabic
      ? 'آخر تحديث $time | ${online ? connectionStable : connectionLost}'
      : 'Last updated $time | ${online ? connectionStable : connectionLost}';

  String get soilMoisture => isArabic ? 'رطوبة التربة' : 'Soil Moisture';
  String get soilMoistureSubtitle => isArabic
      ? 'عرض مركز لمستويات الرطوبة والحدود وتوصيات الري.'
      : 'A focused view of moisture levels, thresholds, and irrigation guidance.';
  String get currentMoisture => isArabic ? 'الرطوبة الحالية' : 'Current moisture';
  String lastUpdatedAt(String time) =>
      isArabic ? 'آخر تحديث: $time' : 'Last updated: $time';
  String thresholdLevel(int value, String recommendation) => isArabic
      ? 'مستوى الحد: $value%\n$recommendation'
      : 'Threshold level: $value%\n$recommendation';
  String get historyChart => isArabic ? 'مخطط السجل' : 'History chart';

  String get alertsAndNotifications => isArabic ? 'التنبيهات والإشعارات' : 'Alerts & notifications';
  String get markAllRead => isArabic ? 'تحديد الكل كمقروء' : 'Mark all read';
  String get alertsSubtitle => isArabic
      ? 'تحديثات مهمة من الروبوت وحساسات الرطوبة ومراقبة الخزانات.'
      : 'Critical updates from the field robot, moisture sensors, and tank monitoring.';
  String get noAlertsTitle => isArabic ? 'لا توجد تنبيهات الآن' : 'No alerts right now';
  String get noAlertsDescription => isArabic
      ? 'الروبوت مستقر، والأحواض سليمة، ولا يوجد أي إجراء مطلوب.'
      : 'The robot is calm, the beds are healthy, and no action is needed.';

  String get historyTitle => isArabic ? 'السجل' : 'History';
  String get historySubtitle => isArabic
      ? 'راجع عمليات الري والرش وقياسات الرطوبة وأحداث الروبوت في خط زمني واضح.'
      : 'Review irrigation, spraying, moisture logs, and robot events in a clean timeline.';
  String get noHistoryTitle => isArabic ? 'لا توجد عناصر في هذا العرض' : 'No entries in this view';
  String get noHistoryDescription => isArabic
      ? 'عندما يرسل الروبوت أحداثًا مطابقة ستظهر هنا.'
      : 'When the robot reports matching events, they will appear here.';
  String filterLabel(String filter) {
    switch (filter) {
      case 'all':
        return isArabic ? 'الكل' : 'All';
      case 'spray':
        return isArabic ? 'الرش' : 'Spray';
      case 'irrigation':
        return isArabic ? 'الري' : 'Irrigation';
      case 'alerts':
        return isArabic ? 'التنبيهات' : 'Alerts';
      case 'moisture':
        return isArabic ? 'الرطوبة' : 'Moisture';
      default:
        return filter;
    }
  }

  String get settingsTitle => isArabic ? 'الإعدادات' : 'Settings';
  String get settingsSubtitle => isArabic
      ? 'خصص التنبيهات وقواعد الأتمتة والتكاملات المستقبلية.'
      : 'Personalize alerts, automation rules, and future integrations.';
  String roleLabel(String role) => isArabic
      ? (role == 'admin' ? 'الدور: مزارع أدمن' : 'الدور: مستخدم')
      : (role == 'admin' ? 'Role: Admin Farmer' : 'Role: User');
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get notificationsDescription => isArabic
      ? 'استقبل تنبيهات الرطوبة والخزانات والنشاط'
      : 'Receive moisture, tank, and activity alerts';
  String get robotAutoMode => isArabic ? 'الوضع التلقائي للروبوت' : 'Robot auto mode';
  String get robotAutoModeDescription => isArabic
      ? 'اسمح للروبوت بالاستجابة تلقائيًا'
      : 'Allow the robot to react automatically';
  String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark mode';
  String get darkThemeActive => isArabic ? 'الثيم الداكن مفعّل' : 'Dark theme is active';
  String get lightThemeActive => isArabic ? 'الثيم الفاتح مفعّل' : 'Light theme is active';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabicInterface => isArabic ? 'واجهة عربية' : 'Arabic interface';
  String get englishInterface => isArabic ? 'واجهة إنجليزية' : 'English interface';
  String get arabic => 'العربية';
  String get english => 'English';
  String get moistureThreshold => isArabic ? 'حد الرطوبة' : 'Moisture threshold';
  String currentThreshold(int value) =>
      isArabic ? 'الحد الحالي: $value%' : 'Current threshold: $value%';
  String get aboutApp => isArabic ? 'حول التطبيق' : 'About app';
  String get aboutAppDescription => isArabic
      ? 'RoseCare AI واجهة زراعة ذكية جاهزة للعروض الجامعية وقابلة للتكامل لاحقًا مع Arduino وRaspberry Pi وFirebase وREST وMQTT.'
      : 'RoseCare AI is a mock-data-ready smart farming interface designed for graduation demos and future Arduino, Raspberry Pi, Firebase, REST, or MQTT integration.';
}
