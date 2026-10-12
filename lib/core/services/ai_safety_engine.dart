// ============================================
// MamaCare KE - AI Safety Engine
// ============================================
// Deterministic clinical safety layer adhering
// to Kenya Ministry of Health (MoH) Guidelines
// for Maternal & Neonatal Care.
//
// CRITICAL PRINCIPLE:
// Never rely solely on an LLM for safety-critical
// maternal triage. All user messages and reported
// symptoms are parsed through this deterministic
// engine BEFORE and AFTER LLM processing.
// ============================================

/// Severity of identified maternal symptoms
enum TriageLevel {
  emergency, // Immediate hospital / Call 1199 / Red Cross
  urgent, // Visit healthcare facility within 24 hours
  warning, // Monitor closely; contact clinic if persistent
  routine, // Safe for educational advice; regular ANC
}

/// Danger sign classification according to Kenya MoH
class DangerSignRule {
  final String id;
  final String titleEn;
  final String titleSw;
  final String descriptionEn;
  final String descriptionSw;
  final TriageLevel level;
  final List<String> keywordsEn;
  final List<String> keywordsSw;
  final String immediateActionEn;
  final String immediateActionSw;
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
    required this.immediateActionEn,
    required this.immediateActionSw,
    this.requiresEmergencyHotline = false,
  });
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
}

/// Deterministic clinical safety engine
class AiSafetyEngine {
  AiSafetyEngine._();
  static final AiSafetyEngine instance = AiSafetyEngine._();

  /// Kenya Ministry of Health defined Obstetric Danger Signs
  static final List<DangerSignRule> _dangerSigns = [
    // 1. Vaginal Bleeding (Antepartum / Postpartum hemorrhage risk)
    const DangerSignRule(
      id: 'vaginal_bleeding',
      titleEn: 'Vaginal Bleeding',
      titleSw: 'Kutokwa na Damu Ukeni',
      descriptionEn:
          'Any vaginal bleeding during pregnancy is abnormal and requires immediate evaluation.',
      descriptionSw:
          'Kutokwa na damu ukeni wakati wa ujauzito si kawaida na kunahitaji uchunguzi wa haraka.',
      level: TriageLevel.emergency,
      keywordsEn: [
        'bleeding',
        'blood',
        'spotting',
        'hemorrhage',
        'clots',
        'bloody',
        'discharge with blood',
        'heavy bleeding',
        'red discharge',
      ],
      keywordsSw: [
        'damu',
        'kutokwa na damu',
        'kuvuja damu',
        'matone ya damu',
        'uchafu wenye damu',
      ],
      immediateActionEn:
          'Go to the nearest emergency health facility or call 1199 immediately. Do not insert anything into the vagina.',
      immediateActionSw:
          'Nenda kituo cha afya kilicho karibu au piga simu 1199 mara moja. Usiweke kitu chochote ukeni.',
      requiresEmergencyHotline: true,
    ),

    // 2. Severe Headache with Blurred Vision (Preeclampsia / Eclampsia)
    const DangerSignRule(
      id: 'severe_headache_visual',
      titleEn: 'Severe Headache or Blurred Vision',
      titleSw: 'Kuumwa Kichwa Sana au Kutoona Vizuri',
      descriptionEn:
          'Persistent severe headache, flashing lights, or blurred vision may indicate severe preeclampsia or eclampsia.',
      descriptionSw:
          'Kuumwa kichwa sana kunakoendelea, kuona giza au mianga kunaweza kuashiria shinikizo la juu la damu (preeclampsia).',
      level: TriageLevel.emergency,
      keywordsEn: [
        'severe headache',
        'blurry vision',
        'blurred vision',
        'flashing lights',
        'seeing spots',
        'terrible headache',
        'head pounding',
        'cannot see clearly',
        'vision changes',
      ],
      keywordsSw: [
        'kichwa kinauma sana',
        'kichwa kuuma vikali',
        'kutoona vizuri',
        'kuona giza',
        'kuona mianga',
        'macho kutoona',
      ],
      immediateActionEn:
          'Seek immediate medical attention at a hospital to check blood pressure and urine protein.',
      immediateActionSw:
          'Pata matibabu ya dharura hospitalini ili kupima shinikizo la damu na protini kwenye mkojo.',
      requiresEmergencyHotline: true,
    ),

    // 3. Convulsions / Fits / Seizures (Eclampsia)
    const DangerSignRule(
      id: 'convulsions',
      titleEn: 'Convulsions or Seizures',
      titleSw: 'Degedege au Kifafa cha Mimba',
      descriptionEn:
          'Fits or loss of consciousness during pregnancy or after delivery is a medical emergency.',
      descriptionSw:
          'Kupata degedege au kupoteza fahamu wakati wa ujauzito ni dharura ya kiafya.',
      level: TriageLevel.emergency,
      keywordsEn: [
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
      keywordsSw: [
        'degedege',
        'kifafa cha mimba',
        'kuzimia',
        'kupoteza fahamu',
        'kutingizika',
      ],
      immediateActionEn:
          'Call 1199 or get to the nearest emergency referral hospital immediately. Protect airway and keep mother on her left side.',
      immediateActionSw:
          'Piga 1199 au nenda hospitali ya rufaa iliyo karibu mara moja. Mlaze upande wa kushoto.',
      requiresEmergencyHotline: true,
    ),

    // 4. Reduced or Absent Fetal Movements
    const DangerSignRule(
      id: 'reduced_fetal_movement',
      titleEn: 'Reduced or Absent Baby Movements',
      titleSw: 'Mtoto Kupunguza au Kuacha Kucheza',
      descriptionEn:
          'A significant decrease or cessation in baby kicks/movements after 28 weeks warrants immediate assessment.',
      descriptionSw:
          'Kupungua au kukosekana kwa mienendo au mateke ya mtoto tumboni baada ya wiki 28 kunahitaji uchunguzi wa haraka.',
      level: TriageLevel.emergency,
      keywordsEn: [
        'baby not moving',
        'no kicks',
        'reduced movement',
        'less movement',
        'baby stopped moving',
        'has not kicked',
        'stopped kicking',
        'no movement today',
      ],
      keywordsSw: [
        'mtoto hachezi',
        'mtoto hajasonga',
        'mateke yamepungua',
        'mtoto ametulia',
        'hachezi leo',
      ],
      immediateActionEn:
          'Eat a light snack, lie on your left side for 2 hours and count kicks. If fewer than 10 movements or none, go to a maternity unit immediately.',
      immediateActionSw:
          'Kula chakula chepesi, lala upande wa kushoto kwa saa 2 na uhesabu mienendo. Isipofika 10 au asipocheza, nenda hospitali mara moja.',
      requiresEmergencyHotline: true,
    ),

    // 5. Water Breaking / Fluid Leaking before 37 weeks (Preterm PROM)
    const DangerSignRule(
      id: 'water_leaking',
      titleEn: 'Leaking Amniotic Fluid',
      titleSw: 'Kuvuja kwa Chupa ya Uzazi (Maji)',
      descriptionEn:
          'Sudden gush or continuous trickle of watery fluid before your due date or with foul odor/greenish color.',
      descriptionSw:
          'Kutiririka au kutoka kwa maji ya uzazi kabla ya wiki 37 au maji yenye rangi ya kijani/harufu mbaya.',
      level: TriageLevel.emergency,
      keywordsEn: [
        'water broke',
        'waters broke',
        'leaking fluid',
        'amniotic fluid',
        'gush of water',
        'water leaking',
        'greenish fluid',
        'trickle of liquid',
      ],
      keywordsSw: [
        'chupa imepasuka',
        'chupa imevunjika',
        'maji ya uzazi',
        'kutoka maji',
        'kuvuja maji',
      ],
      immediateActionEn:
          'Go immediately to the maternity department. Note color and time fluid started leaking. Do not take baths or use tampons.',
      immediateActionSw:
          'Nenda haraka kwenye idara ya uzazi hospitalini. Zingatia rangi na muda maji yalianza kutoka.',
      requiresEmergencyHotline: true,
    ),

    // 6. High Fever and Chills (Severe Infection / Malaria)
    const DangerSignRule(
      id: 'high_fever_chills',
      titleEn: 'High Fever with Chills or Rigors',
      titleSw: 'Homa Kali na Kutetemeka',
      descriptionEn:
          'High body temperature (>38°C) with shaking chills could indicate malaria, sepsis, or UTI affecting pregnancy.',
      descriptionSw:
          'Homa kali (juu ya 38°C) pamoja na kutetemeka inaweza kuashiria malaria au maambukizi makali.',
      level: TriageLevel.urgent,
      keywordsEn: [
        'high fever',
        'chills',
        'shivering',
        'very hot',
        'rigors',
        'burning up',
        'temperature above 38',
      ],
      keywordsSw: [
        'homa kali',
        'kutetemeka',
        'mwili moto sana',
        'homa ya vipindi',
        'malaria',
      ],
      immediateActionEn:
          'Visit your health clinic within 24 hours for a blood slide for malaria and antibiotic evaluation. Drink clean fluids.',
      immediateActionSw:
          'Tembelea zahanati au hospitali ndani ya saa 24 ili kupima malaria na kupokea matibabu sahihi.',
      requiresEmergencyHotline: false,
    ),

    // 7. Severe Persistent Abdominal Pain
    const DangerSignRule(
      id: 'severe_abdominal_pain',
      titleEn: 'Severe Abdominal Pain',
      titleSw: 'Maumivu Makali ya Tumbo',
      descriptionEn:
          'Severe, sharp, continuous or cramping lower abdominal pain is a red flag for abruption, ectopic pregnancy, or uterine rupture.',
      descriptionSw:
          'Maumivu makali sana ya tumbo la chini yanayoendelea yanaweza kuashiria hatari kwa mimba au kondo.',
      level: TriageLevel.emergency,
      keywordsEn: [
        'severe stomach pain',
        'severe abdominal pain',
        'sharp belly pain',
        'terrible cramps',
        'continuous pain',
        'uterine pain',
        'unbearable cramps',
      ],
      keywordsSw: [
        'tumbo linauma sana',
        'maumivu makali ya tumbo',
        'tumbo la chini linauma vikali',
        'maumivu yasiyovumilika',
      ],
      immediateActionEn:
          'Seek immediate care at a maternity facility. Avoid taking pain relief tablets before clinical review.',
      immediateActionSw:
          'Nenda kituo cha afya mara moja. Usinywe dawa za kupunguza maumivu bila maagizo ya daktari.',
      requiresEmergencyHotline: true,
    ),

    // 8. Sudden Severe Swelling of Face and Hands
    const DangerSignRule(
      id: 'severe_swelling_face_hands',
      titleEn: 'Sudden Swelling of Face and Hands',
      titleSw: 'Kuvimba Uso na Mikono Ghafla',
      descriptionEn:
          'Sudden puffiness of face, eyes, and hands (not just mild evening ankle swelling) points towards preeclampsia.',
      descriptionSw:
          'Kuvimba kwa uso, macho na mikono ghafla (si tu uvimbe wa kawaida wa miguu jioni) huashiria preeclampsia.',
      level: TriageLevel.urgent,
      keywordsEn: [
        'swollen face',
        'swelling in hands',
        'puffy eyes',
        'facial swelling',
        'cannot remove ring',
        'sudden swelling',
      ],
      keywordsSw: [
        'uso umevimba',
        'kuvimba mikono',
        'macho kuvimba',
        'kuvimba ghafla',
        'uso na mikono',
      ],
      immediateActionEn:
          'Have your blood pressure checked today at the nearest dispensary or health centre.',
      immediateActionSw:
          'Pima shinikizo la damu leo katika zahanati au kituo cha afya kilicho karibu.',
      requiresEmergencyHotline: false,
    ),

    // 9. Foul-Smelling Vaginal Discharge
    const DangerSignRule(
      id: 'foul_discharge',
      titleEn: 'Foul-Smelling Vaginal Discharge or Severe Itching',
      titleSw: 'Uchafu Ukeni Wenye Harufu Mbaya au Mwasho Mkali',
      descriptionEn:
          'Discharge with unpleasant odor, yellow/green color, or intense itching may be a bacterial or parasitic infection risking preterm labor.',
      descriptionSw:
          'Uchafu wa uke wenye harufu mbaya au mwasho huweza kuwa maambukizi yanayohatarisha uzazi kabla ya wakati.',
      level: TriageLevel.warning,
      keywordsEn: [
        'foul smell',
        'bad odor discharge',
        'green discharge',
        'yellow discharge',
        'vaginal itch',
        'burning discharge',
      ],
      keywordsSw: [
        'harufu mbaya ukeni',
        'uchafu unanuka',
        'mwasho ukeni',
        'uchafu wa njano au kijani',
      ],
      immediateActionEn:
          'Visit your ANC clinic for a gentle swab test and safe pregnancy-approved prescription.',
      immediateActionSw:
          'Tembelea kliniki yako ya ANC ili kufanyiwa uchunguzi na kupata dawa zilizo salama kwa ujauzito.',
      requiresEmergencyHotline: false,
    ),

    // 10. Persistent Severe Vomiting / Inability to Keep Fluids (Hyperemesis)
    const DangerSignRule(
      id: 'severe_vomiting',
      titleEn: 'Severe Persistent Vomiting',
      titleSw: 'Kutapika Sana Kusikoisha',
      descriptionEn:
          'Inability to keep water or food down for over 24 hours, leading to dehydration and dark concentrated urine.',
      descriptionSw:
          'Kushindwa kumeza maji au chakula kwa zaidi ya saa 24 na mkojo kuwa mchache au mweusi sana.',
      level: TriageLevel.urgent,
      keywordsEn: [
        'cannot keep water down',
        'vomiting everything',
        'throwing up constantly',
        'dehydrated',
        'severe nausea vomiting',
      ],
      keywordsSw: [
        'ninatapika kila kitu',
        'kutapika sana',
        'hata maji ninatapika',
        'kukosa nguvu kwa kutapika',
      ],
      immediateActionEn:
          'Visit the clinic for IV fluid rehydration and pregnancy-safe antiemetics.',
      immediateActionSw:
          'Fika kituo cha afya upate dripu ya maji na dawa salama za kuzuia kutapika.',
      requiresEmergencyHotline: false,
    ),
  ];

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

    final normalized = text.toLowerCase();
    final matchedRules = <DangerSignRule>[];

    for (final rule in _dangerSigns) {
      bool matched = false;

      // Check English keywords
      for (final kw in rule.keywordsEn) {
        if (_containsPhrase(normalized, kw.toLowerCase())) {
          matched = true;
          break;
        }
      }

      // Check Kiswahili keywords
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
        ? '🚨 CRITICAL MATERNAL ALERT: You have reported signs that require immediate in-person emergency care ($ruleNamesEn). Please call the Red Cross Emergency Hotline at 1199 or go to the nearest maternity emergency room right away.'
        : null;

    final emergencyNoticeSw = hasEmergency
        ? '🚨 TAARIFA YA DHARURA YA UZAZI: Umeripoti dalili zinazohitaji matibabu ya dharura hospitalini mara moja ($ruleNamesSw). Tafadhali piga simu Shirika la Msalaba Mwekundu nambari 1199 au nenda kituo cha afya kilicho karibu sasa.'
        : null;

    return SafetyAssessment(
      triageLevel: highestLevel,
      triggeredRules: matchedRules,
      recommendedActionEn: matchedRules.first.immediateActionEn,
      recommendedActionSw: matchedRules.first.immediateActionSw,
      isSafeForAiResponse:
          !hasEmergency, // If emergency, AI MUST NOT act as medical diagnostician
      requiresImmediateCall: hasEmergency,
      overrideEmergencyMessageEn: emergencyNoticeEn,
      overrideEmergencyMessageSw: emergencyNoticeSw,
    );
  }

  /// Check word boundary or substring match
  static bool _containsPhrase(String text, String phrase) {
    if (phrase.contains(' ')) {
      return text.contains(phrase);
    }
    // Word boundary regex for single words to avoid false positives (e.g., "blood" vs "bloody")
    final regex = RegExp(
      r'\b' + RegExp.escape(phrase) + r'\b',
      caseSensitive: false,
    );
    return regex.hasMatch(text);
  }

  /// System prompt instructions for Mama AI to reinforce safe boundaries
  static String getSystemPromptSafetyGuardrail({required bool isSwahili}) {
    if (isSwahili) {
      return '''
WEWE NI MAMA AI — MSAIDIZI WA AFYA YA UZAZI KWA WAJAWATO NCHINI KENYA.
MIPAKA NA SHERIA ZA USALAMA ZA WIZARA YA AFYA KENYA (MoH):
1. Wewe si daktari na hautoi utambuzi wa kitabibu (diagnosis) au maagizo ya dawa (prescriptions).
2. Daima himiza mama ahudhurie kliniki za ANC (Antenatal Care) angalau mara 8 kulingana na miongozo ya Kenya MoH.
3. Ukigundua dalili ya hatari (damu ukeni, kichwa kuuma sana, degedege, mtoto kutocheza, maji kuvuja), toa maelekezo ya kwenda hospitali mara moja au kupiga 1199.
4. Tumia lugha ya heshima, upendo, na matumaini (Kiswahili sanifu na cha kueleweka nchini Kenya).
5. Kamwe usipendekeze dawa za kienyeji au dawa bila daktari.
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
