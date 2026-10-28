
        const SizedBox(height: 16),
        _whiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Suggested\nmatches',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 19,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '${demoMatches.length} matches',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < demoMatches.length; i++) ...[
                if (i != 0) const Divider(height: 28, color: AppColors.border),
                _matchRow(demoMatches[i]),
              ],
              if (_generated) ...[
                const SizedBox(height: 14),
                const Text(
                  'Results refreshed from local demo data.',
                  style: TextStyle(fontSize: 12, color: AppColors.teal),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _whiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How scoring works',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 18),
              _scoreRow('Skills', 90),
              const SizedBox(height: 15),
              _scoreRow('Activity', 75),
              const SizedBox(height: 15),
              _scoreRow('Interests', 85),
              const SizedBox(height: 16),
              const Text(
                'Illustrative explanations, not real model scores.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: _switchToAnalytics,
                  child: const Text(
                    'Explore AI quality analytics',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
