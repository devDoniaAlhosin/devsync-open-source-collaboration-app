import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CandidateProject', () {
    test('serializes to JSON correctly', () {
      const candidate = CandidateProject(
        projectId: 'proj-1',
        projectName: 'DevSync App',
        description: 'Open source collaboration',
        githubUrl: 'https://github.com/devsync/app',
        neededSkills: ['Flutter', 'Dart'],
        maintainerId: 'user-456',
      );

      final json = candidate.toJson();

      expect(json['projectId'], 'proj-1');
      expect(json['projectName'], 'DevSync App');
      expect(json['description'], 'Open source collaboration');
      expect(json['githubUrl'], 'https://github.com/devsync/app');
      expect(json['neededSkills'], ['Flutter', 'Dart']);
      expect(json['maintainerId'], 'user-456');
    });

    test('omits maintainerId if null', () {
      const candidate = CandidateProject(
        projectId: 'proj-2',
        projectName: 'Widget Lib',
        description: 'UI Widgets',
        githubUrl: 'https://github.com/devsync/widgets',
        neededSkills: ['Flutter'],
      );

      final json = candidate.toJson();

      expect(json.containsKey('maintainerId'), isFalse);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'projectId': 'proj-3',
        'projectName': 'Backend API',
        'description': 'REST service',
        'githubUrl': 'https://github.com/devsync/api',
        'neededSkills': ['Node.js', 'Express'],
        'maintainerId': 'owner-1',
      };

      final candidate = CandidateProject.fromJson(json);

      expect(candidate.projectId, 'proj-3');
      expect(candidate.projectName, 'Backend API');
      expect(candidate.description, 'REST service');
      expect(candidate.githubUrl, 'https://github.com/devsync/api');
      expect(candidate.neededSkills, ['Node.js', 'Express']);
      expect(candidate.maintainerId, 'owner-1');
    });
  });

  group('MatchRequestModel', () {
    const testProfile = UserProfile(
      uid: 'user-123',
      declaredSkills: ['Flutter', 'Dart', 'Firebase'],
      githubLanguages: {'Dart': 45000, 'JavaScript': 12000},
      publicRepoCount: 15,
      totalContributions: 450,
      bio: 'Mobile engineer',
      topRepositories: ['devsync/app'],
    );

    test('fromProfile creates valid model without optional projects', () {
      final request = MatchRequestModel.fromProfile(
        testProfile,
        prompt: 'Prefer beginner issues',
        tags: {'mobile', 'ui'},
      );

      final json = request.toJson();

      expect(json['uid'], 'user-123');
      expect(json['declaredSkills'], ['Flutter', 'Dart', 'Firebase']);
      expect(json['githubLanguages'], {'Dart': 45000, 'JavaScript': 12000});
      expect(json['publicRepoCount'], 15);
      expect(json['totalContributions'], 450);
      expect(json['bio'], 'Mobile engineer');
      expect(json['topRepositories'], ['devsync/app']);
      expect(json['prompt'], 'Prefer beginner issues');
      expect(json['tags'], unorderedEquals(['mobile', 'ui']));
      expect(json.containsKey('projects'), isFalse);
    });

    test('serializes candidates array when projects are supplied', () {
      const candidates = [
        CandidateProject(
          projectId: 'p-1',
          projectName: 'Toolkit',
          description: 'Helpful tools',
          githubUrl: 'https://github.com/example/tools',
          neededSkills: ['Flutter'],
        ),
      ];

      final request = MatchRequestModel.fromProfile(
        testProfile,
        projects: candidates,
      );

      final json = request.toJson();

      expect(json.containsKey('projects'), isTrue);
      final projectsList = json['projects'] as List;
      expect(projectsList.length, 1);
      expect(projectsList.first['projectId'], 'p-1');
      expect(projectsList.first['projectName'], 'Toolkit');
    });
  });
}
