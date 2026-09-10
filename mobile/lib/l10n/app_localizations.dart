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

  /// No description provided for @vitalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get vitalsTitle;

  /// No description provided for @vitalsTrendsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get vitalsTrendsTooltip;

  /// No description provided for @vitalsUnitsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get vitalsUnitsTooltip;

  /// No description provided for @vitalsPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Readings are stored on this phone only. MediVoice records what you enter - it does not interpret the numbers or tell you whether a reading is normal.'**
  String get vitalsPrivacyNote;

  /// No description provided for @vitalsNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded yet'**
  String get vitalsNotRecorded;

  /// No description provided for @vitalsLastRecorded.
  ///
  /// In en, this message translates to:
  /// **'Last recorded: {when}'**
  String vitalsLastRecorded(String when);

  /// No description provided for @vitalsAddReading.
  ///
  /// In en, this message translates to:
  /// **'Add reading'**
  String get vitalsAddReading;

  /// No description provided for @vitalsMeasuredIn.
  ///
  /// In en, this message translates to:
  /// **'Measured in {unit}'**
  String vitalsMeasuredIn(String unit);

  /// No description provided for @vitalsRecordedOn.
  ///
  /// In en, this message translates to:
  /// **'Recorded {when}'**
  String vitalsRecordedOn(String when);

  /// No description provided for @vitalsChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get vitalsChangeDate;

  /// No description provided for @vitalsNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get vitalsNoteLabel;

  /// No description provided for @vitalsNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. before food, after a walk'**
  String get vitalsNoteHint;

  /// No description provided for @vitalsSaveReading.
  ///
  /// In en, this message translates to:
  /// **'Save reading'**
  String get vitalsSaveReading;

  /// No description provided for @vitalsErrEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number for {field}.'**
  String vitalsErrEnterNumber(String field);

  /// No description provided for @vitalsErrOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a {vital} reading. Expected roughly {low} to {high} {unit}.'**
  String vitalsErrOutOfRange(
    String vital,
    String low,
    String high,
    String unit,
  );

  /// No description provided for @vitalsErrNeedLower.
  ///
  /// In en, this message translates to:
  /// **'Enter the lower number too.'**
  String get vitalsErrNeedLower;

  /// No description provided for @vitalsErrLowerRange.
  ///
  /// In en, this message translates to:
  /// **'That lower number looks out of range.'**
  String get vitalsErrLowerRange;

  /// No description provided for @vitalsErrLowerHigher.
  ///
  /// In en, this message translates to:
  /// **'The lower number is usually smaller than the upper one - please check.'**
  String get vitalsErrLowerHigher;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsTitle;

  /// No description provided for @unitsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the units you prefer. Readings you have already saved are converted, not changed.'**
  String get unitsDescription;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @vitalBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get vitalBloodPressure;

  /// No description provided for @vitalBloodGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood glucose'**
  String get vitalBloodGlucose;

  /// No description provided for @vitalPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse rate'**
  String get vitalPulse;

  /// No description provided for @vitalOxygen.
  ///
  /// In en, this message translates to:
  /// **'Oxygen saturation'**
  String get vitalOxygen;

  /// No description provided for @vitalTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get vitalTemperature;

  /// No description provided for @vitalWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get vitalWeight;

  /// No description provided for @vitalBpUpper.
  ///
  /// In en, this message translates to:
  /// **'Upper number'**
  String get vitalBpUpper;

  /// No description provided for @vitalBpLower.
  ///
  /// In en, this message translates to:
  /// **'Lower number'**
  String get vitalBpLower;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String dateDaysAgo(int days);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Past assessments'**
  String get historyTitle;

  /// No description provided for @historyDeleteAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get historyDeleteAllTooltip;

  /// No description provided for @historyDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all assessments?'**
  String get historyDeleteAllTitle;

  /// No description provided for @historyDeleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every saved assessment from this phone. It cannot be undone.'**
  String get historyDeleteAllBody;

  /// No description provided for @actionDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get actionDeleteAll;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No assessments yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Once you complete a consultation it will be saved here so you can look back at it later.'**
  String get historyEmptyBody;

  /// No description provided for @historySymptomsUnclear.
  ///
  /// In en, this message translates to:
  /// **'Symptoms unclear'**
  String get historySymptomsUnclear;

  /// No description provided for @historyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No single condition matched clearly'**
  String get historyNoMatch;

  /// No description provided for @historyReportedSeverity.
  ///
  /// In en, this message translates to:
  /// **'Reported severity'**
  String get historyReportedSeverity;

  /// No description provided for @historyRuledOut.
  ///
  /// In en, this message translates to:
  /// **'{count} symptom(s) ruled out over {rounds} follow-up round(s)'**
  String historyRuledOut(int count, int rounds);

  /// No description provided for @trendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health trends'**
  String get trendsTitle;

  /// No description provided for @trendsRange7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get trendsRange7;

  /// No description provided for @trendsRange30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get trendsRange30;

  /// No description provided for @trendsRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get trendsRangeAll;

  /// No description provided for @trendsNotEnoughTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough readings yet'**
  String get trendsNotEnoughTitle;

  /// No description provided for @trendsNotEnoughBody.
  ///
  /// In en, this message translates to:
  /// **'Record at least two {vital} readings on different days to see a trend.'**
  String trendsNotEnoughBody(String vital);

  /// No description provided for @trendsNothingInPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this period'**
  String get trendsNothingInPeriodTitle;

  /// No description provided for @trendsNothingInPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'There are {count} {vital} readings recorded, but fewer than two fall in this range. Try a longer period.'**
  String trendsNothingInPeriodBody(int count, String vital);

  /// No description provided for @trendsLatestReading.
  ///
  /// In en, this message translates to:
  /// **'Latest reading'**
  String get trendsLatestReading;

  /// No description provided for @trendsReadingsShown.
  ///
  /// In en, this message translates to:
  /// **'{count} readings shown'**
  String trendsReadingsShown(int count);

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetEvening;

  /// No description provided for @greetWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetWithName(String greeting, String name);

  /// No description provided for @dashTitle.
  ///
  /// In en, this message translates to:
  /// **'Health dashboard'**
  String get dashTitle;

  /// No description provided for @dashOverview.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your health overview.'**
  String get dashOverview;

  /// No description provided for @dashAge.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String dashAge(int age);

  /// No description provided for @dashConditionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 condition} other{{count} conditions}}'**
  String dashConditionCount(int count);

  /// No description provided for @dashAllergyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 allergy} other{{count} allergies}}'**
  String dashAllergyCount(int count);

  /// No description provided for @dashLatestVitals.
  ///
  /// In en, this message translates to:
  /// **'Latest vitals'**
  String get dashLatestVitals;

  /// No description provided for @dashViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashViewAll;

  /// No description provided for @dashAddFirstReading.
  ///
  /// In en, this message translates to:
  /// **'Add your first reading to start building a record.'**
  String get dashAddFirstReading;

  /// No description provided for @dashTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get dashTapToAdd;

  /// No description provided for @dashRecentAssessments.
  ///
  /// In en, this message translates to:
  /// **'Recent assessments'**
  String get dashRecentAssessments;

  /// No description provided for @dashNoAssessmentsBody.
  ///
  /// In en, this message translates to:
  /// **'Start a consultation and the result will appear here.'**
  String get dashNoAssessmentsBody;

  /// No description provided for @dashYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get dashYourProfile;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @dashNoneRecorded.
  ///
  /// In en, this message translates to:
  /// **'None recorded'**
  String get dashNoneRecorded;

  /// No description provided for @dashNoProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'No profile yet'**
  String get dashNoProfileTitle;

  /// No description provided for @dashNoProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Add your details so MediVoice can keep your health information in one place.'**
  String get dashNoProfileBody;

  /// No description provided for @dashSetUpProfile.
  ///
  /// In en, this message translates to:
  /// **'Set up profile'**
  String get dashSetUpProfile;

  /// No description provided for @dashQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashQuickActions;

  /// No description provided for @dashAddVital.
  ///
  /// In en, this message translates to:
  /// **'Add a vital reading'**
  String get dashAddVital;

  /// No description provided for @dashViewTrends.
  ///
  /// In en, this message translates to:
  /// **'View health trends'**
  String get dashViewTrends;

  /// No description provided for @dashViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View past assessments'**
  String get dashViewHistory;

  /// No description provided for @dashEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get dashEditProfile;

  /// No description provided for @dashStoredHere.
  ///
  /// In en, this message translates to:
  /// **'Everything shown here is stored on this phone only.'**
  String get dashStoredHere;

  /// No description provided for @howToTitle.
  ///
  /// In en, this message translates to:
  /// **'How MediVoice Works'**
  String get howToTitle;

  /// No description provided for @howToHeading.
  ///
  /// In en, this message translates to:
  /// **'A consultation, step by step'**
  String get howToHeading;

  /// No description provided for @howToSubheading.
  ///
  /// In en, this message translates to:
  /// **'Everything below happens on your phone.'**
  String get howToSubheading;

  /// No description provided for @howToStep1Title.
  ///
  /// In en, this message translates to:
  /// **'You speak'**
  String get howToStep1Title;

  /// No description provided for @howToStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Describe how you\'re feeling in Kannada, Hindi or English. You can type instead if you\'d rather.'**
  String get howToStep1Body;

  /// No description provided for @howToStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Your phone listens'**
  String get howToStep2Title;

  /// No description provided for @howToStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Speech becomes text using a compact recognition model running on the device itself. Your voice is never uploaded.'**
  String get howToStep2Body;

  /// No description provided for @howToStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Symptoms are identified'**
  String get howToStep3Title;

  /// No description provided for @howToStep3Body.
  ///
  /// In en, this message translates to:
  /// **'What you said is matched against a multilingual symptom vocabulary. Saying you DON\'T have something counts too.'**
  String get howToStep3Body;

  /// No description provided for @howToStep4Title.
  ///
  /// In en, this message translates to:
  /// **'A few questions'**
  String get howToStep4Title;

  /// No description provided for @howToStep4Body.
  ///
  /// In en, this message translates to:
  /// **'If there isn\'t enough to go on, you\'ll be asked a short set of yes/no questions chosen to narrow the possibilities.'**
  String get howToStep4Body;

  /// No description provided for @howToStep5Title.
  ///
  /// In en, this message translates to:
  /// **'A preliminary assessment'**
  String get howToStep5Title;

  /// No description provided for @howToStep5Body.
  ///
  /// In en, this message translates to:
  /// **'A lightweight model suggests what the pattern may be consistent with. If it isn\'t confident, it says so instead of guessing.'**
  String get howToStep5Body;

  /// No description provided for @howToStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Guidance and next steps'**
  String get howToStep6Title;

  /// No description provided for @howToStep6Body.
  ///
  /// In en, this message translates to:
  /// **'Practical self-care suggestions, warning signs to watch for, and the kind of specialist worth seeing.'**
  String get howToStep6Body;

  /// No description provided for @howToPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your consultation stays with you'**
  String get howToPrivacyTitle;

  /// No description provided for @howToPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Symptoms, recordings and results are never sent anywhere. The app works with the network switched off - apart from a one-time download of the speech model when you first use it.'**
  String get howToPrivacyBody;

  /// No description provided for @howToNotDiagnosisTitle.
  ///
  /// In en, this message translates to:
  /// **'This is not a diagnosis'**
  String get howToNotDiagnosisTitle;

  /// No description provided for @howToNotDiagnosisBody.
  ///
  /// In en, this message translates to:
  /// **'MediVoice matches patterns against training data to raise awareness. It cannot examine you, it covers a limited set of conditions, and it is not a substitute for a qualified doctor.'**
  String get howToNotDiagnosisBody;
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
