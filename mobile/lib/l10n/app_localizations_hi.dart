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
}
