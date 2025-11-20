class RolesResponse {
  final String? message;
  final int? total;
  final List<Role> roles;

  RolesResponse({
    this.message,
    this.total,
    List<Role>? data,
  }) : roles = data ?? [];

  factory RolesResponse.fromJson(Map<String, dynamic> json) {
    return RolesResponse(
      message: json['message'],
      total: json['total'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((roleJson) => Role.fromJson(roleJson))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total': total,
      'data': roles.map((role) => role.toJson()).toList(),
    };
  }
}

class Role {
  final String id;
  final String? name;
  final String? description;
  final List<String> permissions;
  final bool isSystemRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? v;

  Role({
    required this.id,
    this.name,
    this.description,
    this.permissions = const [],
    this.isSystemRole = false,
    required this.createdAt,
    required this.updatedAt,
    this.v,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : [],
      isSystemRole: json['isSystemRole'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'isSystemRole': isSystemRole,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}