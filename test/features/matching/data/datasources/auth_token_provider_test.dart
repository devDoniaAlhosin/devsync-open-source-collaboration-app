import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/auth_token_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_token_provider_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User])
void main() {
  group('FirebaseAuthTokenProvider', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late FirebaseAuthTokenProvider provider;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      provider = FirebaseAuthTokenProvider(mockAuth);
    });

    test('returns ID token when user is signed in', () async {
      const testToken = 'test-firebase-id-token-123';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(any)).thenAnswer((_) async => testToken);

      final token = await provider.getIdToken();

      expect(token, testToken);
      verify(mockUser.getIdToken(false)).called(1);
    });

    test('returns null when no user is signed in', () async {
      when(mockAuth.currentUser).thenReturn(null);

      final token = await provider.getIdToken();

      expect(token, isNull);
    });

    test('forces token refresh when requested', () async {
      const refreshedToken = 'refreshed-token-456';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(any)).thenAnswer((_) async => refreshedToken);

      final token = await provider.getIdToken(forceRefresh: true);

      expect(token, refreshedToken);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('throws AuthTokenException when Firebase auth fails', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(
        mockUser.getIdToken(any),
      ).thenThrow(FirebaseAuthException(code: 'token-expired'));

      expect(() => provider.getIdToken(), throwsA(isA<AuthTokenException>()));
    });

    test('throws AuthTokenException on unexpected errors', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(any)).thenThrow(Exception('Network error'));

      expect(() => provider.getIdToken(), throwsA(isA<AuthTokenException>()));
    });
  });
}
