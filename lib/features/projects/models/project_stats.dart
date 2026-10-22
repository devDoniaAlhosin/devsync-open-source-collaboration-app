import 'package:flutter/foundation.dart';

@immutable
class SkillAlignment {
  const SkillAlignment({required this.label, required this.score});

  final String label;
  final int score;
}

@immutable
class ProjectStats {
  const ProjectStats({
    required this.stars,
    required this.contributors,
    required this.openTasks,
    required this.ownerName,
    required this.ownerResponseTime,
    required this.updatedLabel,
    required this.matchSummary,
    required this.alignments,
    required this.matchedSkills,
    required this.weeklyViews,
  });

  final int stars;
  final int contributors;
  final int openTasks;
  final String ownerName;
  final String ownerResponseTime;
  final String updatedLabel;
  final String matchSummary;
  final List<SkillAlignment> alignments;
  final List<String> matchedSkills;
  final List<double> weeklyViews;
}
