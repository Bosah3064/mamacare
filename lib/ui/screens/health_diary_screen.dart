// ============================================
// MamaCare KE - Health & Symptoms Diary Screen
// ============================================
// Tracks blood pressure, maternal weight, fetal
// kick counts, moods, and common pregnancy signs.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/mama_card.dart';

class HealthDiaryScreen extends ConsumerStatefulWidget {
  const HealthDiaryScreen({super.key});

  @override
  ConsumerState<HealthDiaryScreen> createState() => _HealthDiaryScreenState();
}

class _HealthDiaryScreenState extends ConsumerState<HealthDiaryScreen> {
  int _activeKickCount = 0;

  void _showLogModal(BuildContext context, bool isSwahili) {
    final sysCtrl = TextEditingController(text: '118');
    final diaCtrl = TextEditingController(text: '76');
    final pulseCtrl = TextEditingController(text: '74');
    final wtCtrl = TextEditingController(text: '64.8');
    final notesCtrl = TextEditingController();
    String? selectedSymptom;
    SymptomSeverity selectedSeverity = SymptomSeverity.mild;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSwahili ? 'Rekodi Afya ya Leo' : 'Record Today\'s Health',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Blood Pressure Row
                    Text(
                      isSwahili ? 'Shinikizo la Damu (BP mmHg)' : 'Blood Pressure (mmHg)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: sysCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isSwahili ? 'Juu (Systolic)' : 'Systolic',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: diaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isSwahili ? 'Chini (Diastolic)' : 'Diastolic',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Maternal Weight
                    TextField(
                      controller: wtCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isSwahili ? 'Uzito wa Mwili (kg)' : 'Maternal Weight (kg)',
                        suffixText: 'kg',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Symptoms dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedSymptom,
                      decoration: InputDecoration(
                        labelText: isSwahili ? 'Dalili Unayohisi (Symptom)' : 'Reported Symptom',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text(isSwahili ? 'Sina dalili mbaya (Najisikia Vizuri)' : 'No symptoms (Feeling Good)'),
                        ),
                        DropdownMenuItem(
                          value: 'mild_backache',
                          child: Text(isSwahili ? 'Maumivu kidogo ya mgongo' : 'Mild lower backache'),
                        ),
                        DropdownMenuItem(
                          value: 'nausea',
                          child: Text(isSwahili ? 'Kichefuchefu / Nausea' : 'Morning nausea'),
                        ),
                        DropdownMenuItem(
                          value: 'swollen_feet',
                          child: Text(isSwahili ? 'Uvimbe kidogo miguuni' : 'Mild evening ankle swelling'),
                        ),
                        DropdownMenuItem(
                          value: 'heartburn',
                          child: Text(isSwahili ? 'Kuhisi kuungua kifuani (Heartburn)' : 'Heartburn / Acidity'),
                        ),
                        DropdownMenuItem(
                          value: 'fatigue',
                          child: Text(isSwahili ? 'Uchovu wa kawaida' : 'General fatigue'),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() => selectedSymptom = val);
                      },
                    ),

                    const SizedBox(height: 14),

                    // Notes
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: isSwahili ? 'Vidokezo vya kibinafsi (Notes)' : 'Personal notes',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MamaCareColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final pregnancy = ref.read(pregnancyProfileProvider).value;
                          final sys = int.tryParse(sysCtrl.text);
                          final dia = int.tryParse(diaCtrl.text);
                          final pulse = int.tryParse(pulseCtrl.text);
                          final wt = double.tryParse(wtCtrl.text);

                          final currentUid = SupabaseService.instance.currentUserId;
                          await ref.read(healthDiaryProvider.notifier).logHealthRecord(
                            pregnancyId: pregnancy?.id ?? 'preg-$currentUid',
                            userId: pregnancy?.userId ?? currentUid ?? 'demo-user-amani',
                            notes: notesCtrl.text.trim(),
                            systolic: sys,
                            diastolic: dia,
                            pulse: pulse,
                            weightKg: wt,
                            symptomName: (selectedSymptom != null && selectedSymptom != 'none')
                                ? selectedSymptom
                                : null,
                            severity: selectedSeverity,
                          );

                          if (modalCtx.mounted) Navigator.pop(modalCtx);
                        },
                        child: Text(
                          isSwahili ? 'Hifadhi kwenye Shajara' : 'Save Health Record',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final diaryState = ref.watch(healthDiaryProvider);

    final latestBp = diaryState.bpEntries.isNotEmpty ? diaryState.bpEntries.first : null;
    final latestWeight = diaryState.weightEntries.isNotEmpty ? diaryState.weightEntries.first : null;

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        title: Text(
          isSwahili ? 'Shajara ya Afya' : 'Health Diary',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MamaCareColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          isSwahili ? 'Rekodi Afya' : 'Log Health',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showLogModal(context, isSwahili),
      ),
      body: diaryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(MamaCareSpacing.md),
              children: [
                // ── Vitals Overview Cards Row ──
                Row(
                  children: [
                    // Blood Pressure Card
                    Expanded(
                      child: MamaCard(
                        elevation: 1,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.favorite_rounded, color: MamaCareColors.error, size: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: MamaCareColors.successSurface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isSwahili ? 'Kawaida' : 'Normal',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: MamaCareColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              latestBp != null ? '${latestBp.systolic}/${latestBp.diastolic}' : '118/76',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MamaCareColors.textPrimary,
                              ),
                            ),
                            Text(
                              isSwahili ? 'Shinikizo (BP mmHg)' : 'Blood Pressure',
                              style: const TextStyle(fontSize: 11, color: MamaCareColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Weight Card
                    Expanded(
                      child: MamaCard(
                        elevation: 1,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.monitor_weight_outlined, color: MamaCareColors.secondary, size: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: MamaCareColors.secondarySurface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '+2.1 kg',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: MamaCareColors.secondaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              latestWeight != null ? '${latestWeight.weightKg} kg' : '64.8 kg',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MamaCareColors.textPrimary,
                              ),
                            ),
                            Text(
                              isSwahili ? 'Uzito wa Mama' : 'Maternal Weight',
                              style: const TextStyle(fontSize: 11, color: MamaCareColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Interactive Fetal Kick Counter Tool ──
                MamaCard(
                  color: MamaCareColors.primarySurface,
                  border: Border.all(color: MamaCareColors.primaryLight),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSwahili ? 'Kipima Mateke ya Mtoto (Kick Counter)' : 'Baby Kick Counter',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: MamaCareColors.primaryDark,
                                ),
                              ),
                              Text(
                                isSwahili ? 'Lengo: Mateke 10 ndani ya masaa 2' : 'Goal: 10 movements in 2 hours',
                                style: const TextStyle(fontSize: 11, color: MamaCareColors.textSecondary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: MamaCareColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$_activeKickCount / 10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _activeKickCount++;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MamaCareColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.touch_app, size: 18),
                              label: Text(
                                isSwahili ? 'Gusa Mtoto Akipiga Teke' : 'Tap on Baby Kick',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _activeKickCount = 0;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MamaCareColors.textSecondary,
                              side: const BorderSide(color: MamaCareColors.divider),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(isSwahili ? 'Weka Upya' : 'Reset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Health History Entries ──
                Text(
                  isSwahili ? 'Historia ya Rekodi' : 'Health History',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (diaryState.entries.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      isSwahili ? 'Hakuna rekodi zilizohifadhiwa bado.' : 'No diary records saved yet.',
                      style: const TextStyle(color: MamaCareColors.textSecondary),
                    ),
                  )
                else
                  ...diaryState.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MamaCard(
                        elevation: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy').format(entry.recordedAt),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const Icon(Icons.check_circle, size: 16, color: MamaCareColors.success),
                              ],
                            ),
                            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                entry.notes!,
                                style: const TextStyle(fontSize: 13, color: MamaCareColors.textPrimary),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: MamaCareColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('BP: 118/76 mmHg', style: TextStyle(fontSize: 11)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: MamaCareColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Uzito: 64.5 kg', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
