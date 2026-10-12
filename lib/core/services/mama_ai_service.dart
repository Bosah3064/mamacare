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

  /// Send message to Mama AI with full deterministic safety checks
  Future<MamaAiResponse> sendMessage({
    required String userText,
    required PregnancyProfile? pregnancyProfile,
    required Language language,
  }) async {
    final isSwahili = language == Language.sw;
    final now = DateTime.now();
    final userId = pregnancyProfile?.userId ?? _supabaseService.currentUserId ?? 'demo-user-amani';
    const conversationId = 'conv-default';

    // Save user's message
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

    // 1. Run deterministic safety evaluation BEFORE processing
    final safety = _safetyEngine.evaluate(userText);

    // If an emergency is detected, return immediate emergency guidance
    if (safety.isEmergency) {
      final emergencyText = isSwahili
          ? (safety.overrideEmergencyMessageSw ?? safety.recommendedActionSw)
          : (safety.overrideEmergencyMessageEn ?? safety.recommendedActionEn);

      final assistantMsg = AIMessage(
        id: _uuid.v4(),
        conversationId: conversationId,
        userId: userId,
        role: 'assistant',
        content: emergencyText,
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
            ? ['Piga 1199 (Bila Malipo)', 'Tafuta Hospitali ya Karibu', 'Mfahamishe Mume/Familia']
            : ['Call 1199 Emergency', 'Locate Nearest Hospital', 'Notify Emergency Contact'],
      );
    }

    // If urgent danger sign
    if (safety.isUrgent) {
      final urgentText = isSwahili
          ? '⚠️ TAHADHARI YA KIAFYA: ${safety.recommendedActionSw}\n\nDalili uliyoeleza inahitaji kufanyiwa uchunguzi na daktari au mkunga leo. Usisubiri kliniki yako ijayo ya kawaida.'
          : '⚠️ HEALTH ALERT: ${safety.recommendedActionEn}\n\nThe symptom you described should be checked by a healthcare provider or midwife today. Do not wait for your next routine ANC.';

      final assistantMsg = AIMessage(
        id: _uuid.v4(),
        conversationId: conversationId,
        userId: userId,
        role: 'assistant',
        content: urgentText,
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
            ? ['Vituo vya Afya Karibu Nami', 'Andika kwenye Shajara ya Afya', 'Mawaidha ya Lishe']
            : ['Clinics Near Me', 'Record in Health Diary', 'Nutrition Advice'],
      );
    }

    // Routine / Normal Maternal Guidance
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

    // Nutrition & food inquiries
    if (q.contains('food') || q.contains('eat') || q.contains('diet') ||
        q.contains('chakula') || q.contains('kula') || q.contains('lishe') || q.contains('mboga')) {
      if (isSwahili) {
        return 'Katika wiki ya $week, mtoto wako anakua kwa kasi na anahitaji virutubisho vya kutosha!\n\n'
            '🥗 **Vyakula Muhimu vya Kenya:**\n'
            '• **Mboga za Kienyeji:** Terere, managu, kunde, na sukuma wiki zina madini mengi ya chuma (iron) kuzuia upungufu wa damu.\n'
            '• **Protini:** Mayai ya kuchemsha, maziwa fresh, maharagwe, dengu, na samaki (kama omena au tilapiya).\n'
            '• **Wanga na Nishati:** Viazi vitamu, ndizi za kupika, ugali wa dona, na uji wa wimbi.\n'
            '• **Maji na Matunda:** Parachichi (avocado), maembe, machungwa (vitamini C husaidia kunyonya chuma), na kunywa angalau glasi 8 za maji safi kila siku.\n\n'
            'Kumbuka kuendelea kumeza vidonge vya IFAS (Iron & Folic Acid) kila siku baada ya chakula cha jioni!';
      } else {
        return 'At week $week, your baby is growing rapidly and needs balanced nourishment!\n\n'
            '🥗 **Recommended Kenyan Maternal Foods:**\n'
            '• **Traditional Greens:** Terere (amaranth), managu (African nightshade), kunde (cowpea leaves), and spinach for vital iron.\n'
            '• **Proteins:** Hard-boiled eggs, fresh pasteurized milk, beans, green grams (ndengu), and fish (omena or tilapia).\n'
            '• **Energy & Fiber:** Sweet potatoes, cooked green bananas (matoke), whole grain brown ugali, and millet/sorghum porridge (uji wa wimbi).\n'
            '• **Hydration & Fruits:** Avocado for healthy fats, oranges/mangoes (Vitamin C enhances iron absorption), and at least 8 glasses of safe water daily.\n\n'
            'Remember to take your daily IFAS (Iron and Folic Acid Supplements) with water after meals!';
      }
    }

    // Baby kicks & movement
    if (q.contains('kick') || q.contains('move') || q.contains('mateke') || q.contains('kucheza')) {
      if (isSwahili) {
        return 'Kuanzia wiki ya 24 hadi 28, mienendo ya mtoto huanza kuwa dhahiri zaidi!\n\n'
            '👶 **Mambo ya Kuzingatia:**\n'
            '• Watoto huwa na vipindi vya kulala (dakika 20-40) na vipindi vya kuwa macho.\n'
            '• Ukitaka kuhisi mtoto akicheza: Kula vitafunio vyepesi au glasi ya maji baridi, kisha ulale upande wa kushoto kwa utulivu.\n'
            '• Kuanzia wiki ya 28, unapaswa kuhisi angalau mienendo 10 ndani ya masaa 2 wakati mtoto yuko macho.\n\n'
            '⚠️ *Iwapo mtoto ataacha kucheza kabisa au mienendo itapungua sana ghafla, tafadhali nenda kituo cha afya mara moja.*';
      } else {
        return 'Around week $week, your baby\'s kicks, turns, and hiccups become noticeably stronger!\n\n'
            '👶 **Fetal Movement Guidelines:**\n'
            '• Babies develop sleep-wake cycles (typically resting for 20–40 minutes at a time).\n'
            '• To encourage movement: Have a light snack or cold glass of water, then rest quietly on your left side.\n'
            '• From 28 weeks onwards, aim to feel at least 10 kicks or movements within a 2-hour window during active times.\n\n'
            '⚠️ *If baby stops moving or kicks drop significantly, seek immediate clinical review at your maternity clinic.*';
      }
    }

    // Backache / Body changes
    if (q.contains('back') || q.contains('pain') || q.contains('mgongo') || q.contains('maumivu')) {
      if (isSwahili) {
        return 'Maumivu madogo ya mgongo katika wiki ya $week ni ya kawaida kwa sababu ya uzito wa tumbo na mabadiliko ya homoni za ujauzito (relaxin).\n\n'
            '🌿 **Vidokezo vya Kupunguza Maumivu:**\n'
            '• Vaa viatu bapa (flat shoes) vyenye staha; epuka viatu virefu (heels).\n'
            '• Unapolala, lala upande wa kushoto na uweke mto kati ya magoti yako na chini ya tumbo.\n'
            '• Unapoinua vitu, pinda magoti badala ya kuinama kwa mgongo.\n'
            '• Omba mwenzi au familia wakufanyie masaji laini mgongoni.\n\n'
            'Ikiwa maumivu ni makali sana, yanakuja kwa vipindi kama uchungu wa uzazi, au yanaambatana na damu, fika hospitali mara moja.';
      } else {
        return 'Mild lower back soreness at week $week is very common as your center of gravity shifts and relaxin hormone loosens your pelvis.\n\n'
            '🌿 **Gentle Comfort Measures:**\n'
            '• Wear supportive flat footwear; avoid high heels.\n'
            '• Sleep on your left side with a supportive pillow placed between your knees and under your bump.\n'
            '• When picking items up, bend at your knees rather than bending from your waist.\n'
            '• Ask your partner or family member for a gentle lower back massage.\n\n'
            'If the pain becomes rhythmic like contractions, severe, or is accompanied by fluid or bleeding, please visit your maternity clinic right away.';
      }
    }

    // Default supportive response
    if (isSwahili) {
      return 'Asante kwa kuwasiliana na MamaCare KE! Uko katika wiki ya $week ya safari yako ya baraka.\n\n'
          'Mtoto wako anaendelea kukua salama. Hakikisha unapata mapumziko ya kutosha, unakunywa maji safi, unakula vyakula vyenye madini ya chuma na mboga za asili, na kufuata ratiba yako ya kliniki ya ANC.\n\n'
          'Una swali mahususi kuhusu lishe, maandalizi ya uzazi (Linda Mama), au mienendo ya mtoto leo?';
    } else {
      return 'Thank you for reaching out to MamaCare KE! You are in week $week of your maternal journey.\n\n'
          'Your baby is growing and thriving. Remember to take your daily iron/folate supplements, stay well hydrated, rest whenever needed, and prepare questions for your next ANC visit.\n\n'
          'Do you have a specific question about nutrition, baby movements, or clinic preparations today?';
    }
  }

  List<String> _getSuggestedFollowUps(String text, bool isSwahili) {
    if (isSwahili) {
      return [
        'Vyakula vya kienyeji vyenye chuma',
        'Jinsi ya kuhesabu mateke ya mtoto',
        'Maandalizi ya kliniki ijayo ya ANC',
        'Nambari za dharura za uzazi',
      ];
    } else {
      return [
        'Traditional Kenyan foods high in iron',
        'How to do a fetal kick count',
        'Preparing for my next ANC contact',
        'Emergency maternal contacts',
      ];
    }
  }
}
