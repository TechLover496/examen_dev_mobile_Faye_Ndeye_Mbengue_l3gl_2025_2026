import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class ProjectsTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;

  const ProjectsTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, _) {
        return Visibility(
          visible: projectProvider.projects.isEmpty,
          replacement: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projectProvider.projects.length,
            itemBuilder: (context, index) {
              final project = projectProvider.projects[index];
              return ProjectCard(
                project: project,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailScreen(
                      project: project,
                      authProvider: authProvider,
                      projectProvider: projectProvider,
                    ),
                  ),
                ),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectFormScreen(
                      project: project,
                      authProvider: authProvider,
                      projectProvider: projectProvider,
                    ),
                  ),
                ),
                onDelete: () async {
                  await projectProvider.deleteProject(project.id);
                },
              );
            },
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_off, size: 64, color: AppColors.textDisable),
                const SizedBox(height: 16),
                const Text(AppStrings.noProjects,
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text(AppStrings.noProjectsDesc,
                    style: TextStyle(color: AppColors.textDisable)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectFormScreen(
                        authProvider: authProvider,
                        projectProvider: projectProvider,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Créer un projet'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}