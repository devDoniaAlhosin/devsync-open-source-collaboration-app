class GithubScanResult {
  const GithubScanResult({
    required this.username,
    required this.publicRepos,
    required this.languages,
    required this.commitsLastYear,
  });

  final String username;
  final int publicRepos;

  final List<String> languages;
  final int commitsLastYear;

  int get languageCount => languages.length;

  String get languagesSummary {
    const shown = 3;
    final head = languages.take(shown).join(', ');
    final extra = languages.length - shown;
    return extra > 0 ? '$head +$extra' : head;
  }
}
