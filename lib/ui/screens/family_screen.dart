// ============================================
// MamaCare KE - Family Mode Screen
// ============================================
// Granular family sharing for partners & guardians
// to receive ANC reminders, progress, and SOS alerts.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/mama_card.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  void _showInviteSheet(BuildContext context, WidgetRef ref, bool isSwahili) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+2547');
    String relationship = isSwahili ? 'Mume (Husband)' : 'Husband';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
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
                    isSwahili ? 'Alika Mwanafamilia' : 'Invite Family Member',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isSwahili ? 'Jina Kamili' : 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isSwahili ? 'Nambari ya Simu (+254...)' : 'Phone Number (+254...)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: relationship,
                decoration: InputDecoration(
                  labelText: isSwahili ? 'Uhusiano' : 'Relationship',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  DropdownMenuItem(
                    value: isSwahili ? 'Mume (Husband)' : 'Husband',
                    child: Text(isSwahili ? 'Mume / Mwenzi' : 'Husband / Partner'),
                  ),
                  DropdownMenuItem(
                    value: isSwahili ? 'Mama Mzazi (Mother)' : 'Mother',
                    child: Text(isSwahili ? 'Mama Mzazi' : 'Mother'),
                  ),
                  DropdownMenuItem(
                    value: isSwahili ? 'Dada / Kaka (Sibling)' : 'Sibling',
                    child: Text(isSwahili ? 'Dada / Kaka' : 'Sister / Brother'),
                  ),
                  DropdownMenuItem(
                    value: isSwahili ? 'Mlezi (Guardian)' : 'Guardian',
                    child: Text(isSwahili ? 'Mlezi' : 'Guardian'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) relationship = val;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MamaCareColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;

                    final userProfile = ref.read(userProfileProvider).value;
                    final currentUid = SupabaseService.instance.currentUserId;
                    final connection = FamilyConnection(
                      id: const Uuid().v4(),
                      userId: userProfile?.id ?? currentUid ?? SupabaseService.defaultSeedUserId,
                      familyMemberName: nameCtrl.text.trim(),
                      familyMemberPhone: phoneCtrl.text.trim(),
                      relationship: relationship,
                      status: FamilyConnectionStatus.active,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    await SupabaseService.instance.addFamilyConnection(connection);
                    ref.invalidate(familyConnectionsProvider);

                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                  child: Text(
                    isSwahili ? 'Tuma Mwaliko' : 'Send Invitation',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final familyAsync = ref.watch(familyConnectionsProvider);

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        title: Text(
          isSwahili ? 'Njia ya Familia (Family Mode)' : 'Family Support Mode',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MamaCareColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: Text(
          isSwahili ? 'Alika Mwanafamilia' : 'Invite Family',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showInviteSheet(context, ref, isSwahili),
      ),
      body: familyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (connections) {
          return ListView(
            padding: const EdgeInsets.all(MamaCareSpacing.md),
            children: [
              // ── Description Card ──
              MamaCard(
                color: MamaCareColors.secondarySurface,
                border: Border.all(color: MamaCareColors.secondaryLight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.people_outline, color: MamaCareColors.secondaryDark, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSwahili ? 'Ushiriki Salama wa Familia' : 'Safe Family Sharing',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MamaCareColors.secondaryDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSwahili
                                ? 'Mpe mume au mlezi idhini ya kuona maendeleo ya mtoto, vikumbusho vya kliniki, na kupokea tahadhari pindi unapohitaji msaada wa dharura.'
                                : 'Grant your partner or family member controlled access to clinic schedules, baby progress, and instant emergency alerts.',
                            style: const TextStyle(fontSize: 12, height: 1.4, color: MamaCareColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                isSwahili ? 'Wanafamilia Waliounganishwa' : 'Connected Family Members',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (connections.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Text(
                    isSwahili ? 'Bado hujaongeza mwanafamilia yeyote.' : 'No family members connected yet.',
                    style: const TextStyle(color: MamaCareColors.textSecondary),
                  ),
                )
              else
                ...connections.map((c) => _buildConnectionCard(c, isSwahili)),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionCard(FamilyConnection c, bool isSwahili) {
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: MamaCareColors.secondarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: MamaCareColors.secondaryDark, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.familyMemberName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${c.relationship} • ${c.familyMemberPhone ?? ""}',
                          style: const TextStyle(fontSize: 12, color: MamaCareColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MamaCareColors.successSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isSwahili ? 'Hai (Active)' : 'Active',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: MamaCareColors.success),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Active permissions
            Text(
              isSwahili ? 'Idhini Alizopewa:' : 'Granted Permissions:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MamaCareColors.textTertiary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildPermChip(isSwahili ? '✓ Ratiba ya Kliniki' : '✓ Clinic Schedule'),
                _buildPermChip(isSwahili ? '✓ Tahadhari ya Dharura' : '✓ SOS Emergency Alert'),
                _buildPermChip(isSwahili ? '✓ Maendeleo ya Mtoto' : '✓ Baby Milestones'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MamaCareColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: MamaCareColors.divider),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: MamaCareColors.textPrimary),
      ),
    );
  }
}
