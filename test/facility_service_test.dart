// ============================================
// MamaCare KE - Facility & Emergency Service Test
// ============================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare_ke/core/services/facility_service.dart';

void main() {
  late FacilityService service;

  setUp(() {
    service = FacilityService.instance;
  });

  group('Kenyan Facilities Directory', () {
    test('provides curated Level 4-6 facilities across Kenya', () {
      expect(FacilityService.curatedFacilities.isNotEmpty, isTrue);
      expect(FacilityService.curatedFacilities.any((f) => f.name.contains('Kenyatta National Hospital')), isTrue);
      expect(FacilityService.curatedFacilities.any((f) => f.name.contains('Pumwani Maternity')), isTrue);
      expect(FacilityService.curatedFacilities.any((f) => f.name.contains('Moi Teaching')), isTrue);
      expect(FacilityService.curatedFacilities.any((f) => f.name.contains('Coast General')), isTrue);
    });

    test('calculates correct distance from Nairobi coordinates', () {
      // Nairobi City Center: -1.2921, 36.8219
      const userLat = -1.2921;
      const userLng = 36.8219;

      final nearby = service.getFacilitiesNear(
        latitude: userLat,
        longitude: userLng,
      );

      expect(nearby.isNotEmpty, isTrue);
      // Closest should be within 15 km in Nairobi
      final firstDist = nearby.first.distanceToKm(userLat, userLng);
      expect(firstDist, lessThan(15.0));

      // Results must be sorted by distance ascending
      for (int i = 0; i < nearby.length - 1; i++) {
        expect(
          nearby[i].distanceToKm(userLat, userLng),
          lessThanOrEqualTo(nearby[i + 1].distanceToKm(userLat, userLng)),
        );
      }
    });

    test('filters facilities by county', () {
      final coastal = service.getFacilitiesNear(
        latitude: -4.0435,
        longitude: 39.6682,
        countyFilter: 'Mombasa',
      );

      expect(coastal.isNotEmpty, isTrue);
      expect(coastal.every((f) => f.county.toLowerCase().contains('mombasa')), isTrue);
    });

    test('filters by Linda Mama accreditation', () {
      final lindaMamaOnly = service.getFacilitiesNear(
        latitude: -1.2921,
        longitude: 36.8219,
        onlyLindaMama: true,
      );

      expect(lindaMamaOnly.isNotEmpty, isTrue);
      expect(lindaMamaOnly.every((f) => f.isLindaMamaAccredited), isTrue);
    });
  });

  group('Official Emergency Hotlines', () {
    test('contains verified 24/7 Kenyan maternal emergency hotlines', () {
      final hotlines = FacilityService.emergencyHotlines;
      expect(hotlines.any((h) => h.phoneNumber == '1199' && h.name.contains('Red Cross')), isTrue);
      expect(hotlines.any((h) => h.phoneNumber == '999' || h.phoneNumber == '112'), isTrue);
      expect(hotlines.any((h) => h.phoneNumber == '1195' && h.name.contains('Gender-Based Violence')), isTrue);
    });
  });
}
