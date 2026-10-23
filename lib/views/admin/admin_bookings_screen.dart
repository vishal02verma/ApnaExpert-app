import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_request.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = ['All', 'Requested', 'Accepted', 'In Progress', 'Done', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    final bookings = bookingProvider.allBookings.where((b) {
      bool matchesFilter = true;
      if (_selectedFilter == 'Requested') matchesFilter = b.status == BookingStatus.requested;
      if (_selectedFilter == 'Accepted') matchesFilter = b.status == BookingStatus.accepted;
      if (_selectedFilter == 'In Progress') matchesFilter = b.status == BookingStatus.inProgress;
      if (_selectedFilter == 'Done') matchesFilter = b.status == BookingStatus.serviceDone || b.status == BookingStatus.reviewed;
      if (_selectedFilter == 'Cancelled') matchesFilter = b.status == BookingStatus.cancelled;

      bool matchesSearch = _searchQuery.isEmpty ||
          b.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.categoryTitle.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    double totalVolume = bookings.fold(0.0, (sum, b) => sum + b.finalCost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: System Bookings Monitor'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search bookings by ID, customer, service...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: isSelected,
                          showCheckmark: false,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          selectedColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? primary
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A)),
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilter = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${bookings.length} Bookings Found',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Volume: ₹${totalVolume.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: bookings.isEmpty
                ? const Center(child: Text('No system bookings recorded.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 85),
                    itemCount: bookings.length,
                    itemBuilder: (context, idx) {
                      final b = bookings[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${b.id} • ${b.categoryTitle}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(status: b.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Customer: ${b.customerName} (${b.customerPhone})', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('Technician: ${b.selectedWorkerName ?? "Unassigned"}', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('Location: ${b.address}', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('Issue: ${b.problemDescription}', style: const TextStyle(fontSize: 13)),
                              if (b.cancellationReason != null) ...[
                                const SizedBox(height: 2),
                                Text('Cancellation Reason: ${b.cancellationReason}', style: const TextStyle(color: Colors.red, fontSize: 13)),
                              ],
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Payment: ${b.paymentMethod} • Slot: ${b.scheduledTime}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '₹${b.finalCost.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
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
