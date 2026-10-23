import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../customer/customer_home_screen.dart';
import '../worker/worker_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

/// Role-based direct router.
/// Seamlessly loads each role's dedicated screen without any redundant outer app bar.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentRole = authProvider.currentRole;

    switch (currentRole) {
      case UserRole.customer:
        return const CustomerHomeScreen();
      case UserRole.provider:
        return const WorkerDashboardScreen();
      case UserRole.admin:
        return const AdminDashboardScreen();
    }
  }
}
