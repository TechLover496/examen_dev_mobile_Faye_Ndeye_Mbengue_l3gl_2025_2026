import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;

  const ProjectFormScreen({
    super.key,
    this.project,
    required this.authProvider,
    required this.projectProvider,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedColor = '#FF0293ED';
  bool _isLoading = false;

  final List<String> _colors = [
    '#FF0293ED', '#FF22C55E', '#FFEF4444',
    '#FFF59E0B', '#FF8B5CF6', '#FFEC4899',
    '#FF14B8A6', '#FF263B4D',
  ];

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final project = _isEditing
        ? widget.project!.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
    )
        : Project(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
      ownerId: widget.authProvider.currentUser!.id,
    );

    if (_isEditing) {
      await widget.projectProvider.updateProject(project);
    } else {
      await widget.projectProvider.createProject(project);
    }

    setState(() => _isLoading = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le projet' : 'Nouveau projet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ nom
              CustomTextField(
                label: 'Nom du projet',
                controller: _nameController,
                prefixIcon: Icons.folder,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Le nom est requis';
                  if (value.length < 3) return 'Minimum 3 caractères';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ description
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                prefixIcon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Sélecteur de couleur
              const Text(
                'Couleur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final c = Color(int.parse(color.replaceAll('#', '0x')));
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: Visibility(
                        visible: isSelected,
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Aperçu en temps réel
              const Text(
                'Aperçu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              ListenableBuilder(
                listenable: _nameController,
                builder: (context, _) {
                  return ProjectCard(
                    project: Project(
                      id: 'preview',
                      name: _nameController.text.isEmpty
                          ? 'Nom du projet'
                          : _nameController.text,
                      description: _descriptionController.text,
                      color: _selectedColor,
                      ownerId: '',
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Bouton sauvegarder
              CustomButton(
                text: _isEditing ? 'Modifier' : 'Créer',
                onPressed: _save,
                isLoading: _isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}