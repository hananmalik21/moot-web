import 'dart:convert';

import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';

class BusinessUnitsResponse {
  final String? message;
  final int? count;
  final List<BusinessUnit> businessUnits;

  BusinessUnitsResponse({
    this.message,
    this.count,
    List<BusinessUnit>? data,
  }) : businessUnits = data ?? [];

  factory BusinessUnitsResponse.fromJson(Map<String, dynamic> json) {
    return BusinessUnitsResponse(
      message: json['message'] as String?,
      count: json['count'] as int?,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BusinessUnit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'count': count,
      'data': businessUnits.map((b) => b.toJson()).toList(),
    };
  }

  factory BusinessUnitsResponse.fromRawJson(String source) =>
      BusinessUnitsResponse.fromJson(json.decode(source));

  String toRawJson() => json.encode(toJson());
}

class BusinessUnit {
  final String id;
  final String businessUnitName;
  final String? companyId;
  final Company? company;
  final String? address;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  BusinessUnit({
    required this.id,
    required this.businessUnitName,
    this.companyId,
    this.company,
    this.address,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory BusinessUnit.fromJson(Map<String, dynamic> json) {
    final compRaw = json['company'];

    return BusinessUnit(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      businessUnitName: (json['businessUnitName'] ?? '') as String,

      // --- Handle company as String or Map ---
      companyId: compRaw is String
          ? compRaw
          : (compRaw is Map<String, dynamic>
          ? (compRaw['_id'] ?? compRaw['id']) as String?
          : null),
      company: compRaw is Map<String, dynamic>
          ? Company.fromJson(compRaw)
          : (compRaw is String && compRaw.isNotEmpty
          ? Company.fromJson({'_id': compRaw})
          : null),

      address: json['address'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      v: json['__v'] is int ? json['__v'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'businessUnitName': businessUnitName,
      'company': company?.toJson() ?? companyId,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}



