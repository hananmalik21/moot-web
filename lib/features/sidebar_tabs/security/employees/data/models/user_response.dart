import 'package:moot_web/core/model/user_data_model.dart';

class UsersResponse {
  final String message;
  final int total;
  final List<User> users;

  UsersResponse({
    required this.message,
    required this.total,
    required this.users,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    var list = json['users'] as List;
    List<User> jobsList = list.map((job) => User.fromJson(job)).toList();

    return UsersResponse(
      message: json['message'] as String,
      total: json['total'] as int,
      users: jobsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total': total,
      'data': users.map((job) => job.toJson()).toList(),
    };
  }
}