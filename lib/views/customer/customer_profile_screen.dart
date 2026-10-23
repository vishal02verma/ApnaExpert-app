import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/location_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_avatar.dart';
import 'customer_home_screen.dart';
import 'welcome_onboarding_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isEditingPersonal = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _emailController = TextEditingController(text: user.email);
    _addressController = TextEditingController(
      text: user.address ?? (auth.savedAddresses.isNotEmpty ? auth.savedAddresses.first : ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showAddAddressDialog(
    BuildContext context,
    AuthProvider auth, {
    String? defaultAddress,
  }) {
    final addrController = TextEditingController(text: defaultAddress ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Saved Address'),
        content: TextField(
          controller: addrController,
          decoration: const InputDecoration(
            labelText: 'Address with Tag (e.g. Home / Office)',
            hintText: 'e.g. Sector 18, Noida (Home)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addrController.text.trim().isNotEmpty) {
                auth.addSavedAddress(addrController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address added to your account!')),
                );
              }
            },
            child: const Text('Save Address'),
          )
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Help & Support FAQ'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How does the 8-Step Service work?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: You choose a category, describe the problem, specify your address, pick a nearby verified specialist, and track real-time progress until service is done.'),
              SizedBox(height: 12),
              Text('Q: When do I share the Security PIN?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Only share the 4-digit PIN with the technician once they arrive at your location.'),
              SizedBox(height: 12),
              Text('Q: How are technicians verified?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Every professional submits identity and skill certifications vetted manually by the ApnaExpert admin team.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.currentUser;
    final isDark = authProvider.isDarkMode;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Account & Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Avatar Card
            Center(
              child: Column(
                children: [
                  AppAvatar(
                    avatarUrl: user.avatarUrl,
                    name: user.name,
                    radius: 46,
                    showEditBadge: true,
                    onTap: () {
                      showProfilePhotoOptionsSheet(
                        context: context,
                        currentAvatarUrl: user.avatarUrl,
                        onPhotoUpdated: (newUrl) async {
                          await authProvider.updateProfilePhoto(newUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(newUrl.isNotEmpty
                                        ? 'Profile photo successfully updated!'
                                        : 'Default circle avatar set!'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF0F4C81),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () {
                      showProfilePhotoOptionsSheet(
                        context: context,
                        currentAvatarUrl: user.avatarUrl,
                        onPhotoUpdated: (newUrl) async {
                          await authProvider.updateProfilePhoto(newUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(newUrl.isNotEmpty
                                        ? 'Profile photo successfully updated!'
                                        : 'Default circle avatar set!'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF0F4C81),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Change Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      side: BorderSide(
                        color: primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      setState(() {
                        _nameController.text = user.name;
                        _phoneController.text = user.phone;
                        _emailController.text = user.email;
                        _addressController.text = user.address ??
                            (authProvider.savedAddresses.isNotEmpty
                                ? authProvider.savedAddresses.first
                                : '');
                        _isEditingPersonal = true;
                      });
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: primary,
                    ),
                    label: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (authProvider.isWorkerAccount) ...[
              Card(
                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.engineering_rounded, color: Color(0xFF10B981)),
                  ),
                  title: const Text(
                    'Return to Worker Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                  ),
                  subtitle: const Text('Manage your service jobs, requests & earnings'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF059669)),
                  onTap: () {
                    authProvider.switchToWorkerMode();
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Personal Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedCrossFade(
                  crossFadeState: _isEditingPersonal
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                  firstChild: _buildReadOnlyPersonalView(context, isDark, user, primary, authProvider),
                  secondChild: _buildEditPersonalView(context, isDark, user, authProvider),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Service Location & Addresses Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Service Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit_location_alt_rounded, size: 16),
                          label: const Text('Change'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0284C7),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            showAppLocationSelectorBottomSheet(
                              context,
                              locationProvider,
                              authProvider,
                              bookingProvider,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Active Location Box (synced with Home Page)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        showAppLocationSelectorBottomSheet(
                          context,
                          locationProvider,
                          authProvider,
                          bookingProvider,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF0284C7).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: locationProvider.isLiveLocation
                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                    : const Color(0xFF0284C7).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                locationProvider.isLiveLocation
                                    ? Icons.my_location_rounded
                                    : Icons.place_rounded,
                                size: 18,
                                color: locationProvider.isLiveLocation
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0284C7),
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
                                          locationProvider.isLoading
                                              ? 'Detecting GPS...'
                                              : locationProvider.shortLocation,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (locationProvider.isLiveLocation &&
                                          !locationProvider.isLoading) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'LIVE GPS',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    locationProvider.isLoading
                                        ? 'Please wait, resolving your GPS coordinates...'
                                        : locationProvider.currentAddress,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.sync_rounded,
                                        size: 13,
                                        color: Color(0xFF0284C7),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Active Home Page Location • Tap to change',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF0284C7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Saved Addresses Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saved Addresses',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Address'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => _showAddAddressDialog(
                            context,
                            authProvider,
                            defaultAddress: locationProvider.currentAddress.contains('Detecting')
                                ? ''
                                : locationProvider.currentAddress,
                          ),
                        ),
                      ],
                    ),

                    if (authProvider.savedAddresses.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No extra saved addresses yet. You can add Home or Office address for faster booking.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF64748B) : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (locationProvider.currentAddress.isNotEmpty &&
                          !locationProvider.currentAddress.contains('Detecting'))
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(
                            Icons.bookmark_add_outlined,
                            size: 16,
                            color: Color(0xFF0284C7),
                          ),
                          label: const Text(
                            'Save current home location to saved addresses',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          onPressed: () {
                            authProvider.addSavedAddress(
                              '${locationProvider.currentAddress} (${locationProvider.isLiveLocation ? "Live GPS" : "Home"})',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Location saved to your address list!'),
                              ),
                            );
                          },
                        ),
                    ] else ...[
                      const SizedBox(height: 6),
                      ...authProvider.savedAddresses.map((addr) {
                        final isCurrentlyActive =
                            locationProvider.currentAddress == addr ||
                            addr.startsWith(locationProvider.shortLocation);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrentlyActive
                                  ? const Color(0xFF0284C7)
                                  : (isDark
                                      ? const Color(0xFF262626)
                                      : Colors.grey.shade200),
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            leading: Icon(
                              addr.toLowerCase().contains('office')
                                  ? Icons.business_rounded
                                  : Icons.home_rounded,
                              color: isCurrentlyActive
                                  ? const Color(0xFF0284C7)
                                  : AppTheme.accentOrange,
                              size: 22,
                            ),
                            title: Text(
                              addr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCurrentlyActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: isCurrentlyActive
                                ? const Text(
                                    'Active on Home Screen',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF0284C7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isCurrentlyActive)
                                  IconButton(
                                    tooltip: 'Set as Active Location',
                                    icon: const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 18,
                                      color: Color(0xFF0284C7),
                                    ),
                                    onPressed: () {
                                      locationProvider.setManualLocation(addr);
                                      bookingProvider.setDraftLocation(
                                        addr,
                                        'Saved Address',
                                      );
                                      authProvider.updateAddress(addr);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Active location set to: $addr',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                                IconButton(
                                  tooltip: 'Delete address',
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    authProvider.removeSavedAddress(addr);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Address removed.'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Preferences
            Card(
              child: Column(
                children: [
                  if (authProvider.isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_rounded, color: Colors.purple),
                      title: const Text('Admin Control Console', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                      subtitle: const Text('Access platform controls, user management & bookings'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.purple),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],
                  SwitchListTile(
                    title: const Text('Dark Mode Appearance'),
                    subtitle: Text(isDark ? 'Dark Theme Active' : 'Light Theme Active'),
                    secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: primary),
                    value: isDark,
                    onChanged: (val) {
                      authProvider.toggleTheme();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_center_outlined, color: AppTheme.secondaryColor),
                    title: const Text('Help & FAQ Support'),
                    subtitle: const Text('Learn how ApnaExpert works and safety tips'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showFaqDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.red),
                    title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Sign out of your ApnaExpert account'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                    onTap: () {
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
                          content: const Text('Are you sure you want to log out of your ApnaExpert account?'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyPersonalView(
    BuildContext context,
    bool isDark,
    UserModel user,
    Color primary,
    AuthProvider authProvider,
  ) {
    final effectiveAddress = (user.address != null && user.address!.trim().isNotEmpty)
        ? user.address!.trim()
        : (authProvider.savedAddresses.isNotEmpty
            ? authProvider.savedAddresses.first
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.badge_outlined, size: 18, color: primary),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 15),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: primary,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () {
                setState(() {
                  _nameController.text = user.name;
                  _phoneController.text = user.phone;
                  _emailController.text = user.email;
                  _addressController.text = user.address ??
                      (authProvider.savedAddresses.isNotEmpty
                          ? authProvider.savedAddresses.first
                          : '');
                  _isEditingPersonal = true;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.person_outline_rounded,
          label: 'Full Name',
          value: user.name.isNotEmpty ? user.name : 'Not set',
          isDark: isDark,
          primary: primary,
        ),
        const Divider(height: 18),
        _buildInfoTile(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: user.phone.isNotEmpty ? user.phone : 'Not provided',
          isDark: isDark,
          primary: primary,
        ),
        const Divider(height: 18),
        _buildInfoTile(
          icon: Icons.email_outlined,
          label: 'Email Address',
          value: user.email.isNotEmpty ? user.email : 'Not provided',
          isDark: isDark,
          primary: primary,
        ),
        const Divider(height: 18),
        _buildInfoTile(
          icon: Icons.home_work_outlined,
          label: 'Default Address / Home Location',
          value: effectiveAddress ?? 'No address saved yet',
          isDark: isDark,
          primary: primary,
        ),
      ],
    );
  }

  Widget _buildEditPersonalView(
    BuildContext context,
    bool isDark,
    UserModel user,
    AuthProvider authProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_note_rounded, size: 18, color: Colors.amber),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Edit Personal Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              tooltip: 'Cancel Edit',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  _nameController.text = user.name;
                  _phoneController.text = user.phone;
                  _emailController.text = user.email;
                  _addressController.text = user.address ??
                      (authProvider.savedAddresses.isNotEmpty
                          ? authProvider.savedAddresses.first
                          : '');
                  _isEditingPersonal = false;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+91 98765 43210',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address *',
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Default Service Address / Home Location',
            hintText: 'Enter house/flat, street, locality or city',
            prefixIcon: Icon(Icons.home_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _nameController.text = user.name;
                    _phoneController.text = user.phone;
                    _emailController.text = user.email;
                    _addressController.text = user.address ??
                        (authProvider.savedAddresses.isNotEmpty
                            ? authProvider.savedAddresses.first
                            : '');
                    _isEditingPersonal = false;
                  });
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Save Changes'),
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final phone = _phoneController.text.trim();
                  final email = _emailController.text.trim();
                  final address = _addressController.text.trim();

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your full name.')),
                    );
                    return;
                  }

                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your email address.')),
                    );
                    return;
                  }

                  await authProvider.updateProfile(
                    name: name,
                    phone: phone,
                    email: email,
                    address: address.isNotEmpty ? address : null,
                  );

                  if (address.isNotEmpty && context.mounted) {
                    Provider.of<LocationProvider>(context, listen: false).setManualLocation(address);
                    Provider.of<BookingProvider>(context, listen: false).setDraftLocation(address, 'Home');
                  }

                  setState(() {
                    _isEditingPersonal = false;
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Information & address saved to Firestore!'),
                          ],
                        ),
                        backgroundColor: Color(0xFF0F4C81),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
