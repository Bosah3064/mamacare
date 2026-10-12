// ============================================
// MamaCare KE - ANC Visits Manager Screen
// ============================================
// Tracks the 8 Kenya MoH Antenatal Contacts,
// appointment preparation, clinical tests,
// Linda Mama entitlements, and visit scheduling.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/facility_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/mama_card.dart';

class AncScreen extends ConsumerWidget {
  final VoidCallback? onOpenSummary;

  const AncScreen({
    super.key,
    this.onOpenSummary,
  });

  void _showAddAppointmentSheet(BuildContext context, WidgetRef ref, bool isSwahili) {
    final titleController = TextEditingController(
      text: isSwahili ? 'Kliniki ya ANC (Mwezi Huu)' : 'Routine ANC Contact',
    );
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 14));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSwahili ? 'Ratiba Kliniki ya ANC' : 'Schedule ANC Visit',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: isSwahili ? 'Jina la Kliniki / Ziara' : 'Visit Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: MamaCareColors.divider),
                    ),
                    leading: const Icon(Icons.calendar_today, color: MamaCareColors.primary),
                    title: Text(
                      isSwahili ? 'Tarehe ya Kliniki' : 'Appointment Date',
                      style: const TextStyle(fontSize: 12, color: MamaCareColors.textSecondary),
                    ),
                    subtitle: Text(
                      DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.edit_calendar, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 280)),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: isSwahili ? 'Vidokezo vya kumuuliza nesi/mkunga' : 'Questions for the midwife',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final pregnancy = ref.read(pregnancyProfileProvider).value;
                        final currentUid = SupabaseService.instance.currentUserId;
                        final newAppt = Appointment(
                          id: const Uuid().v4(),
                          userId: pregnancy?.userId ?? currentUid ?? SupabaseService.defaultSeedUserId,
                          pregnancyId: pregnancy?.id ?? 'preg-$currentUid',
                          facilityId: pregnancy?.preferredFacilityId ??
                              (FacilityService.instance.allFacilities.isNotEmpty
                                  ? FacilityService.instance.allFacilities.first.id
                                  : 'knh_nairobi'),
                          appointmentDate: selectedDate,
                          appointmentType: AppointmentType.routine,
                          status: AppointmentStatus.scheduled,
                          title: titleController.text.trim(),
                          notes: notesController.text.trim(),
                          synced: true,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        await ref.read(appointmentsProvider.notifier).addAppointment(newAppt);
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MamaCareColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isSwahili ? 'Hifadhi Ziara' : 'Save Visit',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCompleteDialog(BuildContext context, WidgetRef ref, Appointment appt, bool isSwahili) {
    final notesCtrl = TextEditingController(text: isSwahili ? 'Shinikizo na uzito vimepimwa vizuri.' : 'Blood pressure and weight checked.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSwahili ? 'Tia Alama ya Kukamilika' : 'Mark Visit Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appt.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isSwahili ? 'Matokeo / Maoni ya Nesi' : 'Nurse / Midwife notes',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSwahili ? 'Ghairi' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MamaCareColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(appointmentsProvider.notifier).markCompleted(appt.id, notesCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isSwahili ? 'Kamilisha' : 'Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        title: Text(
          isSwahili ? 'Kliniki za ANC (MOH Kenya)' : 'ANC Contacts (Kenya MoH)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (onOpenSummary != null)
            TextButton.icon(
              onPressed: onOpenSummary,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(isSwahili ? 'Muhtasari' : 'Summary'),
              style: TextButton.styleFrom(foregroundColor: MamaCareColors.primaryDark),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MamaCareColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          isSwahili ? 'Ratiba Ziara' : 'Schedule Visit',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddAppointmentSheet(context, ref, isSwahili),
      ),
      body: appointmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading appointments: $err')),
        data: (appointments) {
          final completed = appointments.where((a) => a.status == AppointmentStatus.completed).toList();
          final scheduled = appointments.where((a) => a.status == AppointmentStatus.scheduled).toList();

          return ListView(
            padding: const EdgeInsets.all(MamaCareSpacing.md),
            children: [
              // ── Linda Mama Free Care Guarantee Card ──
              MamaCard(
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
                      child: const Icon(Icons.verified, color: MamaCareColors.secondaryDark, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSwahili ? 'Bima ya Linda Mama (Bila Malipo)' : 'Linda Mama Free Maternal Care',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: MamaCareColors.secondaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSwahili
                                ? 'Huduma zote 8 za ANC, vipimo vya damu na uzazi ni bure katika vituo vya umma (Level 2 - 6).'
                                : 'All 8 ANC visits, ultrasound scans, and deliveries are covered 100% free at public facilities.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: MamaCareColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Kenya MoH 8-Contact Progress ──
              MamaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSwahili ? 'Maendeleo ya Ziara 8 za MoH' : 'Kenya MoH 8 Contacts Progress',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${completed.length} / 8',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MamaCareColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (completed.length / 8.0).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: MamaCareColors.divider,
                        valueColor: const AlwaysStoppedAnimation(MamaCareColors.success),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSwahili
                          ? 'Wizara ya Afya (MoH) inapendekeza angalau ziara 8 ili kuhakikisha afya njema ya mama na mtoto.'
                          : 'Kenya Ministry of Health recommends a minimum of 8 antenatal contacts.',
                      style: const TextStyle(fontSize: 11, color: MamaCareColors.textTertiary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Scheduled Visits ──
              Text(
                isSwahili ? 'Ziara Zinazokuja' : 'Upcoming Visits',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MamaCareColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (scheduled.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    isSwahili ? 'Hakuna ziara zilizoratibiwa sasa.' : 'No upcoming visits scheduled.',
                    style: const TextStyle(color: MamaCareColors.textSecondary),
                  ),
                )
              else
                ...scheduled.map((appt) => _buildAppointmentCard(appt, false, isSwahili, context, ref)),

              const SizedBox(height: 20),

              // ── Completed Visits ──
              Text(
                isSwahili ? 'Ziara Zilizokamilika' : 'Completed Contacts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MamaCareColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (completed.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    isSwahili ? 'Bado hujakamilisha ziara yoyote.' : 'No completed contacts yet.',
                    style: const TextStyle(color: MamaCareColors.textSecondary),
                  ),
                )
              else
                ...completed.map((appt) => _buildAppointmentCard(appt, true, isSwahili, context, ref)),

              const SizedBox(height: 20),

              // ── What to Bring to ANC Checklist ──
              MamaCard(
                color: MamaCareColors.accentSurface,
                border: Border.all(color: MamaCareColors.accentLight.withValues(alpha: 0.6)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.checklist_rtl_rounded, color: MamaCareColors.accentDark),
                        const SizedBox(width: 8),
                        Text(
                          isSwahili ? 'Vitu vya Kubeba Kliniki (Checklist)' : 'What to Bring to ANC Visit',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: MamaCareColors.accentDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildChecklistItem(
                      isSwahili ? 'Kijitabu cha Kliniki cha Afya ya Mama na Mtoto (MOH 216)' : 'Mother and Child Health Booklet (MOH 216)',
                    ),
                    _buildChecklistItem(
                      isSwahili ? 'Kadi ya Kitambulisho cha Kitaifa (National ID) & Linda Mama' : 'National ID & Linda Mama / NHIF details',
                    ),
                    _buildChecklistItem(
                      isSwahili ? 'Matokeo ya vipimo vya awali vya maabara na ultrasound' : 'Previous ultrasound scans and lab results',
                    ),
                    _buildChecklistItem(
                      isSwahili ? 'Maji ya kunywa na vitafunio vyepesi' : 'Clean drinking water and light snack',
                    ),
                    _buildChecklistItem(
                      isSwahili ? 'Mwenzi au mlezi wa familia (husaidia kujifunza pamoja)' : 'Birth partner or supportive family member',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: MamaCareColors.accentDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: MamaCareColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    Appointment appt,
    bool isCompleted,
    bool isSwahili,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MamaCard(
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appt.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCompleted ? MamaCareColors.successSurface : MamaCareColors.secondarySurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted ? MamaCareColors.success : MamaCareColors.secondary,
                    ),
                  ),
                  child: Text(
                    isCompleted
                        ? (isSwahili ? 'Imekamilika' : 'Completed')
                        : (isSwahili ? 'Imeratibiwa' : 'Scheduled'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? MamaCareColors.success : MamaCareColors.secondaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: MamaCareColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(appt.appointmentDate),
                  style: const TextStyle(fontSize: 13, color: MamaCareColors.textSecondary),
                ),
              ],
            ),
            if (appt.notes != null && appt.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '📝 ${appt.notes}',
                style: const TextStyle(fontSize: 12, color: MamaCareColors.textPrimary),
              ),
            ],
            if (appt.testsConducted != null && appt.testsConducted!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MamaCareColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.biotech, size: 16, color: MamaCareColors.info),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Vipimo: ${appt.testsConducted}',
                        style: const TextStyle(fontSize: 11, color: MamaCareColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isCompleted) ...[
              const Divider(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showCompleteDialog(context, ref, appt, isSwahili),
                  icon: const Icon(Icons.check_circle, size: 16, color: MamaCareColors.success),
                  label: Text(
                    isSwahili ? 'Tia Alama ya Kukamilika' : 'Mark as Completed',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: MamaCareColors.success),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
