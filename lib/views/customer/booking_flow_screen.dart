import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_request.dart';
import '../../models/worker_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/booking_status_stepper.dart';
import '../../widgets/worker_card.dart';
import '../../widgets/app_avatar.dart';
import 'booking_tracker_screen.dart';

class BookingFlowScreen extends StatefulWidget {
  final int initialStep; // Defaults to 2 (Describe Problem)

  const BookingFlowScreen({super.key, this.initialStep = 2});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late int _currentStep;

  // Form Controllers for Step 2
  final TextEditingController _problemController = TextEditingController();
  String _urgency = 'Normal';
  String _scheduledSlot = 'Today (Immediate)';
  bool _hasPhotoAttached = false;

  // Form Controllers for Step 3
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  // Step 4 Selection & Filtering
  String? _selectedWorkerId;
  String _workerSortBy = 'All';

  // Step 5 Selection & Promo Code
  String _paymentMethod = 'Cash on Service';
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    final bp = Provider.of<BookingProvider>(context, listen: false);
    final lp = Provider.of<LocationProvider>(context, listen: false);
    if (bp.draftAddress.isNotEmpty) {
      _addressController.text = bp.draftAddress;
      _landmarkController.text = bp.draftLandmark;
    } else if (lp.currentAddress.isNotEmpty &&
        lp.currentAddress != 'Detecting live location...') {
      _addressController.text = lp.currentAddress;
      _landmarkController.text =
          lp.isLiveLocation ? 'GPS Auto-Detected' : lp.shortLocation;
    } else {
      _addressController.text = '';
      _landmarkController.text = '';
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _showWorkerDetailSheet(WorkerModel worker) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(
                    avatarUrl: worker.avatarUrl,
                    name: worker.name,
                    radius: 30,
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
                              worker.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (worker.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${worker.categoryName} • ${worker.experience}',
                          style: const TextStyle(
                            color: AppTheme.subtitleColor,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${worker.rating} (${worker.totalReviews} reviews)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'About the Specialist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                worker.bio,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Fare',
                        style: TextStyle(
                          color: AppTheme.subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₹${worker.hourlyRate.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedWorkerId = worker.id;
                      });
                      final bp = Provider.of<BookingProvider>(
                        context,
                        listen: false,
                      );
                      bp.setDraftWorker(
                        worker.id,
                        worker.name,
                        worker.phone,
                        worker.hourlyRate,
                      );
                    },
                    child: const Text('Select This Worker'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final serviceState = Provider.of<ServiceProviderState>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    // Map step index to BookingStatus for the stepper
    BookingStatus stepperStatus = BookingStatus.selectService;
    if (_currentStep == 2) stepperStatus = BookingStatus.describeProblem;
    if (_currentStep == 3) stepperStatus = BookingStatus.location;
    if (_currentStep == 4) stepperStatus = BookingStatus.nearbyWorkers;
    if (_currentStep == 5) stepperStatus = BookingStatus.requested;

    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${bookingProvider.draftCategoryTitle ?? "Service"}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BookingStatusStepper(currentStatus: stepperStatus),
            const SizedBox(height: 16),
            if (_currentStep == 2)
              _buildStep2DescribeProblem(bookingProvider, primary),
            if (_currentStep == 3)
              _buildStep3Location(bookingProvider, authProvider, primary),
            if (_currentStep == 4)
              _buildStep4NearbyWorkers(bookingProvider, serviceState, primary),
            if (_currentStep == 5)
              _buildStep5ConfirmRequest(bookingProvider, authProvider, primary),
          ],
        ),
      ),
    );
  }

  // STEP 2: DESCRIBE PROBLEM & SCHEDULE
  Widget _buildStep2DescribeProblem(
    BookingProvider bookingProvider,
    Color primary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Step 2: Describe Your Problem',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Give us details so your specialist arrives with the exact equipment needed.',
              style: TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _problemController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'e.g., Kitchen pipe burst under the sink, water leaking rapidly onto cabinets...',
                labelText: 'Problem Description & Symptoms *',
              ),
            ),
            const SizedBox(height: 16),

            // Urgency Level Chips
            const Text(
              'Urgency Level',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children:
                  [
                    {'label': 'Normal', 'color': const Color(0xFF3B82F6)},
                    {'label': 'Urgent', 'color': const Color(0xFFF97316)},
                    {'label': 'Emergency', 'color': const Color(0xFFEF4444)},
                  ].map((item) {
                    final lvl = item['label'] as String;
                    final chipColor = item['color'] as Color;
                    final isSelected = _urgency == lvl;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Center(child: Text(lvl)),
                          selected: isSelected,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF1F5F9),
                          selectedColor: chipColor.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? chipColor
                                : (isDark
                                      ? const Color(0xFF2E2E2E)
                                      : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? chipColor
                                : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B)),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 13,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _urgency = lvl);
                          },
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            // Service Schedule Slot
            const Text(
              'Preferred Service Slot',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    'Today (Immediate)',
                    'Today Evening (5 - 8 PM)',
                    'Tomorrow Morning (9 - 12 AM)',
                    'Tomorrow Afternoon (1 - 4 PM)',
                  ].map((slot) {
                    final isSelected = _scheduledSlot == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      showCheckmark: false,
                      backgroundColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF1F5F9),
                      selectedColor: primary.withValues(
                        alpha: isDark ? 0.25 : 0.15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? primary
                            : (isDark
                                  ? const Color(0xFF2E2E2E)
                                  : const Color(0xFFE2E8F0)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? primary
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _scheduledSlot = slot);
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            // Photo attachment simulation
            InkWell(
              onTap: () {
                setState(() {
                  _hasPhotoAttached = !_hasPhotoAttached;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _hasPhotoAttached
                          ? 'Photo attached: issue_photo.jpg (1.4 MB)'
                          : 'Photo removed',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _hasPhotoAttached
                      ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasPhotoAttached
                        ? AppTheme.secondaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasPhotoAttached
                          ? Icons.check_circle
                          : Icons.add_a_photo_outlined,
                      color: _hasPhotoAttached
                          ? AppTheme.secondaryColor
                          : primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _hasPhotoAttached
                            ? '1 Photo Attached (issue_photo.jpg)'
                            : 'Attach Photo of Problem (Optional)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _hasPhotoAttached
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _hasPhotoAttached
                              ? AppTheme.secondaryColor
                              : null,
                        ),
                      ),
                    ),
                    if (_hasPhotoAttached)
                      const Icon(Icons.close, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_problemController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please describe the problem.'),
                      ),
                    );
                    return;
                  }
                  bookingProvider.setDraftProblem(
                    _problemController.text,
                    _urgency,
                  );
                  bookingProvider.setDraftScheduledTime(_scheduledSlot);
                  setState(() => _currentStep = 3);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue to Location'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: LOCATION
  Widget _buildStep3Location(
    BookingProvider bookingProvider,
    AuthProvider authProvider,
    Color primary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Step 3: Service Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter the address where the service worker will arrive.',
              style: TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
            ),
            const SizedBox(height: 16),

            if (authProvider.savedAddresses.isNotEmpty) ...[
              // Quick select from saved addresses
              const Text(
                'Saved Addresses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: authProvider.savedAddresses.map((addr) {
                  final isSelected = _addressController.text == addr;
                  return ChoiceChip(
                    avatar: Icon(
                      isSelected
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      size: 16,
                      color: isSelected
                          ? primary
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                    ),
                    label: Text(addr.split('(').first.trim()),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF1F5F9),
                    selectedColor: primary.withValues(
                      alpha: isDark ? 0.25 : 0.15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? primary
                          : (isDark
                                ? const Color(0xFF2E2E2E)
                                : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? primary
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _addressController.text = addr;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // GPS Pin Location Simulation Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location, color: primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GPS Coordinates Locked',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Consumer<LocationProvider>(
                          builder: (context, lp, _) {
                            final latStr = lp.latitude != null
                                ? '${lp.latitude!.toStringAsFixed(4)}° N'
                                : '28.5355° N';
                          
                            final lonStr = lp.longitude != null
                                ? '${lp.longitude!.toStringAsFixed(4)}° E'
                                : '77.3910° E';
                            return Text(
                              '$latStr, $lonStr • Precision ~10m',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.subtitleColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final lp = Provider.of<LocationProvider>(
                        context,
                        listen: false,
                      );
                      await lp.fetchLiveLocation();
                      setState(() {
                        _addressController.text = lp.currentAddress;
                        _landmarkController.text = lp.shortLocation;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              lp.isLiveLocation
                                  ? 'GPS Auto-detected address filled!'
                                  : (lp.errorMessage ?? 'GPS address updated'),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address / House No. *',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _landmarkController,
              decoration: const InputDecoration(
                labelText: 'Landmark / Area / Flat No. (Optional)',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 2),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_addressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter an address'),
                          ),
                        );
                        return;
                      }
                      bookingProvider.setDraftLocation(
                        _addressController.text,
                        _landmarkController.text,
                      );
                      setState(() => _currentStep = 4);
                    },
                    child: const Text('Find Workers'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: NEARBY WORKERS
  Widget _buildStep4NearbyWorkers(
    BookingProvider bookingProvider,
    ServiceProviderState serviceState,
    Color primary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catId = bookingProvider.draftCategoryId ?? 'cat_plumbing';
    var availableWorkers = serviceState.getWorkersByCategory(catId);

    // Apply sorting
    if (_workerSortBy == 'Top Rated') {
      availableWorkers.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_workerSortBy == 'Nearest') {
      availableWorkers.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_workerSortBy == 'Best Price') {
      availableWorkers.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Step 4: Choose Nearby Worker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${availableWorkers.length} available service workers nearby',
                  style: const TextStyle(
                    color: AppTheme.subtitleColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sort Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Top Rated', 'Nearest', 'Best Price'].map((sort) {
              final isSelected = _workerSortBy == sort;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(sort),
                  selected: isSelected,
                  showCheckmark: false,
                  backgroundColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF1F5F9),
                  selectedColor: primary.withValues(
                    alpha: isDark ? 0.25 : 0.15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? primary
                        : (isDark
                              ? const Color(0xFF2E2E2E)
                              : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? primary
                        : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _workerSortBy = sort);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        if (availableWorkers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_search,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No available workers in this category right now.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'We will assign an on-call technician automatically once submitted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Auto-assign default
                        bookingProvider.setDraftWorker(
                          'wrk_auto',
                          'Auto-Assigned Expert',
                          '+91 1800 200 4567',
                          bookingProvider.draftEstimatedCost,
                        );
                        setState(() => _currentStep = 5);
                      },
                      child: const Text('Auto-Assign & Proceed'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableWorkers.length,
            itemBuilder: (context, index) {
              final worker = availableWorkers[index];
              final isSelected = _selectedWorkerId == worker.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WorkerCard(
                  worker: worker,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedWorkerId = worker.id;
                    });
                    bookingProvider.setDraftWorker(
                      worker.id,
                      worker.name,
                      worker.phone,
                      worker.hourlyRate,
                    );
                  },
                  onInfoTap: () => _showWorkerDetailSheet(worker),
                ),
              );
            },
          ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 3),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedWorkerId == null
                    ? null
                    : () {
                        setState(() => _currentStep = 5);
                      },
                child: const Text('Next: Confirm'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 5: REVIEW & SEND REQUEST
  Widget _buildStep5ConfirmRequest(
    BookingProvider bookingProvider,
    AuthProvider authProvider,
    Color primary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paymentMethods = [
      {
        'name': 'Cash on Service',
        'desc': 'Pay directly after job is completed',
        'icon': Icons.payments_outlined,
      },
      {
        'name': 'UPI Direct',
        'desc': 'Google Pay, PhonePe, Paytm, BHIM',
        'icon': Icons.qr_code_2_rounded,
      },
      {
        'name': 'Card / Netbanking',
        'desc': 'Visa, Mastercard, RuPay',
        'icon': Icons.credit_card_rounded,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in_rounded,
                  color: primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Step 5: Review & Send Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // Summary list
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Service Category'),
              subtitle: Text(
                bookingProvider.draftCategoryTitle ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(Icons.build_rounded, color: primary),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Scheduled Time Slot'),
              subtitle: Text(
                bookingProvider.draftScheduledTime,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              leading: const Icon(
                Icons.access_time_filled,
                color: AppTheme.secondaryColor,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Problem Description'),
              subtitle: Text(bookingProvider.draftDescription),
              leading: Icon(Icons.article_rounded, color: primary),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Service Address'),
              subtitle: Text(
                '${bookingProvider.draftAddress} (${bookingProvider.draftLandmark})',
              ),
              leading: Icon(Icons.location_on_rounded, color: primary),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Assigned Technician'),
              subtitle: Text(
                bookingProvider.draftWorkerName ?? 'Auto Assign',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(Icons.engineering_rounded, color: primary),
            ),

            const Divider(),
            const SizedBox(height: 8),

            // Coupon / Promo Code Input
            const Text(
              'Have a Promo Code?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter code (e.g. APNAEXPERT50)',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      prefixIcon: const Icon(
                        Icons.local_offer_outlined,
                        size: 18,
                      ),
                      suffixIcon: bookingProvider.draftPromoCode.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _promoController.clear();
                                bookingProvider.removePromoCode();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    final msg = bookingProvider.applyPromoCode(
                      _promoController.text,
                    );
                    if (msg != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: bookingProvider.draftDiscount > 0
                              ? AppTheme.secondaryColor
                              : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bill Breakdown Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Base Service Fare'),
                      Text(
                        '₹${bookingProvider.draftEstimatedCost.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Convenience Fee'),
                      Text(
                        'FREE',
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (bookingProvider.draftDiscount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Promo Discount (${bookingProvider.draftPromoCode})',
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        Text(
                          '-₹${bookingProvider.draftDiscount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '₹${bookingProvider.draftFinalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Method Selection (Custom Modern Selector, no deprecations)
            const Text(
              'Select Payment Mode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Column(
              children: paymentMethods.map((method) {
                final isSelected = _paymentMethod == method['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withValues(alpha: 0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : (isDark
                                ? const Color(0xFF262626)
                                : const Color(0xFFE2E8F0)),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      method['icon'] as IconData,
                      color: isSelected ? primary : Colors.grey,
                    ),
                    title: Text(
                      method['name'] as String,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      method['desc'] as String,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: primary)
                        : const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey,
                          ),
                    onTap: () {
                      setState(() {
                        _paymentMethod = method['name'] as String;
                      });
                      bookingProvider.setDraftPaymentMethod(_paymentMethod);
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Security PIN Guarantee notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: Colors.amber, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Safe & Verified: A 4-digit security PIN will be shown upon confirmation. Share it only when technician arrives.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 4),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                    onPressed: () {
                      final user = authProvider.currentUser;
                      final newBooking = bookingProvider.createBookingRequest(
                        customerId: user.id,
                        customerName: user.name,
                        customerPhone: user.phone,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking Request Sent to Worker!'),
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingTrackerScreen(bookingId: newBooking.id),
                        ),
                      );
                    },
                    child: const Text('Submit Request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
