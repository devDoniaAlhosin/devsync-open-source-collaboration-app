import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ProjectFilter {
  forYou('For You'),
  trending('Trending'),
  newest('New'),
  beginnerFriendly('Beginner Friendly');

  const ProjectFilter(this.label);

  final String label;
}

class ProjectFilterBar extends StatelessWidget {
  const ProjectFilterBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ProjectFilter selected;
  final ValueChanged<ProjectFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final filter in ProjectFilter.values) ...[
            _FilterChip(
              label: filter.label,
              selected: filter == selected,
              onTap: () => onSelected(filter),
            ),
            if (filter != ProjectFilter.values.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.selected
        ? AppColors.teal
        : (_hovered ? context.ds.surface : Colors.transparent);

    return Semantics(
      button: true,
      selected: widget.selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (value) => setState(() => _hovered = value),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.selected
                    ? AppColors.teal
                    : (_hovered ? context.ds.textMuted : context.ds.border),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: widget.selected
                    ? AppColors.onTeal
                    : context.ds.textPrimary,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
