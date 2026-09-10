// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppTextHi extends AppText {
  AppTextHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'MediVoice';

  @override
  String get consultGreeting =>
      'नमस्ते! मुझे बताइए आप कैसा महसूस कर रहे हैं - आप बोल सकते हैं या लिख सकते हैं।';

  @override
  String get consultGreetingExample => 'उदाहरण: \"मुझे बुखार और खांसी है\"।';

  @override
  String get consultGreetingSpoken =>
      'नमस्ते। मुझे बताइए आप कैसा महसूस कर रहे हैं। आप बोल सकते हैं या लिख सकते हैं।';

  @override
  String get consultRestart =>
      'फिर से शुरू करते हैं। आप कैसा महसूस कर रहे हैं?';

  @override
  String get consultInputHint => 'लिखें या बोलें';

  @override
  String get consultInputHintListening => 'सुन रहा है...';

  @override
  String get consultInputHintTranscribing => 'लिख रहा है...';

  @override
  String get voiceGuidanceTurnOff => 'आवाज़ मार्गदर्शन बंद करें';

  @override
  String get voiceGuidanceTurnOn => 'आवाज़ मार्गदर्शन चालू करें';

  @override
  String get consultNoSymptoms =>
      'मुझे कोई लक्षण नहीं मिले। सरल शब्दों में बताइए - जैसे \"बुखार और खांसी\"।';

  @override
  String get consultOnlyDenied =>
      'आपने बताया कि आपको क्या नहीं है, लेकिन यह नहीं कि क्या है। आपको क्या तकलीफ़ है?';

  @override
  String get consultDidntCatch =>
      'मैं समझ नहीं पाया। कृपया स्पष्ट बोलकर फिर से कोशिश करें।';

  @override
  String get consultListeningError =>
      'सुनने में कुछ गलत हुआ। फिर से कोशिश करें।';

  @override
  String get consultMicPermission =>
      'सुनने के लिए माइक्रोफ़ोन की अनुमति चाहिए। सेटिंग्स में अनुमति दें या लिखकर बताएं।';

  @override
  String get consultPredictionError => 'कुछ गलत हुआ। फिर से कोशिश करें।';

  @override
  String get questionsTitle => 'कुछ छोटे प्रश्न';

  @override
  String get questionsSubtitle => 'इससे आकलन बेहतर होगा।';

  @override
  String get answerYes => 'हाँ';

  @override
  String get answerNo => 'नहीं';

  @override
  String get severityPrompt => 'कितना गंभीर? (ऐच्छिक)';

  @override
  String get severityMild => 'हल्का';

  @override
  String get severityModerate => 'मध्यम';

  @override
  String get severitySevere => 'गंभीर';

  @override
  String questionsAnsweredCount(int answered, int total) {
    return '$total में से $answered उत्तर दिए';
  }

  @override
  String get actionContinue => 'जारी रखें';

  @override
  String get actionSkipRest => 'बाकी छोड़ दें';

  @override
  String questionsSpokenIntro(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'मेरे पास $count छोटे प्रश्न हैं।',
      one: 'मेरे पास 1 छोटा प्रश्न है।',
    );
    return '$_temp0';
  }

  @override
  String get resultMayBeConsistentWith => 'यह इससे मेल खा सकता है';

  @override
  String resultModelScore(String percent) {
    return 'मॉडल स्कोर: $percent% - यह एक पैटर्न मिलान है, निदान नहीं।';
  }

  @override
  String resultSpoken(String disease, int percent) {
    return 'आपने जो बताया, उसके आधार पर यह $disease से मेल खा सकता है। मॉडल स्कोर $percent प्रतिशत है। यह एक पैटर्न मिलान है, निदान नहीं।';
  }

  @override
  String get resultUncertainTitle =>
      'आपने जो बताया उससे मैं किसी एक स्थिति का सुझाव नहीं दे सकता।';

  @override
  String get resultUncertainBody =>
      'हल्की या शुरुआती बीमारी में यह आम है। मैं फिर भी कुछ सुझाव दे सकता हूँ।';

  @override
  String get resultUncertainSpoken =>
      'आपने जो बताया उससे मैं किसी एक स्थिति का सुझाव नहीं दे सकता। हल्की बीमारी में यह आम है। देखने के लिए टैप करें।';

  @override
  String get actionSeeFullAssessment => 'पूरा आकलन देखें';

  @override
  String get actionSeeWhatYouCanDo => 'क्या करें देखें';

  @override
  String get unclearFindGp => 'सामान्य चिकित्सक खोजें';

  @override
  String get unclearFindGpExplain =>
      'आपके लक्षण स्पष्ट नहीं हैं। एक सामान्य चिकित्सक आपकी जांच कर आगे की सलाह दे सकता है।';

  @override
  String get doctorsGeneralTitle => 'आपके पास के सामान्य चिकित्सक';

  @override
  String get doctorsGeneralSubtitle =>
      'जब लक्षण स्पष्ट न हों, तो सामान्य चिकित्सक से शुरुआत करना अच्छा है।';

  @override
  String questionTemplate(String symptom) {
    return 'क्या आपको $symptom है?';
  }

  @override
  String get resultAppBarTitle => 'प्रारंभिक स्वास्थ्य आकलन';

  @override
  String get resultAppBarFallback => 'आकलन';

  @override
  String get resultNoResult => 'कोई परिणाम उपलब्ध नहीं है।';

  @override
  String get resultPossibleCondition => 'संभावित स्थिति';

  @override
  String resultScoreLine(String percent) {
    return 'मॉडल स्कोर: $percent%';
  }

  @override
  String resultBodyFairlyConfident(String disease) {
    return 'आपने जो लक्षण बताए, उनके आधार पर मॉडल को काफ़ी भरोसा है कि यह $disease से मेल खा सकता है। यह प्रशिक्षण डेटा से मिलान है, चिकित्सकीय निदान नहीं।';
  }

  @override
  String resultBodyModeratelyConfident(String disease) {
    return 'आपने जो लक्षण बताए, उनके आधार पर मॉडल को कुछ हद तक भरोसा है कि यह $disease से मेल खा सकता है। यह प्रशिक्षण डेटा से मिलान है, चिकित्सकीय निदान नहीं।';
  }

  @override
  String get resultRecognizedSymptoms => 'पहचाने गए लक्षण';

  @override
  String get resultDisclaimer =>
      'यह AI मॉडल द्वारा तैयार किया गया प्रारंभिक आकलन है, निदान नहीं। यह पेशेवर चिकित्सकीय सलाह का विकल्प नहीं है। सही निदान और इलाज के लिए योग्य डॉक्टर से मिलें।';

  @override
  String get actionViewAdvice => 'स्वास्थ्य सलाह देखें';

  @override
  String get actionFindDoctors => 'डॉक्टर खोजें';

  @override
  String get actionTryAgain => 'फिर से कोशिश करें';

  @override
  String get actionRetry => 'फिर कोशिश करें';

  @override
  String get actionBackToAssessment => 'आकलन पर वापस जाएं';

  @override
  String get uncertainCardTitle => 'लक्षण स्पष्ट नहीं';

  @override
  String get uncertainInsufficient =>
      'आपने केवल कुछ लक्षण बताए, जो किसी विशेष स्थिति का सुझाव देने के लिए पर्याप्त नहीं हैं। रोज़मर्रा के कई कारणों से भी ये लक्षण हो सकते हैं।';

  @override
  String get uncertainLowConfidence =>
      'आपके लक्षण इस ऐप द्वारा जांची जा सकने वाली किसी एक स्थिति से स्पष्ट रूप से मेल नहीं खाते। हल्की या शुरुआती बीमारी में यह आम है।';

  @override
  String get uncertainWhatYouCanDo => 'अभी आप क्या कर सकते हैं';

  @override
  String get uncertainSeekCare => 'इनमें से कुछ हो तो डॉक्टर से मिलें';

  @override
  String get adviceAppBarTitle => 'स्वास्थ्य सलाह';

  @override
  String get adviceFor => 'इसके लिए सलाह';

  @override
  String get adviceRecommendedSteps => 'सुझाए गए कदम';

  @override
  String get adviceLoadError => 'सलाह लोड नहीं हो सकी।';

  @override
  String get adviceDisclaimer =>
      'यह केवल सामान्य मार्गदर्शन है, पर्चा नहीं। योग्य डॉक्टर से पूछे बिना कोई दवा शुरू या बंद न करें।';

  @override
  String get adviceLevelSerious => 'जल्द से जल्द डॉक्टर से मिलें';

  @override
  String get adviceLevelChronic => 'लंबे समय की स्थिति - निगरानी ज़रूरी';

  @override
  String get adviceLevelModerate => 'मध्यम - ध्यान से देखें';

  @override
  String get adviceLevelMild => 'आमतौर पर हल्का, अपने आप ठीक हो जाता है';

  @override
  String get doctorsAppBarTitle => 'नज़दीकी डॉक्टर';

  @override
  String get doctorsFor => 'इसके लिए डॉक्टर';

  @override
  String doctorsFoundCount(int count) {
    return '$count मिले, नज़दीकी पहले';
  }

  @override
  String get doctorsLoadError => 'डॉक्टरों की सूची लोड नहीं हो सकी।';

  @override
  String get doctorsNoneForCondition =>
      'स्थानीय सूची में इस स्थिति के लिए कोई डॉक्टर नहीं मिला।';

  @override
  String get doctorsNoneGeneral =>
      'स्थानीय सूची में कोई सामान्य चिकित्सक नहीं मिला।';

  @override
  String get doctorsDemoNotice =>
      'प्रदर्शन के लिए डेटा। ये नमूना रिकॉर्ड हैं जो दिखाते हैं कि निर्देशिका कैसे काम करती है - ये असली डॉक्टर नहीं हैं, और ये नंबर किसी से नहीं जुड़ते।';

  @override
  String get doctorsDistanceNote =>
      'दूरियां अनुमानित हैं और आपके वर्तमान स्थान पर आधारित नहीं हैं।';

  @override
  String doctorCopiedNumber(String name) {
    return '$name का नंबर कॉपी हो गया';
  }

  @override
  String get profileSetupTitle => 'अपनी प्रोफ़ाइल बनाएं';

  @override
  String get profileTitle => 'आपकी प्रोफ़ाइल';

  @override
  String get profileHeading => 'आपके बारे में थोड़ा';

  @override
  String get profileIntro =>
      'इससे MediVoice आपको सही तरीके से संबोधित कर सकेगा और आपकी स्वास्थ्य जानकारी एक जगह रख सकेगा। आप इसे छोड़कर बाद में भर सकते हैं।';

  @override
  String get profilePrivacyNote =>
      'यह केवल आपके फ़ोन पर रहता है। इसे कहीं भेजा या साझा नहीं किया जाता, और आप इसे कभी भी बदल या हटा सकते हैं।';

  @override
  String get profileLanguageLabel => 'भाषा';

  @override
  String get fieldName => 'नाम';

  @override
  String get fieldNameHint => 'आपको क्या कहकर बुलाएं?';

  @override
  String get fieldAge => 'उम्र';

  @override
  String get fieldOptional => 'वैकल्पिक';

  @override
  String get fieldSex => 'लिंग';

  @override
  String get sexFemale => 'महिला';

  @override
  String get sexMale => 'पुरुष';

  @override
  String get sexOther => 'अन्य';

  @override
  String get sexPreferNotToSay => 'बताना नहीं चाहते';

  @override
  String get fieldConditions => 'मौजूदा बीमारियां';

  @override
  String get fieldConditionsHint =>
      'जो आपको पहले से पता हो - डायबिटीज़, अस्थमा, ब्लड प्रेशर।';

  @override
  String get fieldAddCondition => 'बीमारी जोड़ें';

  @override
  String get fieldAllergies => 'एलर्जी';

  @override
  String get fieldAllergiesHint => 'दवा, खाना या कुछ और जो आपको सूट न करता हो।';

  @override
  String get fieldAddAllergy => 'एलर्जी जोड़ें';

  @override
  String get actionSaveAndContinue => 'सहेजें और आगे बढ़ें';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionSkipForNow => 'अभी छोड़ें';

  @override
  String get profileNameRequired => 'आगे बढ़ने के लिए नाम भरें।';

  @override
  String homeGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get homeGreetingSub => 'आज मैं आपकी क्या मदद करूं?';

  @override
  String get homeTagline => 'आपका ऑफ़लाइन स्वास्थ्य साथी';

  @override
  String get homeHowAreYou => 'आज आप कैसा महसूस कर रहे हैं?';

  @override
  String get homeTellMe =>
      'अपने शब्दों में बताइए क्या तकलीफ़ है - बोलें या लिखें, जो आसान लगे।';

  @override
  String get homeTapToSpeak => 'बोलने के लिए दबाएं';

  @override
  String get homeStartConsultation => 'परामर्श शुरू करें';

  @override
  String get homeWorksOffline => 'ऑफ़लाइन काम करता है';

  @override
  String get homeNoInternet => 'इंटरनेट की ज़रूरत नहीं';

  @override
  String get homeStaysPrivate => 'निजी रहता है';

  @override
  String get homeNothingLeaves => 'कुछ भी आपके फ़ोन से बाहर नहीं जाता';

  @override
  String get homeDashboard => 'स्वास्थ्य डैशबोर्ड';

  @override
  String get homeSettings => 'सेटिंग्स';

  @override
  String get homeHowItWorks => 'MediVoice कैसे काम करता है';

  @override
  String get homeDisclaimer =>
      'MediVoice केवल प्रारंभिक स्वास्थ्य जानकारी देता है। यह निदान नहीं है और डॉक्टर का विकल्प नहीं है।';

  @override
  String get homeProfileTooltip => 'आपकी प्रोफ़ाइल';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageDesc => 'MediVoice किस भाषा में दिखेगा और बोलेगा।';

  @override
  String get settingsLanguageNote =>
      'कन्नड़ और हिंदी का अनुवाद चल रहा है। जो अभी तक अनुवादित नहीं है वह अंग्रेज़ी में ही रहेगा।';

  @override
  String get settingsDisplay => 'प्रदर्शन';

  @override
  String get settingsTextSize => 'टेक्स्ट का आकार';

  @override
  String get settingsMeasurements => 'माप';

  @override
  String get settingsTemperature => 'तापमान';

  @override
  String get settingsWeight => 'वज़न';

  @override
  String get settingsUnitsNote =>
      'रीडिंग एक ही रूप में सहेजी जाती हैं और दिखाने के लिए बदली जाती हैं, इसलिए यूनिट बदलने से सहेजा गया मान नहीं बदलता।';

  @override
  String get settingsVoice => 'आवाज़';

  @override
  String get settingsVoiceGuidance => 'आवाज़ मार्गदर्शन';

  @override
  String get settingsVoiceGuidanceSub => 'सवाल और नतीजे पढ़कर सुनाता है';

  @override
  String get settingsVoiceNote =>
      'आवाज़ मार्गदर्शन ऊपर की भाषा के अनुसार चलता है। आपके फ़ोन में उस भाषा का वॉइस डेटा होना चाहिए - न हो तो ऐप ग़लत उच्चारण के बजाय चुप रहता है।';

  @override
  String get settingsYourData => 'आपका डेटा';

  @override
  String get settingsDataNote =>
      'आपकी प्रोफ़ाइल, स्वास्थ्य रीडिंग और पिछले आकलन केवल इसी फ़ोन पर रहते हैं। कुछ भी अपलोड या साझा नहीं किया जाता।';

  @override
  String get settingsNothingStored => 'अभी कुछ भी सहेजा नहीं है।';

  @override
  String get settingsCurrentlyStored => 'अभी सहेजा गया:';

  @override
  String get settingsDeleteData => 'स्वास्थ्य डेटा हटाएं';

  @override
  String get settingsDeleteTitle => 'स्वास्थ्य डेटा हटाएं?';

  @override
  String get settingsDeleteBody => 'यह स्थायी रूप से हटा देगा:';

  @override
  String get settingsDeleteUndone => 'इसे वापस नहीं लाया जा सकता।';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get settingsDataDeleted => 'स्वास्थ्य डेटा हटा दिया गया।';

  @override
  String get vitalsTitle => 'स्वास्थ्य माप';

  @override
  String get vitalsTrendsTooltip => 'रुझान';

  @override
  String get vitalsUnitsTooltip => 'यूनिट';

  @override
  String get vitalsPrivacyNote =>
      'रीडिंग केवल इसी फ़ोन पर रहती हैं। MediVoice सिर्फ़ वही दर्ज करता है जो आप भरते हैं - यह संख्याओं का विश्लेषण नहीं करता और न ही बताता है कि रीडिंग सामान्य है या नहीं।';

  @override
  String get vitalsNotRecorded => 'अभी दर्ज नहीं';

  @override
  String vitalsLastRecorded(String when) {
    return 'पिछली बार: $when';
  }

  @override
  String get vitalsAddReading => 'रीडिंग जोड़ें';

  @override
  String vitalsMeasuredIn(String unit) {
    return '$unit में मापा जाता है';
  }

  @override
  String vitalsRecordedOn(String when) {
    return '$when दर्ज किया गया';
  }

  @override
  String get vitalsChangeDate => 'बदलें';

  @override
  String get vitalsNoteLabel => 'नोट (वैकल्पिक)';

  @override
  String get vitalsNoteHint => 'जैसे खाने से पहले, टहलने के बाद';

  @override
  String get vitalsSaveReading => 'रीडिंग सहेजें';

  @override
  String vitalsErrEnterNumber(String field) {
    return '$field के लिए संख्या भरें।';
  }

  @override
  String vitalsErrOutOfRange(
    String vital,
    String low,
    String high,
    String unit,
  ) {
    return 'यह $vital की रीडिंग नहीं लगती। लगभग $low से $high $unit की उम्मीद है।';
  }

  @override
  String get vitalsErrNeedLower => 'नीचे वाला नंबर भी भरें।';

  @override
  String get vitalsErrLowerRange => 'वह नीचे वाला नंबर सही नहीं लगता।';

  @override
  String get vitalsErrLowerHigher =>
      'नीचे वाला नंबर आमतौर पर ऊपर वाले से कम होता है - जांच लें।';

  @override
  String get unitsTitle => 'यूनिट';

  @override
  String get unitsDescription =>
      'अपनी पसंद की यूनिट चुनें। पहले से सहेजी गई रीडिंग बदली नहीं जातीं, सिर्फ़ बदलकर दिखाई जाती हैं।';

  @override
  String get actionDone => 'हो गया';

  @override
  String get vitalBloodPressure => 'ब्लड प्रेशर';

  @override
  String get vitalBloodGlucose => 'ब्लड शुगर';

  @override
  String get vitalPulse => 'नाड़ी की गति';

  @override
  String get vitalOxygen => 'ऑक्सीजन स्तर';

  @override
  String get vitalTemperature => 'शरीर का तापमान';

  @override
  String get vitalWeight => 'वज़न';

  @override
  String get vitalBpUpper => 'ऊपर वाला नंबर';

  @override
  String get vitalBpLower => 'नीचे वाला नंबर';

  @override
  String get dateToday => 'आज';

  @override
  String get dateYesterday => 'कल';

  @override
  String dateDaysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String get historyTitle => 'पिछले आकलन';

  @override
  String get historyDeleteAllTooltip => 'सभी हटाएं';

  @override
  String get historyDeleteAllTitle => 'सभी आकलन हटाएं?';

  @override
  String get historyDeleteAllBody =>
      'यह इस फ़ोन से सहेजे गए सभी आकलन हटा देगा। इसे वापस नहीं लाया जा सकता।';

  @override
  String get actionDeleteAll => 'सभी हटाएं';

  @override
  String get historyEmptyTitle => 'अभी कोई आकलन नहीं';

  @override
  String get historyEmptyBody =>
      'परामर्श पूरा करने के बाद वह यहां सहेजा जाएगा, ताकि आप बाद में देख सकें।';

  @override
  String get historySymptomsUnclear => 'लक्षण स्पष्ट नहीं';

  @override
  String get historyNoMatch => 'कोई एक स्थिति स्पष्ट रूप से मेल नहीं खाई';

  @override
  String get historyReportedSeverity => 'बताई गई गंभीरता';

  @override
  String historyRuledOut(int count, int rounds) {
    return '$rounds दौर के सवालों में $count लक्षण हटाए गए';
  }

  @override
  String get trendsTitle => 'स्वास्थ्य रुझान';

  @override
  String get trendsRange7 => '7 दिन';

  @override
  String get trendsRange30 => '30 दिन';

  @override
  String get trendsRangeAll => 'सभी';

  @override
  String get trendsNotEnoughTitle => 'अभी पर्याप्त रीडिंग नहीं';

  @override
  String trendsNotEnoughBody(String vital) {
    return 'रुझान देखने के लिए अलग-अलग दिनों की कम से कम दो $vital रीडिंग दर्ज करें।';
  }

  @override
  String get trendsNothingInPeriodTitle => 'इस अवधि में कुछ नहीं';

  @override
  String trendsNothingInPeriodBody(int count, String vital) {
    return '$count $vital रीडिंग दर्ज हैं, लेकिन इस अवधि में दो से कम हैं। बड़ी अवधि चुनें।';
  }

  @override
  String get trendsLatestReading => 'नवीनतम रीडिंग';

  @override
  String trendsReadingsShown(int count) {
    return '$count रीडिंग दिखाई गई';
  }
}
