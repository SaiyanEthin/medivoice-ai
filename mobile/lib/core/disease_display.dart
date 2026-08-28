/// Raw model class labels -> clean user-facing names.
///
/// The raw strings must stay EXACTLY as the training data has them: the
/// weights JSON, advice templates, and specialist mappings all key off
/// them. So cleanup happens at display time only, never in the data.
String diseaseDisplayName(String raw) => _displayNames[raw.trim()] ?? raw;

const Map<String, String> _displayNames = {
  // Dataset label is misspelled ("Paroymsal"), double-spaced, and repeats
  // "vertigo" in its own parenthetical.
  '(vertigo) Paroymsal  Positional Vertigo': 'Vertigo (BPPV)',
};
