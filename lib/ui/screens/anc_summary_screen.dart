// ============================================
// MamaCare KE - ANC Clinical Summary Screen
// ============================================
// Auto-generated clinical handoff summary for
// nurses, midwives, and obstetricians.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/facility_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/mama_card.dart';

class AncSummaryScreen extends ConsumerWidget {
  const AncSummaryScreen({super.key});

  void _shareSummary(BuildContext context, String text) {
    Share.share(text, subject: 'MamaCare KE - ANC Maternal Clinical Summary');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final user = ref.watch(userProfileProvider).value;
    final pregnancy = ref.watch(pregnancyProfileProvider).value;
    final appointments = ref.watch(appointmentsProvider).value ?? [];
    final diary = ref.watch(healthDiaryProvider);

    final completed = appointments.where((a) => a.status == AppointmentStatus.completed).toList();
    final latestBp = diary.bpEntries.isNotEmpty ? diary.bpEntries.first : null;
    final latestWeight = diary.weightEntries.isNotEmpty ? diary.weightEntries.first : null;
    final emergencyContacts = ref.watch(emergencyContactsProvider).value ?? [];
    final primaryEmergency = emergencyContacts.isNotEmpty ? emergencyContacts.first : null;

    final eddStr = pregnancy != null
        ? DateFormat('d MMMM yyyy').format(pregnancy.estimatedDueDate)
        : 'Unknown';

    final emergencyText = primaryEmergency != null
        ? '${primaryEmergency.name} (${primaryEmergency.relationship}): ${primaryEmergency.phone}'
        : 'Kenya Red Cross Dispatch: 1199';

    final gravidityStr = pregnancy?.gravityType == GravityType.multigravida
        ? 'Multigravida (${pregnancy?.previousPregnancies ?? 1} previous)'
        : 'Primigravida (First pregnancy)';

    final String facilityName = pregnancy?.preferredFacilityId != null
        ? (FacilityService.instance.allFacilities
            .where((f) => f.id == pregnancy!.preferredFacilityId)
            .firstOrNull
            ?.name ??
            pregnancy!.preferredFacilityId ??
            (isSwahili ? "Kituo cha Afya" : "Health Facility"))
        : (isSwahili ? "Kituo Hakijachaguliwa" : "Facility not selected");

    final summaryText = '''
MAMACARE KE — MATERNAL ANC CLINICAL SUMMARY
Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}
Patient Name: ${user?.fullName.isNotEmpty == true ? user!.fullName : (isSwahili ? "Mama Mjamzito" : "Expectant Mother")}
Phone: ${user?.phone ?? (isSwahili ? "Haijarekodiwa" : "Not recorded")}
County: ${user?.countyId ?? "Kenya"}${user?.subCountyId != null ? " (Sub-County: ${user!.subCountyId})" : ""}

PREGNANCY PROFILE:
- Gestational Age: ${pregnancy?.currentWeek != null ? "${pregnancy!.currentWeek} Weeks (Trimester ${pregnancy.trimester})" : (isSwahili ? "Haijarekodiwa" : "Not recorded")}
- Estimated Due Date (EDD): $eddStr
- Gravidity / Parity: $gravidityStr
- Assigned Health Facility: $facilityName

RECENT VITALS:
- Blood Pressure: ${latestBp != null ? "${latestBp.systolic}/${latestBp.diastolic} mmHg" : (isSwahili ? "Hakuna rekodi" : "Pending recording")}
- Weight: ${latestWeight != null ? "${latestWeight.weightKg} kg" : (isSwahili ? "Hakuna rekodi" : "Pending recording")}
- Fetal Kicks: ${diary.kickCount > 0 ? "${diary.kickCount} kicks recorded" : (isSwahili ? "Haijarekodiwa" : "Pending recording")}

KENYA MOH ANC CONTACTS RECORD (${completed.length}/8 Completed):
${completed.isEmpty ? (isSwahili ? "• Hakuna kliniki iliyokamilika bado." : "• No ANC contacts completed yet.") : completed.map((a) => "• ${a.title} (${DateFormat('yyyy-MM-dd').format(a.appointmentDate)}): ${a.notes ?? 'Routine checks normal'}").join('\n')}

EMERGENCY CONTACT:
- $emergencyText
''';

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        title: Text(
          isSwahili ? 'Muhtasari wa Kliniki ya ANC' : 'ANC Clinical Summary',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: isSwahili ? 'Shiriki Muhtasari' : 'Share Summary',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareSummary(context, summaryText),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(MamaCareSpacing.md),
        children: [
          // ── Brand Passport Header ──
          Container(
            margin: const EdgeInsets.only(bottom: MamaCareSpacing.md),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MamaCareColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo_emblem.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MamaCare KE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: MamaCareColors.textPrimary,
                        ),
                      ),
                      Text(
                        isSwahili
                            ? 'Kadi ya Kliniki ya Uzazi (Miongozo ya MoH Kenya)'
                            : 'Maternal Clinical Passport (MoH Kenya Guidelines)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: MamaCareColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Header Card ──
          MamaCard(
            color: MamaCareColors.primarySurface,
            border: Border.all(color: MamaCareColors.primaryLight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName.isNotEmpty == true ? user!.fullName : (isSwahili ? 'Mama Mjamzito' : 'Expectant Mother'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          isSwahili
                              ? 'Wiki ya ${pregnancy?.currentWeek ?? 24} • Trimester ${pregnancy?.trimester ?? 2}'
                              : 'Week ${pregnancy?.currentWeek ?? 24} • Trimester ${pregnancy?.trimester ?? 2}',
                          style: const TextStyle(color: MamaCareColors.primaryDark, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.health_and_safety, color: MamaCareColors.primary, size: 28),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      isSwahili ? 'Tarehe ya Uzazi (EDD)' : 'Due Date (EDD)',
                      eddStr,
                    ),
                    _buildInfoColumn(
                      isSwahili ? 'Kituo cha Afya' : 'Assigned Clinic',
                      facilityName,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Latest Clinical Vitals ──
          MamaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSwahili ? 'Vipimo vya Hivi Karibuni' : 'Recent Vitals',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildVitalBadge(
                      Icons.favorite,
                      latestBp != null ? '${latestBp.systolic}/${latestBp.diastolic}' : '--/--',
                      'BP (mmHg)',
                      MamaCareColors.error,
                    ),
                    _buildVitalBadge(
                      Icons.monitor_weight_outlined,
                      latestWeight != null ? '${latestWeight.weightKg} kg' : '-- kg',
                      isSwahili ? 'Uzito' : 'Weight',
                      MamaCareColors.secondary,
                    ),
                    _buildVitalBadge(
                      Icons.child_care,
                      diary.kickCount > 0 ? '${diary.kickCount}' : '--',
                      isSwahili ? 'Mateke' : 'Kicks',
                      MamaCareColors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Recorded MoH ANC Visits ──
          MamaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSwahili ? 'Rekodi za Ziara za MoH' : 'Kenya MoH Contacts Record',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${completed.length}/8',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: MamaCareColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...completed.map((a) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 18, color: MamaCareColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${a.title} (${DateFormat('d MMM yyyy').format(a.appointmentDate)})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (a.notes != null)
                                Text(
                                  a.notes!,
                                  style: const TextStyle(fontSize: 12, color: MamaCareColors.textSecondary),
                                ),
                              if (a.testsConducted != null)
                                Text(
                                  'Vipimo: ${a.testsConducted}',
                                  style: const TextStyle(fontSize: 11, color: MamaCareColors.info),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Share Button ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _shareSummary(context, summaryText),
              style: ElevatedButton.styleFrom(
                backgroundColor: MamaCareColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.share, size: 20),
              label: Text(
                isSwahili ? 'Mtumie Mkunga / Daktari Muhtasari' : 'Share Summary with Midwife',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: MamaCareColors.textTertiary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildVitalBadge(IconData icon, String val, String label, Color col) {
    return Column(
      children: [
        Icon(icon, color: col, size: 22),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(fontSize: 11, color: MamaCareColors.textSecondary)),
      ],
    );
  }
}
