import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class WorkerIncomingRequestsScreen extends StatefulWidget {
  const WorkerIncomingRequestsScreen({super.key});

  @override
  State<WorkerIncomingRequestsScreen> createState() =>
      _WorkerIncomingRequestsScreenState();
}

class _WorkerIncomingRequestsScreenState
    extends State<WorkerIncomingRequestsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'In Progress', 'Completed'];

  void _showVerifyOtpDialog(
    BuildContext context,
    BookingRequest booking,
    BookingProvider bp,
  ) {
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
            Text(
              'Ask customer ${booking.customerName} for their 4-digit start PIN:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: const InputDecoration(hintText: '4821'),
            ),
            const SizedBox(height: 6),
            Text(
              'Demo Tip: The customer PIN is "${booking.securityOtp}"',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
            ),
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
                    content: Text(
                      'Incorrect PIN. Please recheck with customer.',
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    final user = authProvider.currentUser;
    final worker = serviceState.getWorkerForUser(user);

    final allJobs = bookingProvider.getWorkerBookings(worker.id, categoryId: worker.categoryId);
    final filteredJobs = allJobs.where((b) {
      if (_selectedFilter == 'Pending') {
        return b.status == BookingStatus.requested;
      }
      if (_selectedFilter == 'In Progress') {
        return b.status == BookingStatus.accepted ||
            b.status == BookingStatus.inProgress;
      }
      if (_selectedFilter == 'Completed') {
        return b.status == BookingStatus.serviceDone ||
            b.status == BookingStatus.reviewed;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Jobs & Service Orders'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.secondaryColor.withValues(
                      alpha: isDark ? 0.25 : 0.15,
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.secondaryColor
                          : (isDark
                                ? const Color(0xFF2E2E2E)
                                : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.secondaryColor
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 54,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No ${_selectedFilter.toLowerCase()} jobs found.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, idx) {
                      final booking = filteredJobs[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${booking.customerName} • ${booking.categoryTitle}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(status: booking.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Phone: ${booking.customerPhone}',
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${booking.finalCost.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      booking.address,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.build_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Issue: ${booking.problemDescription}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              if (booking.scheduledTime.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Slot: ${booking.scheduledTime}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (booking.status == BookingStatus.requested)
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          bookingProvider.updateBookingStatus(
                                            booking.id,
                                            BookingStatus.cancelled,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Request Rejected'),
                                            ),
                                          );
                                        },
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.secondaryColor,
                                        ),
                                        onPressed: () {
                                          bookingProvider.updateBookingStatus(
                                            booking.id,
                                            BookingStatus.accepted,
                                            workerId: worker.id,
                                            workerName: worker.name,
                                            workerPhone: worker.phone,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Request Accepted! Customer notified.',
                                              ),
                                              backgroundColor:
                                                  AppTheme.secondaryColor,
                                            ),
                                          );
                                        },
                                        child: const Text('Accept Job'),
                                      ),
                                    ),
                                  ],
                                ),
                              if (booking.status == BookingStatus.accepted)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                    ),
                                    icon: const Icon(Icons.pin, size: 18),
                                    label: const Text(
                                      'Verify PIN & Start Work',
                                    ),
                                    onPressed: () => _showVerifyOtpDialog(
                                      context,
                                      booking,
                                      bookingProvider,
                                    ),
                                  ),
                                ),
                              if (booking.status == BookingStatus.inProgress)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.secondaryColor,
                                    ),
                                    onPressed: () {
                                      bookingProvider.updateBookingStatus(
                                        booking.id,
                                        BookingStatus.serviceDone,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Service marked Completed!',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Mark Service Completed (Step 7)',
                                    ),
                                  ),
                                ),
                              if (booking.status == BookingStatus.serviceDone ||
                                  booking.status == BookingStatus.reviewed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: AppTheme.secondaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        booking.status == BookingStatus.reviewed
                                            ? 'Completed & Reviewed'
                                            : 'Completed (Awaiting Customer Review)',
                                        style: const TextStyle(
                                          color: AppTheme.secondaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
