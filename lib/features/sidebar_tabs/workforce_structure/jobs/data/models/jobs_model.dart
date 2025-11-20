class JobsModel {
  final String id;
  final String jobTitle;
  final double minSalary;
  final double maxSalary;
  final String description;
  final DateTime createdDate;
  final int v;

  JobsModel({
    required this.id,
    required this.jobTitle,
    required this.minSalary,
    required this.maxSalary,
    required this.description,
    required this.createdDate,
    required this.v,
  });

  // Factory constructor to create a Job from JSON
  factory JobsModel.fromJson(Map<String, dynamic> json) {
    return JobsModel(
      id: json['_id'] as String,
      jobTitle: json['jobTitle'] as String,
      minSalary: json['minSalary'] as double,
      maxSalary: json['maxSalary'] as double,
      description: json['description'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      v: json['__v'] as int,
    );
  }

  // Convert Job object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'jobTitle': jobTitle,
      'minSalary': minSalary,
      'maxSalary': maxSalary,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
      '__v': v,
    };
  }
}

// Optional: Wrapper class for API response
class JobsResponse {
  final String message;
  final int total;
  final List<JobsModel> data;

  JobsResponse({
    required this.message,
    required this.total,
    required this.data,
  });

  factory JobsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<JobsModel> jobsList = list.map((job) => JobsModel.fromJson(job)).toList();

    return JobsResponse(
      message: json['message'] as String,
      total: json['total'] as int,
      data: jobsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total': total,
      'data': data.map((job) => job.toJson()).toList(),
    };
  }
}
