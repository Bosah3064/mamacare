// ============================================
// MamaCare KE - Mama AI Service
// ============================================
// Intelligent maternal companion service with
// integrated clinical safety guardrails, Kenya MoH
// context, and bilingual conversation handling.
// ============================================

import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'ai_safety_engine.dart';
import 'supabase_service.dart';

class MamaAiResponse {
  final AIMessage message;
  final SafetyAssessment safetyAssessment;
  final List<String> suggestedFollowUps;
  final bool shouldShowCall1199;
  final bool shouldShowFindFacility;

  const MamaAiResponse({
    required this.message,
    required this.safetyAssessment,
    this.suggestedFollowUps = const [],
    this.shouldShowCall1199 = false,
    this.shouldShowFindFacility = false,
  });
}

class MamaAiService {
  MamaAiService._();
  static final MamaAiService instance = MamaAiService._();

  final _uuid = const Uuid();
  final _safetyEngine = AiSafetyEngine.instance;
  final _supabaseService = SupabaseService.instance;

  /// Send message to Mama AI with deterministic safety checks and live Supabase persistence
  Future<MamaAiResponse> sendMessage({
    required String userText,
    required PregnancyProfile? pregnancyProfile,
    required Language language,
  }) async {
    final isSwahili = language == Language.sw;
    final now = DateTime.now();
    final userId = pregnancyProfile?.userId ??
        _supabaseService.currentUserId ??
        SupabaseService.defaultSeedUserId;
    const conversationId = 'conv-default';

    // 1. Save user's message in Supabase
    final userMsg = AIMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      userId: userId,
      role: 'user',
      content: userText,
      createdAt: now,
      updatedAt: now,
    );
    await _supabaseService.saveAIMessage(userMsg);

    // 2. Run deterministic clinical safety evaluation
    final safety = _safetyEngine.evaluate(userText);

    // 3. EMERGENCY RED FLAG (Kenya MoH Level 1 Danger Sign)
    if (safety.isEmergency) {
      final primaryRule = safety.primaryDangerSign;
      final buffer = StringBuffer();

      if (isSwahili) {
        buffer.writeln('🚨 **TAARIFA YA DHARURA YA KLINIKI (Kenya MoH Red Flag)**\n');
        if (primaryRule != null) {
          buffer.writeln('**Dalili ya Hatari Iliyogunduliwa:** ${primaryRule.titleSw}');
          buffer.writeln('${primaryRule.descriptionSw}\n');
        } else {
          buffer.writeln(safety.overrideEmergencyMessageSw ?? safety.recommendedActionSw);
          buffer.writeln();
        }

        buffer.writeln('📋 **HATUA ZA KUCHUKUA MARA MOJA:**');
        if (primaryRule != null && primaryRule.immediateStepsSw.isNotEmpty) {
          for (final step in primaryRule.immediateStepsSw) {
            buffer.writeln('• $step');
          }
        } else {
          buffer.writeln('• ${safety.recommendedActionSw}');
          buffer.writeln('• Piga simu Msalaba Mwekundu 1199 mara moja.');
          buffer.writeln('• Fika kituo cha afya chenye huduma ya dharura ya uzazi (Level 4+).');
        }

        buffer.writeln('\n⚠️ *Usiwahi kusubiri siku yako ya kliniki ya kawaida. Nenda hospitali au piga 1199 sasa.*');
      } else {
        buffer.writeln('🚨 **CRITICAL CLINICAL EMERGENCY ALERT (Kenya MoH Red Flag)**\n');
        if (primaryRule != null) {
          buffer.writeln('**Identified Danger Sign:** ${primaryRule.titleEn}');
          buffer.writeln('${primaryRule.descriptionEn}\n');
        } else {
          buffer.writeln(safety.overrideEmergencyMessageEn ?? safety.recommendedActionEn);
          buffer.writeln();
        }

        buffer.writeln('📋 **IMMEDIATE ACTION PROTOCOL:**');
        if (primaryRule != null && primaryRule.immediateStepsEn.isNotEmpty) {
          for (final step in primaryRule.immediateStepsEn) {
            buffer.writeln('• $step');
          }
        } else {
          buffer.writeln('• ${safety.recommendedActionEn}');
          buffer.writeln('• Call Kenya Red Cross Emergency Dispatch at 1199 (toll-free).');
          buffer.writeln('• Proceed immediately to the nearest Level 4+ County Referral Hospital.');
        }

        buffer.writeln('\n⚠️ *Do not wait for your scheduled clinic appointment. Seek emergency hospital care or dial 1199 immediately.*');
      }

      final assistantMsg = AIMessage(
        id: _uuid.v4(),
        conversationId: conversationId,
        userId: userId,
        role: 'assistant',
        content: buffer.toString().trim(),
        riskLevel: AIRiskLevel.emergency,
        safetyFlags: safety.triggeredRules.map((r) => r.id).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabaseService.saveAIMessage(assistantMsg);

      return MamaAiResponse(
        message: assistantMsg,
        safetyAssessment: safety,
        shouldShowCall1199: true,
        shouldShowFindFacility: true,
        suggestedFollowUps: isSwahili
            ? [
                'Piga 1199 (Bila Malipo)',
                'Tafuta Hospitali ya Karibu',
                'Mfahamishe Mtu wa Karibu',
                'Kagua Dalili Nyingine za Hatari',
              ]
            : [
                'Call 1199 Emergency',
                'Locate Nearest Hospital',
                'Notify Emergency Contact',
                'Review Other Danger Signs',
              ],
      );
    }

    // 4. URGENT HEALTH ALERT (Within 24 Hours)
    if (safety.isUrgent) {
      final primaryRule = safety.primaryDangerSign;
      final buffer = StringBuffer();

      if (isSwahili) {
        buffer.writeln('⚠️ **TAHADARI YA KIAFYA YA KLINIKI**\n');
        if (primaryRule != null) {
          buffer.writeln('**Dalili:** ${primaryRule.titleSw}');
          buffer.writeln('${primaryRule.descriptionSw}\n');
          buffer.writeln('📋 **Ushauri:**');
          if (primaryRule.immediateStepsSw.isNotEmpty) {
            for (final step in primaryRule.immediateStepsSw) {
              buffer.writeln('• $step');
            }
          } else {
            buffer.writeln('• ${primaryRule.immediateActionSw}');
          }
        } else {
          buffer.writeln(safety.recommendedActionSw);
        }
        buffer.writeln('\n*Dalili hii inahitaji kufanyiwa uchunguzi na daktari au mkunga leo katika zahanati au kituo cha afya kilicho karibu.*');
      } else {
        buffer.writeln('⚠️ **CLINICAL URGENT HEALTH ALERT**\n');
        if (primaryRule != null) {
          buffer.writeln('**Symptom:** ${primaryRule.titleEn}');
          buffer.writeln('${primaryRule.descriptionEn}\n');
          buffer.writeln('📋 **Clinical Guidance:**');
          if (primaryRule.immediateStepsEn.isNotEmpty) {
            for (final step in primaryRule.immediateStepsEn) {
              buffer.writeln('• $step');
            }
          } else {
            buffer.writeln('• ${primaryRule.immediateActionEn}');
          }
        } else {
          buffer.writeln(safety.recommendedActionEn);
        }
        buffer.writeln('\n*Please visit your nearest healthcare facility or dispensary today for a proper clinical evaluation.*');
      }

      final assistantMsg = AIMessage(
        id: _uuid.v4(),
        conversationId: conversationId,
        userId: userId,
        role: 'assistant',
        content: buffer.toString().trim(),
        riskLevel: AIRiskLevel.high,
        safetyFlags: safety.triggeredRules.map((r) => r.id).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabaseService.saveAIMessage(assistantMsg);

      return MamaAiResponse(
        message: assistantMsg,
        safetyAssessment: safety,
        shouldShowCall1199: false,
        shouldShowFindFacility: true,
        suggestedFollowUps: isSwahili
            ? ['Vituo vya Afya Karibu Nami', 'Andika kwenye Shajara ya Afya', 'Pima Shinikizo la Damu Leo']
            : ['Clinics Near Me', 'Record in Health Diary', 'Check Blood Pressure Today'],
      );
    }

    // 5. ROUTINE MATERNAL GUIDANCE (Safe Educational Companion)
    final gestationalWeek = pregnancyProfile?.currentWeek ?? 24;
    final responseContent = _generateContextualResponse(
      query: userText,
      week: gestationalWeek,
      isSwahili: isSwahili,
    );

    final assistantMsg = AIMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      userId: userId,
      role: 'assistant',
      content: responseContent,
      riskLevel: AIRiskLevel.low,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _supabaseService.saveAIMessage(assistantMsg);

    return MamaAiResponse(
      message: assistantMsg,
      safetyAssessment: safety,
      shouldShowCall1199: false,
      shouldShowFindFacility: false,
      suggestedFollowUps: _getSuggestedFollowUps(userText, isSwahili),
    );
  }

  /// Generates clinically grounded, culturally rich Kenyan maternal responses
  String _generateContextualResponse({
    required String query,
    required int week,
    required bool isSwahili,
  }) {
    final q = query.toLowerCase();

    // Educational inquiry about Danger Signs
    if (q.contains('danger sign') ||
        q.contains('warning sign') ||
        q.contains('dalili za hatari') ||
        q.contains('alama za hatari') ||
        q.contains('dharura')) {
      if (isSwahili) {
        return '🚨 **Alama Kuu 4 za Hatari Wakati wa Ujauzito (Kenya MoH):**\n\n'
            'Ukiona yoyote kati ya dalili hizi, nenda hospitali mara moja au piga **1199 (Msalaba Mwekundu)** bila kusubiri:\n\n'
            '1. **Kutokwa na Damu Ukeni:** Matone au damu nyingi wakati wowote wa mimba si kawaida.\n'
            '2. **Kuumwa Kichwa Sana na Kiza Machoni:** Maumivu makali ya kichwa yanayoambatana na kuona ukungu, giza, au mianga huashiria shinikizo la damu (pre-eclampsia).\n'
            '3. **Mtoto Kutocheza:** Mtoto kuacha kupiga mateke au kupunguza sana mienendo baada ya wiki ya 24.\n'
            '4. **Maji ya Uzazi Kuvuja:** Chupa kupasuka au maji kutiririka ukeni kabla ya tarehe ya kujifungua.\n\n'
            '🛡️ *Zingatia: MamaCare KE ina mfumo mahususi unaotambua dalili hizi kiotomatiki.*';
      } else {
        return '🚨 **The 4 Primary Obstetric Danger Signs (Kenya MoH Red Flags):**\n\n'
            'If you experience any of these symptoms, go to the nearest maternity hospital immediately or dial **1199 (Kenya Red Cross)**:\n\n'
            '1. **Vaginal Bleeding:** Any spotting or bleeding during pregnancy is abnormal and requires clinical review.\n'
            '2. **Severe Headache + Blurred Vision:** Persistent severe headache with visual aura, spots, or blurriness signals pre-eclampsia / hypertensive danger.\n'
            '3. **Reduced or Absent Fetal Movement:** Cessation or sharp drop in baby kicks after 24 weeks.\n'
            '4. **Rupture of Membranes / Leaking Amniotic Fluid:** Water breaking or continuous leaking before labor.\n\n'
            '🛡️ *Note: MamaCare KE has strict deterministic safety guardrails built in to protect you and your baby.*';
      }
    }

    // Nutrition & food inquiries
    if (q.contains('food') ||
        q.contains('eat') ||
        q.contains('diet') ||
        q.contains('nutrition') ||
        q.contains('chakula') ||
        q.contains('kula') ||
        q.contains('lishe') ||
        q.contains('mboga')) {
      if (isSwahili) {
        return 'Katika wiki ya $week, mtoto wako anakua kwa kasi na anahitaji virutubisho vya kutosha!\n\n'
            '🥗 **Vyakula Muhimu vya Kenya:**\n'
            '• **Mboga za Kienyeji:** Terere, managu, kunde, na sukuma wiki zina madini mengi ya chuma (iron) kuzuia upungufu wa damu.\n'
            '• **Protini:** Mayai ya kuchemsha, maziwa fresh, maharagwe, dengu (ndengu), na samaki (omena au tilapia).\n'
            '• **Wanga na Nishati:** Viazi vitamu, ndizi za kupika (matoke), ugali wa dona, na uji wa wimbi.\n'
            '• **Maji na Matunda:** Parachichi (avocado), maembe, machungwa (vitamini C husaidia kunyonya chuma), na kunywa angalau glasi 8 za maji safi kila siku.\n\n'
            '💊 **Muhimu:** Endelea kumeza vidonge vyako vya IFAS (Iron & Folic Acid) kila siku baada ya chakula cha jioni pamoja na maji safi!';
      } else {
        return 'At week $week, your baby is growing rapidly and needs balanced maternal nourishment!\n\n'
            '🥗 **Recommended Kenyan Maternal Foods:**\n'
            '• **Traditional Greens:** Terere (amaranth), managu (African nightshade), kunde (cowpea leaves), and spinach for essential iron.\n'
            '• **Proteins:** Hard-boiled eggs, fresh pasteurized milk, beans, green grams (ndengu), and fish (omena or tilapia).\n'
            '• **Energy & Fiber:** Sweet potatoes, cooked green bananas (matoke), whole grain brown ugali, and millet/sorghum porridge (uji wa wimbi).\n'
            '• **Hydration & Fruits:** Avocado for healthy fats, oranges/mangoes (Vitamin C enhances iron absorption), and at least 8 glasses of safe water daily.\n\n'
            '💊 **Essential:** Continue taking your daily IFAS (Iron and Folic Acid Supplements) with water after meals!';
      }
    }

    // Baby kicks & movement inquiries
    if (q.contains('kick') ||
        q.contains('move') ||
        q.contains('mateke') ||
        q.contains('kucheza')) {
      if (isSwahili) {
        return 'Kuanzia wiki ya 24 hadi 28, mienendo ya mtoto huanza kuwa thabiti na dhahiri zaidi!\n\n'
            '👶 **Jinsi ya Kufuatilia Mienendo ya Mtoto:**\n'
            '• Watoto huwa na vipindi vya kulala (dakika 20-40) na vipindi vya kuwa macho.\n'
            '• **Kuhimiza mwendo:** Kunywa glasi ya maji baridi au kula vitafunio vyepesi, kisha ulale upande wa kushoto kwa utulivu.\n'
            '• **Kipimo cha Mateke 10:** Kuanzia wiki ya 28, unapaswa kuhisi angalau mienendo au mateke 10 ndani ya masaa 2 wakati mtoto yuko macho.\n\n'
            '🚨 *Iwapo mtoto ataacha kucheza kabisa au mienendo itapungua sana, fika hospitali ya uzazi mara moja.*';
      } else {
        return 'Around week $week, your baby\'s kicks, turns, and hiccups become noticeably stronger!\n\n'
            '👶 **Fetal Movement Guidelines:**\n'
            '• Babies develop sleep-wake cycles (typically resting for 20–40 minutes at a time).\n'
            '• **To encourage movement:** Have a light snack or cold glass of water, then rest quietly on your left side.\n'
            '• **The 10-Kick Rule:** From 28 weeks onwards, aim to feel at least 10 kicks or distinct movements within a 2-hour window during active times.\n\n'
            '🚨 *If your baby stops moving or kicks drop significantly, seek immediate clinical review at your maternity clinic.*';
      }
    }

    // Linda Mama & ANC Contact Schedule
    if (q.contains('linda mama') ||
        q.contains('clinic') ||
        q.contains('anc') ||
        q.contains('kliniki') ||
        q.contains('ratiba')) {
      if (isSwahili) {
        return '🏥 **Huduma ya Linda Mama na Ratiba ya Kliniki (ANC) Kenya:**\n\n'
            'Wizara ya Afya (MoH) inapendekeza angalau **mawasiliano 8 ya kliniki ya ANC** katika ujauzito mzima:\n\n'
            '• **Mawasiliano 1 (Kabla ya wiki 12):** Usajili, vipimo vya damu na mkojo, kadi ya kliniki, kuanza IFAS.\n'
            '• **Mawasiliano 2 (Wiki ya 20):** Ultrasound ya anatomy, kupima shinikizo la damu na ukuaji wa tumbo.\n'
            '• **Mawasiliano 3 (Wiki ya 26):** Dawa ya kuzuia malaria (IPTp/Fansidar) na chanjo ya pepopunda (Tetanus).\n'
            '• **Mawasiliano 4 (Wiki ya 30):** Kupima damu tena (HB), kufuatilia presha na uzito.\n'
            '• **Mawasiliano 5, 6, 7, 8 (Wiki 34, 36, 38, 40):** Maandalizi ya kujifungua salama na mpango wa dharura.\n\n'
            'Chini ya Linda Mama, huduma zote za kliniki na uzazi ni **bila malipo** katika hospitali zote za umma na za kidini zilizoidhinishwa!';
      } else {
        return '🏥 **Linda Mama & Kenya MoH 8 ANC Contact Schedule:**\n\n'
            'Under Kenya MoH guidelines, every expectant mother should complete at least **8 ANC contacts** for safe pregnancy:\n\n'
            '• **Contact 1 (< 12 weeks):** Booking visit, baseline blood/urine screening, IFAS supplements, Mother-Child booklet.\n'
            '• **Contact 2 (Week 20):** Ultrasound screening, blood pressure monitoring, symphysis-fundal height.\n'
            '• **Contact 3 (Week 26):** Malaria prevention (IPTp-SP) and Tetanus toxoid immunization.\n'
            '• **Contact 4 (Week 30):** Repeat hemoglobin test and pre-eclampsia screening.\n'
            '• **Contacts 5, 6, 7, 8 (Weeks 34, 36, 38, 40):** Individualized birth preparedness and complication readiness.\n\n'
            'Under Linda Mama / SHA, routine ANC and delivery services are **free of charge** in accredited public and mission health facilities across Kenya!';
      }
    }

    // Backache / Body changes
    if (q.contains('back') ||
        q.contains('pain') ||
        q.contains('mgongo') ||
        q.contains('maumivu')) {
      if (isSwahili) {
        return 'Maumivu madogo ya mgongo katika wiki ya $week ni ya kawaida kwa sababu ya uzito wa tumbo na mabadiliko ya homoni za ujauzito (relaxin).\n\n'
            '🌿 **Vidokezo vya Kupunguza Maumivu:**\n'
            '• Vaa viatu bapa (flat shoes) vyenye staha; epuka viatu virefu.\n'
            '• Unapolala, lala upande wa kushoto na uweke mto kati ya magoti yako na chini ya tumbo.\n'
            '• Unapoinua vitu, pinda magoti badala ya kuinama kwa mgongo.\n'
            '• Omba mwenzi au familia wakufanyie masaji laini mgongoni.\n\n'
            '⚠️ *Ikiwa maumivu ni makali sana, yanakuja kwa vipindi kama uchungu wa uzazi, au yanaambatana na damu au maji, fika hospitali mara moja.*';
      } else {
        return 'Mild lower back soreness at week $week is very common as your center of gravity shifts and pregnancy hormones loosen pelvic joints.\n\n'
            '🌿 **Gentle Comfort Measures:**\n'
            '• Wear supportive flat footwear; avoid high heels.\n'
            '• Sleep on your left side with a supportive pillow between your knees and under your bump.\n'
            '• When lifting objects, bend at your knees rather than at your lower spine.\n'
            '• Ask your partner or family member for a gentle lower back massage.\n\n'
            '⚠️ *If back pain becomes rhythmic like contractions, severe, or is accompanied by fluid or bleeding, please visit your maternity clinic right away.*';
      }
    }

    // Default supportive maternal response
    if (isSwahili) {
      return 'Habari mama! Uko katika wiki ya $week ya safari yako ya ujauzito.\n\n'
          'Mtoto wako anaendelea kukua na kuimarika. Kumbuka kumeza vidonge vya IFAS kila siku, kunywa maji safi ya kutosha, kula mboga za kienyeji zenye madini ya chuma, na kulala upande wa kushoto.\n\n'
          'Una swali lolote leo kuhusu:\n'
          '• 🚨 Alama 4 kuu za hatari (Damu, Kichwa & Kiza, Mtoto kutocheza, Maji kuvuja)\n'
          '• 🥗 Vyakula vya asili vya Kenya na lishe bora\n'
          '• 👶 Mienendo na kuhesabu mateke ya mtoto\n'
          '• 🏥 Ratiba ya kliniki ya ANC na Linda Mama?';
    } else {
      return 'Hello mama! You are currently in week $week of your maternal journey.\n\n'
          'Your baby is growing and thriving. Remember to take your daily IFAS iron/folate supplements, drink plenty of safe water, enjoy nutritious traditional greens, and rest comfortably on your left side.\n\n'
          'Do you have any questions today regarding:\n'
          '• 🚨 The 4 primary danger signs (Bleeding, Headache/Vision, Baby kicks, Water breaking)\n'
          '• 🥗 Kenyan maternal nutrition & iron-rich greens\n'
          '• 👶 Tracking fetal movements & kick counts\n'
          '• 🏥 ANC contact schedules and Linda Mama benefits?';
    }
  }

  List<String> _getSuggestedFollowUps(String text, bool isSwahili) {
    final t = text.toLowerCase();
    if (t.contains('food') || t.contains('chakula') || t.contains('lishe')) {
      return isSwahili
          ? ['Jinsi ya kumeza vidonge vya IFAS', 'Vyakula vya kuongeza damu', 'Uliza kuhusu dalili za hatari']
          : ['How to take IFAS supplements', 'Foods that prevent anemia', 'Ask about danger signs'];
    }
    if (t.contains('kick') || t.contains('mateke') || t.contains('move')) {
      return isSwahili
          ? ['Kipimo cha mateke 10 tumboni', 'Mtoto asipocheza nifanye nini?', 'Vituo vya afya karibu nami']
          : ['The 10-kick count rule', 'What if baby stops moving?', 'Find clinics near me'];
    }
    if (isSwahili) {
      return [
        '🚨 Alama 4 za hatari',
        '🥗 Vyakula vyenye madini ya chuma',
        '👶 Jinsi ya kuhesabu mateke',
        '🏥 Ratiba ya kliniki ya ANC',
      ];
    } else {
      return [
        '🚨 4 Primary danger signs',
        '🥗 Iron-rich traditional greens',
        '👶 How to count baby kicks',
        '🏥 8 ANC clinic schedule',
      ];
    }
  }
}
