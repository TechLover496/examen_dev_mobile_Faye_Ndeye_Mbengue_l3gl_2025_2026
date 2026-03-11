import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final TaskProvider taskProvider;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la tâche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskFormScreen(
                  task: task,
                  projectId: task.projectId,
                  taskProvider: taskProvider,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Statut
            Row(
              children: [
                const Text('Statut : ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Priorité
            Row(
              children: [
                const Text('Priorité : ', style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.flag, color: _getPriorityColor(), size: 18),
                const SizedBox(width: 4),
                Text(_getPriorityLabel(), style: TextStyle(color: _getPriorityColor())),
              ],
            ),

            const SizedBox(height: 12),

            // Date échéance
            Visibility(
              visible: task.dueDate != null,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    task.dueDate != null
                        ? 'Échéance : ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'
                        : '',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Visibility(
              visible: task.description != null && task.description!.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(task.description ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Changement rapide de statut
            const Text('Changer le statut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            Row(
              children: TaskStatus.values.map((status) {
                final isSelected = task.status == status;
                final label = status == TaskStatus.todo ? 'À faire'
                    : status == TaskStatus.inProgress ? 'En cours' : 'Terminé';
                final color = status == TaskStatus.todo ? AppColors.statusTodo
                    : status == TaskStatus.inProgress ? AppColors.statusInProgress
                    : AppColors.statusDone;
                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await taskProvider.updateTaskStatus(task.id, status);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.todo: return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done: return AppColors.statusDone;
    }
  }

  String _getStatusLabel() {
    switch (task.status) {
      case TaskStatus.todo: return 'À faire';
      case TaskStatus.inProgress: return 'En cours';
      case TaskStatus.done: return 'Terminé';
    }
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.low: return AppColors.priorityLow;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.high: return AppColors.priorityHigh;
    }
  }

  String _getPriorityLabel() {
    switch (task.priority) {
      case TaskPriority.low: return 'Basse';
      case TaskPriority.medium: return 'Moyenne';
      case TaskPriority.high: return 'Haute';
    }
  }
}