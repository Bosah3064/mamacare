// ============================================
// MamaCare KE - Facility & Emergency Service
// ============================================
// Kenyan Health Facilities directory & emergency
// hotlines across counties (Levels 2 - 6).
// Linda Mama accredited facilities & 24/7 care.
// ============================================

import 'dart:math';

class EmergencyContactInfo {
  final String name;
  final String phoneNumber;
  final String descriptionEn;
  final String descriptionSw;
  final bool isTollFree;
  final bool is24Hours;

  const EmergencyContactInfo({
    required this.name,
    required this.phoneNumber,
    required this.descriptionEn,
    required this.descriptionSw,
    this.isTollFree = true,
    this.is24Hours = true,
  });
}

class KenyanFacility {
  final String id;
  final String name;
  final String county;
  final String subCounty;
  final int
  level; // 2: Dispensary, 3: Health Centre, 4: Sub-County Hospital, 5: County Referral, 6: National
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String address;
  final bool has24HrMaternity;
  final bool isLindaMamaAccredited;
  final bool hasAmbulance;
  final bool hasNicu;
  final bool hasBloodBank;

  const KenyanFacility({
    required this.id,
    required this.name,
    required this.county,
    required this.subCounty,
    required this.level,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.address,
    this.has24HrMaternity = true,
    this.isLindaMamaAccredited = true,
    this.hasAmbulance = false,
    this.hasNicu = false,
    this.hasBloodBank = false,
  });

  factory KenyanFacility.fromJson(Map<String, dynamic> json) {
    final rawCounty = json['county'] as String? ?? json['county_id'] as String? ?? 'Nairobi';
    final countyName = rawCounty.isNotEmpty
        ? rawCounty
            .split('_')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ')
        : 'Kenya';

    return KenyanFacility(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Healthcare Facility',
      county: countyName,
      subCounty: json['sub_county'] as String? ?? json['sub_county_id'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 4,
      latitude: (json['latitude'] as num?)?.toDouble() ?? -1.2828,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 36.8442,
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String? ?? '+2541199',
      address: json['address'] as String? ?? 'Kenya',
      has24HrMaternity: json['is_maternity_available'] as bool? ?? json['has24HrMaternity'] as bool? ?? true,
      isLindaMamaAccredited: json['is_linda_mama_accredited'] as bool? ?? json['isLindaMamaAccredited'] as bool? ?? true,
      hasAmbulance: json['has_ambulance'] as bool? ?? json['hasAmbulance'] as bool? ?? false,
      hasNicu: json['has_nicu'] as bool? ?? json['hasNicu'] as bool? ?? false,
      hasBloodBank: json['has_blood_bank'] as bool? ?? json['hasBloodBank'] as bool? ?? false,
    );
  }

  String get levelLabel => 'Level $level Facility';

  double distanceToKm(double userLat, double userLng) {
    const double earthRadiusKm = 6371.0;
    final dLat = (latitude - userLat) * (pi / 180.0);
    final dLng = (longitude - userLng) * (pi / 180.0);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(userLat * (pi / 180.0)) *
            cos(latitude * (pi / 180.0)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }
}

class FacilityService {
  FacilityService._();
  static final FacilityService instance = FacilityService._();

  List<KenyanFacility> _databaseFacilities = [];

  void setDatabaseFacilities(List<KenyanFacility> list) {
    if (list.isNotEmpty) {
      _databaseFacilities = list;
    }
  }

  List<KenyanFacility> get allFacilities {
    if (_databaseFacilities.isNotEmpty) {
      return _databaseFacilities;
    }
    return curatedFacilities;
  }

  /// Official Kenyan Emergency Hotlines
  static const List<EmergencyContactInfo> emergencyHotlines = [
    EmergencyContactInfo(
      name: 'Kenya Red Cross Emergency Ambulance',
      phoneNumber: '1199',
      descriptionEn: '24/7 Nationwide Rapid Response & Maternal Emergency',
      descriptionSw: 'Huduma ya Dharura ya Ambulensi ya Msalaba Mwekundu 24/7',
      isTollFree: true,
      is24Hours: true,
    ),
    EmergencyContactInfo(
      name: 'National Police & Emergency Line',
      phoneNumber: '999',
      descriptionEn: 'Emergency Response / Security & Rescue',
      descriptionSw: 'Huduma ya Dharura ya Kitaifa ya Polisi na Uokoaji',
      isTollFree: true,
      is24Hours: true,
    ),
    EmergencyContactInfo(
      name: 'Kenya Emergency Hotline (Alternative)',
      phoneNumber: '112',
      descriptionEn: 'Mobile Emergency Assistance Toll-Free',
      descriptionSw: 'Huduma ya Dharura ya Simu Bila Malipo',
      isTollFree: true,
      is24Hours: true,
    ),
    EmergencyContactInfo(
      name: 'St. John Ambulance Kenya',
      phoneNumber: '0721225285',
      descriptionEn: 'Emergency Ambulance & First Aid Support',
      descriptionSw: 'Huduma ya Ambulensi ya Mtakatifu Yohana',
      isTollFree: false,
      is24Hours: true,
    ),
    EmergencyContactInfo(
      name: 'National Gender-Based Violence Helpline',
      phoneNumber: '1195',
      descriptionEn: 'Support for GBV, psycho-social, and safety distress',
      descriptionSw: 'Msaada wa Dhuluma za Kijinsia na Ushauri Nasaha',
      isTollFree: true,
      is24Hours: true,
    ),
  ];

  /// Curated list of Kenyan Maternity & Referral Facilities across counties
  static const List<KenyanFacility> curatedFacilities = [
    // Level 6 - National
    KenyanFacility(
      id: 'knh_nairobi',
      name: 'Kenyatta National Hospital (KNH)',
      county: 'Nairobi',
      subCounty: 'Kibra / Upper Hill',
      level: 6,
      latitude: -1.3015,
      longitude: 36.8073,
      phoneNumber: '+254202726300',
      address: 'Hospital Road, Upper Hill, Nairobi',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'ku_trh_nairobi',
      name: 'Kenyatta University Teaching & Referral Hospital (KUTRRH)',
      county: 'Nairobi / Kiambu',
      subCounty: 'Ruiru / Roysambu',
      level: 6,
      latitude: -1.1802,
      longitude: 36.9312,
      phoneNumber: '+254800721038',
      address: 'Northern Bypass Rd, Kahawa West, Nairobi',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'mtrh_eldoret',
      name: 'Moi Teaching and Referral Hospital (MTRH)',
      county: 'Uasin Gishu',
      subCounty: 'Eldoret Town',
      level: 6,
      latitude: 0.5143,
      longitude: 35.2698,
      phoneNumber: '+254532033471',
      address: 'Nandi Road, Eldoret',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),

    // Level 5 - County Referral
    KenyanFacility(
      id: 'pumwani_maternity',
      name: 'Pumwani Maternity Hospital',
      county: 'Nairobi',
      subCounty: 'Kamukunji',
      level: 5,
      latitude: -1.2789,
      longitude: 36.8486,
      phoneNumber: '+254202422731',
      address: 'General Waruinge St, Pumwani, Nairobi',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'mbagathi_hospital',
      name: 'Mbagathi County Referral Hospital',
      county: 'Nairobi',
      subCounty: 'Kibra',
      level: 5,
      latitude: -1.3117,
      longitude: 36.7932,
      phoneNumber: '+254722880000',
      address: 'Mbagathi Way, Nairobi',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'mama_lucy_kibaki',
      name: 'Mama Lucy Kibaki Hospital',
      county: 'Nairobi',
      subCounty: 'Embakasi Central',
      level: 5,
      latitude: -1.2828,
      longitude: 36.9023,
      phoneNumber: '+254722000000',
      address: 'Kangundo Road, Kayole, Nairobi',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'coast_general_hospital',
      name: 'Coast General Teaching & Referral Hospital (CGTRH)',
      county: 'Mombasa',
      subCounty: 'Mvita',
      level: 5,
      latitude: -4.0435,
      longitude: 39.6682,
      phoneNumber: '+254412314204',
      address: 'Kisauni Rd, Mombasa',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'jaramogi_oginga_odinga_hospital',
      name: 'Jaramogi Oginga Odinga Teaching & Referral Hospital (JOOTRH)',
      county: 'Kisumu',
      subCounty: 'Kisumu Central',
      level: 5,
      latitude: -0.0917,
      longitude: 34.7679,
      phoneNumber: '+254572020801',
      address: 'Kakamega Road, Kisumu',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'nakuru_level_5',
      name: 'Nakuru Level 5 County Referral Hospital',
      county: 'Nakuru',
      subCounty: 'Nakuru Town East',
      level: 5,
      latitude: -0.2827,
      longitude: 36.0711,
      phoneNumber: '+254512215500',
      address: 'Showground Rd, Nakuru',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'kiambu_level_5',
      name: 'Kiambu Level 5 County Referral Hospital',
      county: 'Kiambu',
      subCounty: 'Kiambu Town',
      level: 5,
      latitude: -1.1714,
      longitude: 36.8356,
      phoneNumber: '+254662022022',
      address: 'Kiambu Road, Kiambu',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'machakos_level_5',
      name: 'Machakos Level 5 Hospital',
      county: 'Machakos',
      subCounty: 'Machakos Central',
      level: 5,
      latitude: -1.5177,
      longitude: 37.2634,
      phoneNumber: '+254442021000',
      address: 'Hospital Rd, Machakos',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'kakamega_level_5',
      name: 'Kakamega County General Teaching & Referral Hospital',
      county: 'Kakamega',
      subCounty: 'Lurambi',
      level: 5,
      latitude: 0.2827,
      longitude: 34.7519,
      phoneNumber: '+254562030000',
      address: 'Kisumu-Kakamega Rd, Kakamega',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),

    // Level 4 - Sub-County
    KenyanFacility(
      id: 'thika_level_5',
      name: 'Thika Level 5 Sub-County Referral Hospital',
      county: 'Kiambu',
      subCounty: 'Thika Town',
      level: 5,
      latitude: -1.0396,
      longitude: 37.0693,
      phoneNumber: '+25467222000',
      address: 'General Kago Rd, Thika',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: true,
      hasNicu: true,
      hasBloodBank: true,
    ),
    KenyanFacility(
      id: 'westlands_health_centre',
      name: 'Westlands Health Centre',
      county: 'Nairobi',
      subCounty: 'Westlands',
      level: 3,
      latitude: -1.2635,
      longitude: 36.8041,
      phoneNumber: '+254204443120',
      address: 'Waiyaki Way, Westlands, Nairobi',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: false,
      hasNicu: false,
      hasBloodBank: false,
    ),
    KenyanFacility(
      id: 'langata_health_centre',
      name: 'Lang\'ata Health Centre',
      county: 'Nairobi',
      subCounty: 'Lang\'ata',
      level: 3,
      latitude: -1.3324,
      longitude: 36.7588,
      phoneNumber: '+254208901234',
      address: 'Langata Rd, Nairobi',
      has24HrMaternity: true,
      isLindaMamaAccredited: true,
      hasAmbulance: false,
      hasNicu: false,
      hasBloodBank: false,
    ),
  ];

  /// Find facilities near given coordinates sorted by distance
  List<KenyanFacility> getFacilitiesNear({
    required double latitude,
    required double longitude,
    String? countyFilter,
    int? minLevel,
    bool onlyLindaMama = false,
  }) {
    var list = allFacilities.where((f) {
      if (countyFilter != null && countyFilter.isNotEmpty) {
        if (!f.county.toLowerCase().contains(countyFilter.toLowerCase())) {
          return false;
        }
      }
      if (minLevel != null && f.level < minLevel) {
        return false;
      }
      if (onlyLindaMama && !f.isLindaMamaAccredited) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      final distA = a.distanceToKm(latitude, longitude);
      final distB = b.distanceToKm(latitude, longitude);
      return distA.compareTo(distB);
    });

    return list;
  }

  /// Get list of counties
  List<String> getCounties() {
    final counties = allFacilities.map((f) => f.county).toSet().toList();
    counties.sort();
    return counties;
  }
}
