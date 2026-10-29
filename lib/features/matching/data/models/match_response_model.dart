import 'match_item_model.dart';

class MatchResponseModel {
  const MatchResponseModel({
    required this.matches,
    required this.promptVersion,
  });

  final List<MatchItemModel> matches;
  final String promptVersion;

  factory MatchResponseModel.fromJson(Map<String, dynamic> json) {
    final items = (json['matches'] as List? ?? [])
        .map((e) => MatchItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MatchResponseModel(
      matches: items,
      promptVersion: json['promptVersion'] as String? ?? 'unknown',
    );
  }
}
