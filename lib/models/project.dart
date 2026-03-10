class Project {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String ownerId;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.ownerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name)';
}