import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider_state.dart';
import '../../widgets/app_avatar.dart';
import 'booking_flow_screen.dart';

class FindExpertWorkersScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryId;

  const FindExpertWorkersScreen({
    super.key,
    this.categoryTitle = 'Plumber',
    this.categoryId = 'cat_plumbing',
  });

  @override
  State<FindExpertWorkersScreen> createState() =>
      _FindExpertWorkersScreenState();
}

class _FindExpertWorkersScreenState extends State<FindExpertWorkersScreen> {
  final Set<String> _bookmarkedWorkerIds = {'wrk_001', 'wrk_003'};
  String _searchQuery = '';

  // Demo workers matching Indian context
  final List<Map<String, dynamic>> _demoExperts = [
    {
      'id': 'exp_001',
      'name': 'Ramesh Kumar',
      'roleTitle': 'Expert Home Plumber',
      'rating': 4.8,
      'totalJobs': 384,
      'rate': 199.0,
      'imageUrl':
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 'exp_002',
      'name': 'Suresh Sharma',
      'roleTitle': 'Expert Home Plumber',
      'rating': 4.7,
      'totalJobs': 210,
      'rate': 149.0,
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 'exp_003',
      'name': 'Rajesh Verma',
      'roleTitle': 'Expert Home Plumber',
      'rating': 4.6,
      'totalJobs': 165,
      'rate': 249.0,
      'imageUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 'exp_004',
      'name': 'Pooja Sharma',
      'roleTitle': 'Expert Home Sanitation & Plumber',
      'rating': 4.9,
      'totalJobs': 344,
      'rate': 199.0,
      'imageUrl':
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 'exp_005',
      'name': 'Manoj Tiwari',
      'roleTitle': 'Master Plumber & Pipe Fitter',
      'rating': 4.9,
      'totalJobs': 420,
      'rate': 299.0,
      'imageUrl':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final serviceState = Provider.of<ServiceProviderState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Merge system state workers matching this category
    final systemWorkers = serviceState.workers.where((w) {
      return w.categoryId == widget.categoryId ||
          w.categoryName.toLowerCase().contains(
            widget.categoryTitle.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? Colors.black
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Color(0xFF0F4C81),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Find Expert ${widget.categoryTitle}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: const Color(0xFF262626)) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by technician name...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF0284C7),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Worker List
            Expanded(
              child: Builder(
                builder: (context) {
                  // Deduplicate demo experts if matched by system worker name
                  final displayDemoExperts = _demoExperts.where((d) {
                    return !systemWorkers.any(
                      (s) => s.name.toLowerCase().trim() == d['name'].toString().toLowerCase().trim(),
                    );
                  }).toList();

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: displayDemoExperts.length + systemWorkers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index < displayDemoExperts.length) {
                        final item = displayDemoExperts[index];
                        if (_searchQuery.isNotEmpty &&
                            !item['name'].toString().toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            )) {
                          return const SizedBox.shrink();
                        }
                        return _buildWorkerCard(
                          id: item['id'],
                          name: item['name'],
                          roleTitle: 'Expert Home ${widget.categoryTitle}',
                          rating: item['rating'],
                          totalJobs: item['totalJobs'],
                          rate: item['rate'],
                          imageUrl: item['imageUrl'],
                          isBookmarked: _bookmarkedWorkerIds.contains(item['id']),
                          isAvailable: true,
                        );
                      } else {
                        final worker = systemWorkers[index - displayDemoExperts.length];
                        if (_searchQuery.isNotEmpty &&
                            !worker.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            )) {
                          return const SizedBox.shrink();
                        }
                        return _buildWorkerCard(
                          id: worker.id,
                          name: worker.name,
                          roleTitle: 'Expert Home ${worker.categoryName}',
                          rating: worker.rating,
                          totalJobs: worker.totalReviews * 4,
                          rate: worker.hourlyRate,
                          imageUrl: worker.avatarUrl,
                          isBookmarked: _bookmarkedWorkerIds.contains(worker.id),
                          isAvailable: worker.isAvailable,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard({
    required String id,
    required String name,
    required String roleTitle,
    required double rating,
    required int totalJobs,
    required double rate,
    required String imageUrl,
    required bool isBookmarked,
    bool isAvailable = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (!isAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$name is currently OFFLINE and not taking new booking requests.',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        _showBookWorkerDialog(name, roleTitle, rate);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Technician Square Avatar with Online / Offline Badge
            Stack(
              children: [
                AppAvatar(
                  avatarUrl: imageUrl,
                  name: name,
                  radius: 40,
                  defaultIcon: Icons.engineering_rounded,
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isAvailable ? const Color(0xFF10B981) : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Technician Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Bookmark Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked
                              ? const Color(0xFF0284C7)
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_bookmarkedWorkerIds.contains(id)) {
                              _bookmarkedWorkerIds.remove(id);
                            } else {
                              _bookmarkedWorkerIds.add(id);
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Role Title & Availability Tag
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          roleTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0284C7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isAvailable ? const Color(0xFF10B981) : Colors.red).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Offline',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? const Color(0xFF10B981) : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Stats Row: Rating | Total Jobs | Rate
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),

                      // Total Jobs
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Jobs',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            '$totalJobs',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Hourly Rate
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            '₹${rate.toStringAsFixed(0)}/hr',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F4C81),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookWorkerDialog(String workerName, String roleTitle, double rate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.handyman_rounded,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book $workerName',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        roleTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm immediate dispatch or scheduled doorstep visit. Estimated arrival time within 30-45 minutes.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Standard Inspection Fee:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '₹${rate.toStringAsFixed(0)}/hr',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C81),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingFlowScreen(initialStep: 2),
                    ),
                  );
                },
                child: const Text(
                  'Proceed to Confirm Booking',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
