// ============================================
// MamaCare KE - Maternal Intake Onboarding Screen
// ============================================
// Sets up the mother's pregnancy profile after signup:
// EDD / LMP, gestational age calculation, gravida/parity,
// and preferred delivery facility in Kenya.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  DateTime? _estimatedDueDate;
  DateTime? _lastMenstrualPeriod;
  GravityType _gravityType = GravityType.primigravida;
  int _previousPregnancies = 0;
  int _previousBirths = 0;
  String _preferredFacility = 'pumwani_maternity';
  Language _selectedLanguage = Language.sw;

  final List<Map<String, String>> _kenyaFacilities = const [
    {'id': 'pumwani_maternity', 'name': 'Pumwani Maternity Hospital (Nairobi)', 'level': 'Level 4 Specialized'},
    {'id': 'knh_nairobi', 'name': 'Kenyatta National Hospital (Nairobi)', 'level': 'Level 6 National Referral'},
    {'id': 'mtrh_eldoret', 'name': 'Moi Teaching & Referral Hospital (Eldoret)', 'level': 'Level 6 National Referral'},
    {'id': 'nakuru_level5', 'name': 'Nakuru Level 5 Hospital (Rift Valley)', 'level': 'Level 5 County Referral'},
    {'id': 'coast_general', 'name': 'Coast General Teaching & Referral (Mombasa)', 'level': 'Level 5 County Referral'},
    {'id': 'jaramogi_oginga', 'name': 'Jaramogi Oginga Odinga TRH (Kisumu)', 'level': 'Level 5 County Referral'},
    {'id': 'machakos_level5', 'name': 'Machakos Level 5 Hospital (Machakos)', 'level': 'Level 5 County Referral'},
    {'id': 'mbagathi_hospital', 'name': 'Mbagathi Hospital (Nairobi)', 'level': 'Level 4 District Hospital'},
  ];

  @override
  void initState() {
    super.initState();
    // Default estimated due date ~24 weeks from now (or 16 weeks pregnant)
    final now = DateTime.now();
    _estimatedDueDate = now.add(const Duration(days: 168)); // ~24 weeks remaining (16 weeks pregnant)
    _lastMenstrualPeriod = now.subtract(const Duration(days: 112)); // ~16 weeks ago
  }

  int get _calculatedGestationalWeeks {
    if (_lastMenstrualPeriod != null) {
      final days = DateTime.now().difference(_lastMenstrualPeriod!).inDays;
      return (days / 7).clamp(1, 42).floor();
    }
    if (_estimatedDueDate != null) {
      final daysRemaining = _estimatedDueDate!.difference(DateTime.now()).inDays;
      final daysPast = 280 - daysRemaining;
      return (daysPast / 7).clamp(1, 42).floor();
    }
    return 16;
  }

  Future<void> _submitOnboarding() async {
    if (_estimatedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali chagua tarehe ya kujifungua (EDD) / Please pick your due date'),
          backgroundColor: MamaCareColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).completeOnboarding(
          estimatedDueDate: _estimatedDueDate!,
          lastMenstrualPeriod: _lastMenstrualPeriod,
          gravityType: _gravityType,
          previousPregnancies: _previousPregnancies,
          previousBirths: _previousBirths,
          preferredFacilityId: _preferredFacility,
          preferredLanguage: _selectedLanguage,
        );

    if (success && mounted) {
      // Sync language provider
      ref.read(languageProvider.notifier).setLanguage(_selectedLanguage);
      // Reload providers for new user
      ref.invalidate(pregnancyProfileProvider);
      ref.invalidate(appointmentsProvider);
      ref.invalidate(healthDiaryProvider);
      ref.invalidate(familyConnectionsProvider);
      ref.invalidate(emergencyContactsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.userProfile;
    final motherName = user?.firstName ?? 'Mama';
    final weeks = _calculatedGestationalWeeks;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: MamaCareColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.pregnant_woman_rounded,
                    color: MamaCareColors.primary,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Karibu, $motherName! 🌸',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: MamaCareColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Let us set up your maternal health journey & clinical milestones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: MamaCareColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Pregnancy Timeline Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MamaCareColors.primary,
                      MamaCareColors.primary.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: MamaCareColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gestational Age',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            weeks <= 12 ? 'Trimester 1' : (weeks <= 27 ? 'Trimester 2' : 'Trimester 3'),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$weeks',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Weeks Pregnant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (weeks / 40.0).clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── 1. Estimated Due Date (EDD) Picker ──
              _buildSectionTitle('1. Estimated Due Date (EDD)', Icons.calendar_month_rounded),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _estimatedDueDate ?? DateTime.now().add(const Duration(days: 140)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 280)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: MamaCareColors.primary),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _estimatedDueDate = picked;
                      _lastMenstrualPeriod = picked.subtract(const Duration(days: 280));
                    });
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: MamaCareColors.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Delivery Date',
                              style: TextStyle(fontSize: 12, color: MamaCareColors.textTertiary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _estimatedDueDate != null
                                  ? '${_estimatedDueDate!.day}/${_estimatedDueDate!.month}/${_estimatedDueDate!.year}'
                                  : 'Select your due date',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: MamaCareColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: MamaCareColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── 2. Gravidity (First vs Subsequent Pregnancy) ──
              _buildSectionTitle('2. Pregnancy History', Icons.family_restroom_rounded),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceCard(
                      title: 'First Pregnancy',
                      subtitle: 'Primigravida',
                      selected: _gravityType == GravityType.primigravida,
                      onTap: () {
                        setState(() {
                          _gravityType = GravityType.primigravida;
                          _previousPregnancies = 0;
                          _previousBirths = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChoiceCard(
                      title: 'Previous Births',
                      subtitle: 'Multigravida',
                      selected: _gravityType == GravityType.multigravida,
                      onTap: () {
                        setState(() {
                          _gravityType = GravityType.multigravida;
                          if (_previousPregnancies == 0) _previousPregnancies = 1;
                          if (_previousBirths == 0) _previousBirths = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (_gravityType == GravityType.multigravida) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Number of previous children delivered:',
                          style: TextStyle(fontSize: 13, color: MamaCareColors.textSecondary),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: MamaCareColors.primary),
                        onPressed: _previousBirths > 1
                            ? () => setState(() => _previousBirths--)
                            : null,
                      ),
                      Text(
                        '$_previousBirths',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: MamaCareColors.primary),
                        onPressed: () => setState(() => _previousBirths++),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // ── 3. Preferred Facility ──
              _buildSectionTitle('3. Preferred Delivery Hospital / Clinic', Icons.local_hospital_rounded),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _preferredFacility,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: MamaCareColors.primary),
                    items: _kenyaFacilities.map((fac) {
                      return DropdownMenuItem<String>(
                        value: fac['id'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              fac['name']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: MamaCareColors.textPrimary,
                              ),
                            ),
                            Text(
                              fac['level']!,
                              style: const TextStyle(fontSize: 11, color: MamaCareColors.accent),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _preferredFacility = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── 4. Preferred Language ──
              _buildSectionTitle('4. Preferred App Language', Icons.translate_rounded),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceCard(
                      title: 'Kiswahili',
                      subtitle: 'Lugha ya Taifa 🇰🇪',
                      selected: _selectedLanguage == Language.sw,
                      onTap: () => setState(() => _selectedLanguage = Language.sw),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChoiceCard(
                      title: 'English',
                      subtitle: 'Official Language',
                      selected: _selectedLanguage == Language.en,
                      onTap: () => setState(() => _selectedLanguage = Language.en),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _submitOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MamaCareColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Complete My Profile'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: MamaCareColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MamaCareColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? MamaCareColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? MamaCareColors.primary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? MamaCareColors.primary : MamaCareColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: selected ? MamaCareColors.primary : MamaCareColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
