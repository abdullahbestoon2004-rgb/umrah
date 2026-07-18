import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'services/api_service.dart';
import 'screens/main_screen.dart';
import 'screens/lock/lock_screen.dart';
import 'l10n/generated/app_localizations.dart';

/// Best-effort crash visibility through the PHP backend. Never throws — a
/// failing log must not crash the crash handler.
void _logCrash(Object error, StackTrace? stack, {String? context}) {
  try {
    PhpApiService().logError(
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
class _KuMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KuMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
  @override
  bool shouldReload(_KuMaterialLocalizationsDelegate old) => false;
}

class _KuCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
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

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logCrash(details.exception, details.stack, context: 'FlutterError');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _logCrash(error, stack, context: 'PlatformDispatcher');
      return true;
    };

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    runApp(const TawafApp());
  }, (error, stack) => _logCrash(error, stack, context: 'runZonedGuarded'));
}

class TawafApp extends StatelessWidget {
  /// Injectable for tests; defaults to the real backend-backed provider.
  final AppProvider Function()? createProvider;
  const TawafApp({super.key, this.createProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => (createProvider ?? AppProvider.new)(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final isRtl = provider.locale.languageCode != 'en';
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
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
            // Keep the Navigator's root route stable. AppProvider notifies while
            // it restores preferences/auth, and changing MaterialApp.home during
            // that update can briefly remove the Navigator's only history entry.
            home: const _AppRoot(),
          );
        },
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final locked = context.select<AppProvider, bool>((value) => value.locked);
    return locked ? const LockScreen() : const MainScreen();
  }
}
