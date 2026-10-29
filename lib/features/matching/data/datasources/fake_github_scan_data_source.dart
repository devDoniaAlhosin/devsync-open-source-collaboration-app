import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/github_scan_result.dart';

class FakeGithubScanDataSource {
  const FakeGithubScanDataSource();

  Future<GithubScanResult> scan(String username) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return GithubScanResult(
      username: username,
      publicRepos: 18,
      languages: const ['Dart', 'Python', 'JS', 'Kotlin', 'HTML'],
      commitsLastYear: 940,
    );
  }
}
