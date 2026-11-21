import 'match_item_model.dart';

class MatchResponseModel {
  const MatchResponseModel({
    required this.matches,
    required this.promptVersion,
    this.fallback = false,
  });

  final List<MatchItemModel> matches;
  final String promptVersion;
  final bool fallback;

  factory MatchResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['matches'];
    final version = json['promptVersion'];
    final fallback = (json['fallback'] ?? json['isFallback']) as bool? ?? false;
    if (rawItems is! List || version is! String || version.trim().isEmpty) {
      throw const FormatException('Invalid matching response');
    }
    final ids = <String>{};
    final items = <MatchItemModel>[];
    for (final item in rawItems) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid match');
      }
      final match = MatchItemModel.fromJson(item);
      if (!ids.add(match.projectId)) {
        throw const FormatException('Duplicate project match');
      }
      items.add(match);
    }

    return MatchResponseModel(
      matches: List.unmodifiable(items),
      promptVersion: version,
      fallback: fallback,
    );
  }
}
