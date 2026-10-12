// ============================================
// MamaCare KE - Home Dashboard Screen
// ============================================
// Personalized pregnancy dashboard featuring
// gestational progress, baby development, ANC
// countdown, quick health actions, and emergency.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/mama_card.dart';
import '../widgets/mamacare_logo.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(int tabIndex)? onNavigateToTab;
  final VoidCallback? onOpenEmergency;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
    this.onOpenEmergency,
  });

  String _getGreeting(bool isSwahili) {
    final hour = DateTime.now().hour;
    if (isSwahili) {
      if (hour < 12) return 'Habari ya asubuhi';
      if (hour < 17) return 'Habari ya mchana';
      return 'Habari ya jioni';
    } else {
      if (hour < 12) return 'Good morning';
      if (hour < 17) return 'Good afternoon';
      return 'Good evening';
    }
  }

  String _getBabySizeComparison(int week, bool isSwahili) {
    if (week <= 8) return isSwahili ? 'Mbegu ya Tofaa (Apple Seed)' : 'Apple Seed';
    if (week <= 12) return isSwahili ? 'Chokaa (Lime)' : 'Lime';
    if (week <= 16) return isSwahili ? 'Parachichi (Avocado)' : 'Avocado';
    if (week <= 20) return isSwahili ? 'Ndizi Mbivu (Banana)' : 'Banana';
    if (week <= 24) return isSwahili ? 'Nanasi Dogo (Small Pineapple)' : 'Small Pineapple';
    if (week <= 28) return isSwahili ? 'Bilinganya Kubwa (Large Eggplant)' : 'Large Eggplant';
    if (week <= 32) return isSwahili ? 'Boga la Wastani (Squash / Butternut)' : 'Butternut Squash';
    if (week <= 36) return isSwahili ? 'Papai Lililoiva (Ripe Papaya)' : 'Ripe Papaya';
    return isSwahili ? 'Tikiti Maji (Watermelon)' : 'Watermelon';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final userProfileAsync = ref.watch(userProfileProvider);
    final pregnancyAsync = ref.watch(pregnancyProfileProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final milestoneAsync = ref.watch(activeMilestoneProvider);
    final milestone = milestoneAsync.value;

    final motherName = userProfileAsync.value?.firstName ?? 'Mama';
    final pregnancy = pregnancyAsync.value;

    final currentWeek = pregnancy?.currentWeek ?? 24;
    final trimester = pregnancy?.trimester ?? 2;
    final daysRemaining = pregnancy?.daysRemaining ?? 112;
    final progress = ((currentWeek / 40.0).clamp(0.0, 1.0));

    // Next scheduled appointment
    Appointment? nextAppointment;
    if (appointmentsAsync.value != null) {
      final scheduled = appointmentsAsync.value!
          .where((a) => a.status == AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      if (scheduled.isNotEmpty) {
        nextAppointment = scheduled.first;
      }
    }

    final babyDevText = milestone != null
        ? (isSwahili ? milestone.babyDevelopmentSw : milestone.babyDevelopmentEn)
        : (isSwahili
            ? 'Mtoto anaweza kusikia sauti yako na kupiga miayo sasa!'
            : 'Baby can hear your voice and now yawns and stretches!');

    final tipsText = milestone != null
        ? (isSwahili ? milestone.tipsSw : milestone.tipsEn)
        : null;

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        title: const MamaCareLogo(size: 34),
        actions: [
          // Language Switcher Toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () {
                ref.read(languageProvider.notifier).toggleLanguage();
              },
              icon: Icon(
                Icons.language_rounded,
                color: MamaCareColors.primaryDark,
                size: 18,
              ),
              label: Text(
                isSwahili ? 'SW' : 'EN',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MamaCareColors.primaryDark,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: MamaCareColors.primarySurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            ),
          ),
          // Emergency SOS Action Button
          IconButton(
            tooltip: isSwahili ? 'Dharura ya Uzazi' : 'Maternal Emergency',
            icon: const Icon(Icons.emergency_outlined, color: MamaCareColors.error, size: 28),
            onPressed: onOpenEmergency,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pregnancyProfileProvider);
          ref.invalidate(appointmentsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency 1-Tap Banner
              EmergencyBanner(
                isSwahili: isSwahili,
                onMoreInfoPressed: onOpenEmergency,
              ),

              // Personalized Maternal Greeting
              Padding(
                padding: const EdgeInsets.fromLTRB(MamaCareSpacing.md, MamaCareSpacing.sm, MamaCareSpacing.md, MamaCareSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting(isSwahili)}, $motherName! 🌸',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: MamaCareColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSwahili
                          ? 'Safari yako ya ujauzito inakwenda salama. Tuko pamoja nawe kila hatua.'
                          : 'Your pregnancy journey is going smoothly. We are with you every step.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: MamaCareColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Pregnancy Timeline Card ──
              Padding(
                padding: const EdgeInsets.all(MamaCareSpacing.md),
                child: MamaCard(
                  elevation: 2,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3F1), Color(0xFFFFFBF9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: MamaCareColors.primaryLight.withValues(alpha: 0.5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: MamaCareColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isSwahili ? 'Wiki ya $currentWeek' : 'Week $currentWeek',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            isSwahili ? 'Awamu ya $trimester (Trimester $trimester)' : 'Trimester $trimester',
                            style: const TextStyle(
                              color: MamaCareColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress Bar
                      LinearPercentIndicator(
                        lineHeight: 10.0,
                        percent: progress,
                        padding: EdgeInsets.zero,
                        backgroundColor: MamaCareColors.divider.withValues(alpha: 0.5),
                        progressColor: MamaCareColors.primary,
                        barRadius: const Radius.circular(5),
                        animation: true,
                        animationDuration: 1000,
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isSwahili
                                ? 'Zimesalia siku $daysRemaining hadi uzazi'
                                : '$daysRemaining days until estimated due date',
                            style: const TextStyle(
                              fontSize: 12,
                              color: MamaCareColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: MamaCareColors.primaryDark,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Baby Development comparison
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: MamaCareColors.secondarySurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: MamaCareColors.secondaryLight),
                            ),
                            child: const Text('🍍', style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSwahili ? 'Ukubwa wa Mtoto Wako:' : 'Baby\'s Current Size:',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: MamaCareColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _getBabySizeComparison(currentWeek, isSwahili),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: MamaCareColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  babyDevText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: MamaCareColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                                if (tipsText != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: MamaCareColors.primarySurface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '💡 $tipsText',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: MamaCareColors.primaryDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Action Grid ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MamaCareSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSwahili ? 'Huduma za Haraka' : 'Quick Actions',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MamaCareColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        // 1. Mama AI
                        _buildQuickActionCard(
                          icon: Icons.auto_awesome,
                          color: MamaCareColors.primary,
                          title: 'Mama AI',
                          subtitle: isSwahili ? 'Msaidizi wa Afya' : 'AI Companion',
                          badge: isSwahili ? 'Msaada 24/7' : '24/7 Active',
                          onTap: () => onNavigateToTab?.call(1),
                        ),
                        // 2. ANC Clinic
                        _buildQuickActionCard(
                          icon: Icons.calendar_month_rounded,
                          color: MamaCareColors.secondary,
                          title: isSwahili ? 'Kliniki ya ANC' : 'ANC Visits',
                          subtitle: nextAppointment != null
                              ? DateFormat('d MMM').format(nextAppointment.appointmentDate)
                              : (isSwahili ? 'Ratiba Kliniki' : 'Schedule Visit'),
                          badge: isSwahili ? 'Linda Mama' : 'Free Care',
                          onTap: () => onNavigateToTab?.call(2),
                        ),
                        // 3. Health Diary
                        _buildQuickActionCard(
                          icon: Icons.favorite_border_rounded,
                          color: MamaCareColors.accent,
                          title: isSwahili ? 'Shajara ya Afya' : 'Health Diary',
                          subtitle: isSwahili ? 'BP, Uzito & Dalili' : 'BP, Weight & Kicks',
                          badge: null,
                          onTap: () => onNavigateToTab?.call(3),
                        ),
                        // 4. Hospitals & Care
                        _buildQuickActionCard(
                          icon: Icons.local_hospital_outlined,
                          color: MamaCareColors.info,
                          title: isSwahili ? 'Vituo vya Afya' : 'Find Facilities',
                          subtitle: isSwahili ? 'Hospitali Karibu Nawe' : 'Accredited Centers',
                          badge: isSwahili ? 'Level 2 - 6' : 'MoH Verified',
                          onTap: () => onNavigateToTab?.call(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Upcoming ANC Visit Card ──
              if (nextAppointment != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MamaCareSpacing.md),
                  child: MamaCard(
                    color: MamaCareColors.secondarySurface,
                    border: Border.all(color: MamaCareColors.secondaryLight),
                    onTap: () => onNavigateToTab?.call(2),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MamaCareColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_available, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSwahili ? 'Kliniki Ijayo ya ANC' : 'Next ANC Appointment',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: MamaCareColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${nextAppointment.title} • ${DateFormat('EEE, d MMMM').format(nextAppointment.appointmentDate)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MamaCareColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSwahili
                                    ? 'Kumbuka kubeba kijitabu cha kliniki cha mama na mtoto.'
                                    : 'Remember to carry your Mother-Child Health booklet.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: MamaCareColors.secondaryDark,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: MamaCareColors.textSecondary),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ── Kenyan Maternal Nutrition & Wellbeing Tip ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MamaCareSpacing.md),
                child: MamaCard(
                  color: MamaCareColors.accentSurface,
                  border: Border.all(color: MamaCareColors.accentLight.withValues(alpha: 0.5)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MamaCareColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: MamaCareColors.accentDark,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSwahili ? 'Mawaidha ya Lishe ya Leo (Kenya)' : 'Today\'s Nutrition Tip (Kenya)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: MamaCareColors.accentDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSwahili
                                  ? 'Mboga za kienyeji kama terere, managu, na kunde zina madini mengi ya chuma. Meza vidonge vya IFAS kila jioni na maji safi (si chai wala kahawa) ili mtoto akue mwenye afya.'
                                  : 'Indigenous vegetables like terere, managu, and kunde provide essential iron. Take your daily IFAS supplements with water (avoid tea/coffee nearby) for optimal absorption.',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: MamaCareColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String? badge,
    required VoidCallback onTap,
  }) {
    return MamaCard(
      onTap: onTap,
      elevation: 1,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: MamaCareColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: MamaCareColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
