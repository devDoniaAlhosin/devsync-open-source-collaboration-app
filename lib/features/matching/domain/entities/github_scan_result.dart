class GithubScanResult {
  const GithubScanResult({
    required this.username,
    required this.publicRepos,
    required this.languages,
    required this.commitsLastYear,
    this.languagePercents = const {},
    this.bioSuggestion,
    this.activity = const [],
  });

  final String username;
  final int publicRepos;

  /// Languages ordered by usage (highest first).
  final List<String> languages;

  /// Percent share per language name (sums to 100 when non-empty).
  final Map<String, int> languagePercents;

  final int commitsLastYear;

  /// Prefill for Edit Profile (README or GitHub bio), already truncated.
  final String? bioSuggestion;

  /// Weekly activity grid (weeks × days), intensity 0–4.
  final List<List<int>> activity;

  int get languageCount => languages.length;

  String get languagesSummary {
    const shown = 3;
    final head = languages.take(shown).join(', ');
    final extra = languages.length - shown;
    return extra > 0 ? '$head +$extra' : head;
  }
}
