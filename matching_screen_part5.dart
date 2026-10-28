
  Widget _matchRow(Match match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                match.name,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${match.score}%',
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          match.description,
          style: const TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.65),
        ),
        const SizedBox(height: 10),
        _progressBar(match.score / 100),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => _showProject(match),
            child: const Text(
              'View project details →',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _scoreRow(String label, int score) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ),
        Expanded(child: _progressBar(score / 100)),
        const SizedBox(width: 14),
        SizedBox(
          width: 24,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _progressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: AppColors.chip,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
        minHeight: 7,
      ),
    );
  }
