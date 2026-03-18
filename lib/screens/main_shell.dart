import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../utils/app_language.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      path: '/home',
    ),
    _TabItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
      path: '/reports',
    ),
    _TabItem(
      icon: Icons.bookmark_outline_rounded,
      activeIcon: Icons.bookmark_rounded,
      path: '/saved',
    ),
    _TabItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      path: '/profile',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final language = ref.watch(appLanguageProvider);
    final labels = [
      AppStrings.home(language),
      AppStrings.reports(language),
      AppStrings.saved(language),
      AppStrings.profile(language),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140A1628),
              blurRadius: 18,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(tab.path),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.blueAccent.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          color: isActive
                              ? AppColors.blueAccent
                              : AppColors.textHint,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppColors.blueAccent
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
