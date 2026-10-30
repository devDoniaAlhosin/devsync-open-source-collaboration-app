import '../domain/entities/match_item.dart';

/// In-memory liked / hearted matches until Firestore likes land.
///
/// Feed "request" (heart) actions append here; [LikedMatchesScreen] reads it.
class LikedMatchesStore {
  LikedMatchesStore._() {
    _items.addAll(_seed);
  }

  static final LikedMatchesStore instance = LikedMatchesStore._();

  final List<MatchItem> _items = [];

  List<MatchItem> get items => List.unmodifiable(_items);

  void add(MatchItem match) {
    if (_items.any((m) => m.projectId == match.projectId)) return;
    _items.insert(0, match);
  }

  static const _seed = [
    MatchItem(
      projectId: 'flutter-oss-charts',
      projectName: 'flutter-oss/charts',
      description: 'Needs a Dart contributor',
      githubUrl: 'https://github.com/flutter-oss/charts',
      neededSkills: ['Dart', 'Firebase', 'Animation'],
      score: 92,
      reason: 'Strong Dart + animation overlap with your profile.',
    ),
  ];
}
