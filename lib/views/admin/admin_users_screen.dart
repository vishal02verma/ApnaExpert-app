import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_avatar.dart';
import '../../theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _selectedRole = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF0284C7) : AppTheme.primaryColor;

    final users = authProvider.allUsers.where((u) {
      bool matchesRole = true;
      if (_selectedRole == 'Customer') matchesRole = u.role == UserRole.customer;
      if (_selectedRole == 'Provider') matchesRole = u.role == UserRole.provider;
      if (_selectedRole == 'Admin') matchesRole = u.role == UserRole.admin;

      bool matchesSearch = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesRole && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Manage Users'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search users by name or email...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: ['All', 'Customer', 'Provider', 'Admin'].map((r) {
                      final isSelected = _selectedRole == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(r),
                          selected: isSelected,
                          showCheckmark: false,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          selectedColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? primary
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A)),
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedRole = r);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: users.isEmpty
                ? const Center(child: Text('No users match the criteria.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, idx) {
                      final u = users[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: AppAvatar(
                            avatarUrl: u.avatarUrl,
                            name: u.name,
                            radius: 20,
                          ),
                          title: Row(
                            children: [
                              Text(
                                u.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (u.isBlocked) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('BLOCKED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ]
                            ],
                          ),
                          subtitle: Text('${u.email}\nPhone: ${u.phone} • Role: ${u.role.name.toUpperCase()}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: Icon(
                              u.isBlocked ? Icons.block : Icons.check_circle,
                              color: u.isBlocked ? Colors.red : Colors.green,
                            ),
                            tooltip: u.isBlocked ? 'Unblock User' : 'Block User',
                            onPressed: () {
                              authProvider.toggleUserBlockStatus(u.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    u.isBlocked
                                        ? 'User Unblocked'
                                        : 'User Blocked from System',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
