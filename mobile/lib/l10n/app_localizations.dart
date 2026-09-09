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
