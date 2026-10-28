import '../entities/match_item.dart';
import '../repositories/matching_repository.dart';

/// Use case for generating matches dynamically based on natural language prompt and tags.
class GenerateMatchesUseCase {
  const GenerateMatchesUseCase(this._repository);

  final MatchingRepository _repository;

  Future<List<MatchItem>> call({required String prompt, Set<String>? tags}) {
    return _repository.generateMatchesWithPrompt(prompt: prompt, tags: tags);
  }
}
