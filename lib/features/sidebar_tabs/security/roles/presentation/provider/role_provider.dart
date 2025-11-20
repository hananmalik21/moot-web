import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/data/models/role_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/repository/role_repository_impl.dart';

class RoleProvider extends ChangeNotifier {
  final RolesRepositoryImpl _rolesRepositoryImpl = RolesRepositoryImpl();

  List<Role> roles = [];
  Role? selectedRole;
  bool isLoading = false;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  setRole(Role val) {
    selectedRole = val;
    log("role is ${selectedRole?.id}");
    notifyListeners();
  }

  Future<void> getRoles({String? roleId,Function()? onSuccess}) async {
    setLoading(true);

    try {
      RolesResponse value = await _rolesRepositoryImpl.getRoles();

      roles.addAll(value.roles);
      if (roleId != null) {
        Role? role = roles.firstWhere((element) => element.id == roleId);
        setRole(role);
        onSuccess != null ? onSuccess() : null;
      }

      if (kDebugMode) {
        log("LOCATIONS LIST LENGTH IS ${roles.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }



  Future<void> createRole({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _rolesRepositoryImpl.createRole(
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${roles.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  Future<void> updateRole({
    required Map<String, dynamic> body,
    required String roleId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _rolesRepositoryImpl.updateRole(
        roleId: roleId,
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${roles.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  deleteRole({required String roleId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _rolesRepositoryImpl.deleteRole(
        roleId: roleId,
      );

      roles.removeWhere((element) => element.id == roleId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("JOBS LIST LENGTH IS ${roles.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }
}
