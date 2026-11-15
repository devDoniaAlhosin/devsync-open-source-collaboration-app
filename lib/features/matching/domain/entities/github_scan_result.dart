class GithubScanResult {
  const GithubScanResult({
    required this.username,
    required this.publicRepos,
    required this.languages,
    required this.commitsLastYear,
    this.languagePercents = const {},
  });

  final String username;
  final int publicRepos;

  /// Languages ordered by usage (highest first).
  final List<String> languages;

  /// Percent share per language name (sums to 100 when non-empty).
  final Map<String, int> languagePercents;

  final int commitsLastYear;

  int get languageCount => languages.length;

  String get languagesSummary {
    const shown = 3;
    final head = languages.take(shown).join(', ');
    final extra = languages.length - shown;
    return extra > 0 ? '$head +$extra' : head;
  }
}
