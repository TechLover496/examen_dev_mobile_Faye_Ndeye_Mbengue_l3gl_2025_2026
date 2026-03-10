import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
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
              return ProjectCard(
                project: projectProvider.projects[index],
              );
            },
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 64, color: AppColors.textDisable),
                SizedBox(height: 16),
                Text(AppStrings.noProjects,
                    style: TextStyle(
                        fontSize: 18, color: AppColors.textSecondary)),
                SizedBox(height: 8),
                Text(AppStrings.noProjectsDesc,
                    style: TextStyle(color: AppColors.textDisable)),
              ],
            ),
          ),
        );
      },
    );
  }
}