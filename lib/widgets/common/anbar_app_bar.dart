import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Clean AFPay-style header used on Sales, Warehouse, Settings, Master Data.
class AnbarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;

  const AnbarAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.leading,
    this.showBack = true,
    this.backgroundColor,
    this.onBackPressed,
  });

  static const double _toolbarHeight = 58;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_toolbarHeight + BrandStripe.height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final canPop = Navigator.of(context).canPop();
    final showLeading = (showBack && canPop) || leading != null;
    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
    );

    return Material(
      color: backgroundColor ?? theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _toolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (showLeading) ...[
                      leading ??
                          _CircleIconButton(
                            icon: isRtl
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            iconSize: 16,
                            onTap:
                                onBackPressed ?? () => Navigator.pop(context),
                          ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (actions != null)
                      Row(mainAxisSize: MainAxisSize.min, children: actions!),
                  ],
                ),
              ),
            ),
            const BrandStripe(),
          ],
        ),
      ),
    );
  }
}

/// Thin green / blue / red line marking the bottom edge of the app bars.
class BrandStripe extends StatelessWidget {
  static const double height = 3;

  const BrandStripe({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (final color in AppColors.brandStripe)
            Expanded(child: ColoredBox(color: color)),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconSize = 20,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                backgroundColor ??
                (isDark ? AppColors.darkSurface : Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: iconSize,
            color:
                iconColor ??
                (isDark ? AppColors.darkTextPrimary : const Color(0xFF111827)),
          ),
        ),
      ),
    );
  }
}

/// Circular action used inside [AnbarAppBar].
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? iconColor;
  final Color? bgColor;
  final Widget? badge;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.iconColor,
    this.bgColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: Tooltip(
        message: tooltip ?? '',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _CircleIconButton(
              icon: icon,
              onTap: onTap,
              iconColor: iconColor,
              backgroundColor: bgColor,
            ),
            if (badge != null)
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: -2,
                top: -2,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Home top strip — weather/date style from the reference.
class AnbarHomeAppBar extends StatelessWidget {
  final String greeting;
  final String username;
  final String dateLabel;
  final int lowStockCount;

  const AnbarHomeAppBar({
    super.key,
    required this.greeting,
    required this.username,
    required this.dateLabel,
    required this.lowStockCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final greetingIcon = hour < 12
        ? Icons.wb_sunny_rounded
        : hour < 17
        ? Icons.wb_twilight_rounded
        : Icons.nights_stay_rounded;

    return SliverAppBar(
      pinned: true,
      toolbarHeight: 76,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(BrandStripe.height),
        child: BrandStripe(),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        greetingIcon,
                        size: 18,
                        color: hour < 17
                            ? AppColors.amber
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          greeting,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    username,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              dateLabel,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                height: 1.35,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF6B7280),
              ),
            ),
            if (lowStockCount > 0) ...[
              const SizedBox(width: 10),
              _CircleIconButton(
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.accent,
                onTap: () {},
              ),
            ],
          ],
        ),
      ),
    );
  }
}
