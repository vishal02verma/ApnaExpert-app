import 'package:flutter/foundation.dart';
import '../models/payout_model.dart';
import '../services/firestore_service.dart';

class PayoutProvider extends ChangeNotifier {
  final List<PayoutRequestModel> _payouts = [
    // Pre-seed a sample completed payout for demonstration
    PayoutRequestModel(
      id: 'PAY-89214',
      workerId: 'wrk_001',
      workerName: 'Ramesh Kumar',
      amount: 500.0,
      payoutMethod: 'UPI',
      upiId: 'ramesh.kumar@okhdfcbank',
      status: PayoutStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      processedAt: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
      transactionReference: 'UPI/IMPS/529104819201',
      adminNote: 'Settled to technician account',
    ),
  ];

  // Saved user payout details for fast re-use
  String? _savedUpiId;
  String? _savedBankAccount;
  String? _savedBankIfsc;
  String? _savedAccountHolder;
  String? _savedBankName;

  String? get savedUpiId => _savedUpiId;
  String? get savedBankAccount => _savedBankAccount;
  String? get savedBankIfsc => _savedBankIfsc;
  String? get savedAccountHolder => _savedAccountHolder;
  String? get savedBankName => _savedBankName;

  List<PayoutRequestModel> get allPayouts => List.unmodifiable(_payouts);

  List<PayoutRequestModel> getPayoutsForWorker(String workerId) {
    return _payouts.where((p) => p.workerId == workerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Total amount withdrawn or in process (not rejected)
  double getTotalWithdrawnForWorker(String workerId) {
    final workerPayouts = _payouts.where(
      (p) => p.workerId == workerId && (p.status == PayoutStatus.completed || p.status == PayoutStatus.processing),
    );
    return workerPayouts.fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Total amount currently pending review
  double getPendingPayoutsForWorker(String workerId) {
    final workerPayouts = _payouts.where(
      (p) => p.workerId == workerId && p.status == PayoutStatus.pending,
    );
    return workerPayouts.fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Submit a new withdrawal request
  Future<PayoutRequestModel?> requestPayout({
    required String workerId,
    required String workerName,
    required double amount,
    required String payoutMethod, // 'UPI' or 'Bank Transfer'
    String? upiId,
    String? bankAccountNumber,
    String? bankIfsc,
    String? bankAccountHolder,
    String? bankName,
  }) async {
    final cleanAmount = double.parse(amount.toStringAsFixed(2));
    if (cleanAmount <= 0) return null;

    final newId = 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    // Save details for future fast auto-fill
    if (payoutMethod == 'UPI' && upiId != null) {
      _savedUpiId = upiId.trim();
    } else {
      _savedBankAccount = bankAccountNumber?.trim();
      _savedBankIfsc = bankIfsc?.trim().toUpperCase();
      _savedAccountHolder = bankAccountHolder?.trim();
      _savedBankName = bankName?.trim();
    }

    final newPayout = PayoutRequestModel(
      id: newId,
      workerId: workerId,
      workerName: workerName,
      amount: cleanAmount,
      payoutMethod: payoutMethod,
      upiId: upiId?.trim(),
      bankAccountNumber: bankAccountNumber?.trim(),
      bankIfsc: bankIfsc?.trim().toUpperCase(),
      bankAccountHolder: bankAccountHolder?.trim(),
      bankName: bankName?.trim(),
      status: PayoutStatus.pending,
      createdAt: DateTime.now(),
      transactionReference: 'PENDING_ADMIN_APPROVAL',
    );

    _payouts.insert(0, newPayout);
    notifyListeners();

    // Persist to Cloud Firestore
    await FirestoreService.createPayoutRequest(newPayout);

    return newPayout;
  }

  /// Admin updates payout status (e.g. approve, mark completed, add UTR reference)
  Future<bool> updatePayoutStatus({
    required String payoutId,
    required PayoutStatus status,
    String? reference,
    String? adminNote,
  }) async {
    final idx = _payouts.indexWhere((p) => p.id == payoutId);
    if (idx != -1) {
      _payouts[idx] = _payouts[idx].copyWith(
        status: status,
        processedAt: DateTime.now(),
        transactionReference: reference ?? _payouts[idx].transactionReference,
        adminNote: adminNote ?? _payouts[idx].adminNote,
      );
      notifyListeners();

      await FirestoreService.updatePayoutStatus(
        payoutId,
        status,
        reference: reference,
        adminNote: adminNote,
      );
      return true;
    }
    return false;
  }
}
