enum BookingStatus {
  selectService, // Step 1
  describeProblem, // Step 2
  location, // Step 3
  nearbyWorkers, // Step 4
  requested, // Step 5: Submitted request, pending worker response
  accepted, // Step 6: Worker accepted, on the way / arrived
  inProgress, // Working on site
  serviceDone, // Step 7: Worker completed service
  reviewed, // Step 8: Customer submitted review
  cancelled, // Request cancelled or rejected
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.selectService:
        return 'Select Service';
      case BookingStatus.describeProblem:
        return 'Describe Problem';
      case BookingStatus.location:
        return 'Location';
      case BookingStatus.nearbyWorkers:
        return 'Nearby Workers';
      case BookingStatus.requested:
        return 'Request Pending';
      case BookingStatus.accepted:
        return 'Worker Accepted';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.serviceDone:
        return 'Service Done';
      case BookingStatus.reviewed:
        return 'Reviewed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case BookingStatus.selectService:
        return 1;
      case BookingStatus.describeProblem:
        return 2;
      case BookingStatus.location:
        return 3;
      case BookingStatus.nearbyWorkers:
        return 4;
      case BookingStatus.requested:
        return 5;
      case BookingStatus.accepted:
        return 6;
      case BookingStatus.inProgress:
        return 6;
      case BookingStatus.serviceDone:
        return 7;
      case BookingStatus.reviewed:
        return 8;
      case BookingStatus.cancelled:
        return 0;
    }
  }
}

class ReviewModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String customerName;
  final String workerId;
  final String workerName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isFlagged;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.workerId,
    required this.workerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isFlagged = false,
  });

  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? customerName,
    String? workerId,
    String? workerName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    bool? isFlagged,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'workerId': workerId,
      'workerName': workerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isFlagged': isFlagged,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return ReviewModel(
      id: map['id']?.toString() ?? '',
      bookingId: map['bookingId']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      workerId: map['workerId']?.toString() ?? '',
      workerName: map['workerName']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment']?.toString() ?? '',
      createdAt: parseDate(map['createdAt']),
      isFlagged: map['isFlagged'] == true,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isCustomer;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isCustomer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isCustomer': isCustomer,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return ChatMessage(
      id: map['id']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      timestamp: parseDate(map['timestamp']),
      isCustomer: map['isCustomer'] == true,
    );
  }
}

class BookingRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String categoryId;
  final String categoryTitle;
  final String problemDescription;
  final String urgency; // 'Normal', 'Urgent', 'Emergency'
  final String address;
  final String landmark;
  final String? selectedWorkerId;
  final String? selectedWorkerName;
  final String? selectedWorkerPhone;
  final double estimatedCost;
  final double discountAmount;
  final String paymentMethod; // 'Cash on Service', 'Card', 'UPI'
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final ReviewModel? review;
  final String scheduledTime;
  final String securityOtp;
  final String? cancellationReason;
  final String? problemPhoto;

  BookingRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.categoryId,
    required this.categoryTitle,
    required this.problemDescription,
    required this.urgency,
    required this.address,
    required this.landmark,
    this.selectedWorkerId,
    this.selectedWorkerName,
    this.selectedWorkerPhone,
    required this.estimatedCost,
    this.discountAmount = 0.0,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.review,
    this.scheduledTime = 'Today (Immediate)',
    this.securityOtp = '4821',
    this.cancellationReason,
    this.problemPhoto,
  });

  double get finalCost =>
      (estimatedCost - discountAmount).clamp(0.0, double.infinity);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'categoryId': categoryId,
      'categoryTitle': categoryTitle,
      'problemDescription': problemDescription,
      'urgency': urgency,
      'address': address,
      'landmark': landmark,
      'selectedWorkerId': selectedWorkerId,
      'selectedWorkerName': selectedWorkerName,
      'selectedWorkerPhone': selectedWorkerPhone,
      'estimatedCost': estimatedCost,
      'discountAmount': discountAmount,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'scheduledTime': scheduledTime,
      'securityOtp': securityOtp,
      if (problemPhoto != null) 'problemPhoto': problemPhoto,
      'createdAt': createdAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (review != null) 'review': review!.toMap(),
    };
  }

  factory BookingRequest.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    BookingStatus parseStatus(dynamic val) {
      if (val == null) return BookingStatus.requested;
      final str = val.toString();
      for (final s in BookingStatus.values) {
        if (s.name == str) return s;
      }
      return BookingStatus.requested;
    }

    return BookingRequest(
      id: map['id']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      customerPhone: map['customerPhone']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryTitle: map['categoryTitle']?.toString() ?? '',
      problemDescription: map['problemDescription']?.toString() ?? '',
      urgency: map['urgency']?.toString() ?? 'Normal',
      address: map['address']?.toString() ?? '',
      landmark: map['landmark']?.toString() ?? '',
      selectedWorkerId: map['selectedWorkerId']?.toString(),
      selectedWorkerName: map['selectedWorkerName']?.toString(),
      selectedWorkerPhone: map['selectedWorkerPhone']?.toString(),
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 249.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod']?.toString() ?? 'Cash on Service',
      status: parseStatus(map['status']),
      createdAt: parseDate(map['createdAt']),
      completedAt: map['completedAt'] != null ? parseDate(map['completedAt']) : null,
      review: map['review'] != null && map['review'] is Map
          ? ReviewModel.fromMap(Map<String, dynamic>.from(map['review'] as Map))
          : null,
      scheduledTime: map['scheduledTime']?.toString() ?? 'Today (Immediate)',
      securityOtp: map['securityOtp']?.toString() ?? '4821',
      cancellationReason: map['cancellationReason']?.toString(),
      problemPhoto: map['problemPhoto']?.toString(),
    );
  }

  BookingRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? categoryId,
    String? categoryTitle,
    String? problemDescription,
    String? urgency,
    String? address,
    String? landmark,
    String? selectedWorkerId,
    String? selectedWorkerName,
    String? selectedWorkerPhone,
    double? estimatedCost,
    double? discountAmount,
    String? paymentMethod,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    ReviewModel? review,
    String? scheduledTime,
    String? securityOtp,
    String? cancellationReason,
    String? problemPhoto,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      problemDescription: problemDescription ?? this.problemDescription,
      urgency: urgency ?? this.urgency,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      selectedWorkerId: selectedWorkerId ?? this.selectedWorkerId,
      selectedWorkerName: selectedWorkerName ?? this.selectedWorkerName,
      selectedWorkerPhone: selectedWorkerPhone ?? this.selectedWorkerPhone,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      review: review ?? this.review,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      securityOtp: securityOtp ?? this.securityOtp,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      problemPhoto: problemPhoto ?? this.problemPhoto,
    );
  }
}
