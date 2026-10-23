
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/service_category.dart';
import '../models/worker_model.dart';
import '../services/firestore_service.dart';

class ServiceProviderState extends ChangeNotifier {
  // Service Categories List
  final List<ServiceCategory> _categories = [
    ServiceCategory(
      id: 'cat_plumbing',
      title: 'Plumbing',
      description: 'Leak repairs, pipe installation, drain unblocking',
      icon: Icons.plumbing,
      color: Colors.blue,
      basePrice: 249.0,
    ),
    ServiceCategory(
      id: 'cat_electrical',
      title: 'Electrician',
      description: 'Wiring, outlet repairs, circuit breaker fixing',
      icon: Icons.electrical_services,
      color: Colors.amber,
      basePrice: 299.0,
    ),
    ServiceCategory(
      id: 'cat_cleaning',
      title: 'House Cleaning',
      description: 'Deep house cleaning, kitchen & washroom sanitization',
      icon: Icons.cleaning_services,
      color: Colors.green,
      basePrice: 199.0,
    ),
    ServiceCategory(
      id: 'cat_ac',
      title: 'AC Repair',
      description: 'Air conditioner servicing, gas refill, cooling fix',
      icon: Icons.ac_unit,
      color: Colors.cyan,
      basePrice: 399.0,
    ),
    ServiceCategory(
      id: 'cat_carpentry',
      title: 'Carpentry',
      description: 'Furniture repair, custom woodwork, door fixes',
      icon: Icons.carpenter,
      color: Colors.brown,
      basePrice: 249.0,
    ),
    ServiceCategory(
      id: 'cat_painting',
      title: 'Painting',
      description: 'Interior & exterior wall painting, waterproof coating',
      icon: Icons.format_paint,
      color: Colors.purple,
      basePrice: 499.0,
    ),
    ServiceCategory(
      id: 'cat_appliance',
      title: 'Appliance Repair',
      description: 'Washing machine, refrigerator, microwave service',
      icon: Icons.kitchen,
      color: Colors.orange,
      basePrice: 349.0,
    ),
    ServiceCategory(
      id: 'cat_locksmith',
      title: 'Locksmith',
      description: 'Lock opening, key replacement, door lock install',
      icon: Icons.vpn_key,
      color: Colors.redAccent,
      basePrice: 199.0,
    ),
  ];

  // Service Workers List
  final List<WorkerModel> _workers = [
    WorkerModel(
      id: 'wrk_001',
      userId: 'wrk_001',
      name: 'Ramesh Kumar',
      phone: '+91 98991 22334',
      avatarUrl: '',
      categoryId: 'cat_plumbing',
      categoryName: 'Plumbing',
      rating: 4.8,
      totalReviews: 42,
      hourlyRate: 249.0,
      distanceKm: 1.2,
      experience: '7 years exp.',
      isAvailable: true,
      isVerified: true,
      bio: 'Master plumber specializing in residential leak detection and pipe fittings.',
    ),
    WorkerModel(
      id: 'wrk_002',
      userId: 'wrk_002',
      name: 'Amit Sharma',
      phone: '+91 98123 45678',
      avatarUrl: '',
      categoryId: 'cat_electrical',
      categoryName: 'Electrician',
      rating: 4.9,
      totalReviews: 68,
      hourlyRate: 299.0,
      distanceKm: 2.1,
      experience: '9 years exp.',
      isAvailable: true,
      isVerified: true,
      bio: 'Licensed electrician for high-voltage and home automation setups.',
    ),
    WorkerModel(
      id: 'wrk_003',
      userId: 'wrk_003',
      name: 'Sunil Yadav',
      phone: '+91 98234 56789',
      avatarUrl: '',
      categoryId: 'cat_cleaning',
      categoryName: 'House Cleaning',
      rating: 4.7,
      totalReviews: 31,
      hourlyRate: 199.0,
      distanceKm: 0.8,
      experience: '4 years exp.',
      isAvailable: true,
      isVerified: true,
      bio: 'Eco-friendly cleaning expert providing spotless home maintenance.',
    ),
    WorkerModel(
      id: 'wrk_004',
      userId: 'wrk_004',
      name: 'Rajesh Verma',
      phone: '+91 98345 67890',
      avatarUrl: '',
      categoryId: 'cat_ac',
      categoryName: 'AC Repair',
      rating: 4.6,
      totalReviews: 24,
      hourlyRate: 399.0,
      distanceKm: 3.4,
      experience: '6 years exp.',
      isAvailable: true,
      isVerified: true,
      bio: 'HVAC technician certified in all major AC split and inverter systems.',
    ),
    WorkerModel(
      id: 'wrk_005',
      userId: 'wrk_005',
      name: 'Manoj Tiwari',
      phone: '+91 98456 78901',
      avatarUrl: '',
      categoryId: 'cat_plumbing',
      categoryName: 'Plumbing',
      rating: 4.5,
      totalReviews: 19,
      hourlyRate: 249.0,
      distanceKm: 2.8,
      experience: '5 years exp.',
      isAvailable: true,
      isVerified: false, // Pending verification for admin demo
      bio: 'Fast response plumber available for emergency drain unblocking.',
    ),
  ];

  List<ServiceCategory> get categories => List.unmodifiable(_categories.where((c) => c.isActive));
  List<ServiceCategory> get allCategoriesAdmin => List.unmodifiable(_categories);
  List<WorkerModel> get workers => List.unmodifiable(_workers);

  // Filter Workers by Category
  List<WorkerModel> getWorkersByCategory(String categoryId) {
    return _workers.where((w) => w.categoryId == categoryId && w.isAvailable && w.isVerified).toList();
  }

  // Admin: Add Category
  void addCategory(ServiceCategory category) {
    _categories.add(category);
    notifyListeners();
  }

  // Admin: Update Category
  void updateCategory(String id, {String? title, String? description, double? basePrice}) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        title: title ?? _categories[index].title,
        description: description ?? _categories[index].description,
        basePrice: basePrice ?? _categories[index].basePrice,
      );
      notifyListeners();
    }
  }

  // Admin: Delete Category
  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Admin: Toggle Category Active
  void toggleCategoryStatus(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        isActive: !_categories[index].isActive,
      );
      notifyListeners();
    }
  }

  // Admin: Verify Provider
  void toggleWorkerVerification(String workerId) {
    final index = _workers.indexWhere((w) => w.id == workerId);
    if (index != -1) {
      _workers[index] = _workers[index].copyWith(
        isVerified: !_workers[index].isVerified,
      );
      notifyListeners();
    }
  }

  // Worker: Toggle Availability
  void toggleWorkerAvailability(String workerId) {
    final index = _workers.indexWhere((w) => w.id == workerId);
    if (index != -1) {
      _workers[index] = _workers[index].copyWith(
        isAvailable: !_workers[index].isAvailable,
      );
      notifyListeners();
    }
  }

  // Worker: Update Hourly Rate & Bio
  void updateWorkerProfile(String workerId, double hourlyRate, String bio) {
    final index = _workers.indexWhere((w) => w.id == workerId);
    if (index != -1) {
      _workers[index] = _workers[index].copyWith(
        hourlyRate: hourlyRate,
        bio: bio,
      );
      notifyListeners();
    }
  }

  // Register New Worker from Sign-up
  void registerNewWorker(WorkerModel newWorker) {
    _workers.insert(0, newWorker);
    FirestoreService.saveWorker(newWorker);
    notifyListeners();
  }

  // Update Worker Avatar
  void updateWorkerAvatar(String workerId, String newAvatarUrl) {
    final index = _workers.indexWhere((w) => w.id == workerId || w.userId == workerId);
    if (index != -1) {
      _workers[index] = _workers[index].copyWith(avatarUrl: newAvatarUrl);
      FirestoreService.saveWorker(_workers[index]);
      notifyListeners();
    }
  }

  // Find Worker by User ID
  WorkerModel? getWorkerByUserId(String userId) {
    try {
      return _workers.firstWhere((w) => w.userId == userId || w.id == userId);
    } catch (_) {
      return null;
    }
  }

  // Get or dynamically create Worker profile for logged-in user
  WorkerModel getWorkerForUser(UserModel user) {
    final existingIdx = _workers.indexWhere(
      (w) => w.userId == user.id || w.id == user.id,
    );
    if (existingIdx != -1) {
      final current = _workers[existingIdx];
      if (user.name.isNotEmpty && user.name != 'ApnaExpert User' && current.name != user.name) {
        _workers[existingIdx] = current.copyWith(
          name: user.name,
          phone: user.phone.isNotEmpty ? user.phone : current.phone,
          avatarUrl: user.avatarUrl.isNotEmpty ? user.avatarUrl : current.avatarUrl,
        );
      }
      return _workers[existingIdx];
    }

    // Synthesize worker from logged-in user's details
    final cat = _categories.firstWhere(
      (c) => c.id == user.serviceCategory,
      orElse: () => _categories.first,
    );

    final newWorker = WorkerModel(
      id: user.id.isNotEmpty ? user.id : 'wrk_${DateTime.now().millisecondsSinceEpoch % 100000}',
      userId: user.id,
      name: user.name.isNotEmpty && user.name != 'ApnaExpert User' ? user.name : 'Service Partner',
      phone: user.phone.isNotEmpty ? user.phone : '',
      avatarUrl: user.avatarUrl,
      categoryId: cat.id,
      categoryName: cat.title,
      rating: 5.0,
      totalReviews: 0,
      hourlyRate: user.hourlyRate ?? cat.basePrice,
      distanceKm: 1.0,
      experience: 'Verified Professional',
      isAvailable: true,
      isVerified: true,
      bio: 'Professional ${cat.title} specialist providing trusted doorstep services.',
    );

    _workers.insert(0, newWorker);
    FirestoreService.saveWorker(newWorker);
    return newWorker;
  }
}
