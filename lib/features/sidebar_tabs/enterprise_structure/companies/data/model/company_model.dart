import 'dart:convert';

class CompaniesResponse {
  final String? message;
  final int? count;
  final List<Company> companies;

  CompaniesResponse({
    this.message,
    this.count,
    List<Company>? data,
  }) : companies = data ?? [];

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    return CompaniesResponse(
      message: json['message'] as String?,
      count: json['count'] as int?,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Company.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'count': count,
      'data': companies.map((c) => c.toJson()).toList(),
    };
  }

  /// Convenience helpers if you handle raw strings
  factory CompaniesResponse.fromRawJson(String source) =>
      CompaniesResponse.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}


class Company {
  final String id;
  final String companyName;
  final String? description;
  final String? address;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v; // maps __v

  Company({
    required this.id,
    required this.companyName,
    this.description,
    this.address,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id'] ?? '',
      companyName: json['companyName'] ?? '',
      description: json['description'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'companyName': companyName,
      'description': description,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  Company copyWith({
    String? id,
    String? companyName,
    String? description,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      description: description ?? this.description,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  /// Optional helper for raw JSON string parsing
  factory Company.fromRawJson(String str) =>
      Company.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

