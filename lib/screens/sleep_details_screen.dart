// 📁 lib/screens/sleep_details_screen.dart
// Sleep details screen showing 7-day sleep history with stats

import 'package:flutter/material.dart';
import 'package:health_care/models/sleep_model.dart';
import 'package:health_care/services/sleep_service.dart';
import 'package:health_care/theme/app_theme.dart';

class SleepDetailsScreen extends StatefulWidget {
  const SleepDetailsScreen({super.key});

  @override
  State<SleepDetailsScreen> createState() => _SleepDetailsScreenState();
}

class _SleepDetailsScreenState extends State<SleepDetailsScreen> {
  final SleepService _sleepService = SleepService();
  List<SleepLog> _sleepLogs = [];
  bool _isLoading = true;
  double _avgDuration = 0.0;
  double _avgQuality = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWeeklySleep();
  }

  Future<void> _loadWeeklySleep() async {
    setState(() => _isLoading = true);
    
    try {
      final logs = await _sleepService.getWeeklySleep();
      final stats = await _sleepService.getSleepStats();
      
      if (mounted) {
        setState(() {
          _sleepLogs = logs;
          _avgDuration = stats['avgDuration'] as double? ?? 0.0;
          _avgQuality = stats['avgQuality'] as double? ?? 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading weekly sleep: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1E) : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Sleep Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWeeklySleep,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7B68EE).withOpacity(0.2),
                              const Color(0xFF9D84FF).withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B68EE).withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bedtime_rounded,
                          size: 72,
                          color: Color(0xFF7B68EE),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),

                    // Statistics Cards
                    Text(
                      'Weekly Summary',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Avg Duration',
                            value: '${_avgDuration.toStringAsFixed(1)}h',
                            icon: Icons.schedule_rounded,
                            color: const Color(0xFF7B68EE),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Avg Quality',
                            value: _avgQuality.toStringAsFixed(1),
                            subtitle: _getQualityLabel(_avgQuality.round()),
                            icon: Icons.star_rounded,
                            color: AppColors.warning,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildStatCard(
                      title: 'Total Nights',
                      value: '${_sleepLogs.length}',
                      subtitle: 'Last 7 days',
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.secondary,
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Sleep History
                    Text(
                      'Sleep History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (_sleepLogs.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ..._sleepLogs.map((log) => _buildSleepLogCard(log, isDark)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepLogCard(SleepLog log, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(log.date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getQualityColor(log.quality).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: _getQualityColor(log.quality),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.qualityLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getQualityColor(log.quality),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Duration
          Row(
            children: [
              Icon(
                Icons.bedtime_rounded,
                size: 20,
                color: const Color(0xFF7B68EE),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                log.formattedDuration,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7B68EE),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Time range
          Row(
            children: [
              Icon(
                Icons.nightlight_round,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Bed: ${log.bedTime}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.wb_sunny_rounded,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Wake: ${log.wakeTime}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 80,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Sleep Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start logging your sleep to see your history here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;
      
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getQualityLabel(int quality) {
    switch (quality) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Fair';
    }
  }

  Color _getQualityColor(int quality) {
    switch (quality) {
      case 1:
        return AppColors.error;
      case 2:
        return Colors.orange;
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.secondary;
      case 5:
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }
}
