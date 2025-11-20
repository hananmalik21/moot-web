import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/model/user_data_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/data/models/user_response.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/repository/users_repository_impl.dart';

class UserProvider extends ChangeNotifier {
  final UsersRepositoryImpl _usersRepositoryImpl = UsersRepositoryImpl();
  final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

  List<User> users = [];
  User? manager;
  bool isLoading = false;

  // 👇 track disposal
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // 👇 safe notifier
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void setLoading(bool val) {
    isLoading = val;
    _safeNotify();
  }

  void setManager(User? val) {
    manager = val;
    debugPrint("manager is ${manager?.firstName}");
    _safeNotify();
  }

  Future<dynamic> registerUser({
    required Map<String, dynamic> body,
    required String email,
    required Function() onSuccess,
  }) async {
    if (body["firstName"] == null ||
        body["lastName"] == null ||
        body["phoneNumber"] == null ||
        body["designation"] == null ||
        body["password"] == null ||
        body["salary"] == null) {
      Utils().showToast("Please enter required fields");
      return;
    }
    if (!emailRegExp.hasMatch(email)) {
      Utils().showToast("Please enter valid email");
      return;
    }

    setLoading(true);
    try {
      await _usersRepositoryImpl.createUser(body: body);
      onSuccess();
    } catch (err) {
      if (kDebugMode) log("ERROR IS ${err.toString()}");
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false); // uses _safeNotify
    }
  }

  Future<void> getUsers({String? userId, Function()? onSuccess}) async {
    setLoading(true);

    try {
      final UsersResponse value = await _usersRepositoryImpl.getUsers(
        userId: userId,
      );

      // you may want users = value.users; instead of addAll
      users.addAll(value.users);

      if (userId != null) {
        debugPrint("manager id is $userId");
        final User manager = users.firstWhere(
          (element) => element.id == userId,
        );
        setManager(manager);
      }
      onSuccess != null ? onSuccess() : null;

      if (kDebugMode) {
        log("USERS LIST LENGTH IS ${users.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
  }

  Future<dynamic> updateUser({
    required Map<String, dynamic> body,
    required String email,
    required String userId,
    required Function() onSuccess,
  }) async {
    if (body["firstName"] == null ||
        body["lastName"] == null ||
        body["phoneNumber"] == null ||
        body["designation"] == null ||
        body["salary"] == null) {
      Utils().showToast("Please enter required fields");
      return;
    }
    if (!emailRegExp.hasMatch(email)) {
      Utils().showToast("Please enter valid email");
      return;
    }

    setLoading(true);
    try {
      await _usersRepositoryImpl.updateUser(body: body, userId: userId);
      onSuccess();
    } catch (err) {
      if (kDebugMode) log("ERROR IS ${err.toString()}");
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteUser({required String userId}) async {
    setLoading(true);

    try {
      final BaseApiResponseModel value = await _usersRepositoryImpl.deleteUser(
        userId: userId,
      );

      users.removeWhere((element) => element.id == userId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("JOBS LIST LENGTH IS ${users.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
  }

  Future<void> assignRoleToUser({
    required String userId,
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      final BaseApiResponseModel value = await _usersRepositoryImpl
          .assignRoleToEmployee(userId: userId, body: body);

      Utils().showToast("${value.message}");
      onSuccess();
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
  }

  Future<void> removeRoleFromUser({
    required String userId,
    required Map<String, dynamic> body,
  }) async {
    setLoading(true);

    try {
      final roleId = '${body["roleId"]}';

      final BaseApiResponseModel value = await _usersRepositoryImpl
          .removeRoleFromEmployee(userId: userId, body: body);

      final idx = users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        final user = users[idx];

        final newRoles = List.of(user.effectiveUserRoles)
          ..removeWhere((r) => r.role.id == roleId);

        users[idx] = user.copyWith(effectiveUserRoles: newRoles);
      }

      Utils().showToast("${value.message}");
    } catch (err) {
      if (kDebugMode) log("ERROR IS ${err.toString()}");
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
  }

}
