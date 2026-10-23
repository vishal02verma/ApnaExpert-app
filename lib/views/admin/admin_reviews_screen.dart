import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF0284C7) : AppTheme.primaryColor;

    final bookingsWithReviews = bookingProvider.allBookings
        .where((b) => b.review != null)
        .where((b) => _filter == 'All' || (_filter == 'Flagged' && b.review!.isFlagged))
        .toList();

    double avgRating = 0.0;
    if (bookingsWithReviews.isNotEmpty) {
      avgRating = bookingsWithReviews.fold(0.0, (sum, b) => sum + b.review!.rating) /
          bookingsWithReviews.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Review Moderation'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Reviews'),
                  selected: _filter == 'All',
                  showCheckmark: false,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  selectedColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: _filter == 'All'
                        ? primary
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1)),
                    width: _filter == 'All' ? 1.5 : 1.0,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: _filter == 'All' ? FontWeight.bold : FontWeight.w600,
                    color: _filter == 'All'
                        ? Colors.white
                        : (isDark
                            ? Colors.white
                            : const Color(0xFF0F172A)),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _filter = 'All');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Flagged Only'),
                  selected: _filter == 'Flagged',
                  showCheckmark: false,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  selectedColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: _filter == 'Flagged'
                        ? Colors.red.shade600
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1)),
                    width: _filter == 'Flagged' ? 1.5 : 1.0,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: _filter == 'Flagged' ? FontWeight.bold : FontWeight.w600,
                    color: _filter == 'Flagged'
                        ? Colors.white
                        : (isDark
                            ? Colors.white
                            : const Color(0xFF0F172A)),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _filter = 'Flagged');
                  },
                ),
                const Spacer(),
                if (bookingsWithReviews.isNotEmpty)
                  Text(
                    'Avg: ${avgRating.toStringAsFixed(1)} ⭐',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: bookingsWithReviews.isEmpty
                ? const Center(
                    child: Text('No user reviews matching the filter.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingsWithReviews.length,
                    itemBuilder: (context, idx) {
                      final b = bookingsWithReviews[idx];
                      final rev = b.review!;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${rev.rating} / 5.0',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  if (rev.isFlagged)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'FLAGGED',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '"${rev.comment}"',
                                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'By: ${rev.customerName} for ${rev.workerName} (${b.categoryTitle})',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      bookingProvider.deleteReview(b.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Review removed from system.')),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: rev.isFlagged ? Colors.green : Colors.orange,
                                    ),
                                    icon: Icon(
                                      rev.isFlagged ? Icons.check : Icons.flag,
                                      size: 16,
                                    ),
                                    label: Text(rev.isFlagged ? 'Unflag' : 'Flag Inappropriate'),
                                    onPressed: () {
                                      bookingProvider.toggleFlagReview(b.id);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
