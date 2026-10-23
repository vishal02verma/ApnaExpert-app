import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/role_selection_screen.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<double> _imageFadeAnimation;
  late Animation<double> _badgeScaleAnimation;
  late Animation<double> _badgeFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  // Gentle idle floating animation after entrance
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // 1. Top Header Entrance (slides down slightly and fades in)
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // 2. Stat badges pop in gently
    _badgeScaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _badgeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    // 3. Worker Hero Image slides up from the bottom! (Smooth bottom-to-top entrance)
    _imageSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.55),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _imageFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.70, curve: Curves.easeOut),
      ),
    );

    // 4. "Get Started" CTA Button slides up from bottom
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
      ),
    );

    // Subtle continuous floating motion for hero image
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _floatAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // Start entrance animation, then loop gentle floating
    _entranceController.forward().then((_) {
      if (mounted) {
        _floatController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFEBF3FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      // Background Decorative Concentric Rings
                      Positioned(
                        top: 140,
                        left: -60,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.blue.withValues(alpha: 0.12),
                              width: 32,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 260,
                        right: -80,
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.blue.withValues(alpha: 0.08),
                              width: 48,
                            ),
                          ),
                        ),
                      ),

                      // Main Content Layout
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),

                            // Top Heading & Subtitle with Slide + Fade Animation
                            SlideTransition(
                              position: _headerSlideAnimation,
                              child: FadeTransition(
                                opacity: _headerFadeAnimation,
                                child: Column(
                                  children: [
                                    Text(
                                      'Best Helping\nHands For You',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF0F4C81),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'With Our On-Demand Service App, We Give\nBetter Service To You.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Top Stats Row (2 Cards) with Scale + Fade Animation
                            ScaleTransition(
                              scale: _badgeScaleAnimation,
                              child: FadeTransition(
                                opacity: _badgeFadeAnimation,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildStatPill(
                                          iconWidget: const Icon(Icons.star_rounded,
                                              color: Colors.amber, size: 20),
                                          title: '2247+',
                                          subtitle: 'Customer Reviews',
                                        ),
                                        const SizedBox(width: 12),
                                        _buildStatPill(
                                          iconWidget: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.miscellaneous_services_rounded,
                                              color: Color(0xFF0284C7),
                                              size: 16,
                                            ),
                                          ),
                                          title: '40+',
                                          subtitle: 'Service Categories',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Center Floating Stat Badge (Workers)
                                    _buildStatPill(
                                      iconWidget: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF10B981),
                                        size: 18,
                                      ),
                                      title: '1500+',
                                      subtitle: 'Expert Workers',
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Hero Worker Graphic with Bottom-to-Top Slide Entrance and gentle floating
                            SlideTransition(
                              position: _imageSlideAnimation,
                              child: FadeTransition(
                                opacity: _imageFadeAnimation,
                                child: AnimatedBuilder(
                                  animation: _floatAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -_floatAnimation.value),
                                      child: child,
                                    );
                                  },
                                  child: Center(
                                    child: Container(
                                      constraints: const BoxConstraints(maxHeight: 380),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: isDark ? 0.35 : 0.08,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.asset(
                                          'assets/images/handyman_hero.jpg',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Image.network(
                                            'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800&auto=format&fit=crop&q=80',
                                            fit: BoxFit.contain,
                                            loadingBuilder: (ctx, child, progress) {
                                              if (progress == null) return child;
                                              return const SizedBox(
                                                height: 280,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color: Color(0xFF0F4C81),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (ctx, err, stack) => Container(
                                              height: 280,
                                              color: Colors.white70,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.engineering_rounded,
                                                  size: 90,
                                                  color: Color(0xFF0F4C81),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // "Get Started" CTA Button with Slide + Fade Animation
                            SlideTransition(
                              position: _buttonSlideAnimation,
                              child: FadeTransition(
                                opacity: _buttonFadeAnimation,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A66C2),
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor:
                                          const Color(0xFF0A66C2).withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (authProvider.isAuthenticated) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const RoleSelectionScreen(),
                                          ),
                                        );
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Get Started',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required Widget iconWidget,
    required String title,
    required String subtitle,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: const Color(0xFF262626)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
