import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ta'),
    Locale('hi'),
    Locale('te'),
    Locale('kn'),
    Locale('ml'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String _t(
    String en,
    String ta,
    String hi, {
    String? te,
    String? kn,
    String? ml,
  }) {
    switch (locale.languageCode) {
      case 'ta':
        return ta;
      case 'hi':
        return hi;
      case 'te':
        return te ?? en;
      case 'kn':
        return kn ?? en;
      case 'ml':
        return ml ?? en;
      default:
        return en;
    }
  }

  // Bottom navigation
  String get navHome => _t('Home', 'முகப்பு', 'होम', te: 'హోమ్', kn: 'ಮುಖಪುಟ', ml: 'ഹോം');
  String get navDuties => _t('Duties', 'பணிகள்', 'ड्यूटी', te: 'డ్యూటీలు', kn: 'ಕರ್ತವ್ಯಗಳು', ml: 'ഡ്യൂട്ടികൾ');
  String get navJobs => _t('Jobs', 'வேலைகள்', 'नौकरियाँ', te: 'ఉద్యోగాలు', kn: 'ಉದ್ಯೋಗಗಳು', ml: 'ജോലികൾ');
  String get navCommunity => _t('Community', 'சமூகம்', 'समुदाय', te: 'సమాజం', kn: 'ಸಮುದಾಯ', ml: 'കമ്മ്യൂണിറ്റി');
  String get navMessages => _t('Messages', 'செய்திகள்', 'संदेश', te: 'సందేశాలు', kn: 'ಸಂದೇಶಗಳು', ml: 'സന്ദേശങ്ങൾ');
  String get navProfile => _t('Profile', 'சுயவிவரம்', 'प्रोफ़ाइल', te: 'ప్రొఫైల్', kn: 'ಪ್ರೊಫೈಲ್', ml: 'പ്രൊഫൈൽ');

  // Duties & Jobs
  String get duties => _t('Duties', 'பணிகள்', 'ड्यूटी', te: 'డ్యూటీలు', kn: 'ಕರ್ತವ್ಯಗಳು', ml: 'ഡ്യൂട്ടികൾ');
  String get jobs => _t('Jobs', 'வேலைகள்', 'नौकरियाँ', te: 'ఉద్యోగాలు', kn: 'ಉದ್ಯೋಗಗಳು', ml: 'ജോലികൾ');
  String get nearby => _t('Nearby', 'அருகிலுள்ள', 'नज़दीकी', te: 'సమీపంలో', kn: 'ಹತ್ತಿರ', ml: 'അടുത്തുള്ള');
  String get recommended => _t('Recommended', 'பரிந்துரைக்கப்பட்ட', 'अनुशंसित', te: 'సిఫార్సు', kn: 'ಶಿಫಾರಸು', ml: 'ശുപാർശ');
  String get applied => _t('Applied', 'விண்ணப்பித்தது', 'आवेदन किया', te: 'దరఖాస్తు', kn: 'ಅರ್ಜಿ ಸಲ್ಲಿಸಲಾಗಿದೆ', ml: 'അപേക്ഷിച്ചു');
  String get saved => _t('Saved', 'சேமிக்கப்பட்டது', 'सहेजा गया', te: 'సేవ్ చేయబడింది', kn: 'ಉಳಿಸಲಾಗಿದೆ', ml: 'സേവ് ചെയ്തു');
  String get upcoming => _t('Upcoming', 'வரவிருக்கும்', 'आगामी', te: 'రాబోయే', kn: 'ಮುಂದಿನ', ml: 'വരാനിരിക്കുന്ന');
  String get completed => _t('Completed', 'முடிந்தது', 'पूर्ण', te: 'పూర్తయింది', kn: 'ಪೂರ್ಣಗೊಂಡಿದೆ', ml: 'പൂർത്തിയായി');
  String get apply => _t('Apply', 'விண்ணப்பி', 'आवेदन करें', te: 'దరఖాస్తు', kn: 'ಅರ್ಜಿ ಸಲ್ಲಿಸಿ', ml: 'അപേക്ഷിക്കുക');
  String get contact => _t('Contact', 'தொடர்பு', 'संपर्क', te: 'సంప్రదించండి', kn: 'ಸಂಪರ್ಕ', ml: 'ബന്ധപ്പെടുക');
  String get searchDuties => _t(
        'Search city, hospital or duty...',
        'நகரம், மருத்துவமனை அல்லது பணியைத் தேடு...',
        'शहर, अस्पताल या ड्यूटी खोजें...',
        te: 'నగరం, ఆసుపత్రి లేదా డ్యూటీ వెతకండి...',
        kn: 'ನಗರ, ಆಸ್ಪತ್ರೆ ಅಥವಾ ಕರ್ತವ್ಯ ಹುಡುಕಿ...',
        ml: 'നഗരം, ആശുപത്രി അല്ലെങ്കിൽ ഡ്യൂട്ടി തിരയുക...',
      );
  String get searchJobs => _t(
        'Search title, specialty, hospital...',
        'பதவி, சிறப்பு, மருத்துவமனையைத் தேடு...',
        'पद, विशेषता, अस्पताल खोजें...',
        te: 'శీర్షిక, స్పెషాలిటీ, ఆసుపత్రి వెతకండి...',
        kn: 'ಶೀರ್ಷಿಕೆ, ವಿಶೇಷತೆ, ಆಸ್ಪತ್ರೆ ಹುಡುಕಿ...',
        ml: 'തലക്കെട്ട്, സ്പെഷ്യാലിറ്റി, ആശുപത്രി തിരയുക...',
      );
  String get offlineCachedBanner => _t(
        "You're offline — showing cached results.",
        'நீங்கள் ஆஃப்லைனில் — சேமிக்கப்பட்ட முடிவுகள் காட்டப்படுகின்றன.',
        'आप ऑफ़लाइन हैं — कैश किए परिणाम दिखाए जा रहे हैं।',
        te: 'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు — కాష్ ఫలితాలు చూపిస్తున్నాం.',
        kn: 'ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ — ಕ್ಯಾಶ್ ಫಲಿತಾಂಶಗಳನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ.',
        ml: 'നിങ്ങൾ ഓഫ്‌ലൈനാണ് — കാഷ് ഫലങ്ങൾ കാണിക്കുന്നു.',
      );
  String get dutySaved => _t('Duty saved', 'பணி சேமிக்கப்பட்டது', 'ड्यूटी सहेजी गई', te: 'డ్యూటీ సేవ్ అయింది', kn: 'ಕರ್ತವ್ಯ ಉಳಿಸಲಾಗಿದೆ', ml: 'ഡ്യൂട്ടി സേവ് ചെയ്തു');
  String get dutyRemoved => _t('Removed from saved duties', 'சேமித்த பணிகளிலிருந்து நீக்கப்பட்டது', 'सहेजी गई ड्यूटी से हटाया गया', te: 'సేవ్ చేసిన డ్యూటీల నుండి తీసివేయబడింది', kn: 'ಉಳಿಸಿದ ಕರ್ತವ್ಯಗಳಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ', ml: 'സേവ് ചെയ്ത ഡ്യൂട്ടികളിൽ നിന്ന് നീക്കി');
  String get applicationSubmitted => _t('Application submitted successfully.', 'விண்ணப்பம் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது.', 'आवेदन सफलतापूर्वक जमा हो गया।', te: 'దరఖాస్తు విజయవంతంగా సమర్పించబడింది.', kn: 'ಅರ್ಜಿ ಯಶಸ್ವಿಯಾಗಿ ಸಲ್ಲಿಸಲಾಗಿದೆ.', ml: 'അപേക്ഷ വിജയകരമായി സമർപ്പിച്ചു.');

  // Common
  String get close => _t('Close', 'மூடு', 'बंद करें');
  String get save => _t('Save', 'சேமி', 'सहेजें');
  String get submit => _t('Submit', 'சமர்ப்பி', 'जमा करें');
  String get manage => _t('Manage', 'நிர்வகி', 'प्रबंधित करें');
  String get allowed => _t('Allowed', 'அனுமதிக்கப்பட்டது', 'अनुमति है');
  String get notAllowed => _t('Not allowed', 'அனுமதிக்கப்படவில்லை', 'अनुमति नहीं');
  String get browserPermissionHint => _t(
        'Use your browser permission prompt or site settings to allow this.',
        'இதை அனுமதிக்க உலாவி அனுமதி அல்லது தள அமைப்புகளைப் பயன்படுத்தவும்.',
        'इसे अनुमति देने के लिए ब्राउज़र अनुमति या साइट सेटिंग्स का उपयोग करें।',
      );

  // Settings
  String get settings => _t('Settings', 'அமைப்புகள்', 'सेटिंग्स');
  String get account => _t('Account', 'கணக்கு', 'खाता');
  String get accountInfo => _t('Account info', 'கணக்கு தகவல்', 'खाता जानकारी');
  String get changePassword => _t('Change Password', 'கடவுச்சொல் மாற்று', 'पासवर्ड बदलें');
  String get emailPhone => _t('Email & Phone', 'மின்னஞ்சல் & தொலைபேசி', 'ईमेल और फ़ोन');
  String get deleteAccount => _t('Delete Account', 'கணக்கை நீக்கு', 'खाता हटाएँ');
  String get deactivateAccount => _t('Deactivate Account', 'கணக்கை செயலிழக்கச் செய்', 'खाता निष्क्रिय करें');
  String get notifications => _t('Notifications', 'அறிவிப்புகள்', 'सूचनाएँ');
  String get push => _t('Push', 'புஷ்', 'पुश');
  String get dutyAlerts => _t('Duty Alerts', 'பணி எச்சரிக்கைகள்', 'ड्यूटी अलर्ट');
  String get community => _t('Community', 'சமூகம்', 'समुदाय');
  String get messages => _t('Messages', 'செய்திகள்', 'संदेश');
  String get privacy => _t('Privacy', 'தனியுரிமை', 'गोपनीयता');
  String get profileVisibility => _t('Profile Visibility', 'சுயவிவர தெரிவுநிலை', 'प्रोफ़ाइल दृश्यता');
  String get onlineStatus => _t('Online Status', 'ஆன்லைன் நிலை', 'ऑनलाइन स्थिति');
  String get followersFollowing => _t('Followers & Following', 'பின்தொடர்பவர்கள் & பின்தொடர்தல்', 'फ़ॉलोअर्स और फ़ॉलोइंग');
  String get blockedUsers => _t('Blocked Users', 'தடுக்கப்பட்ட பயனர்கள்', 'ब्लॉक किए गए उपयोगकर्ता');
  String get security => _t('Security', 'பாதுகாப்பு', 'सुरक्षा');
  String get biometricLogin => _t('Face ID/Biometric', 'Face ID/பயோமெட்ரிக்', 'Face ID/बायोमेट्रिक');
  String get twoFactorAuth => _t('Two-Factor Auth', 'இரண்டு-காரணி அங்கீகாரம்', 'दो-कारक प्रमाणीकरण');
  String get loginActivity => _t('Login Activity', 'உள்நுழைவு செயல்பாடு', 'लॉगिन गतिविधि');
  String get trustedDevices => _t('Trusted Devices', 'நம்பகமான சாதனங்கள்', 'विश्वसनीय उपकरण');
  String get preferences => _t('Preferences', 'விருப்பத்தேர்வுகள்', 'प्राथमिकताएँ');
  String get appearance => _t('Appearance', 'தோற்றம்', 'दिखावट');
  String get language => _t('Language', 'மொழி', 'भाषा');
  String get permissions => _t('Permissions', 'அனுமதிகள்', 'अनुमतियाँ');
  String get support => _t('Support', 'ஆதரவு', 'सहायता');
  String get helpCenter => _t('Help Center', 'உதவி மையம்', 'सहायता केंद्र');
  String get faq => _t('FAQ', 'அடிக்கடி கேட்கப்படும் கேள்விகள்', 'अक्सर पूछे जाने वाले प्रश्न');
  String get reportIssue => _t('Report Issue', 'சிக்கலைப் புகாரளி', 'समस्या रिपोर्ट करें');
  String get contactSupport => _t('Contact Support', 'ஆதரவைத் தொடர்பு கொள்', 'सहायता से संपर्क करें');
  String get legalAbout => _t('Legal & About', 'சட்டம் & பற்றி', 'कानूनी और परिचय');
  String get terms => _t('Terms', 'விதிமுறைகள்', 'नियम');
  String get privacyPolicy => _t('Privacy Policy', 'தனியுரிமைக் கொள்கை', 'गोपनीयता नीति');
  String get appVersion => _t('App Version', 'பயன்பாட்டு பதிப்பு', 'ऐप संस्करण');
  String get languageSaved => _t('Language updated.', 'மொழி புதுப்பிக்கப்பட்டது.', 'भाषा अपडेट की गई।');
  String get twoFactorEnabled => _t('Enabled', 'இயக்கப்பட்டது', 'सक्षम');
  String get twoFactorDisabled => _t('Disabled', 'முடக்கப்பட்டது', 'अक्षम');

  // Permissions
  String get location => _t('Location', 'இருப்பிடம்', 'स्थान');
  String get camera => _t('Camera', 'கேமரா', 'कैमरा');
  String get microphone => _t('Microphone', 'மைக்ரோஃபோன்', 'माइक्रोफ़ोन');
  String get photos => _t('Photos', 'புகைப்படங்கள்', 'फ़ोटो');
  String get notificationsPerm => _t('Notifications', 'அறிவிப்புகள்', 'सूचनाएँ');

  // Support screens
  String get howCanWeHelp => _t('How can we help?', 'எப்படி உதவலாம்?', 'हम कैसे मदद कर सकते हैं?');
  String get emailSupport => _t('Email Support', 'மின்னஞ்சல் ஆதரவு', 'ईमेल सहायता');
  String get callSupport => _t('Call Support', 'அழைப்பு ஆதரவு', 'कॉल सहायता');
  String get issueType => _t('Issue type', 'சிக்கல் வகை', 'समस्या का प्रकार');
  String get description => _t('Description', 'விளக்கம்', 'विवरण');
  String get submitReport => _t('Submit Report', 'அறிக்கையை சமர்ப்பி', 'रिपोर्ट जमा करें');
  String get submitting => _t('Submitting...', 'சமர்ப்பிக்கிறது...', 'जमा हो रहा है...');
  String get reportRecorded => _t('Thanks. Your issue has been recorded.', 'நன்றி. உங்கள் சிக்கல் பதிவு செய்யப்பட்டது.', 'धन्यवाद। आपकी समस्या दर्ज हो गई है।');
  String get addScreenshot => _t('Add screenshot or image', 'ஸ்கிரீன்ஷாட் அல்லது படத்தைச் சேர்', 'स्क्रीनशॉट या छवि जोड़ें');
  String get removeImage => _t('Remove image', 'படத்தை நீக்கு', 'छवि हटाएँ');
  String get couldNotOpenEmail => _t('Could not open email app.', 'மின்னஞ்சல் பயன்பாட்டைத் திறக்க முடியவில்லை.', 'ईमेल ऐप नहीं खोला जा सका।');
  String get couldNotOpenPhone => _t('Could not open phone dialer.', 'தொலைபேசி டயலரைத் திறக்க முடியவில்லை.', 'फ़ोन डायलर नहीं खोला जा सका।');
  String get termsAndConditions => _t('Terms & Conditions', 'விதிமுறைகள் & நிபந்தனைகள்', 'नियम और शर्तें');

  // 2FA
  String get twoFactorTitle => _t('Two-Factor Authentication', 'இரண்டு-காரணி அங்கீகாரம்', 'दो-कारक प्रमाणीकरण');
  String get twoFactorDesc => _t(
        'Add an extra security step when signing in. Create a 6-digit security code that you will enter after login.',
        'உள்நுழையும்போது கூடுதல் பாதுகாப்பு படியைச் சேர்க்கவும். உள்நுழைவுக்குப் பிறகு உள்ளிட வேண்டிய 6-இலக்க பாதுகாப்புக் குறியீட்டை உருவாக்கவும்.',
        'साइन इन करते समय एक अतिरिक्त सुरक्षा चरण जोड़ें। लॉगिन के बाद दर्ज करने के लिए 6-अंकीय सुरक्षा कोड बनाएँ।',
      );
  String get enable2fa => _t('Enable 2FA', '2FA ஐ இயக்கு', '2FA सक्षम करें');
  String get manage2fa => _t('Manage 2FA', '2FA ஐ நிர்வகி', '2FA प्रबंधित करें');
  String get createSecurityCode => _t('Create security code', 'பாதுகாப்புக் குறியீட்டை உருவாக்கு', 'सुरक्षा कोड बनाएँ');
  String get confirmSecurityCode => _t('Confirm security code', 'பாதுகாப்புக் குறியீட்டை உறுதிப்படுத்து', 'सुरक्षा कोड की पुष्टि करें');
  String get enterSecurityCode => _t('Enter your 6-digit security code', 'உங்கள் 6-இலக்க பாதுகாப்புக் குறியீட்டை உள்ளிடவும்', 'अपना 6-अंकीय सुरक्षा कोड दर्ज करें');
  String get codesDoNotMatch => _t('Codes do not match. Try again.', 'குறியீடுகள் பொருந்தவில்லை. மீண்டும் முயற்சிக்கவும்.', 'कोड मेल नहीं खाते। पुनः प्रयास करें।');
  String get twoFactorSetupSuccess => _t('Two-factor authentication enabled.', 'இரண்டு-காரணி அங்கீகாரம் இயக்கப்பட்டது.', 'दो-कारक प्रमाणीकरण सक्षम हो गया।');
  String get twoFactorDisabledMsg => _t('Two-factor authentication disabled.', 'இரண்டு-காரணி அங்கீகாரம் முடக்கப்பட்டது.', 'दो-कारक प्रमाणीकरण अक्षम हो गया।');
  String get verifyToContinue => _t('Verify to continue', 'தொடர உறுதிப்படுத்தவும்', 'जारी रखने के लिए सत्यापित करें');
  String get verify => _t('Verify', 'உறுதிப்படுத்து', 'सत्यापित करें');
  String get incorrectCode => _t('Incorrect code. Try again.', 'தவறான குறியீடு. மீண்டும் முயற்சிக்கவும்.', 'गलत कोड। पुनः प्रयास करें।');
  String get disable2fa => _t('Disable 2FA', '2FA ஐ முடக்கு', '2FA अक्षम करें');

  List<String> get issueTypes => [
        _t('Technical Problem', 'தொழில்நுட்ப சிக்கல்', 'तकनीकी समस्या'),
        _t('Duty Problem', 'பணி சிக்கல்', 'ड्यूटी समस्या'),
        _t('Chat Problem', 'அரட்டை சிக்கல்', 'चैट समस्या'),
        _t('Community Problem', 'சமூக சிக்கல்', 'समुदाय समस्या'),
        _t('Account Problem', 'கணக்கு சிக்கல்', 'खाता समस्या'),
        _t('Other', 'மற்றவை', 'अन्य'),
      ];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ta', 'hi', 'te', 'kn', 'ml'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
