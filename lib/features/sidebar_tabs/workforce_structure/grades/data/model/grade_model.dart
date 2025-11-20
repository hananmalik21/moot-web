class GradeResponse {
  final String message;
  final int total;
  final List<Grade> grades;

  GradeResponse({
    required this.message,
    required this.total,
    required this.grades,
  });

  factory GradeResponse.fromJson(Map<String, dynamic> json) {
    return GradeResponse(
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      grades:
          (json['grades'] as List<dynamic>?)
              ?.map((e) => Grade.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'total': total,
    'grades': grades.map((e) => e.toJson()).toList(),
  };
}

class Grade {
  final String id;
  final String gradeName;
  final int minSalary;
  final int maxSalary;
  final String description;
  final DateTime createdDate;

  Grade({
    required this.id,
    required this.gradeName,
    required this.minSalary,
    required this.maxSalary,
    required this.description,
    required this.createdDate,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['_id'] ?? '',
      gradeName: json['gradeName'] ?? '',
      minSalary: json['minSalary'] ?? 0,
      maxSalary: json['maxSalary'] ?? 0,
      description: json['description'] ?? '',
      createdDate:
          DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'gradeName': gradeName,
    'minSalary': minSalary,
    'maxSalary': maxSalary,
    'description': description,
    'createdDate': createdDate.toIso8601String(),
  };
}
