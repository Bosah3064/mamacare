// ============================================
// MamaCare KE - App State Providers
// ============================================
// Riverpod state management for user profile,
// pregnancy timeline, ANC visits, health diary,
// Mama AI chat, facilities, and localization.
// Full real-time subscription support via Supabase.
// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/ai_safety_engine.dart';
import '../services/facility_service.dart';
import '../services/mama_ai_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ============================================
// 1. Language & Localization Provider
// ============================================

class LanguageNotifier extends StateNotifier<Language> {
  LanguageNotifier() : super(Language.sw); // Default Swahili for Kenya

  void setLanguage(Language lang) => state = lang;
  void toggleLanguage() {
    state = state == Language.sw ? Language.en : Language.sw;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Language>((ref) {
  return LanguageNotifier();
});

// ============================================
// 2. User & Pregnancy Profile Providers (Realtime)
// ============================================

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.userProfile != null) {
    return authState.userProfile;
  }
  return SupabaseService.instance.getCurrentUserProfile();
});

class PregnancyProfileNotifier extends StateNotifier<AsyncValue<PregnancyProfile?>> {
  final Ref _ref;
  StreamSubscription<PregnancyProfile?>? _pregSub;

  PregnancyProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initStream();
  }

  void _initStream() {
    final auth = _ref.watch(authProvider);
    final uid = auth.userProfile?.id ?? auth.supabaseUser?.id ?? SupabaseService.instance.currentUserId;

    if (uid != null && uid.isNotEmpty) {
      _pregSub?.cancel();
      _pregSub = SupabaseService.instance.streamPregnancyProfile(uid).listen(
        (profile) {
          if (profile != null) {
            state = AsyncValue.data(profile);
          }
        },
        onError: (e, st) {
          debugPrint('Realtime pregnancy stream error: $e');
        },
      );
    }
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authProvider);
      if (auth.pregnancyProfile != null) {
        state = AsyncValue.data(auth.pregnancyProfile);
        return;
      }
      final profile = await SupabaseService.instance.getPregnancyProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(PregnancyProfile updated) async {
    try {
      final saved = await SupabaseService.instance.savePregnancyProfile(updated);
      state = AsyncValue.data(saved);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _pregSub?.cancel();
    super.dispose();
  }
}

final pregnancyProfileProvider =
    StateNotifierProvider<PregnancyProfileNotifier, AsyncValue<PregnancyProfile?>>((ref) {
  return PregnancyProfileNotifier(ref);
});

// ============================================
// 3. Pregnancy Weeks & Milestones (From DB)
// ============================================

final pregnancyWeeksStreamProvider = StreamProvider<List<PregnancyWeek>>((ref) {
  return SupabaseService.instance.streamPregnancyWeeks();
});

final activeMilestoneProvider = FutureProvider<PregnancyWeek?>((ref) async {
  final pregnancyAsync = ref.watch(pregnancyProfileProvider);
  final currentWeek = pregnancyAsync.value?.currentWeek ?? 24;
  return SupabaseService.instance.getPregnancyWeek(currentWeek);
});

// ============================================
// 4. ANC Appointments Provider (Realtime Stream)
// ============================================

class AppointmentsNotifier extends StateNotifier<AsyncValue<List<Appointment>>> {
  final Ref _ref;
  StreamSubscription<List<Appointment>>? _realtimeSub;

  AppointmentsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initStream();
  }

  void _initStream() {
    final auth = _ref.watch(authProvider);
    final uid = auth.userProfile?.id ?? auth.supabaseUser?.id ?? SupabaseService.instance.currentUserId;

    if (uid != null && uid.isNotEmpty) {
      _realtimeSub?.cancel();
      _realtimeSub = SupabaseService.instance.streamAppointments(uid).listen(
        (list) {
          state = AsyncValue.data(list);
        },
        onError: (e, st) {
          debugPrint('Realtime appointments stream error: $e');
          loadAppointments();
        },
      );
    } else {
      loadAppointments();
    }
  }

  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    try {
      final list = await SupabaseService.instance.getAppointments();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAppointment(Appointment appt) async {
    try {
      await SupabaseService.instance.saveAppointment(appt);
      await loadAppointments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markCompleted(String id, String notes) async {
    final current = state.value ?? [];
    final item = current.firstWhere((a) => a.id == id);
    final updated = Appointment(
      id: item.id,
      userId: item.userId,
      pregnancyId: item.pregnancyId,
      facilityId: item.facilityId,
      appointmentDate: item.appointmentDate,
      appointmentType: item.appointmentType,
      status: AppointmentStatus.completed,
      title: item.title,
      notes: item.notes,
      completedAt: DateTime.now(),
      completedNotes: notes,
      testsConducted: item.testsConducted,
      synced: item.synced,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
    );
    await SupabaseService.instance.saveAppointment(updated);
    await loadAppointments();
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, AsyncValue<List<Appointment>>>((ref) {
  return AppointmentsNotifier(ref);
});

// ============================================
// 5. Health Diary Provider (Realtime Stream)
// ============================================

class HealthDiaryState {
  final List<HealthEntry> entries;
  final List<SymptomEntry> symptoms;
  final List<BloodPressureEntry> bpEntries;
  final List<WeightEntry> weightEntries;
  final bool isLoading;

  const HealthDiaryState({
    this.entries = const [],
    this.symptoms = const [],
    this.bpEntries = const [],
    this.weightEntries = const [],
    this.isLoading = false,
  });

  HealthDiaryState copyWith({
    List<HealthEntry>? entries,
    List<SymptomEntry>? symptoms,
    List<BloodPressureEntry>? bpEntries,
    List<WeightEntry>? weightEntries,
    bool? isLoading,
  }) {
    return HealthDiaryState(
      entries: entries ?? this.entries,
      symptoms: symptoms ?? this.symptoms,
      bpEntries: bpEntries ?? this.bpEntries,
      weightEntries: weightEntries ?? this.weightEntries,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HealthDiaryNotifier extends StateNotifier<HealthDiaryState> {
  final Ref _ref;
  StreamSubscription<List<HealthEntry>>? _healthSub;
  StreamSubscription<List<BloodPressureEntry>>? _bpSub;
  StreamSubscription<List<SymptomEntry>>? _symSub;
  final _uuid = const Uuid();

  HealthDiaryNotifier(this._ref) : super(const HealthDiaryState(isLoading: true)) {
    _initStream();
  }

  void _initStream() {
    final auth = _ref.watch(authProvider);
    final uid = auth.userProfile?.id ?? auth.supabaseUser?.id ?? SupabaseService.instance.currentUserId;

    if (uid != null && uid.isNotEmpty) {
      _healthSub?.cancel();
      _healthSub = SupabaseService.instance.streamHealthEntries(uid).listen(
        (_) => loadAll(),
        onError: (err) => debugPrint('Realtime health entries error: $err'),
      );

      _bpSub?.cancel();
      _bpSub = SupabaseService.instance.streamBloodPressureEntries(uid).listen(
        (_) => loadAll(),
        onError: (err) => debugPrint('Realtime BP entries error: $err'),
      );

      _symSub?.cancel();
      _symSub = SupabaseService.instance.streamSymptomEntries(uid).listen(
        (_) => loadAll(),
        onError: (err) => debugPrint('Realtime symptom entries error: $err'),
      );
    }
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    final entries = await SupabaseService.instance.getHealthEntries();
    final symptoms = await SupabaseService.instance.getSymptoms();
    final bps = await SupabaseService.instance.getBloodPressureEntries();
    final wts = await SupabaseService.instance.getWeightEntries();

    state = HealthDiaryState(
      entries: entries,
      symptoms: symptoms,
      bpEntries: bps,
      weightEntries: wts,
      isLoading: false,
    );
  }

  Future<void> logHealthRecord({
    required String pregnancyId,
    required String userId,
    String? notes,
    int? systolic,
    int? diastolic,
    int? pulse,
    double? weightKg,
    String? symptomName,
    SymptomSeverity? severity,
  }) async {
    final now = DateTime.now();
    final entryId = _uuid.v4();

    final entry = HealthEntry(
      id: entryId,
      userId: userId,
      pregnancyId: pregnancyId,
      entryType: symptomName != null ? HealthEntryType.symptom : HealthEntryType.bloodPressure,
      recordedAt: now,
      notes: notes,
      synced: true,
      createdAt: now,
      updatedAt: now,
    );

    BloodPressureEntry? bpEntry;
    if (systolic != null && diastolic != null) {
      bpEntry = BloodPressureEntry(
        id: _uuid.v4(),
        healthEntryId: entryId,
        userId: userId,
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
        createdAt: now,
        updatedAt: now,
      );
    }

    WeightEntry? wtEntry;
    if (weightKg != null) {
      wtEntry = WeightEntry(
        id: _uuid.v4(),
        healthEntryId: entryId,
        userId: userId,
        weightKg: weightKg,
        createdAt: now,
        updatedAt: now,
      );
    }

    SymptomEntry? symEntry;
    if (symptomName != null) {
      symEntry = SymptomEntry(
        id: _uuid.v4(),
        healthEntryId: entryId,
        userId: userId,
        symptomName: symptomName,
        severity: severity ?? SymptomSeverity.mild,
        createdAt: now,
        updatedAt: now,
      );
    }

    await SupabaseService.instance.recordHealthEntry(
      entry: entry,
      symptom: symEntry,
      bp: bpEntry,
      weight: wtEntry,
    );

    await loadAll();
  }

  @override
  void dispose() {
    _healthSub?.cancel();
    _bpSub?.cancel();
    _symSub?.cancel();
    super.dispose();
  }
}

final healthDiaryProvider =
    StateNotifierProvider<HealthDiaryNotifier, HealthDiaryState>((ref) {
  return HealthDiaryNotifier(ref);
});

// ============================================
// 6. Mama AI Chat Provider (Realtime Stream)
// ============================================

class ChatState {
  final List<AIMessage> messages;
  final bool isSending;
  final SafetyAssessment? lastSafetyAssessment;
  final List<String> suggestions;

  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.lastSafetyAssessment,
    this.suggestions = const [],
  });

  ChatState copyWith({
    List<AIMessage>? messages,
    bool? isSending,
    SafetyAssessment? lastSafetyAssessment,
    List<String>? suggestions,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      lastSafetyAssessment: lastSafetyAssessment ?? this.lastSafetyAssessment,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref ref;
  StreamSubscription<List<AIMessage>>? _aiSub;

  ChatNotifier(this.ref) : super(const ChatState()) {
    _initStream();
  }

  void _initStream() {
    final auth = ref.watch(authProvider);
    final uid = auth.userProfile?.id ?? auth.supabaseUser?.id ?? SupabaseService.instance.currentUserId;

    if (uid != null && uid.isNotEmpty) {
      _aiSub?.cancel();
      _aiSub = SupabaseService.instance.streamAIMessages(uid).listen(
        (list) {
          state = state.copyWith(messages: list);
        },
        onError: (err) => debugPrint('Realtime AI stream error: $err'),
      );
    }
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    final history = await SupabaseService.instance.getAIMessages();
    state = state.copyWith(messages: history);
  }

  Future<MamaAiResponse> sendMessage(String text) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Message text cannot be empty');
    }

    state = state.copyWith(isSending: true);
    final language = ref.read(languageProvider);
    final pregnancy = ref.read(pregnancyProfileProvider).value;

    final response = await MamaAiService.instance.sendMessage(
      userText: text,
      pregnancyProfile: pregnancy,
      language: language,
    );

    final history = await SupabaseService.instance.getAIMessages();
    state = state.copyWith(
      messages: history,
      isSending: false,
      lastSafetyAssessment: response.safetyAssessment,
      suggestions: response.suggestedFollowUps,
    );

    return response;
  }

  @override
  void dispose() {
    _aiSub?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

// ============================================
// 7. Kenyan Facilities & Emergency Providers (Live DB)
// ============================================

final facilityServiceProvider = Provider<FacilityService>((ref) {
  return FacilityService.instance;
});

final emergencyHotlinesProvider = Provider<List<EmergencyContactInfo>>((ref) {
  return FacilityService.emergencyHotlines;
});

final liveFacilitiesStreamProvider = StreamProvider<List<KenyanFacility>>((ref) {
  return SupabaseService.instance.streamHealthcareFacilities();
});

class FacilityFilterState {
  final String searchQuery;
  final String? county;
  final int? minLevel;
  final bool onlyLindaMama;

  const FacilityFilterState({
    this.searchQuery = '',
    this.county,
    this.minLevel,
    this.onlyLindaMama = false,
  });

  FacilityFilterState copyWith({
    String? searchQuery,
    String? county,
    int? minLevel,
    bool? onlyLindaMama,
  }) {
    return FacilityFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      county: county ?? this.county,
      minLevel: minLevel ?? this.minLevel,
      onlyLindaMama: onlyLindaMama ?? this.onlyLindaMama,
    );
  }
}

class FacilityFilterNotifier extends StateNotifier<FacilityFilterState> {
  FacilityFilterNotifier() : super(const FacilityFilterState());

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);
  void setCounty(String? c) => state = state.copyWith(county: c);
  void setMinLevel(int? l) => state = state.copyWith(minLevel: l);
  void toggleLindaMama() => state = state.copyWith(onlyLindaMama: !state.onlyLindaMama);
}

final facilityFilterProvider =
    StateNotifierProvider<FacilityFilterNotifier, FacilityFilterState>((ref) {
  return FacilityFilterNotifier();
});

final filteredFacilitiesProvider = Provider<List<KenyanFacility>>((ref) {
  final filter = ref.watch(facilityFilterProvider);
  final liveFacilitiesAsync = ref.watch(liveFacilitiesStreamProvider);
  final service = ref.watch(facilityServiceProvider);

  // Sync real-time facilities loaded from database
  if (liveFacilitiesAsync.value != null && liveFacilitiesAsync.value!.isNotEmpty) {
    service.setDatabaseFacilities(liveFacilitiesAsync.value!);
  }

  // Default coordinates: Central Nairobi (-1.2921, 36.8219)
  const defaultLat = -1.2921;
  const defaultLng = 36.8219;

  var results = service.getFacilitiesNear(
    latitude: defaultLat,
    longitude: defaultLng,
    countyFilter: filter.county,
    minLevel: filter.minLevel,
    onlyLindaMama: filter.onlyLindaMama,
  );

  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    results = results.where((f) {
      return f.name.toLowerCase().contains(query) ||
          f.county.toLowerCase().contains(query) ||
          f.subCounty.toLowerCase().contains(query) ||
          f.address.toLowerCase().contains(query);
    }).toList();
  }

  return results;
});

// ============================================
// 8. Family Connections & Emergency Contacts (Realtime Streams)
// ============================================

final emergencyContactsProvider = StreamProvider<List<EmergencyContact>>((ref) {
  final auth = ref.watch(authProvider);
  final uid = auth.userProfile?.id ?? auth.supabaseUser?.id ?? SupabaseService.instance.currentUserId;
  if (uid != null && uid.isNotEmpty) {
    return SupabaseService.instance.streamEmergencyContacts(uid);
  }
  return Stream.fromFuture(SupabaseService.instance.getEmergencyContacts());
});

final familyConnectionsProvider = StreamProvider<List<FamilyConnection>>((ref) {
  final auth = ref.watch(authProvider);
  final uid = auth.userProfile?.id ?? auth.supabaseUser?.id ?? SupabaseService.instance.currentUserId;
  if (uid != null && uid.isNotEmpty) {
    return SupabaseService.instance.streamFamilyConnections(uid);
  }
  return Stream.fromFuture(SupabaseService.instance.getFamilyConnections());
});
