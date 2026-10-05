import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnbarBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final int lowStock;
  final List<AnbarNavItem> items;

  const AnbarBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
    this.lowStock = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, 10 + (bottomInset > 0 ? bottomInset : 8)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == index,
                    badge: i == 2 && lowStock > 0 ? lowStock : null,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnbarNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AnbarNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final AnbarNavItem item;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = isDark ? AppColors.primaryLight : AppColors.primary;
    final idle = isDark ? AppColors.darkTextSecondary : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: selected ? 26 : 24,
                color: selected ? active : idle,
              ),
              if (badge != null)
                Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? active : idle,
            ),
          ),
        ],
      ),
    );
  }
}
