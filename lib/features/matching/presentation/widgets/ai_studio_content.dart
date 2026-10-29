import 'package:flutter/material.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/entities/matching_preferences.dart';
import 'ai_studio_preferences_card.dart';
import 'ai_studio_scoring_card.dart';
import 'ai_studio_suggested_matches_card.dart';

/// Shared Studio layout accepting values and callbacks from any state manager.
class AiStudioContent extends StatefulWidget {
  const AiStudioContent({
    super.key,
    required this.onPromptChanged,
    required this.preferences,
    required this.matches,
    required this.scoringBreakdown,
    required this.isGenerating,
    required this.onTagToggled,
    required this.onGenerateMatches,
    required this.onViewProjectDetails,
    required this.onExploreAnalytics,
  });
  final ValueChanged<String> onPromptChanged;
  final MatchingPreferences preferences;
  final List<MatchItem> matches;
  final Map<String, int> scoringBreakdown;
  final bool isGenerating;
  final ValueChanged<String> onTagToggled;
  final VoidCallback onGenerateMatches;
  final ValueChanged<MatchItem> onViewProjectDetails;
  final VoidCallback onExploreAnalytics;
  @override
  State<AiStudioContent> createState() => _AiStudioContentState();
}

class _AiStudioContentState extends State<AiStudioContent> {
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.preferences.prompt);
    _promptController.addListener(_onPromptChanged);
  }

  void _onPromptChanged() {
    if (_promptController.text != widget.preferences.prompt) {
      widget.onPromptChanged(_promptController.text);
    }
  }

  @override
  void didUpdateWidget(covariant AiStudioContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_promptController.text != widget.preferences.prompt) {
      _promptController.value = TextEditingValue(
        text: widget.preferences.prompt,
        selection: TextSelection.collapsed(
          offset: widget.preferences.prompt.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _IntelligenceBanner(),
          const SizedBox(height: AppSpacing.md),

          AiStudioPreferencesCard(
            promptController: _promptController,
            selectedTags: widget.preferences.selectedTags,
            onTagToggled: widget.onTagToggled,
            isGenerating: widget.isGenerating,
            onGenerateMatches: widget.onGenerateMatches,
          ),
          const SizedBox(height: AppSpacing.md),

          AiStudioSuggestedMatchesCard(
            matches: widget.matches,
            onViewProjectDetails: widget.onViewProjectDetails,
          ),
          const SizedBox(height: AppSpacing.md),

          AiStudioScoringCard(
            breakdown: widget.scoringBreakdown,
            onExploreAnalytics: widget.onExploreAnalytics,
          ),
        ],
      ),
    );
  }
}

class _IntelligenceBanner extends StatelessWidget {
  const _IntelligenceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: context.ds.surface,
        border: Border.all(color: context.ds.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Row(
        children: [
          DsIcon(AppIcons.sparkle, color: AppColors.teal, size: 16),
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              'DEVSYNC INTELLIGENCE / BETA',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
