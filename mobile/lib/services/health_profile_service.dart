import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_profile.dart';

/// Stores the health profile on the device.
///
/// shared_preferences rather than a database: the profile is a single
/// small record, and adding a database engine for one row would cost APK
/// size for nothing. Vitals and history, which are lists that grow, may
/// justify one later.
class HealthProfileService {
  static const _profileKey = 'health_profile';
  static const _skippedKey = 'health_profile_setup_skipped';

  Future<HealthProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      return HealthProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt or from an older shape - treat as absent rather than
      // crashing the home screen on launch.
      return null;
    }
  }

  Future<void> save(HealthProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    // Saving supersedes any earlier skip.
    await prefs.remove(_skippedKey);
  }

  Future<bool> hasProfile() async => (await load()) != null;

  /// The user declined setup. Recorded so they aren't asked again on every
  /// launch - the profile stays reachable from the home screen.
  Future<void> markSetupSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skippedKey, true);
  }

  Future<bool> wasSetupSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skippedKey) ?? false;
  }

  /// True only on a genuinely fresh install where setup hasn't been
  /// offered yet.
  Future<bool> shouldOfferSetup() async {
    if (await hasProfile()) return false;
    return !(await wasSetupSkipped());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_skippedKey);
  }
}
