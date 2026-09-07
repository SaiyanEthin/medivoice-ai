import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/config.dart';
import 'core/text_scale_prefs.dart';
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
      child: ValueListenableBuilder<TextSizeOption>(
        valueListenable: TextScalePrefs(),
        builder: (context, textSize, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: textSize.scale,
          maxScaleFactor: textSize.scale,
          child: child!,
        ),
        child: MaterialApp(
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
