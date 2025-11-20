import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/data/models/permission_model.dart' show Permission, PermissionsResponse;
import 'package:moot_web/features/sidebar_tabs/security/permissions/repository/permission_repository_impl.dart';

class PermissionProvider extends ChangeNotifier {
  final PermissionsRepositoryImpl _permissionsRepositoryImpl = PermissionsRepositoryImpl();

  List<Permission> permissions = [];
  Permission? selectedPermission;
  bool isLoading = false;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  setPermission(Permission val) {
    selectedPermission = val;
    log("permission is ${selectedPermission?.id}");
    notifyListeners();
  }

  Future<void> getPermissions({String? permissionId,Function()? onSuccess}) async {
    setLoading(true);

    try {
      PermissionsResponse value = await _permissionsRepositoryImpl.getPermissions();

      permissions.addAll(value.permissions);
      if (permissionId != null) {
        Permission? permission = permissions.firstWhere((element) => element.id == permissionId);
        setPermission(permission);
        onSuccess != null ? onSuccess() : null;
      }

      if (kDebugMode) {
        log("LOCATIONS LIST LENGTH IS ${permissions.length}");
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



  Future<void> createPermission({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _permissionsRepositoryImpl.createPermission(
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${permissions.length}");
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

  Future<void> updatePermission({
    required Map<String, dynamic> body,
    required String permissionId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _permissionsRepositoryImpl.updatePermission(
        permissionId: permissionId,
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${permissions.length}");
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

  deletePermission({required String permissionId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _permissionsRepositoryImpl.deletePermission(
        permissionId: permissionId,
      );

      permissions.removeWhere((element) => element.id == permissionId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("JOBS LIST LENGTH IS ${permissions.length}");
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
