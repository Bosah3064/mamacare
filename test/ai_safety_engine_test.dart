// ============================================
// MamaCare KE - AI Safety Engine Test Suite
// ============================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare_ke/core/services/ai_safety_engine.dart';

void main() {
  late AiSafetyEngine engine;

  setUp(() {
    engine = AiSafetyEngine.instance;
  });

  group('Obstetric Danger Signs - English Detection', () {
    test('detects severe vaginal bleeding as emergency', () {
      final assessment = engine.evaluate('I am bleeding heavily from my vagina and feeling dizzy');
      expect(assessment.isEmergency, isTrue);
      expect(assessment.triageLevel, equals(TriageLevel.emergency));
      expect(assessment.triggeredRules.any((r) => r.id == 'vaginal_bleeding'), isTrue);
    });

    test('detects preeclampsia symptoms (severe headache + blurred vision) as urgent/emergency', () {
      final assessment = engine.evaluate('I have a severe headache and seeing spots and blurry vision');
      expect(assessment.isUrgent || assessment.isEmergency, isTrue);
      expect(assessment.triggeredRules.any((r) => r.id == 'severe_headache_visual'), isTrue);
    });

    test('detects reduced or absent fetal movement as urgent', () {
      final assessment = engine.evaluate('My baby has stopped kicking today, no movement for 6 hours');
      expect(assessment.isUrgent || assessment.isEmergency, isTrue);
      expect(assessment.triggeredRules.any((r) => r.id == 'reduced_fetal_movement'), isTrue);
    });

    test('detects broken waters / leaking fluid as urgent', () {
      final assessment = engine.evaluate('My water broke and there is leaking fluid from my vagina');
      expect(assessment.isUrgent || assessment.isEmergency, isTrue);
      expect(assessment.triggeredRules.any((r) => r.id == 'water_leaking'), isTrue);
    });
  });

  group('Obstetric Danger Signs - Kiswahili Detection', () {
    test('detects vaginal bleeding in Kiswahili (damu inatoka)', () {
      final assessment = engine.evaluate('Ninavuja damu nyingi sana ukeni tangu asubuhi');
      expect(assessment.isEmergency, isTrue);
      expect(assessment.triggeredRules.any((r) => r.id == 'vaginal_bleeding'), isTrue);
    });

    test('detects absence of baby movement in Kiswahili (mtoto hachezi)', () {
      final assessment = engine.evaluate('Mtoto hachezi kabisa tumboni leo, sijahisi mateke');
      expect(assessment.isUrgent || assessment.isEmergency, isTrue);
    });

    test('detects preeclampsia signs in Kiswahili (kichwa kinauma sana na kiza machoni)', () {
      final assessment = engine.evaluate('Kichwa kinauma sana na ninaona giza machoni');
      expect(assessment.isUrgent || assessment.isEmergency, isTrue);
      expect(assessment.triggeredRules.any((r) => r.id == 'severe_headache_visual'), isTrue);
    });

    test('detects rupture of membranes in Kiswahili (maji ya uzazi kuvuja)', () {
      final assessment = engine.evaluate('Maji ya uzazi yanavuja sana na chupa imepasuka');
      expect(assessment.isUrgent || assessment.isEmergency, isTrue);
      expect(assessment.triggeredRules.any((r) => r.id == 'water_leaking'), isTrue);
    });

    test('detects all 4 backbone danger signs verbatim in Kiswahili', () {
      final a1 = engine.evaluate('Kutokwa na damu ukeni');
      expect(a1.isEmergency, isTrue);
      expect(a1.triggeredRules.any((r) => r.id == 'vaginal_bleeding'), isTrue);

      final a2 = engine.evaluate('Kuumwa na kichwa na kiza machoni');
      expect(a2.isEmergency || a2.isUrgent, isTrue);
      expect(a2.triggeredRules.any((r) => r.id == 'severe_headache_visual'), isTrue);

      final a3 = engine.evaluate('Mtoto kutocheza tumboni');
      expect(a3.isEmergency || a3.isUrgent, isTrue);
      expect(a3.triggeredRules.any((r) => r.id == 'reduced_fetal_movement'), isTrue);

      final a4 = engine.evaluate('Maji ya uzazi kuvuja');
      expect(a4.isEmergency || a4.isUrgent, isTrue);
      expect(a4.triggeredRules.any((r) => r.id == 'water_leaking'), isTrue);
    });
  });

  group('Normal Pregnancy Queries (Safe)', () {
    test('classifies diet and food questions as low risk', () {
      final assessment = engine.evaluate('What healthy food should I eat in week 24? Can I eat managu and avocado?');
      expect(assessment.isEmergency, isFalse);
      expect(assessment.isUrgent, isFalse);
      expect(assessment.triageLevel, equals(TriageLevel.routine));
    });

    test('classifies routine morning sickness questions as low risk', () {
      final assessment = engine.evaluate('Habari ya asubuhi, nina kichefuchefu kidogo asubuhi, nifanye nini?');
      expect(assessment.isEmergency, isFalse);
      expect(assessment.isUrgent, isFalse);
    });
  });

  group('SafetyAssessment properties', () {
    test('hasDangerSigns is true when rules are triggered', () {
      final assessment = engine.evaluate('I am bleeding heavily');
      expect(assessment.hasDangerSigns, isTrue);
    });

    test('hasDangerSigns is false for routine queries', () {
      final assessment = engine.evaluate('How much water should I drink today?');
      expect(assessment.hasDangerSigns, isFalse);
    });

    test('emergency assessment is not safe for AI response', () {
      final assessment = engine.evaluate('I am having convulsions and seizures');
      expect(assessment.isEmergency, isTrue);
      expect(assessment.isSafeForAiResponse, isFalse);
      expect(assessment.requiresImmediateCall, isTrue);
    });

    test('routine assessment is safe for AI response', () {
      final assessment = engine.evaluate('What exercises can I do during pregnancy?');
      expect(assessment.isSafeForAiResponse, isTrue);
      expect(assessment.requiresImmediateCall, isFalse);
    });
  });
}
