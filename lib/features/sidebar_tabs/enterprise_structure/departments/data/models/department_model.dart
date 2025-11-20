

import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/data/models/location_model.dart';

class DepartmentsModel {
  final String message;
  final int total;
  final List<Department> data;

  DepartmentsModel({
    required this.message,
    required this.total,
    required this.data,
  });

  factory DepartmentsModel.fromJson(Map<String, dynamic> json) {
    return DepartmentsModel(
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      data: (json['data'] as List?)
          ?.map((item) => Department.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total': total,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Department {
  final String id;
  final String departmentName;

  final String? companyId;
  final Company? company;

  final String? businessUnitId;
  final BusinessUnit? businessUnit;

  final String? locationId;
  final Location? location;

  final String? managerId;
  final Manager? manager;

  final DateTime createdAt;

  Department({
    required this.id,
    required this.departmentName,
    this.companyId,
    this.company,
    this.businessUnitId,
    this.businessUnit,
    this.locationId,
    this.location,
    this.managerId,
    this.manager,
    required this.createdAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    final compRaw = json['company'];
    final buRaw = json['businessUnit'];
    final locRaw = json['location'];
    final manRaw = json['manager'];

    return Department(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      departmentName: (json['departmentName'] ?? '') as String,

      // --- Company (can be Map or String)
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

      // --- Business Unit
      businessUnitId: buRaw is String
          ? buRaw
          : (buRaw is Map<String, dynamic>
          ? (buRaw['_id'] ?? buRaw['id']) as String?
          : null),
      businessUnit: buRaw is Map<String, dynamic>
          ? BusinessUnit.fromJson(buRaw)
          : (buRaw is String && buRaw.isNotEmpty
          ? BusinessUnit.fromJson({'_id': buRaw})
          : null),

      // --- Location
      locationId: locRaw is String
          ? locRaw
          : (locRaw is Map<String, dynamic>
          ? (locRaw['_id'] ?? locRaw['id']) as String?
          : null),
      location: locRaw is Map<String, dynamic>
          ? Location.fromJson(locRaw)
          : (locRaw is String && locRaw.isNotEmpty
          ? Location.fromJson({'_id': locRaw})
          : null),

      // --- Manager
      managerId: manRaw is String
          ? manRaw
          : (manRaw is Map<String, dynamic>
          ? (manRaw['_id'] ?? manRaw['id']) as String?
          : null),
      manager: manRaw is Map<String, dynamic>
          ? Manager.fromJson(manRaw)
          : (manRaw is String && manRaw.isNotEmpty
          ? Manager.fromJson({'_id': manRaw})
          : null),

      createdAt: _parseDate(json['createdAt'] ?? json['createdDate']) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'departmentName': departmentName,
      'company': company?.toJson() ?? companyId,
      'businessUnit': businessUnit?.toJson() ?? businessUnitId,
      'location': location?.toJson() ?? locationId,
      'manager': manager?.toJson() ?? managerId,
      'createdAt': createdAt.toIso8601String(),
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


// --- Manager
class Manager {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String department; // can be ID string
  final String designation;
  final String employeeId;
  final String role;

  Manager({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    required this.designation,
    required this.employeeId,
    required this.role,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] is String
          ? json['department']
          : (json['department']?['_id'] ?? ''),
      designation: json['designation'] ?? '',
      employeeId: json['employeeId'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'department': department,
      'designation': designation,
      'employeeId': employeeId,
      'role': role,
    };
  }
}


