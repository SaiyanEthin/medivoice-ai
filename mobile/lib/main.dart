import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/config.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/app_locale.dart';
import 'core/text_scale_prefs.dart';
import 'l10n/app_localizations.dart';
import 'core/unit_prefs.dart';
import 'services/speech_output_service.dart';
import 'providers/consultation_provider.dart';

void main() async {
  // Unit preferences are read synchronously all over the vitals screens,
  // so load them before the first frame rather than having every widget
  // handle a not-yet-loaded state.
  WidgetsFlutterBinding.ensureInitialized();
  await UnitPrefs().load();
  await SpeechOutputService().load();
  await TextScalePrefs().load();
  await AppLocale().load();
  // Month names come from intl, which needs its data loaded per locale.
  // flutter_localizations does this as a side effect of its delegates;
  // doing it explicitly means date formatting doesn't depend on that.
  for (final code in AppLocale.supportedCodes) {
    await initializeDateFormatting(code);
  }
  runApp(const MediVoiceApp());
}

class MediVoiceApp extends StatelessWidget {
  const MediVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLocale(),
        builder: (context, locale, _) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppText.localizationsDelegates,
          supportedLocales: AppText.supportedLocales,
          builder: (context, child) => ValueListenableBuilder<TextSizeOption>(
            valueListenable: TextScalePrefs(),
            builder: (context, textSize, _) =>
                MediaQuery.withClampedTextScaling(
              minScaleFactor: textSize.scale,
              maxScaleFactor: textSize.scale,
              child: child!,
            ),
          ),
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.home,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}
