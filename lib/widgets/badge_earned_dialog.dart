import 'package:flutter/material.dart';
import 'share_edit_sheet.dart';
import '../l10n/app_strings.dart';
import '../models/badge_type.dart';
import '../theme/app_colors.dart';
import 'badge_widget.dart';

class BadgeEarnedDialog extends StatelessWidget {
  final BadgeType badge;
  final int streak;
  final AppStrings strings;

  const BadgeEarnedDialog({
    super.key,
    required this.badge,
    required this.streak,
    required this.strings,
  });

  static const _anniversaryDays = {365: 1, 730: 2, 1095: 3};

  @override
  Widget build(BuildContext context) {
    final name = strings.badgeName(badge.name);
    final days = badge.requiredStreak;
    final anniversaryYears = _anniversaryDays[days];
    final bodyText = anniversaryYears != null
        ? strings.badgeAnniversaryBody(anniversaryYears)
        : strings.badgeEarnedBody(days);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeWidget(badge: badge, unlocked: true, size: 96),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.badgeEarnedTitle,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              bodyText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ShareEditSheet.show(context,
                      defaultText: strings.badgeShareText(name, streak),
                      strings: strings);
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  strings.share,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                strings.cancel,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
