import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/booking_status_stepper.dart';
import '../../widgets/status_badge.dart';

class BookingTrackerScreen extends StatefulWidget {
  final String bookingId;

  const BookingTrackerScreen({super.key, required this.bookingId});

  @override
  State<BookingTrackerScreen> createState() => _BookingTrackerScreenState();
}

class _BookingTrackerScreenState extends State<BookingTrackerScreen> {
  double _userRating = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _selectedReviewTags = [];
  final List<String> _feedbackOptions = [
    'Punctual',
    'Polite Behavior',
    'Expert Work',
    'Cleaned After Work',
    'Affordable',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _showChatDialog(BuildContext context, BookingRequest booking, BookingProvider bookingProvider, AuthProvider authProvider) {
    final messageController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final messages = bookingProvider.getMessages(booking.id);
            final user = authProvider.currentUser;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: 480,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chat with ${booking.selectedWorkerName ?? "Technician"}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Text(
                                'Live Coordination • In-app safe chat',
                                style: TextStyle(color: AppTheme.subtitleColor, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: messages.isEmpty
                          ? const Center(
                              child: Text(
                                'No messages yet.\nSend a message to coordinate with technician.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
                              ),
                            )
                          : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, idx) {
                                final msg = messages[idx];
                                final isMe = msg.isCustomer;
                                return Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppTheme.primaryColor
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(14),
                                        topRight: const Radius.circular(14),
                                        bottomLeft: Radius.circular(isMe ? 14 : 2),
                                        bottomRight: Radius.circular(isMe ? 2 : 14),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.text,
                                          style: TextStyle(
                                            color: isMe ? Colors.white : null,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isMe ? Colors.white70 : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                bookingProvider.sendMessage(
                                  booking.id,
                                  user.id,
                                  user.name,
                                  val,
                                  true,
                                );
                                messageController.clear();
                                setModalState(() {});
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.send, size: 18),
                          onPressed: () {
                            if (messageController.text.trim().isNotEmpty) {
                              bookingProvider.sendMessage(
                                booking.id,
                                user.id,
                                user.name,
                                messageController.text,
                                true,
                              );
                              messageController.clear();
                              setModalState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, BookingRequest booking, BookingProvider bookingProvider) {
    String selectedReason = 'Change of plans / Emergency';
    final reasons = [
      'Change of plans / Emergency',
      'Worker taking too long to arrive',
      'Issue fixed by myself',
      'Price discrepancy',
      'Booked by mistake',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red),
                SizedBox(width: 8),
                Text('Cancel Booking'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please select a cancellation reason:'),
                const SizedBox(height: 12),
                ...reasons.map((r) {
                  final isSelected = selectedReason == r;
                  return InkWell(
                    onTap: () {
                      setDialogState(() => selectedReason = r);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Keep Booking'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  bookingProvider.cancelBooking(booking.id, selectedReason);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking has been cancelled.')),
                  );
                },
                child: const Text('Confirm Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context, BookingRequest booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: AppTheme.secondaryColor),
            const SizedBox(width: 8),
            Text('Invoice ${booking.id}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${booking.categoryTitle}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Specialist: ${booking.selectedWorkerName ?? "Technician"}'),
            Text('Date: ${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Standard Service Charge'),
                Text('₹${booking.estimatedCost.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Platform & Safety Fee'),
                Text('FREE', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            if (booking.discountAmount > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Promo Discount', style: TextStyle(color: AppTheme.secondaryColor)),
                  Text('-₹${booking.discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.secondaryColor)),
                ],
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  '₹${booking.finalCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Paid via: ${booking.paymentMethod}', style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt link copied to clipboard!')),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download PDF'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice PDF downloaded to device!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    final booking = bookingProvider.allBookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => BookingRequest(
        id: widget.bookingId,
        customerId: 'cust',
        customerName: 'Customer',
        customerPhone: '',
        categoryId: 'cat',
        categoryTitle: 'Service',
        problemDescription: 'Details',
        urgency: 'Normal',
        address: 'Address',
        landmark: '',
        estimatedCost: 50,
        paymentMethod: 'Cash',
        status: BookingStatus.requested,
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking ${booking.id}'),
        actions: [
          if (booking.status != BookingStatus.cancelled)
            IconButton(
              tooltip: 'Invoice / Receipt',
              icon: const Icon(Icons.receipt_long_rounded),
              onPressed: () => _showInvoiceDialog(context, booking),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingStatusStepper(currentStatus: booking.status),
            const SizedBox(height: 16),

            // Security OTP PIN Card (Shown when requested/accepted/inProgress)
            if (booking.status == BookingStatus.requested ||
                booking.status == BookingStatus.accepted ||
                booking.status == BookingStatus.inProgress) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? const Color(0xFF1E3A8A) : AppTheme.primaryColor,
                      isDark ? const Color(0xFF0F172A) : const Color(0xFF1E40AF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.amber, size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'START SERVICE SECURITY PIN',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Share PIN with worker upon arrival',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        booking.securityOtp,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 3,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Live Status Hero Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
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
                          Icon(Icons.build_circle, color: primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            booking.categoryTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Problem: ${booking.problemDescription}',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkSubtitleColor : Colors.grey.shade800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // Worker Coordination Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primary.withValues(alpha: 0.12),
                        child: Icon(Icons.engineering, color: primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.selectedWorkerName ?? "Pending assignment",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Specialist • ${booking.selectedWorkerPhone ?? "+91 98765 00100"}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.subtitleColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Message Technician',
                        icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryLight),
                        onPressed: () => _showChatDialog(context, booking, bookingProvider, authProvider),
                      ),
                      IconButton(
                        tooltip: 'Call Technician',
                        icon: const Icon(Icons.phone, color: AppTheme.secondaryColor),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dialing ${booking.selectedWorkerName ?? "Worker"} (${booking.selectedWorkerPhone})...'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Divider(),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        'Scheduled: ${booking.scheduledTime}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking.address} ${booking.landmark.isNotEmpty ? "(${booking.landmark})" : ""}',
                          style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkSubtitleColor : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.payment, size: 16, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        'Payment: ${booking.paymentMethod} (₹${booking.finalCost.toStringAsFixed(2)})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),

                  if (booking.cancellationReason != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cancellation Reason: ${booking.cancellationReason}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Booking Action Simulation Card
            _buildInteractiveStatusDemoCard(context, bookingProvider, booking),

            const SizedBox(height: 16),

            // STEP 8: LEAVE A REVIEW CARD (If Service Done & Not Reviewed Yet)
            if (booking.status == BookingStatus.serviceDone) ...[
              _buildStep8ReviewCard(context, bookingProvider, booking),
            ],

            // Display existing review if completed
            if (booking.review != null) ...[
              Card(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Step 8 Complete: ${booking.review!.rating} Stars Review',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Spacer(),
                          if (booking.review!.isFlagged)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('FLAGGED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${booking.review!.comment}"',
                        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Cancel Booking Button (if not already done or cancelled)
            if (booking.status != BookingStatus.serviceDone &&
                booking.status != BookingStatus.reviewed &&
                booking.status != BookingStatus.cancelled) ...[
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel This Booking'),
                  onPressed: () => _showCancelDialog(context, booking, bookingProvider),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Interactive Demo card to trigger statuses for testing/demo
  Widget _buildInteractiveStatusDemoCard(
    BuildContext context,
    BookingProvider bookingProvider,
    BookingRequest booking,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app, color: AppTheme.primaryLight, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Live Booking Action Simulation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Interactive', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Simulate status transitions (Worker accept, complete service, review):',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (booking.status == BookingStatus.requested)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Simulate Worker Accept (Step 6)'),
                    onPressed: () {
                      bookingProvider.updateBookingStatus(booking.id, BookingStatus.accepted);
                    },
                  ),
                if (booking.status == BookingStatus.accepted)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.engineering, size: 16),
                    label: const Text('Technician Arrived (In Progress)'),
                    onPressed: () {
                      bookingProvider.updateBookingStatus(booking.id, BookingStatus.inProgress);
                    },
                  ),
                if (booking.status == BookingStatus.inProgress)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Mark Service Done (Step 7)'),
                    onPressed: () {
                      bookingProvider.updateBookingStatus(booking.id, BookingStatus.serviceDone);
                    },
                  ),
                if (booking.status == BookingStatus.serviceDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Service Done! Submit your review below.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                if (booking.status == BookingStatus.reviewed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('8-Step Journey Fully Complete! Thank you.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // STEP 8: LEAVE REVIEW
  Widget _buildStep8ReviewCard(
    BuildContext context,
    BookingProvider bookingProvider,
    BookingRequest booking,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.amber, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rate_review_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  'Step 8: Write a Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Rate your service experience with ${booking.selectedWorkerName ?? "worker"}.',
              style: const TextStyle(fontSize: 13, color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 14),

            // Star selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starRating = index + 1;
                return IconButton(
                  icon: Icon(
                    starRating <= _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 34,
                  ),
                  onPressed: () {
                    setState(() {
                      _userRating = starRating.toDouble();
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 10),

            // Multi-tag feedback chips
            const Text('What went well?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _feedbackOptions.map((tag) {
                final isSelected = _selectedReviewTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedReviewTags.add(tag);
                      } else {
                        _selectedReviewTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share feedback on punctuality, quality, and behavior...',
                labelText: 'Review Comment *',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
                onPressed: () {
                  if (_reviewController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please write a brief comment.')),
                    );
                    return;
                  }

                  String fullComment = _reviewController.text.trim();
                  if (_selectedReviewTags.isNotEmpty) {
                    fullComment += ' [Highlights: ${_selectedReviewTags.join(", ")}]';
                  }

                  bookingProvider.submitReview(
                    booking.id,
                    _userRating,
                    fullComment,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review submitted! Thank you.'),
                      backgroundColor: Colors.amber,
                    ),
                  );
                },
                child: const Text('Submit Review (Step 8)'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
