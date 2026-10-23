import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/worker_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider_state.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';
import 'role_selection_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final UserRole initialRole;
  const SignupScreen({super.key, this.initialRole = UserRole.customer});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late UserRole _selectedRole;

  // Common Fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Customer Field
  final _addressController = TextEditingController();

  // Worker Fields
  String _selectedCategory = 'cat_plumbing';
  String _selectedExperience = '3-5 years exp.';
  final _hourlyRateController = TextEditingController(text: '50.0');
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = true;

  @override
  void initState() {
    super.initState();
    // Public signup is only for Customer and Worker
    if (widget.initialRole == UserRole.admin) {
      _selectedRole = UserRole.customer;
    } else {
      _selectedRole = widget.initialRole;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _hourlyRateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Color _getRolePrimaryColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const Color(0xFF0F4C81);
      case UserRole.provider:
        return AppTheme.secondaryColor;
      case UserRole.admin:
        return const Color(0xFF7C3AED);
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.provider:
        return 'Worker';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Future<void> _handleSignup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final serviceProviderState = Provider.of<ServiceProviderState>(
      context,
      listen: false,
    );
    authProvider.clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms of Service to create an account.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final hourlyRate = double.tryParse(_hourlyRateController.text) ?? 50.0;

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      address: _selectedRole == UserRole.customer
          ? _addressController.text.trim()
          : null,
      serviceCategory: _selectedRole == UserRole.provider
          ? _selectedCategory
          : null,
      hourlyRate: _selectedRole == UserRole.provider ? hourlyRate : null,
    );

    if (!mounted) return;

    if (success) {
      // If Worker signed up, also register into ServiceProviderState
      if (_selectedRole == UserRole.provider) {
        final cat = serviceProviderState.categories.firstWhere(
          (c) => c.id == _selectedCategory,
          orElse: () => serviceProviderState.categories.first,
        );

        final newWorker = WorkerModel(
          id: authProvider.currentUser.id,
          userId: authProvider.currentUser.id,
          name: authProvider.currentUser.name,
          phone: authProvider.currentUser.phone,
          avatarUrl: authProvider.currentUser.avatarUrl,
          categoryId: cat.id,
          categoryName: cat.title,
          rating: 5.0,
          totalReviews: 1,
          hourlyRate: hourlyRate,
          distanceKm: 1.5,
          experience: _selectedExperience,
          isAvailable: true,
          isVerified: true,
          bio: _bioController.text.trim().isNotEmpty
              ? _bioController.text.trim()
              : 'Certified ${cat.title} technician ready for reliable doorstep service.',
        );

        serviceProviderState.registerNewWorker(newWorker);
      }

      final isFirestoreSuccess = FirestoreService.lastError == null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Account created! Logged in as ${_getRoleLabel(_selectedRole)}.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                isFirestoreSuccess
                    ? '🔥 Synced with Cloud Firestore (users collection)'
                    : '⚠️ Firestore notice: ${FirestoreService.lastError}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          backgroundColor: _getRolePrimaryColor(_selectedRole),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      // Navigate to the role screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProviderState = Provider.of<ServiceProviderState>(context);
    final isDark = authProvider.isDarkMode;
    final primaryColor = _getRolePrimaryColor(_selectedRole);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${_getRoleLabel(_selectedRole)} Account'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Prominent Role Selection Question: "Are you a Customer or Worker?"
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.06,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.help_outline_rounded,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Are you a Customer or Worker?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Choose how you want to join:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white60
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Two Large Interactive Role Cards: Customer vs Worker
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                role: UserRole.customer,
                                title: 'Customer',
                                subtitle: 'Hire Services',
                                description:
                                    'Looking for home repair & cleaning services',
                                icon: Icons.person_rounded,
                                color: const Color(0xFF0F4C81),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRoleCard(
                                role: UserRole.provider,
                                title: 'Worker',
                                subtitle: 'Provide Services',
                                description:
                                    'Want to provide services & get local jobs',
                                icon: Icons.handyman_rounded,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error Display
                  if (authProvider.authError != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authProvider.authError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                            onPressed: () => authProvider.clearError(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Sign Up Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Header
                        Text(
                          'Personal Information',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Full Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            hintText: 'e.g. Rahul Sharma',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address *',
                            hintText: 'e.g. rahul@example.com',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: '+91 98765 43210',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),

                        // ROLE-SPECIFIC FIELDS
                        if (_selectedRole == UserRole.customer) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Default Service Address (Optional)',
                              hintText:
                                  'e.g. Flat 402, Shanti Heights, Sector 18, Noida',
                              prefixIcon: Icon(Icons.home_outlined),
                            ),
                          ),
                        ],

                        if (_selectedRole == UserRole.provider) ...[
                          const SizedBox(height: 18),
                          Text(
                            'Technician / Trade Details',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Service Category Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Primary Service Skill / Trade *',
                              prefixIcon: Icon(Icons.build_circle_outlined),
                            ),
                            items: serviceProviderState.categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Row(
                                  children: [
                                    Icon(cat.icon, size: 18, color: cat.color),
                                    const SizedBox(width: 8),
                                    Text(cat.title),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategory = val);
                              }
                            },
                          ),

                          const SizedBox(height: 12),

                          // Experience Level Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedExperience,
                            decoration: const InputDecoration(
                              labelText: 'Experience Level *',
                              prefixIcon: Icon(Icons.work_history_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '1-2 years exp.',
                                child: Text('1-2 Years Experience'),
                              ),
                              DropdownMenuItem(
                                value: '3-5 years exp.',
                                child: Text('3-5 Years Experience'),
                              ),
                              DropdownMenuItem(
                                value: '6-9 years exp.',
                                child: Text('6-9 Years Experience'),
                              ),
                              DropdownMenuItem(
                                value: '10+ years Master',
                                child: Text('10+ Years (Master Technician)'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedExperience = val);
                              }
                            },
                          ),

                          const SizedBox(height: 12),

                          // Hourly Rate
                          TextFormField(
                            controller: _hourlyRateController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Hourly / Standard Rate (₹) *',
                              prefixIcon: Icon(Icons.currency_rupee_rounded),
                              hintText: 'e.g. 249',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please specify standard rate';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Bio Field
                          TextFormField(
                            controller: _bioController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Short Professional Bio / Specialties',
                              hintText:
                                  'e.g. Licensed technician for residential plumbing and pipe fixes.',
                              prefixIcon: Icon(Icons.notes_rounded),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Security / Password Header
                        Text(
                          'Account Security',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Create Password *',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password *',
                            prefixIcon: const Icon(Icons.lock_reset_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Terms & Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeTerms,
                              activeColor: primaryColor,
                              onChanged: (val) =>
                                  setState(() => _agreeTerms = val ?? true),
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to ApnaExpert Terms of Service and Privacy Policy.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: authProvider.isLoading
                                ? null
                                : _handleSignup,
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create ${_getRoleLabel(_selectedRole)} Account',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Already have account
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginScreen(
                                  initialRole: _selectedRole,
                                  prefilledEmail: _emailController.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.25 : 0.08)
              : (isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? color.withValues(alpha: 0.85)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
