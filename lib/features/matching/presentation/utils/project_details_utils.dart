String fitLabelForScore(double score) {
  if (score >= 85) return 'Strong fit';
  if (score >= 65) return 'Good fit';
  return 'Potential fit';
}

String projectInitials(String projectName) {
  final parts = projectName
      .split(RegExp(r'[/\s-]'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0];
  return '${parts.first[0]}${parts.last[0]}';
}

String repositoryHost(String value) {
  final uri = Uri.tryParse(value);
  if (uri?.host.isNotEmpty == true) return uri!.host;
  return value;
}

Set<String> normalizedSkills(Iterable<String> skills) => skills
    .map((skill) => skill.trim().toLowerCase())
    .where((skill) => skill.isNotEmpty)
    .toSet();

double? skillCoverageFor({
  required Iterable<String> neededSkills,
  required Iterable<String> currentUserSkills,
}) {
  final needed = normalizedSkills(neededSkills);
  if (needed.isEmpty) return null;
  final current = normalizedSkills(currentUserSkills);
  return needed.where(current.contains).length / needed.length * 100;
}
