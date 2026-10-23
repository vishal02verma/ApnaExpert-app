import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_avatar.dart';
import '../customer/welcome_onboarding_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  late TextEditingController _rateController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final serviceState = Provider.of<ServiceProviderState>(context, listen: false);
    final worker = serviceState.getWorkerForUser(user);
    _rateController = TextEditingController(text: worker.hourlyRate.toStringAsFixed(0));
    _bioController = TextEditingController(text: worker.bio);
  }

  @override
  void dispose() {
    _rateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceState = Provider.of<ServiceProviderState>(context);
    final user = authProvider.currentUser;
    final worker = serviceState.getWorkerForUser(user);
    final isDark = authProvider.isDarkMode;
    final primary = isDark ? AppTheme.primaryLight : AppTheme.secondaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Service Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  AppAvatar(
                    avatarUrl: worker.avatarUrl,
                    name: worker.name,
                    radius: 46,
                    backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.15),
                    foregroundColor: AppTheme.secondaryColor,
                    defaultIcon: Icons.engineering_rounded,
                    showEditBadge: true,
                    onTap: () {
                      showProfilePhotoOptionsSheet(
                        context: context,
                        currentAvatarUrl: worker.avatarUrl,
                        onPhotoUpdated: (newUrl) async {
                          await authProvider.updateProfilePhoto(newUrl);
                          serviceState.updateWorkerAvatar(worker.id, newUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(newUrl.isNotEmpty
                                        ? 'Worker profile photo updated!'
                                        : 'Default circle avatar set!'),
                                  ],
                                ),
                                backgroundColor: AppTheme.secondaryColor,
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
                        currentAvatarUrl: worker.avatarUrl,
                        onPhotoUpdated: (newUrl) async {
                          await authProvider.updateProfilePhoto(newUrl);
                          serviceState.updateWorkerAvatar(worker.id, newUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(newUrl.isNotEmpty
                                        ? 'Worker profile photo updated!'
                                        : 'Default circle avatar set!'),
                                  ],
                                ),
                                backgroundColor: AppTheme.secondaryColor,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (worker.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${worker.categoryName} • ${worker.experience}',
                    style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${worker.rating} Rating (${worker.totalReviews} reviews)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Preferences & Rates',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Available for Immediate Booking Requests'),
                      subtitle: Text(
                        worker.isAvailable ? 'Currently Online' : 'Currently Offline',
                        style: TextStyle(
                          color: worker.isAvailable ? AppTheme.secondaryColor : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      value: worker.isAvailable,
                      activeThumbColor: AppTheme.secondaryColor,
                      onChanged: (val) {
                        serviceState.toggleWorkerAvailability(worker.id);
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Standard Job / Hourly Rate (₹) *',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Professional Bio & Experience Summary',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                        onPressed: () {
                          final rate = double.tryParse(_rateController.text) ?? worker.hourlyRate;
                          serviceState.updateWorkerProfile(worker.id, rate, _bioController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Technician profile updated successfully!'),
                              backgroundColor: AppTheme.secondaryColor,
                            ),
                          );
                        },
                        child: const Text('Save Service Profile'),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Verification Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      worker.isVerified ? Icons.verified_user : Icons.pending_actions,
                      color: worker.isVerified ? AppTheme.secondaryColor : Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.isVerified ? 'Identity & Skill Verified' : 'Verification Under Review',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            worker.isVerified
                                ? 'Your profile has full verified badge in search results.'
                                : 'Admin approval pending. You can still accept trial requests.',
                            style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Switch to Customer Mode Card
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0284C7)),
                ),
                title: const Text('Switch to Customer Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Hire an Electrician, Carpenter or other experts with this account'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  authProvider.switchToCustomerMode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Switched to Customer Mode! Browse and book any service.'),
                      backgroundColor: Color(0xFF0284C7),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Appearance
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode Appearance'),
                subtitle: Text(isDark ? 'Dark Theme Active' : 'Light Theme Active'),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: primary),
                value: isDark,
                onChanged: (val) {
                  authProvider.toggleTheme();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Logout Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Sign out of your technician account'),
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
                            await Provider.of<AuthProvider>(context, listen: false).logout();
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
            ),
          ],
        ),
      ),
    );
  }
}
