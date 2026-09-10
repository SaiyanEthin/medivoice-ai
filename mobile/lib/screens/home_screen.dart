import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/health_profile.dart';
import '../services/health_profile_service.dart';
import '../services/language_prefs_service.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'health_profile_screen.dart';
import 'how_it_works_screen.dart';
import 'language_select_screen.dart';
import 'voice_input_screen.dart';

/// Landing screen. Introduces the app and starts a new consultation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _profileService = HealthProfileService();
  HealthProfile? _profile;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      if (await _profileService.shouldOfferSetup()) {
        if (!mounted) return;
        // After the first frame so the home screen is behind it rather
        // than the setup form appearing out of nowhere.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HealthProfileScreen(isSetup: true),
            ),
          );
          _refreshProfile();
        });
        return;
      }
      _refreshProfile();
    } catch (_) {
      // Storage unavailable - the home screen still works without a
      // profile, so fail quietly rather than blocking the app.
    }
  }

  Future<void> _refreshProfile() async {
    final profile = await _profileService.load();
    if (mounted) setState(() => _profile = profile);
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HealthProfileScreen()),
    );
    _refreshProfile();
  }

  /// First-ever consultation routes through the one-time language picker.
  /// [speakNow] carries through so the mic can be live on arrival.
  Future<void> _startConsultation(
    BuildContext context, {
    bool speakNow = false,
  }) async {
    final hasPreference = await LanguagePrefsService().hasPreference();
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => hasPreference
            ? VoiceInputScreen(autoStartRecording: speakNow)
            : LanguageSelectScreen(autoStartRecording: speakNow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(profile: _profile, onProfileTap: _openProfile),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StartCard(
                    onStart: () => _startConsultation(context),
                    onSpeakNow: () =>
                        _startConsultation(context, speakNow: true),
                  ),
                  const SizedBox(height: 14),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _FeatureTile(
                            icon: Icons.wifi_off_rounded,
                            title: AppText.of(context).homeWorksOffline,
                            body: AppText.of(context).homeNoInternet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FeatureTile(
                            icon: Icons.lock_outline_rounded,
                            title: AppText.of(context).homeStaysPrivate,
                            body: AppText.of(context).homeNothingLeaves,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardScreen()),
                    ),
                    icon: const Icon(Icons.dashboard_outlined, size: 18),
                    label: Text(AppText.of(context).homeDashboard),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                      // Deleting health data from Settings clears the
                      // profile, so the greeting has to be re-read.
                      _refreshProfile();
                    },
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: Text(AppText.of(context).homeSettings),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HowItWorksScreen()),
                    ),
                    icon: const Icon(Icons.help_outline_rounded, size: 18),
                    label: Text(AppText.of(context).homeHowItWorks),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppText.of(context).homeDisclaimer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HealthProfile? profile;
  final VoidCallback onProfileTap;

  const _Header({required this.profile, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final name = profile?.greetingName ?? '';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 34,
        left: 24,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety_rounded,
                    size: 28, color: Colors.white),
              ),
              const Spacer(),
              IconButton(
                onPressed: onProfileTap,
                tooltip: AppText.of(context).homeProfileTooltip,
                icon: Icon(
                  name.isEmpty
                      ? Icons.person_add_alt_1_outlined
                      : Icons.person_outline_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name.isEmpty
                ? "MediVoice AI"
                : AppText.of(context).homeGreeting(name),
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name.isEmpty
                ? AppText.of(context).homeTagline
                : AppText.of(context).homeGreetingSub,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSpeakNow;
  const _StartCard({required this.onStart, required this.onSpeakNow});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppText.of(context).homeHowAreYou,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              AppText.of(context).homeTellMe,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            // Shortcut: opens the consultation with the microphone already
            // listening, so describing a symptom is a single tap.
            Center(child: _SpeakNowButton(onTap: onSpeakNow)),
            const SizedBox(height: 10),
            Center(
              child: Text(AppText.of(context).homeTapToSpeak,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.keyboard_alt_outlined, size: 18),
                label: Text(AppText.of(context).homeStartConsultation),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LanguageChip(label: "\u0c95\u0ca8\u0ccd\u0ca8\u0ca1"),
                SizedBox(width: 8),
                _LanguageChip(label: "\u0939\u093f\u0902\u0926\u0940"),
                SizedBox(width: 8),
                _LanguageChip(label: "English"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Large circular microphone. Deliberately the most prominent control on
/// the screen: speaking is the primary interaction, and typing is the
/// fallback rather than the other way round.
class _SpeakNowButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SpeakNowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: AppTheme.danger,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: AppTheme.danger.withOpacity(0.5),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 92,
            height: 92,
            child: Icon(Icons.mic_rounded, size: 44, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryDark, size: 22),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  const _LanguageChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
