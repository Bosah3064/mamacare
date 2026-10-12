// ============================================
// MamaCare KE - Domain Models
// ============================================
// Dart data classes mirroring the PostgreSQL
// schema. Uses freezed-style immutability.
// ============================================

import 'package:equatable/equatable.dart';

// ---- Utility Types ----

typedef JsonMap = Map<String, dynamic>;

enum Language { en, sw }

enum UserRole { user, contentReviewer, healthReviewer, administrator }

// ---- User Profile ----

class UserProfile extends Equatable {
  final String id;
  final String authId;
  final String firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final Language preferredLanguage;
  final String? countyId;
  final String? subCountyId;
  final String? avatarUrl;
  final UserRole role;
  final bool onboardingCompleted;
  final bool demoMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const UserProfile({
    required this.id,
    required this.authId,
    required this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.preferredLanguage = Language.en,
    this.countyId,
    this.subCountyId,
    this.avatarUrl,
    this.role = UserRole.user,
    this.onboardingCompleted = false,
    this.demoMode = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String get fullName => [firstName, lastName].where((n) => n != null && n.isNotEmpty).join(' ');

  factory UserProfile.fromJson(JsonMap json) {
    return UserProfile(
      id: json['id'] as String,
      authId: json['auth_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      preferredLanguage: json['preferred_language'] == 'sw' ? Language.sw : Language.en,
      countyId: json['county_id'] as String?,
      subCountyId: json['sub_county_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == (json['role'] as String? ?? 'user'),
        orElse: () => UserRole.user,
      ),
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      demoMode: json['demo_mode'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  JsonMap toJson() => {
    'id': id,
    'auth_id': authId,
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'email': email,
    'preferred_language': preferredLanguage == Language.sw ? 'sw' : 'en',
    'county_id': countyId,
    'sub_county_id': subCountyId,
    'avatar_url': avatarUrl,
    'role': role.name,
    'onboarding_completed': onboardingCompleted,
    'demo_mode': demoMode,
  };

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    Language? preferredLanguage,
    String? countyId,
    String? subCountyId,
    String? avatarUrl,
    bool? onboardingCompleted,
    bool? demoMode,
  }) {
    return UserProfile(
      id: id,
      authId: authId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      countyId: countyId ?? this.countyId,
      subCountyId: subCountyId ?? this.subCountyId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      demoMode: demoMode ?? this.demoMode,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, authId, firstName, lastName, email, phone];
}

// ---- Pregnancy ----

enum PregnancyStatus { active, completed, loss, inactive }

enum GravityType { primigravida, multigravida }

class PregnancyProfile extends Equatable {
  final String id;
  final String userId;
  final PregnancyStatus status;
  final DateTime estimatedDueDate;
  final DateTime? lastMenstrualPeriod;
  final GravityType gravityType;
  final int previousPregnancies;
  final int previousBirths;
  final String? previousComplications;
  final String? preferredFacilityId;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const PregnancyProfile({
    required this.id,
    required this.userId,
    this.status = PregnancyStatus.active,
    required this.estimatedDueDate,
    this.lastMenstrualPeriod,
    this.gravityType = GravityType.primigravida,
    this.previousPregnancies = 0,
    this.previousBirths = 0,
    this.previousComplications,
    this.preferredFacilityId,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Calculate current pregnancy week based on EDD.
  int get currentWeek {
    final now = DateTime.now();
    final gestationalAge = estimatedDueDate.difference(now).inDays;
    final weeksRemaining = (gestationalAge / 7).ceil();
    return (40 - weeksRemaining).clamp(1, 42);
  }

  /// Current trimester.
  int get trimester {
    final week = currentWeek;
    if (week <= 12) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  /// Days remaining until due date.
  int get daysRemaining {
    final days = estimatedDueDate.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Progress percentage (0-100).
  double get progressPercent {
    return ((currentWeek / 40) * 100).clamp(0, 100);
  }

  factory PregnancyProfile.fromJson(JsonMap json) {
    return PregnancyProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: PregnancyStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'active'),
        orElse: () => PregnancyStatus.active,
      ),
      estimatedDueDate: DateTime.parse(json['estimated_due_date'] as String),
      lastMenstrualPeriod: json['last_menstrual_period'] != null
          ? DateTime.parse(json['last_menstrual_period'] as String)
          : null,
      gravityType: json['gravity_type'] == 'multigravida'
          ? GravityType.multigravida
          : GravityType.primigravida,
      previousPregnancies: json['previous_pregnancies'] as int? ?? 0,
      previousBirths: json['previous_births'] as int? ?? 0,
      previousComplications: json['previous_complications'] as String?,
      preferredFacilityId: json['preferred_facility_id'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  JsonMap toJson() => {
    'id': id,
    'user_id': userId,
    'status': status.name,
    'estimated_due_date': estimatedDueDate.toIso8601String().split('T').first,
    'last_menstrual_period': lastMenstrualPeriod?.toIso8601String().split('T').first,
    'gravity_type': gravityType.name,
    'previous_pregnancies': previousPregnancies,
    'previous_births': previousBirths,
    'previous_complications': previousComplications,
    'preferred_facility_id': preferredFacilityId,
    'notes': notes,
    'is_active': isActive,
  };

  PregnancyProfile copyWith({
    PregnancyStatus? status,
    DateTime? estimatedDueDate,
    DateTime? lastMenstrualPeriod,
    GravityType? gravityType,
    int? previousPregnancies,
    int? previousBirths,
    String? previousComplications,
    String? preferredFacilityId,
    String? notes,
    bool? isActive,
  }) {
    return PregnancyProfile(
      id: id,
      userId: userId,
      status: status ?? this.status,
      estimatedDueDate: estimatedDueDate ?? this.estimatedDueDate,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      gravityType: gravityType ?? this.gravityType,
      previousPregnancies: previousPregnancies ?? this.previousPregnancies,
      previousBirths: previousBirths ?? this.previousBirths,
      previousComplications: previousComplications ?? this.previousComplications,
      preferredFacilityId: preferredFacilityId ?? this.preferredFacilityId,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, status, estimatedDueDate];
}

// ---- Health Entries ----

enum HealthEntryType { symptom, bloodPressure, weight, temperature, mood, medication, note, fetalMovement, other }

enum SymptomSeverity { mild, moderate, severe }

enum MoodLevel { veryLow, low, neutral, good, great }

class HealthEntry extends Equatable {
  final String id;
  final String userId;
  final String pregnancyId;
  final HealthEntryType entryType;
  final DateTime recordedAt;
  final String? notes;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const HealthEntry({
    required this.id,
    required this.userId,
    required this.pregnancyId,
    required this.entryType,
    required this.recordedAt,
    this.notes,
    this.synced = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory HealthEntry.fromJson(JsonMap json) => HealthEntry(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    pregnancyId: json['pregnancy_id'] as String,
    entryType: HealthEntryType.values.firstWhere(
      (e) => e.name == _snakeToCamel(json['entry_type'] as String),
      orElse: () => HealthEntryType.other,
    ),
    recordedAt: DateTime.parse(json['recorded_at'] as String),
    notes: json['notes'] as String?,
    synced: json['synced'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
  );

  JsonMap toJson() => {
    'id': id,
    'user_id': userId,
    'pregnancy_id': pregnancyId,
    'entry_type': _camelToSnake(entryType.name),
    'recorded_at': recordedAt.toIso8601String(),
    'notes': notes,
    'synced': synced,
  };

  @override
  List<Object?> get props => [id, userId, pregnancyId, entryType, recordedAt];
}

class SymptomEntry extends Equatable {
  final String id;
  final String healthEntryId;
  final String userId;
  final String symptomName;
  final SymptomSeverity severity;
  final String? duration;
  final String? location;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SymptomEntry({
    required this.id,
    required this.healthEntryId,
    required this.userId,
    required this.symptomName,
    required this.severity,
    this.duration,
    this.location,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SymptomEntry.fromJson(JsonMap json) => SymptomEntry(
    id: json['id'] as String,
    healthEntryId: json['health_entry_id'] as String,
    userId: json['user_id'] as String,
    symptomName: json['symptom_name'] as String,
    severity: SymptomSeverity.values.firstWhere(
      (s) => s.name == json['severity'],
      orElse: () => SymptomSeverity.mild,
    ),
    duration: json['duration'] as String?,
    location: json['location'] as String?,
    description: json['description'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  JsonMap toJson() => {
    'id': id,
    'health_entry_id': healthEntryId,
    'user_id': userId,
    'symptom_name': symptomName,
    'severity': severity.name,
    'duration': duration,
    'location': location,
    'description': description,
  };

  @override
  List<Object?> get props => [id, healthEntryId, symptomName, severity];
}

class BloodPressureEntry extends Equatable {
  final String id;
  final String healthEntryId;
  final String userId;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? position;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BloodPressureEntry({
    required this.id,
    required this.healthEntryId,
    required this.userId,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.position,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BloodPressureEntry.fromJson(JsonMap json) => BloodPressureEntry(
    id: json['id'] as String,
    healthEntryId: json['health_entry_id'] as String,
    userId: json['user_id'] as String,
    systolic: json['systolic'] as int,
    diastolic: json['diastolic'] as int,
    pulse: json['pulse'] as int?,
    position: json['position'] as String?,
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  JsonMap toJson() => {
    'id': id,
    'health_entry_id': healthEntryId,
    'user_id': userId,
    'systolic': systolic,
    'diastolic': diastolic,
    'pulse': pulse,
    'position': position,
    'notes': notes,
  };

  @override
  List<Object?> get props => [id, systolic, diastolic];
}

class WeightEntry extends Equatable {
  final String id;
  final String healthEntryId;
  final String userId;
  final double weightKg;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeightEntry({
    required this.id,
    required this.healthEntryId,
    required this.userId,
    required this.weightKg,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeightEntry.fromJson(JsonMap json) => WeightEntry(
    id: json['id'] as String,
    healthEntryId: json['health_entry_id'] as String,
    userId: json['user_id'] as String,
    weightKg: (json['weight_kg'] as num).toDouble(),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  JsonMap toJson() => {
    'id': id,
    'health_entry_id': healthEntryId,
    'user_id': userId,
    'weight_kg': weightKg,
    'notes': notes,
  };

  @override
  List<Object?> get props => [id, weightKg];
}

// ---- ANC Appointments ----

enum AppointmentStatus { scheduled, completed, missed, rescheduled, cancelled }

enum AppointmentType { routine, followUp, ultrasound, labTest, specialist, emergency, other }

class Appointment extends Equatable {
  final String id;
  final String userId;
  final String pregnancyId;
  final String? facilityId;
  final DateTime appointmentDate;
  final AppointmentType appointmentType;
  final AppointmentStatus status;
  final String title;
  final String? notes;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final DateTime? followUpDate;
  final DateTime? completedAt;
  final String? completedNotes;
  final String? testsConducted;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Appointment({
    required this.id,
    required this.userId,
    required this.pregnancyId,
    this.facilityId,
    required this.appointmentDate,
    this.appointmentType = AppointmentType.routine,
    this.status = AppointmentStatus.scheduled,
    required this.title,
    this.notes,
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 1440, // 24 hours
    this.followUpDate,
    this.completedAt,
    this.completedNotes,
    this.testsConducted,
    this.synced = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isUpcoming =>
      status == AppointmentStatus.scheduled &&
      appointmentDate.isAfter(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  factory Appointment.fromJson(JsonMap json) => Appointment(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    pregnancyId: json['pregnancy_id'] as String,
    facilityId: json['facility_id'] as String?,
    appointmentDate: DateTime.parse(json['appointment_date'] as String),
    appointmentType: AppointmentType.values.firstWhere(
      (t) => t.name == _snakeToCamel(json['appointment_type'] as String),
      orElse: () => AppointmentType.other,
    ),
    status: AppointmentStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => AppointmentStatus.scheduled,
    ),
    title: json['title'] as String,
    notes: json['notes'] as String?,
    reminderEnabled: json['reminder_enabled'] as bool? ?? true,
    reminderMinutesBefore: json['reminder_minutes_before'] as int? ?? 1440,
    followUpDate: json['follow_up_date'] != null
        ? DateTime.parse(json['follow_up_date'] as String)
        : null,
    completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'] as String)
        : null,
    completedNotes: json['completed_notes'] as String?,
    testsConducted: json['tests_conducted'] as String?,
    synced: json['synced'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
  );

  JsonMap toJson() => {
    'id': id,
    'user_id': userId,
    'pregnancy_id': pregnancyId,
    'facility_id': facilityId,
    'appointment_date': appointmentDate.toIso8601String(),
    'appointment_type': _camelToSnake(appointmentType.name),
    'status': status.name,
    'title': title,
    'notes': notes,
    'reminder_enabled': reminderEnabled,
    'reminder_minutes_before': reminderMinutesBefore,
    'follow_up_date': followUpDate?.toIso8601String().split('T').first,
    'completed_at': completedAt?.toIso8601String(),
    'completed_notes': completedNotes,
    'tests_conducted': testsConducted,
    'synced': synced,
  };

  @override
  List<Object?> get props => [id, userId, appointmentDate, status];
}

// ---- Healthcare Facilities (Kenya) ----

enum FacilityType { hospital, healthCentre, clinic, maternity, dispensary, other }

enum FacilityOwnership { publicOwned, privateOwned, faithBased, ngo, other }

class County extends Equatable {
  final String id;
  final int code;
  final String name;
  final String nameSw;

  const County({
    required this.id,
    required this.code,
    required this.name,
    required this.nameSw,
  });

  factory County.fromJson(JsonMap json) => County(
    id: json['id'] as String,
    code: json['code'] as int,
    name: json['name'] as String,
    nameSw: json['name_sw'] as String,
  );

  JsonMap toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'name_sw': nameSw,
  };

  @override
  List<Object?> get props => [id, code, name];
}

class SubCounty extends Equatable {
  final String id;
  final String countyId;
  final String name;
  final String nameSw;

  const SubCounty({
    required this.id,
    required this.countyId,
    required this.name,
    required this.nameSw,
  });

  factory SubCounty.fromJson(JsonMap json) => SubCounty(
    id: json['id'] as String,
    countyId: json['county_id'] as String,
    name: json['name'] as String,
    nameSw: json['name_sw'] as String,
  );

  @override
  List<Object?> get props => [id, countyId, name];
}

class HealthcareFacility extends Equatable {
  final String id;
  final String name;
  final String countyId;
  final String? subCountyId;
  final FacilityType facilityType;
  final FacilityOwnership ownership;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? description;
  final bool isEmergencyAvailable;
  final bool isMaternityAvailable;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? sourceReference;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const HealthcareFacility({
    required this.id,
    required this.name,
    required this.countyId,
    this.subCountyId,
    required this.facilityType,
    this.ownership = FacilityOwnership.publicOwned,
    this.latitude,
    this.longitude,
    this.address,
    this.description,
    this.isEmergencyAvailable = false,
    this.isMaternityAvailable = false,
    this.isVerified = false,
    this.verifiedAt,
    this.sourceReference,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory HealthcareFacility.fromJson(JsonMap json) => HealthcareFacility(
    id: json['id'] as String,
    name: json['name'] as String,
    countyId: json['county_id'] as String,
    subCountyId: json['sub_county_id'] as String?,
    facilityType: FacilityType.values.firstWhere(
      (t) => t.name == _snakeToCamel(json['facility_type'] as String),
      orElse: () => FacilityType.other,
    ),
    ownership: _parseOwnership(json['ownership'] as String? ?? 'public'),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    address: json['address'] as String?,
    description: json['description'] as String?,
    isEmergencyAvailable: json['is_emergency_available'] as bool? ?? false,
    isMaternityAvailable: json['is_maternity_available'] as bool? ?? false,
    isVerified: json['is_verified'] as bool? ?? false,
    verifiedAt: json['verified_at'] != null
        ? DateTime.parse(json['verified_at'] as String)
        : null,
    sourceReference: json['source_reference'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
  );

  JsonMap toJson() => {
    'name': name,
    'county_id': countyId,
    'sub_county_id': subCountyId,
    'facility_type': _camelToSnake(facilityType.name),
    'ownership': _ownershipToDb(ownership),
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'description': description,
    'is_emergency_available': isEmergencyAvailable,
    'is_maternity_available': isMaternityAvailable,
    'is_verified': isVerified,
    'source_reference': sourceReference,
  };

  @override
  List<Object?> get props => [id, name, countyId, facilityType];
}

// ---- AI ----

enum AIRiskLevel { low, moderate, high, emergency }

class AIConversation extends Equatable {
  final String id;
  final String userId;
  final String? pregnancyId;
  final String? title;
  final Language language;
  final bool isActive;
  final int messageCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const AIConversation({
    required this.id,
    required this.userId,
    this.pregnancyId,
    this.title,
    this.language = Language.en,
    this.isActive = true,
    this.messageCount = 0,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AIConversation.fromJson(JsonMap json) => AIConversation(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    pregnancyId: json['pregnancy_id'] as String?,
    title: json['title'] as String?,
    language: json['language'] == 'sw' ? Language.sw : Language.en,
    isActive: json['is_active'] as bool? ?? true,
    messageCount: json['message_count'] as int? ?? 0,
    lastMessageAt: json['last_message_at'] != null
        ? DateTime.parse(json['last_message_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
  );

  @override
  List<Object?> get props => [id, userId, isActive];
}

class AIMessage extends Equatable {
  final String id;
  final String conversationId;
  final String userId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final AIRiskLevel? riskLevel;
  final List<String>? safetyFlags;
  final JsonMap? metadata;
  final int? tokensUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIMessage({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.role,
    required this.content,
    this.riskLevel,
    this.safetyFlags,
    this.metadata,
    this.tokensUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory AIMessage.fromJson(JsonMap json) => AIMessage(
    id: json['id'] as String,
    conversationId: json['conversation_id'] as String,
    userId: json['user_id'] as String,
    role: json['role'] as String,
    content: json['content'] as String,
    riskLevel: json['risk_level'] != null
        ? AIRiskLevel.values.firstWhere(
            (r) => r.name == json['risk_level'],
            orElse: () => AIRiskLevel.low,
          )
        : null,
    safetyFlags: (json['safety_flags'] as List<dynamic>?)?.cast<String>(),
    metadata: json['metadata'] as JsonMap?,
    tokensUsed: json['tokens_used'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  JsonMap toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'user_id': userId,
    'role': role,
    'content': content,
    'risk_level': riskLevel?.name,
    'safety_flags': safetyFlags,
    'metadata': metadata,
    'tokens_used': tokensUsed,
  };

  @override
  List<Object?> get props => [id, conversationId, role, content];
}

// ---- Emergency Contact ----

class EmergencyContact extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;
  final bool notifyOnEmergency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.relationship,
    this.isPrimary = false,
    this.notifyOnEmergency = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory EmergencyContact.fromJson(JsonMap json) => EmergencyContact(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    relationship: json['relationship'] as String,
    isPrimary: json['is_primary'] as bool? ?? false,
    notifyOnEmergency: json['notify_on_emergency'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
  );

  JsonMap toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'phone': phone,
    'relationship': relationship,
    'is_primary': isPrimary,
    'notify_on_emergency': notifyOnEmergency,
  };

  @override
  List<Object?> get props => [id, userId, name, phone];
}

// ---- Family Sharing ----

enum FamilyConnectionStatus { pending, active, revoked, expired }

enum FamilyPermissionType {
  pregnancyProgress,
  ancAppointments,
  reminders,
  emergencyInfo,
  healthSummary,
}

class FamilyConnection extends Equatable {
  final String id;
  final String userId;
  final String? familyMemberId;
  final String familyMemberName;
  final String? familyMemberPhone;
  final String? familyMemberEmail;
  final String relationship;
  final FamilyConnectionStatus status;
  final String? inviteToken;
  final DateTime? inviteExpiresAt;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyConnection({
    required this.id,
    required this.userId,
    this.familyMemberId,
    required this.familyMemberName,
    this.familyMemberPhone,
    this.familyMemberEmail,
    required this.relationship,
    this.status = FamilyConnectionStatus.pending,
    this.inviteToken,
    this.inviteExpiresAt,
    this.acceptedAt,
    this.revokedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyConnection.fromJson(JsonMap json) => FamilyConnection(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    familyMemberId: json['family_member_id'] as String?,
    familyMemberName: json['family_member_name'] as String,
    familyMemberPhone: json['family_member_phone'] as String?,
    familyMemberEmail: json['family_member_email'] as String?,
    relationship: json['relationship'] as String,
    status: FamilyConnectionStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => FamilyConnectionStatus.pending,
    ),
    inviteToken: json['invite_token'] as String?,
    inviteExpiresAt: json['invite_expires_at'] != null
        ? DateTime.parse(json['invite_expires_at'] as String)
        : null,
    acceptedAt: json['accepted_at'] != null
        ? DateTime.parse(json['accepted_at'] as String)
        : null,
    revokedAt: json['revoked_at'] != null
        ? DateTime.parse(json['revoked_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  JsonMap toJson() => {
    'id': id,
    'user_id': userId,
    'family_member_id': familyMemberId,
    'family_member_name': familyMemberName,
    'family_member_phone': familyMemberPhone,
    'family_member_email': familyMemberEmail,
    'relationship': relationship,
    'status': status.name,
    'invite_token': inviteToken,
    'invite_expires_at': inviteExpiresAt?.toIso8601String(),
    'accepted_at': acceptedAt?.toIso8601String(),
    'revoked_at': revokedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, userId, familyMemberId, status];
}

// ---- Pregnancy Week Content ----

class PregnancyWeek extends Equatable {
  final String id;
  final int weekNumber;
  final int trimester;
  final String babyDevelopmentEn;
  final String babyDevelopmentSw;
  final String maternalChangesEn;
  final String maternalChangesSw;
  final String tipsEn;
  final String tipsSw;
  final String? ancRecommendationsEn;
  final String? ancRecommendationsSw;
  final String? warningSignsEn;
  final String? warningSignsSw;
  final String? imageUrl;
  final bool published;

  const PregnancyWeek({
    required this.id,
    required this.weekNumber,
    required this.trimester,
    required this.babyDevelopmentEn,
    required this.babyDevelopmentSw,
    required this.maternalChangesEn,
    required this.maternalChangesSw,
    required this.tipsEn,
    required this.tipsSw,
    this.ancRecommendationsEn,
    this.ancRecommendationsSw,
    this.warningSignsEn,
    this.warningSignsSw,
    this.imageUrl,
    this.published = true,
  });

  factory PregnancyWeek.fromJson(JsonMap json) => PregnancyWeek(
    id: json['id'] as String,
    weekNumber: json['week_number'] as int,
    trimester: json['trimester'] as int,
    babyDevelopmentEn: json['baby_development_en'] as String,
    babyDevelopmentSw: json['baby_development_sw'] as String,
    maternalChangesEn: json['maternal_changes_en'] as String,
    maternalChangesSw: json['maternal_changes_sw'] as String,
    tipsEn: json['tips_en'] as String,
    tipsSw: json['tips_sw'] as String,
    ancRecommendationsEn: json['anc_recommendations_en'] as String?,
    ancRecommendationsSw: json['anc_recommendations_sw'] as String?,
    warningSignsEn: json['warning_signs_en'] as String?,
    warningSignsSw: json['warning_signs_sw'] as String?,
    imageUrl: json['image_url'] as String?,
    published: json['published'] as bool? ?? true,
  );

  @override
  List<Object?> get props => [id, weekNumber];
}

// ---- Helpers ----

String _snakeToCamel(String snake) {
  final parts = snake.split('_');
  return parts.first + parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join('');
}

String _camelToSnake(String camel) {
  return camel.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
}

FacilityOwnership _parseOwnership(String value) {
  switch (value) {
    case 'public': return FacilityOwnership.publicOwned;
    case 'private': return FacilityOwnership.privateOwned;
    case 'faith_based': return FacilityOwnership.faithBased;
    case 'ngo': return FacilityOwnership.ngo;
    default: return FacilityOwnership.other;
  }
}

String _ownershipToDb(FacilityOwnership ownership) {
  switch (ownership) {
    case FacilityOwnership.publicOwned: return 'public';
    case FacilityOwnership.privateOwned: return 'private';
    case FacilityOwnership.faithBased: return 'faith_based';
    case FacilityOwnership.ngo: return 'ngo';
    case FacilityOwnership.other: return 'other';
  }
}
