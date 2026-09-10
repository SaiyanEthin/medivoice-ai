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

  @override
  String questionTemplate(String symptom) {
    return 'ನಿಮಗೆ $symptom ಇದೆಯೇ?';
  }

  @override
  String get resultAppBarTitle => 'ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಮೌಲ್ಯಮಾಪನ';

  @override
  String get resultAppBarFallback => 'ಮೌಲ್ಯಮಾಪನ';

  @override
  String get resultNoResult => 'ಯಾವುದೇ ಫಲಿತಾಂಶ ಇಲ್ಲ.';

  @override
  String get resultPossibleCondition => 'ಸಂಭವನೀಯ ಸ್ಥಿತಿ';

  @override
  String resultScoreLine(String percent) {
    return 'ಮಾದರಿ ಸ್ಕೋರ್: $percent%';
  }

  @override
  String resultBodyFairlyConfident(String disease) {
    return 'ನೀವು ಹೇಳಿದ ರೋಗಲಕ್ಷಣಗಳ ಆಧಾರದ ಮೇಲೆ, ಇದು $disease ಗೆ ಹೊಂದಿಕೆಯಾಗಬಹುದು ಎಂದು ಮಾದರಿ ಸಾಕಷ್ಟು ವಿಶ್ವಾಸ ಹೊಂದಿದೆ. ಇದು ತರಬೇತಿ ದತ್ತಾಂಶದೊಂದಿಗೆ ಹೋಲಿಕೆ, ವೈದ್ಯಕೀಯ ರೋಗನಿದಾನ ಅಲ್ಲ.';
  }

  @override
  String resultBodyModeratelyConfident(String disease) {
    return 'ನೀವು ಹೇಳಿದ ರೋಗಲಕ್ಷಣಗಳ ಆಧಾರದ ಮೇಲೆ, ಇದು $disease ಗೆ ಹೊಂದಿಕೆಯಾಗಬಹುದು ಎಂದು ಮಾದರಿ ಸ್ವಲ್ಪ ಮಟ್ಟಿಗೆ ವಿಶ್ವಾಸ ಹೊಂದಿದೆ. ಇದು ತರಬೇತಿ ದತ್ತಾಂಶದೊಂದಿಗೆ ಹೋಲಿಕೆ, ವೈದ್ಯಕೀಯ ರೋಗನಿದಾನ ಅಲ್ಲ.';
  }

  @override
  String get resultRecognizedSymptoms => 'ಗುರುತಿಸಲಾದ ರೋಗಲಕ್ಷಣಗಳು';

  @override
  String get resultDisclaimer =>
      'ಇದು AI ಮಾದರಿಯಿಂದ ರಚಿಸಲಾದ ಪ್ರಾಥಮಿಕ ಮೌಲ್ಯಮಾಪನ, ರೋಗನಿದಾನ ಅಲ್ಲ. ಇದು ವೃತ್ತಿಪರ ವೈದ್ಯಕೀಯ ಸಲಹೆಗೆ ಬದಲಿ ಅಲ್ಲ. ಸರಿಯಾದ ರೋಗನಿದಾನ ಮತ್ತು ಚಿಕಿತ್ಸೆಗಾಗಿ ಅರ್ಹ ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get actionViewAdvice => 'ಆರೋಗ್ಯ ಸಲಹೆ ನೋಡಿ';

  @override
  String get actionFindDoctors => 'ವೈದ್ಯರನ್ನು ಹುಡುಕಿ';

  @override
  String get actionTryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get actionRetry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get actionBackToAssessment => 'ಮೌಲ್ಯಮಾಪನಕ್ಕೆ ಹಿಂತಿರುಗಿ';

  @override
  String get uncertainCardTitle => 'ರೋಗಲಕ್ಷಣಗಳು ಸ್ಪಷ್ಟವಾಗಿಲ್ಲ';

  @override
  String get uncertainInsufficient =>
      'ನೀವು ಕೆಲವೇ ರೋಗಲಕ್ಷಣಗಳನ್ನು ಹೇಳಿದ್ದೀರಿ, ಅದು ನಿರ್ದಿಷ್ಟ ಸ್ಥಿತಿಯನ್ನು ಸೂಚಿಸಲು ಸಾಕಾಗುವುದಿಲ್ಲ. ದಿನನಿತ್ಯದ ಹಲವು ಕಾರಣಗಳಿಂದಲೂ ಈ ಲಕ್ಷಣಗಳು ಬರಬಹುದು.';

  @override
  String get uncertainLowConfidence =>
      'ನಿಮ್ಮ ರೋಗಲಕ್ಷಣಗಳು ಈ ಆ್ಯಪ್ ಪರಿಶೀಲಿಸಬಹುದಾದ ಯಾವುದೇ ಒಂದು ಸ್ಥಿತಿಗೆ ಸ್ಪಷ್ಟವಾಗಿ ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ. ಸೌಮ್ಯ ಅಥವಾ ಆರಂಭದ ಅನಾರೋಗ್ಯದಲ್ಲಿ ಇದು ಸಾಮಾನ್ಯ.';

  @override
  String get uncertainWhatYouCanDo => 'ಈಗ ನೀವು ಏನು ಮಾಡಬಹುದು';

  @override
  String get uncertainSeekCare => 'ಇವು ಇದ್ದರೆ ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ';

  @override
  String get adviceAppBarTitle => 'ಆರೋಗ್ಯ ಸಲಹೆ';

  @override
  String get adviceFor => 'ಇದಕ್ಕಾಗಿ ಸಲಹೆ';

  @override
  String get adviceRecommendedSteps => 'ಶಿಫಾರಸು ಮಾಡಿದ ಕ್ರಮಗಳು';

  @override
  String get adviceLoadError => 'ಸಲಹೆ ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get adviceDisclaimer =>
      'ಇದು ಸಾಮಾನ್ಯ ಮಾರ್ಗದರ್ಶನ ಮಾತ್ರ, ಔಷಧಿ ಚೀಟಿ ಅಲ್ಲ. ಅರ್ಹ ವೈದ್ಯರನ್ನು ಕೇಳದೆ ಯಾವುದೇ ಔಷಧಿಯನ್ನು ಪ್ರಾರಂಭಿಸಬೇಡಿ ಅಥವಾ ನಿಲ್ಲಿಸಬೇಡಿ.';

  @override
  String get adviceLevelSerious => 'ಶೀಘ್ರವಾಗಿ ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ';

  @override
  String get adviceLevelChronic => 'ದೀರ್ಘಕಾಲದ ಸ್ಥಿತಿ - ಗಮನದಲ್ಲಿಡಬೇಕು';

  @override
  String get adviceLevelModerate => 'ಮಧ್ಯಮ - ಎಚ್ಚರಿಕೆಯಿಂದ ಗಮನಿಸಿ';

  @override
  String get adviceLevelMild => 'ಸಾಮಾನ್ಯವಾಗಿ ಸೌಮ್ಯ, ತಾನಾಗಿಯೇ ಕಡಿಮೆಯಾಗುತ್ತದೆ';

  @override
  String get doctorsAppBarTitle => 'ಹತ್ತಿರದ ವೈದ್ಯರು';

  @override
  String get doctorsFor => 'ಇದಕ್ಕಾಗಿ ವೈದ್ಯರು';

  @override
  String doctorsFoundCount(int count) {
    return '$count ಸಿಕ್ಕಿದ್ದಾರೆ, ಹತ್ತಿರದವರು ಮೊದಲು';
  }

  @override
  String get doctorsLoadError => 'ವೈದ್ಯರ ಪಟ್ಟಿ ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get doctorsNoneForCondition =>
      'ಈ ಸ್ಥಿತಿಗೆ ಸ್ಥಳೀಯ ಪಟ್ಟಿಯಲ್ಲಿ ಯಾವುದೇ ವೈದ್ಯರು ಸಿಗಲಿಲ್ಲ.';

  @override
  String get doctorsNoneGeneral =>
      'ಸ್ಥಳೀಯ ಪಟ್ಟಿಯಲ್ಲಿ ಯಾವುದೇ ಸಾಮಾನ್ಯ ವೈದ್ಯರು ಸಿಗಲಿಲ್ಲ.';

  @override
  String get doctorsDemoNotice =>
      'ಪ್ರದರ್ಶನಕ್ಕಾಗಿ ಮಾತ್ರ. ಇವು ಪಟ್ಟಿ ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ ಎಂದು ತೋರಿಸಲು ಬಳಸಿದ ಮಾದರಿ ದಾಖಲೆಗಳು - ಇವರು ನಿಜವಾದ ವೈದ್ಯರಲ್ಲ, ಮತ್ತು ಈ ಸಂಖ್ಯೆಗಳು ಯಾರಿಗೂ ಸಂಪರ್ಕವಾಗುವುದಿಲ್ಲ.';

  @override
  String get doctorsDistanceNote =>
      'ದೂರಗಳು ಅಂದಾಜು ಮಾತ್ರ, ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಸ್ಥಳದ ಆಧಾರದ ಮೇಲೆ ಅಲ್ಲ.';

  @override
  String doctorCopiedNumber(String name) {
    return '$name ಅವರ ಸಂಖ್ಯೆ ನಕಲಿಸಲಾಗಿದೆ';
  }

  @override
  String get profileSetupTitle => 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಸಿದ್ಧಪಡಿಸಿ';

  @override
  String get profileTitle => 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್';

  @override
  String get profileHeading => 'ನಿಮ್ಮ ಬಗ್ಗೆ ಸ್ವಲ್ಪ';

  @override
  String get profileIntro =>
      'ಇದು MediVoice ನಿಮ್ಮನ್ನು ಸರಿಯಾಗಿ ಸಂಬೋಧಿಸಲು ಮತ್ತು ನಿಮ್ಮ ಆರೋಗ್ಯ ಮಾಹಿತಿಯನ್ನು ಒಂದೇ ಕಡೆ ಇಡಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ. ಇದನ್ನು ಈಗ ಬಿಟ್ಟು ನಂತರ ಭರ್ತಿ ಮಾಡಬಹುದು.';

  @override
  String get profilePrivacyNote =>
      'ಇದು ನಿಮ್ಮ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ಉಳಿಯುತ್ತದೆ. ಇದನ್ನು ಎಲ್ಲಿಗೂ ಕಳುಹಿಸುವುದಿಲ್ಲ ಅಥವಾ ಹಂಚಿಕೊಳ್ಳುವುದಿಲ್ಲ, ಮತ್ತು ನೀವು ಯಾವಾಗ ಬೇಕಾದರೂ ಬದಲಾಯಿಸಬಹುದು ಅಥವಾ ಅಳಿಸಬಹುದು.';

  @override
  String get profileLanguageLabel => 'ಭಾಷೆ';

  @override
  String get fieldName => 'ಹೆಸರು';

  @override
  String get fieldNameHint => 'ನಿಮ್ಮನ್ನು ಏನೆಂದು ಕರೆಯಬೇಕು?';

  @override
  String get fieldAge => 'ವಯಸ್ಸು';

  @override
  String get fieldOptional => 'ಐಚ್ಛಿಕ';

  @override
  String get fieldSex => 'ಲಿಂಗ';

  @override
  String get sexFemale => 'ಮಹಿಳೆ';

  @override
  String get sexMale => 'ಪುರುಷ';

  @override
  String get sexOther => 'ಇತರೆ';

  @override
  String get sexPreferNotToSay => 'ಹೇಳಲು ಇಷ್ಟವಿಲ್ಲ';

  @override
  String get fieldConditions => 'ಈಗಿರುವ ಆರೋಗ್ಯ ಸಮಸ್ಯೆಗಳು';

  @override
  String get fieldConditionsHint =>
      'ನಿಮಗೆ ಈಗಾಗಲೇ ಗೊತ್ತಿರುವ ಸಮಸ್ಯೆಗಳು - ಡಯಾಬಿಟಿಸ್, ಅಸ್ತಮಾ, ಬ್ಲಡ್ ಪ್ರೆಶರ್.';

  @override
  String get fieldAddCondition => 'ಸಮಸ್ಯೆ ಸೇರಿಸಿ';

  @override
  String get fieldAllergies => 'ಅಲರ್ಜಿಗಳು';

  @override
  String get fieldAllergiesHint =>
      'ಔಷಧಿ, ಆಹಾರ ಅಥವಾ ಬೇರೆ ಯಾವುದಾದರೂ ನಿಮಗೆ ಒಗ್ಗದಿರುವುದು.';

  @override
  String get fieldAddAllergy => 'ಅಲರ್ಜಿ ಸೇರಿಸಿ';

  @override
  String get actionSaveAndContinue => 'ಉಳಿಸಿ ಮತ್ತು ಮುಂದುವರಿಸಿ';

  @override
  String get actionSave => 'ಉಳಿಸಿ';

  @override
  String get actionSkipForNow => 'ಸದ್ಯಕ್ಕೆ ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String get profileNameRequired => 'ಮುಂದುವರಿಯಲು ಹೆಸರು ನಮೂದಿಸಿ.';

  @override
  String homeGreeting(String name) {
    return 'ನಮಸ್ಕಾರ, $name';
  }

  @override
  String get homeGreetingSub => 'ಇಂದು ಹೇಗೆ ಸಹಾಯ ಮಾಡಲಿ?';

  @override
  String get homeTagline => 'ನಿಮ್ಮ ಆಫ್‌ಲೈನ್ ಆರೋಗ್ಯ ಸಂಗಾತಿ';

  @override
  String get homeHowAreYou => 'ಇಂದು ನಿಮಗೆ ಹೇಗಿದೆ?';

  @override
  String get homeTellMe =>
      'ನಿಮ್ಮ ಮಾತಿನಲ್ಲೇ ಏನಾಗಿದೆ ಎಂದು ಹೇಳಿ - ಮಾತನಾಡಿ ಅಥವಾ ಟೈಪ್ ಮಾಡಿ, ಯಾವುದು ಸುಲಭವೋ ಅದು.';

  @override
  String get homeTapToSpeak => 'ಮಾತನಾಡಲು ಒತ್ತಿ';

  @override
  String get homeStartConsultation => 'ಸಮಾಲೋಚನೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get homeWorksOffline => 'ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get homeNoInternet => 'ಇಂಟರ್ನೆಟ್ ಬೇಕಾಗಿಲ್ಲ';

  @override
  String get homeStaysPrivate => 'ಖಾಸಗಿಯಾಗಿ ಉಳಿಯುತ್ತದೆ';

  @override
  String get homeNothingLeaves => 'ಏನೂ ನಿಮ್ಮ ಫೋನ್‌ನಿಂದ ಹೊರಗೆ ಹೋಗುವುದಿಲ್ಲ';

  @override
  String get homeDashboard => 'ಆರೋಗ್ಯ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';

  @override
  String get homeSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get homeHowItWorks => 'MediVoice ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get homeDisclaimer =>
      'MediVoice ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಅರಿವನ್ನು ಮಾತ್ರ ನೀಡುತ್ತದೆ. ಇದು ರೋಗನಿದಾನ ಅಲ್ಲ ಮತ್ತು ವೈದ್ಯರಿಗೆ ಬದಲಿ ಅಲ್ಲ.';

  @override
  String get homeProfileTooltip => 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್';

  @override
  String get settingsTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get settingsLanguage => 'ಭಾಷೆ';

  @override
  String get settingsLanguageDesc =>
      'MediVoice ಯಾವ ಭಾಷೆಯಲ್ಲಿ ತೋರಿಸುತ್ತದೆ ಮತ್ತು ಮಾತನಾಡುತ್ತದೆ.';

  @override
  String get settingsLanguageNote =>
      'ಕನ್ನಡ ಮತ್ತು ಹಿಂದಿ ಅನುವಾದ ನಡೆಯುತ್ತಿದೆ. ಇನ್ನೂ ಅನುವಾದವಾಗದಿರುವುದು ಇಂಗ್ಲಿಷ್‌ನಲ್ಲೇ ಇರುತ್ತದೆ.';

  @override
  String get settingsDisplay => 'ಪ್ರದರ್ಶನ';

  @override
  String get settingsTextSize => 'ಪಠ್ಯದ ಗಾತ್ರ';

  @override
  String get settingsMeasurements => 'ಅಳತೆಗಳು';

  @override
  String get settingsTemperature => 'ತಾಪಮಾನ';

  @override
  String get settingsWeight => 'ತೂಕ';

  @override
  String get settingsUnitsNote =>
      'ಅಳತೆಗಳು ಒಂದೇ ರೂಪದಲ್ಲಿ ಉಳಿಯುತ್ತವೆ ಮತ್ತು ತೋರಿಸಲು ಪರಿವರ್ತಿಸಲಾಗುತ್ತದೆ, ಹಾಗಾಗಿ ಘಟಕ ಬದಲಾಯಿಸಿದರೆ ಉಳಿಸಿದ ಮೌಲ್ಯ ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get settingsVoice => 'ಧ್ವನಿ';

  @override
  String get settingsVoiceGuidance => 'ಧ್ವನಿ ಮಾರ್ಗದರ್ಶನ';

  @override
  String get settingsVoiceGuidanceSub =>
      'ಪ್ರಶ್ನೆಗಳು ಮತ್ತು ಫಲಿತಾಂಶಗಳನ್ನು ಓದಿ ಹೇಳುತ್ತದೆ';

  @override
  String get settingsVoiceNote =>
      'ಧ್ವನಿ ಮಾರ್ಗದರ್ಶನ ಮೇಲಿನ ಭಾಷೆಯನ್ನು ಅನುಸರಿಸುತ್ತದೆ. ನಿಮ್ಮ ಫೋನ್‌ನಲ್ಲಿ ಆ ಭಾಷೆಯ ಧ್ವನಿ ಡೇಟಾ ಇರಬೇಕು - ಇಲ್ಲದಿದ್ದರೆ ತಪ್ಪಾಗಿ ಓದುವ ಬದಲು ಆ್ಯಪ್ ಮೌನವಾಗಿರುತ್ತದೆ.';

  @override
  String get settingsYourData => 'ನಿಮ್ಮ ಡೇಟಾ';

  @override
  String get settingsDataNote =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್, ಆರೋಗ್ಯ ಅಳತೆಗಳು ಮತ್ತು ಹಿಂದಿನ ಮೌಲ್ಯಮಾಪನಗಳು ಈ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ಇರುತ್ತವೆ. ಏನನ್ನೂ ಕಳುಹಿಸುವುದಿಲ್ಲ ಅಥವಾ ಹಂಚಿಕೊಳ್ಳುವುದಿಲ್ಲ.';

  @override
  String get settingsNothingStored => 'ಇನ್ನೂ ಏನೂ ಉಳಿಸಿಲ್ಲ.';

  @override
  String get settingsCurrentlyStored => 'ಈಗ ಉಳಿಸಿರುವುದು:';

  @override
  String get settingsDeleteData => 'ಆರೋಗ್ಯ ಡೇಟಾ ಅಳಿಸಿ';

  @override
  String get settingsDeleteTitle => 'ಆರೋಗ್ಯ ಡೇಟಾ ಅಳಿಸಬೇಕೆ?';

  @override
  String get settingsDeleteBody => 'ಇದು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುತ್ತದೆ:';

  @override
  String get settingsDeleteUndone => 'ಇದನ್ನು ಮತ್ತೆ ಪಡೆಯಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get actionCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get actionDelete => 'ಅಳಿಸಿ';

  @override
  String get settingsDataDeleted => 'ಆರೋಗ್ಯ ಡೇಟಾ ಅಳಿಸಲಾಗಿದೆ.';
}
