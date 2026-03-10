enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String projectId;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    this.assigneeId,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? assigneeId,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'projectId': projectId,
      'assigneeId': assigneeId,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TaskStatus.values.firstWhere((e) => e.name == map['status']),
      priority: TaskPriority.values.firstWhere((e) => e.name == map['priority']),
      projectId: map['projectId'] as String,
      assigneeId: map['assigneeId'] as String?,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, status: $status)';
}