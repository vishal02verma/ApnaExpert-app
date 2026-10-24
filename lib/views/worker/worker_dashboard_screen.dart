import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/booking_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/payout_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/chat_bottom_sheet.dart';
import 'worker_earnings_screen.dart';
import 'worker_incoming_requests_screen.dart';
import 'worker_profile_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  int _currentIndex = 0;

  void _showVerifyOtpDialog(BuildContext context, BookingRequest booking, BookingProvider bp) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.pin, color: AppTheme.secondaryColor),
            SizedBox(width: 8),
            Text('Verify Customer PIN'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ask customer ${booking.customerName} for their 4-digit start PIN:'),
            const SizedBox(height: 12),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4),
              decoration: const InputDecoration(
                hintText: '4821',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Demo Tip: The customer PIN is "${booking.securityOtp}"',
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
            onPressed: () {
              if (otpController.text.trim() == booking.securityOtp) {
                bp.updateBookingStatus(booking.id, BookingStatus.inProgress);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN Verified! Work marked In Progress.'),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect PIN. Please recheck with customer.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Verify & Start Work'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final serviceState = Provider.of<ServiceProviderState>(context);
    final user = authProvider.currentUser;
    final worker = serviceState.getWorkerForUser(user);
    final pendingCount = bookingProvider.getWorkerPendingRequests(worker.id, categoryId: worker.categoryId).length;

    final List<Widget> workerPages = [
      _buildWorkerMainTab(context),
      const WorkerIncomingRequestsScreen(),
      const WorkerEarningsScreen(),
      const WorkerProfileScreen(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      body: SafeArea(child: workerPages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppTheme.secondaryColor,
            unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500),
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.dashboard_rounded, color: AppTheme.secondaryColor),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text('$pendingCount'),
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.notifications_active_rounded, color: AppTheme.secondaryColor),
                  ),
                ),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.secondaryColor),
                ),
                label: 'Earnings',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppTheme.secondaryColor),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerMainTab(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final serviceState = Provider.of<ServiceProviderState>(context);
    final payoutProvider = Provider.of<PayoutProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authProvider.currentUser;
    final worker = serviceState.getWorkerForUser(user);

    final pendingRequests = bookingProvider.getWorkerPendingRequests(worker.id, categoryId: worker.categoryId);
    final allJobs = bookingProvider.getWorkerBookings(worker.id, categoryId: worker.categoryId);
    final activeJobs = allJobs.where((b) =>
        b.status == BookingStatus.accepted || b.status == BookingStatus.inProgress).toList();

    double totalEarnings = 0.0;
    int completedCount = 0;
    for (var b in allJobs) {
      if (b.status == BookingStatus.serviceDone || b.status == BookingStatus.reviewed) {
        totalEarnings += b.finalCost;
        completedCount++;
      }
    }

    final totalWithdrawn = payoutProvider.getTotalWithdrawnForWorker(worker.id);
    final pendingPayouts = payoutProvider.getPendingPayoutsForWorker(worker.id);
    final availableBalance =
        (totalEarnings - totalWithdrawn - pendingPayouts).clamp(0.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technician Status Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: worker.isAvailable
                    ? [const Color(0xFF065F46), const Color(0xFF047857)]
                    : [const Color(0xFF475569), const Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (worker.isAvailable ? AppTheme.secondaryColor : Colors.black).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                AppAvatar(
                  avatarUrl: worker.avatarUrl,
                  name: worker.name,
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  defaultIcon: Icons.engineering_rounded,
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
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (worker.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.amber, size: 16),
                          ]
                        ],
                      ),
                      Text(
                        '${worker.categoryName} • ${worker.rating} ⭐ (${worker.totalReviews} reviews)',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: worker.isAvailable ? Colors.greenAccent : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            worker.isAvailable ? 'Online & Available for Jobs' : 'Offline (Not visible)',
                            style: TextStyle(
                              color: worker.isAvailable ? Colors.greenAccent : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Switch(
                  value: worker.isAvailable,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.greenAccent,
                  onChanged: (val) {
                    serviceState.toggleWorkerAvailability(worker.id);
                  },
                )
              ],
            ),
          ),

          // Offline Warning Ribbon (When technician paused their availability)
          if (!worker.isAvailable)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'You are currently OFFLINE. Customers cannot find you or send job requests.',
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => serviceState.toggleWorkerAvailability(worker.id),
                    child: const Text('Go Online', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Switch to Customer Mode Banner (Need a Worker at Home?)
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_repair_service_rounded,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need a Worker at Home?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Book Electrician, Carpenter or other experts with this account',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text(
                    'Book Service',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    authProvider.switchToCustomerMode();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Switched to Customer Mode! Browse and book any service.'),
                        backgroundColor: Color(0xFF0284C7),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  title: 'Pending',
                  value: '${pendingRequests.length}',
                  icon: Icons.hourglass_top_rounded,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  title: 'Active Jobs',
                  value: '${activeJobs.length}',
                  icon: Icons.build_circle_rounded,
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _currentIndex = 2),
                  child: _buildStatTile(
                    title: 'Earnings',
                    value: '₹${availableBalance.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.secondaryColor,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  title: 'Completed',
                  value: '$completedCount',
                  icon: Icons.check_circle_rounded,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Ongoing Active Work Section (if any accepted/in progress jobs exist)
          if (activeJobs.isNotEmpty) ...[
            const Text(
              'Active Work in Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...activeJobs.map((job) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.secondaryColor, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Job ${job.id} • ${job.categoryTitle}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: job.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Customer: ${job.customerName} (${job.customerPhone})'),
                      Text('Address: ${job.address}'),
                      Text('Problem: ${job.problemDescription}'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(color: AppTheme.primaryColor),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              label: const Text('Chat with Customer', style: TextStyle(fontSize: 12)),
                              onPressed: () => showAppChatBottomSheet(
                                context,
                                booking: job,
                                isCustomer: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppTheme.secondaryColor,
                              side: const BorderSide(color: AppTheme.secondaryColor),
                            ),
                            icon: const Icon(Icons.phone_outlined, size: 16),
                            label: const Text('Call', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Calling customer ${job.customerName} (${job.customerPhone})...'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (job.status == BookingStatus.accepted)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            icon: const Icon(Icons.pin, size: 18),
                            label: const Text('Verify Customer PIN & Start Work'),
                            onPressed: () => _showVerifyOtpDialog(context, job, bookingProvider),
                          ),
                        ),
                      if (job.status == BookingStatus.inProgress)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                            icon: const Icon(Icons.done_all, size: 18),
                            label: const Text('Mark Service Completed (Step 7)'),
                            onPressed: () {
                              bookingProvider.updateBookingStatus(job.id, BookingStatus.serviceDone);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Service Completed! Customer notified to leave review.'),
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Incoming Service Requests Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Incoming Job Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: const Text('View All'),
              ),
            ],
          ),

          if (pendingRequests.isEmpty)
            Card(
              child: Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No pending requests. You are all caught up!',
                      style: TextStyle(color: AppTheme.subtitleColor),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingRequests.length,
              itemBuilder: (context, idx) {
                final req = pendingRequests[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                req.customerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                req.urgency,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(req.address, style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.build_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text('Issue: ${req.problemDescription}', style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Slot: ${req.scheduledTime}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('₹${req.finalCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  bookingProvider.updateBookingStatus(
                                      req.id, BookingStatus.cancelled);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Request Rejected')),
                                  );
                                },
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                                onPressed: () {
                                  bookingProvider.updateBookingStatus(
                                    req.id,
                                    BookingStatus.accepted,
                                    workerId: worker.id,
                                    workerName: worker.name,
                                    workerPhone: worker.phone,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request Accepted! Customer notified.'),
                                      backgroundColor: AppTheme.secondaryColor,
                                    ),
                                  );
                                },
                                child: const Text('Accept Job'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppTheme.subtitleColor, height: 1.1),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
