// ============================================
// MamaCare KE - Mama AI Obstetric Safety Engine
// ============================================
// Deterministic clinical safety layer adhering
// to Kenya Ministry of Health (MoH) Guidelines
// for Maternal & Neonatal Health.
//
// CRITICAL ARCHITECTURAL PRINCIPLE:
// Never rely solely on an LLM for safety-critical
// maternal triage. All user messages and reported
// symptoms are parsed through this deterministic
// engine BEFORE and AFTER LLM processing.
//
// CORE BACKBONE DANGER SIGNS (Kenya MoH Red Flags):
// 1. Vaginal Bleeding (Kutokwa na Damu)
// 2. Severe Headache + Blurred Vision / Pre-eclampsia
//    (Kuumwa na Kichwa na Kiza Machoni)
// 3. Reduced or Absent Fetal Movements (Mtoto Kutocheza)
// 4. Rupture of Membranes (Maji ya Uzazi Kuvuja)
// ============================================

/// Clinical severity level according to Kenya MoH maternal triage protocols
enum TriageLevel {
  emergency, // Immediate hospital transfer / Call 1199 Red Cross / Level 4-6 facility
  urgent, // Visit healthcare clinic within 24 hours
  warning, // Monitor closely; consult healthcare provider if symptoms persist
  routine, // Safe for educational maternal guidance; regular ANC adherence
}

/// Danger sign classification with deterministic regex rules and Kenya MoH clinical actions
class DangerSignRule {
  final String id;
  final String titleEn;
  final String titleSw;
  final String descriptionEn;
  final String descriptionSw;
  final TriageLevel level;
  final List<String> keywordsEn;
  final List<String> keywordsSw;
  final List<RegExp> regexPatterns;
  final String immediateActionEn;
  final String immediateActionSw;
  final List<String> immediateStepsEn;
  final List<String> immediateStepsSw;
  final String clinicalRationaleEn;
  final String clinicalRationaleSw;
  final bool requiresEmergencyHotline;

  const DangerSignRule({
    required this.id,
    required this.titleEn,
    required this.titleSw,
    required this.descriptionEn,
    required this.descriptionSw,
    required this.level,
    required this.keywordsEn,
    required this.keywordsSw,
    this.regexPatterns = const [],
    required this.immediateActionEn,
    required this.immediateActionSw,
    this.immediateStepsEn = const [],
    this.immediateStepsSw = const [],
    this.clinicalRationaleEn = '',
    this.clinicalRationaleSw = '',
    this.requiresEmergencyHotline = false,
  });

  bool get isEmergency => level == TriageLevel.emergency;
  bool get isUrgent => level == TriageLevel.urgent;
}

/// Result of deterministic safety analysis
class SafetyAssessment {
  final TriageLevel triageLevel;
  final List<DangerSignRule> triggeredRules;
  final String recommendedActionEn;
  final String recommendedActionSw;
  final bool isSafeForAiResponse;
  final bool requiresImmediateCall;
  final String? overrideEmergencyMessageEn;
  final String? overrideEmergencyMessageSw;

  const SafetyAssessment({
    required this.triageLevel,
    required this.triggeredRules,
    required this.recommendedActionEn,
    required this.recommendedActionSw,
    required this.isSafeForAiResponse,
    required this.requiresImmediateCall,
    this.overrideEmergencyMessageEn,
    this.overrideEmergencyMessageSw,
  });

  bool get isEmergency => triageLevel == TriageLevel.emergency;
  bool get isUrgent => triageLevel == TriageLevel.urgent;
  bool get hasDangerSigns => triggeredRules.isNotEmpty;

  DangerSignRule? get primaryDangerSign =>
      triggeredRules.isNotEmpty ? triggeredRules.first : null;

  bool get isBleeding => triggeredRules.any((r) => r.id == 'vaginal_bleeding');
  bool get isPreeclampsia =>
      triggeredRules.any((r) => r.id == 'severe_headache_visual');
  bool get isReducedMovement =>
      triggeredRules.any((r) => r.id == 'reduced_fetal_movement');
  bool get isMembraneRupture =>
      triggeredRules.any((r) => r.id == 'water_leaking');
}

/// Deterministic clinical obstetric safety engine
class AiSafetyEngine {
  AiSafetyEngine._();
  static final AiSafetyEngine instance = AiSafetyEngine._();

  /// Kenya Ministry of Health defined Obstetric Danger Signs
  static final List<DangerSignRule> _dangerSigns = [
    // ----------------------------------------------------
    // 1. VAGINAL BLEEDING (Kutokwa na Damu Ukeni)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'vaginal_bleeding',
      titleEn: 'Vaginal Bleeding',
      titleSw: 'Kutokwa na Damu Ukeni',
      descriptionEn:
          'Any vaginal bleeding during pregnancy is abnormal. It poses high risk of antepartum hemorrhage, placenta previa, placental abruption, or miscarriage.',
      descriptionSw:
          'Kutokwa na damu ukeni wakati wa ujauzito si kawaida. Huashiria hatari ya placenta previa, kondo kubanduka, au hatari ya kuharibika kwa mimba.',
      level: TriageLevel.emergency,
      keywordsEn: const [
        'bleeding',
        'blood',
        'spotting',
        'hemorrhage',
        'clots',
        'bloody',
        'discharge with blood',
        'heavy bleeding',
        'red discharge',
        'losing blood',
        'soaked pad',
      ],
      keywordsSw: const [
        'damu',
        'kutokwa na damu',
        'kuvuja damu',
        'matone ya damu',
        'uchafu wenye damu',
        'damu ukeni',
        'damu nyingi',
        'mabonge ya damu',
        'pande la damu',
        'damu inatoka',
        'damu inavuja',
      ],
      regexPatterns: [
        // English: Bleeding / blood variations
        RegExp(r'\b(bleed(ing)?|bloody|spotting|hemorrhag(e|ic))\b',
            caseSensitive: false),
        RegExp(
            r'\b(blood|clots?)\b.*\b(vagina|underwear|pad|discharge|pant|wip(e|ing)|toilet|soaked)\b',
            caseSensitive: false),
        RegExp(
            r'\b(vagina|discharge|pad|underwear)\b.*\b(blood|bleeding|spotting|clots?)\b',
            caseSensitive: false),
        RegExp(r'\b(losing|lost|passing)\s+(blood|clots?)\b',
            caseSensitive: false),
        RegExp(r'\bheavy\s+bleeding\b', caseSensitive: false),

        // Kiswahili: Kutokwa/kuvuja damu
        RegExp(
            r'\b(kutokwa|kutoka|kuvuja|kuvujisha|nimetoa|nimeona|ninaona|inatoka|inavuja|kumwaga|inamwagika|matone\s+ya|mabonge\s+ya|uchafu\s+wenye)\s+(na\s+)?damu\b',
            caseSensitive: false),
        RegExp(
            r'\bdamu\b.*\b(ina(toka|vuja|mwagika)|ime(toka|vuja)|nyingi|ukeni|nzito|nyeusi|nyekundu|mabonge|matone)\b',
            caseSensitive: false),
        RegExp(r'\b(kuvuja|ninavuja|anaye\s+vuja|anavuja)\s+damu\b',
            caseSensitive: false),
        RegExp(
            r'\bdamu\b.*\b(uke(ni)?|nguo\s+ya\s+ndani|chupi|kitambaa|pedi)\b',
            caseSensitive: false),
        RegExp(r'\b(kutokwa|kuvuja)\s+na\s+damu\b', caseSensitive: false),
      ],
      immediateActionEn:
          'Go to the nearest emergency maternity unit or call 1199 immediately. Do not insert anything into the vagina.',
      immediateActionSw:
          'Nenda kituo cha afya kilicho karibu au piga simu 1199 mara moja. Usiweke kitu chochote ukeni.',
      immediateStepsEn: const [
        'Lie down immediately on your left side to maintain uterine blood flow.',
        'Do not insert tampons, fingers, or medications into the vagina.',
        'Wear a clean pad to monitor the amount and color of blood for the midwife.',
        'Call Kenya Red Cross toll-free at 1199 or arrange transport to a Level 4+ hospital.',
        'Take your Kenya MoH Mother and Child Health (MCH) clinic booklet with you.',
      ],
      immediateStepsSw: const [
        'Lala chini upande wako wa kushoto ili kuruhusu mtiririko mzuri wa damu kwa mtoto.',
        'Usiweke kitambaa cha ndani (tampon), vidole, au dawa yoyote ndani ya uke.',
        'Vaa pedi safi ili uweze kumwonyesha muuguzi au daktari wingi na rangi ya damu.',
        'Piga simu Msalaba Mwekundu 1199 (bila malipo) au nenda Hospitali ya Rufaa Level 4+.',
        'Beba kadi yako ya kliniki ya mama na mtoto (Mother-Child Health booklet).',
      ],
      clinicalRationaleEn:
          'Vaginal bleeding at any gestational age indicates potential placental separation, cervical changes, or ectopic/miscarriage complications.',
      clinicalRationaleSw:
          'Damu ukeni wakati wa ujauzito inaweza kumaanisha kondo la nyuma kubanduka au hatari kubwa kwa mama na mtoto.',
      requiresEmergencyHotline: true,
    ),

    // ----------------------------------------------------
    // 2. SEVERE HEADACHE + BLURRED VISION (Pre-eclampsia)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'severe_headache_visual',
      titleEn: 'Severe Headache or Blurred Vision (Pre-eclampsia)',
      titleSw: 'Kuumwa Kichwa Sana na Kiza Machoni (Shinikizo la Damu)',
      descriptionEn:
          'Persistent severe headache, flashing lights, dark spots, or blurred vision are hallmarks of severe pre-eclampsia or impending eclamptic seizures.',
      descriptionSw:
          'Kuumwa kichwa sana kunakoendelea, kuona giza, mianga, au kutoona vizuri ni ishara ya shinikizo la juu la damu (pre-eclampsia) na kifafa cha mimba.',
      level: TriageLevel.emergency,
      keywordsEn: const [
        'severe headache',
        'blurry vision',
        'blurred vision',
        'flashing lights',
        'seeing spots',
        'terrible headache',
        'head pounding',
        'cannot see clearly',
        'vision changes',
        'preeclampsia',
        'pre-eclampsia',
        'eclampsia',
        'dark spots in vision',
        'blind spots',
        'aura',
      ],
      keywordsSw: const [
        'kichwa kinauma sana',
        'kichwa kuuma vikali',
        'kuumwa na kichwa na kiza machoni',
        'kiza machoni',
        'giza machoni',
        'kutoona vizuri',
        'kuona giza',
        'kuona mianga',
        'macho kutoona',
        'kuona ukungu',
        'shinikizo la damu',
        'presha ya kupanda',
      ],
      regexPatterns: [
        // English: severe headache / vision disturbances
        RegExp(
            r'\b(severe|terrible|splitting|unbearable|pounding|worst)\s+headache\b',
            caseSensitive: false),
        RegExp(
            r'\bheadache\b.*\b(vision|blurr(y|ed)|spots|flashing|cannot\s+see|dizzy|blood\s+pressure|bp)\b',
            caseSensitive: false),
        RegExp(
            r'\b(blurr(y|ed)\s+vision|seeing\s+spots|flashing\s+lights|loss\s+of\s+vision|cannot\s+see\s+clearly|darkness\s+in\s+eyes)\b',
            caseSensitive: false),
        RegExp(r'\b(preeclampsia|pre-eclampsia|eclampsia)\b',
            caseSensitive: false),

        // Kiswahili: Kichwa kinauma sana / kiza machoni
        RegExp(
            r'\bkichwa\b.*\b(kuuma\s+sana|kinauma\s+sana|inauma\s+sana|kuuma\s+vikali|kinapasuka|kigumu)\b',
            caseSensitive: false),
        RegExp(
            r'\b(kichwa\b.*\b(kuuma|kinauma))\b.*\b(kiza|giza|macho|kutoona|presha|shinikizo)\b',
            caseSensitive: false),
        RegExp(
            r'\b(kiza|giza|mianga|ukungu)\s+(machoni|mbele\s+ya\s+macho)\b',
            caseSensitive: false),
        RegExp(
            r'\b(macho\b.*\b(kutoona\s+vizuri|kuona\s+giza|kuona\s+kiza|kuona\s+mianga|kuona\s+ukungu))\b',
            caseSensitive: false),
        RegExp(
            r'\b(presha\s+ya\s+kupanda|shinikizo\s+la\s+damu)\b.*\b(kichwa|kiza|macho)\b',
            caseSensitive: false),
        RegExp(r'\bkuumwa\s+(na\s+)?kichwa\s+na\s+kiza\s+machoni\b',
            caseSensitive: false),
      ],
      immediateActionEn:
          'Seek immediate medical care at a hospital to check blood pressure and urine protein.',
      immediateActionSw:
          'Pata matibabu ya dharura hospitalini mara moja ili kupima shinikizo la damu na protini kwenye mkojo.',
      immediateStepsEn: const [
        'Have someone escort you to the nearest hospital emergency room immediately.',
        'Do not take ordinary over-the-counter painkillers without medical supervision.',
        'Rest in a quiet, dimly lit room while awaiting emergency transport.',
        'Be prepared for urgent blood pressure measurement and magnesium sulfate treatment if indicated.',
      ],
      immediateStepsSw: const [
        'Omba mtu akusindikize hospitali kwenye kitengo cha dharura mara moja.',
        'Usinywe dawa za maumivu za dukani bila maagizo ya mhudumu wa afya.',
        'Pumzika mahali tulivu penye mwanga hafifu unaposubiri usafiri wa hospitali.',
        'Jitayarishe kupimwa shinikizo la damu na kupewa matibabu sahihi ya kuzuia degedege.',
      ],
      clinicalRationaleEn:
          'Cerebral edema and severe vasospasm can rapidly escalate into eclamptic convulsions and maternal stroke.',
      clinicalRationaleSw:
          'Kuvimba kwa ubongo na shinikizo kubwa la damu kunaweza kusababisha kifafa cha mimba na kupoteza fahamu.',
      requiresEmergencyHotline: true,
    ),

    // ----------------------------------------------------
    // 3. REDUCED OR ABSENT FETAL MOVEMENTS (Mtoto Kutocheza)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'reduced_fetal_movement',
      titleEn: 'Reduced or Absent Fetal Movements',
      titleSw: 'Mtoto Kutocheza au Kupunguza Mwendo Tumboni',
      descriptionEn:
          'A marked decrease or total cessation of baby kicks/movements after 24-28 weeks signals potential fetal distress or placental insufficiency.',
      descriptionSw:
          'Kupungua au kuacha kabisa kwa mateke au mienendo ya mtoto baada ya wiki 24-28 ni ishara ya hatari ya mtoto kukosa hewa safi au chakula tumboni.',
      level: TriageLevel.emergency,
      keywordsEn: const [
        'baby not moving',
        'no kicks',
        'reduced movement',
        'less movement',
        'baby stopped moving',
        'has not kicked',
        'stopped kicking',
        'no movement today',
        'haven\'t felt baby',
        'decreased fetal movement',
        'absent fetal movements',
        'baby quiet',
      ],
      keywordsSw: const [
        'mtoto kutocheza',
        'mtoto hachezi',
        'mtoto hajacheza',
        'mateke yamepungua',
        'hakuna mateke',
        'mtoto ametulia',
        'hachezi leo',
        'mtoto hajasonga',
        'sihisi mateke',
        'sijasikia mtoto akicheza',
        'mateke yameisha',
        'mtoto hasongei',
      ],
      regexPatterns: [
        // English: baby stopped moving / no kicks
        RegExp(
            r"\b(baby|fetus|fetal)\b.*\b(not\s+mov(ing|ed)|stopped\s+mov(ing|ed)|no\s+movement|less\s+movement|decreased\s+movement|reduced\s+movement|hasn'?t\s+kicked?|stopped\s+kicking|isn'?t\s+moving|not\s+kicking)\b",
            caseSensitive: false),
        RegExp(
            r"\b(no|zero|haven'?t\s+felt|stopped)\s+(kicks?|movement|flutter(s)?)\b",
            caseSensitive: false),
        RegExp(r'\b(fewer|less|reduced)\s+kicks\b', caseSensitive: false),
        RegExp(r'\bbaby\s+has\s+not\s+moved\b', caseSensitive: false),

        // Kiswahili: mtoto hachezi / mateke yamepungua
        RegExp(
            r'\bmtoto\b.*\b(hachezi|hajacheza|hasongi|hajasonga|hatikisiki|ametulia\s+sana|hachezi\s+leo|hasongei)\b',
            caseSensitive: false),
        RegExp(
            r'\b(mateke|mwendo\s+wa\s+mtoto)\b.*\b(yamepungua|yameisha|hakuna|yamepotea|sijasikia|sihisi)\b',
            caseSensitive: false),
        RegExp(
            r'\b(sijasikia|sihisi|sijaona)\b.*\b(mtoto\b.*\b(akicheza|kusonga|akitingizika)|mateke)\b',
            caseSensitive: false),
        RegExp(r'\bmtoto\s+(kutocheza|kuacha\s+kucheza|hatikisiki)\b',
            caseSensitive: false),
        RegExp(r'\bhachezi\s+leo\b', caseSensitive: false),
      ],
      immediateActionEn:
          'Eat a light snack, lie on your left side for 2 hours and count kicks. If fewer than 10 movements or none, go to a maternity unit immediately.',
      immediateActionSw:
          'Kula chakula chepesi, lala upande wa kushoto kwa saa 2 na uhesabu mienendo. Isipofika 10 au asipocheza, nenda hospitali mara moja.',
      immediateStepsEn: const [
        'Drink a glass of cold water or have a nutritious snack.',
        'Lie quietly on your left side in a calm environment for up to 2 hours.',
        'Place your hands on your bump and count distinct kicks, swishes, or rolls.',
        'If fewer than 10 movements occur in 2 hours, go to the maternity triage immediately for CTG / Doppler fetal heart auscultation.',
      ],
      immediateStepsSw: const [
        'Kunywa glasi ya maji baridi au kula vitafunio vyenye lishe.',
        'Lala kwa utulivu upande wako wa kushoto kwa muda wa saa 2.',
        'Weka mikono yako tumboni na uhesabu mateke au mienendo ya mtoto.',
        'Iwapo haifiki mateke 10 ndani ya masaa 2 au hachezi kabisa, nenda kituo cha afya mara moja kwa kipimo cha sauti ya moyo wa mtoto (Doppler/CTG).',
      ],
      clinicalRationaleEn:
          'Fetal quiescence may indicate acute fetal hypoxia, oligohydramnios, or cord compression requiring urgent assessment.',
      clinicalRationaleSw:
          'Mtoto kutulia sana huweza kuashiria upungufu wa hewa au matatizo ya kitovu yanayohitaji uchunguzi wa dharura.',
      requiresEmergencyHotline: true,
    ),

    // ----------------------------------------------------
    // 4. RUPTURE OF MEMBRANES (Maji ya Uzazi Kuvuja)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'water_leaking',
      titleEn: 'Rupture of Membranes / Leaking Amniotic Fluid',
      titleSw: 'Maji ya Uzazi Kuvuja / Chupa ya Uzazi Kupasuka',
      descriptionEn:
          'Sudden gush or continuous trickle of watery fluid from the vagina indicates rupture of membranes. Risks include umbilical cord prolapse, preterm labor, and intrauterine infection.',
      descriptionSw:
          'Maji mengi au matone yanayoendelea kutoka ukeni huashiria chupa ya uzazi kupasuka. Hatari ni kitovu kushuka, uchungu kabla ya wakati, na maambukizi.',
      level: TriageLevel.emergency,
      keywordsEn: const [
        'water broke',
        'waters broke',
        'leaking fluid',
        'amniotic fluid',
        'gush of water',
        'water leaking',
        'greenish fluid',
        'trickle of liquid',
        'bag of waters broke',
        'fluid leaking from vagina',
        'rupture of membranes',
        'clear watery discharge',
      ],
      keywordsSw: const [
        'maji ya uzazi kuvuja',
        'chupa imepasuka',
        'chupa imevunjika',
        'chupa kupasuka',
        'maji ya uzazi',
        'kutoka maji',
        'kuvuja maji',
        'maji yanatoka',
        'maji yanavuja',
        'maji ya mtoto',
        'maji ya uzazi yanatoka',
        'maji mengi yanatoka ukeni',
      ],
      regexPatterns: [
        // English: water broke / amniotic fluid
        RegExp(r'\bwater(s)?\s+(has\s+)?(broke|broken|breaking)\b',
            caseSensitive: false),
        RegExp(r'\b(amniotic\s+fluid|rupture\s+of\s+membranes?|prom)\b',
            caseSensitive: false),
        RegExp(
            r'\b(leak(ing)?|trickl(ing|e)|gush(ing)?)\b.*\b(fluid|water|liquid|amniotic)\b',
            caseSensitive: false),
        RegExp(
            r'\b(fluid|water)\b.*\b(leak(ing)?|trickl(ing|e)|gush(ing)?|pour(ing)?)\b',
            caseSensitive: false),
        RegExp(
            r'\b(water|fluid)\s+(is\s+)?(running|coming\s+out)\s+(from|down)\s+(vagina|legs|under)\b',
            caseSensitive: false),

        // Kiswahili: chupa imepasuka / maji ya uzazi yanatoka
        RegExp(
            r'\bchupa\b.*\b(imepasuka|imevunjika|kupasuk(a)?|kuvunjik(a)?|imepasukia)\b',
            caseSensitive: false),
        RegExp(r'\bmaji\s+ya\s+(uzazi|mtoto)\b', caseSensitive: false),
        RegExp(
            r'\bmaji\b.*\b(yana(toka|vuja|mwagika)|yame(toka|vuja|mwagika)|kuvuja|kutoka|kumwagika)\b.*\b(ukeni|chupi|nguo)?\b',
            caseSensitive: false),
        RegExp(r'\b(kuvuja|kutoka)\s+(kwa\s+)?maji\s+ya\s+uzazi\b',
            caseSensitive: false),
        RegExp(r'\bchupa\s+ya\s+uzazi\b', caseSensitive: false),
      ],
      immediateActionEn:
          'Go immediately to the maternity department. Note color and time fluid started leaking. Do not take baths or use tampons.',
      immediateActionSw:
          'Nenda haraka kwenye idara ya uzazi hospitalini. Zingatia rangi na muda maji yalianza kutoka. Usiingize kitu ukeni.',
      immediateStepsEn: const [
        'Put on a clean maternity sanitary pad to observe fluid color (clear, pink, greenish, or cloudy).',
        'Note the exact time leaking began to report to your midwife or doctor.',
        'Do not have sexual intercourse, insert tampons, or take bath soaks.',
        'Proceed immediately to the hospital maternity wing regardless of whether you have contractions.',
      ],
      immediateStepsSw: const [
        'Vaa pedi safi ili uone rangi ya maji (maji safi, mekundu, ya kijani, au machafu).',
        'Zingatia saa kamili maji yalianza kutoka ili kumwambia muuguzi au daktari.',
        'Usifanye tendo la ndoa, usiweke kitambaa ndani ya uke, wala kuoga kwenye birika.',
        'Fika hospitali kwenye kitengo cha uzazi mara moja, hata kama bado hujapata uchungu.',
      ],
      clinicalRationaleEn:
          'Ruptured membranes expose the uterine cavity to ascending bacteria and risk umbilical cord prolapse.',
      clinicalRationaleSw:
          'Kupasuka kwa chupa kunaweza kusababisha maambukizi na kitovu cha mtoto kubanwa.',
      requiresEmergencyHotline: true,
    ),

    // ----------------------------------------------------
    // 5. CONVULSIONS / FITS / ECLAMPSIA (Degedege)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'convulsions',
      titleEn: 'Convulsions or Seizures (Eclampsia)',
      titleSw: 'Degedege au Kifafa cha Mimba',
      descriptionEn:
          'Fits, seizures, involuntary body jerking, or loss of consciousness is a critical obstetric emergency.',
      descriptionSw:
          'Kupata degedege au kupoteza fahamu wakati wa ujauzito ni dharura kubwa ya kiafya.',
      level: TriageLevel.emergency,
      keywordsEn: const [
        'convulsion',
        'convulsions',
        'seizure',
        'seizures',
        'fit',
        'fits',
        'fainted',
        'loss of consciousness',
        'blackout',
      ],
      keywordsSw: const [
        'degedege',
        'kifafa cha mimba',
        'kuzimia',
        'kupoteza fahamu',
        'kutingizika mwili',
      ],
      regexPatterns: [
        RegExp(r'\b(convulsion(s)?|seizure(s)?|epilep(sy|tic)|fits?)\b',
            caseSensitive: false),
        RegExp(r'\b(faint(ed|ing)?|loss\s+of\s+consciousness|blacked?\s*out)\b',
            caseSensitive: false),
        RegExp(r'\b(degedege|kifafa\s+cha\s+mimba|kuzimia|kupoteza\s+fahamu)\b',
            caseSensitive: false),
      ],
      immediateActionEn:
          'Call 1199 or get to the nearest emergency referral hospital immediately. Protect airway and keep mother on her left side.',
      immediateActionSw:
          'Piga 1199 au nenda hospitali ya rufaa iliyo karibu mara moja. Mlaze upande wa kushoto na ulinde njia ya hewa.',
      requiresEmergencyHotline: true,
    ),

    // ----------------------------------------------------
    // 6. HIGH FEVER AND CHILLS (Homa Kali na Kutetemeka)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'high_fever_chills',
      titleEn: 'High Fever with Chills or Rigors',
      titleSw: 'Homa Kali na Kutetemeka',
      descriptionEn:
          'High maternal body temperature (>38°C) with shaking chills could indicate severe malaria, pyelonephritis, or sepsis.',
      descriptionSw:
          'Homa kali (juu ya 38°C) pamoja na kutetemeka inaweza kuashiria malaria kali au maambukizi mwilini.',
      level: TriageLevel.urgent,
      keywordsEn: const [
        'high fever',
        'chills',
        'shivering',
        'very hot',
        'rigors',
        'burning up',
        'temperature above 38',
      ],
      keywordsSw: const [
        'homa kali',
        'kutetemeka',
        'mwili moto sana',
        'homa ya vipindi',
        'malaria',
      ],
      regexPatterns: [
        RegExp(r'\b(high\s+fever|chills|shivering|rigors|burning\s+up)\b',
            caseSensitive: false),
        RegExp(r'\b(homa\s+kali|kutetemeka|mwili\s+kuwa\s+moto\s+sana)\b',
            caseSensitive: false),
      ],
      immediateActionEn:
          'Visit your health clinic within 24 hours for a blood slide for malaria and antibiotic evaluation. Drink clean fluids.',
      immediateActionSw:
          'Tembelea zahanati au hospitali ndani ya saa 24 ili kupima malaria na kupokea matibabu sahihi.',
      requiresEmergencyHotline: false,
    ),

    // ----------------------------------------------------
    // 7. SEVERE ABDOMINAL PAIN (Maumivu Makali ya Tumbo)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'severe_abdominal_pain',
      titleEn: 'Severe Abdominal Pain',
      titleSw: 'Maumivu Makali ya Tumbo',
      descriptionEn:
          'Severe, sharp, continuous or cramping lower abdominal pain is a red flag for placental abruption, ectopic pregnancy, or uterine rupture.',
      descriptionSw:
          'Maumivu makali sana ya tumbo la chini yanayoendelea yanaweza kuashiria kondo kubanduka au mimba kutunga nje.',
      level: TriageLevel.emergency,
      keywordsEn: const [
        'severe stomach pain',
        'severe abdominal pain',
        'sharp belly pain',
        'terrible cramps',
        'continuous pain',
        'uterine pain',
        'unbearable cramps',
      ],
      keywordsSw: const [
        'tumbo linauma sana',
        'maumivu makali ya tumbo',
        'tumbo la chini linauma vikali',
        'maumivu yasiyovumilika',
      ],
      regexPatterns: [
        RegExp(
            r'\b(severe|sharp|terrible|unbearable|constant)\s+(abdominal|belly|stomach|tummy)\s+pain\b',
            caseSensitive: false),
        RegExp(
            r'\b(tumbo\b.*\b(kuuma\s+sana|linauma\s+sana|kuuma\s+vikali|yasiyovumilika))\b',
            caseSensitive: false),
      ],
      immediateActionEn:
          'Seek immediate care at a maternity facility. Avoid taking pain relief tablets before clinical review.',
      immediateActionSw:
          'Nenda kituo cha afya mara moja. Usinywe dawa za kupunguza maumivu bila maagizo ya daktari.',
      requiresEmergencyHotline: true,
    ),

    // ----------------------------------------------------
    // 8. SUDDEN SWELLING OF FACE & HANDS (Kuvimba Uso na Mikono)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'severe_swelling_face_hands',
      titleEn: 'Sudden Swelling of Face and Hands',
      titleSw: 'Kuvimba Uso na Mikono Ghafla',
      descriptionEn:
          'Sudden puffiness of face, eyes, and hands indicates fluid retention from pre-eclampsia.',
      descriptionSw:
          'Kuvimba kwa uso, macho na mikono ghafla huashiria pre-eclampsia na shinikizo la damu.',
      level: TriageLevel.urgent,
      keywordsEn: const [
        'swollen face',
        'swelling in hands',
        'puffy eyes',
        'facial swelling',
        'cannot remove ring',
        'sudden swelling',
      ],
      keywordsSw: const [
        'uso umevimba',
        'kuvimba mikono',
        'macho kuvimba',
        'kuvimba ghafla',
        'uso na mikono',
      ],
      regexPatterns: [
        RegExp(
            r'\b(swollen\s+face|facial\s+swelling|swelling\s+in\s+hands|puffy\s+eyes)\b',
            caseSensitive: false),
        RegExp(r'\b(uso\s+umevimba|kuvimba\s+mikono|macho\s+kuvimba)\b',
            caseSensitive: false),
      ],
      immediateActionEn:
          'Have your blood pressure checked today at the nearest dispensary or health centre.',
      immediateActionSw:
          'Pima shinikizo la damu leo katika zahanati au kituo cha afya kilicho karibu.',
      requiresEmergencyHotline: false,
    ),

    // ----------------------------------------------------
    // 9. FOUL-SMELLING VAGINAL DISCHARGE (Uchafu Wenye Harufu)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'foul_discharge',
      titleEn: 'Foul-Smelling Vaginal Discharge or Severe Itching',
      titleSw: 'Uchafu Ukeni Wenye Harufu Mbaya au Mwasho Mkali',
      descriptionEn:
          'Discharge with unpleasant odor, yellow/green color, or intense itching may be a bacterial or parasitic infection risking preterm labor.',
      descriptionSw:
          'Uchafu wa uke wenye harufu mbaya au mwasho huweza kuwa maambukizi yanayohatarisha uzazi kabla ya wakati.',
      level: TriageLevel.warning,
      keywordsEn: const [
        'foul smell',
        'bad odor discharge',
        'green discharge',
        'yellow discharge',
        'vaginal itch',
        'burning discharge',
      ],
      keywordsSw: const [
        'harufu mbaya ukeni',
        'uchafu unanuka',
        'mwasho ukeni',
        'uchafu wa njano au kijani',
      ],
      regexPatterns: [
        RegExp(
            r'\b(foul\s+smell|bad\s+odor|smelly\s+discharge|green\s+discharge)\b',
            caseSensitive: false),
        RegExp(
            r'\b(harufu\s+mbaya|uchafu\s+unanuka|mwasho\s+ukeni)\b',
            caseSensitive: false),
      ],
      immediateActionEn:
          'Visit your ANC clinic for a gentle swab test and safe pregnancy-approved prescription.',
      immediateActionSw:
          'Tembelea kliniki yako ya ANC ili kufanyiwa uchunguzi na kupata dawa zilizo salama kwa ujauzito.',
      requiresEmergencyHotline: false,
    ),

    // ----------------------------------------------------
    // 10. PERSISTENT SEVERE VOMITING (Kutapika Sana)
    // ----------------------------------------------------
    DangerSignRule(
      id: 'severe_vomiting',
      titleEn: 'Severe Persistent Vomiting (Hyperemesis)',
      titleSw: 'Kutapika Sana Kusikoisha',
      descriptionEn:
          'Inability to keep water or food down for over 24 hours, leading to dehydration and electrolyte imbalance.',
      descriptionSw:
          'Kushindwa kumeza maji au chakula kwa zaidi ya saa 24 na mkojo kuwa mchache au mweusi sana.',
      level: TriageLevel.urgent,
      keywordsEn: const [
        'cannot keep water down',
        'vomiting everything',
        'throwing up constantly',
        'dehydrated',
        'severe nausea vomiting',
      ],
      keywordsSw: const [
        'ninatapika kila kitu',
        'kutapika sana',
        'hata maji ninatapika',
        'kukosa nguvu kwa kutapika',
      ],
      regexPatterns: [
        RegExp(
            r'\b(cannot\s+keep\s+water\s+down|vomiting\s+everything|throwing\s+up\s+constantly)\b',
            caseSensitive: false),
        RegExp(
            r'\b(kutapika\s+sana|hata\s+maji\s+ninatapika|ninatapika\s+kila\s+kitu)\b',
            caseSensitive: false),
      ],
      immediateActionEn:
          'Visit the clinic for IV fluid rehydration and pregnancy-safe antiemetics.',
      immediateActionSw:
          'Fika kituo cha afya upate dripu ya maji na dawa salama za kuzuia kutapika.',
      requiresEmergencyHotline: false,
    ),
  ];

  /// Full catalog of Kenya MoH Danger Sign Rules
  static List<DangerSignRule> get dangerSigns => List.unmodifiable(_dangerSigns);

  /// The 4 Backbone Critical Obstetric Danger Signs highlighted by Kenya MoH
  static List<DangerSignRule> get backboneDangerSigns => _dangerSigns
      .where((r) =>
          r.id == 'vaginal_bleeding' ||
          r.id == 'severe_headache_visual' ||
          r.id == 'reduced_fetal_movement' ||
          r.id == 'water_leaking')
      .toList();

  /// Evaluate user query or recorded symptoms against deterministic safety rules
  SafetyAssessment evaluate(String text) {
    if (text.trim().isEmpty) {
      return const SafetyAssessment(
        triageLevel: TriageLevel.routine,
        triggeredRules: [],
        recommendedActionEn: 'Routine maternal wellbeing guidance.',
        recommendedActionSw: 'Mwongozo wa kawaida wa afya ya uzazi.',
        isSafeForAiResponse: true,
        requiresImmediateCall: false,
      );
    }

    final normalized = text.toLowerCase().trim();

    // Check for negative false-positive contexts (e.g. routine blood test / clinic lab work)
    final isRoutineLabContext = _isRoutineLabContext(normalized);

    final matchedRules = <DangerSignRule>[];

    for (final rule in _dangerSigns) {
      // If query is just about routine blood test without bleeding symptoms, skip vaginal bleeding rule
      if (rule.id == 'vaginal_bleeding' && isRoutineLabContext) {
        continue;
      }

      bool matched = false;

      // 1. High-fidelity Regex Pattern Matching
      for (final regex in rule.regexPatterns) {
        if (regex.hasMatch(normalized)) {
          matched = true;
          break;
        }
      }

      // 2. Keyword/phrase checking (English)
      if (!matched) {
        for (final kw in rule.keywordsEn) {
          if (_containsPhrase(normalized, kw.toLowerCase())) {
            matched = true;
            break;
          }
        }
      }

      // 3. Keyword/phrase checking (Kiswahili)
      if (!matched) {
        for (final kw in rule.keywordsSw) {
          if (_containsPhrase(normalized, kw.toLowerCase())) {
            matched = true;
            break;
          }
        }
      }

      if (matched) {
        matchedRules.add(rule);
      }
    }

    if (matchedRules.isEmpty) {
      return const SafetyAssessment(
        triageLevel: TriageLevel.routine,
        triggeredRules: [],
        recommendedActionEn:
            'Safe for AI maternal educational guidance. Always verify with your ANC provider.',
        recommendedActionSw:
            'Salama kwa mwongozo wa elimu ya uzazi. Daima thibitisha na mhudumu wako wa ANC.',
        isSafeForAiResponse: true,
        requiresImmediateCall: false,
      );
    }

    // Determine highest triage level
    bool hasEmergency = matchedRules.any(
      (r) => r.level == TriageLevel.emergency,
    );
    bool hasUrgent = matchedRules.any((r) => r.level == TriageLevel.urgent);
    bool hasWarning = matchedRules.any((r) => r.level == TriageLevel.warning);

    final highestLevel = hasEmergency
        ? TriageLevel.emergency
        : (hasUrgent
            ? TriageLevel.urgent
            : (hasWarning ? TriageLevel.warning : TriageLevel.routine));

    final ruleNamesEn = matchedRules.map((r) => r.titleEn).join(', ');
    final ruleNamesSw = matchedRules.map((r) => r.titleSw).join(', ');

    final emergencyNoticeEn = hasEmergency
        ? '🚨 CRITICAL MATERNAL ALERT: You have reported symptoms that require immediate emergency care ($ruleNamesEn).\n\n'
            'Please call the Kenya Red Cross Emergency Hotline at 1199 (toll-free) or go to the nearest maternity emergency hospital right away. Do not wait for your scheduled clinic appointment.'
        : null;

    final emergencyNoticeSw = hasEmergency
        ? '🚨 TAARIFA YA DHARURA YA UZAZI: Umeripoti dalili za hatari zinazohitaji matibabu ya dharura hospitalini mara moja ($ruleNamesSw).\n\n'
            'Tafadhali piga simu Shirika la Msalaba Mwekundu nambari 1199 (bila malipo) au nenda kituo cha afya kilicho karibu sasa hivi. Usisubiri siku ya kliniki yako ya kawaida.'
        : null;

    return SafetyAssessment(
      triageLevel: highestLevel,
      triggeredRules: matchedRules,
      recommendedActionEn: matchedRules.first.immediateActionEn,
      recommendedActionSw: matchedRules.first.immediateActionSw,
      isSafeForAiResponse: !hasEmergency,
      requiresImmediateCall: hasEmergency,
      overrideEmergencyMessageEn: emergencyNoticeEn,
      overrideEmergencyMessageSw: emergencyNoticeSw,
    );
  }

  /// Disambiguate routine blood pressure or routine lab test questions from acute bleeding
  static bool _isRoutineLabContext(String text) {
    final isBloodTest = text.contains('blood test') ||
        text.contains('blood group') ||
        text.contains('blood count') ||
        text.contains('kipimo cha damu') ||
        text.contains('kupima damu') ||
        text.contains('vipimo vya damu');

    final hasAcuteBleedingClues = text.contains('vagina') ||
        text.contains('pad') ||
        text.contains('underwear') ||
        text.contains('spotting') ||
        text.contains('clot') ||
        text.contains('heavy') ||
        text.contains('flowing') ||
        text.contains('soak') ||
        text.contains('uke') ||
        text.contains('kuvuja') ||
        text.contains('inatoka') ||
        text.contains('inavuja') ||
        text.contains('nyingi') ||
        text.contains('mabonge');

    return isBloodTest && !hasAcuteBleedingClues;
  }

  /// Check word boundary or substring match
  static bool _containsPhrase(String text, String phrase) {
    if (phrase.contains(' ')) {
      return text.contains(phrase);
    }
    final regex = RegExp(
      r'\b' + RegExp.escape(phrase) + r'\b',
      caseSensitive: false,
    );
    return regex.hasMatch(text);
  }

  /// System prompt instructions for Mama AI to reinforce clinical guardrails
  static String getSystemPromptSafetyGuardrail({required bool isSwahili}) {
    if (isSwahili) {
      return '''
WEWE NI MAMA AI — MSAIDIZI WA AFYA YA UZAZI KWA WAJAWATO NCHINI KENYA.
MIPAKA NA SHERIA ZA USALAMA ZA WIZARA YA AFYA KENYA (MoH):
1. Wewe si daktari na hautoi utambuzi wa kitabibu (diagnosis) au maagizo ya dawa (prescriptions).
2. Daima himiza mama ahudhurie kliniki zote 8 za ANC (Antenatal Care) chini ya mpango wa Linda Mama / SHA.
3. Ukigundua dalili ya hatari (damu ukeni, kichwa kuuma sana na kiza machoni, degedege, mtoto kutocheza, maji ya uzazi kuvuja, homa kali), toa maelekezo ya dharura kwenda hospitali mara moja au kupiga 1199.
4. Tumia lugha ya heshima, upendo, na matumaini (Kiswahili Sanifu na cha kueleweka nchini Kenya).
5. Kamwe usipendekeze dawa za kienyeji au dawa za dukani bila daktari.
''';
    } else {
      return '''
YOU ARE MAMA AI — A TRUSTED, COMPASSIONATE MATERNAL WELLBEING ASSISTANT FOR EXPECTANT MOTHERS IN KENYA.
KENYA MINISTRY OF HEALTH (MoH) CLINICAL BOUNDARIES & SAFETY RULES:
1. You are an educational pregnancy companion, NOT a medical doctor. Never diagnose illnesses or prescribe medication.
2. Strongly encourage mothers to complete all recommended 8 Antenatal Care (ANC) contacts under Kenya MoH guidelines.
3. For any danger sign (vaginal bleeding, severe headache/blurred vision, convulsions, reduced fetal movement, fluid leakage, severe abdominal pain), instruct the mother to visit the nearest healthcare facility immediately or dial Kenya Red Cross 1199.
4. Keep advice culturally attuned, warm, reassuring, and aligned with Kenyan nutritional and healthcare contexts (e.g. sukuma wiki, terere, managu, avocado, iron/folate supplements, mosquito net usage).
5. Always advise the mother to discuss any physical symptoms directly with her nurse or midwife.
''';
    }
  }
}
