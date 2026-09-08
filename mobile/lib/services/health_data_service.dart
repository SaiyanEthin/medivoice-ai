import 'consultation_history_service.dart';
import 'health_profile_service.dart';
import 'vitals_service.dart';

/// Clears everything the user has stored.
///
/// Exists as its own service so there is ONE place listing every health
/// store. Doing this inline in a screen makes it easy to add a fourth
/// store later and quietly forget to clear it, which for a privacy-first
/// app would be a bad way to find out.
///
/// Preferences - text size, units, voice, language - are settings rather
/// than health data and are deliberately left alone.
class HealthDataService {
  final HealthProfileService _profile;
  final VitalsService _vitals;
  final ConsultationHistoryService _history;

  HealthDataService({
    HealthProfileService? profile,
    VitalsService? vitals,
    ConsultationHistoryService? history,
  })  : _profile = profile ?? HealthProfileService(),
        _vitals = vitals ?? VitalsService(),
        _history = history ?? ConsultationHistoryService();

  Future<void> clearAll() async {
    await _profile.clear();
    await _vitals.clearAll();
    await _history.clear();
  }

  /// Whether there is anything to delete, so the option can be disabled
  /// rather than offering to remove nothing.
  Future<bool> hasAnyData() async {
    if (await _profile.hasProfile()) return true;
    if ((await _vitals.countAll()) > 0) return true;
    if ((await _history.count()) > 0) return true;
    return false;
  }

  /// A short summary of what would be removed, so the confirmation names
  /// what is at stake instead of asking about "your data" in the abstract.
  Future<List<String>> summary() async {
    final items = <String>[];
    if (await _profile.hasProfile()) items.add('Your health profile');
    final vitals = await _vitals.countAll();
    if (vitals > 0) {
      items.add('$vitals vital reading${vitals == 1 ? '' : 's'}');
    }
    final history = await _history.count();
    if (history > 0) {
      items.add('$history past assessment${history == 1 ? '' : 's'}');
    }
    return items;
  }
}
