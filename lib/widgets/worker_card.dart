import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../theme/app_theme.dart';
import 'app_avatar.dart';

class WorkerCard extends StatelessWidget {
  final WorkerModel worker;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;

  const WorkerCard({
    super.key,
    required this.worker,
    this.isSelected = false,
    required this.onTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: primary, width: 2)
            : BorderSide(color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                children: [
                  AppAvatar(
                    avatarUrl: worker.avatarUrl,
                    name: worker.name,
                    radius: 28,
                    backgroundColor: primary.withValues(alpha: 0.12),
                    foregroundColor: primary,
                    defaultIcon: Icons.engineering_rounded,
                  ),
                  if (worker.isAvailable)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF121212) : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            worker.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (worker.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 16, color: Colors.blue),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${worker.categoryName} • ${worker.experience}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkSubtitleColor : AppTheme.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${worker.rating} (${worker.totalReviews})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? AppTheme.darkSubtitleColor : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${worker.distanceKm} km',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkSubtitleColor : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${worker.hourlyRate.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  Text(
                    'per job',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkSubtitleColor : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.arrow_forward_ios,
                      size: 13,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey.shade600),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
