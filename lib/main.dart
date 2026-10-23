import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/location_provider.dart';
import 'providers/service_provider_state.dart';
import 'providers/payout_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/role_selection_screen.dart';
import 'views/customer/welcome_onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const ApnaExpertApp());
}

class ApnaExpertApp extends StatelessWidget {
  const ApnaExpertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProviderState()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PayoutProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'ApnaExpert - Local Home Services',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: auth.themeMode,
            home: auth.isAuthenticated ? const RoleSelectionScreen() : const WelcomeOnboardingScreen(),
          );
        },
      ),
    );
  }
}
