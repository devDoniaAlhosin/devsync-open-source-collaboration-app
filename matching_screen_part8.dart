
  Widget _otherTabBody() {
    const names = ['Matches', 'Discover', 'Projects', 'Requests', 'Profile'];
    final title = names[_selectedTab];
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The $title section is a placeholder. The supplied references '
            'cover Matches and AI quality analytics.',
            style: const TextStyle(color: AppColors.muted, height: 1.6),
          ),
          const SizedBox(height: 18),
          _tealButton('Back to matches', _switchToMatches),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    const tabs = [
      (Icons.auto_awesome_outlined, 'Matches'),
      (Icons.auto_awesome, 'Discover'),
      (Icons.folder_outlined, 'Projects'),
      (Icons.inbox_outlined, 'Requests'),
      (Icons.person_outline_rounded, 'Profile'),
    ];
    return Container(
      height: 74,
      margin: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        MediaQuery.of(context).viewPadding.bottom > 0 ? 5 : 12,
      ),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1C58584B),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _selectedTab = i;
                  if (i == 0) _analytics = false;
                }),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: i == _selectedTab ? AppColors.mintLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      if (i == _selectedTab)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 32,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: i == 1 ? AppColors.mint : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Icon(
                                tabs[i].$1,
                                size: 19,
                                color: i < 2 ? AppColors.teal : AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                tabs[i].$2,
                                style: const TextStyle(fontSize: 10, color: AppColors.ink),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i == 3)
                        Positioned(
                          top: 11,
                          right: 15,
                          child: Container(
                            height: 4,
                            width: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.mint,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
