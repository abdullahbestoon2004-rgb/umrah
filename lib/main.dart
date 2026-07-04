import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'services/supabase_service.dart';
import 'screens/main_screen.dart';
import 'screens/lock/lock_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'supabase_config.dart';

/// Best-effort crash visibility: writes to the error_logs table (see
/// supabase/patches.sql #8) so uncaught errors are visible somewhere other
/// than a connected debugger. Never throws — a failing log must not crash
/// the crash handler.
void _logCrash(Object error, StackTrace? stack, {String? context}) {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    SupabaseService().logError(
      userId: userId,
      message: error.toString(),
      stack: stack?.toString(),
      context: context,
    );
  } catch (_) {}
}

// Flutter's built-in Material/Cupertino localizations don't ship Kurdish
// translations. Without a fallback, widgets that read MaterialLocalizations
// (e.g. AppBar back-button tooltips) throw for the 'ku' locale. Route 'ku'
// to the Arabic translations instead (same RTL direction, closest available).
class _KuMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _KuMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
  @override
  bool shouldReload(_KuMaterialLocalizationsDelegate old) => false;
}

class _KuCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KuCupertinoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));
  @override
  bool shouldReload(_KuCupertinoLocalizationsDelegate old) => false;
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logCrash(details.exception, details.stack, context: 'FlutterError');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _logCrash(error, stack, context: 'PlatformDispatcher');
      return true;
    };

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    runApp(const UmrahApp());
  }, (error, stack) => _logCrash(error, stack, context: 'runZonedGuarded'));
}

class UmrahApp extends StatelessWidget {
  /// Injectable for tests; defaults to the real backend-backed provider.
  final AppProvider Function()? createProvider;
  const UmrahApp({super.key, this.createProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => (createProvider ?? AppProvider.new)(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final isRtl = provider.locale.languageCode != 'en';
          return MaterialApp(
            title: 'Umrah',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            locale: provider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              _KuMaterialLocalizationsDelegate(),
              _KuCupertinoLocalizationsDelegate(),
            ],
            builder: (context, child) => Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
            home: provider.locked ? const LockScreen() : const MainScreen(),
          );
        },
      ),
    );
  }
}
