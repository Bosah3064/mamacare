// ============================================
// MamaCare KE - Facilities & Care Navigator
// ============================================
// Kenya healthcare directory covering Level 2-6
// facilities, Linda Mama accreditation, 24/7
// maternity services, and direct ambulance dialing.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/facility_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/mama_card.dart';

class FacilitiesScreen extends ConsumerWidget {
  const FacilitiesScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;
    final filter = ref.watch(facilityFilterProvider);
    final filterNotifier = ref.read(facilityFilterProvider.notifier);
    final facilities = ref.watch(filteredFacilitiesProvider);
    final facilityService = ref.watch(facilityServiceProvider);
    final counties = facilityService.getCounties();

    return Scaffold(
      backgroundColor: MamaCareColors.background,
      appBar: AppBar(
        title: Text(
          isSwahili ? 'Vituo vya Afya & Huduma' : 'Care Facilities & Hospitals',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // ── Search & Filter Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: filterNotifier.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: isSwahili ? 'Tafuta hospitali, mtaa, au eneo...' : 'Search facility name or location...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: MamaCareColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),

                // Filters Row: County & Linda Mama
                Row(
                  children: [
                    // County Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: MamaCareColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: filter.county,
                            hint: Text(isSwahili ? 'Kaunti Zote' : 'All Counties', style: const TextStyle(fontSize: 12)),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(isSwahili ? 'Kaunti Zote' : 'All Counties', style: const TextStyle(fontSize: 12)),
                              ),
                              ...counties.map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: const TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                            onChanged: filterNotifier.setCounty,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Linda Mama Toggle Filter
                    FilterChip(
                      selected: filter.onlyLindaMama,
                      label: Text(
                        'Linda Mama',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: filter.onlyLindaMama ? Colors.white : MamaCareColors.secondaryDark,
                        ),
                      ),
                      selectedColor: MamaCareColors.secondary,
                      backgroundColor: MamaCareColors.secondarySurface,
                      checkmarkColor: Colors.white,
                      onSelected: (_) => filterNotifier.toggleLindaMama(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Emergency Hotlines Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: MamaCareColors.errorSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_in_talk, color: MamaCareColors.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isSwahili ? 'Ambulensi ya Dharura: 1199' : 'Emergency Ambulance: 1199',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: MamaCareColors.error,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: const Size(0, 28),
                    backgroundColor: MamaCareColors.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _makeCall('1199'),
                  child: Text(
                    isSwahili ? 'Piga 1199' : 'Dial 1199',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // ── Facilities List ──
          Expanded(
            child: facilities.isEmpty
                ? Center(
                    child: Text(
                      isSwahili ? 'Hakuna vituo vya afya vilivyopatikana.' : 'No facilities found.',
                      style: const TextStyle(color: MamaCareColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(MamaCareSpacing.md),
                    itemCount: facilities.length,
                    itemBuilder: (context, index) {
                      final f = facilities[index];
                      return _buildFacilityCard(f, isSwahili);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(KenyanFacility f, bool isSwahili) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MamaCard(
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    f.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MamaCareColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MamaCareColors.primaryLight),
                  ),
                  child: Text(
                    f.levelLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MamaCareColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: MamaCareColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${f.address} • ${f.subCounty}, ${f.county}',
                    style: const TextStyle(fontSize: 12, color: MamaCareColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Service Badges
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (f.isLindaMamaAccredited)
                  _buildServiceBadge(
                    'Linda Mama (Bure)',
                    MamaCareColors.secondarySurface,
                    MamaCareColors.secondaryDark,
                  ),
                if (f.has24HrMaternity)
                  _buildServiceBadge(
                    isSwahili ? 'Uzazi 24/7' : '24/7 Maternity',
                    MamaCareColors.successSurface,
                    MamaCareColors.success,
                  ),
                if (f.hasAmbulance)
                  _buildServiceBadge(
                    isSwahili ? 'Ambulensi' : 'Ambulance',
                    MamaCareColors.errorSurface,
                    MamaCareColors.error,
                  ),
                if (f.hasNicu)
                  _buildServiceBadge(
                    'NICU (Watoto Wachanga)',
                    MamaCareColors.infoSurface,
                    MamaCareColors.info,
                  ),
              ],
            ),

            const Divider(height: 20),

            // Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  f.phoneNumber,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  onPressed: () => _makeCall(f.phoneNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MamaCareColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(0, 34),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.phone, size: 14),
                  label: Text(
                    isSwahili ? 'Piga Simu' : 'Call Facility',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBadge(String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol),
      ),
    );
  }
}
