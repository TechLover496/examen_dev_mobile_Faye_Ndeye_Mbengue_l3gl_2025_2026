import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class DashboardTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const DashboardTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await projectProvider.loadProjects(
                authProvider.currentUser!.id);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message de bienvenue
                Text(
                  '${_getGreeting()}, ${authProvider.currentUser?.name ?? ''} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 24),

                // Cartes statistiques
                Row(
                  children: [
                    _buildStatCard(
                      'Projets',
                      projectProvider.projectCount.toString(),
                      Icons.folder,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'À faire',
                      (taskProvider.taskCountByStatus[TaskStatus.todo] ?? 0).toString(),
                      Icons.radio_button_unchecked,
                      AppColors.statusTodo,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'En cours',
                      (taskProvider.taskCountByStatus[TaskStatus.inProgress] ?? 0).toString(),
                      Icons.timelapse,
                      AppColors.statusInProgress,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Terminé',
                      (taskProvider.taskCountByStatus[TaskStatus.done] ?? 0).toString(),
                      Icons.check_circle,
                      AppColors.statusDone,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Projets récents
                const Text(
                  'Projets récents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Visibility(
                  visible: projectProvider.projects.isEmpty,
                  child: const Center(
                    child: Text(
                      'Aucun projet pour le moment',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),

                Visibility(
                  visible: projectProvider.projects.isNotEmpty,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projectProvider.projects.length > 3
                        ? 3
                        : projectProvider.projects.length,
                    itemBuilder: (context, index) {
                      return ProjectCard(
                        project: projectProvider.projects[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}