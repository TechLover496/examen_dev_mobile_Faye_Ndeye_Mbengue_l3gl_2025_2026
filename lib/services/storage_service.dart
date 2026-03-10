import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/models/task.dart';

class StorageService {
  // ===== Singleton ==========
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Clés de Stockage =========
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'users';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';

  // ======== Onboarding =========
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ======== Utilisateurs =========
  Future<List<User>> getUsers() async {
    final data = _prefs.getString(_keyUsers);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => User.fromMap(e)).toList();
  }

  Future<void> saveUser(User user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs.setString(_keyUsers, jsonEncode(users.map((u) => u.toMap()).toList()));
  }

  Future<User?> getCurrentUser() async {
    final data = _prefs.getString(_keyCurrentUser);
    if (data == null) return null;
    return User.fromMap(jsonDecode(data));
  }

  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // ======== Projets =========
  Future<List<Project>> getProjectsByUser(String userId) async {
    final data = _prefs.getString(_keyProjects);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Project.fromMap(e)).where((p) => p.ownerId == userId).toList();
  }

  Future<void> saveProject(Project project) async {
    final data = _prefs.getString(_keyProjects);
    final List<dynamic> list = data != null ? jsonDecode(data) : [];
    final projects = list.map((e) => Project.fromMap(e)).toList();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  Future<void> deleteProject(String projectId) async {
    final data = _prefs.getString(_keyProjects);
    if (data == null) return;
    final List<dynamic> list = jsonDecode(data);
    final projects = list.map((e) => Project.fromMap(e)).where((p) => p.id != projectId).toList();
    await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
    await deleteTasksByProject(projectId);
  }

  // ======== Tâches =========
  Future<List<Task>> getTasksByProject(String projectId) async {
    final data = _prefs.getString(_keyTasks);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Task.fromMap(e)).where((t) => t.projectId == projectId).toList();
  }

  Future<List<Task>> getAllTasks() async {
    final data = _prefs.getString(_keyTasks);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> saveTask(Task task) async {
    final data = _prefs.getString(_keyTasks);
    final List<dynamic> list = data != null ? jsonDecode(data) : [];
    final tasks = list.map((e) => Task.fromMap(e)).toList();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> deleteTask(String taskId) async {
    final data = _prefs.getString(_keyTasks);
    if (data == null) return;
    final List<dynamic> list = jsonDecode(data);
    final tasks = list.map((e) => Task.fromMap(e)).where((t) => t.id != taskId).toList();
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> deleteTasksByProject(String projectId) async {
    final data = _prefs.getString(_keyTasks);
    if (data == null) return;
    final List<dynamic> list = jsonDecode(data);
    final tasks = list.map((e) => Task.fromMap(e)).where((t) => t.projectId != projectId).toList();
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }
}