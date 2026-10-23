


import 'package:flutter/material.dart';
import '../models/booking_request.dart';
import '../services/firestore_service.dart';

class BookingProvider extends ChangeNotifier {
  // Active draft state during wizard creation
  String? _draftCategoryId;
  String? _draftCategoryTitle;
  String _draftDescription = '';
  String _draftUrgency = 'Normal';
  String _draftAddress = '';
  String _draftLandmark = '';
  String? _draftWorkerId;
  String? _draftWorkerName;
  String? _draftWorkerPhone;
  double _draftEstimatedCost = 249.0;
  String _draftPaymentMethod = 'Cash on Service';
  String _draftScheduledTime = 'Today (Immediate)';
  String _draftPromoCode = '';
  double _draftDiscount = 0.0;

  // Getters for draft flow
  String? get draftCategoryId => _draftCategoryId;
  String? get draftCategoryTitle => _draftCategoryTitle;
  String get draftDescription => _draftDescription;
  String get draftUrgency => _draftUrgency;
  String get draftAddress => _draftAddress;
  String get draftLandmark => _draftLandmark;
  String? get draftWorkerId => _draftWorkerId;
  String? get draftWorkerName => _draftWorkerName;
  double get draftEstimatedCost => _draftEstimatedCost;
  String get draftPaymentMethod => _draftPaymentMethod;
  String get draftScheduledTime => _draftScheduledTime;
  String get draftPromoCode => _draftPromoCode;
  double get draftDiscount => _draftDiscount;
  double get draftFinalCost => (_draftEstimatedCost - _draftDiscount).clamp(0.0, double.infinity);

  // Setters for draft steps
  void setDraftCategory(String id, String title, double basePrice) {
    _draftCategoryId = id;
    _draftCategoryTitle = title;
    _draftEstimatedCost = basePrice;
    _draftDiscount = 0.0;
    _draftPromoCode = '';
    notifyListeners();
  }

  void setDraftProblem(String description, String urgency) {
    _draftDescription = description;
    _draftUrgency = urgency;
    notifyListeners();
  }

  void setDraftScheduledTime(String time) {
    _draftScheduledTime = time;
    notifyListeners();
  }

  void setDraftLocation(String address, String landmark) {
    _draftAddress = address;
    _draftLandmark = landmark;
    notifyListeners();
  }

  void setDraftWorker(String workerId, String workerName, String workerPhone, double hourlyRate) {
    _draftWorkerId = workerId;
    _draftWorkerName = workerName;
    _draftWorkerPhone = workerPhone;
    _draftEstimatedCost = hourlyRate;
    if (_draftPromoCode.isNotEmpty) {
      applyPromoCode(_draftPromoCode);
    }
    notifyListeners();
  }

  void setDraftPaymentMethod(String paymentMethod) {
    _draftPaymentMethod = paymentMethod;
    notifyListeners();
  }

  String? applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'APNAEXPERT50') {
      _draftPromoCode = 'APNAEXPERT50';
      _draftDiscount = 50.0;
      notifyListeners();
      return 'Coupon APNAEXPERT50 applied! ₹50 OFF';
    } else if (clean == 'SAVE20') {
      _draftPromoCode = clean;
      _draftDiscount = (_draftEstimatedCost * 0.20).roundToDouble();
      notifyListeners();
      return 'Coupon SAVE20 applied! 20% OFF';
    } else if (clean == 'WELCOME10') {
      _draftPromoCode = clean;
      _draftDiscount = (_draftEstimatedCost * 0.10).roundToDouble();
      notifyListeners();
      return 'Coupon WELCOME10 applied! 10% OFF';
    } else {
      return 'Invalid coupon code. Try APNAEXPERT50 or SAVE20';
    }
  }

  void removePromoCode() {
    _draftPromoCode = '';
    _draftDiscount = 0.0;
    notifyListeners();
  }

  void resetDraft() {
    _draftCategoryId = null;
    _draftCategoryTitle = null;
    _draftDescription = '';
    _draftUrgency = 'Normal';
    _draftAddress = '';
    _draftLandmark = '';
    _draftWorkerId = null;
    _draftWorkerName = null;
    _draftWorkerPhone = null;
    _draftEstimatedCost = 249.0;
    _draftPaymentMethod = 'Cash on Service';
    _draftScheduledTime = 'Today (Immediate)';
    _draftPromoCode = '';
    _draftDiscount = 0.0;
    notifyListeners();
  }

  // Pre-loaded initial bookings for realistic simulation
  final List<BookingRequest> _bookings = [
    BookingRequest(
      id: 'BK-1001',
      customerId: 'cust_001',
      customerName: 'Rahul Sharma',
      customerPhone: '+91 98765 43210',
      categoryId: 'cat_plumbing',
      categoryTitle: 'Plumbing',
      problemDescription: 'Leaking pipe under kitchen sink with water leaking onto floor.',
      urgency: 'Urgent',
      address: 'Flat 402, Shanti Heights, Sector 18, Noida',
      landmark: 'Near Wave Mall',
      selectedWorkerId: 'wrk_001',
      selectedWorkerName: 'Ramesh Kumar',
      selectedWorkerPhone: '+91 98991 22334',
      estimatedCost: 249.0,
      discountAmount: 0.0,
      paymentMethod: 'Cash on Service',
      status: BookingStatus.accepted,
      scheduledTime: 'Today (Immediate)',
      securityOtp: '4821',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BookingRequest(
      id: 'BK-1002',
      customerId: 'cust_001',
      customerName: 'Rahul Sharma',
      customerPhone: '+91 98765 43210',
      categoryId: 'cat_electrical',
      categoryTitle: 'Electrician',
      problemDescription: 'Master bedroom main switch spark and trip circuit breaker.',
      urgency: 'Emergency',
      address: 'Flat 402, Shanti Heights, Sector 18, Noida',
      landmark: 'Near Wave Mall',
      selectedWorkerId: 'wrk_002',
      selectedWorkerName: 'Amit Sharma',
      selectedWorkerPhone: '+91 98123 45678',
      estimatedCost: 299.0,
      discountAmount: 50.0,
      paymentMethod: 'UPI',
      status: BookingStatus.serviceDone,
      scheduledTime: 'Yesterday, 11:00 AM',
      securityOtp: '7190',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BookingRequest(
      id: 'BK-1003',
      customerId: 'cust_002',
      customerName: 'Priya Patel',
      customerPhone: '+91 98112 34567',
      categoryId: 'cat_cleaning',
      categoryTitle: 'House Cleaning',
      problemDescription: 'Full house deep cleaning before moving in.',
      urgency: 'Normal',
      address: 'B-12, Green Park Main, New Delhi',
      landmark: 'Opposite Metro Station Gate 2',
      selectedWorkerId: 'wrk_003',
      selectedWorkerName: 'Sunil Yadav',
      selectedWorkerPhone: '+91 98234 56789',
      estimatedCost: 399.0,
      discountAmount: 50.0,
      paymentMethod: 'UPI',
      status: BookingStatus.requested,
      scheduledTime: 'Today, 4:00 PM',
      securityOtp: '3352',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  // In-app chat messages per booking
  final Map<String, List<ChatMessage>> _chatMessages = {
    'BK-1001': [
      ChatMessage(
        id: 'msg_1',
        senderId: 'wrk_001',
        senderName: 'Ramesh Kumar',
        text: 'Namaste Rahul ji! I have accepted your plumbing request. I am on my way with the pipe replacement kit.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isCustomer: false,
      ),
      ChatMessage(
        id: 'msg_2',
        senderId: 'cust_001',
        senderName: 'Rahul Sharma',
        text: 'Thanks Ramesh ji! Please take the service elevator to the 4th floor.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        isCustomer: true,
      ),
      ChatMessage(
        id: 'msg_3',
        senderId: 'wrk_001',
        senderName: 'Ramesh Kumar',
        text: 'Ji bilkul! I will arrive in approximately 10 minutes.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isCustomer: false,
      ),
    ],
  };

  List<ChatMessage> getMessages(String bookingId) {
    return _chatMessages[bookingId] ?? [];
  }

  void sendMessage(String bookingId, String senderId, String senderName, String text, bool isCustomer) {
    if (text.trim().isEmpty) return;
    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      text: text.trim(),
      timestamp: DateTime.now(),
      isCustomer: isCustomer,
    );
    if (_chatMessages.containsKey(bookingId)) {
      _chatMessages[bookingId]!.add(msg);
    } else {
      _chatMessages[bookingId] = [msg];
    }
    notifyListeners();
  }

  List<BookingRequest> get allBookings => List.unmodifiable(_bookings);

  List<BookingRequest> getCustomerBookings(String customerId) {
    return _bookings.where((b) => b.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<BookingRequest> getWorkerBookings(String workerId) {
    return _bookings.where((b) => b.selectedWorkerId == workerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<BookingRequest> getWorkerPendingRequests(String workerId) {
    return _bookings.where((b) => b.selectedWorkerId == workerId && b.status == BookingStatus.requested).toList();
  }

  // Create new request (Step 5)
  BookingRequest createBookingRequest({
    required String customerId,
    required String customerName,
    required String customerPhone,
  }) {
    final randomOtp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();

    final newBooking = BookingRequest(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      categoryId: _draftCategoryId ?? 'cat_plumbing',
      categoryTitle: _draftCategoryTitle ?? 'Plumbing',
      problemDescription: _draftDescription,
      urgency: _draftUrgency,
      address: _draftAddress,
      landmark: _draftLandmark,
      selectedWorkerId: _draftWorkerId,
      selectedWorkerName: _draftWorkerName,
      selectedWorkerPhone: _draftWorkerPhone,
      estimatedCost: _draftEstimatedCost,
      discountAmount: _draftDiscount,
      paymentMethod: _draftPaymentMethod,
      scheduledTime: _draftScheduledTime,
      securityOtp: randomOtp,
      status: BookingStatus.requested,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, newBooking);
    FirestoreService.createBooking(newBooking);
    resetDraft();
    notifyListeners();
    return newBooking;
  }

  // Worker Accepts Request (Step 6)
  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      DateTime? completedTime = _bookings[index].completedAt;
      if (newStatus == BookingStatus.serviceDone || newStatus == BookingStatus.reviewed) {
        completedTime ??= DateTime.now();
      }

      _bookings[index] = _bookings[index].copyWith(
        status: newStatus,
        completedAt: completedTime,
      );
      FirestoreService.updateBookingStatus(bookingId, newStatus);
      notifyListeners();
    }
  }

  // Cancel booking with reason
  void cancelBooking(String bookingId, String reason) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason,
      );
      FirestoreService.updateBookingStatus(bookingId, BookingStatus.cancelled);
      notifyListeners();
    }
  }

  // Submit Review for completed service (Step 8)
  void submitReview(String bookingId, double rating, String comment) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _bookings[index];
      final review = ReviewModel(
        id: 'REV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        bookingId: bookingId,
        customerId: booking.customerId,
        customerName: booking.customerName,
        workerId: booking.selectedWorkerId ?? 'wrk_001',
        workerName: booking.selectedWorkerName ?? 'Worker',
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      _bookings[index] = booking.copyWith(
        status: BookingStatus.reviewed,
        review: review,
      );
      notifyListeners();
    }
  }

  // Moderation / Admin Delete or Flag Review
  void toggleFlagReview(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1 && _bookings[index].review != null) {
      final currentRev = _bookings[index].review!;
      _bookings[index] = _bookings[index].copyWith(
        review: currentRev.copyWith(isFlagged: !currentRev.isFlagged),
      );
      notifyListeners();
    }
  }

  // Delete review (Admin)
  void deleteReview(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        review: null,
      );
      notifyListeners();
    }
  }
}
