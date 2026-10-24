import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_request.dart';
import '../../models/payout_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/payout_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';

class WorkerEarningsScreen extends StatefulWidget {
  const WorkerEarningsScreen({super.key});

  @override
  State<WorkerEarningsScreen> createState() => _WorkerEarningsScreenState();
}

class _WorkerEarningsScreenState extends State<WorkerEarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showWithdrawalModal(BuildContext context, double availableBalance) {
    final payoutProvider = Provider.of<PayoutProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final serviceState = Provider.of<ServiceProviderState>(context, listen: false);

    final user = authProvider.currentUser;
    final worker = serviceState.getWorkerForUser(user);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WithdrawalModalSheet(
        availableBalance: availableBalance,
        workerId: worker.id,
        workerName: worker.name,
        payoutProvider: payoutProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final serviceState = Provider.of<ServiceProviderState>(context);
    final payoutProvider = Provider.of<PayoutProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authProvider.currentUser;
    final worker = serviceState.getWorkerForUser(user);

    final completedJobs = bookingProvider.getWorkerBookings(worker.id).where(
      (b) => b.status == BookingStatus.serviceDone || b.status == BookingStatus.reviewed,
    ).toList();

    final workerPayouts = payoutProvider.getPayoutsForWorker(worker.id);

    final double totalEarnings = completedJobs.fold(0.0, (sum, b) => sum + b.finalCost);
    final double totalWithdrawn = payoutProvider.getTotalWithdrawnForWorker(worker.id);
    final double pendingPayouts = payoutProvider.getPendingPayoutsForWorker(worker.id);
    final double availableBalance =
        (totalEarnings - totalWithdrawn - pendingPayouts).clamp(0.0, double.infinity);
    final double averagePerJob = completedJobs.isEmpty ? 0.0 : totalEarnings / completedJobs.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Payouts'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Payout Info & Help',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showPayoutInfoDialog(context),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    // Total Earnings Hero Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF047857), Color(0xFF065F46)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF047857).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_rounded,
                                      color: Colors.white70, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Available Payout Balance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt_rounded, color: Colors.amber, size: 14),
                                    SizedBox(width: 3),
                                    Text(
                                      '0% Fee Transfer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${availableBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (pendingPayouts > 0)
                                Text(
                                  '(₹${pendingPayouts.toStringAsFixed(0)} in review)',
                                  style: TextStyle(
                                    color: Colors.amber.shade200,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Lifetime Earned',
                                        style: TextStyle(color: Colors.white60, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${totalEarnings.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 26, color: Colors.white24),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Withdrawn',
                                          style: TextStyle(color: Colors.white60, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${totalWithdrawn.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 26, color: Colors.white24),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Settled Jobs',
                                          style: TextStyle(color: Colors.white60, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${completedJobs.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF065F46),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.send_to_mobile_rounded, size: 18),
                              label: Text(
                                availableBalance > 0
                                    ? 'Withdraw to Bank / UPI'
                                    : 'Zero Balance to Withdraw',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              onPressed: availableBalance <= 0
                                  ? null
                                  : () => _showWithdrawalModal(context, availableBalance),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.task_alt_rounded,
                            iconColor: Colors.blue,
                            title: 'Completed Jobs',
                            value: '${completedJobs.length}',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.price_check_rounded,
                            iconColor: const Color(0xFF047857),
                            title: 'Avg. per Job',
                            value: '₹${averagePerJob.toStringAsFixed(0)}',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.history_rounded,
                            iconColor: Colors.purple,
                            title: 'Payout Count',
                            value: '${workerPayouts.length}',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.secondaryColor,
                  labelColor: AppTheme.secondaryColor,
                  unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.monetization_on_outlined, size: 18),
                      text: 'Job Earnings (${completedJobs.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      text: 'Withdrawals (${workerPayouts.length})',
                    ),
                  ],
                ),
                isDark: isDark,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Completed Jobs Earnings List
            _buildJobsEarningsTab(context, completedJobs, isDark),

            // Tab 2: Payout Requests and History List
            _buildPayoutsHistoryTab(context, workerPayouts, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildJobsEarningsTab(
    BuildContext context,
    List<BookingRequest> jobs,
    bool isDark,
  ) {
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_history_outlined,
                    size: 36, color: AppTheme.secondaryColor),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Settled Jobs Yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Once you accept and complete service bookings, customer payments and job earnings will reflect here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: jobs.length,
      itemBuilder: (context, idx) {
        final job = jobs[idx];
        final formattedDate = job.completedAt != null
            ? DateFormat('dd MMM yyyy, hh:mm a').format(job.completedAt!)
            : DateFormat('dd MMM yyyy').format(job.createdAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.call_received_rounded,
                    color: Color(0xFF10B981),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.customerName.isNotEmpty ? job.customerName : 'Direct Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${job.categoryTitle} • #${job.id}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.payment_rounded, size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                job.paymentMethod,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+₹${job.finalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SETTLED',
                        style: TextStyle(
                          color: Color(0xFF047857),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayoutsHistoryTab(
    BuildContext context,
    List<PayoutRequestModel> payouts,
    bool isDark,
  ) {
    if (payouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_outlined, size: 36, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Withdrawals Yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'When you request a payout via UPI or Bank Account, all transaction receipts and status will be logged here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: payouts.length,
      itemBuilder: (context, idx) {
        final payout = payouts[idx];
        final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(payout.createdAt);

        Color statusColor;
        String statusLabel;
        IconData statusIcon;

        switch (payout.status) {
          case PayoutStatus.completed:
            statusColor = const Color(0xFF10B981);
            statusLabel = 'COMPLETED';
            statusIcon = Icons.check_circle_rounded;
            break;
          case PayoutStatus.processing:
            statusColor = const Color(0xFF0284C7);
            statusLabel = 'PROCESSING';
            statusIcon = Icons.sync_rounded;
            break;
          case PayoutStatus.pending:
            statusColor = Colors.orange;
            statusLabel = 'PENDING';
            statusIcon = Icons.hourglass_top_rounded;
            break;
          case PayoutStatus.rejected:
            statusColor = Colors.red;
            statusLabel = 'REJECTED';
            statusIcon = Icons.cancel_rounded;
            break;
        }

        final destination = payout.payoutMethod == 'UPI'
            ? 'UPI: ${payout.upiId ?? "VPA"}'
            : 'Bank: ${payout.bankName ?? "A/C"} ••${payout.bankAccountNumber != null && payout.bankAccountNumber!.length >= 4 ? payout.bankAccountNumber!.substring(payout.bankAccountNumber!.length - 4) : ""}';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    payout.payoutMethod == 'UPI' ? Icons.qr_code_2_rounded : Icons.account_balance_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              destination,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ref: ${payout.id}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11.5),
                      ),
                      if (payout.transactionReference != null &&
                          payout.transactionReference!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'UTR: ${payout.transactionReference}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-₹${payout.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 10, color: statusColor),
                          const SizedBox(width: 3),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPayoutInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: AppTheme.secondaryColor),
            SizedBox(width: 8),
            Text('Payout Protection & Timing'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚡ Instant UPI Transfer: Direct transfer to Google Pay, PhonePe, or Paytm UPI ID within 2-4 hours.',
                style: TextStyle(fontSize: 12.5)),
            SizedBox(height: 10),
            Text('🏦 IMPS Bank Transfer: Directly sent to your savings/current account. Settles automatically on all days.',
                style: TextStyle(fontSize: 12.5)),
            SizedBox(height: 10),
            Text('🔒 100% Platform Guarantee: No deduction or commission taken from technician completed earnings.',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Understood')),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _SliverAppBarDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _WithdrawalModalSheet extends StatefulWidget {
  final double availableBalance;
  final String workerId;
  final String workerName;
  final PayoutProvider payoutProvider;

  const _WithdrawalModalSheet({
    required this.availableBalance,
    required this.workerId,
    required this.workerName,
    required this.payoutProvider,
  });

  @override
  State<_WithdrawalModalSheet> createState() => _WithdrawalModalSheetState();
}

class _WithdrawalModalSheetState extends State<_WithdrawalModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _upiController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _holderController;
  late TextEditingController _bankNameController;

  String _payoutMethod = 'UPI'; // 'UPI' or 'Bank'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.payoutProvider;
    _amountController = TextEditingController(text: widget.availableBalance.toStringAsFixed(0));
    _upiController = TextEditingController(text: p.savedUpiId ?? '${widget.workerName.toLowerCase().replaceAll(" ", "")}@okhdfcbank');
    _accountNumberController = TextEditingController(text: p.savedBankAccount ?? '');
    _ifscController = TextEditingController(text: p.savedBankIfsc ?? 'HDFC0001234');
    _holderController = TextEditingController(text: p.savedAccountHolder ?? widget.workerName);
    _bankNameController = TextEditingController(text: p.savedBankName ?? 'HDFC Bank');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _holderController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amt <= 0 || amt > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid withdrawal amount. Exceeds available balance.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payout = await widget.payoutProvider.requestPayout(
      workerId: widget.workerId,
      workerName: widget.workerName,
      amount: amt,
      payoutMethod: _payoutMethod == 'UPI' ? 'UPI' : 'Bank Transfer',
      upiId: _payoutMethod == 'UPI' ? _upiController.text.trim() : null,
      bankAccountNumber: _payoutMethod == 'Bank' ? _accountNumberController.text.trim() : null,
      bankIfsc: _payoutMethod == 'Bank' ? _ifscController.text.trim().toUpperCase() : null,
      bankAccountHolder: _payoutMethod == 'Bank' ? _holderController.text.trim() : null,
      bankName: _payoutMethod == 'Bank' ? _bankNameController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pop(context); // Close sheet

    if (payout != null) {
      _showWithdrawalSuccessDialog(context, payout);
    }
  }

  void _showWithdrawalSuccessDialog(BuildContext context, PayoutRequestModel payout) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF047857), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Withdrawal Initiated!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '₹${payout.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF047857),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payout ID:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(payout.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transfer Mode:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(payout.payoutMethod, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Destination:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Flexible(
                        child: Text(
                          payout.payoutMethod == 'UPI'
                              ? (payout.upiId ?? '')
                              : 'A/C ••${payout.bankAccountNumber != null && payout.bankAccountNumber!.length >= 4 ? payout.bankAccountNumber!.substring(payout.bankAccountNumber!.length - 4) : ""}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your payout request is being processed via IMPS/UPI. Funds will credit to your account within 2-4 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047857),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done & View Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Withdraw Earnings',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Available Balance: ₹${widget.availableBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF047857),
                ),
              ),
              const SizedBox(height: 16),

              // Payout Method Selector
              const Text('Select Payout Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFF047857)),
                          SizedBox(width: 4),
                          Text('UPI Instant', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      selected: _payoutMethod == 'UPI',
                      selectedColor: const Color(0xFF047857).withValues(alpha: 0.15),
                      onSelected: (val) {
                        if (val) setState(() => _payoutMethod = 'UPI');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_rounded, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Text('Bank Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      selected: _payoutMethod == 'Bank',
                      selectedColor: Colors.blue.withValues(alpha: 0.15),
                      onSelected: (val) {
                        if (val) setState(() => _payoutMethod = 'Bank');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount Input Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Withdrawal Amount (₹) *',
                  hintText: 'Enter amount to withdraw',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  suffixText: 'Max: ₹${widget.availableBalance.toStringAsFixed(0)}',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                  final n = double.tryParse(val.trim());
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  if (n > widget.availableBalance) return 'Exceeds available balance';
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Preset Amount Quick Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (widget.availableBalance >= 200)
                      _buildQuickAmountChip('₹200', 200),
                    if (widget.availableBalance >= 500)
                      _buildQuickAmountChip('₹500', 500),
                    if (widget.availableBalance >= 1000)
                      _buildQuickAmountChip('₹1,000', 1000),
                    _buildQuickAmountChip('Full ₹${widget.availableBalance.toStringAsFixed(0)}', widget.availableBalance),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Conditional Fields based on method
              if (_payoutMethod == 'UPI') ...[
                TextFormField(
                  controller: _upiController,
                  decoration: const InputDecoration(
                    labelText: 'UPI Virtual Payment Address (VPA) *',
                    hintText: 'e.g. mobile@paytm or name@okhdfcbank',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                    helperText: 'Google Pay, PhonePe, Paytm, BHIM UPI ID supported',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your UPI ID';
                    if (!val.contains('@')) return 'Enter a valid UPI ID (e.g. name@bank)';
                    return null;
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _holderController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name *',
                    hintText: 'Full name as per bank records',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter account holder name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bank Account Number *',
                    hintText: '9 to 18 digits account number',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter account number';
                    if (val.trim().length < 9) return 'Account number too short';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _ifscController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'IFSC Code *',
                          hintText: 'e.g. HDFC0001234',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (val) => val == null || val.trim().length < 6 ? 'Invalid IFSC' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _bankNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Bank Name',
                          hintText: 'e.g. SBI, HDFC',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Fee Guarantee note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF047857).withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Color(0xFF047857), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '0% platform withdrawal fee • Direct IMPS settlement to your account',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF047857),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'Processing Payout...' : 'Confirm & Withdraw Now',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: _isSubmitting ? null : _handleConfirmWithdrawal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
        onPressed: () {
          setState(() {
            _amountController.text = amount.toStringAsFixed(0);
          });
        },
      ),
    );
  }
}
