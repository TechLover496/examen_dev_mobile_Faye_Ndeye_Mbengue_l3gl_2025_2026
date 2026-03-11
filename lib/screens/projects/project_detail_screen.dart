import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';
import 'package:uuid/uuid.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.authProvider,
    required this.projectProvider,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _taskProvider = TaskProvider();
    _taskProvider.loadTasks(widget.project.id);
  }

  Future<void> _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text('Voulez-vous vraiment supprimer ce projet et toutes ses tâches ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.projectProvider.deleteProject(widget.project.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(widget.project.color.replaceAll('#', '0x')));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectFormScreen(
                  project: widget.project,
                  authProvider: widget.authProvider,
                  projectProvider: widget.projectProvider,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _deleteProject,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _taskProvider,
        builder: (context, _) {
          return Column(
            children: [
              // En-tête coloré
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: color.withAlpha(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: widget.project.description != null &&
                          widget.project.description!.isNotEmpty,
                      child: Text(
                        widget.project.description ?? '',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Chips statistiques
                    Row(
                      children: [
                        _buildChip('À faire',
                            _taskProvider.taskCountByStatus[TaskStatus.todo] ?? 0,
                            AppColors.statusTodo),
                        const SizedBox(width: 8),
                        _buildChip('En cours',
                            _taskProvider.taskCountByStatus[TaskStatus.inProgress] ?? 0,
                            AppColors.statusInProgress),
                        const SizedBox(width: 8),
                        _buildChip('Terminé',
                            _taskProvider.taskCountByStatus[TaskStatus.done] ?? 0,
                            AppColors.statusDone),
                      ],
                    ),
                  ],
                ),
              ),

              // Liste des tâches
              Expanded(
                child: Visibility(
                  visible: _taskProvider.tasks.isEmpty,
                  replacement: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: _taskProvider.tasks[index],
                        onTap: () {},
                      );
                    },
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune tâche pour ce projet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskFormScreen(
              projectId: widget.project.id,
              taskProvider: _taskProvider,
            ),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}