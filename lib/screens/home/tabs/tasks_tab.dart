import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

class TasksTab extends StatelessWidget {
  final TaskProvider taskProvider;

  const TasksTab({
    super.key,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: taskProvider,
      builder: (context, _) {
        return Visibility(
          visible: taskProvider.tasks.isEmpty,
          replacement: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              return TaskCard(
                task: taskProvider.tasks[index],
              );
            },
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checklist, size: 64, color: AppColors.textDisable),
                SizedBox(height: 16),
                Text(AppStrings.noTasks,
                    style: TextStyle(
                        fontSize: 18, color: AppColors.textSecondary)),
                SizedBox(height: 8),
                Text(AppStrings.noTasksDesc,
                    style: TextStyle(color: AppColors.textDisable)),
              ],
            ),
          ),
        );
      },
    );
  }
}