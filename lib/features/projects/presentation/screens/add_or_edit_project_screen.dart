import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ds_page_fade.dart';
import '../../domain/entities/project.dart';
import '../../project_layout.dart';
import '../widgets/project_action_button.dart';
import '../widgets/project_background.dart';
import '../widgets/project_form_field.dart';
import '../widgets/project_preview_card.dart';
import '../widgets/skill_selector.dart';
import '../widgets/workspace_header.dart';

class AddOrEditProjectScreen extends StatefulWidget {
  const AddOrEditProjectScreen({this.initialProject, super.key});

  final Project? initialProject;

  @override
  State<AddOrEditProjectScreen> createState() => _AddOrEditProjectScreenState();
}

class _AddOrEditProjectScreenState extends State<AddOrEditProjectScreen> {
  static const _baseSkills = <String>[
    'Dart',
    'Flutter',
    'Firebase',
    'TypeScript',
    'Testing',
    'Design',
    'Animation',
    'React',
    'Python',
    'Docs',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _githubController;
  late final Set<String> _selectedSkills;
  final _customSkills = <String>[];
  String? _skillsError;

  List<String> get _availableSkills => [..._baseSkills, ..._customSkills];

  @override
  void initState() {
    super.initState();
    final project = widget.initialProject;
    _titleController = TextEditingController(text: project?.title ?? '');
    _descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    _githubController = TextEditingController(text: project?.githubUrl ?? '');
    _selectedSkills = {
      ...(project?.techStack ?? const ['Flutter', 'Firebase', 'Dart']),
    };
    _customSkills.addAll(
      _selectedSkills.where((skill) => !_baseSkills.contains(skill)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
      _skillsError = null;
    });
  }

  Future<void> _addCustomSkill() async {
    var draft = '';
    final skill = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add a skill'),
          content: TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: Theme.of(context).textTheme.titleMedium,
            decoration: const InputDecoration(hintText: 'e.g. WebRTC'),
            onChanged: (value) => draft = value,
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(draft),
              child: const Text(
                'Add skill',
                style: TextStyle(color: AppColors.teal),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || skill == null || skill.trim().isEmpty) {
      return;
    }

    final normalized = skill.trim();
    final existing = _availableSkills.firstWhere(
      (item) => item.toLowerCase() == normalized.toLowerCase(),
      orElse: () => normalized,
    );

    setState(() {
      if (!_availableSkills.contains(existing)) {
        _customSkills.add(existing);
      }
      _selectedSkills.add(existing);
      _skillsError = null;
    });
  }

  void _saveProject() {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    final hasSkills = _selectedSkills.isNotEmpty;

    if (!hasSkills) {
      setState(() {
        _skillsError = 'Choose at least one skill needed.';
      });
    }

    if (!isValid || !hasSkills) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final githubUrl = _normalizeGithub(_githubController.text);
    final skills = [
      for (final skill in _availableSkills)
        if (_selectedSkills.contains(skill)) skill,
    ];

    final existing = widget.initialProject;
    final project = existing == null
        ? Project(
            id: 'project-${DateTime.now().microsecondsSinceEpoch}',
            title: title,
            description: description,
            githubUrl: githubUrl,
            techStack: skills,
            requiredContributors: 2,
            viewsCount: 0,
            requestsCount: 0,
            matchPercentage: 92,
            isOwner: true,
          )
        : existing.copyWith(
            title: title,
            description: description,
            githubUrl: githubUrl,
            techStack: skills,
          );

    Navigator.of(context).pop(project);
  }

  String _normalizeGithub(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  String? _validateGithub(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Add your GitHub repository link.';
    }
    final normalized = _normalizeGithub(value);
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasAuthority ||
        !uri.host.toLowerCase().contains('github.com')) {
      return 'Use a valid github.com repository link.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProjectBackground(
        child: DsPageFade(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                WorkspaceHeader(
                  title: 'Add or edit project',
                  maxContentWidth: ProjectLayout.formWidth,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gutter = ProjectLayout.gutterFor(
                      constraints.maxWidth,
                    );
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 28),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ProjectLayout.formWidth,
                          ),
                          child: LayoutBuilder(
                            builder: (context, contentConstraints) {
                              final isWide = contentConstraints.maxWidth >= 880;
                              if (isWide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 350,
                                      child: _buildPreview(),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(child: _buildForm()),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPreview(),
                                  const SizedBox(height: 20),
                                  _buildForm(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ),
      ),
      bottomNavigationBar: _SaveBar(
        label: 'Save project',
        onPressed: _saveProject,
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectPreviewCard(
          title: _titleController.text,
          skills: [
            for (final skill in _availableSkills)
              if (_selectedSkills.contains(skill)) skill,
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'This is how your project appears in Discover.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.ds.textMuted,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectFormField(
            label: 'Title',
            controller: _titleController,
            hint: 'devsync-api',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return 'Give your project a title.';
              }
              if (text.length > 60) {
                return 'Keep the title under 60 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          ProjectFormField(
            label: 'Description',
            controller: _descriptionController,
            hint: 'REST and Cloud Functions backend for DevSync.',
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Describe what you are building.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          ProjectFormField(
            label: 'GitHub link',
            controller: _githubController,
            hint: 'github.com/devsync/api',
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            suffixIcon: AppIcons.code,
            validator: _validateGithub,
          ),
          const SizedBox(height: 22),
          SkillSelector(
            availableSkills: _availableSkills,
            selectedSkills: _selectedSkills,
            onToggle: _toggleSkill,
            onAddSkill: _addCustomSkill,
            errorText: _skillsError,
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        height: 56,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ProjectLayout.formWidth,
            ),
            child: ProjectActionButton(label: label, onPressed: onPressed),
          ),
        ),
      ),
    );
  }
}
