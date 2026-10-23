
import 'package:flutter/material.dart';
import '../models/booking_request.dart';
import '../theme/app_theme.dart';

class BookingStatusStepper extends StatelessWidget {
  final BookingStatus currentStatus;

  const BookingStatusStepper({super.key, required this.currentStatus});

  static const List<Map<String, dynamic>> _steps = [
    {'step': 1, 'title': 'Select Service', 'icon': Icons.grid_view_rounded},
    {'step': 2, 'title': 'Describe Problem', 'icon': Icons.description_rounded},
    {'step': 3, 'title': 'Location', 'icon': Icons.location_on_rounded},
    {'step': 4, 'title': 'Nearby Workers', 'icon': Icons.engineering_rounded},
    {'step': 5, 'title': 'Request', 'icon': Icons.send_rounded},
    {'step': 6, 'title': 'Worker Accepts', 'icon': Icons.check_circle_rounded},
    {'step': 7, 'title': 'Service Done', 'icon': Icons.task_alt_rounded},
    {'step': 8, 'title': 'Review', 'icon': Icons.star_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    int currentStepIndex = currentStatus.stepIndex;
    if (currentStatus == BookingStatus.cancelled) {
      currentStepIndex = 0;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '8-Step Service Journey',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentStatus == BookingStatus.cancelled ? 'Cancelled' : 'Step $currentStepIndex of 8',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: currentStatus == BookingStatus.cancelled ? Colors.red : primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _steps.map((s) {
                final int stepNum = s['step'] as int;
                final bool isCompleted = stepNum < currentStepIndex;
                final bool isCurrent = stepNum == currentStepIndex;

                Color circleColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200;
                Color iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
                if (isCompleted) {
                  circleColor = AppTheme.secondaryColor;
                  iconColor = Colors.white;
                } else if (isCurrent) {
                  circleColor = primary;
                  iconColor = Colors.white;
                }

                return Row(
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleColor,
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : s['icon'] as IconData,
                            size: 19,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 75,
                          child: Text(
                            s['title'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent
                                  ? primary
                                  : (isCompleted
                                      ? (isDark ? Colors.white : AppTheme.textColor)
                                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (stepNum < 8)
                      Container(
                        width: 24,
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 22, left: 4, right: 4),
                        color: stepNum < currentStepIndex
                            ? AppTheme.secondaryColor
                            : (isDark ? const Color(0xFF262626) : Colors.grey.shade300),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
