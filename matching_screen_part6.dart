
  Widget _analyticsBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 1),
        const Text(
          'MODEL TRANSPARENCY',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.teal,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Recommendation insights',
          style: TextStyle(
            fontSize: 24,
            height: 1.12,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Understand your feedback and matching trends.',
          style: TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _stat('18', 'Matches rated')),
            const SizedBox(width: 8),
            Expanded(child: _stat('83%', 'Positive signals')),
            const SizedBox(width: 8),
            Expanded(child: _stat('4', 'Skills matched')),
          ],
        ),
        const SizedBox(height: 16),
        _whiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Match relevance trend',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 149,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final height in [43.0, 59, 68, 65, 87, 100, 111]) ...[
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: height,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFEDEEEA), AppColors.mint],
                              ),
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(7)),
                            ),
                          ),
                        ),
                      ),
                      if (height != 111) const SizedBox(width: 7),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Demo values showing how recommendations can improve\nwith feedback.',
                style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _whiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tune your recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'What should the next match prioritize?',
                style: TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 7, runSpacing: 8, children: [
                _priorityChip('Skills'),
                _priorityChip('Beginner-friendly'),
                _priorityChip('Recent activity'),
              ]),
              const SizedBox(height: 16),
              _tealButton('Refine AI prompt', _refine),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _whiteCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, color: AppColors.teal, size: 22),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Matching should use public GitHub activity and your declared skills only. '
                  'Scores here are sample data.',
                  style: TextStyle(fontSize: 13, color: AppColors.ink, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
