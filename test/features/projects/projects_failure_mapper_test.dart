import 'dart:async';

import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/data/exceptions/projects_exceptions.dart';
import 'package:devsync_open_source_collaboration_app/features/projects/data/mappers/projects_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapProjectsError', () {
    test('maps not found', () {
      expect(
        mapProjectsError(const ProjectNotFoundException()),
        isA<NotFoundFailure>(),
      );
    });

    test('maps forbidden', () {
      final failure = mapProjectsError(const ProjectForbiddenException());
      expect(failure, isA<PermissionFailure>());
      expect(failure.message, contains('own projects'));
    });

    test('maps validation', () {
      final failure = mapProjectsError(
        const ProjectValidationException('Project id is required'),
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Project id is required');
    });

    test('maps auth required', () {
      expect(
        mapProjectsError(const AuthRequiredException()),
        isA<AuthFailure>(),
      );
    });

    test('maps timeout as network', () {
      expect(
        mapProjectsError(TimeoutException('Saving project timed out')),
        isA<NetworkFailure>(),
      );
    });
  });
}
