class PermissionsResponse {
  final String? message;
  final int? count;
  final List<Permission> permissions;

  PermissionsResponse({
    this.message,
    this.count,
    List<Permission>? data,
  }) : permissions = data ?? [];

  factory PermissionsResponse.fromJson(Map<String, dynamic> json) {
    return PermissionsResponse(
      message: json['message'],
      count: json['count'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((item) => Permission.fromJson(item))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'count': count,
      'data': permissions.map((p) => p.toJson()).toList(),
    };
  }
}

class Permission {
  final String id;
  final String key;
  final String label;
  final String group;
  final String? module;
  final bool isActive;
  final bool? isSystemPermission;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Permission({
    required this.id,
    required this.key,
    required this.label,
    required this.group,
    this.module,
    required this.isActive,
    this.isSystemPermission,
    this.createdAt,
    this.updatedAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['_id'] ?? '',
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      group: json['group'] ?? '',
      module: json['module'],
      isActive: json['isActive'] ?? false,
      isSystemPermission: json['isSystemPermission'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'key': key,
      'label': label,
      'group': group,
      'module': module,
      'isActive': isActive,
      'isSystemPermission': isSystemPermission,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
