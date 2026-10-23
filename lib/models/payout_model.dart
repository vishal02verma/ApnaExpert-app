enum PayoutStatus {
  pending,
  processing,
  completed,
  rejected,
}

class PayoutRequestModel {
  final String id;
  final String workerId;
  final String workerName;
  final double amount;
  final String payoutMethod; // 'UPI' or 'Bank Transfer'
  final String? upiId;
  final String? bankAccountNumber;
  final String? bankIfsc;
  final String? bankAccountHolder;
  final String? bankName;
  final PayoutStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? transactionReference;
  final String? adminNote;

  PayoutRequestModel({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.amount,
    required this.payoutMethod,
    this.upiId,
    this.bankAccountNumber,
    this.bankIfsc,
    this.bankAccountHolder,
    this.bankName,
    this.status = PayoutStatus.pending,
    required this.createdAt,
    this.processedAt,
    this.transactionReference,
    this.adminNote,
  });

  PayoutRequestModel copyWith({
    String? id,
    String? workerId,
    String? workerName,
    double? amount,
    String? payoutMethod,
    String? upiId,
    String? bankAccountNumber,
    String? bankIfsc,
    String? bankAccountHolder,
    String? bankName,
    PayoutStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    String? transactionReference,
    String? adminNote,
  }) {
    return PayoutRequestModel(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      amount: amount ?? this.amount,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      upiId: upiId ?? this.upiId,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      bankAccountHolder: bankAccountHolder ?? this.bankAccountHolder,
      bankName: bankName ?? this.bankName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      transactionReference: transactionReference ?? this.transactionReference,
      adminNote: adminNote ?? this.adminNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workerId': workerId,
      'workerName': workerName,
      'amount': amount,
      'payoutMethod': payoutMethod,
      'upiId': upiId,
      'bankAccountNumber': bankAccountNumber,
      'bankIfsc': bankIfsc,
      'bankAccountHolder': bankAccountHolder,
      'bankName': bankName,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'transactionReference': transactionReference,
      'adminNote': adminNote,
    };
  }

  factory PayoutRequestModel.fromMap(Map<String, dynamic> map) {
    PayoutStatus status = PayoutStatus.pending;
    if (map['status'] != null) {
      status = PayoutStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PayoutStatus.pending,
      );
    }

    return PayoutRequestModel(
      id: map['id'] ?? '',
      workerId: map['workerId'] ?? '',
      workerName: map['workerName'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      payoutMethod: map['payoutMethod'] ?? 'UPI',
      upiId: map['upiId'],
      bankAccountNumber: map['bankAccountNumber'],
      bankIfsc: map['bankIfsc'],
      bankAccountHolder: map['bankAccountHolder'],
      bankName: map['bankName'],
      status: status,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      processedAt: map['processedAt'] != null
          ? DateTime.tryParse(map['processedAt'])
          : null,
      transactionReference: map['transactionReference'],
      adminNote: map['adminNote'],
    );
  }
}
