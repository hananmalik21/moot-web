

import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/data/model/grade_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';

class PositionResponse {
  final String message;
  final int total;
  final int? page;
  final int? limit;
  final String? departmentId; // can be null per your payload
  final List<Position> positions;

  PositionResponse({
    required this.message,
    required this.total,
    this.page,
    this.limit,
    this.departmentId,
    required this.positions,
  });

  factory PositionResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['positions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Position.fromJson)
        .toList();

    return PositionResponse(
      message: (json['message'] ?? '') as String,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse('${json['total'] ?? 0}') ?? 0,
      page: json['page'] is int ? json['page'] as int : int.tryParse('${json['page'] ?? ''}'),
      limit: json['limit'] is int ? json['limit'] as int : int.tryParse('${json['limit'] ?? ''}'),
      departmentId: json['departmentId']?.toString(),
      positions: list,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'total': total,
    'page': page,
    'limit': limit,
    'departmentId': departmentId,
    'positions': positions.map((p) => p.toJson()).toList(),
  };
}

class Position {
  final String id;
  final String positionTitle;
  final String? positionTitleLower;
  final JobsModel? job;
  final Grade? grade;
  final Department? department;
  final BusinessUnit? businessUnit;
  final Company? company;
  final String positionStatus;
  final DateTime createdDate;
  final DateTime? createdAt; // present in your payload
  final DateTime? updatedAt; // present in your payload

  Position({
    required this.id,
    required this.positionTitle,
    this.positionTitleLower,
    this.job,
    this.grade,
    this.department,
    this.businessUnit,
    this.company,
    required this.positionStatus,
    required this.createdDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    // createdDate fallback logic: prefer createdDate, else createdAt, else now
    final dt = _parseDate(json['createdDate']) ??
        _parseDate(json['createdAt']) ??
        DateTime.now();

    return Position(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      positionTitle: (json['positionTitle'] ?? '') as String,
      positionTitleLower: (json['positionTitleLower'] as String?)?.trim(),
      job: _parseNested<JobsModel>(json['job'], (m) => JobsModel.fromJson(m)),
      grade: _parseNested<Grade>(json['grade'], (m) => Grade.fromJson(m)),
      department: _parseNested<Department>(json['department'], (m) => Department.fromJson(m)),
      businessUnit: _parseNested<BusinessUnit>(json['businessUnit'], (m) => BusinessUnit.fromJson(m)),
      company: _parseNested<Company>(json['company'], (m) => Company.fromJson(m)),
      positionStatus: (json['positionStatus'] ?? '') as String,
      createdDate: dt,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'positionTitle': positionTitle,
    'positionTitleLower': positionTitleLower,
    'job': job?.toJson(),
    'grade': grade?.toJson(),
    'department': department?.toJson(),
    'businessUnit': businessUnit?.toJson(),
    'company': company?.toJson(),
    'positionStatus': positionStatus,
    'createdDate': createdDate.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

/// ---------- helpers ----------

T? _parseNested<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
    ) {
  if (value is Map<String, dynamic>) return parser(value);
  // If API sometimes returns just an ID string, you can adapt here:
  // if (value is String && value.isNotEmpty) { ...construct a minimal T... }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
