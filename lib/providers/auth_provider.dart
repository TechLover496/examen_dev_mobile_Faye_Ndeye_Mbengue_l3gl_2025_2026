import 'package:flutter/material.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthProvider extends ChangeNotifier {
  // Propriétés privées
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters publics
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charge l'utilisateur depuis le stockage
  Future<void> init() async {
    _currentUser = await StorageService.instance.getCurrentUser();
    notifyListeners();
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await StorageService.instance.getUsers();
      final user = users.firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception('Email ou mot de passe incorrect'),
      );
      _currentUser = user;
      await StorageService.instance.saveCurrentUser(user);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Inscription
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await StorageService.instance.getUsers();
      final exists = users.any((u) => u.email == email);
      if (exists) {
        _error = 'Un compte existe déjà avec cet email';
        return false;
      }

      final newUser = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
      );

      await StorageService.instance.saveUser(newUser);
      _currentUser = newUser;
      await StorageService.instance.saveCurrentUser(newUser);
      return true;
    } catch (e) {
      _error = 'Une erreur est survenue';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await StorageService.instance.clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }

  // Mise à jour profil
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name, email: email);
    await StorageService.instance.saveUser(_currentUser!);
    await StorageService.instance.saveCurrentUser(_currentUser!);
    notifyListeners();
  }

  // Efface le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}