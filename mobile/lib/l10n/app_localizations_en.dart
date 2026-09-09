// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppTextEn extends AppText {
  AppTextEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MediVoice';

  @override
  String get consultGreeting =>
      'Hello! Tell me how you\'re feeling - you can speak or type.';

  @override
  String get consultGreetingExample =>
      'For example: \"I have fever and a cough\".';

  @override
  String get consultGreetingSpoken =>
      'Hello. Tell me how you\'re feeling. You can speak or type.';

  @override
  String get consultRestart => 'Let\'s start again. How are you feeling?';

  @override
  String get consultInputHint => 'Type or speak';

  @override
  String get consultInputHintListening => 'Listening...';

  @override
  String get consultInputHintTranscribing => 'Transcribing...';

  @override
  String get voiceGuidanceTurnOff => 'Turn off voice guidance';

  @override
  String get voiceGuidanceTurnOn => 'Turn on voice guidance';

  @override
  String get consultNoSymptoms =>
      'I couldn\'t pick out any symptoms there. Try describing them more simply - for example \"fever and cough\".';

  @override
  String get consultOnlyDenied =>
      'You told me what you don\'t have, but not what you do. What symptoms are you experiencing?';

  @override
  String get consultDidntCatch =>
      'I didn\'t catch that. Please try again, speaking clearly.';

  @override
  String get consultListeningError =>
      'Something went wrong while listening. Please try again.';

  @override
  String get consultMicPermission =>
      'I need microphone permission to listen. You can allow it in your phone\'s settings, or type instead.';

  @override
  String get consultPredictionError =>
      'Something went wrong working that out. Please try again.';

  @override
  String get questionsTitle => 'A few quick questions';

  @override
  String get questionsSubtitle => 'This helps narrow things down.';

  @override
  String get answerYes => 'Yes';

  @override
  String get answerNo => 'No';

  @override
  String get severityPrompt => 'How severe? (optional)';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String questionsAnsweredCount(int answered, int total) {
    return '$answered of $total answered';
  }

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionSkipRest => 'Skip the rest';

  @override
  String questionsSpokenIntro(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'I have $count quick questions.',
      one: 'I have 1 quick question.',
    );
    return '$_temp0';
  }

  @override
  String get resultMayBeConsistentWith => 'This may be consistent with';

  @override
  String resultModelScore(String percent) {
    return 'Model score: $percent% - a pattern match, not a diagnosis.';
  }

  @override
  String resultSpoken(String disease, int percent) {
    return 'Based on what you\'ve described, this may be consistent with $disease. The model score is $percent percent. This is a pattern match, not a diagnosis.';
  }

  @override
  String get resultUncertainTitle =>
      'I\'m not confident enough to suggest a specific condition from what you\'ve told me.';

  @override
  String get resultUncertainBody =>
      'That\'s common with mild or early illness. I can still suggest some things that may help.';

  @override
  String get resultUncertainSpoken =>
      'I\'m not confident enough to suggest a specific condition from what you\'ve told me. This is common with mild or early illness. Tap to see what you can do.';

  @override
  String get actionSeeFullAssessment => 'See full assessment';

  @override
  String get actionSeeWhatYouCanDo => 'See what you can do';

  @override
  String get unclearFindGp => 'Find a general physician';

  @override
  String get unclearFindGpExplain =>
      'Your symptoms aren\'t clear enough to identify a condition. A general physician can assess you properly and advise on next steps.';

  @override
  String get doctorsGeneralTitle => 'General physicians near you';

  @override
  String get doctorsGeneralSubtitle =>
      'A general physician is a good starting point when symptoms aren\'t clear.';

  @override
  String questionTemplate(String symptom) {
    return 'Do you have $symptom?';
  }
}
