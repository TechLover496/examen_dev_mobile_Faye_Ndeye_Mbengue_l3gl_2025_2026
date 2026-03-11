import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final String projectId;
  final TaskProvider taskProvider;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.projectId,
    required this.taskProvider,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  TaskStatus _selectedStatus = TaskStatus.todo;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final task = widget.task != null
        ? widget.task!.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      dueDate: _dueDate,
    )
        : Task(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      projectId: widget.projectId,
      dueDate: _dueDate,
    );

    if (widget.task != null) {
      await widget.taskProvider.updateTask(task);
    } else {
      await widget.taskProvider.createTask(task);
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Voulez-vous vraiment supprimer cette tâche ?'),
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
      await widget.taskProvider.deleteTask(widget.task!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Titre',
                controller: _titleController,
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Le titre est requis';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                prefixIcon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Sélecteur statut
              const Text('Statut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: TaskStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  final label = status == TaskStatus.todo ? 'À faire'
                      : status == TaskStatus.inProgress ? 'En cours' : 'Terminé';
                  final color = status == TaskStatus.todo ? AppColors.statusTodo
                      : status == TaskStatus.inProgress ? AppColors.statusInProgress
                      : AppColors.statusDone;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStatus = status),
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

              const SizedBox(height: 24),

              // Sélecteur priorité
              const Text('Priorité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  final label = priority == TaskPriority.low ? 'Basse'
                      : priority == TaskPriority.medium ? 'Moyenne' : 'Haute';
                  final color = priority == TaskPriority.low ? AppColors.priorityLow
                      : priority == TaskPriority.medium ? AppColors.priorityMedium
                      : AppColors.priorityHigh;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
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

              const SizedBox(height: 24),

              // Date d'échéance
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: Text(
                  _dueDate != null
                      ? 'Échéance : ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : 'Ajouter une date limite',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _dueDate = date);
                },
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: isEditing ? 'Modifier' : 'Créer',
                onPressed: _save,
                isLoading: _isLoading,
                width: double.infinity,
              ),

              const SizedBox(height: 16),

              // Bouton supprimer visible uniquement en mode modification
              Visibility(
                visible: isEditing,
                child: CustomButton(
                  text: 'Supprimer',
                  onPressed: _deleteTask,
                  isOutlined: true,
                  color: AppColors.error,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}