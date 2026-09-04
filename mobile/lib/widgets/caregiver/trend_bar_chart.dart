import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/dashboard_data.dart';

/// Accessible weekly activity and engagement consistency bar chart.
/// Displays daily activity counts with day-level context markers (music, together mode).
class TrendBarChart extends StatelessWidget {
  final List<DailyContextPoint> weeklyData;

  const TrendBarChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    const maxActivities = 4.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Activity Consistency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Daily Moments',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Number of gentle activities completed each day and session context.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Bars Row
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((point) {
                final heightFraction = (point.completedActivitiesCount / maxActivities).clamp(0.15, 1.0);
                final isToday = point.dayLabel.contains('Today');

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Context markers (Together mode or Music)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (point.hadTogetherSession)
                              const Icon(Icons.favorite, size: 13, color: AppColors.peach),
                            if (point.hadMusicActivity)
                              const Icon(Icons.music_note, size: 13, color: AppColors.domainLanguage),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Number of completed activities
                        Text(
                          '${point.completedActivitiesCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isToday ? AppColors.forestPrimary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Visual Bar
                        Container(
                          height: 80 * heightFraction,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.forestPrimary
                                : AppColors.sage.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Day Label
                        Text(
                          point.dayLabel.split(' ')[0], // "Mon", "Tue", etc.
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday ? AppColors.forestPrimary : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 14, color: AppColors.peach),
              const SizedBox(width: 4),
              const Text('Together Mode', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              const Icon(Icons.music_note, size: 14, color: AppColors.domainLanguage),
              const SizedBox(width: 4),
              const Text('Music Activity', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
