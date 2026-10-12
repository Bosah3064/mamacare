// ============================================
// MamaCare KE - Main Application Entrypoint
// ============================================
// "Your pregnancy companion, connected to care."
// AI-Powered Maternal Wellbeing & Communication
// for expectant mothers across Kenya.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/i18n/app_localizations.dart';
import 'core/models/models.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/main_shell.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint(
      'MamaCare KE: .env file not found or failed to load ($e). Using default config.',
    );
  }

  // Initialize Supabase backend or fallback to realistic demo mode
  await SupabaseService.instance.initialize();

  runApp(const ProviderScope(child: MamaCareApp()));
}

class MamaCareApp extends ConsumerWidget {
  const MamaCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final activeLocale = language == Language.sw
        ? AppLocales.kiswahili
        : AppLocales.english;

    return MaterialApp(
      title: 'MamaCare KE',
      debugShowCheckedModeBanner: false,
      theme: MamaCareTheme.lightTheme,
      themeMode: ThemeMode.light,
      locale: activeLocale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}

/// Dynamic routing gate based on real authentication & onboarding status
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.unknown:
        return const _SplashScreen();
      case AuthStatus.unauthenticated:
        return const WelcomeScreen();
      case AuthStatus.onboarding:
        return const OnboardingScreen();
      case AuthStatus.authenticated:
        return const MainShell();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: MamaCareColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/logo_emblem.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    decoration: BoxDecoration(
                      gradient: MamaCareColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'MamaCare KE',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: MamaCareColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your pregnancy companion, connected to care',
              style: TextStyle(
                fontSize: 13,
                color: MamaCareColors.textSecondary,
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  MamaCareColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
