import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/season_provider.dart';
import 'core/providers/crop_provider.dart';
import 'core/providers/product_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/chat_inbox_provider.dart';
import 'core/providers/factory_contract_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/shell_tab_bridge.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/onboarding_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const HasadApp());
}

class HasadApp extends StatelessWidget {
  const HasadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SeasonProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatInboxProvider()),
        // عقود المصنع فقط — شاشات التاجر لا تستخدم هذا المزوّد
        ChangeNotifierProvider(create: (_) => FactoryContractProvider()),
        Provider(create: (_) => ShellTabBridge()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp(
            title: 'حصاد',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: langProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: langProvider.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
            home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
