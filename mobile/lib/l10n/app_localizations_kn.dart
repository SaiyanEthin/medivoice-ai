// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppTextKn extends AppText {
  AppTextKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'MediVoice';

  @override
  String get consultGreeting =>
      'ನಮಸ್ಕಾರ! ನಿಮಗೆ ಹೇಗಿದೆ ಎಂದು ಹೇಳಿ - ನೀವು ಮಾತನಾಡಬಹುದು ಅಥವಾ ಟೈಪ್ ಮಾಡಬಹುದು.';

  @override
  String get consultGreetingExample =>
      'ಉದಾಹರಣೆಗೆ: \"ನನಗೆ ಜ್ವರ ಮತ್ತು ಕೆಮ್ಮು ಇದೆ\".';

  @override
  String get consultGreetingSpoken =>
      'ನಮಸ್ಕಾರ. ನಿಮಗೆ ಹೇಗಿದೆ ಎಂದು ಹೇಳಿ. ನೀವು ಮಾತನಾಡಬಹುದು ಅಥವಾ ಟೈಪ್ ಮಾಡಬಹುದು.';

  @override
  String get consultRestart => 'ಮತ್ತೆ ಪ್ರಾರಂಭಿಸೋಣ. ನಿಮಗೆ ಹೇಗಿದೆ?';

  @override
  String get consultInputHint => 'ಟೈಪ್ ಮಾಡಿ ಅಥವಾ ಮಾತನಾಡಿ';

  @override
  String get consultInputHintListening => 'ಕೇಳುತ್ತಿದೆ...';

  @override
  String get consultInputHintTranscribing => 'ಬರೆಯುತ್ತಿದೆ...';

  @override
  String get voiceGuidanceTurnOff => 'ಧ್ವನಿ ಮಾರ್ಗದರ್ಶನ ಆಫ್ ಮಾಡಿ';

  @override
  String get voiceGuidanceTurnOn => 'ಧ್ವನಿ ಮಾರ್ಗದರ್ಶನ ಆನ್ ಮಾಡಿ';

  @override
  String get consultNoSymptoms =>
      'ಅಲ್ಲಿ ಯಾವುದೇ ರೋಗಲಕ್ಷಣಗಳು ಗುರ್ತಿಸಲಿಲ್ಲ. ಸರಳವಾಗಿ ಹೇಳಲು ಪ್ರಯತ್ನಿಸಿ - ಉದಾಹರಣೆಗೆ \"ಜ್ವರ ಮತ್ತು ಕೆಮ್ಮು\".';

  @override
  String get consultOnlyDenied =>
      'ನಿಮಗೆ ಏನು ಇಲ್ಲ ಎಂದು ಹೇಳಿದ್ದೀರಿ, ಆದರೆ ಏನು ಇದೆ ಎಂದು ಹೇಳಿಲ್ಲ. ನಿಮಗೆ ಯಾವ ತ್ರಾಸಗಳಿವೆ?';

  @override
  String get consultDidntCatch =>
      'ನನಗೆ ಕೇಳಿಸಲಿಲ್ಲ. ಸ್ಪಷ್ಟವಾಗಿ ಮಾತನಾಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get consultListeningError =>
      'ಕೇಳುವಾಗ ಸಮಸ್ಯೆ ಉಂಟಾಯಿತು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get consultMicPermission =>
      'ಕೇಳಲು ನನಗೆ ಮೈಕ್ ಅನುಮತಿ ಬೇಕು. ಫೋನ್ ಸೆಟ್ಟಿಂಗ್ಸ್ನಲ್ಲಿ ಅನುಮತಿ ನೀಡಿ ಅಥವಾ ಟೈಪ್ ಮಾಡಿ.';

  @override
  String get consultPredictionError => 'ಎನುವೇ ತಪ್ಪಾಯಿತು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get questionsTitle => 'ಕೆಲವು ಸಣ್ಣ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get questionsSubtitle => 'ಇದು ಹೆಚ್ಚು ನಿ೦ರ್ಧರಿಸಲು ಸಹಾಯಕ.';

  @override
  String get answerYes => 'ಹೌದು';

  @override
  String get answerNo => 'ಇಲ್ಲ';

  @override
  String get severityPrompt => 'ಎಷ್ಟು ತೀವ್ರ? (ಐಚ್ಛಿಕ)';

  @override
  String get severityMild => 'ಸೌಮ್ಯ';

  @override
  String get severityModerate => 'ಮಧ್ಯಮ';

  @override
  String get severitySevere => 'ತೀವ್ರ';

  @override
  String questionsAnsweredCount(int answered, int total) {
    return '$total ರಲ್ಲಿ $answered ಉತ್ತರಿಸಲಾಗಿದೆ';
  }

  @override
  String get actionContinue => 'ಮುಂದುವರಿಸಿ';

  @override
  String get actionSkipRest => 'ಉಳಿದವನ್ನು ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String questionsSpokenIntro(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ನನ್ನಲ್ಲಿ $count ಪ್ರಶ್ನೆಗಳು ಇದ್ದವೆ.',
      one: 'ನನ್ನಲ್ಲಿ 1 ಸಣ್ಣ ಪ್ರಶ್ನೆ ಇದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get resultMayBeConsistentWith => 'ಇದು ಇದಕ್ಕೆ ಹೊಂದಿಕೆಯಾಗಬಹುದು';

  @override
  String resultModelScore(String percent) {
    return 'ಮಾದರಿ ಸ್ಕೋರ್: $percent% - ಇದು ಮಾದರಿ ಹೋಲಿಕೆ, ರೋಗನಿದಾನ ಅಲ್ಲ.';
  }

  @override
  String resultSpoken(String disease, int percent) {
    return 'ನೀವು ಹೇಳಿದ್ದರ ಪ್ರಕಾರ, ಇದು $disease ಗೆ ಹೊಂದಿಕೆಯಾಗಬಹುದು. ಮಾದರಿ ಸ್ಕೋರ್ $percent ಶೇಕಡ. ಇದು ಮಾದರಿ ಹೋಲಿಕೆ, ರೋಗನಿದಾನ ಅಲ್ಲ.';
  }

  @override
  String get resultUncertainTitle =>
      'ನೀವು ಹೇಳಿದ್ದರಿಂದ ನಿರ್ದಿಷ್ಟ ಸ್ಥಿತಿಯನ್ನು ಹೇಳಲು ನನಗೆ ಸಾಕಷ್ಟು ಮಾಹಿತಿ ಇಲ್ಲ.';

  @override
  String get resultUncertainBody =>
      'ಸೌಮ್ಯ ಅಥವಾ ಆರಂಭದ ಅನಾರೋಗ್ಯದಲ್ಲಿ ಇದು ಸಾಮಾನ್ಯ. ಸಹಾಯವಾಗಬಹುದಾದ ಕೆಲವು ಸಲಹೆಗಳನ್ನು ನೀಡಬಲ್ಲೆ.';

  @override
  String get resultUncertainSpoken =>
      'ನೀವು ಹೇಳಿದ್ದರಿಂದ ನಿರ್ದಿಷ್ಟ ಸ್ಥಿತಿಯನ್ನು ಹೇಳಲು ಸಾಕಷ್ಟು ಮಾಹಿತಿ ಇಲ್ಲ. ನೀವು ಏನು ಮಾಡಬಹುದು ಎಂದು ನೋಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get actionSeeFullAssessment => 'ಸಂಪೂರ್ಣ ಮಾಹಿತಿ ನೋಡಿ';

  @override
  String get actionSeeWhatYouCanDo => 'ಏನು ಮಾಡಬಹುದು ಎಂದು ನೋಡಿ';

  @override
  String get unclearFindGp => 'ಸಾಮಾನ್ಯ ವೈದ್ಯರನ್ನು ಹುಡುಕಿ';

  @override
  String get unclearFindGpExplain =>
      'ನಿಮ್ಮ ರೋಗಲಕ್ಷಣಗಳು ಸ್ಪಷ್ಟವಾಗಿಲ್ಲ. ಸಾಮಾನ್ಯ ವೈದ್ಯರು ನಿಮ್ಮನ್ನು ಪರಿಶೀಲಿಸಿ ಮುಂದಿನ ಹೆಾರತುಸಲಹೆ ನೀಡಬಲ್ಲರು.';

  @override
  String get doctorsGeneralTitle => 'ನಿಮ್ಮ ಹತ್ತಿರದ ಸಾಮಾನ್ಯ ವೈದ್ಯರು';

  @override
  String get doctorsGeneralSubtitle =>
      'ರೋಗಲಕ್ಷಣಗಳು ಸ್ಪಷ್ಟವಾಗಿಲ್ಲದಿದ್ದಾಗ ಸಾಮಾನ್ಯ ವೈದ್ಯರನ್ನು ಭೇಟಿಯಾಗುವುದು ಉತ್ತಮ.';
}
