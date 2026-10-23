import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import 'admin_bookings_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_providers_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_users_screen.dart';
import 'admin_payouts_screen.dart';
import '../../models/payout_model.dart';
import '../../providers/payout_provider.dart';
import '../customer/welcome_onboarding_screen.dart';
import '../customer/customer_home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _adminNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    final List<Widget> adminPages = [
      _buildAdminHomeOverview(context),
      const AdminUsersScreen(),
      const AdminProvidersScreen(),
      const AdminCategoriesScreen(),
      const AdminBookingsScreen(),
      const AdminReviewsScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      body: SafeArea(child: adminPages[_adminNavIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BottomNavigationBar(
            currentIndex: _adminNavIndex,
            selectedItemColor: primary,
            unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500),
            onTap: (index) => setState(() => _adminNavIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.dashboard_rounded, color: primary),
                ),
                label: 'Overview',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline_rounded),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.people_rounded, color: primary),
                ),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.engineering_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.engineering_rounded, color: primary),
                ),
                label: 'Providers',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.category_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.category_rounded, color: primary),
                ),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark_border_rounded),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.bookmark_rounded, color: primary),
                ),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.rate_review_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.rate_review_rounded, color: primary),
                ),
                label: 'Reviews',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHomeOverview(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceState = Provider.of<ServiceProviderState>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final payoutProvider = Provider.of<PayoutProvider>(context);

    final totalUsers = authProvider.allUsers.length;
    final totalWorkers = serviceState.workers.length;
    final totalCategories = serviceState.allCategoriesAdmin.length;
    final totalBookings = bookingProvider.allBookings.length;
    final pendingPayouts = payoutProvider.allPayouts.where((p) => p.status == PayoutStatus.pending).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 38, color: Colors.amber),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ApnaExpert Admin Console',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage Users, Providers, Categories & System',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Go to Home App',
                  icon: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                      );
                    }
                  },
                ),
                IconButton(
                  tooltip: authProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  icon: Icon(
                    authProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => authProvider.toggleTheme(),
                ),
                IconButton(
                  tooltip: 'Log Out',
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Row(
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Log Out'),
                          ],
                        ),
                        content: const Text('Are you sure you want to log out of Admin Console?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await authProvider.logout();
                              if (!context.mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const WelcomeOnboardingScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Overview Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildAdminStatCard(
                title: 'Total Users',
                value: '$totalUsers',
                icon: Icons.group_rounded,
                color: Colors.blue,
                onTap: () => setState(() => _adminNavIndex = 1),
              ),
              _buildAdminStatCard(
                title: 'Service Workers',
                value: '$totalWorkers',
                icon: Icons.engineering_rounded,
                color: Colors.orange,
                onTap: () => setState(() => _adminNavIndex = 2),
              ),
              _buildAdminStatCard(
                title: 'Categories',
                value: '$totalCategories',
                icon: Icons.grid_view_rounded,
                color: Colors.green,
                onTap: () => setState(() => _adminNavIndex = 3),
              ),
              _buildAdminStatCard(
                title: 'Bookings',
                value: '$totalBookings',
                icon: Icons.receipt_long_rounded,
                color: Colors.purple,
                onTap: () => setState(() => _adminNavIndex = 4),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Admin Quick Action Shortcuts
          const Text(
            'Quick Admin Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_add_rounded, color: Colors.blue),
                  title: const Text('Manage Customer Accounts'),
                  subtitle: const Text('Block or view customer list'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _adminNavIndex = 1),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_rounded, color: Colors.orange),
                  title: const Text('Approve / Verify Providers'),
                  subtitle: const Text('Review worker applications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _adminNavIndex = 2),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.add_business_rounded, color: Colors.green),
                  title: const Text('Manage Categories & Rates'),
                  subtitle: const Text('Add or update base prices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _adminNavIndex = 3),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.flag_rounded, color: Colors.red),
                  title: const Text('Moderate Reviews & Reports'),
                  subtitle: const Text('Inspect flagged comments'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _adminNavIndex = 5),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payments_rounded, color: Colors.purple),
                  title: const Text('Worker Payouts & Withdrawals'),
                  subtitle: Text(
                    pendingPayouts > 0
                        ? '$pendingPayouts pending withdrawal request${pendingPayouts > 1 ? "s" : ""}'
                        : 'Review, process & approve technician withdrawals',
                    style: TextStyle(
                      color: pendingPayouts > 0 ? Colors.purple.shade700 : null,
                      fontWeight: pendingPayouts > 0 ? FontWeight.bold : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pendingPayouts > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade700,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$pendingPayouts NEW',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminPayoutsScreen()),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAdminStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
