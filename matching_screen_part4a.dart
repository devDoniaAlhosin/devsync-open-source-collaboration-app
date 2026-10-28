
  Widget _matchingBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(colors: [AppColors.card, AppColors.background]),
          ),
          child: const Text(
            'DEVSYNC INTELLIGENCE / BETA',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _whiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Match\npreferences',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 19,
                        height: 1.13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Text('Demo',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 17),
              const Text(
                'Describe the kind of open-source work you want to do.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _preferences,
                maxLines: 5,
                minLines: 4,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: AppColors.ink, fontSize: 14, height: 1.55),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.all(15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.mint, width: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Wrap(spacing: 7, runSpacing: 7, children: [
                _tag('Flutter UI'),
                _tag('Testing'),
                _tag('Firebase'),
              ]),
              const SizedBox(height: 16),
              _tealButton('Generate matches', () {
                setState(() => _generated = true);
                _notify('3 demo matches generated');
              }, icon: Icons.auto_awesome),
              const SizedBox(height: 14),
              const Text(
                'Using demo project data; no external AI request is sent.',
                style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
