// ============================================
// MamaCare KE - Main Navigation Shell
// ============================================
// Bottom navigation shell orchestrating Home,
// Mama AI, ANC Visits, Health Diary, and Care.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import 'anc_screen.dart';
import 'anc_summary_screen.dart';
import 'chat_screen.dart';
import 'emergency_screen.dart';
import 'facilities_screen.dart';
import 'family_screen.dart';
import 'health_diary_screen.dart';
import 'home_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openEmergencyScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EmergencyScreen()),
    );
  }

  void _openSummaryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AncSummaryScreen()),
    );
  }

  void _openFamilyScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FamilyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final isSwahili = currentLang == Language.sw;

    final authState = ref.watch(authProvider);
    final user = authState.userProfile;
    final motherName = user?.fullName ?? (isSwahili ? 'Mama' : 'Mother');
    final motherEmail = user?.email ?? user?.phone ?? 'Online Session';
    final isDemo = user?.demoMode ?? SupabaseService.instance.isDemoMode;

    final List<Widget> pages = [
      HomeScreen(
        onNavigateToTab: _onNavigateToTab,
        onOpenEmergency: _openEmergencyScreen,
      ),
      ChatScreen(
        onOpenEmergency: _openEmergencyScreen,
        onOpenFacilities: () => _onNavigateToTab(4),
      ),
      AncScreen(
        onOpenSummary: _openSummaryScreen,
      ),
      const HealthDiaryScreen(),
      const FacilitiesScreen(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: MamaCareColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/logo_emblem.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.favorite_rounded,
                              color: MamaCareColors.primary,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isDemo ? const Color(0xFFFBBF24) : const Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isDemo ? 'Demo Mode' : 'Live Supabase',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    motherName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    motherEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline, color: MamaCareColors.secondary),
              title: Text(isSwahili ? 'Njia ya Familia (Family Mode)' : 'Family Support Mode'),
              subtitle: Text(isSwahili ? 'Mpe mume au mlezi idhini' : 'Invite partner or family'),
              onTap: () {
                Navigator.pop(context);
                _openFamilyScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: MamaCareColors.primary),
              title: Text(isSwahili ? 'Muhtasari wa Kliniki ya ANC' : 'ANC Clinical Summary'),
              subtitle: Text(isSwahili ? 'Tolea nesi au daktari' : 'Handoff summary for clinic'),
              onTap: () {
                Navigator.pop(context);
                _openSummaryScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.emergency_outlined, color: MamaCareColors.error),
              title: Text(isSwahili ? 'Dharura ya Uzazi (1199)' : 'Maternal Emergency (1199)'),
              subtitle: Text(isSwahili ? 'Dalili za hatari na uokoaji' : 'Red flags & ambulance'),
              onTap: () {
                Navigator.pop(context);
                _openEmergencyScreen();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language, color: MamaCareColors.accent),
              title: Text(isSwahili ? 'Badilisha Lugha' : 'Switch Language'),
              trailing: Text(
                isSwahili ? '🇰🇪 Kiswahili' : '🇬🇧 English',
                style: const TextStyle(fontWeight: FontWeight.bold, color: MamaCareColors.primary),
              ),
              onTap: () {
                ref.read(languageProvider.notifier).toggleLanguage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: MamaCareColors.error),
              title: Text(
                isSwahili ? 'Toka Kwenye Akaunti' : 'Sign Out',
                style: const TextStyle(color: MamaCareColors.error, fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(isSwahili ? 'Je, ungependa kutoka?' : 'Sign Out?'),
                    content: Text(
                      isSwahili
                          ? 'Utahitaji kuingia tena ili kupata kumbukumbu zako za afya.'
                          : 'You will need to log back in to access your pregnancy care records.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(isSwahili ? 'Ghairi' : 'Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MamaCareColors.error,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isSwahili ? 'Toka' : 'Sign Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authProvider.notifier).signOut();
                }
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigateToTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: MamaCareColors.primary,
          unselectedItemColor: MamaCareColors.textTertiary,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: isSwahili ? 'Nyumbani' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_outlined),
              activeIcon: const Icon(Icons.auto_awesome),
              label: 'Mama AI',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month_rounded),
              label: isSwahili ? 'Kliniki' : 'ANC Visits',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline_rounded),
              activeIcon: const Icon(Icons.favorite_rounded),
              label: isSwahili ? 'Shajara' : 'Diary',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.local_hospital_outlined),
              activeIcon: const Icon(Icons.local_hospital),
              label: isSwahili ? 'Hospitali' : 'Care',
            ),
          ],
        ),
      ),
    );
  }
}
