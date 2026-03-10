import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';

class ProfileTab extends StatelessWidget {
  final AuthProvider authProvider;

  const ProfileTab({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final user = authProvider.currentUser;

    return ListenableBuilder(
      listenable: authProvider,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Nom
              Text(
                user?.name ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 8),

              // Date inscription
              Text(
                'Membre depuis le ${user?.createdAt.day}/${user?.createdAt.month}/${user?.createdAt.year}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDisable,
                ),
              ),

              const SizedBox(height: 48),

              // Bouton déconnexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(AppStrings.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}