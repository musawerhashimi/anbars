import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Green→blue pill with a white icon badge, used for header actions
/// like "Warehouse Report" and "Sale History".
class GradientPillButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool busy;
  final String? tooltip;

  const GradientPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.busy = false,
    this.tooltip,
  });

  static const _radius = BorderRadius.all(Radius.circular(22));

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _radius,
          onTap: busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 14, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: busy
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        )
                      : Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
