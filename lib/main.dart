import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/design/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/config/app_config_provider.dart';
import 'core/config/theme_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter framework error: ${details.exception}');
      debugPrintStack(stackTrace: details.stack);
    };

    WidgetsBinding.instance.platformDispatcher.onError =
        (Object error, StackTrace stack) {
      debugPrint('Uncaught async error: $error');
      debugPrintStack(stackTrace: stack);
      // Handled to avoid silent process termination in debug sessions.
      return true;
    };

    // Warm up SharedPreferences on iOS; if channel fails, app still opens (login save may need retry)
    try {
      await SharedPreferences.getInstance();
    } on PlatformException catch (e) {
      if (e.code == 'channel-error') {
        debugPrint(
            'SharedPreferences channel not ready at startup — app will continue');
      } else {
        rethrow;
      }
    }

    // App config: remote GET /config/app disabled — use `initialize()` again to re-enable.
    final configProvider = AppConfigProvider();
    // configProvider.initialize();
    configProvider.skipRemoteFetch();

    // Initialize theme provider; if prefs fail, use defaults
    final themeProvider = ThemeProvider.instance;
    try {
      await themeProvider.ensureInitialized();
    } catch (e) {
      debugPrint('ThemeProvider init error (using defaults): $e');
    }

    runApp(EducationalApp(
      configProvider: configProvider,
      themeProvider: themeProvider,
    ));
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

class EducationalApp extends StatelessWidget {
  final AppConfigProvider configProvider;
  final ThemeProvider themeProvider;

  const EducationalApp({
    super.key,
    required this.configProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: configProvider,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: themeProvider,
          builder: (context, _) {
            return MaterialApp.router(
              title: configProvider.config?.appName ?? 'Medex',
              debugShowCheckedModeBanner: false,

              // RTL & Localization
              locale: themeProvider.locale,
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // Theme - use API config if available
              theme: AppTheme.lightTheme(configProvider.config?.theme),
              darkTheme: AppTheme.darkTheme(configProvider.config?.theme),
              themeMode: themeProvider.themeMode,

              // Router
              routerConfig: AppRouter.router,
            );
          },
        );
      },
    );
  }
}
