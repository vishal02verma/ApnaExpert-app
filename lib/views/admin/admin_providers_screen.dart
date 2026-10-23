import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker_model.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_avatar.dart';

class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  String _filter = 'All';
  String _searchQuery = '';

  void _showProviderDetails(BuildContext context, WorkerModel w) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(w.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trade / Category: ${w.categoryName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Phone: ${w.phone}'),
            Text('Experience: ${w.experience}'),
            Text('Hourly Rate: ₹${w.hourlyRate.toStringAsFixed(0)}'),
            Text('Rating: ${w.rating} ⭐ (${w.totalReviews} reviews)'),
            const SizedBox(height: 8),
            const Text('Professional Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(w.bio, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Verification Status: '),
                Text(
                  w.isVerified ? 'VERIFIED' : 'PENDING APPROVAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: w.isVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = Provider.of<ServiceProviderState>(context);
    final workers = serviceState.workers.where((w) {
      bool matchesFilter = true;
      if (_filter == 'Verified') matchesFilter = w.isVerified;
      if (_filter == 'Pending') matchesFilter = !w.isVerified;

      bool matchesSearch = _searchQuery.isEmpty ||
          w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.categoryName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF0284C7) : AppTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Manage Service Providers'),
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
                    hintText: 'Search service workers...',
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
                    children: ['All', 'Pending', 'Verified'].map((f) {
                      final isSelected = _filter == f;
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
                            if (val) setState(() => _filter = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: workers.isEmpty
                ? const Center(child: Text('No service workers match the criteria.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workers.length,
                    itemBuilder: (context, idx) {
                      final w = workers[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              AppAvatar(
                                avatarUrl: w.avatarUrl,
                                name: w.name,
                                radius: 26,
                                defaultIcon: Icons.engineering_rounded,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          w.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (w.isVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                                        ]
                                      ],
                                    ),
                                    Text('Trade: ${w.categoryName} • ${w.phone}'),
                                    Text('Rate: ₹${w.hourlyRate.toStringAsFixed(0)}/job • Rating: ${w.rating} ⭐'),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: w.isVerified ? Colors.red : AppTheme.secondaryColor,
                                    ),
                                    icon: Icon(w.isVerified ? Icons.cancel_outlined : Icons.verified_user, size: 16),
                                    label: Text(w.isVerified ? 'Revoke' : 'Approve'),
                                    onPressed: () {
                                      serviceState.toggleWorkerVerification(w.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            w.isVerified
                                                ? 'Provider Verification Revoked'
                                                : 'Provider Approved & Verified!',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () => _showProviderDetails(context, w),
                                    child: const Text('Details', style: TextStyle(fontSize: 12)),
                                  )
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
