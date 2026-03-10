enum MemberRole { owner, admin, member }

class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final MemberRole role;
  final DateTime joinedAt;

  ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.role,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  ProjectMember copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? userName,
    MemberRole? role,
    DateTime? joinedAt,
  }) {
    return ProjectMember(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory ProjectMember.fromMap(Map<String, dynamic> map) {
    return ProjectMember(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      role: MemberRole.values.firstWhere((e) => e.name == map['role']),
      joinedAt: DateTime.parse(map['joinedAt'] as String),
    );
  }

  @override
  String toString() => 'ProjectMember(userId: $userId, role: $role)';
}