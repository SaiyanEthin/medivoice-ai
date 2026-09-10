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

  @override
  String get resultAppBarTitle => 'Preliminary Health Assessment';

  @override
  String get resultAppBarFallback => 'Assessment';

  @override
  String get resultNoResult => 'No result available.';

  @override
  String get resultPossibleCondition => 'Possible condition';

  @override
  String resultScoreLine(String percent) {
    return 'Model score: $percent%';
  }

  @override
  String resultBodyFairlyConfident(String disease) {
    return 'Based on the symptoms you described, the model is fairly confident these may be consistent with $disease. This is a pattern match against training data, not a medical diagnosis.';
  }

  @override
  String resultBodyModeratelyConfident(String disease) {
    return 'Based on the symptoms you described, the model is moderately confident these may be consistent with $disease. This is a pattern match against training data, not a medical diagnosis.';
  }

  @override
  String get resultRecognizedSymptoms => 'Recognized Symptoms';

  @override
  String get resultDisclaimer =>
      'This is a preliminary, non-diagnostic assessment generated by an AI model. It is not a substitute for professional medical advice. Please consult a qualified doctor for accurate diagnosis and treatment.';

  @override
  String get actionViewAdvice => 'View Health Advice';

  @override
  String get actionFindDoctors => 'Find Doctors';

  @override
  String get actionTryAgain => 'Try Again';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionBackToAssessment => 'Back to Assessment';

  @override
  String get uncertainCardTitle => 'Symptoms Unclear';

  @override
  String get uncertainInsufficient =>
      'You described only a few symptoms, which isn\'t enough to suggest a specific condition. Many everyday causes can produce these symptoms.';

  @override
  String get uncertainLowConfidence =>
      'Your symptoms don\'t clearly match any single condition this app can assess. This is common with mild or early-stage illness.';

  @override
  String get uncertainWhatYouCanDo => 'What You Can Do Now';

  @override
  String get uncertainSeekCare => 'Seek medical care if you have';

  @override
  String get adviceAppBarTitle => 'Health Advice';

  @override
  String get adviceFor => 'Advice for';

  @override
  String get adviceRecommendedSteps => 'Recommended steps';

  @override
  String get adviceLoadError => 'Couldn\'t load advice.';

  @override
  String get adviceDisclaimer =>
      'This is general guidance only, not a prescription. Do not start or stop any medication without consulting a qualified doctor.';

  @override
  String get adviceLevelSerious => 'Seek medical attention promptly';

  @override
  String get adviceLevelChronic => 'Ongoing condition - needs monitoring';

  @override
  String get adviceLevelModerate => 'Moderate - monitor closely';

  @override
  String get adviceLevelMild => 'Usually mild and self-limiting';

  @override
  String get doctorsAppBarTitle => 'Nearby Doctors';

  @override
  String get doctorsFor => 'Doctors for';

  @override
  String doctorsFoundCount(int count) {
    return '$count found, nearest first';
  }

  @override
  String get doctorsLoadError => 'Couldn\'t load doctors.';

  @override
  String get doctorsNoneForCondition =>
      'No doctors found for this condition in the local directory.';

  @override
  String get doctorsNoneGeneral =>
      'No general physicians found in the local directory.';

  @override
  String get doctorsDemoNotice =>
      'Demonstration data. These are sample records used to show how the directory works - they are not real doctors, and the numbers do not connect to anyone.';

  @override
  String get doctorsDistanceNote =>
      'Distances are approximate and are not based on your live location.';

  @override
  String doctorCopiedNumber(String name) {
    return 'Copied $name\'s number';
  }

  @override
  String get profileSetupTitle => 'Set up your profile';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileHeading => 'A little about you';

  @override
  String get profileIntro =>
      'This helps MediVoice address you properly and keep your health information in one place. You can skip this and fill it in later.';

  @override
  String get profilePrivacyNote =>
      'This is stored on your phone only. It is never uploaded, shared, or sent anywhere, and you can change or delete it at any time.';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldNameHint => 'What should we call you?';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldOptional => 'Optional';

  @override
  String get fieldSex => 'Sex';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexMale => 'Male';

  @override
  String get sexOther => 'Other';

  @override
  String get sexPreferNotToSay => 'Prefer not to say';

  @override
  String get fieldConditions => 'Existing conditions';

  @override
  String get fieldConditionsHint =>
      'Anything you already know about - diabetes, asthma, high blood pressure.';

  @override
  String get fieldAddCondition => 'Add a condition';

  @override
  String get fieldAllergies => 'Allergies';

  @override
  String get fieldAllergiesHint =>
      'Medicines, foods or anything else you react to.';

  @override
  String get fieldAddAllergy => 'Add an allergy';

  @override
  String get actionSaveAndContinue => 'Save and continue';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSkipForNow => 'Skip for now';

  @override
  String get profileNameRequired => 'Please enter a name to continue.';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeGreetingSub => 'How can I help you today?';

  @override
  String get homeTagline => 'Your offline health companion';

  @override
  String get homeHowAreYou => 'How are you feeling today?';

  @override
  String get homeTellMe =>
      'Tell me what\'s wrong in your own words - speak or type, whichever is easier.';

  @override
  String get homeTapToSpeak => 'Tap to speak now';

  @override
  String get homeStartConsultation => 'Start consultation';

  @override
  String get homeWorksOffline => 'Works offline';

  @override
  String get homeNoInternet => 'No internet needed';

  @override
  String get homeStaysPrivate => 'Stays private';

  @override
  String get homeNothingLeaves => 'Nothing leaves your phone';

  @override
  String get homeDashboard => 'Health dashboard';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeHowItWorks => 'How MediVoice works';

  @override
  String get homeDisclaimer =>
      'MediVoice offers preliminary health awareness only. It is not a diagnosis and does not replace a doctor.';

  @override
  String get homeProfileTooltip => 'Your profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc =>
      'The language MediVoice is shown and spoken in.';

  @override
  String get settingsLanguageNote =>
      'Kannada and Hindi are being translated. Anything not yet translated stays in English.';

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsMeasurements => 'Measurements';

  @override
  String get settingsTemperature => 'Temperature';

  @override
  String get settingsWeight => 'Weight';

  @override
  String get settingsUnitsNote =>
      'Readings are stored in one form and converted for display, so switching units never changes a saved value.';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get settingsVoiceGuidance => 'Voice guidance';

  @override
  String get settingsVoiceGuidanceSub => 'Reads questions and results aloud';

  @override
  String get settingsVoiceNote =>
      'Voice guidance follows the language above. Your phone needs that language\'s voice data installed - if it isn\'t, the app stays silent rather than reading the wrong pronunciation.';

  @override
  String get settingsYourData => 'Your data';

  @override
  String get settingsDataNote =>
      'Your profile, vital readings and past assessments are stored on this phone only. Nothing is uploaded or shared.';

  @override
  String get settingsNothingStored => 'Nothing is stored yet.';

  @override
  String get settingsCurrentlyStored => 'Currently stored:';

  @override
  String get settingsDeleteData => 'Delete health data';

  @override
  String get settingsDeleteTitle => 'Delete health data?';

  @override
  String get settingsDeleteBody => 'This will permanently remove:';

  @override
  String get settingsDeleteUndone => 'This cannot be undone.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get settingsDataDeleted => 'Health data deleted.';
}
