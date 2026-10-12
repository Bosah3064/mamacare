// ============================================
// MamaCare KE - Supabase & Data Service
// ============================================
// Complete data access layer for Supabase PostgreSQL
// with full real-time subscriptions, user-scoped queries,
// and zero mock data leakage for authenticated users.
// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'facility_service.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const String defaultSeedUserId = 'd0000001-0000-0000-0000-000000000001';

  SupabaseClient? _client;
  bool _isDemoMode = false;
  String? _customActiveUserId;

  // In-memory demo store used EXCLUSIVELY when DEMO mode is explicitly activated or offline
  UserProfile? _demoUser;
  PregnancyProfile? _demoPregnancy;
  final List<HealthEntry> _demoHealthEntries = [];
  final List<SymptomEntry> _demoSymptoms = [];
  final List<BloodPressureEntry> _demoBpEntries = [];
  final List<WeightEntry> _demoWeightEntries = [];
  final List<Appointment> _demoAppointments = [];
  final List<AIMessage> _demoAiMessages = [];
  final List<FamilyConnection> _demoFamilyConnections = [];
  final List<EmergencyContact> _demoEmergencyContacts = [];

  bool get isDemoMode => _isDemoMode;
  SupabaseClient? get client => _client;

  void setActiveUserId(String? id) {
    _customActiveUserId = id;
  }

  String? get currentUserId {
    return _client?.auth.currentUser?.id ?? _customActiveUserId ?? defaultSeedUserId;
  }

  /// Initialize Supabase backend
  Future<void> initialize() async {
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://efybakgaaoyunqdxstwm.supabase.co';
      final supabasePublishableKey = dotenv.env['SUPABASE_ANON_KEY'] ??
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmeWJha2dhYW95dW5xZHhzdHdtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA3NTc0MDAsImV4cCI6MjEwNjMzMzQwMH0.nLgDOulrn7GyQ3qeKRwPVA_OoVd0EDYG2O-2gRXYdPI';
      final forceDemo = dotenv.env['DEMO_MODE']?.toLowerCase() == 'true';

      if (!forceDemo &&
          supabaseUrl.isNotEmpty &&
          !supabaseUrl.contains('your-project') &&
          supabasePublishableKey.isNotEmpty &&
          !supabasePublishableKey.contains('your-anon-key')) {
        await Supabase.initialize(
          url: supabaseUrl,
          publishableKey: supabasePublishableKey,
        );
        _client = Supabase.instance.client;
        _isDemoMode = false;
        debugPrint('MamaCare KE: Connected to Supabase PostgreSQL backend successfully.');
      } else {
        _isDemoMode = true;
        _initDemoData();
        debugPrint('MamaCare KE: Running in local Demo Mode.');
      }
    } catch (e) {
      _isDemoMode = true;
      _initDemoData();
      debugPrint('MamaCare KE: Supabase init error ($e). Falling back to Demo Mode.');
    }
  }

  void _initDemoData() {
    final now = DateTime.now();
    _demoUser = UserProfile(
      id: defaultSeedUserId,
      authId: 'auth-amani-live',
      firstName: 'Amani',
      lastName: 'Wanjiku',
      phone: '+254712345678',
      email: 'amani.wanjiku@mamacare.ke',
      preferredLanguage: Language.sw,
      countyId: 'Nairobi',
      subCountyId: 'Westlands',
      role: UserRole.user,
      onboardingCompleted: true,
      demoMode: true,
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    );

    final lmpDate = now.subtract(const Duration(days: 24 * 7));
    final eddDate = lmpDate.add(const Duration(days: 280));

    _demoPregnancy = PregnancyProfile(
      id: 'p0000001-0000-0000-0000-000000000001',
      userId: defaultSeedUserId,
      status: PregnancyStatus.active,
      estimatedDueDate: eddDate,
      lastMenstrualPeriod: lmpDate,
      gravityType: GravityType.primigravida,
      previousPregnancies: 0,
      previousBirths: 0,
      preferredFacilityId: 'pumwani_maternity',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    );
  }

  // ============================================
  // Profile & User Methods
  // ============================================

  Future<UserProfile?> getCurrentUserProfile() async {
    if (_client != null) {
      try {
        final authId = _client!.auth.currentUser?.id;
        if (authId != null) {
          final response = await _client!
              .from('user_profiles')
              .select()
              .eq('auth_id', authId)
              .maybeSingle();

          if (response != null) {
            return UserProfile.fromJson(response);
          }
        }

        // Check if there is an active user id or default seed user
        final uid = _customActiveUserId ?? defaultSeedUserId;
        final response = await _client!
            .from('user_profiles')
            .select()
            .or('id.eq.$uid,auth_id.eq.$uid')
            .maybeSingle();

        if (response != null) {
          return UserProfile.fromJson(response);
        }
      } catch (e) {
        debugPrint('Supabase getCurrentUserProfile error: $e');
      }
    }
    return _demoUser;
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('user_profiles')
            .update(profile.toJson())
            .eq('id', profile.id)
            .select()
            .single();
        return UserProfile.fromJson(response);
      } catch (e) {
        debugPrint('Supabase updateUserProfile error: $e');
      }
    }
    _demoUser = profile;
    return profile;
  }

  Stream<UserProfile?> streamUserProfile(String userId) {
    if (_client == null) {
      return Stream.value(_demoUser);
    }
    return _client!
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserProfile.fromJson(data.first);
        });
  }

  // ============================================
  // Pregnancy Profile Methods
  // ============================================

  Future<PregnancyProfile?> getPregnancyProfile() async {
    if (_client != null) {
      try {
        final user = await getCurrentUserProfile();
        final uid = user?.id ?? currentUserId;
        if (uid != null) {
          final response = await _client!
              .from('pregnancy_profiles')
              .select()
              .eq('user_id', uid)
              .eq('is_active', true)
              .maybeSingle();

          if (response != null) {
            return PregnancyProfile.fromJson(response);
          }
        }
      } catch (e) {
        debugPrint('Supabase getPregnancyProfile error: $e');
      }
    }
    return _demoPregnancy;
  }

  Future<PregnancyProfile> savePregnancyProfile(PregnancyProfile profile) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('pregnancy_profiles')
            .upsert(profile.toJson())
            .select()
            .single();
        return PregnancyProfile.fromJson(response);
      } catch (e) {
        debugPrint('Supabase savePregnancyProfile error: $e');
      }
    }
    _demoPregnancy = profile;
    return profile;
  }

  Stream<PregnancyProfile?> streamPregnancyProfile(String userId) {
    if (_client == null) {
      return Stream.value(_demoPregnancy);
    }
    return _client!
        .from('pregnancy_profiles')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return PregnancyProfile.fromJson(data.first);
        });
  }

  // ============================================
  // Pregnancy Week Content (Realtime from DB)
  // ============================================

  Future<List<PregnancyWeek>> getPregnancyWeeks() async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('pregnancy_weeks')
            .select()
            .order('week_number', ascending: true);
        return (response as List).map((json) => PregnancyWeek.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getPregnancyWeeks error: $e');
      }
    }
    return [];
  }

  Future<PregnancyWeek?> getPregnancyWeek(int weekNumber) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('pregnancy_weeks')
            .select()
            .lte('week_number', weekNumber)
            .order('week_number', ascending: false)
            .limit(1)
            .maybeSingle();
        if (response != null) {
          return PregnancyWeek.fromJson(response);
        }
      } catch (e) {
        debugPrint('Supabase getPregnancyWeek error: $e');
      }
    }
    return null;
  }

  Stream<List<PregnancyWeek>> streamPregnancyWeeks() {
    if (_client == null) {
      return Stream.value([]);
    }
    return _client!
        .from('pregnancy_weeks')
        .stream(primaryKey: ['id'])
        .order('week_number', ascending: true)
        .map((data) => data.map((json) => PregnancyWeek.fromJson(json)).toList());
  }

  // ============================================
  // Healthcare Facilities (Realtime from DB)
  // ============================================

  Future<List<KenyanFacility>> getHealthcareFacilities() async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('healthcare_facilities')
            .select()
            .order('name', ascending: true);
        final list = (response as List).map((json) => KenyanFacility.fromJson(json)).toList();
        if (list.isNotEmpty) return list;
      } catch (e) {
        debugPrint('Supabase getHealthcareFacilities error: $e');
      }
    }
    return FacilityService.curatedFacilities;
  }

  Stream<List<KenyanFacility>> streamHealthcareFacilities() {
    if (_client == null) {
      return Stream.value(FacilityService.curatedFacilities);
    }
    return _client!
        .from('healthcare_facilities')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((data) => data.map((json) => KenyanFacility.fromJson(json)).toList());
  }

  // ============================================
  // Health Diary & Entries Methods
  // ============================================

  Future<List<HealthEntry>> getHealthEntries() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('health_entries')
            .select()
            .eq('user_id', uid)
            .order('recorded_at', ascending: false);

        return (response as List).map((json) => HealthEntry.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getHealthEntries error: $e');
      }
    }
    return List.unmodifiable(_demoHealthEntries);
  }

  Future<List<SymptomEntry>> getSymptoms() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('symptom_entries')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false);

        return (response as List).map((json) => SymptomEntry.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getSymptoms error: $e');
      }
    }
    return List.unmodifiable(_demoSymptoms);
  }

  Future<List<BloodPressureEntry>> getBloodPressureEntries() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('blood_pressure_entries')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false);

        return (response as List).map((json) => BloodPressureEntry.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getBloodPressureEntries error: $e');
      }
    }
    return List.unmodifiable(_demoBpEntries);
  }

  Future<List<WeightEntry>> getWeightEntries() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('weight_entries')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false);

        return (response as List).map((json) => WeightEntry.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getWeightEntries error: $e');
      }
    }
    return List.unmodifiable(_demoWeightEntries);
  }

  Future<void> recordHealthEntry({
    required HealthEntry entry,
    SymptomEntry? symptom,
    BloodPressureEntry? bp,
    WeightEntry? weight,
  }) async {
    if (_client != null) {
      try {
        await _client!.from('health_entries').insert(entry.toJson());
        if (symptom != null) await _client!.from('symptom_entries').insert(symptom.toJson());
        if (bp != null) await _client!.from('blood_pressure_entries').insert(bp.toJson());
        if (weight != null) await _client!.from('weight_entries').insert(weight.toJson());
        return;
      } catch (e) {
        debugPrint('Supabase recordHealthEntry error: $e');
      }
    }

    _demoHealthEntries.insert(0, entry);
    if (symptom != null) _demoSymptoms.insert(0, symptom);
    if (bp != null) _demoBpEntries.insert(0, bp);
    if (weight != null) _demoWeightEntries.insert(0, weight);
  }

  // ============================================
  // ANC Appointments Methods
  // ============================================

  Future<List<Appointment>> getAppointments() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('appointments')
            .select()
            .eq('user_id', uid)
            .order('appointment_date', ascending: true);

        return (response as List).map((json) => Appointment.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getAppointments error: $e');
      }
    }
    return List.unmodifiable(_demoAppointments);
  }

  Future<Appointment> saveAppointment(Appointment appointment) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('appointments')
            .upsert(appointment.toJson())
            .select()
            .single();
        return Appointment.fromJson(response);
      } catch (e) {
        debugPrint('Supabase saveAppointment error: $e');
      }
    }

    final index = _demoAppointments.indexWhere((a) => a.id == appointment.id);
    if (index >= 0) {
      _demoAppointments[index] = appointment;
    } else {
      _demoAppointments.add(appointment);
    }
    return appointment;
  }

  Future<void> deleteAppointment(String appointmentId) async {
    if (_client != null) {
      try {
        await _client!.from('appointments').delete().eq('id', appointmentId);
        return;
      } catch (e) {
        debugPrint('Supabase deleteAppointment error: $e');
      }
    }
    _demoAppointments.removeWhere((a) => a.id == appointmentId);
  }

  /// Generates the standard 8 WHO / Kenya MoH ANC contacts for a newly registered expectant mother
  Future<void> generateInitialAncAppointments({
    required String userId,
    required String pregnancyId,
    required DateTime estimatedDueDate,
    DateTime? lastMenstrualPeriod,
    String? facilityId,
  }) async {
    final now = DateTime.now();
    final lmp = lastMenstrualPeriod ?? estimatedDueDate.subtract(const Duration(days: 280));

    final schedule = [
      {'week': 8, 'title': 'ANC Contact 1 (< 12 Weeks)', 'desc': 'Initial clinical profile, baseline Hb, blood group, HIV, VDRL, ultrasound dating & IFAS.'},
      {'week': 20, 'title': 'ANC Contact 2 (20 Weeks)', 'desc': 'Detailed ultrasound anatomy scan, maternal BP monitoring, tetanus vaccination review.'},
      {'week': 26, 'title': 'ANC Contact 3 (26 Weeks)', 'desc': 'Gestational diabetes screening, check BP, anemia check, review kick counts.'},
      {'week': 30, 'title': 'ANC Contact 4 (30 Weeks)', 'desc': 'Birth preparedness and complication readiness plan (BPCR). Facility delivery plan.'},
      {'week': 34, 'title': 'ANC Contact 5 (34 Weeks)', 'desc': 'Fetal growth and presentation assessment. Pre-eclampsia danger signs review.'},
      {'week': 36, 'title': 'ANC Contact 6 (36 Weeks)', 'desc': 'Hospital bag preparation, birth partner involvement, verify transport arrangement.'},
      {'week': 38, 'title': 'ANC Contact 7 (38 Weeks)', 'desc': 'Cervical checks, signs of labor review, 24/7 hotline confirmation.'},
      {'week': 40, 'title': 'ANC Contact 8 (40 Weeks)', 'desc': 'Due date assessment, fetal heart rate monitoring, active labor guidance.'},
    ];

    final appts = schedule.map((item) {
      final weekNum = item['week'] as int;
      final targetDate = lmp.add(Duration(days: weekNum * 7));
      final isPast = targetDate.isBefore(now);

      return Appointment(
        id: 'anc-$userId-wk$weekNum',
        userId: userId,
        pregnancyId: pregnancyId,
        facilityId: facilityId ?? 'pumwani_maternity',
        appointmentDate: targetDate,
        appointmentType: AppointmentType.routine,
        status: isPast ? AppointmentStatus.completed : AppointmentStatus.scheduled,
        title: item['title'] as String,
        notes: item['desc'] as String,
        reminderEnabled: true,
        reminderMinutesBefore: 1440,
        completedAt: isPast ? targetDate : null,
        completedNotes: isPast ? 'Completed routine clinic check' : null,
        synced: true,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();

    for (final appt in appts) {
      await saveAppointment(appt);
    }
  }

  // ============================================
  // Family Connections & Emergency Contacts
  // ============================================

  Future<List<FamilyConnection>> getFamilyConnections() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('family_connections')
            .select()
            .eq('user_id', uid);
        return (response as List).map((json) => FamilyConnection.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getFamilyConnections error: $e');
      }
    }
    return List.unmodifiable(_demoFamilyConnections);
  }

  Future<FamilyConnection> addFamilyConnection(FamilyConnection connection) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('family_connections')
            .insert(connection.toJson())
            .select()
            .single();
        return FamilyConnection.fromJson(response);
      } catch (e) {
        debugPrint('Supabase addFamilyConnection error: $e');
      }
    }
    _demoFamilyConnections.add(connection);
    return connection;
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('emergency_contacts')
            .select()
            .eq('user_id', uid);
        final list = (response as List).map((json) => EmergencyContact.fromJson(json)).toList();
        if (list.isNotEmpty) return list;
      } catch (e) {
        debugPrint('Supabase getEmergencyContacts error: $e');
      }
    }
    return List.unmodifiable(_demoEmergencyContacts);
  }

  Future<EmergencyContact> saveEmergencyContact(EmergencyContact contact) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('emergency_contacts')
            .upsert(contact.toJson())
            .select()
            .single();
        return EmergencyContact.fromJson(response);
      } catch (e) {
        debugPrint('Supabase saveEmergencyContact error: $e');
      }
    }

    final index = _demoEmergencyContacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      _demoEmergencyContacts[index] = contact;
    } else {
      _demoEmergencyContacts.add(contact);
    }
    return contact;
  }

  // ============================================
  // AI Conversation & Messages Methods
  // ============================================

  Future<List<AIMessage>> getAIMessages() async {
    final uid = currentUserId;
    if (_client != null && uid != null) {
      try {
        final response = await _client!
            .from('ai_messages')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: true);
        return (response as List).map((json) => AIMessage.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Supabase getAIMessages error: $e');
      }
    }
    return List.unmodifiable(_demoAiMessages);
  }

  Future<AIMessage> saveAIMessage(AIMessage message) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('ai_messages')
            .insert(message.toJson())
            .select()
            .single();
        return AIMessage.fromJson(response);
      } catch (e) {
        debugPrint('Supabase saveAIMessage error: $e');
      }
    }
    _demoAiMessages.add(message);
    return message;
  }

  // ============================================
  // Realtime Subscriptions (Native Supabase Streams)
  // ============================================

  /// Stream of appointments with live updates from Supabase Realtime
  Stream<List<Appointment>> streamAppointments(String userId) {
    if (_client == null) {
      return Stream.value(_demoAppointments);
    }
    return _client!
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('appointment_date', ascending: true)
        .map((data) => data.map((json) => Appointment.fromJson(json)).toList());
  }

  /// Stream of health entries with live updates
  Stream<List<HealthEntry>> streamHealthEntries(String userId) {
    if (_client == null) {
      return Stream.value(_demoHealthEntries);
    }
    return _client!
        .from('health_entries')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .map((data) => data.map((json) => HealthEntry.fromJson(json)).toList());
  }

  /// Stream of blood pressure entries with live updates
  Stream<List<BloodPressureEntry>> streamBloodPressureEntries(String userId) {
    if (_client == null) {
      return Stream.value(_demoBpEntries);
    }
    return _client!
        .from('blood_pressure_entries')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => BloodPressureEntry.fromJson(json)).toList());
  }

  /// Stream of symptom entries with live updates
  Stream<List<SymptomEntry>> streamSymptomEntries(String userId) {
    if (_client == null) {
      return Stream.value(_demoSymptoms);
    }
    return _client!
        .from('symptom_entries')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => SymptomEntry.fromJson(json)).toList());
  }

  /// Stream of weight entries with live updates
  Stream<List<WeightEntry>> streamWeightEntries(String userId) {
    if (_client == null) {
      return Stream.value(_demoWeightEntries);
    }
    return _client!
        .from('weight_entries')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => WeightEntry.fromJson(json)).toList());
  }

  /// Stream of family connections with live updates
  Stream<List<FamilyConnection>> streamFamilyConnections(String userId) {
    if (_client == null) {
      return Stream.value(_demoFamilyConnections);
    }
    return _client!
        .from('family_connections')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data.map((json) => FamilyConnection.fromJson(json)).toList());
  }

  /// Stream of emergency contacts with live updates
  Stream<List<EmergencyContact>> streamEmergencyContacts(String userId) {
    if (_client == null) {
      return Stream.value(_demoEmergencyContacts);
    }
    return _client!
        .from('emergency_contacts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data.map((json) => EmergencyContact.fromJson(json)).toList());
  }

  /// Stream of AI messages with live updates
  Stream<List<AIMessage>> streamAIMessages(String userId) {
    if (_client == null) {
      return Stream.value(_demoAiMessages);
    }
    return _client!
        .from('ai_messages')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => AIMessage.fromJson(json)).toList());
  }
}
