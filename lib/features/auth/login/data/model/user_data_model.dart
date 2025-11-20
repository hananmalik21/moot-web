// class UserData {
//   final String message;
//   final String accessToken;
//   final String refreshToken;
//   final User user;
//
//   UserData({
//     required this.message,
//     required this.accessToken,
//     required this.refreshToken,
//     required this.user,
//   });
//
//   factory UserData.fromJson(Map<String, dynamic> json) {
//     return UserData(
//       message: json['message'],
//       accessToken: json['accessToken'],
//       refreshToken: json['refreshToken'],
//       user: User.fromJson(json['user']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       'accessToken': accessToken,
//       'refreshToken': refreshToken,
//       'user': user.toJson(),
//     };
//   }
// }
//
// class User {
//   final String id;
//   final String fullName;
//   final String email;
//   final String role;
//   final String status;
//
//   User({
//     required this.id,
//     required this.fullName,
//     required this.email,
//     required this.role,
//     required this.status,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       fullName: json['fullName'],
//       email: json['email'],
//       role: json['role'],
//       status: json['status'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'fullName': fullName,
//       'email': email,
//       'role': role,
//       'status': status,
//     };
//   }
// }
