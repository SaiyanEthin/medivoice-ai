import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppText
/// returned by `AppText.of(context)`.
///
/// Applications need to include `AppText.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppText.localizationsDelegates,
///   supportedLocales: AppText.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppText.supportedLocales
/// property.
abstract class AppText {
  AppText(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppText of(BuildContext context) {
    return Localizations.of<AppText>(context, AppText)!;
  }

  static const LocalizationsDelegate<AppText> delegate = _AppTextDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
  ];

  /// Product name - not translated
  ///
  /// In en, this message translates to:
  /// **'MediVoice'**
  String get appTitle;

  /// First message in a consultation
  ///
  /// In en, this message translates to:
  /// **'Hello! Tell me how you\'re feeling - you can speak or type.'**
  String get consultGreeting;

  /// Follows the greeting. The quoted example should be a natural phrase in the target language, not a literal translation.
  ///
  /// In en, this message translates to:
  /// **'For example: \"I have fever and a cough\".'**
  String get consultGreetingExample;

  /// Spoken form of the greeting. Differs from the written one because quotation marks and line breaks do not read aloud.
  ///
  /// In en, this message translates to:
  /// **'Hello. Tell me how you\'re feeling. You can speak or type.'**
  String get consultGreetingSpoken;

  /// No description provided for @consultRestart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start again. How are you feeling?'**
  String get consultRestart;

  /// No description provided for @consultInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type or speak'**
  String get consultInputHint;

  /// No description provided for @consultInputHintListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get consultInputHintListening;

  /// No description provided for @consultInputHintTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing...'**
  String get consultInputHintTranscribing;

  /// No description provided for @voiceGuidanceTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off voice guidance'**
  String get voiceGuidanceTurnOff;

  /// No description provided for @voiceGuidanceTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on voice guidance'**
  String get voiceGuidanceTurnOn;

  /// REVIEW: shown when nothing matched. Should sound helpful, not like the user did something wrong.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t pick out any symptoms there. Try describing them more simply - for example \"fever and cough\".'**
  String get consultNoSymptoms;

  /// REVIEW: the user described only absent symptoms.
  ///
  /// In en, this message translates to:
  /// **'You told me what you don\'t have, but not what you do. What symptoms are you experiencing?'**
  String get consultOnlyDenied;

  /// No description provided for @consultDidntCatch.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t catch that. Please try again, speaking clearly.'**
  String get consultDidntCatch;

  /// No description provided for @consultListeningError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while listening. Please try again.'**
  String get consultListeningError;

  /// No description provided for @consultMicPermission.
  ///
  /// In en, this message translates to:
  /// **'I need microphone permission to listen. You can allow it in your phone\'s settings, or type instead.'**
  String get consultMicPermission;

  /// No description provided for @consultPredictionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong working that out. Please try again.'**
  String get consultPredictionError;

  /// No description provided for @questionsTitle.
  ///
  /// In en, this message translates to:
  /// **'A few quick questions'**
  String get questionsTitle;

  /// No description provided for @questionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps narrow things down.'**
  String get questionsSubtitle;

  /// No description provided for @answerYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get answerYes;

  /// No description provided for @answerNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get answerNo;

  /// No description provided for @severityPrompt.
  ///
  /// In en, this message translates to:
  /// **'How severe? (optional)'**
  String get severityPrompt;

  /// REVIEW: clinical wording
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityMild;

  /// REVIEW: clinical wording
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// REVIEW: clinical wording
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @questionsAnsweredCount.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} answered'**
  String questionsAnsweredCount(int answered, int total);

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionSkipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip the rest'**
  String get actionSkipRest;

  /// Spoken before reading a round of questions aloud.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{I have 1 quick question.} other{I have {count} quick questions.}}'**
  String questionsSpokenIntro(int count);

  /// REVIEW: deliberately tentative. Must not imply a diagnosis in any language.
  ///
  /// In en, this message translates to:
  /// **'This may be consistent with'**
  String get resultMayBeConsistentWith;

  /// REVIEW: 'pattern match, not a diagnosis' is a safety statement and must survive translation.
  ///
  /// In en, this message translates to:
  /// **'Model score: {percent}% - a pattern match, not a diagnosis.'**
  String resultModelScore(String percent);

  /// Spoken form of the result. Says 'percent' as a word because a voice cannot read the % sign, and rounds the number because decimals mishear.
  ///
  /// In en, this message translates to:
  /// **'Based on what you\'ve described, this may be consistent with {disease}. The model score is {percent} percent. This is a pattern match, not a diagnosis.'**
  String resultSpoken(String disease, int percent);

  /// REVIEW: safety wording
  ///
  /// In en, this message translates to:
  /// **'I\'m not confident enough to suggest a specific condition from what you\'ve told me.'**
  String get resultUncertainTitle;

  /// REVIEW: safety wording
  ///
  /// In en, this message translates to:
  /// **'That\'s common with mild or early illness. I can still suggest some things that may help.'**
  String get resultUncertainBody;

  /// REVIEW: safety wording
  ///
  /// In en, this message translates to:
  /// **'I\'m not confident enough to suggest a specific condition from what you\'ve told me. This is common with mild or early illness. Tap to see what you can do.'**
  String get resultUncertainSpoken;

  /// No description provided for @actionSeeFullAssessment.
  ///
  /// In en, this message translates to:
  /// **'See full assessment'**
  String get actionSeeFullAssessment;

  /// No description provided for @actionSeeWhatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'See what you can do'**
  String get actionSeeWhatYouCanDo;

  /// No description provided for @unclearFindGp.
  ///
  /// In en, this message translates to:
  /// **'Find a general physician'**
  String get unclearFindGp;

  /// REVIEW: shown when no condition was identified. Must not imply the app has ruled anything out.
  ///
  /// In en, this message translates to:
  /// **'Your symptoms aren\'t clear enough to identify a condition. A general physician can assess you properly and advise on next steps.'**
  String get unclearFindGpExplain;

  /// No description provided for @doctorsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General physicians near you'**
  String get doctorsGeneralTitle;

  /// No description provided for @doctorsGeneralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A general physician is a good starting point when symptoms aren\'t clear.'**
  String get doctorsGeneralSubtitle;

  /// The symptom name is inserted untranslated for now - symptom labels live in symptom_dictionary.json and are a later pass.
  ///
  /// In en, this message translates to:
  /// **'Do you have {symptom}?'**
  String questionTemplate(String symptom);

  /// No description provided for @resultAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Preliminary Health Assessment'**
  String get resultAppBarTitle;

  /// No description provided for @resultAppBarFallback.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get resultAppBarFallback;

  /// No description provided for @resultNoResult.
  ///
  /// In en, this message translates to:
  /// **'No result available.'**
  String get resultNoResult;

  /// No description provided for @resultPossibleCondition.
  ///
  /// In en, this message translates to:
  /// **'Possible condition'**
  String get resultPossibleCondition;

  /// No description provided for @resultScoreLine.
  ///
  /// In en, this message translates to:
  /// **'Model score: {percent}%'**
  String resultScoreLine(String percent);

  /// REVIEW: 'pattern match, not a medical diagnosis' is a safety statement and must survive translation.
  ///
  /// In en, this message translates to:
  /// **'Based on the symptoms you described, the model is fairly confident these may be consistent with {disease}. This is a pattern match against training data, not a medical diagnosis.'**
  String resultBodyFairlyConfident(String disease);

  /// REVIEW: as above, for the lower confidence band.
  ///
  /// In en, this message translates to:
  /// **'Based on the symptoms you described, the model is moderately confident these may be consistent with {disease}. This is a pattern match against training data, not a medical diagnosis.'**
  String resultBodyModeratelyConfident(String disease);

  /// No description provided for @resultRecognizedSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Recognized Symptoms'**
  String get resultRecognizedSymptoms;

  /// REVIEW: safety wording
  ///
  /// In en, this message translates to:
  /// **'This is a preliminary, non-diagnostic assessment generated by an AI model. It is not a substitute for professional medical advice. Please consult a qualified doctor for accurate diagnosis and treatment.'**
  String get resultDisclaimer;

  /// No description provided for @actionViewAdvice.
  ///
  /// In en, this message translates to:
  /// **'View Health Advice'**
  String get actionViewAdvice;

  /// No description provided for @actionFindDoctors.
  ///
  /// In en, this message translates to:
  /// **'Find Doctors'**
  String get actionFindDoctors;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get actionTryAgain;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionBackToAssessment.
  ///
  /// In en, this message translates to:
  /// **'Back to Assessment'**
  String get actionBackToAssessment;

  /// No description provided for @uncertainCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms Unclear'**
  String get uncertainCardTitle;

  /// No description provided for @uncertainInsufficient.
  ///
  /// In en, this message translates to:
  /// **'You described only a few symptoms, which isn\'t enough to suggest a specific condition. Many everyday causes can produce these symptoms.'**
  String get uncertainInsufficient;

  /// No description provided for @uncertainLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Your symptoms don\'t clearly match any single condition this app can assess. This is common with mild or early-stage illness.'**
  String get uncertainLowConfidence;

  /// No description provided for @uncertainWhatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'What You Can Do Now'**
  String get uncertainWhatYouCanDo;

  /// REVIEW: red-flag heading
  ///
  /// In en, this message translates to:
  /// **'Seek medical care if you have'**
  String get uncertainSeekCare;

  /// No description provided for @adviceAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Advice'**
  String get adviceAppBarTitle;

  /// No description provided for @adviceFor.
  ///
  /// In en, this message translates to:
  /// **'Advice for'**
  String get adviceFor;

  /// No description provided for @adviceRecommendedSteps.
  ///
  /// In en, this message translates to:
  /// **'Recommended steps'**
  String get adviceRecommendedSteps;

  /// No description provided for @adviceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load advice.'**
  String get adviceLoadError;

  /// REVIEW: safety wording
  ///
  /// In en, this message translates to:
  /// **'This is general guidance only, not a prescription. Do not start or stop any medication without consulting a qualified doctor.'**
  String get adviceDisclaimer;

  /// REVIEW: tells the user to seek care promptly. Must not read as optional in any language.
  ///
  /// In en, this message translates to:
  /// **'Seek medical attention promptly'**
  String get adviceLevelSerious;

  /// No description provided for @adviceLevelChronic.
  ///
  /// In en, this message translates to:
  /// **'Ongoing condition - needs monitoring'**
  String get adviceLevelChronic;

  /// No description provided for @adviceLevelModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate - monitor closely'**
  String get adviceLevelModerate;

  /// No description provided for @adviceLevelMild.
  ///
  /// In en, this message translates to:
  /// **'Usually mild and self-limiting'**
  String get adviceLevelMild;

  /// No description provided for @doctorsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Doctors'**
  String get doctorsAppBarTitle;

  /// No description provided for @doctorsFor.
  ///
  /// In en, this message translates to:
  /// **'Doctors for'**
  String get doctorsFor;

  /// No description provided for @doctorsFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count} found, nearest first'**
  String doctorsFoundCount(int count);

  /// No description provided for @doctorsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load doctors.'**
  String get doctorsLoadError;

  /// No description provided for @doctorsNoneForCondition.
  ///
  /// In en, this message translates to:
  /// **'No doctors found for this condition in the local directory.'**
  String get doctorsNoneForCondition;

  /// No description provided for @doctorsNoneGeneral.
  ///
  /// In en, this message translates to:
  /// **'No general physicians found in the local directory.'**
  String get doctorsNoneGeneral;

  /// No description provided for @doctorsDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demonstration data. These are sample records used to show how the directory works - they are not real doctors, and the numbers do not connect to anyone.'**
  String get doctorsDemoNotice;

  /// No description provided for @doctorsDistanceNote.
  ///
  /// In en, this message translates to:
  /// **'Distances are approximate and are not based on your live location.'**
  String get doctorsDistanceNote;

  /// No description provided for @doctorCopiedNumber.
  ///
  /// In en, this message translates to:
  /// **'Copied {name}\'s number'**
  String doctorCopiedNumber(String name);

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get profileSetupTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// No description provided for @profileHeading.
  ///
  /// In en, this message translates to:
  /// **'A little about you'**
  String get profileHeading;

  /// No description provided for @profileIntro.
  ///
  /// In en, this message translates to:
  /// **'This helps MediVoice address you properly and keep your health information in one place. You can skip this and fill it in later.'**
  String get profileIntro;

  /// No description provided for @profilePrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'This is stored on your phone only. It is never uploaded, shared, or sent anywhere, and you can change or delete it at any time.'**
  String get profilePrivacyNote;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageLabel;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get fieldNameHint;

  /// No description provided for @fieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fieldAge;

  /// No description provided for @fieldOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get fieldOptional;

  /// No description provided for @fieldSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get fieldSex;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sexOther;

  /// No description provided for @sexPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get sexPreferNotToSay;

  /// No description provided for @fieldConditions.
  ///
  /// In en, this message translates to:
  /// **'Existing conditions'**
  String get fieldConditions;

  /// No description provided for @fieldConditionsHint.
  ///
  /// In en, this message translates to:
  /// **'Anything you already know about - diabetes, asthma, high blood pressure.'**
  String get fieldConditionsHint;

  /// No description provided for @fieldAddCondition.
  ///
  /// In en, this message translates to:
  /// **'Add a condition'**
  String get fieldAddCondition;

  /// No description provided for @fieldAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get fieldAllergies;

  /// No description provided for @fieldAllergiesHint.
  ///
  /// In en, this message translates to:
  /// **'Medicines, foods or anything else you react to.'**
  String get fieldAllergiesHint;

  /// No description provided for @fieldAddAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add an allergy'**
  String get fieldAddAllergy;

  /// No description provided for @actionSaveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get actionSaveAndContinue;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get actionSkipForNow;

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name to continue.'**
  String get profileNameRequired;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingSub.
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get homeGreetingSub;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your offline health companion'**
  String get homeTagline;

  /// No description provided for @homeHowAreYou.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get homeHowAreYou;

  /// No description provided for @homeTellMe.
  ///
  /// In en, this message translates to:
  /// **'Tell me what\'s wrong in your own words - speak or type, whichever is easier.'**
  String get homeTellMe;

  /// No description provided for @homeTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak now'**
  String get homeTapToSpeak;

  /// No description provided for @homeStartConsultation.
  ///
  /// In en, this message translates to:
  /// **'Start consultation'**
  String get homeStartConsultation;

  /// No description provided for @homeWorksOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get homeWorksOffline;

  /// No description provided for @homeNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet needed'**
  String get homeNoInternet;

  /// No description provided for @homeStaysPrivate.
  ///
  /// In en, this message translates to:
  /// **'Stays private'**
  String get homeStaysPrivate;

  /// No description provided for @homeNothingLeaves.
  ///
  /// In en, this message translates to:
  /// **'Nothing leaves your phone'**
  String get homeNothingLeaves;

  /// No description provided for @homeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Health dashboard'**
  String get homeDashboard;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How MediVoice works'**
  String get homeHowItWorks;

  /// No description provided for @homeDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'MediVoice offers preliminary health awareness only. It is not a diagnosis and does not replace a doctor.'**
  String get homeDisclaimer;

  /// No description provided for @homeProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get homeProfileTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'The language MediVoice is shown and spoken in.'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsLanguageNote.
  ///
  /// In en, this message translates to:
  /// **'Kannada and Hindi are being translated. Anything not yet translated stays in English.'**
  String get settingsLanguageNote;

  /// No description provided for @settingsDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplay;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSize;

  /// No description provided for @settingsMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get settingsMeasurements;

  /// No description provided for @settingsTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get settingsTemperature;

  /// No description provided for @settingsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get settingsWeight;

  /// No description provided for @settingsUnitsNote.
  ///
  /// In en, this message translates to:
  /// **'Readings are stored in one form and converted for display, so switching units never changes a saved value.'**
  String get settingsUnitsNote;

  /// No description provided for @settingsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// No description provided for @settingsVoiceGuidance.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance'**
  String get settingsVoiceGuidance;

  /// No description provided for @settingsVoiceGuidanceSub.
  ///
  /// In en, this message translates to:
  /// **'Reads questions and results aloud'**
  String get settingsVoiceGuidanceSub;

  /// No description provided for @settingsVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance follows the language above. Your phone needs that language\'s voice data installed - if it isn\'t, the app stays silent rather than reading the wrong pronunciation.'**
  String get settingsVoiceNote;

  /// No description provided for @settingsYourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsYourData;

  /// No description provided for @settingsDataNote.
  ///
  /// In en, this message translates to:
  /// **'Your profile, vital readings and past assessments are stored on this phone only. Nothing is uploaded or shared.'**
  String get settingsDataNote;

  /// No description provided for @settingsNothingStored.
  ///
  /// In en, this message translates to:
  /// **'Nothing is stored yet.'**
  String get settingsNothingStored;

  /// No description provided for @settingsCurrentlyStored.
  ///
  /// In en, this message translates to:
  /// **'Currently stored:'**
  String get settingsCurrentlyStored;

  /// No description provided for @settingsDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete health data'**
  String get settingsDeleteData;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete health data?'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove:'**
  String get settingsDeleteBody;

  /// No description provided for @settingsDeleteUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get settingsDeleteUndone;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @settingsDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Health data deleted.'**
  String get settingsDataDeleted;
}

class _AppTextDelegate extends LocalizationsDelegate<AppText> {
  const _AppTextDelegate();

  @override
  Future<AppText> load(Locale locale) {
    return SynchronousFuture<AppText>(lookupAppText(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppTextDelegate old) => false;
}

AppText lookupAppText(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppTextEn();
    case 'hi':
      return AppTextHi();
    case 'kn':
      return AppTextKn();
  }

  throw FlutterError(
    'AppText.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
