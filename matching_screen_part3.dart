
  Widget _drawer() {
    return Drawer(
      backgroundColor: AppColors.card,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ListTile(
              title: Text(
                'DEVSYNC',
                style: TextStyle(letterSpacing: 2, color: AppColors.teal),
              ),
              subtitle: Text('AI Studio',
                  style: TextStyle(fontSize: 22, color: AppColors.ink)),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Matches'),
              onTap: () {
                Navigator.pop(context);
                _switchToMatches();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('AI quality analytics'),
              onTap: () {
                Navigator.pop(context);
                _switchToAnalytics();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 73,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _headerIcon(Icons.menu_rounded, () => _scaffoldKey.currentState?.openDrawer()),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('D E V S Y N C',
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.5,
                    letterSpacing: 0.65,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                  )),
              Text(
                _analytics && _selectedTab == 0 ? 'AI analytics' : 'AI Studio',
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const Spacer(),
          _headerIcon(
            Icons.notifications_none_rounded,
            () => _notify('No new notifications'),
            showDot: true,
          ),
          if (!_analytics && _selectedTab == 0) ...[
            const SizedBox(width: 8),
            _headerIcon(Icons.bar_chart_rounded, _switchToAnalytics),
          ],
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap, {bool showDot = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 21, color: AppColors.ink),
            if (showDot)
              Positioned(
                right: 8,
                top: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
