import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_match_card.dart';
import '../../data/datasources/matching_local_data_source.dart';
import '../../data/datasources/matching_remote_data_source.dart';
import '../../data/repositories/matching_repository_impl.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/match_card_skeleton.dart';

/// Ranked AI-match feed screen (FR-11 to FR-14, NFR-01).
///
/// Shows a scrollable list of [DsMatchCard] widgets ranked by fit score.
/// Handles loading, empty, fallback-notice, and error states.
///
/// **Owner:** Emad · **Route:** [AppRoutes.feed]
class MatchFeedScreen extends StatefulWidget {
  const MatchFeedScreen({super.key});

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  // ---------- State ----------
  late final MatchingRepositoryImpl _repository;
  List<MatchItem> _matches = [];
  bool _isLoading = true;
  bool _hasFallback = false;
  String? _errorMessage;

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  @override
  void initState() {
    super.initState();
    // Wire data sources — swap mocks for real ones once Firebase lands.
    _repository = MatchingRepositoryImpl(
      remoteDataSource: MockMatchingRemoteDataSource(),
      localDataSource: InMemoryMatchingLocalDataSource(),
    );
    _loadMatches();
  }

  Widget _buildBody() {
    // Loading state with skeleton placeholders
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => const MatchCardSkeleton(),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return DsEmptyState(
        icon: AppIcons.error,
        title: 'Something went wrong',
        message: _errorMessage!,
        actionLabel: 'Retry',
        onAction: _loadMatches,
      );
    }

    // Empty state
    if (_matches.isEmpty) {
      return DsEmptyState(
        icon: AppIcons.feed,
        title: 'No matches yet',
        message:
            'Complete your profile and add skills so we can find projects for you.',
        actionLabel: 'Refresh',
        onAction: _loadMatches,
      );
    }

    final palette = DevSyncPalette.of(context);

    // Loaded state
    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: _matches.length + (_hasFallback ? 1 : 0),
        itemBuilder: (context, index) {
          // Fallback notice banner at position 0
          if (_hasFallback && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: DsCard(
                tone: DsCardTone.inset,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const DsIcon(
                      AppIcons.info,
                      size: 20,
                      color: AppColors.teal,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'AI matching is temporarily unavailable. Showing skills-based results.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final matchIndex = _hasFallback ? index - 1 : index;
          final match = _matches[matchIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: DsMatchCard(
              projectName: match.projectName,
              subtitle: match.description,
              score: match.score,
              reason: match.reason,
              skills: match.neededSkills,
              onRequest: () {
                // TODO: Navigate to collaboration request (Yousef's feature).
              },
              onSkip: () {
                // TODO: Record skip feedback in Firestore (Yousef's like/skip).
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with the real user profile from Saga's profile feature.
      final profile = UserProfile(
        uid: 'demo-user',
        declaredSkills: ['Flutter', 'Dart', 'Firebase'],
        githubLanguages: {'Dart': 60, 'Python': 20, 'JavaScript': 10},
        publicRepoCount: 12,
        totalContributions: 340,
        bio: 'Mobile developer interested in open source.',
      );

      final results = await _repository.getRankedMatches(profile);

      if (!mounted) return;
      setState(() {
        _matches = results;
        _hasFallback = results.any((m) => m.isFallback);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load matches. Please try again.';
      });
    }
  }
}
