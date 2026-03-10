import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  // Propriétés privées
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // Getters publics
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  // Charger les projets d'un utilisateur
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    _projects = await StorageService.instance.getProjectsByUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  // Créer un projet
  Future<void> createProject(Project project) async {
    await StorageService.instance.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }

  // Modifier un projet
  Future<void> updateProject(Project project) async {
    await StorageService.instance.saveProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  // Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    await StorageService.instance.deleteProject(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    if (_selectedProject?.id == projectId) {
      _selectedProject = null;
    }
    notifyListeners();
  }

  // Sélectionner un projet
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}