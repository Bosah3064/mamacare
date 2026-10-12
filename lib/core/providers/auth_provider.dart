// ============================================
// MamaCare KE - Authentication Provider
// ============================================
// Manages Supabase Auth state: login, signup,
// logout, session persistence, and onboarding.
// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// Auth state that drives the entire app routing
enum AuthStatus {
  unknown,        // Initial state, checking session
  unauthenticated, // No session — show welcome/login
  authenticated,   // Logged in but might not be onboarded
  onboarding,      // Logged in, needs pregnancy profile setup
}

class AuthState {
  final AuthStatus status;
  final User? supabaseUser;
  final UserProfile? userProfile;
  final PregnancyProfile? pregnancyProfile;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.supabaseUser,
    this.userProfile,
    this.pregnancyProfile,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? supabaseUser,
    UserProfile? userProfile,
    PregnancyProfile? pregnancyProfile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      supabaseUser: supabaseUser ?? this.supabaseUser,
      userProfile: userProfile ?? this.userProfile,
      pregnancyProfile: pregnancyProfile ?? this.pregnancyProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  StreamSubscription<AuthState>? _authSubscription;

  Future<void> _init() async {
    final service = SupabaseService.instance;

    // Listen to Supabase auth state changes
    final client = service.client;
    if (client != null) {
      client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        final session = data.session;

        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
          _loadUserData(session?.user);
        } else if (event == AuthChangeEvent.signedOut) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      });

      // Check existing session
      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        await _loadUserData(currentUser);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _loadUserData(User? user) async {
    if (user == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    SupabaseService.instance.setActiveUserId(user.id);
    state = state.copyWith(isLoading: true, supabaseUser: user);

    try {
      // Try to fetch user profile from Supabase
      final client = SupabaseService.instance.client!;
      final profileResponse = await client
          .from('user_profiles')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle();

      if (profileResponse == null) {
        // User exists in auth but no profile yet → onboarding
        state = AuthState(
          status: AuthStatus.onboarding,
          supabaseUser: user,
          isLoading: false,
        );
        return;
      }

      final userProfile = UserProfile.fromJson(profileResponse);

      // Check if pregnancy profile exists
      final pregResponse = await client
          .from('pregnancy_profiles')
          .select()
          .eq('user_id', userProfile.id)
          .eq('is_active', true)
          .maybeSingle();

      PregnancyProfile? pregnancyProfile;
      if (pregResponse != null) {
        pregnancyProfile = PregnancyProfile.fromJson(pregResponse);
      }

      if (!userProfile.onboardingCompleted || pregnancyProfile == null) {
        state = AuthState(
          status: AuthStatus.onboarding,
          supabaseUser: user,
          userProfile: userProfile,
          pregnancyProfile: pregnancyProfile,
          isLoading: false,
        );
      } else {
        state = AuthState(
          status: AuthStatus.authenticated,
          supabaseUser: user,
          userProfile: userProfile,
          pregnancyProfile: pregnancyProfile,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('MamaCare KE Auth: Error loading user data: $e');
      state = AuthState(
        status: AuthStatus.onboarding,
        supabaseUser: user,
        isLoading: false,
      );
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final client = SupabaseService.instance.client;
      if (client == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Service unavailable');
        return false;
      }

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName ?? '',
          'phone': phone ?? '',
        },
      );

      if (response.user != null) {
        // Create user profile in our table
        final now = DateTime.now();
        final profile = UserProfile(
          id: response.user!.id,
          authId: response.user!.id,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          email: email,
          preferredLanguage: Language.sw,
          role: UserRole.user,
          onboardingCompleted: false,
          demoMode: false,
          createdAt: now,
          updatedAt: now,
        );

        await client.from('user_profiles').upsert(profile.toJson());
        SupabaseService.instance.setActiveUserId(response.user!.id);

        state = AuthState(
          status: AuthStatus.onboarding,
          supabaseUser: response.user,
          userProfile: profile,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(isLoading: false, errorMessage: 'Sign up failed');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final client = SupabaseService.instance.client;
      if (client == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Service unavailable');
        return false;
      }

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserData(response.user);
        return true;
      }

      state = state.copyWith(isLoading: false, errorMessage: 'Login failed');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Complete onboarding: save pregnancy profile
  Future<bool> completeOnboarding({
    required DateTime estimatedDueDate,
    DateTime? lastMenstrualPeriod,
    GravityType gravityType = GravityType.primigravida,
    int previousPregnancies = 0,
    int previousBirths = 0,
    String? preferredFacilityId,
    Language preferredLanguage = Language.sw,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final client = SupabaseService.instance.client;
      if (client == null) return false;

      final userId = state.userProfile?.id ?? state.supabaseUser?.id ?? '';
      if (userId.isEmpty) return false;

      final now = DateTime.now();

      // Create pregnancy profile
      final pregnancy = PregnancyProfile(
        id: 'preg-${now.millisecondsSinceEpoch}',
        userId: userId,
        status: PregnancyStatus.active,
        estimatedDueDate: estimatedDueDate,
        lastMenstrualPeriod: lastMenstrualPeriod,
        gravityType: gravityType,
        previousPregnancies: previousPregnancies,
        previousBirths: previousBirths,
        preferredFacilityId: preferredFacilityId,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await client.from('pregnancy_profiles').insert(pregnancy.toJson());

      // Mark onboarding as complete
      await client
          .from('user_profiles')
          .update({
            'onboarding_completed': true,
            'preferred_language': preferredLanguage == Language.sw ? 'sw' : 'en',
            'updated_at': now.toIso8601String(),
          })
          .eq('id', userId);

      // Generate initial WHO / Kenya MoH ANC appointments in database
      try {
        await SupabaseService.instance.generateInitialAncAppointments(
          userId: userId,
          pregnancyId: pregnancy.id,
          estimatedDueDate: estimatedDueDate,
          lastMenstrualPeriod: lastMenstrualPeriod,
          facilityId: preferredFacilityId,
        );

        await client.from('emergency_contacts').upsert({
          'id': 'emg-$userId-1199',
          'user_id': userId,
          'name': 'Kenya Red Cross Emergency Ambulance',
          'phone': '1199',
          'relationship': 'Emergency Dispatch',
          'is_primary': true,
          'notify_on_emergency': true,
        });
      } catch (e) {
        debugPrint('MamaCare KE: Error generating clinical appointments: $e');
      }

      // Refresh user profile
      final profileResponse = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      final updatedProfile = UserProfile.fromJson(profileResponse);

      state = AuthState(
        status: AuthStatus.authenticated,
        supabaseUser: state.supabaseUser,
        userProfile: updatedProfile,
        pregnancyProfile: pregnancy,
        isLoading: false,
      );
      return true;
    } catch (e) {
      debugPrint('MamaCare KE: Onboarding error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await SupabaseService.instance.client?.auth.signOut();
    } catch (e) {
      debugPrint('MamaCare KE: Sign out error: $e');
    }
    SupabaseService.instance.setActiveUserId(null);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Reset password via email
  Future<bool> resetPassword(String email) async {
    try {
      final client = SupabaseService.instance.client;
      if (client == null) return false;
      await client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      debugPrint('MamaCare KE: Reset password error: $e');
      return false;
    }
  }

  /// Guest / Demo mode sign-in fetching directly from Supabase DB seed
  Future<void> signInAsDemo() async {
    state = state.copyWith(isLoading: true);
    final service = SupabaseService.instance;
    service.setActiveUserId(SupabaseService.defaultSeedUserId);

    try {
      final client = service.client;
      if (client != null) {
        final profileRes = await client
            .from('user_profiles')
            .select()
            .eq('id', SupabaseService.defaultSeedUserId)
            .maybeSingle();

        final pregRes = await client
            .from('pregnancy_profiles')
            .select()
            .eq('user_id', SupabaseService.defaultSeedUserId)
            .eq('is_active', true)
            .maybeSingle();

        if (profileRes != null && pregRes != null) {
          final profile = UserProfile.fromJson(profileRes);
          final preg = PregnancyProfile.fromJson(pregRes);
          state = AuthState(
            status: AuthStatus.authenticated,
            userProfile: profile,
            pregnancyProfile: preg,
            isLoading: false,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading demo user from Supabase: $e');
    }

    final now = DateTime.now();
    final lmp = now.subtract(const Duration(days: 24 * 7));
    final edd = lmp.add(const Duration(days: 280));

    final demoUser = UserProfile(
      id: SupabaseService.defaultSeedUserId,
      authId: 'auth-amani-live',
      firstName: 'Amani',
      lastName: 'Wanjiku',
      phone: '+254712345678',
      email: 'amani.wanjiku@mamacare.ke',
      preferredLanguage: Language.sw,
      role: UserRole.user,
      onboardingCompleted: true,
      demoMode: true,
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    );

    final demoPregnancy = PregnancyProfile(
      id: 'p0000001-0000-0000-0000-000000000001',
      userId: SupabaseService.defaultSeedUserId,
      status: PregnancyStatus.active,
      estimatedDueDate: edd,
      lastMenstrualPeriod: lmp,
      gravityType: GravityType.primigravida,
      previousPregnancies: 0,
      previousBirths: 0,
      preferredFacilityId: 'pumwani_maternity',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    );

    state = AuthState(
      status: AuthStatus.authenticated,
      userProfile: demoUser,
      pregnancyProfile: demoPregnancy,
      isLoading: false,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
