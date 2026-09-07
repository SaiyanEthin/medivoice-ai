import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How large text should be, app-wide.
///
/// Named steps rather than a free slider: a slider invites values that
/// break layouts, and "Large" is easier to choose than "1.25".
enum TextSizeOption { normal, large, larger, largest }

extension TextSizeOptionInfo on TextSizeOption {
  String get label {
    switch (this) {
      case TextSizeOption.normal:
        return 'Normal';
      case TextSizeOption.large:
        return 'Large';
      case TextSizeOption.larger:
        return 'Larger';
      case TextSizeOption.largest:
        return 'Largest';
    }
  }

  /// The ceiling is 1.4 on purpose. Past that the two-column vitals grid
  /// and the follow-up answer buttons wrap badly; raising it would mean
  /// reworking those layouts first.
  double get scale {
    switch (this) {
      case TextSizeOption.normal:
        return 1.0;
      case TextSizeOption.large:
        return 1.15;
      case TextSizeOption.larger:
        return 1.28;
      case TextSizeOption.largest:
        return 1.4;
    }
  }

  String get storageKey => name;
}

/// Holds the choice and notifies the app so it can rebuild at the root.
///
/// A ValueNotifier rather than a plain singleton: changing text size has
/// to rebuild everything, and this lets the root widget listen without a
/// state-management package.
class TextScalePrefs extends ValueNotifier<TextSizeOption> {
  static final TextScalePrefs _instance = TextScalePrefs._internal();
  factory TextScalePrefs() => _instance;
  TextScalePrefs._internal() : super(TextSizeOption.normal);

  static const _key = 'text_size';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_key);
      for (final option in TextSizeOption.values) {
        if (option.storageKey == stored) {
          value = option;
          return;
        }
      }
    } catch (_) {
      // Normal size is a safe fallback.
    }
  }

  Future<void> set(TextSizeOption option) async {
    value = option; // notifies listeners, so the app rescales immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, option.storageKey);
    } catch (_) {
      // The change still applies this session.
    }
  }
}
