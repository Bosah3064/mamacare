// ============================================
// MamaCare KE - Maternal Emergency & Danger Signs
// ============================================
// Life-saving red-flag triage according to Kenya
// MoH Maternal guidelines, 1-tap 1199 Red Cross
// ambulance dialing, and emergency protocol.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/mama_card.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final hotlines = ref.watch(emergencyHotlinesProvider);
    final contactsAsync = ref.watch(emergencyContactsProvider);

    EmergencyContact? primaryContact;
    final contacts = contactsAsync.value;
    if (contacts != null && contacts.isNotEmpty) {
      primaryContact = contacts.firstWhere(
        (c) => c.isPrimary,
        orElse: () => contacts.first,
      );
    }

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        backgroundColor: MamaCareColors.error,
        foregroundColor: Colors.white,
        title: Text(
          isSwahili ? 'Dharura ya Uzazi & Dalili za Hatari' : 'Maternal Emergency & Red Flags',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MamaCareSpacing.md),
        children: [
          // ── Main 1199 Ambulance Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD44B4B), Color(0xFFB82E2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emergency_rounded, color: MamaCareColors.error, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSwahili ? 'Msalaba Mwekundu Kenya' : 'Kenya Red Cross',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '1199',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isSwahili
                      ? 'Nambari ya dharura ya bure 24/7 kwa ambulensi ya uzazi nchini kote.'
                      : '24/7 Toll-Free nationwide emergency maternal ambulance dispatch.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall('1199'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: MamaCareColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.call, size: 24, color: MamaCareColors.error),
                    label: Text(
                      isSwahili ? 'PIGA 1199 SASA (BURE)' : 'CALL 1199 NOW (FREE)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Trusted Family Contact Call Card ──
          if (primaryContact != null)
            _buildPrimaryContactCard(primaryContact, isSwahili),

          const SizedBox(height: 20),

          // ── Other Emergency Numbers ──
          Text(
            isSwahili ? 'Nambari Nyingine za Uokoaji' : 'Other National Emergency Hotlines',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          MamaCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: hotlines.map((h) {
                return ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: MamaCareColors.errorSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone, size: 16, color: MamaCareColors.error),
                  ),
                  title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    isSwahili ? h.descriptionSw : h.descriptionEn,
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: TextButton(
                    onPressed: () => _makeCall(h.phoneNumber),
                    child: Text(
                      h.phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: MamaCareColors.error),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ── Kenya MoH Obstetric Danger Signs ──
          Text(
            isSwahili ? 'Dalili za Hatari (Wizara ya Afya Kenya)' : 'Kenya MoH Obstetric Danger Signs',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDangerSignCard(
            title: isSwahili ? '1. Kutokwa na Damu Ukeni' : '1. Vaginal Bleeding',
            action: isSwahili
                ? 'Nenda hospitali mara moja! Usiweke pamba wala dawa ukeni.'
                : 'Go to maternity hospital immediately! Do not insert anything into the vagina.',
            color: MamaCareColors.error,
          ),
          _buildDangerSignCard(
            title: isSwahili ? '2. Kuumwa Kichwa Sana & Kutoona Vizuri' : '2. Severe Headache & Blurry Vision',
            action: isSwahili
                ? 'Pima shinikizo la damu mara moja hospitalini kuzuia eclampsia.'
                : 'Have blood pressure checked immediately to rule out preeclampsia/eclampsia.',
            color: MamaCareColors.error,
          ),
          _buildDangerSignCard(
            title: isSwahili ? '3. Degedege au Kupoteza Fahamu' : '3. Convulsions or Fits',
            action: isSwahili
                ? 'Mlaze mama upande wa kushoto na umpeleke hospitali ya rufaa haraka.'
                : 'Turn mother to left side, keep airway clear, rush to emergency referral unit.',
            color: MamaCareColors.error,
          ),
          _buildDangerSignCard(
            title: isSwahili ? '4. Mtoto Kuacha au Kupunguza Kucheza' : '4. Reduced or Absent Baby Kicks',
            action: isSwahili
                ? 'Lala upande wa kushoto uhesabu mateke. Isipofika 10 kwa saa 2, fika hospitali.'
                : 'Rest on left side. If fewer than 10 kicks in 2 hours, get immediate fetal monitoring.',
            color: MamaCareColors.error,
          ),
          _buildDangerSignCard(
            title: isSwahili ? '5. Maji ya Uzazi Kuvuja Kabla ya Wakati' : '5. Leaking Amniotic Fluid',
            action: isSwahili
                ? 'Maji yakitoka ghafla, vaa pedi safi na uelekee kituo cha afya.'
                : 'If water breaks early, wear a clean pad and head directly to maternity.',
            color: MamaCareColors.warning,
          ),
          _buildDangerSignCard(
            title: isSwahili ? '6. Homa Kali na Kutetemeka' : '6. High Fever with Chills',
            action: isSwahili
                ? 'Pima malaria na maambukizi ya njia ya mkojo ndani ya masaa 24.'
                : 'Test for malaria and urinary tract infection within 24 hours.',
            color: MamaCareColors.warning,
          ),

          const SizedBox(height: 20),

          // ── Immediate Steps to take while waiting ──
          MamaCard(
            color: MamaCareColors.infoSurface,
            border: Border.all(color: MamaCareColors.info.withValues(alpha: 0.4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: MamaCareColors.info),
                    const SizedBox(width: 8),
                    Text(
                      isSwahili ? 'Wakati Unasubiri Usaidizi:' : 'While Waiting for Transport:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MamaCareColors.info),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isSwahili
                      ? '• Lala upande wako wa kushoto ili damu imfikie mtoto vizuri.\n'
                          '• Usinywe dawa za kienyeji wala dawa za kutuliza maumivu bila daktari.\n'
                          '• Beba kijitabu chako cha kliniki cha mama na mtoto (MOH 216).\n'
                          '• Muombe mwenzi au jirani afuatane nawe hospitalini.'
                      : '• Lie on your left side to maximize oxygen and blood flow to baby.\n'
                          '• Avoid self-medicating or taking herbs without clinical advice.\n'
                          '• Have your Mother-Child Clinic booklet (MOH 216) ready.\n'
                          '• Ensure a family member or neighbor accompanies you.',
                  style: const TextStyle(fontSize: 12, height: 1.5, color: MamaCareColors.textPrimary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDangerSignCard({
    required String title,
    required String action,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MamaCard(
        elevation: 1,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              action,
              style: const TextStyle(fontSize: 12, color: MamaCareColors.textPrimary, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryContactCard(EmergencyContact contact, bool isSwahili) {
    return MamaCard(
      color: MamaCareColors.secondarySurface,
      border: Border.all(color: MamaCareColors.secondaryLight),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MamaCareColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.family_restroom, color: MamaCareColors.secondaryDark, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSwahili ? 'Mtu wa Karibu wa Dharura' : 'Primary Emergency Contact',
                  style: const TextStyle(
                    fontSize: 11,
                    color: MamaCareColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${contact.name} (${contact.relationship})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(contact.phone, style: const TextStyle(fontSize: 12, color: MamaCareColors.textSecondary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _makeCall(contact.phone),
            style: ElevatedButton.styleFrom(
              backgroundColor: MamaCareColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call, size: 16),
                const SizedBox(width: 4),
                Text(isSwahili ? 'Piga' : 'Call'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
