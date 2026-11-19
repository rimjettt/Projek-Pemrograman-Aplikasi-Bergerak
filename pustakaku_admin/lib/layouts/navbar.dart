import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    required this.activePage,
    required this.onPageSelected,
    super.key,
  });

  static const List<String> _pages = [
    'Dashboard',
    'Katalog Buku',
    'Peminjaman',
    'Riwayat',
    'Pelanggaran',
    'Profil',
  ];

  final String activePage;
  final ValueChanged<String> onPageSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;
        final isWide = constraints.maxWidth >= 1400;
        return Material(
          color: AppColors.white,
          elevation: 1,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth >= 900
                    ? 32
                    : constraints.maxWidth < 360
                    ? 12
                    : 16,
              ),
              child: isMobile
                  ? _buildMobileNavbar(context)
                  : isWide
                  ? _buildWideNavbar(context)
                  : _buildCompactNavbar(context, constraints.maxWidth),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideNavbar(BuildContext context) {
    return SizedBox(
      height: 78,
      child: Row(
        children: [
          const _Brand(),
          const SizedBox(width: 28),
          Expanded(child: _buildNavigation()),
          const SizedBox(width: 20),
          _buildProfile(context, showName: true, showLogout: true),
        ],
      ),
    );
  }

  Widget _buildMobileNavbar(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          const _Brand(),
          const Spacer(),
          _buildProfile(context, showName: false, showLogout: false),
          PopupMenuButton<String>(
            tooltip: 'Buka menu navigasi',
            icon: const Icon(Icons.menu_rounded, color: AppColors.navy),
            onSelected: onPageSelected,
            itemBuilder: (context) => [
              for (final page in _pages)
                PopupMenuItem(
                  value: page,
                  child: Row(
                    children: [
                      Icon(
                        page == activePage
                            ? Icons.circle
                            : Icons.circle_outlined,
                        size: 12,
                        color: page == activePage
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        page,
                        style: TextStyle(
                          color: page == activePage
                              ? AppColors.navy
                              : AppColors.textPrimary,
                          fontWeight: page == activePage
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNavbar(BuildContext context, double width) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                const _Brand(),
                const Spacer(),
                _buildProfile(
                  context,
                  showName: width >= 800,
                  showLogout: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: _buildNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final page in _pages)
            _NavItem(
              label: page,
              isActive: page == activePage,
              onTap: () => onPageSelected(page),
            ),
        ],
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context, {
    required bool showName,
    required bool showLogout,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onPageSelected('Profil'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.pale,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.navy,
                    size: 20,
                  ),
                ),
                if (showName) ...[
                  const SizedBox(width: 9),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'Administrator',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showLogout) ...[
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur logout belum tersedia pada demo.'),
                ),
              );
            },
            icon: const Icon(Icons.logout_outlined),
            color: AppColors.textSecondary,
          ),
        ],
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pale,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: AppColors.navy,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'PustakaKu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isActive
                          ? AppColors.navy
                          : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 3,
                width: isActive ? 24 : 0,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
