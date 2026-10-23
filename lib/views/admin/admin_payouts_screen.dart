import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/payout_model.dart';
import '../../providers/payout_provider.dart';

class AdminPayoutsScreen extends StatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  State<AdminPayoutsScreen> createState() => _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends State<AdminPayoutsScreen> {
  String _selectedFilter = 'All'; // 'All', 'Pending', 'Completed', 'Processing', 'Rejected'

  void _showProcessPayoutDialog(BuildContext context, PayoutRequestModel payout, PayoutProvider provider) {
    final utrController = TextEditingController(text: payout.transactionReference ?? 'IMPS${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}');
    final noteController = TextEditingController(text: payout.adminNote ?? 'Processed via Banking Portal');
    PayoutStatus statusChoice = payout.status == PayoutStatus.pending ? PayoutStatus.completed : payout.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_rounded, color: Colors.purple, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('Process Payout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(payout.workerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '₹${payout.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857), fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Method: ${payout.payoutMethod}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (payout.payoutMethod == 'UPI')
                        Text('UPI ID: ${payout.upiId ?? "N/A"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                      else ...[
                        Text('A/C: ${payout.bankAccountNumber ?? "N/A"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('IFSC: ${payout.bankIfsc ?? "N/A"} • ${payout.bankName ?? ""}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                        Text('Holder: ${payout.bankAccountHolder ?? "N/A"}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    ChoiceChip(
                      label: const Text('Completed'),
                      selected: statusChoice == PayoutStatus.completed,
                      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                      onSelected: (s) => setDialogState(() => statusChoice = PayoutStatus.completed),
                    ),
                    ChoiceChip(
                      label: const Text('Processing'),
                      selected: statusChoice == PayoutStatus.processing,
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      onSelected: (s) => setDialogState(() => statusChoice = PayoutStatus.processing),
                    ),
                    ChoiceChip(
                      label: const Text('Reject'),
                      selected: statusChoice == PayoutStatus.rejected,
                      selectedColor: Colors.red.withValues(alpha: 0.2),
                      onSelected: (s) => setDialogState(() => statusChoice = PayoutStatus.rejected),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: utrController,
                  decoration: const InputDecoration(
                    labelText: 'Bank UTR / Transaction Ref ID',
                    hintText: 'e.g. IMPS621094821',
                    prefixIcon: Icon(Icons.receipt_long_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Note (Optional)',
                    hintText: 'e.g. Transferred to verified beneficiary',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: statusChoice == PayoutStatus.rejected ? Colors.red : Colors.purple.shade700,
              ),
              onPressed: () async {
                await provider.updatePayoutStatus(
                  payoutId: payout.id,
                  status: statusChoice,
                  reference: utrController.text.trim(),
                  adminNote: noteController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payout ${payout.id} marked as ${statusChoice.name.toUpperCase()}!'),
                      backgroundColor: Colors.purple.shade700,
                    ),
                  );
                }
              },
              child: const Text('Update Payout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payoutProvider = Provider.of<PayoutProvider>(context);
    final allPayouts = payoutProvider.allPayouts;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = allPayouts.where((p) {
      if (_selectedFilter == 'All') return true;
      return p.status.name.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Withdrawals & Payouts'),
        backgroundColor: isDark ? const Color(0xFF18181B) : Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: ['All', 'Pending', 'Completed', 'Processing', 'Rejected'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: Colors.purple.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payments_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No payouts matching "$_selectedFilter"',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final payout = filtered[idx];
                      final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(payout.createdAt);

                      Color statusColor;
                      switch (payout.status) {
                        case PayoutStatus.completed:
                          statusColor = const Color(0xFF10B981);
                          break;
                        case PayoutStatus.processing:
                          statusColor = Colors.blue;
                          break;
                        case PayoutStatus.pending:
                          statusColor = Colors.orange;
                          break;
                        case PayoutStatus.rejected:
                          statusColor = Colors.red;
                          break;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showProcessPayoutDialog(context, payout, payoutProvider),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: statusColor.withValues(alpha: 0.15),
                                          child: Icon(
                                            payout.payoutMethod == 'UPI' ? Icons.flash_on_rounded : Icons.account_balance_rounded,
                                            size: 16,
                                            color: statusColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          payout.workerName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '₹${payout.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${payout.payoutMethod}: ${payout.payoutMethod == "UPI" ? payout.upiId : (payout.bankAccountNumber ?? "")}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateFormatted,
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        payout.status.name.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (payout.transactionReference != null &&
                                    payout.transactionReference!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'UTR: ${payout.transactionReference}',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
