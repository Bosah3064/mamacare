// ============================================
// MamaCare KE - Pregnancy Profile & Models Test
// ============================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare_ke/core/models/models.dart';

void main() {
  group('PregnancyProfile Calculations', () {
    test('calculates correct gestational week for 24 weeks pregnant', () {
      final now = DateTime.now();
      // EDD 112 days in future = 16 weeks remaining => 40 - 16 = 24 weeks
      final edd = now.add(const Duration(days: 112));
      final profile = PregnancyProfile(
        id: 'test-preg-1',
        userId: 'test-user-1',
        estimatedDueDate: edd,
        status: PregnancyStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      expect(profile.currentWeek, inInclusiveRange(23, 25));
      expect(profile.trimester, equals(2));
      expect(profile.daysRemaining, greaterThan(100));
      expect(profile.progressPercent, greaterThan(50));
    });

    test('calculates correct trimester 1 for early pregnancy', () {
      final now = DateTime.now();
      // EDD 250 days away => week ~4-6
      final edd = now.add(const Duration(days: 250));
      final profile = PregnancyProfile(
        id: 'test-preg-early',
        userId: 'test-user-1',
        estimatedDueDate: edd,
        status: PregnancyStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      expect(profile.trimester, equals(1));
    });

    test('calculates correct trimester 3 for late pregnancy', () {
      final now = DateTime.now();
      // EDD 28 days away => week 36
      final edd = now.add(const Duration(days: 28));
      final profile = PregnancyProfile(
        id: 'test-preg-late',
        userId: 'test-user-1',
        estimatedDueDate: edd,
        status: PregnancyStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      expect(profile.trimester, equals(3));
      expect(profile.currentWeek, inInclusiveRange(35, 37));
    });

    test('JSON serialization includes id and preserves all fields', () {
      final now = DateTime.now();
      final original = PregnancyProfile(
        id: 'test-id-123',
        userId: 'user-id-456',
        estimatedDueDate: DateTime(2027, 2, 15),
        status: PregnancyStatus.active,
        gravityType: GravityType.multigravida,
        previousPregnancies: 2,
        previousBirths: 2,
        notes: 'Clinical notes',
        createdAt: now,
        updatedAt: now,
      );

      final json = original.toJson();
      expect(json['id'], equals('test-id-123'));
      expect(json['user_id'], equals('user-id-456'));
      expect(json['status'], equals('active'));
      expect(json['gravity_type'], equals('multigravida'));
    });
  });

  group('Appointment Model', () {
    test('identifies upcoming vs completed appointment', () {
      final now = DateTime.now();
      final upcoming = Appointment(
        id: 'appt-1',
        userId: 'user-1',
        pregnancyId: 'preg-1',
        appointmentDate: now.add(const Duration(days: 14)),
        status: AppointmentStatus.scheduled,
        title: 'ANC Contact 3',
        createdAt: now,
        updatedAt: now,
      );

      expect(upcoming.isUpcoming, isTrue);

      final completed = Appointment(
        id: 'appt-2',
        userId: 'user-1',
        pregnancyId: 'preg-1',
        appointmentDate: now.subtract(const Duration(days: 14)),
        status: AppointmentStatus.completed,
        title: 'ANC Contact 1',
        createdAt: now,
        updatedAt: now,
      );

      expect(completed.isUpcoming, isFalse);
    });
  });
}
