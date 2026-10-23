import 'package:flutter/material.dart';
import '../models/booking_request.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color baseColor;
    IconData icon;

    switch (status) {
      case BookingStatus.requested:
        baseColor = Colors.orange;
        icon = Icons.hourglass_top_rounded;
        break;
      case BookingStatus.accepted:
        baseColor = Colors.blue;
        icon = Icons.thumb_up_alt_rounded;
        break;
      case BookingStatus.inProgress:
        baseColor = Colors.purple;
        icon = Icons.build_circle_rounded;
        break;
      case BookingStatus.serviceDone:
        baseColor = Colors.green;
        icon = Icons.check_circle_rounded;
        break;
      case BookingStatus.reviewed:
        baseColor = Colors.amber.shade700;
        icon = Icons.star_rounded;
        break;
      case BookingStatus.cancelled:
        baseColor = Colors.red;
        icon = Icons.cancel_rounded;
        break;
      default:
        baseColor = Colors.grey;
        icon = Icons.info_outline;
    }

    final bg = isDark
        ? baseColor.withValues(alpha: 0.2)
        : baseColor.withValues(alpha: 0.12);
    final fg = isDark
        ? (baseColor == Colors.amber.shade700 ? Colors.amber.shade300 : baseColor)
        : (baseColor == Colors.amber.shade700 ? Colors.amber.shade900 : (baseColor == Colors.orange ? Colors.orange.shade900 : baseColor));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.4 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
