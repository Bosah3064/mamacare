// ============================================
// MamaCare KE - Internationalization (i18n)
// ============================================
// Key-based translation system supporting
// English and Kiswahili, extensible to
// additional Kenyan languages.
// ============================================

import 'package:flutter/material.dart';

/// Supported application locales.
class AppLocales {
  AppLocales._();

  static const Locale english = Locale('en');
  static const Locale kiswahili = Locale('sw');

  static const List<Locale> supported = [english, kiswahili];

  static String languageName(Locale locale) {
    switch (locale.languageCode) {
      case 'sw':
        return 'Kiswahili';
      case 'en':
      default:
        return 'English';
    }
  }
}

/// Translation key accessor.
///
/// Usage:
/// ```dart
/// final t = AppLocalizations.of(context);
/// Text(t.homeGreeting);
/// ```
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get _lang => locale.languageCode;

  /// Look up a key, returning English as fallback.
  String _t(String key) {
    final langMap = _translations[_lang] ?? _translations['en']!;
    return langMap[key] ?? _translations['en']![key] ?? key;
  }

  // ══════════════════════════════════════════
  //  GENERAL
  // ══════════════════════════════════════════
  String get appName => _t('app.name');
  String get appTagline => _t('app.tagline');
  String get ok => _t('general.ok');
  String get cancel => _t('general.cancel');
  String get save => _t('general.save');
  String get delete => _t('general.delete');
  String get edit => _t('general.edit');
  String get done => _t('general.done');
  String get next => _t('general.next');
  String get back => _t('general.back');
  String get skip => _t('general.skip');
  String get close => _t('general.close');
  String get retry => _t('general.retry');
  String get loading => _t('general.loading');
  String get search => _t('general.search');
  String get noResults => _t('general.no_results');
  String get error => _t('general.error');
  String get success => _t('general.success');
  String get offline => _t('general.offline');
  String get syncing => _t('general.syncing');
  String get synced => _t('general.synced');
  String get syncFailed => _t('general.sync_failed');

  // ══════════════════════════════════════════
  //  ONBOARDING
  // ══════════════════════════════════════════
  String get onboardingWelcome => _t('onboarding.welcome');
  String get onboardingWelcomeSubtitle => _t('onboarding.welcome_subtitle');
  String get onboardingLanguage => _t('onboarding.language');
  String get onboardingLanguageSubtitle => _t('onboarding.language_subtitle');
  String get onboardingProfile => _t('onboarding.profile');
  String get onboardingProfileSubtitle => _t('onboarding.profile_subtitle');
  String get onboardingPregnancy => _t('onboarding.pregnancy');
  String get onboardingPregnancySubtitle => _t('onboarding.pregnancy_subtitle');
  String get onboardingConsent => _t('onboarding.consent');
  String get onboardingConsentSubtitle => _t('onboarding.consent_subtitle');
  String get onboardingComplete => _t('onboarding.complete');
  String get onboardingGetStarted => _t('onboarding.get_started');
  String get firstName => _t('onboarding.first_name');
  String get lastName => _t('onboarding.last_name');
  String get selectCounty => _t('onboarding.select_county');
  String get estimatedDueDate => _t('onboarding.estimated_due_date');
  String get lastMenstrualPeriod => _t('onboarding.last_menstrual_period');
  String get lastMenstrualPeriodHint => _t('onboarding.lmp_hint');
  String get firstPregnancy => _t('onboarding.first_pregnancy');
  String get previousPregnancies => _t('onboarding.previous_pregnancies');

  // ══════════════════════════════════════════
  //  AUTH
  // ══════════════════════════════════════════
  String get login => _t('auth.login');
  String get register => _t('auth.register');
  String get logout => _t('auth.logout');
  String get email => _t('auth.email');
  String get password => _t('auth.password');
  String get confirmPassword => _t('auth.confirm_password');
  String get forgotPassword => _t('auth.forgot_password');
  String get resetPassword => _t('auth.reset_password');
  String get createAccount => _t('auth.create_account');
  String get alreadyHaveAccount => _t('auth.already_have_account');
  String get dontHaveAccount => _t('auth.dont_have_account');

  // ══════════════════════════════════════════
  //  HOME
  // ══════════════════════════════════════════
  String homeGreeting(String name) {
    final greeting = _t('home.greeting');
    return greeting.replaceAll('{name}', name);
  }
  String get homeWeeksPregnant => _t('home.weeks_pregnant');
  String homeDaysRemaining(int days) {
    return _t('home.days_remaining').replaceAll('{days}', days.toString());
  }
  String get homeNextAnc => _t('home.next_anc');
  String get homeBabyThisWeek => _t('home.baby_this_week');
  String get homeHealthCheckIn => _t('home.health_check_in');
  String get homeAskMamaAi => _t('home.ask_mama_ai');
  String get homeEmergency => _t('home.emergency');

  // ══════════════════════════════════════════
  //  NAVIGATION
  // ══════════════════════════════════════════
  String get navHome => _t('nav.home');
  String get navMamaAi => _t('nav.mama_ai');
  String get navTracker => _t('nav.tracker');
  String get navAnc => _t('nav.anc');
  String get navProfile => _t('nav.profile');

  // ══════════════════════════════════════════
  //  MAMA AI
  // ══════════════════════════════════════════
  String get aiTitle => _t('ai.title');
  String get aiSubtitle => _t('ai.subtitle');
  String get aiDisclaimer => _t('ai.disclaimer');
  String get aiInputHint => _t('ai.input_hint');
  String get aiThinking => _t('ai.thinking');
  String get aiNewChat => _t('ai.new_chat');
  String get aiSafetyAlert => _t('ai.safety_alert');
  String get aiEmergencyAlert => _t('ai.emergency_alert');

  // ══════════════════════════════════════════
  //  HEALTH DIARY
  // ══════════════════════════════════════════
  String get healthDiary => _t('health.diary');
  String get healthRecordSymptom => _t('health.record_symptom');
  String get healthBloodPressure => _t('health.blood_pressure');
  String get healthWeight => _t('health.weight');
  String get healthTemperature => _t('health.temperature');
  String get healthMood => _t('health.mood');
  String get healthNotes => _t('health.notes');
  String get healthSystolic => _t('health.systolic');
  String get healthDiastolic => _t('health.diastolic');
  String get healthSeverity => _t('health.severity');
  String get healthMild => _t('health.mild');
  String get healthModerate => _t('health.moderate');
  String get healthSevere => _t('health.severe');

  // ══════════════════════════════════════════
  //  ANC
  // ══════════════════════════════════════════
  String get ancManager => _t('anc.manager');
  String get ancNewAppointment => _t('anc.new_appointment');
  String get ancUpcoming => _t('anc.upcoming');
  String get ancCompleted => _t('anc.completed');
  String get ancMissed => _t('anc.missed');
  String get ancReschedule => _t('anc.reschedule');
  String get ancReminder => _t('anc.reminder');
  String get ancSummary => _t('anc.summary');
  String get ancPreparation => _t('anc.preparation');

  // ══════════════════════════════════════════
  //  BABY TRACKER
  // ══════════════════════════════════════════
  String get trackerTitle => _t('tracker.title');
  String trackerWeek(int week) => _t('tracker.week').replaceAll('{week}', week.toString());
  String get trackerBabyDevelopment => _t('tracker.baby_development');
  String get trackerMaternalChanges => _t('tracker.maternal_changes');
  String get trackerTips => _t('tracker.tips');
  String get trackerTrimester => _t('tracker.trimester');

  // ══════════════════════════════════════════
  //  CARE NAVIGATOR
  // ══════════════════════════════════════════
  String get careNavigator => _t('care.navigator');
  String get careSearchFacility => _t('care.search_facility');
  String get careDirections => _t('care.directions');
  String get careEmergency => _t('care.emergency_available');
  String get careMaternity => _t('care.maternity_available');
  String get carePublic => _t('care.public');
  String get carePrivate => _t('care.private');

  // ══════════════════════════════════════════
  //  EMERGENCY
  // ══════════════════════════════════════════
  String get emergencyTitle => _t('emergency.title');
  String get emergencySeekHelp => _t('emergency.seek_help');
  String get emergencyCallFacility => _t('emergency.call_facility');
  String get emergencyCallContact => _t('emergency.call_contact');
  String get emergencyDirections => _t('emergency.directions');

  // ══════════════════════════════════════════
  //  SETTINGS
  // ══════════════════════════════════════════
  String get settings => _t('settings.title');
  String get settingsLanguage => _t('settings.language');
  String get settingsNotifications => _t('settings.notifications');
  String get settingsPrivacy => _t('settings.privacy');
  String get settingsAccount => _t('settings.account');
  String get settingsAbout => _t('settings.about');
  String get settingsDeleteAccount => _t('settings.delete_account');
  String get settingsExportData => _t('settings.export_data');
  String get settingsLowDataMode => _t('settings.low_data_mode');

  // ══════════════════════════════════════════
  //  FAMILY
  // ══════════════════════════════════════════
  String get familyMode => _t('family.mode');
  String get familyInvite => _t('family.invite');
  String get familyPermissions => _t('family.permissions');
  String get familyRevoke => _t('family.revoke');

  // ══════════════════════════════════════════
  //  CONSENT & PRIVACY
  // ══════════════════════════════════════════
  String get consentTitle => _t('consent.title');
  String get consentDataCollection => _t('consent.data_collection');
  String get consentAiInteraction => _t('consent.ai_interaction');
  String get consentPrivacyPolicy => _t('consent.privacy_policy');
  String get consentTerms => _t('consent.terms');
  String get consentAgree => _t('consent.agree');

  // ══════════════════════════════════════════
  //  DISCLAIMERS
  // ══════════════════════════════════════════
  String get disclaimerMedical => _t('disclaimer.medical');
  String get disclaimerAi => _t('disclaimer.ai');
  String get disclaimerEmergency => _t('disclaimer.emergency');

  // ══════════════════════════════════════════
  //  ERRORS
  // ══════════════════════════════════════════
  String get errorGeneric => _t('error.generic');
  String get errorNetwork => _t('error.network');
  String get errorSaveFailed => _t('error.save_failed');
  String get errorLoadFailed => _t('error.load_failed');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ═══════════════════════════════════════════════
//  TRANSLATION MAPS
// ═══════════════════════════════════════════════

const Map<String, Map<String, String>> _translations = {
  'en': _enTranslations,
  'sw': _swTranslations,
};

const Map<String, String> _enTranslations = {
  // General
  'app.name': 'MamaCare KE',
  'app.tagline': 'Your pregnancy companion, connected to care.',
  'general.ok': 'OK',
  'general.cancel': 'Cancel',
  'general.save': 'Save',
  'general.delete': 'Delete',
  'general.edit': 'Edit',
  'general.done': 'Done',
  'general.next': 'Next',
  'general.back': 'Back',
  'general.skip': 'Skip',
  'general.close': 'Close',
  'general.retry': 'Retry',
  'general.loading': 'Loading...',
  'general.search': 'Search',
  'general.no_results': 'No results found',
  'general.error': 'Something went wrong',
  'general.success': 'Success',
  'general.offline': 'You are offline',
  'general.syncing': 'Syncing...',
  'general.synced': 'All changes saved',
  'general.sync_failed': 'Sync failed. Will retry when connected.',

  // Onboarding
  'onboarding.welcome': 'Welcome to MamaCare',
  'onboarding.welcome_subtitle': 'Your pregnancy companion, connected to care.',
  'onboarding.language': 'Choose your language',
  'onboarding.language_subtitle': 'You can change this later in Settings.',
  'onboarding.profile': 'Tell us about yourself',
  'onboarding.profile_subtitle': 'This helps us personalize your experience.',
  'onboarding.pregnancy': 'Your pregnancy',
  'onboarding.pregnancy_subtitle': 'This information helps us provide relevant guidance for your stage of pregnancy.',
  'onboarding.consent': 'Your privacy matters',
  'onboarding.consent_subtitle': 'We protect your health information.',
  'onboarding.complete': 'You\'re all set!',
  'onboarding.get_started': 'Get Started',
  'onboarding.first_name': 'First name',
  'onboarding.last_name': 'Last name (optional)',
  'onboarding.select_county': 'Select your county',
  'onboarding.estimated_due_date': 'Estimated due date',
  'onboarding.last_menstrual_period': 'First day of your last period',
  'onboarding.lmp_hint': 'This helps us estimate your pregnancy week.',
  'onboarding.first_pregnancy': 'Is this your first pregnancy?',
  'onboarding.previous_pregnancies': 'Number of previous pregnancies',

  // Auth
  'auth.login': 'Log In',
  'auth.register': 'Create Account',
  'auth.logout': 'Log Out',
  'auth.email': 'Email address',
  'auth.password': 'Password',
  'auth.confirm_password': 'Confirm password',
  'auth.forgot_password': 'Forgot password?',
  'auth.reset_password': 'Reset Password',
  'auth.create_account': 'Create Account',
  'auth.already_have_account': 'Already have an account? Log in',
  'auth.dont_have_account': 'Don\'t have an account? Create one',

  // Home
  'home.greeting': 'Hello, {name} 👋',
  'home.weeks_pregnant': 'weeks pregnant',
  'home.days_remaining': '{days} days until your estimated due date',
  'home.next_anc': 'Next ANC Visit',
  'home.baby_this_week': 'Baby This Week',
  'home.health_check_in': 'Health Check-In',
  'home.ask_mama_ai': 'Ask Mama AI',
  'home.emergency': 'Emergency Help',

  // Navigation
  'nav.home': 'Home',
  'nav.mama_ai': 'Mama AI',
  'nav.tracker': 'Tracker',
  'nav.anc': 'ANC',
  'nav.profile': 'Profile',

  // Mama AI
  'ai.title': 'Mama AI',
  'ai.subtitle': 'Your maternal wellbeing assistant',
  'ai.disclaimer': 'Mama AI provides general pregnancy information. It is not a doctor or nurse and cannot diagnose medical conditions. Always consult your healthcare provider for medical advice.',
  'ai.input_hint': 'Ask Mama AI anything about your pregnancy...',
  'ai.thinking': 'Thinking...',
  'ai.new_chat': 'New Conversation',
  'ai.safety_alert': 'Based on what you\'ve shared, it may be important to speak with your healthcare provider.',
  'ai.emergency_alert': 'This may need urgent medical attention. Please contact your healthcare provider or go to the nearest facility immediately.',

  // Health Diary
  'health.diary': 'Health Diary',
  'health.record_symptom': 'Record Symptom',
  'health.blood_pressure': 'Blood Pressure',
  'health.weight': 'Weight',
  'health.temperature': 'Temperature',
  'health.mood': 'Mood',
  'health.notes': 'Notes',
  'health.systolic': 'Systolic (top number)',
  'health.diastolic': 'Diastolic (bottom number)',
  'health.severity': 'Severity',
  'health.mild': 'Mild',
  'health.moderate': 'Moderate',
  'health.severe': 'Severe',

  // ANC
  'anc.manager': 'ANC Appointments',
  'anc.new_appointment': 'New Appointment',
  'anc.upcoming': 'Upcoming',
  'anc.completed': 'Completed',
  'anc.missed': 'Missed',
  'anc.reschedule': 'Reschedule',
  'anc.reminder': 'Reminder',
  'anc.summary': 'ANC Summary',
  'anc.preparation': 'Prepare for your visit',

  // Baby Tracker
  'tracker.title': 'Baby Tracker',
  'tracker.week': 'Week {week}',
  'tracker.baby_development': 'Baby Development',
  'tracker.maternal_changes': 'Your Body',
  'tracker.tips': 'Tips for This Week',
  'tracker.trimester': 'Trimester',

  // Care Navigator
  'care.navigator': 'Find Healthcare',
  'care.search_facility': 'Search healthcare facilities...',
  'care.directions': 'Get Directions',
  'care.emergency_available': 'Emergency services available',
  'care.maternity_available': 'Maternity services available',
  'care.public': 'Public',
  'care.private': 'Private',

  // Emergency
  'emergency.title': 'Emergency Help',
  'emergency.seek_help': 'If you or your baby are in danger, seek emergency medical care now.',
  'emergency.call_facility': 'Call Healthcare Facility',
  'emergency.call_contact': 'Call Emergency Contact',
  'emergency.directions': 'Get Directions to Facility',

  // Settings
  'settings.title': 'Settings',
  'settings.language': 'Language',
  'settings.notifications': 'Notifications',
  'settings.privacy': 'Privacy & Data',
  'settings.account': 'Account',
  'settings.about': 'About MamaCare',
  'settings.delete_account': 'Delete Account',
  'settings.export_data': 'Export My Data',
  'settings.low_data_mode': 'Low Data Mode',

  // Family
  'family.mode': 'Family Sharing',
  'family.invite': 'Invite Trusted Person',
  'family.permissions': 'Manage Permissions',
  'family.revoke': 'Revoke Access',

  // Consent
  'consent.title': 'Privacy & Consent',
  'consent.data_collection': 'Data Collection',
  'consent.ai_interaction': 'AI Interaction',
  'consent.privacy_policy': 'Privacy Policy',
  'consent.terms': 'Terms of Service',
  'consent.agree': 'I Agree',

  // Disclaimers
  'disclaimer.medical': 'MamaCare KE is not a replacement for professional medical care. Always consult your healthcare provider for medical advice, diagnosis, or treatment.',
  'disclaimer.ai': 'Mama AI provides general pregnancy information and guidance. It is not a doctor, nurse, or midwife. It cannot diagnose medical conditions or prescribe treatment.',
  'disclaimer.emergency': 'In a medical emergency, call your healthcare provider, go to the nearest hospital, or call emergency services immediately. Do not rely solely on this application in emergencies.',

  // Errors
  'error.generic': 'Something went wrong. Please try again.',
  'error.network': 'Please check your internet connection and try again.',
  'error.save_failed': 'We couldn\'t save your information. Please try again.',
  'error.load_failed': 'We couldn\'t load this information. Please try again.',
};

const Map<String, String> _swTranslations = {
  // General
  'app.name': 'MamaCare KE',
  'app.tagline': 'Mwenza wako wa ujauzito, umeunganishwa na huduma.',
  'general.ok': 'Sawa',
  'general.cancel': 'Ghairi',
  'general.save': 'Hifadhi',
  'general.delete': 'Futa',
  'general.edit': 'Hariri',
  'general.done': 'Imekamilika',
  'general.next': 'Endelea',
  'general.back': 'Rudi',
  'general.skip': 'Ruka',
  'general.close': 'Funga',
  'general.retry': 'Jaribu tena',
  'general.loading': 'Inapakia...',
  'general.search': 'Tafuta',
  'general.no_results': 'Hakuna matokeo',
  'general.error': 'Kuna tatizo limetokea',
  'general.success': 'Imefanikiwa',
  'general.offline': 'Huna mtandao',
  'general.syncing': 'Inasawazisha...',
  'general.synced': 'Mabadiliko yote yamehifadhiwa',
  'general.sync_failed': 'Kusawazisha kumeshindikana. Itajaribu tena.',

  // Onboarding
  'onboarding.welcome': 'Karibu MamaCare',
  'onboarding.welcome_subtitle': 'Mwenza wako wa ujauzito, umeunganishwa na huduma.',
  'onboarding.language': 'Chagua lugha yako',
  'onboarding.language_subtitle': 'Unaweza kubadilisha baadaye katika Mipangilio.',
  'onboarding.profile': 'Tuambie kuhusu wewe',
  'onboarding.profile_subtitle': 'Hii inatusaidia kukupa uzoefu bora.',
  'onboarding.pregnancy': 'Ujauzito wako',
  'onboarding.pregnancy_subtitle': 'Taarifa hii inatusaidia kutoa mwongozo unaofaa kwa hatua yako ya ujauzito.',
  'onboarding.consent': 'Faragha yako ni muhimu',
  'onboarding.consent_subtitle': 'Tunalinda taarifa zako za afya.',
  'onboarding.complete': 'Uko tayari!',
  'onboarding.get_started': 'Anza',
  'onboarding.first_name': 'Jina la kwanza',
  'onboarding.last_name': 'Jina la mwisho (si lazima)',
  'onboarding.select_county': 'Chagua kaunti yako',
  'onboarding.estimated_due_date': 'Tarehe ya kuzaliwa inayokadiriwa',
  'onboarding.last_menstrual_period': 'Siku ya kwanza ya hedhi yako ya mwisho',
  'onboarding.lmp_hint': 'Hii inatusaidia kukadiriri wiki yako ya ujauzito.',
  'onboarding.first_pregnancy': 'Huu ni ujauzito wako wa kwanza?',
  'onboarding.previous_pregnancies': 'Idadi ya mimba zilizopita',

  // Auth
  'auth.login': 'Ingia',
  'auth.register': 'Fungua Akaunti',
  'auth.logout': 'Toka',
  'auth.email': 'Barua pepe',
  'auth.password': 'Nenosiri',
  'auth.confirm_password': 'Thibitisha nenosiri',
  'auth.forgot_password': 'Umesahau nenosiri?',
  'auth.reset_password': 'Weka Nenosiri Upya',
  'auth.create_account': 'Fungua Akaunti',
  'auth.already_have_account': 'Una akaunti tayari? Ingia',
  'auth.dont_have_account': 'Huna akaunti? Fungua moja',

  // Home
  'home.greeting': 'Habari, {name} 👋',
  'home.weeks_pregnant': 'wiki za ujauzito',
  'home.days_remaining': 'Siku {days} hadi tarehe yako ya kuzaliwa inayokadiriwa',
  'home.next_anc': 'Mahudhurio ya ANC Yajayo',
  'home.baby_this_week': 'Mtoto Wiki Hii',
  'home.health_check_in': 'Angalia Afya',
  'home.ask_mama_ai': 'Uliza Mama AI',
  'home.emergency': 'Msaada wa Dharura',

  // Navigation
  'nav.home': 'Nyumbani',
  'nav.mama_ai': 'Mama AI',
  'nav.tracker': 'Fuatilia',
  'nav.anc': 'ANC',
  'nav.profile': 'Wasifu',

  // Mama AI
  'ai.title': 'Mama AI',
  'ai.subtitle': 'Msaidizi wako wa ustawi wa uzazi',
  'ai.disclaimer': 'Mama AI hutoa taarifa za jumla za ujauzito. Si daktari au muuguzi na haiwezi kutambua hali za kiafya. Daima wasiliana na mtoa huduma wako wa afya kwa ushauri wa kimatibabu.',
  'ai.input_hint': 'Uliza Mama AI chochote kuhusu ujauzito wako...',
  'ai.thinking': 'Inafikiri...',
  'ai.new_chat': 'Mazungumzo Mapya',
  'ai.safety_alert': 'Kulingana na ulichoshiriki, inaweza kuwa muhimu kuzungumza na mtoa huduma wako wa afya.',
  'ai.emergency_alert': 'Hii inaweza kuhitaji msaada wa haraka wa kimatibabu. Tafadhali wasiliana na mtoa huduma wako wa afya au nenda kituo cha karibu mara moja.',

  // Health Diary
  'health.diary': 'Diari ya Afya',
  'health.record_symptom': 'Rekodi Dalili',
  'health.blood_pressure': 'Shinikizo la Damu',
  'health.weight': 'Uzito',
  'health.temperature': 'Joto',
  'health.mood': 'Hali ya Moyo',
  'health.notes': 'Maelezo',
  'health.systolic': 'Sistoliki (nambari ya juu)',
  'health.diastolic': 'Diastoliki (nambari ya chini)',
  'health.severity': 'Ukali',
  'health.mild': 'Kidogo',
  'health.moderate': 'Wastani',
  'health.severe': 'Kali',

  // ANC
  'anc.manager': 'Miadi ya ANC',
  'anc.new_appointment': 'Miadi Mpya',
  'anc.upcoming': 'Inayokuja',
  'anc.completed': 'Imekamilika',
  'anc.missed': 'Imekosekana',
  'anc.reschedule': 'Panga Upya',
  'anc.reminder': 'Kumbusho',
  'anc.summary': 'Muhtasari wa ANC',
  'anc.preparation': 'Jiandae kwa ziara yako',

  // Baby Tracker
  'tracker.title': 'Fuatilia Mtoto',
  'tracker.week': 'Wiki ya {week}',
  'tracker.baby_development': 'Maendeleo ya Mtoto',
  'tracker.maternal_changes': 'Mwili Wako',
  'tracker.tips': 'Vidokezo vya Wiki Hii',
  'tracker.trimester': 'Miezi Mitatu',

  // Care Navigator
  'care.navigator': 'Tafuta Huduma za Afya',
  'care.search_facility': 'Tafuta vituo vya afya...',
  'care.directions': 'Pata Maelekezo',
  'care.emergency_available': 'Huduma za dharura zinapatikana',
  'care.maternity_available': 'Huduma za uzazi zinapatikana',
  'care.public': 'Ya Umma',
  'care.private': 'Ya Kibinafsi',

  // Emergency
  'emergency.title': 'Msaada wa Dharura',
  'emergency.seek_help': 'Ikiwa wewe au mtoto wako mko hatarini, tafuta huduma ya dharura ya kimatibabu sasa.',
  'emergency.call_facility': 'Piga Simu Kituo cha Afya',
  'emergency.call_contact': 'Piga Simu Anayewasiliana Naye Dharura',
  'emergency.directions': 'Pata Maelekezo kwa Kituo',

  // Settings
  'settings.title': 'Mipangilio',
  'settings.language': 'Lugha',
  'settings.notifications': 'Arifa',
  'settings.privacy': 'Faragha na Data',
  'settings.account': 'Akaunti',
  'settings.about': 'Kuhusu MamaCare',
  'settings.delete_account': 'Futa Akaunti',
  'settings.export_data': 'Hamisha Data Yangu',
  'settings.low_data_mode': 'Hali ya Data Ndogo',

  // Family
  'family.mode': 'Kushiriki na Familia',
  'family.invite': 'Alika Mtu Unayemwamini',
  'family.permissions': 'Simamia Ruhusa',
  'family.revoke': 'Ondoa Ufikiaji',

  // Consent
  'consent.title': 'Faragha na Idhini',
  'consent.data_collection': 'Ukusanyaji wa Data',
  'consent.ai_interaction': 'Mwingiliano wa AI',
  'consent.privacy_policy': 'Sera ya Faragha',
  'consent.terms': 'Masharti ya Huduma',
  'consent.agree': 'Nakubali',

  // Disclaimers
  'disclaimer.medical': 'MamaCare KE si mbadala wa huduma ya kitaalamu ya kimatibabu. Daima wasiliana na mtoa huduma wako wa afya kwa ushauri wa kimatibabu, utambuzi, au matibabu.',
  'disclaimer.ai': 'Mama AI hutoa taarifa za jumla za ujauzito na mwongozo. Si daktari, muuguzi, au mkunga. Haiwezi kutambua hali za kimatibabu au kuandika matibabu.',
  'disclaimer.emergency': 'Katika dharura ya kimatibabu, piga simu mtoa huduma wako wa afya, nenda hospitali ya karibu, au piga simu huduma za dharura mara moja. Usitegemee programu hii pekee katika dharura.',

  // Errors
  'error.generic': 'Kuna tatizo limetokea. Tafadhali jaribu tena.',
  'error.network': 'Tafadhali angalia muunganisho wako wa intaneti na ujaribu tena.',
  'error.save_failed': 'Hatukuweza kuhifadhi taarifa yako. Tafadhali jaribu tena.',
  'error.load_failed': 'Hatukuweza kupakia taarifa hii. Tafadhali jaribu tena.',
};
