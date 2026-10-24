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
