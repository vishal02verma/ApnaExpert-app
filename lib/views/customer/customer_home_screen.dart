import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/booking_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_avatar.dart';
import 'booking_flow_screen.dart';
import 'customer_history_screen.dart';
import 'customer_profile_screen.dart';
import 'find_expert_workers_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentBottomNavIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lp = Provider.of<LocationProvider>(context, listen: false);
      final bp = Provider.of<BookingProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final userAddress = (auth.currentUser.address != null && auth.currentUser.address!.trim().isNotEmpty)
          ? auth.currentUser.address!.trim()
          : (auth.savedAddresses.isNotEmpty ? auth.savedAddresses.first : null);

      if (userAddress != null && userAddress.isNotEmpty && !lp.isLiveLocation) {
        lp.setManualLocation(userAddress);
        bp.setDraftLocation(userAddress, 'Saved Address');
      } else if (lp.isLiveLocation && lp.currentAddress.isNotEmpty && !lp.isLoading) {
        bp.setDraftLocation(lp.currentAddress, lp.shortLocation);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Cleaning Services with curated Unsplash imagery
  final List<Map<String, String>> _cleaningServices = [
    {
      'title': 'Home Cleaning',
      'imageUrl':
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500&auto=format&fit=crop&q=80',
      'category': 'Cleaner',
      'categoryId': 'cat_cleaning',
    },
    {
      'title': 'Bathroom Cleaning',
      'imageUrl':
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=80',
      'category': 'Cleaner',
      'categoryId': 'cat_cleaning',
    },
    {
      'title': 'Disinfection',
      'imageUrl':
          'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=500&auto=format&fit=crop&q=80',
      'category': 'Cleaner',
      'categoryId': 'cat_cleaning',
    },
    {
      'title': 'Kitchen Deep Clean',
      'imageUrl':
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=500&auto=format&fit=crop&q=80',
      'category': 'Cleaner',
      'categoryId': 'cat_cleaning',
    },
  ];

  // Home Repairs with curated Unsplash imagery
  final List<Map<String, String>> _repairServices = [
    {
      'title': 'Plumber',
      'imageUrl':
          'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=500&auto=format&fit=crop&q=80',
      'category': 'Plumber',
      'categoryId': 'cat_plumbing',
    },
    {
      'title': 'Carpenter',
      'imageUrl':
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500&auto=format&fit=crop&q=80',
      'category': 'Carpenter',
      'categoryId': 'cat_carpentry',
    },
    {
      'title': 'Electrician',
      'imageUrl':
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500&auto=format&fit=crop&q=80',
      'category': 'Electrician',
      'categoryId': 'cat_electrical',
    },
    {
      'title': 'AC Servicing',
      'imageUrl':
          'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=500&auto=format&fit=crop&q=80',
      'category': 'AC Repair',
      'categoryId': 'cat_ac',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final myBookings = bookingProvider.getCustomerBookings(
      authProvider.currentUser.id,
    );
    final activeBookingsCount = myBookings
        .where(
          (b) =>
              b.status != BookingStatus.serviceDone &&
              b.status != BookingStatus.reviewed &&
              b.status != BookingStatus.cancelled,
        )
        .length;

    final List<Widget> pages = [
      _buildHomeDashboard(context),
      const CustomerHistoryScreen(),
      _buildSavedWorkersTab(context),
      const CustomerProfileScreen(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Colors.black
          : const Color(0xFFF8FAFC),
      body: pages[_currentBottomNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BottomNavigationBar(
            currentIndex: _currentBottomNavIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            selectedItemColor: const Color(0xFF0A66C2),
            unselectedItemColor: isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8),
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            onTap: (index) => setState(() => _currentBottomNavIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Color(0xFF0A66C2),
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: activeBookingsCount > 0,
                  label: Text('$activeBookingsCount'),
                  backgroundColor: AppTheme.accentOrange,
                  child: const Icon(Icons.receipt_long_outlined),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Badge(
                    isLabelVisible: activeBookingsCount > 0,
                    label: Text('$activeBookingsCount'),
                    backgroundColor: AppTheme.accentOrange,
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                ),
                label: 'Booking',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark_border_rounded),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: Color(0xFF0A66C2),
                  ),
                ),
                label: 'Save',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF0A66C2),
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final serviceState = Provider.of<ServiceProviderState>(context);
    final userName = authProvider.currentUser.name.split(' ').first;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authProvider.isInCustomerModeAsWorker) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF064E3B), const Color(0xFF0F766E)]
                        : [const Color(0xFFECFDF5), const Color(0xFFF0FDF4)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.engineering_rounded,
                        color: AppTheme.secondaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worker Portal (${authProvider.currentUser.name})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark ? Colors.white : const Color(0xFF065F46),
                            ),
                          ),
                          Text(
                            'You are in Customer Mode to hire another worker.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                      label: const Text(
                        'Worker Mode',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        authProvider.switchToWorkerMode();
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Top App Bar (Grid icon + Location + Greeting left, Theme + Notification Bell right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showLocationSelectorBottomSheet(
                        context,
                        locationProvider,
                        authProvider,
                        bookingProvider,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (locationProvider.isLoading)
                                  const SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0284C7),
                                    ),
                                  )
                                else
                                  Icon(
                                    locationProvider.isLiveLocation
                                        ? Icons.my_location_rounded
                                        : Icons.location_on_rounded,
                                    size: 14,
                                    color: locationProvider.isLiveLocation
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF0284C7),
                                  ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 160,
                                  ),
                                  child: Text(
                                    locationProvider.isLoading
                                        ? 'Locating GPS...'
                                        : locationProvider.shortLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                if (locationProvider.isLiveLocation &&
                                    !locationProvider.isLoading) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF10B981),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                            Text(
                              'Hi, $userName 👋',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: isDark
                          ? 'Switch to Light Mode'
                          : 'Switch to Dark Mode',
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDark ? Colors.amber : const Color(0xFF0F4C81),
                        size: 20,
                      ),
                      onPressed: () => authProvider.toggleTheme(),
                    ),
                    if (authProvider.isAdmin)
                      Tooltip(
                        message: 'Open Admin Control Panel',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminDashboardScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF6B21A8),
                                        const Color(0xFF4C1D95),
                                      ]
                                    : [
                                        const Color(0xFF9333EA),
                                        const Color(0xFF7E22CE),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9333EA)
                                      .withValues(alpha: isDark ? 0.45 : 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: Colors.amber,
                                  size: 19,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Admin',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No new notifications right now.'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF121212)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF0F4C81),
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Search Bar ("Search for Services" with blue search icon)
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: isDark
                    ? Border.all(color: const Color(0xFF262626), width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (val) => setState(() => _searchQuery = val),
                onSubmitted: (val) {
                  final q = val.trim().toLowerCase();
                  if (q.isEmpty) return;
                  final match = serviceState.categories.where(
                    (c) =>
                        c.title.toLowerCase().contains(q) ||
                        c.id.toLowerCase().contains(q),
                  ).firstOrNull;
                  if (match != null) {
                    _openFindExpert(match.title, match.id);
                  } else {
                    _openFindExpert(val.trim(), 'cat_all');
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for Services',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            if (_searchQuery.trim().isNotEmpty) ...[
              _buildSearchResultsSection(context, isDark, serviceState),
            ] else ...[
              // SECTION 1: Categories Header ("Categories" + "See all")
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FindExpertWorkersScreen(
                          categoryTitle: 'All Services',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'See all',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Categories Minimalist Icon Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCategoryIconCard(
                    title: 'Cleaner',
                    icon: Icons.cleaning_services_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () => _openFindExpert('Cleaner', 'cat_cleaning'),
                  ),
                  _buildCategoryIconCard(
                    title: 'Plumber',
                    icon: Icons.plumbing_rounded,
                    color: const Color(0xFF0EA5E9),
                    onTap: () => _openFindExpert('Plumber', 'cat_plumbing'),
                  ),
                  _buildCategoryIconCard(
                    title: 'Electrician',
                    icon: Icons.electrical_services_rounded,
                    color: Colors.amber.shade700,
                    onTap: () =>
                        _openFindExpert('Electrician', 'cat_electrical'),
                  ),
                  _buildCategoryIconCard(
                    title: 'Hair / Salon',
                    icon: Icons.content_cut_rounded,
                    color: Colors.pink.shade400,
                    onTap: () =>
                        _openFindExpert('Hair / Salon', 'cat_cleaning'),
                  ),
                  _buildCategoryIconCard(
                    title: 'AC Repair',
                    icon: Icons.ac_unit_rounded,
                    color: Colors.teal,
                    onTap: () => _openFindExpert('AC Repair', 'cat_ac'),
                  ),
                  _buildCategoryIconCard(
                    title: 'Carpenter',
                    icon: Icons.carpenter_rounded,
                    color: Colors.brown,
                    onTap: () => _openFindExpert('Carpenter', 'cat_carpentry'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // SECTION 2: Cleaning Services Header ("Cleaning Services" + "See all")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cleaning Services',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => _openFindExpert('Cleaner', 'cat_cleaning'),
                  child: Text(
                    'See all',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Cleaning Services Horizontal Photo Cards
            SizedBox(
              height: 145,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _cleaningServices.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final service = _cleaningServices[index];
                  return _buildServicePhotoCard(
                    title: service['title']!,
                    imageUrl: service['imageUrl']!,
                    onTap: () => _openFindExpert(
                      service['category']!,
                      service['categoryId']!,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            // SECTION 3: Home Repairs Header ("Home Repairs" + "See all")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Home Repairs',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => _openFindExpert('Plumber', 'cat_plumbing'),
                  child: Text(
                    'See all',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Home Repairs Horizontal Photo Cards
            SizedBox(
              height: 145,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _repairServices.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final service = _repairServices[index];
                  return _buildServicePhotoCard(
                    title: service['title']!,
                    imageUrl: service['imageUrl']!,
                    onTap: () => _openFindExpert(
                      service['category']!,
                      service['categoryId']!,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsSection(
    BuildContext context,
    bool isDark,
    ServiceProviderState serviceState,
  ) {
    final q = _searchQuery.trim().toLowerCase();

    // 1. Filter categories
    final matchingCategories = serviceState.categories.where((cat) {
      return cat.title.toLowerCase().contains(q) ||
          cat.description.toLowerCase().contains(q) ||
          cat.id.toLowerCase().contains(q);
    }).toList();

    // 2. Filter specific services
    final allServices = [..._cleaningServices, ..._repairServices];
    final matchingServices = allServices.where((s) {
      return s['title']!.toLowerCase().contains(q) ||
          s['category']!.toLowerCase().contains(q);
    }).toList();

    // 3. Filter workers
    final matchingWorkers = serviceState.workers.where((w) {
      return w.name.toLowerCase().contains(q) ||
          w.categoryName.toLowerCase().contains(q) ||
          w.bio.toLowerCase().contains(q);
    }).toList();

    final nonDuplicateServices = matchingServices.where(
      (s) => !matchingCategories.any(
        (c) => c.title.toLowerCase() == s['title']!.toLowerCase(),
      ),
    ).toList();

    final totalMatches = matchingCategories.length +
        nonDuplicateServices.length +
        matchingWorkers.length;

    if (totalMatches == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No services found for "$_searchQuery"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try searching for Plumber, Cleaner, AC Repair, Electrician or Carpenter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear Search'),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Results ($totalMatches)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Matching Categories
        ...matchingCategories.map((cat) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF262626)
                    : const Color(0xFFF1F5F9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, color: cat.color, size: 24),
              ),
              title: Text(
                cat.title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                '${cat.description}\nStarting from ₹${cat.basePrice.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              onTap: () => _openFindExpert(cat.title, cat.id),
            ),
          );
        }),

        // Matching Specific Services
        ...nonDuplicateServices.map((srv) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF262626)
                    : const Color(0xFFF1F5F9),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  srv['imageUrl']!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.build_rounded, size: 20),
                  ),
                ),
              ),
              title: Text(
                srv['title']!,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'Category: ${srv['category']}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              onTap: () => _openFindExpert(srv['category']!, srv['categoryId']!),
            ),
          );
        }),

        // Matching Technicians
        if (matchingWorkers.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Matching Technicians',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          ...matchingWorkers.map((w) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF262626)
                      : const Color(0xFFF1F5F9),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: AppAvatar(
                  avatarUrl: w.avatarUrl,
                  name: w.name,
                  radius: 20,
                ),
                title: Text(
                  w.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${w.categoryName} • ${w.rating} ⭐ (${w.totalReviews} reviews) • ₹${w.hourlyRate.toStringAsFixed(0)}/hr',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _openFindExpert(w.categoryName, w.categoryId),
                  child: const Text(
                    'Book',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  void _openFindExpert(String categoryTitle, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FindExpertWorkersScreen(
          categoryTitle: categoryTitle,
          categoryId: categoryId,
        ),
      ),
    );
  }

  Widget _buildCategoryIconCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 74,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicePhotoCard({
    required String title,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo Image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.blue.shade50,
                  child: const Center(
                    child: Icon(
                      Icons.handyman_rounded,
                      color: Color(0xFF0F4C81),
                      size: 36,
                    ),
                  ),
                ),
              ),

              // Subtle bottom dark gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Label Pill Overlay
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedWorkersTab(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Technicians',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your bookmarked expert home service technicians',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSavedCard(
                    'Ramesh Kumar',
                    'Expert Home Plumber',
                    '★ 4.8 • ₹199/hr',
                  ),
                  const SizedBox(height: 12),
                  _buildSavedCard(
                    'Suresh Sharma',
                    'Expert Home Plumber',
                    '★ 4.7 • ₹149/hr',
                  ),
                  const SizedBox(height: 12),
                  _buildSavedCard(
                    'Manoj Tiwari',
                    'Master Plumber',
                    '★ 4.9 • ₹299/hr',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(String name, String role, String rating) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? Border.all(color: const Color(0xFF262626), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.blue.shade100,
              child: const Icon(Icons.person, color: Color(0xFF0F4C81)),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textColor,
              ),
            ),
            subtitle: Text(
              '$role\n$rating',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkSubtitleColor : Colors.grey.shade700,
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookingFlowScreen(initialStep: 2),
                  ),
                );
              },
              child: const Text('Book', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }


  void _showLocationSelectorBottomSheet(
    BuildContext context,
    LocationProvider locationProvider,
    AuthProvider authProvider,
    BookingProvider bookingProvider,
  ) {
    showAppLocationSelectorBottomSheet(
      context,
      locationProvider,
      authProvider,
      bookingProvider,
    );
  }
}

void showAppLocationSelectorBottomSheet(
  BuildContext context,
  LocationProvider locationProvider,
  AuthProvider authProvider,
  BookingProvider bookingProvider,
) {
  final searchCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> popularLocalities = [
      {
        'short': 'Sector 18, Noida',
        'full': 'Sector 18, Noida, Uttar Pradesh, 201301',
        'lat': 28.5708,
        'lon': 77.3271,
      },
      {
        'short': 'Connaught Place, Delhi',
        'full': 'Connaught Place, Central Delhi, New Delhi, 110001',
        'lat': 28.6315,
        'lon': 77.2167,
      },
      {
        'short': 'Indiranagar, Bengaluru',
        'full': '100ft Road, Indiranagar, Bengaluru, Karnataka, 560038',
        'lat': 12.9784,
        'lon': 77.6408,
      },
      {
        'short': 'Cyber City, Gurugram',
        'full': 'DLF Cyber City, Sector 24, Gurugram, Haryana, 122002',
        'lat': 28.4950,
        'lon': 77.0895,
      },
      {
        'short': 'Hitec City, Hyderabad',
        'full': 'Madhapur, Hitec City, Hyderabad, Telangana, 500081',
        'lat': 17.4474,
        'lon': 78.3762,
      },
      {
        'short': 'Bandra West, Mumbai',
        'full': 'Hill Road, Bandra West, Mumbai, Maharashtra, 400050',
        'lat': 19.0596,
        'lon': 72.8295,
      },
      {
        'short': 'Koregaon Park, Pune',
        'full': 'Koregaon Park, Pune, Maharashtra, 411001',
        'lat': 18.5362,
        'lon': 73.8940,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredPopular = popularLocalities.where((loc) {
              return loc['short']!.toLowerCase().contains(query) ||
                  loc['full']!.toLowerCase().contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0284C7,
                              ).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF0284C7),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Select Service Location',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Field
                  TextField(
                    controller: searchCtrl,
                    onChanged: (val) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search city, sector, area or pincode...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF0284C7),
                      ),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                searchCtrl.clear();
                                setModalState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Action Button: Use Live Current Location (GPS)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Detecting live device GPS location...'),
                            ],
                          ),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      await locationProvider.fetchLiveLocation();
                      bookingProvider.setDraftLocation(
                        locationProvider.currentAddress,
                        locationProvider.isLiveLocation
                            ? 'GPS Auto-Detected'
                            : locationProvider.shortLocation,
                      );
                      if (context.mounted) {
                        if (locationProvider.errorMessage != null &&
                            !locationProvider.isLiveLocation) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.orange.shade800,
                              content: Text(
                                '⚠️ ${locationProvider.errorMessage}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF10B981),
                              content: Text(
                                '📍 Live GPS Location: ${locationProvider.shortLocation}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: locationProvider.isLiveLocation
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : (isDark
                                  ? const Color(0xFF121212)
                                  : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: locationProvider.isLiveLocation
                              ? const Color(0xFF10B981)
                              : Colors.grey.withValues(alpha: 0.2),
                          width: locationProvider.isLiveLocation ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.my_location_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Use Live Current Location',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'LIVE GPS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  locationProvider.currentAddress,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (locationProvider.isLiveLocation)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Saved Addresses
                        if (authProvider.savedAddresses.isNotEmpty) ...[
                          Text(
                            'Saved Addresses',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...authProvider.savedAddresses.map((addr) {
                            final isSelected =
                                !locationProvider.isLiveLocation &&
                                locationProvider.currentAddress == addr;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                tileColor: isSelected
                                    ? const Color(
                                        0xFF0284C7,
                                      ).withValues(alpha: 0.1)
                                    : (isDark
                                          ? const Color(0xFF121212)
                                          : const Color(0xFFF8FAFC)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFF0284C7)
                                        : Colors.grey.withValues(alpha: 0.15),
                                  ),
                                ),
                                leading: Icon(
                                  addr.contains('Home')
                                      ? Icons.home_rounded
                                      : addr.contains('Office')
                                      ? Icons.business_rounded
                                      : Icons.place_rounded,
                                  color: const Color(0xFF0284C7),
                                ),
                                title: Text(
                                  addr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF0284C7),
                                        size: 18,
                                      )
                                    : null,
                                onTap: () {
                                  locationProvider.setManualLocation(addr);
                                  bookingProvider.setDraftLocation(
                                    addr,
                                    'Saved Address',
                                  );
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '📍 Location changed to: ${locationProvider.shortLocation}',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 14),
                        ],

                        // Popular Localities / Matching search results
                        Text(
                          query.isNotEmpty
                              ? 'Matching Localities'
                              : 'Popular Service Localities',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...filteredPopular.map((item) {
                          final isSelected =
                              !locationProvider.isLiveLocation &&
                              (locationProvider.shortLocation ==
                                      item['short'] ||
                                  locationProvider.currentAddress ==
                                      item['full']);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              tileColor: isSelected
                                  ? const Color(
                                      0xFF0284C7,
                                    ).withValues(alpha: 0.1)
                                  : (isDark
                                        ? const Color(0xFF121212)
                                        : const Color(0xFFF8FAFC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF0284C7)
                                      : Colors.grey.withValues(alpha: 0.15),
                                ),
                              ),
                              leading: const Icon(
                                Icons.location_city_rounded,
                                color: Color(0xFF0284C7),
                              ),
                              title: Text(
                                item['short']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                item['full']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF0284C7),
                                      size: 18,
                                    )
                                  : null,
                              onTap: () {
                                locationProvider.setManualLocation(
                                  item['full']! as String,
                                  shortLabel: item['short']! as String,
                                  lat: item['lat'] as double?,
                                  lon: item['lon'] as double?,
                                );
                                bookingProvider.setDraftLocation(
                                  item['full']! as String,
                                  item['short']! as String,
                                );
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '📍 Location changed to: ${item['short']}',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          );
                        }),

                        // If user entered custom text not matching predefined options
                        if (query.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          ListTile(
                            tileColor: const Color(
                              0xFF0284C7,
                            ).withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xFF0284C7)),
                            ),
                            leading: const Icon(
                              Icons.add_location_alt_rounded,
                              color: Color(0xFF0284C7),
                            ),
                            title: Text(
                              'Use: "${searchCtrl.text}"',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: const Text(
                              'Tap to apply this custom address',
                              style: TextStyle(fontSize: 11),
                            ),
                            onTap: () {
                              final text = searchCtrl.text.trim();
                              locationProvider.setManualLocation(text);
                              bookingProvider.setDraftLocation(
                                text,
                                'Manual Address',
                              );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '📍 Location updated: ${locationProvider.shortLocation}',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
