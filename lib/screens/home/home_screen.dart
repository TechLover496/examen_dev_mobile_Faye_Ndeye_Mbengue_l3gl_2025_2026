import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';
import 'package:sunu_task/screens/home/tabs/profile_tab.dart';
import 'package:sunu_task/screens/home/tabs/projects_tab.dart';
import 'package:sunu_task/screens/home/tabs/tasks_tab.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;

  const HomeScreen({
    super.key,
    required this.authProvider,
    required this.projectProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _taskProvider = TaskProvider();
  }

  void _logout() async {
    await widget.authProvider.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              accountName: Text(user?.name ?? ''),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.white,
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text(AppStrings.projects),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text(AppStrings.tasks),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(AppStrings.profile),
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.error),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: _taskProvider,
          ),
          ProjectsTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
          ),
          TasksTab(taskProvider: _taskProvider),
          ProfileTab(authProvider: widget.authProvider),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisable,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tâches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),

      floatingActionButton: Visibility(
        visible: _currentIndex == 0 || _currentIndex == 1,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectFormScreen(
                authProvider: widget.authProvider,
                projectProvider: widget.projectProvider,
              ),
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}